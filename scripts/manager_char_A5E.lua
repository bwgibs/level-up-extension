--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

CLASS_HERALD = "herald";

FEATURE_ABILITY_SCORE_INCREASES = "ability score increases";

TRAIT_CONSCRIPT = "conscript";
TRAIT_SHARPENED_TOOLS = "sharpened tools";
TRAIT_SLAPSTICK = "slapstick";
TRAIT_UNDERGROUND_COMBAT_TRAINING = "underground combat training";
TRAIT_WAR_HORDE_WEAPON_TRAINING = "war horde weapon training";

local _fnDefaultAddInfoDB;

function onInit()
	_fnDefaultAddInfoDB = CharManager.addInfoDB;
	CharManager.addInfoDB = addInfoDB;

	CharManager.addClassFeatureDB = addClassFeatureDB;
	CharManager.addTraitDB = addTraitDB;
	CharManager.checkSkillProficiencies = checkSkillProficiencies;
	CharManager.addBackgroundRef = addBackgroundRef;
	CharManager.addRaceSelect = addRaceSelect;
	CharManager.addClassRef = addClassRef;
	CharManager.addClassFeatureHelper = addClassFeatureHelper;
end

--
-- CHARACTER SHEET DROPS
--

function addInfoDB(nodeChar, sClass, sRecord)
	-- Validate parameters
	if not nodeChar then
		return false;
	end

	if sClass == "reference_culture" then
		addCultureRef(nodeChar, sClass, sRecord);
	elseif sClass == "reference_destiny" then
		addDestinyRef(nodeChar, sClass, sRecord);
	elseif sClass == "reference_destinyfeature" then
		CharManager.addClassFeatureDB(nodeChar, sClass, sRecord);
	elseif sClass == "reference_culturaltrait" then
		CharManager.addTraitDB(nodeChar, sClass, sRecord);
	else
		return _fnDefaultAddInfoDB(nodeChar, sClass, sRecord);
	end

	return true;
end

function addClassFeatureDB(nodeChar, sClass, sRecord, nodeClass, bWizard)
	local nodeSource = CharManager.resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end

	-- Get the list we are going to add to
	local nodeList = nodeChar.createChild("featurelist");
	if not nodeList then
		return false;
	end

	-- Get the class name
	local sClassName = DB.getValue(nodeSource, "...name", "");

	-- Make sure this item does not already exist
	local sOriginalName = DB.getValue(nodeSource, "name", "");
	local sOriginalNameLower = StringManager.trim(sOriginalName:lower());
	local sFeatureName = sOriginalName;
	for _,v in pairs(nodeList.getChildren()) do
		if DB.getValue(v, "name", ""):lower() == sOriginalNameLower then
			if sOriginalNameLower == CharManager.FEATURE_SPELLCASTING or sOriginalNameLower == CharManager.FEATURE_PACT_MAGIC then
				sFeatureName = sFeatureName .. " (" .. sClassName .. ")";
			else
				return false;
			end
		end
	end

	-- Pull the feature level
	local nFeatureLevel = DB.getValue(nodeSource, "level", 0);

	-- Add the item
	local vNew = nodeList.createChild();
	DB.copyNode(nodeSource, vNew);
	DB.setValue(vNew, "name", "string", sFeatureName);
	DB.setValue(vNew, "source", "string", DB.getValue(nodeSource, "...name", ""));
	DB.setValue(vNew, "locked", "number", 1);

	-- Special handling
	if sOriginalNameLower == CharManager.FEATURE_SPELLCASTING then
		-- Add spell casting ability
		local sSpellcasting = DB.getText(vNew, "text", "");
		local sAbility = sSpellcasting:match("(%a+) is your spellcasting ability");
		if sAbility then
			local sSpellsLabel = Interface.getString("power_label_groupspells");
			local sLowerSpellsLabel = sSpellsLabel:lower();

			local bFoundSpellcasting = false;
			for _,vGroup in pairs (DB.getChildren(nodeChar, "powergroup")) do
				if DB.getValue(vGroup, "name", ""):lower() == sLowerSpellsLabel then
					bFoundSpellcasting = true;
					break;
				end
			end

			local sNewGroupName = sSpellsLabel;
			if bFoundSpellcasting then
				sNewGroupName = sNewGroupName .. " (" .. sClassName .. ")";
			end

			local nodePowerGroups = DB.createChild(nodeChar, "powergroup");
			local nodeNewGroup = nodePowerGroups.createChild();
			DB.setValue(nodeNewGroup, "castertype", "string", "memorization");
			DB.setValue(nodeNewGroup, "stat", "string", sAbility:lower());
			DB.setValue(nodeNewGroup, "name", "string", sNewGroupName);

			if sSpellcasting:match("Preparing and Casting Spells") then
				local rActor = ActorManager.resolveActor(nodeChar);
				DB.setValue(nodeNewGroup, "prepared", "number", math.min(1 + ActorManager5E.getAbilityBonus(rActor, sAbility:lower())));
			end
		end

		-- Add spell slot calculation info
		if nodeClass and nFeatureLevel > 0 then
			if DB.getValue(nodeClass, "casterlevelinvmult", 0) == 0 then
				local sClassNameLower = StringManager.trim(sClassName):lower();
				if (sClassNameLower == CharManager.CLASS_ARTIFICER) then
					DB.setValue(nodeClass, "casterlevelinvmult", "number", -2);
				elseif (sClassNameLower == CLASS_HERALD) then
					DB.setValue(nodeClass, "casterlevelinvmult", "number", 2);
				else
					DB.setValue(nodeClass, "casterlevelinvmult", "number", nFeatureLevel);
				end
			end
		end

	elseif sOriginalNameLower == CharManager.FEATURE_PACT_MAGIC then
		-- Add spell casting ability
		local sAbility = DB.getText(vNew, "text", ""):match("(%a+) is your spellcasting ability");
		if sAbility then
			local sSpellsLabel = Interface.getString("power_label_groupspells");
			local sLowerSpellsLabel = sSpellsLabel:lower();

			local bFoundSpellcasting = false;
			for _,vGroup in pairs (DB.getChildren(nodeChar, "powergroup")) do
				if DB.getValue(vGroup, "name", ""):lower() == sLowerSpellsLabel then
					bFoundSpellcasting = true;
					break;
				end
			end

			local sNewGroupName = sSpellsLabel;
			if bFoundSpellcasting then
				sNewGroupName = sNewGroupName .. " (" .. sClassName .. ")";
			end

			local nodePowerGroups = DB.createChild(nodeChar, "powergroup");
			local nodeNewGroup = nodePowerGroups.createChild();
			DB.setValue(nodeNewGroup, "castertype", "string", "memorization");
			DB.setValue(nodeNewGroup, "stat", "string", sAbility:lower());
			DB.setValue(nodeNewGroup, "name", "string", sNewGroupName);
		end

		-- Add spell slot calculation info
		DB.setValue(nodeClass, "casterpactmagic", "number", 1);
		if nodeClass and nFeatureLevel > 0 then
			if DB.getValue(nodeClass, "casterlevelinvmult", 0) == 0 then
				DB.setValue(nodeClass, "casterlevelinvmult", "number", nFeatureLevel);
			end
		end

	elseif sOriginalNameLower == CharManager.FEATURE_DRACONIC_RESILIENCE then
		CharManager.applyDraconicResilience(nodeChar, true);
	elseif sOriginalNameLower == CharManager.FEATURE_UNARMORED_DEFENSE then
		CharManager.applyUnarmoredDefense(nodeChar, nodeClass);
	elseif sOriginalNameLower == CharManager.FEATURE_ELDRITCH_INVOCATIONS then
		-- Note: Bypass skill proficiencies due to false positive in skill proficiency detection
	elseif sOriginalNameLower == CharManager.FEATURE_MAGIC_ITEM_ADEPT or
			sOriginalNameLower == CharManager.FEATURE_MAGIC_ITEM_SAVANT or
			sOriginalNameLower == CharManager.FEATURE_MAGIC_ITEM_MASTER then
		local nCurrentClassAttune = DB.getValue(nodeChar, "attunement.class", 0);
		DB.setValue(nodeChar, "attunement.class", "number", nCurrentClassAttune + 1);
	elseif sOriginalNameLower == FEATURE_ABILITY_SCORE_INCREASES then
		applyAbilityScoreIncrease(nodeChar, nodeSource);
	else
		if not bWizard then
			local sText = DB.getText(vNew, "text", "");
			CharManager.checkSkillProficiencies(nodeChar, sText);
		end
	end

	-- Announce
	CharManager.outputUserMessage("char_abilities_message_featureadd", DB.getValue(vNew, "name", ""), DB.getValue(nodeChar, "name", ""));
	return true;
end

function applyAbilityScoreIncrease(nodeChar, nodeSource)
	local bApplied = false;
	local sAdjust = DB.getText(nodeSource, "text"):lower();

	local aIncreases = {};
	for sIncrease, a1 in sAdjust:gmatch("(%d+) to (%w+)") do
		local nIncrease = tonumber(sIncrease) or 0;
		aIncreases[a1] = nIncrease;
	end

	for k,v in pairs(aIncreases) do
		CharManager.addAbilityAdjustment(nodeChar, k, v);
		bApplied = true;
	end

	local tAbilitySelect = {};
	if sAdjust:match("and one other ability score") then
		local aAbilities = {};
		for _,v in ipairs(DataCommon.abilities) do
			if not aIncreases[v] then
				table.insert(aAbilities, StringManager.capitalize(v));
			end
		end
		if #aAbilities > 0 then
			local nAbilityAdj = tonumber(sIncrease) or 1;
			table.insert(tAbilitySelect, { aAbilities = aAbilities, nAbilityAdj = nAbilityAdj, bOther = true });
		end
	end
	if #tAbilitySelect > 0 then
		CharManager.onAbilitySelectDialog(nodeChar, tAbilitySelect);
		bApplied = true;
	end

	if not bApplied then
		return false;
	end
end

function addTraitDB(nodeChar, sClass, sRecord)
	local nodeSource = CharManager.resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end

	local sTraitType = CampaignDataManager2.sanitize(DB.getValue(nodeSource, "name", ""));
	if sTraitType == "" then
		sTraitType = nodeSource.getName();
	end

	if sTraitType == "abilityscoreincrease" then
		local bApplied = false;
		local sAdjust = DB.getText(nodeSource, "text"):lower();

		if sAdjust:match("your ability scores each increase") then
			for _,v in pairs(DataCommon.abilities) do
				CharManager.addAbilityAdjustment(nodeChar, v, 1);
				bApplied = true;
			end
		else
			local aIncreases = {};

			local n1, n2;
			local a1, a2, sIncrease = sAdjust:match("your (%w+) and (%w+) scores increase by (%d+)");
			if not a1 then
				a1, a2, sIncrease = sAdjust:match("your (%w+) and (%w+) scores both increase by (%d+)");
			end
			if a1 then
				local nIncrease = tonumber(sIncrease) or 0;
				aIncreases[a1] = nIncrease;
				aIncreases[a2] = nIncrease;
			else
				for a1, sIncrease in sAdjust:gmatch("your (%w+) score increases by (%d+)") do
					local nIncrease = tonumber(sIncrease) or 0;
					aIncreases[a1] = nIncrease;
				end
				for a1, sDecrease in sAdjust:gmatch("your (%w+) score is reduced by (%d+)") do
					local nDecrease = tonumber(sDecrease) or 0;
					aIncreases[a1] = nDecrease * -1;
				end
			end

			for k,v in pairs(aIncreases) do
				CharManager.addAbilityAdjustment(nodeChar, k, v);
				bApplied = true;
			end

			local tAbilitySelect = {};
			sIncrease = sAdjust:match("two different ability scores of your choice increase by (%d+)")
			if sIncrease then
				local nAbilityAdj = tonumber(sIncrease) or 1;
				table.insert(tAbilitySelect, { nPicks = 2, nAbilityAdj = nAbilityAdj });
			end
			sIncrease = sAdjust:match("one ability score of your choice increases by (%d+)");
			if sIncrease then
				local nAbilityAdj = tonumber(sIncrease) or 1;
				table.insert(tAbilitySelect, { nAbilityAdj = nAbilityAdj });
			end
			sIncrease = sAdjust:match("one other ability score of your choice increases by (%d+)");
			if sIncrease then
				local aAbilities = {};
				for _,v in ipairs(DataCommon.abilities) do
					if not aIncreases[v] then
						table.insert(aAbilities, StringManager.capitalize(v));
					end
				end
				if #aAbilities > 0 then
					local nAbilityAdj = tonumber(sIncrease) or 1;
					table.insert(tAbilitySelect, { aAbilities = aAbilities, nAbilityAdj = nAbilityAdj, bOther = true });
				end
			end
			sIncrease = sAdjust:match("two other ability scores of your choice increase by (%d+)");
			if sIncrease then
				local aAbilities = {};
				for _,v in ipairs(DataCommon.abilities) do
					if not aIncreases[v] then
						table.insert(aAbilities, StringManager.capitalize(v));
					end
				end
				if #aAbilities > 0 then
					local nAbilityAdj = tonumber(sIncrease) or 1;
					table.insert(tAbilitySelect, { aAbilities = aAbilities, nPicks = 2, nAbilityAdj = nAbilityAdj, bOther = true });
				end
			end
			a1, a2, sIncrease = sAdjust:match("either your (%w+) or your (%w+) increases by (%d+)");
			if a1 then
				local aAbilities = {};
				for _,v in ipairs(DataCommon.abilities) do
					if (v == a1) or (v == a2) then
						table.insert(aAbilities, StringManager.capitalize(v));
					end
				end
				if #aAbilities > 0 then
					local nAbilityAdj = tonumber(sIncrease) or 1;
					table.insert(tAbilitySelect, { aAbilities = aAbilities, nAbilityAdj = nAbilityAdj });
				end
			end
			if #tAbilitySelect > 0 then
				CharManager.onAbilitySelectDialog(nodeChar, tAbilitySelect);
				bApplied = true;
			end
		end
		if not bApplied then
			return false;
		end

	elseif sTraitType == "age" then
		return false;

	elseif sTraitType == "alignment" then
		return false;

	elseif sTraitType == "size" then
		local sSize = DB.getText(nodeSource, "text");
		sSize = sSize:match("[Yy]our size is (%w+)");
		if not sSize then
			sSize = "Medium";
		end
		DB.setValue(nodeChar, "size", "string", sSize);

	elseif sTraitType == "speed" then
		local sSpeed = DB.getText(nodeSource, "text");

		local sWalkSpeed = sSpeed:match("walking speed is (%d+) feet");
		if not sWalkSpeed then
			sWalkSpeed = sSpeed:match("land speed is (%d+) feet");
		end
		if sWalkSpeed then
			local nSpeed = tonumber(sWalkSpeed) or 30;
			DB.setValue(nodeChar, "speed.base", "number", nSpeed);
			CharManager.outputUserMessage("char_abilities_message_basespeedset", nSpeed, DB.getValue(nodeChar, "name", ""));
		end

		local aSpecial = {};
		local bSpecialChanged = false;
		local sSpecial = StringManager.trim(DB.getValue(nodeChar, "speed.special", ""));
		if sSpecial ~= "" then
			table.insert(aSpecial, sSpecial);
		end

		local sSwimSpeed = sSpeed:match("swimming speed of (%d+) feet");
		if sSwimSpeed then
			bSpecialChanged = true;
			table.insert(aSpecial, "Swim " .. sSwimSpeed .. " ft.");
		end

		local sFlySpeed = sSpeed:match("flying speed of (%d+) feet");
		if sFlySpeed then
			bSpecialChanged = true;
			table.insert(aSpecial, "Fly " .. sFlySpeed .. " ft.");
		end

		local sClimbSpeed = sSpeed:match("climbing speed of (%d+) feet");
		if sClimbSpeed then
			bSpecialChanged = true;
			table.insert(aSpecial, "Climb " .. sClimbSpeed .. " ft.");
		end

		local sBurrowSpeed = sSpeed:match("burrowing speed of (%d+) feet");
		if sBurrowSpeed then
			bSpecialChanged = true;
			table.insert(aSpecial, "Burrow " .. sBurrowSpeed .. " ft.");
		end

		if bSpecialChanged then
			DB.setValue(nodeChar, "speed.special", "string", table.concat(aSpecial, ", "));
		end

	elseif sTraitType == "fleetoffoot" then
		local sFleetOfFoot = DB.getText(nodeSource, "text");

		local sWalkSpeedIncrease = sFleetOfFoot:match("walking speed increases to (%d+) feet");
		if sWalkSpeedIncrease then
			DB.setValue(nodeChar, "speed.base", "number", tonumber(sWalkSpeedIncrease));
		end

	elseif sTraitType == "darkvision" then
		local sSenses = DB.getValue(nodeChar, "senses", "");
		if sSenses ~= "" then
			sSenses = sSenses .. ", ";
		end
		sSenses = sSenses .. DB.getValue(nodeSource, "name", "");

		local sText = DB.getText(nodeSource, "text");
		if sText then
			local sDist = sText:match("%d+");
			if sDist then
				sSenses = sSenses .. " " .. sDist;
			end
		end

		DB.setValue(nodeChar, "senses", "string", sSenses);

	elseif sTraitType == "superiordarkvision" then
		local sSenses = DB.getValue(nodeChar, "senses", "");

		local sDist = nil;
		local sText = DB.getText(nodeSource, "text");
		if sText then
			sDist = sText:match("%d+");
		end
		if not sDist then
			return false;
		end

		-- Check for regular Darkvision
		local sTraitName = DB.getValue(nodeSource, "name", "");
		if sSenses:find("Darkvision (%d+)") then
			sSenses = sSenses:gsub("Darkvision (%d+)", sTraitName .. " " .. sDist);
		else
			if sSenses ~= "" then
				sSenses = sSenses .. ", ";
			end
			sSenses = sSenses .. sTraitName .. " " .. sDist;
		end

		DB.setValue(nodeChar, "senses", "string", sSenses);

	elseif sTraitType == "languages" then
		local bApplied = false;
		local sText = DB.getText(nodeSource, "text");
		local sLanguages = sText:match("You can speak, read, and write ([^.]+)");
		if not sLanguages then
			sLanguages = sText:match("You can read and write ([^.]+)");
		end
		if not sLanguages then
			sLanguages = sText:match("You can speak, read, write, and sign ([^.]+)");
		end
		if not sLanguages then
			return false;
		end

		sLanguages = sLanguages:gsub(", and ", ",");
		sLanguages = sLanguages:gsub("and ", ",");
		sLanguages = sLanguages:gsub("in ", "");
		sLanguages = sLanguages:gsub("one extra language of your choice", "Choice");
		sLanguages = sLanguages:gsub("one other language of your choice", "Choice");
		-- Level Up
		sLanguages = sLanguages:gsub("one other language", "Choice");
		sLanguages = sLanguages:gsub("one of your choice", "Choice");
		sLanguages = sLanguages:gsub("two of your choice", "Choice,Choice");
		sLanguages = sLanguages:gsub("two additional languages", "Choice,Choice");
		sLanguages = sLanguages:gsub("three additional languages", "Choice,Choice,Choice");
		-- EXCEPTION - Kenku - Languages - Volo
		sLanguages = sLanguages:gsub(", but you.*$", "");
		for s in string.gmatch(sLanguages, "([^,]+)") do
			s = StringManager.trim(s);
			CharManager.addLanguageDB(nodeChar, s);
			bApplied = true;
		end
		return bApplied;

	elseif sTraitType == "extralanguage" then
		CharManager.addLanguageDB(nodeChar, "Choice");
		return true;

	elseif sTraitType == "subrace" then
		return false;

	else
		local sText = DB.getText(nodeSource, "text", "");

		if sTraitType == "stonecunning" then
			-- Note: Bypass due to false positive in skill proficiency detection
		else
			CharManager.checkSkillProficiencies(nodeChar, sText);
		end

		-- Get the list we are going to add to
		local nodeList = nodeChar.createChild("traitlist");
		if not nodeList then
			return false;
		end

		-- Add the item
		local vNew = nodeList.createChild();
		DB.copyNode(nodeSource, vNew);
		DB.setValue(vNew, "source", "string", DB.getValue(nodeSource, "...name", ""));
		DB.setValue(vNew, "locked", "number", 1);

		if sClass == "reference_racialtrait" then
			DB.setValue(vNew, "type", "string", "racial");
		elseif sClass == "reference_subracialtrait" then
			DB.setValue(vNew, "type", "string", "subracial");
		elseif sClass == "reference_backgroundtrait" then
			DB.setValue(vNew, "type", "string", "background");
		end

		-- Special handling
		local sNameLower = DB.getValue(nodeSource, "name", ""):lower();
		if sNameLower == CharManager.TRAIT_DWARVEN_TOUGHNESS then
			CharManager.applyDwarvenToughness(nodeChar, true);
		elseif sNameLower == CharManager.TRAIT_NATURAL_ARMOR then
			CharArmorManager.calcItemArmorClass(nodeChar);
		elseif sNameLower == CharManager.TRAIT_CATS_CLAWS then
			local aSpecial = {};
			local sSpecial = StringManager.trim(DB.getValue(nodeChar, "speed.special", ""));
			if sSpecial ~= "" then
				table.insert(aSpecial, sSpecial);
			end
			table.insert(aSpecial, "Climb 20 ft.");
			DB.setValue(nodeChar, "speed.special", "string", table.concat(aSpecial, ", "));

		-- LEVEL UP
		elseif sNameLower == TRAIT_SLAPSTICK or sNameLower == TRAIT_SHARPENED_TOOLS then
			CharManager.addProficiencyDB(nodeChar, "weapons", "Improvised");
		elseif sNameLower == TRAIT_CONSCRIPT then
			CharManager.addProficiencyDB(nodeChar, "weapons", "Spears, light crossbows");
		elseif sNameLower == TRAIT_UNDERGROUND_COMBAT_TRAINING then
			CharManager.addProficiencyDB(nodeChar, "weapons", "Hand crossbows, short swords, war picks");
		elseif sNameLower == TRAIT_WAR_HORDE_WEAPON_TRAINING then
			CharManager.addProficiencyDB(nodeChar, "armor", "Light armor");
			CharManager.addProficiencyDB(nodeChar, "weapons", "Choose two from martial weapons");
		elseif sNameLower:match("armor training") then
			-- Armor proficiency
			local sArmorProf = sText:match("proficiency with ([^.]+) armor and shields");
			if sArmorProf then
				sArmorProf = sArmorProf:gsub(", and", ",");
				sArmorProf = sArmorProf:gsub(" and", ",");

				CharManager.addProficiencyDB(nodeChar, "armor", StringManager.capitalize(sArmorProf) .. ", shields");
			else
				sArmorProf = sText:match("proficiency with ([^.]+) armor");
				if sArmorProf then
					sArmorProf = sArmorProf:gsub(", and", ",");
					sArmorProf = sArmorProf:gsub(" and", ",");

					CharManager.addProficiencyDB(nodeChar, "armor", StringManager.capitalize(sArmorProf));
				end
			end
		elseif sNameLower:match("weapon training") then
			-- Weapon proficiency
			local sWeaponProf = sText:match("proficiency with ([^.]+)") or sText:match("proficient with ([^.]+)");
			if sWeaponProf then
				sWeaponProf = sWeaponProf:gsub(", and", ",");
				sWeaponProf = sWeaponProf:gsub(" and", ",");
				sWeaponProf = sWeaponProf:gsub("the ", "");

				CharManager.addProficiencyDB(nodeChar, "weapons", StringManager.capitalize(sWeaponProf));
			end
		end
	end

	-- Announce
	CharManager.outputUserMessage("char_abilities_message_traitadd", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));
	return true;
end

function checkSkillProficiencies(nodeChar, sText)
	-- Tabaxi - Cat's Talent - Volo
	local sSkill, sSkill2 = sText:match("proficiency in the ([%w%s]+) and ([%w%s]+) skills");
	if sSkill and sSkill2 then
		CharManager.addSkillDB(nodeChar, sSkill, 1);
		CharManager.addSkillDB(nodeChar, sSkill2, 1);
		return true;
	end
	-- Elf - Keen Senses - PHB
	-- Half-Orc - Menacing - PHB
	-- Goliath - Natural Athlete - Volo
	local sSkill = sText:match("proficiency in the ([%w%s]+) skill");
	if sSkill then
		CharManager.addSkillDB(nodeChar, sSkill, 1);
		return true;
	end
	-- Bugbear - Sneaky - Volo
	-- (FALSE POSITIVE) Dwarf - Stonecunning
	sSkill = sText:match("proficient in the ([%w%s]+) skill");
	if sSkill then
		CharManager.addSkillDB(nodeChar, sSkill, 1);
		return true;
	end
	-- Orc - Menacing - Volo
	sSkill = sText:match("trained in the ([%w%s]+) skill");
	if sSkill then
		CharManager.addSkillDB(nodeChar, sSkill, 1);
		return true;
	end

	-- Half-Elf - Skill Versatility - PHB
	-- Human (Variant) - Skills - PHB
	local sPicks = sText:match("proficiency in (%w+) skills? of your choice");
	if sPicks then
		local nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);
		CharManager.pickSkills(nodeChar, nil, nPicks);
		return true;
	end
	-- Cleric - Acolyte of Nature - PHB
	local nMatchEnd = sText:match("proficiency in one of the following skills of your choice()")
	if nMatchEnd then
		CharManager.pickSkills(nodeChar, CharManager.parseSkillsFromString(sText:sub(nMatchEnd)), 1);
		return true;
	end
	-- Lizardfolk - Hunter's Lore - Volo
	sPicks, nMatchEnd = sText:match("proficiency with (%w+) of the following skills of your choice()")
	if sPicks then
		local nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);
		CharManager.pickSkills(nodeChar, CharManager.parseSkillsFromString(sText:sub(nMatchEnd)), nPicks);
		return true;
	end
	-- Cleric - Blessings of Knowledge - PHB
	-- Kenku - Kenuku Training - Volo
	sPicks, nMatchEnd = sText:match("proficient in your choice of (%w+) of the following skills()")
	if sPicks then
		local nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);
		local nProf = 1;
		if sText:match("proficiency bonus is doubled") then
			nProf = 2;
		end
		CharManager.pickSkills(nodeChar, CharManager.parseSkillsFromString(sText:sub(nMatchEnd)), nPicks, nProf);
		return true;
	end
	-- Human - Fast Learner - Level Up
	sPicks = sText:match("proficiency in (%w+) additional skills? of your choice");
	if sPicks then
		local nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);
		CharManager.pickSkills(nodeChar, nil, nPicks);
		return true;
	end
	-- Imperial - Learned Teachers - Level Up
	sSkill, sPicks = sText:match("proficiency in ([%w%s]+) and (%w+) other skills? of your choice");
	if sSkill and sPicks then
		CharManager.addSkillDB(nodeChar, sSkill, 1);
		
		local nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);
		local aSkills = {};
		for k,_ in pairs(DataCommon.skilldata) do
			if k ~= sSkill then
				table.insert(aSkills, k);
			end
		end
		table.sort(aSkills);		
		CharManager.pickSkills(nodeChar, aSkills, nPicks);
		return true;
	end
	return false;
end

function addBackgroundRef(nodeChar, sClass, sRecord)
	local nodeSource = CharManager.resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end

	-- Notify
	CharManager.outputUserMessage("char_abilities_message_backgroundadd", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));

	-- Add the name and link to the main character sheet
	DB.setValue(nodeChar, "background", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeChar, "backgroundlink", "windowreference", sClass, nodeSource.getPath());

	for _,v in pairs(DB.getChildren(nodeSource, "features")) do
		CharManager.addClassFeatureDB(nodeChar, "reference_backgroundfeature", v.getPath());
	end

	local sSkills = DB.getValue(nodeSource, "skill", "");
	if sSkills ~= "" and sSkills ~= "None" then
		local nPicks = 0;
		local aPickSkills = {};
		if sSkills:match("Choose %w+ from among ") then
			local sPicks, sPickSkills = sSkills:match("Choose (%w+) from among (.*)");
			sPickSkills = sPickSkills:gsub("and ", "");

			sSkills = "";
			nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);

			for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
				local sTrim = StringManager.trim(sSkill);
				table.insert(aPickSkills, sTrim);
			end
		elseif sSkills:match("plus %w+ from among ") then
			local sPicks, sPickSkills = sSkills:match("plus (%w+) from among (.*)");
			sPickSkills = sPickSkills:gsub("and ", "");
			sPickSkills = sPickSkills:gsub(", as appropriate for your order", "");

			sSkills = sSkills:gsub(sSkills:match("plus %w+ from among (.*)"), "");
			nPicks = CharManager.convertSingleNumberTextToNumber(sPicks);

			for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
				local sTrim = StringManager.trim(sSkill);
				if sTrim ~= "" then
					table.insert(aPickSkills, sTrim);
				end
			end
		elseif sSkills:match("plus your choice of one from among") then
			local sPickSkills = sSkills:match("plus your choice of one from among (.*)");
			sPickSkills = sPickSkills:gsub("and ", "");

			sSkills = sSkills:gsub("plus your choice of one from among (.*)", "");

			nPicks = 1;
			for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
				local sTrim = StringManager.trim(sSkill);
				if sTrim ~= "" then
					table.insert(aPickSkills, sTrim);
				end
			end
		elseif sSkills:match("and one Intelligence, Wisdom, or Charisma skill of your choice, as appropriate to your faction") then
			sSkills = sSkills:gsub("and one Intelligence, Wisdom, or Charisma skill of your choice, as appropriate to your faction", "");

			nPicks = 1;
			for k,v in pairs(DataCommon.skilldata) do
				if (v.stat == "intelligence") or (v.stat == "wisdom") or (v.stat == "charisma") then
					table.insert(aPickSkills, k);
				end
			end
			table.sort(aPickSkills);
		-- Level Up
		elseif sSkills:match("and either") then
			local sPickSkills = sSkills:match("and either (.*)");
			sPickSkills = sPickSkills:gsub(", or", ", ");
			sPickSkills = sPickSkills:gsub(" or", ", ");

			sSkills = sSkills:gsub("and either (.*)", "");

			nPicks = 1;
			for sSkill in string.gmatch(sPickSkills, "(%a[%a%s]+)%,?") do
				local sTrim = StringManager.trim(sSkill);
				if sTrim ~= "" then
					table.insert(aPickSkills, sTrim);
				end
			end
			table.sort(aPickSkills);
		end

		for sSkill in sSkills:gmatch("(%a[%a%s]+),?") do
			local sTrim = StringManager.trim(sSkill);
			if sTrim ~= "" then
				CharManager.addSkillDB(nodeChar, sTrim, 1);
			end
		end

		if nPicks > 0 then
			CharManager.pickSkills(nodeChar, aPickSkills, nPicks);
		end
	end

	local sTools = DB.getValue(nodeSource, "tool", "");
	if sTools ~= "" and sTools ~= "None" then
		CharManager.addProficiencyDB(nodeChar, "tools", sTools);
	end

	local sLanguages = DB.getValue(nodeSource, "languages", "");
	sLanguages = sLanguages:gsub("One of your choice", "Choice");
	sLanguages = sLanguages:gsub("Two of your choice", "Choice,Choice");
	if sLanguages ~= "" and sLanguages ~= "None" then
		CharManager.addLanguageDB(nodeChar, sLanguages);
	end
end

function addRaceSelect(aSelection, aTable)
	-- If subraces available, make sure that exactly one is selected
	if aSelection then
		if #aSelection ~= 1 then
			CharManager.outputUserMessage("char_error_addsubrace");
			return;
		end
	end

	local nodeChar = aTable["char"];
	local nodeSource = aTable["record"];

	-- Determine race to display on sheet and in notifications
	local sRace = DB.getValue(nodeSource, "name", "");
	local sSubRace = nil;
	if aSelection then
		if type(aSelection[1]) == "table" then
			sSubRace = aSelection[1].text;
		else
			sSubRace = aSelection[1];
		end
		if sSubRace:match(sRace) then
			sRace = sSubRace;
		else
			sRace = sRace .. " (" .. sSubRace .. ")";
		end
	end

	-- Notify
	CharManager.outputUserMessage("char_abilities_message_raceadd", sRace, DB.getValue(nodeChar, "name", ""));

	-- Add the name and link to the main character sheet
	DB.setValue(nodeChar, "race", "string", sRace);
	DB.setValue(nodeChar, "racelink", "windowreference", aTable["class"], nodeSource.getPath());

	for _,v in pairs(DB.getChildren(nodeSource, "traits")) do
		CharManager.addTraitDB(nodeChar, "reference_racialtrait", v.getPath());
	end

	if sSubRace then
		for _,vSubRace in ipairs(aTable["suboptions"]) do
			if sSubRace == vSubRace.text then
				for _,v in pairs(DB.getChildren(DB.getPath(vSubRace.linkrecord, "traits"))) do
					CharManager.addTraitDB(nodeChar, "reference_subracialtrait", v.getPath());
				end
				break;
			end
		end
	end

	-- Level Up
	local aGifts = {};
	for _,vGift in pairs(DB.getChildren(nodeSource, "heritagegifts")) do
		table.insert(aGifts, { text = DB.getValue(vGift, "name", ""), linkclass = "reference_racialtrait", linkrecord = vGift.getPath() });
	end
	if #(aGifts) == 1 then
		CharManager.addTraitDB(nodeChar, "reference_racialtrait", aGifts[1].linkrecord);
	elseif #(aGifts) > 1 then
		aGifts["nodeChar"] = nodeChar;
		-- Display dialog to choose heritage gift
		local wSelect = Interface.openWindow("select_dialog", "");
		local sTitle = Interface.getString("char_build_title_selectgifts");
		local sMessage = string.format(Interface.getString("char_build_message_selectgifts"), sRace);
		wSelect.requestSelection(sTitle, sMessage, aGifts, onGiftSelect, aGifts);
	end
end

function onGiftSelect(aSelection, aGifts)
	local nodeChar = aGifts["nodeChar"];
	local sGift = aSelection[1];
	if nodeChar and sGift then
		for _,v in ipairs(aGifts) do
			if v.text == sGift then
				CharManager.addTraitDB(nodeChar, "reference_racialtrait", v.linkrecord);
			end
		end
	end
end

function addCultureRef(nodeChar, sClass, sRecord)
	local nodeSource = CharManager.resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end

	if sClass == "reference_culture" then
		CharManager.addTraitDB(nodeChar, sClass, sRecord);

		-- Notify
		CharManager.outputUserMessage("char_abilities_message_cultureadd", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));

		for _,v in pairs(DB.getChildren(nodeSource, "traits")) do
			CharManager.addTraitDB(nodeChar, "reference_culturaltrait", v.getPath());
		end

		local sCulture = DB.getValue(nodeSource, "name", "");
		local sRace = DB.getValue(nodeChar, "race", "");
		if sRace:match("%([%a%s]+%)") then
			sRace = sRace:gsub(" %([%a%s]+%)", "");
		end
		sRace = sRace .. " (" .. sCulture .. ")";
		DB.setValue(nodeChar, "race", "string", sRace);
	end
end

function addDestinyRef(nodeChar, sClass, sRecord)
	local nodeSource = CharManager.resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end

	-- Notify
	CharManager.outputUserMessage("char_abilities_message_destinyadd", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));

	-- Add the name and link to the main character sheet
	DB.setValue(nodeChar, "destiny", "string", DB.getValue(nodeSource, "name", ""));
	DB.setValue(nodeChar, "destinylink", "windowreference", sClass, nodeSource.getPath());

	for _,v in pairs(DB.getChildren(nodeSource, "features")) do
		local sFeature = DB.getValue(v, "name", ""):lower();
		if sFeature:match("^inspiration feature") then
			CharManager.addClassFeatureDB(nodeChar, "reference_destinyfeature", v.getPath());
		end
	end
end

function addClassRef(nodeChar, sClass, sRecord, bWizard)
	local nodeSource = CharManager.resolveRefNode(sRecord)
	if not nodeSource then
		return;
	end

	-- Get the list we are going to add to
	local nodeList = nodeChar.createChild("classes");
	if not nodeList then
		return;
	end

	-- Notify
	CharManager.outputUserMessage("char_abilities_message_classadd", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));

	-- Translate Hit Die
	local bHDFound = false;
	local nHDMult = 1;
	local nHDSides = 6;
	local sHD = DB.getText(nodeSource, "hp.hitdice.text");
	if sHD then
		local sMult, sSides = sHD:match("(%d)d(%d+)");
		if sMult and sSides then
			nHDMult = tonumber(sMult);
			nHDSides = tonumber(sSides);
			bHDFound = true;
		end
	end
	if not bHDFound then
		CharManager.outputUserMessage("char_error_addclasshd");
	end

	-- Keep some data handy for comparisons
	local sClassName = DB.getValue(nodeSource, "name", "");
	local sClassNameLower = StringManager.trim(sClassName):lower();

	-- Check to see if the character already has this class; or create a new class entry
	local nodeClass = nil;
	for _,v in pairs(nodeList.getChildren()) do
		local sExistingClassName = StringManager.trim(DB.getValue(v, "name", "")):lower();
		if (sExistingClassName == sClassNameLower) and (sExistingClassName ~= "") then
			nodeClass = v;
			break;
		end
	end
	local bExistingClass = false;
	if nodeClass then
		bExistingClass = true;
	else
		nodeClass = nodeList.createChild();
	end

	-- Calculate current spell slots before levelling up
	local nCasterLevel = CharManager.calcSpellcastingLevel(nodeChar);
	local nPactMagicLevel = CharManager.calcPactMagicLevel(nodeChar);

	-- Any way you get here, overwrite or set the class reference link with the most current
	DB.setValue(nodeClass, "shortcut", "windowreference", sClass, sRecord);

	-- Add basic class information
	local nLevel = 1;
	if bExistingClass then
		nLevel = DB.getValue(nodeClass, "level", 1) + 1;
	else
		DB.setValue(nodeClass, "name", "string", sClassName);
		local aDice = {};
		for i = 1, nHDMult do
			table.insert(aDice, "d" .. nHDSides);
		end
		DB.setValue(nodeClass, "hddie", "dice", aDice);
	end
	DB.setValue(nodeClass, "level", "number", nLevel);

	-- Calculate total level
	local nTotalLevel = 0;
	for _,vClass in pairs(nodeList.getChildren()) do
		nTotalLevel = nTotalLevel + DB.getValue(vClass, "level", 0);
	end

	-- Add hit points based on level added
	local nHP = DB.getValue(nodeChar, "hp.total", 0);
	local nConBonus = DB.getValue(nodeChar, "abilities.constitution.bonus", 0);
	if nTotalLevel == 1 then
		local nAddHP = math.max((nHDMult * nHDSides) + nConBonus, 1);
		nHP = nHP + nAddHP;

		CharManager.outputUserMessage("char_abilities_message_hpaddmax", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""), nAddHP);
	else
		local nAddHP = math.max(math.floor(((nHDMult * (nHDSides + 1)) / 2) + 0.5) + nConBonus, 1);
		nHP = nHP + nAddHP;

		CharManager.outputUserMessage("char_abilities_message_hpaddavg", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""), nAddHP);
	end
	DB.setValue(nodeChar, "hp.total", "number", nHP);

	-- Special hit point level up handling
	if CharManager.hasTrait(nodeChar, CharManager.TRAIT_DWARVEN_TOUGHNESS) then
		CharManager.applyDwarvenToughness(nodeChar);
	end
	if (sClassNameLower == CharManager.CLASS_SORCERER) and CharManager.hasFeature(nodeChar, CharManager.FEATURE_DRACONIC_RESILIENCE) then
		CharManager.applyDraconicResilience(nodeChar);
	end
	if CharManager.hasFeat(nodeChar, FEAT_TOUGH) then
		CharManager.applyTough(nodeChar);
	end

	-- Add proficiencies
	if not bExistingClass and not bWizard then
		if nTotalLevel == 1 then
			for _,v in pairs(DB.getChildren(nodeSource, "proficiencies")) do
				CharManager.addClassProficiencyDB(nodeChar, "reference_classproficiency", v.getPath());
			end
		else
			for _,v in pairs(DB.getChildren(nodeSource, "multiclassproficiencies")) do
				CharManager.addClassProficiencyDB(nodeChar, "reference_classproficiency", v.getPath());
			end
		end
	end

	-- Level Up
	-- Select a paragon gift from heritage at 10th level
	if nTotalLevel == 10 then
		local _, sRaceRecord = DB.getValue(nodeChar, "racelink");
		local nodeRace = CharManager.resolveRefNode(sRaceRecord);
		if nodeRace then
			-- Level Up
			local aGifts = {};
			for _,vGift in pairs(DB.getChildren(nodeRace, "paragongifts")) do
				table.insert(aGifts, { text = DB.getValue(vGift, "name", ""), linkclass = "reference_racialtrait", linkrecord = vGift.getPath() });
			end
			if #(aGifts) == 1 then
				addTraitDB(nodeChar, "reference_racialtrait", aGifts[1].linkrecord);
			elseif #(aGifts) > 1 then
				aGifts["nodeChar"] = nodeChar;
				-- Display dialog to choose heritage gift
				local wSelect = Interface.openWindow("select_dialog", "");
				local sTitle = Interface.getString("char_build_title_selectgifts");
				local sMessage = string.format(Interface.getString("char_build_message_selectgifts"), DB.getValue(nodeRace, "name", ""));
				wSelect.requestSelection(sTitle, sMessage, aGifts, onGiftSelect, aGifts);
			end
		end
	end

	-- Determine whether a specialization is added this level
	if not bWizard then
		local nodeSpecializationFeature = nil;
		local tClassSpecOptions = {};
		for _,v in pairs(DB.getChildren(nodeSource, "features")) do
			if (DB.getValue(v, "level", 0) == nLevel) and (DB.getValue(v, "specializationchoice", 0) == 1) then
				nodeSpecializationFeature = v;
				tClassSpecOptions = CharManager.getClassSpecializationOptions(nodeSource);
				break;
			end
		end

		-- Add features, with customization based on whether specialization is added this level
		local rClassAdd = { nodeChar = nodeChar, nodeSource = nodeSource, nLevel = nLevel, nodeClass = nodeClass, nCasterLevel = nCasterLevel, nPactMagicLevel = nPactMagicLevel };
		if #tClassSpecOptions == 0 then
			CharManager.addClassFeatureHelper(nil, rClassAdd);
		elseif #tClassSpecOptions == 1 then
			CharManager.addClassFeatureHelper( { tClassSpecOptions[1].text }, rClassAdd);
		else
			-- Display dialog to choose specialization
			local wSelect = Interface.openWindow("select_dialog", "");
			local sTitle = Interface.getString("char_build_title_selectspecialization");
			local sMessage = string.format(Interface.getString("char_build_message_selectspecialization"), DB.getValue(nodeSpecializationFeature, "name", ""), 1);
			wSelect.requestSelection (sTitle, sMessage, tClassSpecOptions, addClassFeatureHelper, rClassAdd);
		end
	else
		return nodeClass;
	end
		end

function addClassFeatureHelper(aSelection, rClassAdd)
	local nodeSource = rClassAdd.nodeSource;
	local nodeChar = rClassAdd.nodeChar;

	-- Check to see if we added specialization
	if aSelection then
		if #aSelection ~= 1 then
			CharManager.outputUserMessage("char_error_addclassspecialization");
			return;
		end

		local tClassSpecOptions = CharManager.getClassSpecializationOptions(rClassAdd.nodeSource);
		for _,v in ipairs(tClassSpecOptions) do
			if v.text == aSelection[1] then
				CharManager.addClassSpecializationDB(nodeChar, v.linkclass, v.linkrecord, rClassAdd.nodeClass);
				break;
			end
		end
	end

	-- Add features
	local aMatchingClassNodes = {};
	local sClassNameLower = StringManager.trim(DB.getValue(nodeSource, "name", "")):lower();
	local aMappings = LibraryData.getMappings("class");
	for _,vMapping in ipairs(aMappings) do
		for _,vNode in pairs(DB.getChildrenGlobal(vMapping)) do
			local sExistingClassName = StringManager.trim(DB.getValue(vNode, "name", "")):lower();
			if (sExistingClassName == sClassNameLower) and (sExistingClassName ~= "") then
				table.insert(aMatchingClassNodes, vNode);
				if nodeSource then
					nodeSource = nil;
				end
			end
		end
	end
	if nodeSource then
		table.insert(aMatchingClassNodes, nodeSource);
	end
	local aAddedFeatures = {};
	for _,vNode in ipairs(aMatchingClassNodes) do
		for _,vFeature in pairs(DB.getChildren(vNode, "features")) do
			if (DB.getValue(vFeature, "level", 0) == rClassAdd.nLevel) then
				local sFeatureName = DB.getValue(vFeature, "name", "");
				local sFeatureSpec = DB.getValue(vFeature, "specialization", "");
				if (sFeatureSpec == "") or CharManager.hasFeature(nodeChar, sFeatureSpec) then
					local sFeatureNameLower = StringManager.trim(sFeatureName):lower();
					if not aAddedFeatures[sFeatureNameLower] then
						CharManager.addClassFeatureDB(nodeChar, "reference_classfeature", vFeature.getPath(), rClassAdd.nodeClass);
						aAddedFeatures[sFeatureNameLower] = true;
					end
				end
			end
		end
	end

	-- Increment spell slots for spellcasting level
	local nNewCasterLevel = CharManager.calcSpellcastingLevel(nodeChar);
	if nNewCasterLevel > rClassAdd.nCasterLevel then
		for i = rClassAdd.nCasterLevel + 1, nNewCasterLevel do
			if i == 1 then
				DB.setValue(nodeChar, "powermeta.spellslots1.max", "number", DB.getValue(nodeChar, "powermeta.spellslots1.max", 0) + 2);
			elseif i == 2 then
				DB.setValue(nodeChar, "powermeta.spellslots1.max", "number", DB.getValue(nodeChar, "powermeta.spellslots1.max", 0) + 1);
			elseif i == 3 then
				DB.setValue(nodeChar, "powermeta.spellslots1.max", "number", DB.getValue(nodeChar, "powermeta.spellslots1.max", 0) + 1);
				DB.setValue(nodeChar, "powermeta.spellslots2.max", "number", DB.getValue(nodeChar, "powermeta.spellslots2.max", 0) + 2);
			elseif i == 4 then
				DB.setValue(nodeChar, "powermeta.spellslots2.max", "number", DB.getValue(nodeChar, "powermeta.spellslots2.max", 0) + 1);
			elseif i == 5 then
				DB.setValue(nodeChar, "powermeta.spellslots3.max", "number", DB.getValue(nodeChar, "powermeta.spellslots3.max", 0) + 2);
			elseif i == 6 then
				DB.setValue(nodeChar, "powermeta.spellslots3.max", "number", DB.getValue(nodeChar, "powermeta.spellslots3.max", 0) + 1);
			elseif i == 7 then
				DB.setValue(nodeChar, "powermeta.spellslots4.max", "number", DB.getValue(nodeChar, "powermeta.spellslots4.max", 0) + 1);
			elseif i == 8 then
				DB.setValue(nodeChar, "powermeta.spellslots4.max", "number", DB.getValue(nodeChar, "powermeta.spellslots4.max", 0) + 1);
			elseif i == 9 then
				DB.setValue(nodeChar, "powermeta.spellslots4.max", "number", DB.getValue(nodeChar, "powermeta.spellslots4.max", 0) + 1);
				DB.setValue(nodeChar, "powermeta.spellslots5.max", "number", DB.getValue(nodeChar, "powermeta.spellslots5.max", 0) + 1);
			elseif i == 10 then
				DB.setValue(nodeChar, "powermeta.spellslots5.max", "number", DB.getValue(nodeChar, "powermeta.spellslots5.max", 0) + 1);
			elseif i == 11 then
				DB.setValue(nodeChar, "powermeta.spellslots6.max", "number", DB.getValue(nodeChar, "powermeta.spellslots6.max", 0) + 1);
			elseif i == 12 then
				-- No change
			elseif i == 13 then
				DB.setValue(nodeChar, "powermeta.spellslots7.max", "number", DB.getValue(nodeChar, "powermeta.spellslots7.max", 0) + 1);
			elseif i == 14 then
				-- No change
			elseif i == 15 then
				DB.setValue(nodeChar, "powermeta.spellslots8.max", "number", DB.getValue(nodeChar, "powermeta.spellslots8.max", 0) + 1);
			elseif i == 16 then
				-- No change
			elseif i == 17 then
				DB.setValue(nodeChar, "powermeta.spellslots9.max", "number", DB.getValue(nodeChar, "powermeta.spellslots9.max", 0) + 1);
			elseif i == 18 then
				DB.setValue(nodeChar, "powermeta.spellslots5.max", "number", DB.getValue(nodeChar, "powermeta.spellslots5.max", 0) + 1);
			elseif i == 19 then
				DB.setValue(nodeChar, "powermeta.spellslots6.max", "number", DB.getValue(nodeChar, "powermeta.spellslots6.max", 0) + 1);
			elseif i == 20 then
				DB.setValue(nodeChar, "powermeta.spellslots7.max", "number", DB.getValue(nodeChar, "powermeta.spellslots7.max", 0) + 1);
			end
		end
	end

	-- Adjust spell slots for pact magic level increase
	local nNewPactMagicLevel = CharManager.calcPactMagicLevel(nodeChar);
	if nNewPactMagicLevel > rClassAdd.nPactMagicLevel then
		for i = rClassAdd.nPactMagicLevel + 1, nNewPactMagicLevel do
			if i == 1 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
				DB.setValue(nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 2 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
			elseif i == 3 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
				DB.setValue(nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 4 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
			elseif i == 5 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
				DB.setValue(nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 6 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 7 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
				DB.setValue(nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 8 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 9 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
				DB.setValue(nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 10 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 3);
			elseif i == 11 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 4);
			elseif i == 12 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 13 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
			elseif i == 14 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 15 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 16 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 17 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 18 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 19 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 20 then
				DB.setValue(nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			end
		end
	end
end
