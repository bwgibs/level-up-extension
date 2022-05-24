--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	onSummaryChanged();
	update();
end

function onSummaryChanged()
	local sDegree = degree.getValue();
	local sTradition = tradition.getValue();
	local sAction = action.getValue();

	local aText = {};
	if sDegree ~= "" then
		table.insert(aText, sDegree .. " degree");
	end
	if sTradition ~= "" then
		table.insert(aText, sTradition);
	end
	if sAction ~= "" then
		sAction = sAction:lower();
		table.insert(aText, sAction);
	end

	summary_label.setValue(table.concat(aText, " "));
end

function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;
	end

	return self[sControl].update(bReadOnly, bForceHide);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);

	local sTypeLower = DB.getValue(nodeRecord, "type", ""):lower();
	local bCombatManeuver = (sTypeLower == "combat maneuver");

	local bSection1 = false;
	if bReadOnly then
		type_label.setVisible(false);
		type.setVisible(false);
	else
		type_label.setVisible(true);
		type.setVisible(true);
		bSection1 = true;
	end

	local bSection2 = false;
	if updateControl("tradition", bReadOnly, bReadOnly or not bCombatManeuver) then bSection2 = true; end
	if updateControl("degree", bReadOnly, bReadOnly or not bCombatManeuver) then bSection2 = true; end
	if updateControl("action", bReadOnly, bReadOnly or not bCombatManeuver) then bSection2 = true; end
	if updateControl("exertion", bReadOnly, not bCombatManeuver) then bSection2 = true; end
	if (not bReadOnly) or (tradition.getValue() == "" and degree.getValue() == "" and action.getValue() == "") then
		summary_label.setVisible(false);
	else
		summary_label.setVisible(true);
		bSection2 = true;
	end

	text.setReadOnly(bReadOnly);

	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible(bSection1 or bSection2);
end
