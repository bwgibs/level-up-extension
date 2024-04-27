-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function parseAction(s)
	if not s then
		return nil;
	end
	local nStarts, nEnds, sLabel, sMod, sDice = s:find("([%a%s%(%)]*[%a%(%)]+)%s*([%+%-–]?%d*)%s*([%w%+%(%)]*)");
	if not nStarts or sMod == "" then
		return nil;
	end
	return ActionSkill.getNPCRoll(self.getActor(), sLabel, tonumber(sMod) or 0, sDice);
end

function onChar(nKeyCode)
	super.onChar(nKeyCode);

	-- If alpha character, then build a potential autocomplete
	if ((nKeyCode >= 65) and (nKeyCode <= 90)) or ((nKeyCode >= 97) and (nKeyCode <= 122)) then
		self.checkAutoComplete();
	-- If space, then perform autocomplete
	elseif (nKeyCode == 32) then
		self.performAutoComplete();
	end
end
function checkAutoComplete()
	local nCursor = getCursorPosition();
	local s = getValue();

	local tStrings, tStringStats = StringManager.split(s, self.getActionSeparators(), true);
	for i = 1, #tStrings do
		if nCursor == tStringStats[i].endpos then
			if tStrings[i]:match("^([%a%s%(%)]*[%a%(%)]+)$") then
				local sCompletion = self.getCompletion(tStrings[i]);
				if sCompletion ~= "" then
					local sNewValue = s:sub(1, nCursor-1) .. sCompletion .. s:sub(nCursor);
					setValue(sNewValue);
					setSelectionPosition(nCursor + #sCompletion);
				end
			end
			return;
		end
	end
end
function performAutoComplete()
	local nLastCursor = getCursorPosition() - 1;
	if nLastCursor <= 0 then
		return;
	end
	local s = getValue();

	local tStrings, tStringStats = StringManager.split(s, self.getActionSeparators(), true);
	for i = 1, #tStrings do
		if nLastCursor == tStringStats[i].endpos then
			if tStrings[i]:match("^([%a%s%(%)]*[%a%(%)]+)$") then
				local sCompletion = self.getCompletion(tStrings[i]);
				if sCompletion ~= "" then
					local sNewValue = s:sub(1, nLastCursor - 1) .. sCompletion .. s:sub(nLastCursor);
					setValue(sNewValue);
					setCursorPosition(nLastCursor + 1 + #sCompletion);
					setSelectionPosition(nLastCursor + 1 + #sCompletion);
				end
			end
			return;
		end
	end
end
function getCompletion(s)
	local sLower = s:lower();
	for k,_ in pairs(DataCommon.skilldata) do
		if sLower == k:sub(1, #s):lower() then
			return k:sub(#s + 1);
		end
	end
	return "";
end
