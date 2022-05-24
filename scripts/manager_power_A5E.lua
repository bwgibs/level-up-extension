--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	PowerManager.resetPowers = resetPowers;
end

-------------------
-- POWER MANAGEMENT
-------------------

function resetPowers(nodeCaster, bLong)
	local aListGroups = {};

	-- Build list of power groups
	for _,vGroup in pairs(DB.getChildren(nodeCaster, "powergroup")) do
		local sGroup = DB.getValue(vGroup, "name", "");
		if not aListGroups[sGroup] then
			local rGroup = {};
			rGroup.sName = sGroup;
			rGroup.sType = DB.getValue(vGroup, "castertype", "");
			rGroup.nUses = DB.getValue(vGroup, "uses", 0);
			rGroup.sUsesPeriod = DB.getValue(vGroup, "usesperiod", "");
			rGroup.nodeGroup = vGroup;

			aListGroups[sGroup] = rGroup;
		end
	end

	-- Reset power usage
	for _,vPower in pairs(DB.getChildren(nodeCaster, "powers")) do
		local bReset = true;

		local sGroup = DB.getValue(vPower, "group", "");
		local rGroup = aListGroups[sGroup];
		local bCaster = (rGroup and rGroup.sType ~= "");

		if not bCaster then
			if rGroup and (rGroup.nUses > 0) then
				if rGroup.sUsesPeriod == "once" then
					bReset = false;
				elseif not bLong and rGroup.sUsesPeriod ~= "enc" then
					bReset = false;
				end
			else
				local sPowerUsesPeriod = DB.getValue(vPower, "usesperiod", "");
				if sPowerUsesPeriod == "once" then
					bReset = false;
				elseif not bLong and sPowerUsesPeriod ~= "enc" then
					bReset = false;
				end
			end
		end

		if bReset then
			DB.setValue(vPower, "cast", "number", 0);
		end
	end

	-- Reset spell slots
	-- Level Up
	DB.setValue(nodeCaster, "powermeta.pactmagicpoints.used", "number", 0);

	if bLong then
		for i = 1, PowerManager.SPELL_LEVELS do
			DB.setValue(nodeCaster, "powermeta.spellslots" .. i .. ".used", "number", 0);
		end
	end
end
