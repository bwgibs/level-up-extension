-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function getItemIsIdentified(vRecord, vDefault)
	return LibraryData.getIDState("item", vRecord, true);
end

function sortNPCCRValues(aFilterValues)
	local function fNPCSortValue(a)
		local v;
		if a == "1/2" then
			v = 0.5;
		elseif a == "1/4" then
			v = 0.25;
		elseif a == "1/8" then
			v = 0.125;
		else
			v = tonumber(a) or 0;
		end
		return v;
	end
	table.sort(aFilterValues, function(a,b) return fNPCSortValue(a) < fNPCSortValue(b); end);
	return aFilterValues;
end

function getNPCTypeValue(vNode)
	local aTypes = StringManager.parseWords(DB.getValue(vNode, "type", ""):lower());

	-- Vehicle or Siege Weapon
	if aTypes[2] == "vehicle" or aTypes[2] == "weapon" then
		aTypes[1] = aTypes[1] .. " " .. aTypes[2];
		table.remove(aTypes, 2);
	end
	
	-- Swarm or Group
	if (aTypes[1] == "swarm" or aTypes[1] == "group") and aTypes[2] == "of" then
		if aTypes[3] == "medium" or DataCommon.creaturesize[aTypes[3]] then
			table.remove(aTypes, 3);
end
		table.remove(aTypes, 2);
	end

	if #(aTypes) > 0 then
		for k,v in ipairs(aTypes) do			
			local sClass = StringManager.capitalizeAll(v);
			if sClass then
				-- Remove trailing 's' from plural types
				if string.sub(sClass, -1) == "s" then
					sClass = string.sub(sClass, 1, -2);
				end
				
				aTypes[k] = sClass;
			end
		end
		
		-- Cleanup
		for k,v in ipairs(aTypes) do
			if v == "Or" then
				table.remove(aTypes, k);
			end
		end
	end
	return aTypes;
end

function getItemRarityValue(vNode)
	local v = StringManager.trim(DB.getValue(vNode, "rarity", ""));
	local sType = v:match("^[^(]+");
	if sType then
		v = StringManager.trim(sType);
	end
	v = StringManager.capitalize(v);
	return v;
end

function getItemAttunementValue(vNode)
	local v = StringManager.trim(DB.getValue(vNode, "rarity", "")):lower();
	if v:match("%(requires attunement") then
		return LibraryData.sFilterValueYes;
	end
	return LibraryData.sFilterValueNo;
end

function getItemRecordDisplayClass(vNode)
	local sRecordDisplayClass = "item";
	if vNode then
		local sBasePath, sSecondPath = UtilityManager.getDataBaseNodePathSplit(vNode);
		if sBasePath == "reference" then
			if sSecondPath == "equipmentdata" then
				local sTypeLower = StringManager.trim(DB.getValue(DB.getPath(vNode, "type"), ""):lower());
				if sTypeLower == "weapon" then
					sRecordDisplayClass = "reference_weapon";
				elseif sTypeLower == "armor" then
					sRecordDisplayClass = "reference_armor";
				elseif sTypeLower == "mounts and other animals" then
					sRecordDisplayClass = "reference_mountsandotheranimals";
				elseif sTypeLower == "waterborne vehicles" then
					sRecordDisplayClass = "reference_waterbornevehicles";
				elseif sTypeLower == "vehicle" then
					sRecordDisplayClass = "reference_vehicle";
				else
					sRecordDisplayClass = "reference_equipment";
				end
			else
				sRecordDisplayClass = "reference_magicitem";
			end
		end
	end
	return sRecordDisplayClass;
end

function isItemIdentifiable(vNode)
	return (getItemRecordDisplayClass(vNode) == "item");
end

function getSpellSourceValue(vNode)
	local aSources = StringManager.split(DB.getValue(vNode, "source", ""), ",;", true);
	if #(aSources) > 0 then
		for k,v in ipairs(aSources) do
			local sClass = StringManager.capitalize(v);
			if sClass then
				aSources[k] = sClass;
			end
		end
	end
	return aSources;
end

function getSpellSchoolValue(vNode)
	local aSchools = StringManager.split(DB.getValue(vNode, "school", ""), ",;", true);
	if #(aSchools) > 0 then
		for k,v in ipairs(aSchools) do
			local sSchool = StringManager.capitalize(v);
			if sSchool then
				aSchools[k] = sSchool;
			end
		end
	end
	return aSchools;
end

function getFeatTypeValue(vNode)
	local v = DB.getValue(vNode, "type", "");
	if v == "" then
		v = "Feat";
	end
	return v;
end

aRecordOverrides = {
	-- CoreRPG overrides
	["quest"] = { 
		aDataMap = { "quest", "reference.questdata" }, 
	},
	["image"] = { 
		aDataMap = { "image", "reference.imagedata" }, 
	},
	["npc"] = { 
		aDataMap = { "npc", "reference.npcdata" }, 
		aGMListButtons = { "button_npc_letter", "button_npc_cr", "button_npc_type" },
		aGMEditButtons = { "button_add_npc_import" },
		aCustomFilters = {
			["CR"] = { sField = "cr", sType = "number", fSort = sortNPCCRValues },
			["Type"] = { sField = "type", fGetValue = getNPCTypeValue },
		},
	},
	["item"] = { 
		fIsIdentifiable = isItemIdentifiable,
		aDataMap = { "item", "reference.equipmentdata", "reference.magicitemdata" }, 
		fRecordDisplayClass = getItemRecordDisplayClass,
		aRecordDisplayClasses = { "item", "reference_magicitem", "reference_armor", "reference_weapon", "reference_equipment", "reference_mountsandotheranimals", "reference_waterbornevehicles", "reference_vehicle" },
		aGMListButtons = { "button_item_armor", "button_item_weapons", "button_item_templates", "button_forge_item" },
		aPlayerListButtons = { "button_item_armor", "button_item_weapons" },
		aCustomFilters = {
			["Type"] = { sField = "type" },
			["Rarity"] = { sField = "rarity", fGetValue = getItemRarityValue },
			["Attunement?"] = { sField = "rarity", fGetValue = getItemAttunementValue },
		},
	},
	
	-- New record types
	["itemtemplate"] = { 
		bExport = true,
		bHidden = true,
		aDataMap = { "itemtemplate", "reference.magicrefitemdata" }, 
		aGMListButtons = { "button_forge_item"  };
		aCustomFilters = {
			["Type"] = { sField = "type" },
		},
	},
	["background"] = {
		bExport = true, 
		aDataMap = { "background", "reference.backgrounddata" }, 
		sRecordDisplayClass = "reference_background", 
	},
	["class"] = {
		bExport = true, 
		aDataMap = { "class", "reference.classdata" }, 
		sRecordDisplayClass = "reference_class", 
	},
	["feat"] = {
		bExport = true, 
		aDataMap = { "feat", "reference.featdata" }, 
		sRecordDisplayClass = "reference_feat", 
		aCustomFilters = {
			["Type"] = { sField = "type", fGetValue = getFeatTypeValue },
			["Tradition"] = { sField = "tradition" },
			["Degree"] = { sField = "degree" },
		},
	},
	["race"] = {
		bExport = true, 
		aDataMap = { "race", "reference.racedata" }, 
		sRecordDisplayClass = "reference_race", 
	},
	["skill"] = {
		bExport = true, 
		aDataMap = { "skill", "reference.skilldata" }, 
		sRecordDisplayClass = "reference_skill", 
	},
	["spell"] = {
		bExport = true, 
		aDataMap = { "spell", "reference.spelldata" }, 
		sRecordDisplayClass = "power", 
		aCustomFilters = {
			["Source"] = { sField = "source", fGetValue = getSpellSourceValue },
			["Level"] = { sField = "level", sType = "number" },
			["Ritual"] = { sField = "ritual", sType = "boolean" },
			["School"] = { sField = "school", fGetValue = getSpellSchoolValue },
			["Rare"] = { sField = "rare", sType = "boolean" },
		},
	},
	["culture"] = {
		bExport = true, 
		aDataMap = { "culture", "reference.culturedata" },
		sRecordDisplayClass = "reference_culture",
		sSidebarCategory = "create",
	},
	["destiny"] = {
		bExport = true, 
		aDataMap = { "destiny", "reference.destinydata" },
		sRecordDisplayClass = "reference_destiny",
		sSidebarCategory = "create",
	},
};

function onInit()
	LibraryData.setCustomFilterHandler("item_isidentified", getItemIsIdentified);

	LibraryData.overrideRecordTypes(aRecordOverrides);
end
