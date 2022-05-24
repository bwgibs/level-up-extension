--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

-- Examples:
-- { type = "attack", range = "[M|R]", [modifier = #] }
--		If modifier defined, then attack bonus will be this fixed value
--		Otherwise, the attack bonus will be the ability bonus defined for the spell group
--
-- { type = "damage", clauses = { { dice = { "d#", ... }, modifier = #, type = "", [stat = ""] }, ... } }
--		Each damage action can have multiple clauses which can do different damage types
--
-- { type = "heal", [subtype = "temp", ][sTargeting = "self", ] clauses = { { dice = { "d#", ... }, bonus = #, [stat = ""] }, ... } }
--		Each heal action can have multiple clauses
--		Heal actions are either direct healing or granting temporary hit points (if subtype = "temp" set)
--		If sTargeting = "self" set, then the heal will always be applied to self instead of target.
--
-- { type = "powersave", save = "<ability>", [savemod = #, ][savestat = "<ability>", ][onmissdamage = "half"] }
--		If savemod defined, then the DC will be this fixed value.
--		If savestat defined, then the DC will be calculated as 8 + specified ability bonus + proficiency bonus
--		Otherwise, the save DC will be the same as the spell group
--
-- { type = "effect", sName = "<effect text>", [sTargeting = "self", ][nDuration = #, ][sUnits = "[<empty>|minute|hour|day]", ][sApply = "[<empty>|action|roll|single]"] }
--		If sTargeting = "self" set, then the effect will always be applied to self instead of target.
--		If nDuration not set or is equal to zero, then the effect will not expire.


-- Spell lookup data
parsedata = {
	-- ["accelerando"] = {
	-- },
	-- 5E SAME
	["aid"] = {
		{ type = "heal", subtype = "temp", clauses = { { bonus = 5 } } },
	},
	-- ["air wave"] = {
	-- },
	-- ["altered strike"] = {
	-- },
	-- ["angel paradox"] = {
	-- },
	-- ["arcane muscles"] = {
	-- },
	-- ["arcane riposte"] = {
	-- },
	-- ["arcane sword"] = {
	-- },
	-- ["aspect of the moon"] = {
	-- },
	-- 5E SAME
	["bane"] = {
		{ type = "powersave", save = "charisma", magic = true, savebase = "group" },
		{ type = "effect", sName = "ATK: -1d4; SAVE: -1d4; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- LEVEL UP
	["beshala's unnerving bane"] = {
		{ type = "powersave", save = "charisma", magic = true, savebase = "group" },
		{ type = "effect", sName = "Rattled; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- LEVEL UP
	["kreven’s tormenting bane"] = {
		{ type = "powersave", save = "charisma", magic = true, savebase = "group" },
	},
	-- ["battlecry ballad"] = {
	-- },
	-- 5E SAME
	["beacon of hope"] = {
		{ type = "effect", sName = "ADVSAV: wisdom; ADVSAV: death; NOTE: Receive Max Healing; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- 5E SAME
	["bestow curse"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "DISCHK: strength; DISSAV: strength; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "DISCHK: dexterity; DISSAV: dexterity; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "DISCHK: constitution; DISSAV: constitution; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "DISCHK: intelligence; DISSAV: intelligence; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "DISCHK: wisdom; DISSAV: wisdom; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "DISCHK: charisma; DISSAV: charisma; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "[TRGT]; GRANTDISATK; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Wisdom save or lose action; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "[TRGT]; DMG: 1d8 necrotic; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
	},
	-- LEVEL UP
	["beshela’s enduring bestow curse"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "DISCHK: strength; DISSAV: strength" },
		{ type = "effect", sName = "DISCHK: dexterity; DISSAV: dexterity" },
		{ type = "effect", sName = "DISCHK: constitution; DISSAV: constitution" },
		{ type = "effect", sName = "DISCHK: intelligence; DISSAV: intelligence" },
		{ type = "effect", sName = "DISCHK: wisdom; DISSAV: wisdom" },
		{ type = "effect", sName = "DISCHK: charisma; DISSAV: charisma" },
		{ type = "effect", sName = "[TRGT]; GRANTDISATK" },
		{ type = "effect", sName = "NOTE: Wisdom save or lose action" },
		{ type = "effect", sName = "[TRGT]; DMG: 1d8 necrotic" },
	},
	-- 5E SAME
	["blade barrier"] = {
		{ type = "powersave", save = "dexterity", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10", "d10", "d10" }, dmgtype = "slashing,magic" } } },
	},
	-- 5E ONLY
	["blade ward"] = {
		{ type = "effect", sName = "RESIST: bludgeoning,piercing,slashing", nDuration = 1 },
	},
	-- 5E SAME
	["bless"] = {
		{ type = "effect", sName = "ATK: 1d4; SAVE: 1d4; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- 5E SAME
	["blindness/deafness"] = {
		{ type = "powersave", save = "constitution", magic = true, savebase = "group" },
		{ type = "effect", sName = "Blinded; NOTE: End of Round Save", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "Deafened; NOTE: End of Round Save", nDuration = 1, sUnits = "minute" },
	},
	-- ["blood-writ bargain"] = {
	-- },
	-- 5E SAME
	["blur"] = {
		{ type = "effect", sName = "GRANTDISATK; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
	},
	-- ["calculate"] = {
	-- },
	-- ["calculated retribution"] = {
	-- },
	-- 5E SAME
	["chill touch"] = {
		{ type = "attack", range = "R", spell = true, base = "group" },
		{ type = "damage", clauses = { { dice = { "d8" }, dmgtype = "necrotic" } } },
		{ type = "effect", sName = "NOTE: Can't regain hit points", nDuration = 1 },
		{ type = "effect", sName = "[TRGT]; GRANTDISATK", sTargeting = "self", nDuration = 1 },
	},
	-- 5E ONLY
	["chromatic orb"] = {
		{ type = "attack", range = "R", spell = true, base = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, dmgtype = "acid" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, dmgtype = "cold" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, dmgtype = "fire" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, dmgtype = "lightning" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, dmgtype = "poison" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8" }, dmgtype = "thunder" } } },
	},
	-- ["circular breathing"] = {
	-- },
	-- ["cobra's spit"] = {
	-- },
	-- 5E SAME
	["color spray"] = {
		{ type = "effect", sName = "Blinded", nDuration = 1 },
	},
	-- 5E MODIFIED
	["contagion"] = {
		{ type = "attack", range = "M", spell = true, base = "group" },
		{ type = "effect", sName = "NOTE: Contagion", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Blinding Sickness; DISCHK: wisdom; DISSAV: wisdom; Blinded", nDuration = 7, sUnits = "day" },
		{ type = "effect", sName = "NOTE: Filth Fever; DISCHK: strength; DISSAV: strength; NOTE: DIS on strength attacks", nDuration = 7, sUnits = "day" },
		{ type = "effect", sName = "NOTE: Flesh Rot; DISCHK: charisma; VULN: all", nDuration = 7, sUnits = "day" },
		{ type = "effect", sName = "NOTE: Mindfire; DISCHK: intelligence; NOTE: Confused", nDuration = 7, sUnits = "day" },
		{ type = "effect", sName = "NOTE: Rattling Cough; Rattled; DISCHK: dexterity; DISSAV: dexterity; NOTE: DIS on dexterity attacks", nDuration = 7, sUnits = "day" },
		{ type = "effect", sName = "NOTE: Slimy Doom; DISCHK: constitution; DISSAV: constitution; NOTE: Stunned when damaged", nDuration = 7, sUnits = "day" },
	},
	-- ["corpse explosion"] = {
	-- },
	-- 5E ONLY
	["crown of madness"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "Charmed; NOTE: Save on end of round; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- ["crushing haymaker"] = {
	-- },
	-- 5E ONLY
	["crusader's mantle"] = {
		{ type = "effect", sName = "DMG: 1d4 radiant; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- ["darklight"] = {
	-- },
	-- ["deadweight"] = {
	-- },
	-- 5E SAME
	["death ward"] = {
		{ type = "effect", sName = "NOTE: Death Ward", nDuration = 8, sUnits = "hour" },
	},
	-- 5E MODIFIED
	["dispel evil and good"] = {
		{ type = "attack", range = "M", spell = true, base = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8", "d8", "d8" }, dmgtype = "radiant" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8", "d8", "d8" }, dmgtype = "necrotic" } } },
		{ type = "effect", sName = "IFT: TYPE(celestial, elemental, fey, fiend, undead); GRANTDISATK; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "Stunned", nDuration = 1 },
	},
	-- LEVEL UP
	["leska's dismissal"] = {
		{ type = "attack", range = "M", spell = true, base = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8", "d8", "d8" }, dmgtype = "radiant" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8", "d8", "d8" }, dmgtype = "necrotic" } } },
		{ type = "effect", sName = "IFT: TYPE(aberrations, dragons, celestial, elemental, fey, fiend, undead); GRANTDISATK; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "Stunned", nDuration = 1 },
	},
	-- 5E SAME
	["divine favor"] = {
		{ type = "effect", sName = "DMG: 1d4 radiant; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
	},
	["sigismund’s spiteful divine favor"] = {
		{ type = "effect", sName = "DMG: 1d4 necrotic; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
	},
	-- 5E MODIFIED
	["divine word"] = {
		{ type = "effect", sName = "Deafened", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "Deafened; Blinded", nDuration = 10, sUnits = "minute" },
		{ type = "effect", sName = "Blinded; Deafened; Stunned", nDuration = 1, sUnits = "hour" },
	},
	-- LEVEL UP
	["leska’s imprecating divine word"] = {
		{ type = "effect", sName = "Deafened", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "Deafened; Blinded", nDuration = 10, sUnits = "minute" },
		{ type = "effect", sName = "Blinded; Deafened; Stunned", nDuration = 1, sUnits = "hour" },
	},
	-- ["dramatic sting"] = {
	-- },
	-- ["earth barrier"] = {
	-- },
	-- ["eldritch cube"] = {
	-- },
	-- 5E SAME
	["enhance ability"] = {
		{ type = "effect", sName = "ADVCHK: constitution; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "heal", subtype = "temp", clauses = { { dice = { "d6", "d6" } } } },
		{ type = "effect", sName = "ADVCHK: strength; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: dexterity; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: charisma; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: intelligence; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: wisdom; (C)", nDuration = 1, sUnits = "hour" },
	},
	-- LEVEL UP
	["nevard’s guarded enhance ability"] = {
		{ type = "effect", sName = "ADVCHK: constitution; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "heal", subtype = "temp", clauses = { { dice = { "d6", "d6" } } } },
		{ type = "effect", sName = "ADVCHK: strength; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: dexterity; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: charisma; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: intelligence; (C)", nDuration = 1, sUnits = "hour" },
		{ type = "effect", sName = "ADVCHK: wisdom; (C)", nDuration = 1, sUnits = "hour" },
	},
	-- 5E SAME
	["enlarge/reduce"] = {
		{ type = "powersave", save = "constitution", magic = true, savebase = "group" },
		{ type = "effect", sName = "NOTE: Enlarged; ADVCHK: strength; ADVSAV: strength; DMG: 1d4; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Reduced; DISCHK: strength; DISSAV: strength; DMG: -1d4; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- ["enrage architecture"] = {
	-- },
	-- 5E SAME
	["faerie fire"] = {
		{ type = "powersave", save = "dexterity", magic = true, savebase = "group" },
		{ type = "effect", sName = "GRANTADVATK; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- LEVEL UP
	["beshela’s rattling faerie fire"] = {
		{ type = "powersave", save = "dexterity", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d4" }, dmgtype = "psychic" } } },
		{ type = "effect", sName = "GRANTADVATK; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "Rattled", nDuration = 1 },
	},
	-- 5E ONLY
	["feign death"] = {
		{ type = "effect", sName = "Blinded; Incapacitated; RESIST: all, !psychic", nDuration = 1, sUnits = "hour" },
	},
	-- ["flex"] = {
	-- },
	-- 5E SAME
	["forbiddance"] = {
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10", "d10" }, dmgtype = "radiant" } } },
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10", "d10" }, dmgtype = "necrotic" } } },
	},
	-- ["force of will"] = {
	-- },
	-- ["force punch"] = {
	-- },
	-- ["forest army"] = {
	-- },
	-- 5E REMOVED
	["friends"] = {
		{ type = "effect", sName = "ADVCHK: charisma; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- 5E MODIFIED
	["gaseous form"] = {
		{ type = "effect", sName = "NOTE: Gaseous Form; RESIST: bludgeoning, piercing, slashing, !magic; ADVSAV: strength; ADVSAV: dexterity; ADVSAV: constitution; (C)", nDuration = 1, sUnits = "hour" },
	},
	-- 5E SAME
	["geas"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "Charmed" },
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10", "d10" }, type = "psychic" } } },
	},
	-- 5E SAME
	["glyph of warding"] = {
		{ type = "powersave", save = "dexterity", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "acid" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "cold" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "fire" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "lightning" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "thunder" } } },
	},
	-- LEVEL UP
	["stekart’s dependable glyph of warding"] = {
		{ type = "powersave", save = "dexterity", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "acid" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "cold" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "fire" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "lightning" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "thunder" } } },
	},
	-- LEVEL UP
	["stekart’s dependable glyph of warding"] = {
		{ type = "powersave", save = "dexterity", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "acid" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "cold" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "fire" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "lightning" } } },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8" }, dmgtype = "thunder" } } },
	},
	-- ["grapevine"] = {
	-- },
	-- 5E SAME
	["grease"] = {
		{ type = "powersave", save = "dexterity", magic = true, savebase = "group" },
		{ type = "effect", sName = "Prone" },
	},
	-- LEVEL UP
	["katrina’s flammable grease"] = {
		{ type = "powersave", save = "dexterity", magic = true, savebase = "group" },
		{ type = "effect", sName = "Prone" },
		{ type = "effect", sName = "DMGO: 1d6 fire" },
	},
	-- 5E ONLY
	["guardian of faith"] = {
		{ type = "effect", sName = "NOTE: Guardian of Faith", sTargeting = "self", nDuration = 8, sUnits = "hour" },
		{ type = "powersave", save = "dexterity", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { modifier = 20, dmgtype = "radiant" } } },
	},
	-- 5E SAME
	["guiding bolt"] = {
		{ type = "attack", range = "R", spell = true, base = "group" },
		{ type = "damage", clauses = { { dice = { "d6", "d6", "d6", "d6" }, dmgtype = "radiant" } } },
		{ type = "effect", sName = "GRANTADVATK", nDuration = 1, sApply = "roll" },
	},
	-- LEVEL UP
	["leska’s marked guiding bolt"] = {
		{ type = "attack", range = "R", spell = true, base = "group" },
		{ type = "damage", clauses = { { dice = { "d6", "d6", "d6", "d6" }, dmgtype = "radiant" } } },
		{ type = "effect", sName = "GRANTADVATK", nDuration = 1, sApply = "roll" },
	},
	-- 5E SAME
	["hallow"] = {
		{ type = "powersave", save = "charisma", magic = true, savebase = "group" },
		{ type = "effect", sName = "IMMUNE: frightened; [FIXED]" },
		{ type = "effect", sName = "RESIST: acid; [FIXED]" },
		{ type = "effect", sName = "RESIST: cold; [FIXED]" },
		{ type = "effect", sName = "RESIST: fire; [FIXED]" },
		{ type = "effect", sName = "RESIST: lightning; [FIXED]" },
		{ type = "effect", sName = "RESIST: necrotic; [FIXED]" },
		{ type = "effect", sName = "RESIST: poison; [FIXED]" },
		{ type = "effect", sName = "RESIST: psychic; [FIXED]" },
		{ type = "effect", sName = "RESIST: radiant; [FIXED]" },
		{ type = "effect", sName = "RESIST: thunder; [FIXED]" },
		{ type = "effect", sName = "VULN: acid; [FIXED]" },
		{ type = "effect", sName = "VULN: cold; [FIXED]" },
		{ type = "effect", sName = "VULN: fire; [FIXED]" },
		{ type = "effect", sName = "VULN: lightning; [FIXED]" },
		{ type = "effect", sName = "VULN: necrotic; [FIXED]" },
		{ type = "effect", sName = "VULN: poison; [FIXED]" },
		{ type = "effect", sName = "VULN: psychic; [FIXED]" },
		{ type = "effect", sName = "VULN: radiant; [FIXED]" },
		{ type = "effect", sName = "VULN: thunder; [FIXED]" },
		{ type = "effect", sName = "Frightened; [FIXED]" },
		{ type = "effect", sName = "NOTE: Silenced; [FIXED]" },
		{ type = "effect", sName = "NOTE: Tongues; [FIXED]" },
	},
	-- ["harmonic resonance"] = {
	-- },
	-- 5E SAME
	["haste"] = {
		{ type = "effect", sName = "NOTE: Hasted; AC: 2; ADVSAV: dexterity; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- ["heart of dis"] = {
	-- },
	-- 5E MODIFIED
	["heroes' feast"] = {
		{ type = "effect", sName = "RESIST: poison; ADVSAV: wisdom", nDuration = 1, sUnits = "day" },
		{ type = "heal", subtype = "temp", clauses = { { dice = { "d10", "d10" } } } },
	},
	-- 5E SAME
	["hideous laughter"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "Prone; Incapacitated; NOTE: Unable to stand up; NOTE: Save on end of round and damage; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- LEVEL UP
	["beshala’s infectious hideous laughter"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "Prone; Incapacitated; NOTE: Unable to stand up; NOTE: Save on end of round and damage; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- LEVEL UP
	["kreven’s despairing hideous laughter"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "Prone; Incapacitated; NOTE: Unable to stand up; NOTE: Save on end of round and damage; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "DISCHK; DISATK; DISSAV", sApply = "roll" },
	},
	-- 5E SAME
	["holy aura"] = {
		{ type = "effect", sName = "ADVSAV; GRANTDISATK; NOTE: Extra effect on fiend/undead melee attack; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- ["inescapable malady"] = {
	-- },
	-- ["infernal weapon"] = {
	-- },
	-- 5E SAME
	["insect plague"] = {
		{ type = "effect", sName = "Insect Plague; (C)", sTargeting = "self", nDuration = 10, sUnits = "minute" },
		{ type = "powersave", save = "constitution", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10" }, dmgtype = "piercing,magic" } } },
	},
	-- LEVEL UP
	["roav’s infernal insect plague"] = {
		{ type = "effect", sName = "Insect Plague; (C)", sTargeting = "self", nDuration = 10, sUnits = "minute" },
		{ type = "powersave", save = "constitution", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10" }, dmgtype = "piercing,magic" } } },
		{ type = "effect", sName = "Frightened; (C)" },
	},
	-- ["invigorated strikes"] = {
	-- },
	-- ["lemure transformation"] = {
	-- },
	-- 5E SAME
	["mage armor"] = {
		{ type = "effect", sName = "AC: 3", nDuration = 8, sUnits = "hour" },
	},
	-- LEVEL UP
	["stekart’s enhanced mage armor"] = {
		{ type = "effect", sName = "Stekart's Enhanced Mage Armor", nDuration = 8, sUnits = "hour" },
	},
	-- 5E SAME
	["magic circle"] = {
		{ type = "powersave", save = "charisma", magic = true, savebase = "group" },
		{ type = "effect", sName = "IFT: TYPE(aberration, celestial, elemental, fey, fiend, undead); GRANTDISATK; IMMUNE: charmed,frightened,possessed; [FIXED]", nDuration = 1, sUnits = "hour" },
	},
	-- 5E SAME
	["magic weapon"] = {
		{ type = "effect", sName = "ATK: 1; DMG: 1; DMGTYPE: magic; (C)", nDuration = 1, sUnits = "hour" },
	},
	-- ["mental grip"] = {
	-- },
	-- ["mindshield"] = {
	-- },
	-- ["pestilence"] = {
	-- },
	-- ["phantasmal talons"] = {
	-- },
	-- ["poison skin"] = {
	-- },
	-- 5E MODIFIED
	["protection from energy"] = {
		{ type = "effect", sName = "RESIST: acid; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "RESIST: cold; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "RESIST: fire; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "RESIST: lightning; (C)", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "RESIST: thunder; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- 5E SAME
	["protection from evil and good"] = {
		{ type = "effect", sName = "IFT: TYPE(aberration, celestial, elemental, fey, fiend, undead); GRANTDISATK; IMMUNE: charmed,frightened,possessed; (C)", nDuration = 10, sUnits = "minute" },
	},
	-- 5E SAME
	["protection from poison"] = {
		{ type = "effect", sName = "RESIST: poison; NOTE: Poison save advantage", nDuration = 1, sUnits = "hour" },
	},
	-- ["rage of the meek"] = {
	-- },
	-- ["raise hell"] = {
	-- },
	-- 5E SAME
	["ray of enfeeblement"] = {
		{ type = "attack", range = "R", spell = true, base = "group" },
		{ type = "effect", sName = "NOTE: Deals half damage with Strength attacks; NOTE: Save on end of round; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- 5E SAME
	["sanctuary"] = {
		{ type = "effect", sName = "NOTE: Sanctuary", nDuration = 1, sUnits = "minute" },
	},
	-- ["searing equation"] = {
	-- },
	-- ["seed bomb"] = {
	-- },
	-- ["shattering barrage"] = {
	-- },
	-- 5E SAME
	["shield"] = {
		{ type = "effect", sName = "AC: 5", sTargeting = "self", nDuration = 1 },
	},
	-- 5E SAME
	["shield of faith"] = {
		{ type = "effect", sName = "AC: 2; (C)", nDuration = 10, sUnits = "minute" },
	},
	-- LEVEL UP
	["komanov’s radiant shield"] = {
		{ type = "damage", clauses = { { dice = { "d6" }, dmgtype = "radiant" } } },
		{ type = "effect", sName = "AC: 2; (C)", nDuration = 10, sUnits = "minute" },
	},
	-- 5E MODIFIED
	["slow"] = {
		{ type = "powersave", save = "wisdom", magic = true, savebase = "group" },
		{ type = "effect", sName = "Rattled", nDuration = 1 },
		{ type = "effect", sName = "NOTE: Slowed; NOTE: Save on end of round; (C)", nDuration = 1, sUnits = "minute" },
	},
	-- ["soulwrought fists"] = {
	-- },
	-- ["sporesight"] = {
	-- },
	-- ["storm kick"] = {
	-- },
	-- 5E SAME
	["sunbeam"] = {
		{ type = "effect", sName = "Sunbeam; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
		{ type = "powersave", save = "constitution", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d8", "d8", "d8", "d8", "d8", "d8" }, dmgtype = "radiant" } } },
		{ type = "effect", sName = "Blinded", nDuration = 1 },
	},
	-- 5E MODIFIED
	["symbol"] = {
		{ type = "powersave", save = "constitution", onmissdamage = "half", magic = true, savebase = "group" },
		{ type = "damage", clauses = { { dice = { "d10", "d10", "d10", "d10", "d10", "d10", "d10", "d10", "d10", "d10" }, dmgtype = "necrotic" } } },
		{ type = "effect", sName = "NOTE: Symbol of Discord; DISATK; DISCHK", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Symbol of Confused", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Symbol of Fear; Frightened", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Symbol of Hopelessness", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Symbol of Pain; Incapacitated", nDuration = 1, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Symbol of Sleep; Unconscious", nDuration = 10, sUnits = "minute" },
		{ type = "effect", sName = "NOTE: Symbol of Stunning; Stunned", nDuration = 1, sUnits = "minute" },
	},
	-- ["tearful sonnet"] = {
	-- },
	-- ["traveler's ward"] = {
	-- },
	-- 5E SAME
	["true strike"] = {
		{ type = "effect", sName = "[TRGT]; ADVATK; (C)", sTargeting = "self", nDuration = 2, sApply = "roll" },
	},
	-- LEVEL UP
	["kasvarina’s greater true strike"] = {
		{ type = "effect", sName = "[TRGT]; ADVATK; (C)", sTargeting = "self", nDuration = 1, sUnits = "minute" },
	},
	-- ["unholy star"] = {
	-- },
	-- ["venomous succor"] = {
	-- },
	-- ["wall of flesh"] = {
	-- },
	-- 5E SAME
	["warding bond"] = {
		{ type = "effect", sName = "AC: 1; SAVE: 1; RESIST: all", nDuration = 1, sUnits = "hour" },
	},
	-- ["warrior's instincts"] = {
	-- },
	-- ["whirlwind kick"] = {
	-- },
	-- ["wind up"] = {
	-- },
	-- ["wormway"] = {
	-- },
	-- ["writhing transformation"] = {
	-- },
};