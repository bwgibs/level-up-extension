--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

TRAIT_HEAVY_LIFTER = "heavy lifter";

function onInit()
	CharEncumbranceManager5E.getEncumbranceMult = getEncumbranceMult;
	CharEncumbranceManager5E.updateEncumbranceLimit = updateEncumbranceLimit;
end

function updateEncumbranceLimit(nodeChar)
	local nStat = DB.getValue(nodeChar, "abilities.strength.score", 10);
	local nEncLimit = math.max(nStat, 0) * 5;

	nEncLimit = nEncLimit * CharEncumbranceManager5E.getEncumbranceMult(nodeChar);

	DB.setValue(nodeChar, "encumbrance.encumbered", "number", nEncLimit);
	DB.setValue(nodeChar, "encumbrance.encumberedheavy", "number", nEncLimit * 2);
	DB.setValue(nodeChar, "encumbrance.max", "number", nEncLimit * 3);
	DB.setValue(nodeChar, "encumbrance.liftpushdrag", "number", nEncLimit * 6);

	local nBulky = DB.getValue(nodeChar, "abilities.strength.bonus", 0) + 1;
	if nBulky < 1 then
		nBulky = 1;
	end
	nBulky = nBulky * CharEncumbranceManager5E.getEncumbranceMult(nodeChar);

	DB.setValue(nodeChar, "encumbrance.bulkyitems", "number", nBulky);
	DB.setValue(nodeChar, "encumbrance.supply", "number", nStat);
end

function getEncumbranceMult(nodeChar)
	local sSize = StringManager.trim(DB.getValue(nodeChar, "size", ""):lower());

	local nSize = 2; -- Medium
	if sSize == "tiny" then
		nSize = 0;
	elseif sSize == "small" then
		nSize = 1;
	elseif sSize == "large" then
		nSize = 3;
	elseif sSize == "huge" then
		nSize = 4;
	elseif sSize == "gargantuan" then
		nSize = 5;
	end
	-- Level Up
	if CharManager.hasTrait(nodeChar, CharManager.TRAIT_POWERFUL_BUILD) or CharManager.hasTrait(nodeChar, TRAIT_HEAVY_LIFTER) then
		nSize = nSize + 1;
	end

	local nMult = 1; -- Both Small and Medium use a multiplier of 1
	if nSize == 0 then
		nMult = 0.5;
	elseif nSize == 3 then
		nMult = 2;
	elseif nSize == 4 then
		nMult = 4;
	elseif nSize == 5 then
		nMult = 8;
	elseif nSize == 6 then
		nMult = 16;
	end

	if CharManager.hasFeature(nodeChar, CharManager.FEATURE_ASPECT_OF_THE_BEAR) then
		nMult = nMult * 2;
	end

	return nMult;
end
