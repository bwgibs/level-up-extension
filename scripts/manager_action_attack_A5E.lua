--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ActionAttack.modAttack = modAttack;
	ActionsManager.unregisterModHandler("attack")
	ActionsManager.registerModHandler("attack", modAttack);
end

function modAttack(rSource, rTarget, rRoll)
	ActionAttack.clearCritState(rSource);
	
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	-- Check for opportunity attack
	local bOpportunity = ModifierManager.getKey("ATT_OPP") or Input.isShiftPressed();

	if bOpportunity then
		table.insert(aAddDesc, "[OPPORTUNITY]");
	end

	-- Check defense modifiers
	local bCover = ModifierManager.getKey("DEF_COVER");
	local bSuperiorCover = ModifierManager.getKey("DEF_SCOVER");
	
	if bSuperiorCover then
		table.insert(aAddDesc, "[COVER -5]");
	elseif bCover then
		table.insert(aAddDesc, "[COVER -2]");
	end
	
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

	local aAttackFilter = {};
	if rSource then
		-- Determine attack type
		local sAttackType = rRoll.sDesc:match("%[ATTACK.*%((%w+)%)%]");
		if not sAttackType then
			sAttackType = "M";
		end

		-- Determine ability used
		local sActionStat = nil;
		local sModStat = rRoll.sDesc:match("%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		
		-- Build attack filter
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end
		
		-- Get attack effect modifiers
		local bEffects = false;
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, {"ATK"}, false, aAttackFilter, rTarget);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- Get condition modifiers
		if EffectManager5E.hasEffect(rSource, "ADVATK", rTarget) then
			bADV = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "ADVATK", aAttackFilter, rTarget)) > 0 then
			bADV = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffect(rSource, "DISATK", rTarget) then
			bDIS = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "DISATK", aAttackFilter, rTarget)) > 0 then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Blinded") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Encumbered") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Frightened") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Intoxicated") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Invisible") then
			bEffects = true;
			bADV = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Poisoned") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager.hasCondition(rSource, "Prone") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Restrained") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Unconscious") then
			bEffects = true;
		end

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager5E.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get exhaustion modifiers
		local nExhaustMod, nExhaustCount = EffectManager5E.getEffectsBonus(rSource, {"EXHAUSTION"}, true);
		if nExhaustCount > 0 then
			bEffects = true;
			if nExhaustMod >= 3 then
				bDIS = true;
			end
		end
		
		-- Level Up
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

		-- Determine crit range
		local aCritRange = EffectManager5E.getEffectsByType(rSource, "CRIT", aAttackFilter, rTarget);
		if #aCritRange > 0 then
			local nCritThreshold = 20;
			for _,v in ipairs(aCritRange) do
				if v.mod > 1 and v.mod < nCritThreshold then
					bEffects = true;
					nCritThreshold = v.mod;
				end
			end
			if nCritThreshold < 20 then
				local sRollCritThreshold = rRoll.sDesc:match("%[CRIT (%d+)%]");
				local nRollCritThreshold = tonumber(sRollCritThreshold) or 20;
				if nCritThreshold < nRollCritThreshold then
					if rRoll.sDesc:match(" %[CRIT %d+%]") then
						rRoll.sDesc = rRoll.sDesc:gsub(" %[CRIT %d+%]", " [CRIT " .. nCritThreshold .. "]");
					else
						rRoll.sDesc = rRoll.sDesc ..  " [CRIT " .. nCritThreshold .. "]";
					end
				end
			end
		end

		-- If effects, then add them
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
	
	if bSuperiorCover then
		nAddMod = nAddMod - 5;
	elseif bCover then
		nAddMod = nAddMod - 2;
	end
	
	local bDefADV, bDefDIS = ActorManager5E.getDefenseAdvantage(rSource, rTarget, aAttackFilter);
	if bDefADV then
		bADV = true;
	end
	if bDefDIS then
		bDIS = true;
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
