--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ActorHealthManager.getWoundPercent = getWoundPercent;
	ActorManager5E.getDefenseValue = getDefenseValue;
end

function getWoundPercent(v)
	local rActor = ActorManager.resolveActor(v);

	local nHP = 0;
	local nWounds = 0;
	local nDeathSaveFail = 0;

	local nodeCT = ActorManager.getCTNode(rActor);
	if nodeCT then
		nHP = math.max(DB.getValue(nodeCT, "hptotal", 0), 0);
		nWounds = math.max(DB.getValue(nodeCT, "wounds", 0), 0);
		nDeathSaveFail = DB.getValue(nodeCT, "deathsavefail", 0);
	elseif ActorManager.isPC(rActor) then
		local nodePC = ActorManager.getCreatureNode(rActor);
		if nodePC then
			nHP = math.max(DB.getValue(nodePC, "hp.total", 0), 0);
			nWounds = math.max(DB.getValue(nodePC, "hp.wounds", 0), 0);
			nDeathSaveFail = DB.getValue(nodePC, "hp.deathsavefail", 0);
		end
	end

	local nPercentWounded = 0;
	if nHP > 0 then
		nPercentWounded = nWounds / nHP;
	end

	local sStatus;
	if nPercentWounded >= 1 then
		if nDeathSaveFail >= 3 then
			sStatus = ActorHealthManager.STATUS_DEAD;
		else
			sStatus = ActorHealthManager.STATUS_DYING;
		end
	else
		sStatus = ActorHealthManager.getDefaultStatusFromWoundPercent(nPercentWounded);
	end

	-- Level Up
	local bBloodied = EffectManager5E.hasEffectCondition(rActor, "Bloodied");
	if nPercentWounded >= 0.5 and not bBloodied then
		EffectManager.addEffect("", "", nodeCT, { sName = "Bloodied", nDuration = 0 }, false);
	elseif nPercentWounded < 0.5 and bBloodied then
		EffectManager.removeEffect(nodeCT, "Bloodied");
	end

	return nPercentWounded, sStatus;
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	if not rDefender or not rRoll then
		return nil, 0, 0, false, false;
	end

	-- Base calculations
	local sAttack = rRoll.sDesc;

	local sAttackType = string.match(sAttack, "%[ATTACK.*%((%w+)%)%]");
	local bOpportunity = string.match(sAttack, "%[OPPORTUNITY%]");
	local nCover = tonumber(string.match(sAttack, "%[COVER %-(%d)%]")) or 0;

	local nDefense = 10;
	local sDefenseStat = "dexterity";

	local sNodeDefenderType, nodeDefender = ActorManager.getTypeAndNode(rDefender);
	if not nodeDefender then
		return nil, 0, 0, false, false;
	end

	if sNodeDefenderType == "pc" then
		nDefense = DB.getValue(nodeDefender, "defenses.ac.total", 10);
		sDefenseStat = DB.getValue(nodeDefender, "ac.sources.ability", "");
		if sDefenseStat == "" then
			sDefenseStat = "dexterity";
		end
	else
		nDefense = DB.getValue(nodeDefender, "ac", 10);
	end
	nDefenseStatMod = ActorManager5E.getAbilityBonus(rDefender, sDefenseStat);

	-- Effects
	local nDefenseEffectMod = 0;
	local bADV = false;
	local bDIS = false;
	if ActorManager.hasCT(rDefender) then
		local nBonusAC = 0;
		local nBonusStat = 0;
		local nBonusSituational = 0;

		local aAttackFilter = {};
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end

		local aACEffects, nACEffectCount = EffectManager5E.getEffectsBonusByType(rDefender, {"AC"}, true, aAttackFilter, rAttacker);
		for _,v in pairs(aACEffects) do
			nBonusAC = nBonusAC + v.mod;
		end

		nBonusStat = ActorManager5E.getAbilityEffectsBonus(rDefender, sDefenseStat);
		if (sNodeDefenderType == "pc") and (nBonusStat > 0) then
			local sMaxDexBonus = DB.getValue(nodeDefender, "defenses.ac.dexbonus", "");
			if sMaxDexBonus == "no" then
				nBonusStat = 0;
			elseif sMaxDexBonus == "max2" then
				local nMaxEffectStatModBonus = math.max(2 - nDefenseStatMod, 0);
				if nBonusStat > nMaxEffectStatModBonus then
					nBonusStat = nMaxEffectStatModBonus;
				end
			elseif sMaxDexBonus == "max3" then
				local nMaxEffectStatModBonus = math.max(3 - nDefenseStatMod, 0);
				if nBonusStat > nMaxEffectStatModBonus then
					nBonusStat = nMaxEffectStatModBonus;
				end
			end
		end

		local bProne = false;
		if EffectManager5E.hasEffect(rAttacker, "ADVATK", rDefender, true) then
			bADV = true;
		end
		if EffectManager5E.hasEffect(rAttacker, "DISATK", rDefender, true) then
			bDIS = true;
		end
		if EffectManager5E.hasEffect(rAttacker, "Invisible", rDefender, true) then
			bADV = true;
		end
		if EffectManager5E.hasEffect(rDefender, "GRANTADVATK", rAtracker) then
			bADV = true;
		end
		if EffectManager5E.hasEffect(rDefender, "GRANTDISATK", rAtracker) then
			bDIS = true;
		end
		if EffectManager5E.hasEffect(rDefender, "Invisible", rAttacker) then
			bDIS = true;
		end
		if EffectManager5E.hasEffect(rDefender, "Paralyzed", rAttacker) then
			bADV = true;
		end
		if EffectManager5E.hasEffect(rDefender, "Prone", rAttacker) then
			bProne = true;
		end
		if EffectManager5E.hasEffect(rDefender, "Restrained", rAttacker) then
			bADV = true;
		end
		if EffectManager5E.hasEffect(rDefender, "Stunned", rAttacker) then
			bADV = true;
		end
		if EffectManager5E.hasEffect(rDefender, "Unconscious", rAttacker) then
			bADV = true;
			bProne = true;
		end

		if bProne then
			if sAttackType == "M" then
				bADV = true;
			elseif sAttackType == "R" then
				bDIS = true;
			end
		end

		if nCover < 5 then
			local aCover = EffectManager5E.getEffectsByType(rDefender, "SCOVER", aAttackFilter, rAttacker);
			if #aCover > 0 or EffectManager5E.hasEffect(rDefender, "SCOVER", rAttacker) then
				nBonusSituational = nBonusSituational + 5 - nCover;
			elseif nCover < 2 then
				aCover = EffectManager5E.getEffectsByType(rDefender, "COVER", aAttackFilter, rAttacker);
				if #aCover > 0 or EffectManager5E.hasEffect(rDefender, "COVER", rAttacker) then
					nBonusSituational = nBonusSituational + 2 - nCover;
				end
			end
		end

		-- Level Up
		if EffectManager5E.hasEffect(rDefender, "Slowed", rAttacker) then
			nBonusSituational = nBonusSituational - 2;
		end

		nDefenseEffectMod = nBonusAC + nBonusStat + nBonusSituational;
	end

	-- Results
	return nDefense, 0, nDefenseEffectMod, bADV, bDIS;
end
