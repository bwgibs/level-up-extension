--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function clearAdvantage(rRoll)
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

	if (bADV and not bDIS) or (bDIS and not bADV) then
		if #(rRoll.aDice) > 1 then
			table.remove(rRoll.aDice, 2);
		end
	end

	return bADV, bDIS;
end

function addEffectsTag(rRoll, bEffects, aAddDice, nAddMod)
	if bEffects then
		aAddDice = aAddDice or {};
		nAddMod = nAddMod or 0;

		local sEffectsTag = Interface.getString("effects_tag");
		local sMatch, sDice = rRoll.sDesc:match("% [(" .. sEffectsTag .. ") ?([^%]]*)%]");
		if sMatch then
			local aDice, nMod = DiceManager.convertStringToDice(sDice);
			rRoll.sDesc:gsub(" %[" .. sEffectsTag .. " ?[^%]]*%]", "");
			for _,sDieType in ipairs(aDice) do
				table.insert(aAddDice, sDieType);
			end
			nAddMod = nAddMod + nMod;
		end

		local sEffects;
		local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
		if sMod ~= "" then
			sEffects = " [" .. sEffectsTag .. " " .. sMod .. "]";
		else
			sEffects = " [" .. sEffectsTag .. "]";
		end
		rRoll.sDesc = rRoll.sDesc .. sEffects;
	end
end