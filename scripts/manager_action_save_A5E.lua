--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ActionsManager.unregisterModHandler("save");
	ActionsManager.unregisterModHandler("death");
	ActionsManager.unregisterModHandler("death_auto");
	ActionsManager.unregisterModHandler("concentration");
	ActionsManager.unregisterModHandler("systemshock");

	ActionsManager.registerModHandler("save", modSave);
	ActionsManager.registerModHandler("death", modSave);
	ActionsManager.registerModHandler("death_auto", modSave);
	ActionsManager.registerModHandler("concentration", modSave);
	ActionsManager.registerModHandler("systemshock", modSave);
end

function modSave(rSource, rTarget, rRoll)
	local bAutoFail = false;

	local sSave = nil;
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

	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;

	local nCover = 0;
	if sSave == "dexterity" then
		if rRoll.sSaveDesc then
			nCover = tonumber(rRoll.sSaveDesc:match("%[COVER %-(%d)%]")) or 0;
		else
			if ModifierManager.getKey("DEF_SCOVER") then
				nCover = 5;
			elseif ModifierManager.getKey("DEF_COVER") then
				nCover = 2;
			end
		end
	end

	if rSource then
		local bEffects = false;

		-- Build filter
		local aSaveFilter = {};
		if sSave then
			table.insert(aSaveFilter, sSave);
		end

		-- Get effect modifiers
		local rSaveSource = nil;
		if rRoll.sSource then
			rSaveSource = ActorManager.resolveActor(rRoll.sSource);
		end
		local aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, {"SAVE"}, false, aSaveFilter, rSaveSource);
		if nEffectCount > 0 then
			bEffects = true;
		end

		-- Get condition modifiers
		if EffectManager5E.hasEffect(rSource, "ADVSAV", rTarget) then
			bADV = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "ADVSAV", aSaveFilter, rTarget)) > 0 then
			bADV = true;
			bEffects = true;
		elseif sSave == "death" and EffectManager5E.hasEffect(rSource, "ADVDEATH") then
			bADV = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffect(rSource, "DISSAV", rTarget) then
			bDIS = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "DISSAV", aSaveFilter, rTarget)) > 0 then
			bDIS = true;
			bEffects = true;
		elseif sSave == "death" and EffectManager5E.hasEffect(rSource, "DISDEATH") then
			bDIS = true;
			bEffects = true;
		end
		if sSave == "dexterity" then
			if EffectManager5E.hasEffectCondition(rSource, "Restrained") then
				bDIS = true;
				bEffects = true;
			end
			if nCover < 5 then
				if EffectManager5E.hasEffect(rSource, "SCOVER", rTarget) then
					nCover = 5;
					bEffects = true;
				elseif nCover < 2 then
					if EffectManager5E.hasEffect(rSource, "COVER", rTarget) then
						nCover = 2;
						bEffects = true;
					end
				end
			end
			-- Level Up
			if EffectManager5E.hasEffectCondition(rSource, "Slowed") then
				nAddMod = nAddMod - 2;
				bEffects = true;
			end
		end
		if StringManager.contains({ "strength", "dexterity" }, sSave) then
			if EffectManager5E.hasEffectCondition(rSource, "Paralyzed") then
				bAutoFail = true;
				bEffects = true;
			end
			if EffectManager5E.hasEffectCondition(rSource, "Stunned") then
				bAutoFail = true;
				bEffects = true;
			end
			if EffectManager5E.hasEffectCondition(rSource, "Unconscious") then
				bAutoFail = true;
				bEffects = true;
			end
		end
		if StringManager.contains({ "strength", "dexterity", "constitution", "concentration", "systemshock" }, sSave) then
			if EffectManager5E.hasEffectCondition(rSource, "Encumbered") then
				bEffects = true;
				bDIS = true;
			end
		end
		if sSave == "dexterity" and EffectManager5E.hasEffectCondition(rSource, "Dodge") and
				not (EffectManager5E.hasEffectCondition(rSource, "Paralyzed") or
				EffectManager5E.hasEffectCondition(rSource, "Stunned") or
				EffectManager5E.hasEffectCondition(rSource, "Unconscious") or
				EffectManager5E.hasEffectCondition(rSource, "Incapacitated") or
				EffectManager5E.hasEffectCondition(rSource, "Grappled") or
				EffectManager5E.hasEffectCondition(rSource, "Restrained")) then
			bEffects = true;
			bADV = true;
		end
		-- Level Up
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
		if rRoll.sSaveDesc then
			if rRoll.sSaveDesc:match("%[MAGIC%]") then
				local bMagicResistance = false;
				if EffectManager5E.hasEffectCondition(rSource, "Magic Resistance") then
					bMagicResistance = true;
				elseif StringManager.contains({ "intelligence", "wisdom", "charisma" }, sSave) then
					if EffectManager5E.hasEffectCondition(rSource, "Gnome Cunning") then
						bMagicResistance = true;
					else
						local sSourceNodeType, nodeSource = ActorManager.getTypeAndNode(rSource);
						if nodeSource and (sSourceNodeType == "pc") then
							if CharManager.hasTrait(nodeSource, CharManager.TRAIT_GNOME_CUNNING) then
								bMagicResistance = true;
							end
						end
					end
				end
				if bMagicResistance then
					bEffects = true;
					bADV = true;
				end
			end
		end

		-- Get ability modifiers
		local sSaveAbility = nil;
		if sSave == "concentration" or sSave == "systemshock" then
			sSaveAbility = "constitution";
		elseif sSave ~= "death" then
			sSaveAbility = sSave;
		end
		if sSaveAbility then
			local nBonusStat, nBonusEffects = ActorManager5E.getAbilityEffectsBonus(rSource, sSaveAbility);
			if nBonusEffects > 0 then
				bEffects = true;
				nAddMod = nAddMod + nBonusStat;
			end
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

		-- If effects apply, then add note
		if bEffects then
			for _, vDie in ipairs(aAddDice) do
				if vDie:sub(1,1) == "-" then
					table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
				else
					table.insert(rRoll.aDice, "p" .. vDie:sub(2));
				end
			end
			rRoll.nMod = rRoll.nMod + nAddMod;

			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			rRoll.sDesc = rRoll.sDesc .. " " .. sEffects;
		end

		-- Handle War Caster feat
		if sSave == "concentration" and ActorManager.isPC(rSource) and CharManager.hasFeat(ActorManager.getCreatureNode(rSource), CharManager.FEAT_WAR_CASTER) then
			bADV = true;
			rRoll.sDesc = rRoll.sDesc .. " [" .. CharManager.FEAT_WAR_CASTER:upper() .. "]";
		end
	end

	if nCover > 0 then
		rRoll.nMod = rRoll.nMod + nCover;
		rRoll.sDesc = rRoll.sDesc .. string.format(" [COVER +%d]", nCover);
	end

	ActionsManager2.encodeDesktopMods(rRoll);
	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);

	if bAutoFail then
		rRoll.sDesc = rRoll.sDesc .. " [AUTOFAIL]";
	end
end
