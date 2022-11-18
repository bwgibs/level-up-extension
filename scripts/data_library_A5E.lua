--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

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
	-- 5E overrides
	["npc"] = {
		aCustomFilters = {
			["CR"] = { sField = "cr", sType = "number", fSort = sortNPCCRValues },
			["Type"] = { sField = "type", fGetValue = getNPCTypeValue },
		},
	},
	["feat"] = {
		aCustomFilters = {
			["Type"] = { sField = "type", fGetValue = getFeatTypeValue },
			["Tradition"] = { sField = "tradition" },
			["Degree"] = { sField = "degree" },
		},
	},
	["spell"] = {
		aCustomFilters = {
			["Source"] = { sField = "source", fGetValue = getSpellSourceValue },
			["Level"] = { sField = "level", sType = "number" },
			["Ritual"] = { sField = "ritual", sType = "boolean" },
			["School"] = { sField = "school", fGetValue = getSpellSchoolValue },
			["Rare"] = { sField = "rare", sType = "boolean" },
		},
	},

	-- New record types
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
	LibraryData.overrideRecordTypes(aRecordOverrides);
end
