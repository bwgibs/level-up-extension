--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

CLASS_HERALD = "herald";

FEAT_CLEARSIGHT_SENTINEL = "clearsight sentinel";
FEAT_DIVINE_VISION = "divine vision";

FEATURE_ABILITY_SCORE_INCREASES = "ability score increases";

TRAIT_CONSCRIPT = "conscript";
TRAIT_SHARPENED_TOOLS = "sharpened tools";
TRAIT_SLAPSTICK = "slapstick";
TRAIT_UNDERGROUND_COMBAT_TRAINING = "underground combat training";
TRAIT_WAR_HORDE_WEAPON_TRAINING = "war horde weapon training";

local _fnDefaultAddInfoDB;
local _fnDefaultCheckSkillProficiencies;
local _fnDefaultAddBackgroundMain;
local _fnDefaultAddRaceMain;
local _fnDefaultAddClassMain;
local _fnDefaultAddFeatMain;

function onInit()
	_fnDefaultAddInfoDB = CharManager.addInfoDB;
	CharManager.addInfoDB = addInfoDB;

	_fnDefaultCheckSkillProficiencies = CharManager.checkSkillProficiencies;
	CharManager.checkSkillProficiencies = checkSkillProficiencies;

	_fnDefaultAddBackgroundMain = CharBackgroundManager.helperAddBackgroundMain;
	CharBackgroundManager.helperAddBackgroundMain = helperAddBackgroundMain;
	CharBackgroundManager.helperAddBackgroundSkills = helperAddBackgroundSkills;

	_fnDefaultAddRaceMain = CharRaceManager.helperAddRaceMain;
	CharRaceManager.helperAddRaceMain = helperAddRaceMain;

	CharRaceManager.helperAddRaceTraitMainDrop = helperAddRaceTraitMainDrop;

	_fnDefaultAddClassMain = CharClassManager.helperAddClassMain;
	CharClassManager.helperAddClassMain = helperAddClassMain;
	
	_fnDefaultAddFeatMain = CharFeatManager.helperAddFeatMain;
	CharFeatManager.helperAddFeatMain = helperAddFeatMain;

	CharClassManager.helperAddClassFeatureMain = helperAddClassFeatureMain;
	CharClassManager.helperAddClassFeatureSpellcasting = helperAddClassFeatureSpellcasting;
	CharClassManager.helperAddClassUpdateSpellSlots = helperAddClassUpdateSpellSlots
end

--
-- CHARACTER SHEET DROPS
--

-- CharManager.addInfoDB
function addInfoDB(nodeChar, sClass, sRecord)
	-- Validate parameters
	if not nodeChar then
		return false;
	end

	-- Level Up
	if sClass == "reference_culture" then
		addCultureRef(nodeChar, sClass, sRecord);
	elseif sClass == "reference_culturaltrait" then
		CharRaceManager.addRaceTrait(nodeChar, sClass, sRecord);
	elseif sClass == "reference_destiny" then
		addDestinyRef(nodeChar, sClass, sRecord);
	elseif sClass == "reference_destinyfeature" then
		CharClassManager.addClassFeature(nodeChar, sClass, sRecord);
	else
		return _fnDefaultAddInfoDB(nodeChar, sClass, sRecord);
	end

	return true;
end
-- Level Up
function addCultureRef(nodeChar, sClass, sRecord)
	local nodeSource = DB.findNode(sRecord);
	if not nodeSource then
		return;
	end

	-- Notify
	CharManager.outputUserMessage("char_abilities_message_cultureadd", DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));

	CharRaceManager.addRaceTrait(nodeChar, sClass, sRecord);
	for _,v in pairs(DB.getChildren(nodeSource, "traits")) do
		CharRaceManager.addRaceTrait(nodeChar, "reference_culturaltrait", v.getPath());
	end

	local sCulture = DB.getValue(nodeSource, "name", "");
	local sRace = DB.getValue(nodeChar, "race", "");
	if sRace:match("%([%a%s]+%)") then
		sRace = sRace:gsub(" %([%a%s]+%)", "");
	end
	sRace = sRace .. " (" .. sCulture .. ")";
	DB.setValue(nodeChar, "race", "string", sRace);
end
-- Level Up
function addDestinyRef(nodeChar, sClass, sRecord)
	local nodeSource = DB.findNode(sRecord);
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
			CharClassManager.addClassFeature(nodeChar, "reference_destinyfeature", v.getPath());
		end
	end
end
-- Level Up
function onGiftSelect(aSelection, aGifts)
	local nodeChar = aGifts["nodeChar"];
	local bWizard = aGifts["bWizard"];
	local sGift = aSelection[1];
	if nodeChar and sGift then
		for _,v in ipairs(aGifts) do
			if v.text == sGift then
				CharRaceManager.addRaceTrait(nodeChar, "reference_racialtrait", v.linkrecord, bWizard);
			end
		end
	end
end

-- CharManager.checkSkillProficiencies
function checkSkillProficiencies(nodeChar, sText)
	if _fnDefaultCheckSkillProficiencies(nodeChar, sText) then
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

-- CharBackgroundManager.helperAddBackgroundMain
function helperAddBackgroundMain(rAdd)
	_fnDefaultAddBackgroundMain(rAdd);

	if not rAdd.bWizard then
		for _,v in pairs(DB.getChildren(rAdd.nodeSource, "features")) do
			local sFeatureName = StringManager.trim(DB.getValue(v, "name", ""));
			local sFeatureType = StringManager.simplify(sFeatureName);
			if sFeatureType == "abilityscoreincrease" or sFeatureType == "abilityscoreincreases" then
				local rAdd = CharManager.helperBuildAddStructure(rAdd.nodeChar, "reference_backgroundfeature", v.getPath(), rAdd.bWizard);
				if rAdd then
					applyAbilityScoreIncrease(rAdd.nodeChar, v);
				end
			end
		end
	end
end
-- CharBackgroundManager.helperAddBackgroundSkills
function helperAddBackgroundSkills(rAdd)
	local sSkills = StringManager.trim(DB.getValue(rAdd.nodeSource, "skill", ""));
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
				CharManager.helperAddSkill(rAdd.nodeChar, sTrim, 1);
			end
		end
		
		if nPicks > 0 then
			CharManager.pickSkills(rAdd.nodeChar, aPickSkills, nPicks);
		end
	end
end
-- Level Up
function applyAbilityScoreIncrease(nodeChar, nodeSource)
	local sAdjust = DB.getText(nodeSource, "text"):lower();

	local aIncreases = {};
	for sIncrease, a1 in sAdjust:gmatch("(%d+) to (%w+)") do
		local nIncrease = tonumber(sIncrease) or 0;
		aIncreases[a1] = nIncrease;
	end

	for k,v in pairs(aIncreases) do
		CharManager.addAbilityAdjustment(nodeChar, k, v);
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
	end
end

-- CharRaceManager.helperAddRaceMain
function helperAddRaceMain(rAdd)
	_fnDefaultAddRaceMain(rAdd);

	-- Level Up
	local aGifts = {};
	for _,vGift in pairs(DB.getChildren(rAdd.nodeSource, "heritagegifts")) do
		table.insert(aGifts, { text = DB.getValue(vGift, "name", ""), linkclass = "reference_racialtrait", linkrecord = vGift.getPath() });
	end
	if #(aGifts) == 1 then
		CharRaceManager.addRaceTrait(rAdd.nodeChar, "reference_racialtrait", aGifts[1].linkrecord, rAdd.bWizard);
	elseif #(aGifts) > 1 then
		aGifts["nodeChar"] = rAdd.nodeChar;
		aGifts["bWizard"] = rAdd.bWizard;
		-- Display dialog to choose heritage gift
		local wSelect = Interface.openWindow("select_dialog", "");
		local sTitle = Interface.getString("char_build_title_selectgifts");
		local sMessage = string.format(Interface.getString("char_build_message_selectgifts"), rAdd.sSourceName);
		wSelect.requestSelection(sTitle, sMessage, aGifts, onGiftSelect, aGifts);
	end
end

-- CharRaceManager.helperAddRaceTraitMainDrop
function helperAddRaceTraitMainDrop(rAdd)
	if rAdd.sSourceType == "abilityscoreincrease" then
		CharRaceManager.helperAddRaceTraitAbilityIncreaseDrop(rAdd);
		return;

	elseif rAdd.sSourceType == "age" then
		return;

	elseif rAdd.sSourceType == "alignment" then
		return;

	elseif rAdd.sSourceType == "size" then
		CharRaceManager.helperAddRaceTraitSizeDrop(rAdd);
		return;

	elseif rAdd.sSourceType == "speed" then
		CharRaceManager.helperAddRaceTraitSpeedDrop(rAdd);
		return;

	elseif rAdd.sSourceType == "fleetoffoot" then
		CharRaceManager.helperAddRaceTraitFleetOfFootDrop(rAdd);
		return;

	elseif rAdd.sSourceType == "darkvision" then
		CharRaceManager.helperAddRaceTraitDarkvisionDrop(rAdd);
		return;
		
	elseif rAdd.sSourceType == "superiordarkvision" then
		CharRaceManager.helperAddRaceTraitSuperiorDarkvisionDrop(rAdd);
		return;

	elseif rAdd.sSourceType == "languages" then
		CharRaceManager.helperAddRaceTraitLanguagesDrop(rAdd);
		return;
		
	elseif rAdd.sSourceType == "extralanguage" then
		CharManager.addLanguage(rAdd.nodeChar, "Choice");
		return;
	
	elseif rAdd.sSourceType == "subrace" then
		return;
		
	else
		local sText = DB.getText(rAdd.nodeSource, "text", "");
		
		if rAdd.sSourceType == "stonecunning" then
			-- Note: Bypass due to false positive in skill proficiency detection
		else
			CharManager.checkSkillProficiencies(rAdd.nodeChar, sText);
		end
		
		-- Create standard trait entry
		local nodeNewTrait = CharRaceManager.helperAddRaceTraitStandard(rAdd);
		if not nodeNewTrait then
			return;
		end
		
		-- Special handling
		local sNameLower = rAdd.sSourceName:lower();
		if sNameLower == CharManager.TRAIT_DWARVEN_TOUGHNESS then
			CharRaceManager.applyDwarvenToughness(rAdd.nodeChar, true);
		elseif sNameLower == CharManager.TRAIT_NATURAL_ARMOR then
			CharArmorManager.calcItemArmorClass(rAdd.nodeChar);
		elseif sNameLower == CharManager.TRAIT_CATS_CLAWS then
			CharRaceManager.applyLegacyCatsClawsClimb(rAdd.nodeChar, sText);
		-- Level Up
		elseif sNameLower == TRAIT_SLAPSTICK or sNameLower == TRAIT_SHARPENED_TOOLS then
			CharManager.addProficiency(rAdd.nodeChar, "weapons", "Improvised");
		elseif sNameLower == TRAIT_CONSCRIPT then
			CharManager.addProficiency(rAdd.nodeChar, "weapons", "Spears, light crossbows");
		elseif sNameLower == TRAIT_UNDERGROUND_COMBAT_TRAINING then
			CharManager.addProficiency(rAdd.nodeChar, "weapons", "Hand crossbows, short swords, war picks");
		elseif sNameLower == TRAIT_WAR_HORDE_WEAPON_TRAINING then
			CharManager.addProficiency(rAdd.nodeChar, "armor", "Light armor");
			CharManager.addProficiency(rAdd.nodeChar, "weapons", "Choose two from martial weapons");
		elseif sNameLower:match("armor training") then
			-- Armor proficiency
			local sArmorProf = sText:match("proficiency with ([^.]+) armor and shields");
			if sArmorProf then
				sArmorProf = sArmorProf:gsub(", and", ",");
				sArmorProf = sArmorProf:gsub(" and", ",");

				CharManager.addProficiency(rAdd.nodeChar, "armor", StringManager.capitalize(sArmorProf) .. ", shields");
			else
				sArmorProf = sText:match("proficiency with ([^.]+) armor");
				if sArmorProf then
					sArmorProf = sArmorProf:gsub(", and", ",");
					sArmorProf = sArmorProf:gsub(" and", ",");

					CharManager.addProficiency(rAdd.nodeChar, "armor", StringManager.capitalize(sArmorProf));
				end
			end
		elseif sNameLower:match("weapon training") then
			-- Weapon proficiency
			local sWeaponProf = sText:match("proficiency with ([^.]+)") or sText:match("proficient with ([^.]+)");
			if sWeaponProf then
				sWeaponProf = sWeaponProf:gsub(", and", ",");
				sWeaponProf = sWeaponProf:gsub(" and", ",");
				sWeaponProf = sWeaponProf:gsub("the ", "");

				CharManager.addProficiency(rAdd.nodeChar, "weapons", StringManager.capitalize(sWeaponProf));
			end
		end

		-- Standard action addition handling
		CharManager.helperCheckActionsAdd(rAdd.nodeChar, rAdd.nodeSource, rAdd.sSourceType, "Race Actions/Effects");
	end
end

-- CharClassManager.helperAddClassMain
function helperAddClassMain(rAdd)
	_fnDefaultAddClassMain(rAdd);

	-- Level Up
	-- Select a paragon gift from heritage at 10th level
	if rAdd.nCharClassLevel == 10 then
		local _, sRaceRecord = DB.getValue(rAdd.nodeChar, "racelink");
		local nodeRace = DB.findNode(sRaceRecord);
		if nodeRace then
			-- Level Up
			local aGifts = {};
			for _,vGift in pairs(DB.getChildren(nodeRace, "paragongifts")) do
				table.insert(aGifts, { text = DB.getValue(vGift, "name", ""), linkclass = "reference_racialtrait", linkrecord = vGift.getPath() });
			end
			if #(aGifts) == 1 then
				CharRaceManager.addRaceTrait(rAdd.nodeChar, "reference_racialtrait", aGifts[1].linkrecord);
			elseif #(aGifts) > 1 then
				aGifts["nodeChar"] = rAdd.nodeChar;
				aGifts["bWizard"] = rAdd.bWizard;
				-- Display dialog to choose heritage gift
				local wSelect = Interface.openWindow("select_dialog", "");
				local sTitle = Interface.getString("char_build_title_selectgifts");
				local sMessage = string.format(Interface.getString("char_build_message_selectgifts"), DB.getValue(nodeRace, "name", ""));
				wSelect.requestSelection(sTitle, sMessage, aGifts, onGiftSelect, aGifts);
			end
		end
	end
end

--CharFeatManager.helperAddFeatMain
function helperAddFeatMain(rAdd)
	_fnDefaultAddFeatMain(rAdd);
	
	-- Level Up
	-- Special handling
	local sNameLower = rAdd.sSourceName:lower();
	if (sNameLower == FEAT_CLEARSIGHT_SENTINEL) or (sNameLower == FEAT_DIVINE_VISION) then
		rAdd.sSourceName = "darkvision";
		CharRaceManager.helperAddRaceTraitDarkvisionDrop(rAdd);
	end
	
	return true;
end

-- CharClassManager.helperAddClassFeatureMain
function helperAddClassFeatureMain(rAdd)
	-- Skip certain entries
	if rAdd.bWizard then
		if rAdd.sSourceType == "abilityscoreimprovement" then
			return;
		end
	end

	-- Prep some variables
	if rAdd.nodeClass then
		rAdd.sFeatureClassName = StringManager.trim(DB.getValue(rAdd.nodeClass, "name", ""));
	else
		rAdd.sFeatureClassName = StringManager.trim(DB.getValue(rAdd.nodeSource, "...name", ""));
	end
	local sSourceNameLower = StringManager.trim(rAdd.sSourceName):lower();

	-- Get the final feature name; and check if it exists
	local sFeatureName = rAdd.sSourceName;
	if CharManager.hasFeature(rAdd.nodeChar, sFeatureName) then
		if sSourceNameLower == CharManager.FEATURE_SPELLCASTING or sSourceNameLower == CharManager.FEATURE_PACT_MAGIC then
			sFeatureName = sFeatureName .. " (" .. rAdd.sFeatureClassName .. ")";
			if CharManager.hasFeature(rAdd.nodeChar, sFeatureName) then
				return;
			end
		else
			return;
		end
	end

	-- Add standard feature record, and adjust name
	local vNew = CharClassManager.helperAddClassFeatureStandard(rAdd);
	DB.setValue(vNew, "name", "string", sFeatureName);

	-- Special handling
	if sSourceNameLower == CharManager.FEATURE_SPELLCASTING then
		CharClassManager.helperAddClassFeatureSpellcasting(rAdd);
	elseif sSourceNameLower == CharManager.FEATURE_PACT_MAGIC then
		CharClassManager.helperAddClassFeaturePactMagic(rAdd);
	elseif sSourceNameLower == CharManager.FEATURE_DRACONIC_RESILIENCE then
		CharClassManager.applyDraconicResilience(rAdd.nodeChar, true);
	elseif sSourceNameLower == CharManager.FEATURE_UNARMORED_DEFENSE then
		CharClassManager.applyUnarmoredDefense(rAdd.nodeChar, rAdd.nodeClass);
	elseif sSourceNameLower == CharManager.FEATURE_MAGIC_ITEM_ADEPT or
			sSourceNameLower == CharManager.FEATURE_MAGIC_ITEM_SAVANT or
			sSourceNameLower == CharManager.FEATURE_MAGIC_ITEM_MASTER then
		CharClassManager.applyAttunementAdjust(rAdd.nodeChar, 1);
	-- Level Up
	elseif sSourceNameLower == FEATURE_ABILITY_SCORE_INCREASES then
		applyAbilityScoreIncrease(rAdd.nodeChar, rAdd.nodeSource);
	else
		if not rAdd.bWizard then
			if sSourceNameLower == CharManager.FEATURE_ELDRITCH_INVOCATIONS then
				-- Note: Bypass skill proficiencies due to false positive in skill proficiency detection
			else
				CharManager.checkSkillProficiencies(rAdd.nodeChar, DB.getText(vNew, "text", ""));
			end
		end
	end

	-- Standard action addition handling
	CharManager.helperCheckActionsAdd(rAdd.nodeChar, rAdd.nodeSource, rAdd.sSourceType, rAdd.sFeatureClassName .. " Actions/Effects");
end
-- CharClassManager.helperAddClassFeatureSpellcasting
function helperAddClassFeatureSpellcasting(rAdd)
	-- Add spell casting ability
	local sSpellcasting = DB.getText(rAdd.nodeSource, "text", "");
	local sAbility = sSpellcasting:match("(%a+) is your spellcasting ability");
	if sAbility then
		local sSpellsLabel = Interface.getString("power_label_groupspells");
		local sLowerSpellsLabel = sSpellsLabel:lower();
		
		local bFoundSpellcasting = false;
		for _,vGroup in pairs (DB.getChildren(rAdd.nodeChar, "powergroup")) do
			if DB.getValue(vGroup, "name", ""):lower() == sLowerSpellsLabel then
				bFoundSpellcasting = true;
				break;
			end
		end
		
		local sNewGroupName = sSpellsLabel;
		if bFoundSpellcasting then
			sNewGroupName = sNewGroupName .. " (" .. rAdd.sFeatureClassName .. ")";
		end
		
		local nodePowerGroups = DB.createChild(rAdd.nodeChar, "powergroup");
		local nodeNewGroup = nodePowerGroups.createChild();
		DB.setValue(nodeNewGroup, "castertype", "string", "memorization");
		DB.setValue(nodeNewGroup, "stat", "string", sAbility:lower());
		DB.setValue(nodeNewGroup, "name", "string", sNewGroupName);
		
		if sSpellcasting:match("Preparing and Casting Spells") then
			local rActor = ActorManager.resolveActor(rAdd.nodeChar);
			DB.setValue(nodeNewGroup, "prepared", "number", math.min(1 + ActorManager5E.getAbilityBonus(rActor, sAbility:lower())));
		end
	end
	
	-- Add spell slot calculation info
	if rAdd.nodeClass then
		if DB.getValue(rAdd.nodeClass, "casterlevelinvmult", 0) == 0 then
			local nFeatureLevel = DB.getValue(rAdd.nodeSource, "level", 0);
			if nFeatureLevel > 0 then
				local sClassNameLower = rAdd.sFeatureClassName:lower();
				if (sClassNameLower == CharManager.CLASS_ARTIFICER) then
					DB.setValue(rAdd.nodeClass, "casterlevelinvmult", "number", -2);
				-- Level Up
				elseif (sClassNameLower == CLASS_HERALD) then
					DB.setValue(rAdd.nodeClass, "casterlevelinvmult", "number", 2);
				else
					DB.setValue(rAdd.nodeClass, "casterlevelinvmult", "number", nFeatureLevel);
				end
			end
		end
	end
end
-- CharClassManager.helperAddClassUpdateSpellSlots
function helperAddClassUpdateSpellSlots(rAdd)
	-- Handle Spellcasting slots
	local nNewCasterLevel = CharClassManager.calcSpellcastingLevel(rAdd.nodeChar);
	local tSpellcastingSlotChange = CharClassManager.helperGetSpellcastingSlotChange(rAdd.nCharCasterLevel, nNewCasterLevel);
	for i = 1,CharClassManager.SPELLCASTING_SLOT_LEVELS do
		if tSpellcastingSlotChange[i] then
			local sField = "powermeta.spellslots" .. i .. ".max";
			DB.setValue(rAdd.nodeChar, sField, "number", math.max(DB.getValue(rAdd.nodeChar, sField, 0) + tSpellcastingSlotChange[i], 0));
		end
	end
	
	-- Level Up (Replace)
	-- Handle Pact Magic slots
	local nNewPactMagicLevel = CharClassManager.calcPactMagicLevel(rAdd.nodeChar);
	if nNewPactMagicLevel > rAdd.nCharPactMagicLevel then
		for i = rAdd.nCharPactMagicLevel + 1, nNewPactMagicLevel do
			if i == 1 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 2 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
			elseif i == 3 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 4 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
			elseif i == 5 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 6 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 7 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 8 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 9 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagiclevel", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagiclevel", 0) + 1);
			elseif i == 10 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 3);
			elseif i == 11 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 4);
			elseif i == 12 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 13 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 2);
			elseif i == 14 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 15 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 16 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 17 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 18 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 19 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			elseif i == 20 then
				DB.setValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", "number", DB.getValue(rAdd.nodeChar, "powermeta.pactmagicpoints.max", 0) + 1);
			end
		end
	end
end
-- Level Up
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
