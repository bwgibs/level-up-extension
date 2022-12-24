--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local modAttackOriginal;

function onInit()
	modAttackOriginal = ActionAttack.modAttack;
	ActionAttack.modAttack = modAttack;
	ActionsManager.registerModHandler("attack", modAttack);
end

function modAttack(rSource, rTarget, rRoll)
	modAttackOriginal(rSource, rTarget, rRoll);
	local bADV, bDIS = ActionsManagerA5E.clearAdvantage(rRoll);

	if rSource then
		local bEffects = false;

		-- Get fatigue modifiers
		local nFatigueMod, nFatigueCount = EffectManager5E.getEffectsBonus(rSource, {"FATIGUE"}, true);
		if nFatigueCount > 0 then
			bEffects = true;
			if nFatigueMod >= 4 then
				bDIS = true;
			end
		end
		-- Get strife modifiers
		local nStrifeMod, nStrifeCount = EffectManager5E.getEffectsBonus(rSource, {"STRIFE"}, true);
		if nStrifeCount > 0 then
			bEffects = true;
			if nStrifeMod >= 4 then
				bDIS = true;
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
