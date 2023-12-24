--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local _fnDefaultGetDefenseValue;

function onInit()
	_fnDefaultGetDefenseValue = ActorManager5E.getDefenseValue;
	ActorManager5E.getDefenseValue = getDefenseValue;
end

function getDefenseValue(rAttacker, rDefender, rRoll)
	local nDefense, _, nDefenseEffectMod, bADV, bDIS = _fnDefaultGetDefenseValue(rAttacker, rDefender, rRoll);

	if rDefender and rRoll and ActorManager.hasCT(rDefender) then
		if EffectManager5E.hasEffect(rDefender, "Slowed", rAttacker) then
			nDefenseEffectMod = nDefenseEffectMod - 2;
		end
	end

	return nDefense, 0, nDefenseEffectMod, bADV, bDIS;
end
