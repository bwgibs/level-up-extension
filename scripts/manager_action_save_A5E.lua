--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local modSaveOriginal;

function onInit()
	modSaveOriginal = ActionSave.modSave;
	ActionSave.modSave = modSave;

	ActionsManager.registerModHandler("save", modSave);
	ActionsManager.registerModHandler("death", modSave);
	ActionsManager.registerModHandler("death_auto", modSave);
	ActionsManager.registerModHandler("concentration", modSave);
	ActionsManager.registerModHandler("systemshock", modSave);
end

function modSave(rSource, rTarget, rRoll)
	modSaveOriginal(rSource, rTarget, rRoll);
	local bADV, bDIS = ActionsManagerA5E.clearAdvantage(rRoll);

	local bAutoFail = false;
	local nAddMod = 0;
	local sSave;
	if rRoll.sDesc:match("%[DEATH%]") then
		sSave = "death";
	elseif rRoll.sDesc:match("%[CONCENTRATION%]") then
		sSave = "concentration";
	elseif rRoll.sDesc:match("%[SYSTEM SHOCK%]") then
		sSave = "systemshock";
	else
		sSave = rRoll.sDesc:match("%[SAVE%] (%w+)");
		if sSave then
			sSave = sSave:lower();
		end
	end

	if rSource then
		local bEffects = false;
		if sSave == "dexterity" then
			-- Level Up
			if EffectManager5E.hasEffectCondition(rSource, "Slowed") then
				nAddMod = nAddMod - 2;
				bEffects = true;
			end
		end

		if StringManager.contains({ "strength", "dexterity", "constitution" }, sSave) then
			-- Get fatigue modifiers
			local nFatigueMod, nFatigueCount = EffectManager5E.getEffectsBonus(rSource, {"FATIGUE"}, true);
			if nFatigueCount > 0 then
				bEffects = true;
				if nFatigueMod >= 4 then
					bDIS = true;
				end
			end
		end
		if StringManager.contains({ "intelligence", "wisdom", "charisma", "concentration" }, sSave) then
			-- Get strife modifiers
			local nStrifeMod, nStrifeCount = EffectManager5E.getEffectsBonus(rSource, {"STRIFE"}, true);
			if nStrifeCount > 0 then
				bEffects = true;
				if nStrifeMod >= 2 and sSave == "concentration" then
					bDIS = true;
				end
				if nStrifeMod >= 4 and StringManager.contains({ "intelligence", "wisdom", "charisma" }, sSave) then
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

		ActionsManagerA5E.addEffectsTag(rRoll, bEffects, {}, nAddMod);
	end

	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);

	if bAutoFail then
		if not rRoll.sDesc:match("%[AUTOFAIL%]") then
			rRoll.sDesc = rRoll.sDesc .. " [AUTOFAIL]";
		end
	end
end
