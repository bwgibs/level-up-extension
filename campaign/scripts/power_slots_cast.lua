--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	rebuildSlots();
	DB.addHandler(DB.getPath(getDatabaseNode(), "powermeta.*.max"), "onUpdate", rebuildSlots);
	onModeChanged();
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "powermeta.*.max"), "onUpdate", rebuildSlots);
end

function onModeChanged()
	local nodeChar = getDatabaseNode();
	local sMode = DB.getValue(nodeChar, "powermode", "");
	if sMode == "preparation" then
		parentcontrol.setVisible(false);
	else
		local bSpellSlotsVisible = false;
		for i = 1, PowerManager.SPELL_LEVELS do
			if DB.getValue(nodeChar, "powermeta.spellslots" .. i .. ".max", 0) > 0 then
				bSpellSlotsVisible = true;
				break;
			end
		end
		-- Level Up
		local bPactMagicSlotsVisible = false;
		if DB.getValue(nodeChar, "powermeta.pactmagicpoints.max", 0) > 0 then
			bPactMagicSlotsVisible = true;
		end

		if bSpellSlotsVisible then
			spellslots.setVisible(true);
			spellslots_label.setVisible(bPactMagicSlotsVisible);
		else
			spellslots.setVisible(false);
			spellslots_label.setVisible(false);
		end
		if bPactMagicSlotsVisible then
			pactmagiccounter.setVisible(true);			-- Level Up
			pactmagicslots_label.setVisible(true);
		else
			pactmagiccounter.setVisible(false);			-- Level Up
			pactmagicslots_label.setVisible(false);
		end
		parentcontrol.setVisible(bSpellSlotsVisible or bPactMagicSlotsVisible);
	end
end

-- NOTE: We can not delete windows here;
-- 		because the counters in each window also have database node handlers
--		that will trigger either before or after
--		and can will generate errors when control no longer exists.
function rebuildListSlots(ctrlList, sPrefix)
	local nodeChar = getDatabaseNode();

	if ctrlList then
		local tWindows = ctrlList.getWindows();

		for i = 1, PowerManager.SPELL_LEVELS do
			if DB.getValue(nodeChar, "powermeta." .. sPrefix .. i .. ".max", 0) > 0 then
				local sLabel = getOrdinalLabel(i);
				local bExists = false;
				for _,wChild in ipairs(tWindows) do
					if wChild.label.getValue() == sLabel then
						bExists = true;
					end
				end
				if not bExists then
					local w = ctrlList.createWindow();
					w.label.setValue(sLabel);
					w.counter.setMaxNode(DB.getPath(nodeChar, "powermeta." .. sPrefix .. i .. ".max"));
					w.counter.setCurrNode(DB.getPath(nodeChar, "powermeta." .. sPrefix .. i .. ".used"));
				end
			end
		end

		ctrlList.applyFilter();
		ctrlList.applySort();
	else
		-- Level Up
		pactmagiccounter.setMaxNode(DB.getPath(nodeChar, "powermeta." .. sPrefix .. ".max"));
		pactmagiccounter.setCurrNode(DB.getPath(nodeChar, "powermeta." .. sPrefix .. ".used"));
	end
end

function getOrdinalLabel(n)
	if n <= 0 then
		return tostring(n) or "";
	end
	if n == 1 then
		return "1st";
	elseif n == 2 then
		return "2nd";
	elseif n == 3 then
		return "3rd";
	end
	return (tostring(n) or "") .. "th";
end

function rebuildSlots()
	rebuildListSlots(spellslots, "spellslots");
	rebuildListSlots(nil, "pactmagicpoints");			-- Level Up
end
