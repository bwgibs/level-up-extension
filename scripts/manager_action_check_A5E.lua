--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ActionsManager.unregisterModHandler("check");
	ActionsManager.registerModHandler("check", modRoll);
end

function modRoll(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	local bADV = false;
	local bDIS = false;
	if rRoll.sDesc:match(" %[ADV%]") then
		bADV = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[ADV%]", "");
	end
	if rRoll.sDesc:match(" %[DIS%]") then
		bDIS = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
	end

	if rSource then
		local bEffects = false;

		-- Get ability used
		local sActionStat = nil;
		local sAbility = rRoll.sDesc:match("%[CHECK%] (%w+)");
		if not sAbility then
			local sSkill = rRoll.sDesc:match("%[SKILL%] (%w+)");
			if sSkill then
				sAbility = rRoll.sDesc:match("%[MOD:(%w+)%]");
				if sAbility then
					sAbility = DataCommon.ability_stol[sAbility];
				else
					for k, v in pairs(DataCommon.skilldata) do
						if k == sSkill then
							sAbility = v.stat;
						end
					end
				end
			end
		end
		if sAbility then
			sAbility = sAbility:lower();
		end

		-- Build filter
		local aCheckFilter = {};
		if sAbility then
			table.insert(aCheckFilter, sAbility);
		end

		-- Get roll effect modifiers
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, {"CHECK"}, false, aCheckFilter);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- Get condition modifiers
		if EffectManager5E.hasEffectCondition(rSource, "ADVCHK") then
			bADV = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "ADVCHK", aCheckFilter)) > 0 then
			bADV = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "DISCHK") then
			bDIS = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "DISCHK", aCheckFilter)) > 0 then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Frightened") then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Intoxicated") then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Poisoned") then
			bDIS = true;
			bEffects = true;
		end
		if StringManager.contains({ "strength", "dexterity", "constitution" }, sAbility) then
			if EffectManager5E.hasEffectCondition(rSource, "Encumbered") then
				bEffects = true;
				bDIS = true;
			end
			-- Level Up
			-- Get fatigue modifiers
			local nFatigueMod, nFatigueCount = EffectManager5E.getEffectsBonus(rSource, {"FATIGUE"}, true);
			if nFatigueCount > 0 then
				bEffects = true;
				if nFatigueMod >= 2 then
					bDIS = true;
				end
			end
		end

		-- Level Up
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

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager5E.getAbilityEffectsBonus(rSource, sAbility);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get exhaustion modifiers
		local nExhaustMod, nExhaustCount = EffectManager5E.getEffectsBonus(rSource, {"EXHAUSTION"}, true);
		if nExhaustCount > 0 then
			bEffects = true;
			if nExhaustMod >= 1 then
				bDIS = true;
			end
		end
		
		-- Level Up
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

		-- If effects happened, then add note
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	ActionsManager2.encodeDesktopMods(rRoll);
	for _,vDie in ipairs(aAddDice) do
		if vDie:sub(1,1) == "-" then
			table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
		else
			table.insert(rRoll.aDice, "p" .. vDie:sub(2));
		end
	end
	rRoll.nMod = rRoll.nMod + nAddMod;
	
	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end
