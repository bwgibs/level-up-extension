--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local modRollOriginal;

function onInit()
	modRollOriginal = ActionCheck.modRoll;
	ActionCheck.modRoll = modRoll;
	ActionsManager.registerModHandler("check", modRoll);
end

function modRoll(rSource, rTarget, rRoll)
	modRollOriginal(rSource, rTarget, rRoll);
	local bADV, bDIS = ActionsManagerA5E.clearAdvantage(rRoll);

	if rSource then
		local bEffects = false;
		local sAbility = rRoll.sDesc:match("%[CHECK%] (%w+)");
		if StringManager.contains({ "strength", "dexterity", "constitution" }, sAbility) then
			-- Get fatigue modifiers
			local nFatigueMod, nFatigueCount = EffectManager5E.getEffectsBonus(rSource, {"FATIGUE"}, true);
			if nFatigueCount > 0 then
				bEffects = true;
				if nFatigueMod >= 2 then
					bDIS = true;
				end
			end
		end

		if StringManager.contains({ "intelligence", "wisdom", "charisma" }, sAbility) then
			-- Get strife modifiers
			local nStrifeMod, nStrifeCount = EffectManager5E.getEffectsBonus(rSource, {"STRIFE"}, true);
			if nStrifeCount > 0 then
				bEffects = true;
				if nStrifeMod >= 1 then
					bDIS = true;
				end
			end
		end

		-- Check for expertise die
		if not EffectManager5E.hasEffectCondition(rSource, "Rattled") then
			local bExpertiseD4 = ModifierManager.getKey("EXP_D4");
			local bExpertiseD6 = ModifierManager.getKey("EXP_D6");
			local bExpertiseD8 = ModifierManager.getKey("EXP_D8");
			local bExpertiseD10 = ModifierManager.getKey("EXP_D10");
			local bExpertiseD12 = ModifierManager.getKey("EXP_D12");

			if bExpertiseD4 then
				table.insert(rRoll.aDice, "g4");
				rRoll.sDesc = rRoll.sDesc ..  " [EXPERTISE]";
			end
			if bExpertiseD6 then
				table.insert(rRoll.aDice, "g6");
				rRoll.sDesc = rRoll.sDesc ..  " [EXPERTISE]";
			end
			if bExpertiseD8 then
				table.insert(rRoll.aDice, "g8");
				rRoll.sDesc = rRoll.sDesc ..  " [EXPERTISE]";
			end
			if bExpertiseD10 then
				table.insert(rRoll.aDice, "g10");
				rRoll.sDesc = rRoll.sDesc ..  " [EXPERTISE]";
			end
			if bExpertiseD12 then
				table.insert(rRoll.aDice, "g12");
				rRoll.sDesc = rRoll.sDesc ..  " [EXPERTISE]";
			end
		end

		ActionsManagerA5E.addEffectsTag(rRoll, bEffects);
	end

	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end
