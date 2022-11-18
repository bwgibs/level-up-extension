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
	local rActor = ActorManager.resolveActor(nodeChar);
	local nActorSize = ActorCommonManager.getCreatureSizeDnD5(rActor);

	if CharManager.hasTrait(nodeChar, CharManager.TRAIT_POWERFUL_BUILD) then
		nActorSize = nActorSize + 1;
	elseif CharManager.hasTrait(nodeChar, CharManager.TRAIT_HIPPO_BUILD) then
		nActorSize = nActorSize + 1;
	-- Level Up
	elseif CharManager.hasTrait(nodeChar, TRAIT_HEAVY_LIFTER) then
		nActorSize = nActorSize + 1;
	end
	
	local nMult = 1; -- Both Small and Medium use a multiplier of 1
	if nActorSize == -2 then
		nMult = 0.5;
	elseif nActorSize > 0 then
		nMult = 2 ^ nActorSize;
	end

	if CharManager.hasFeature(nodeChar, CharManager.FEATURE_ASPECT_OF_THE_BEAR) then
		nMult = nMult * 2;
	end
	
	return nMult;
end
