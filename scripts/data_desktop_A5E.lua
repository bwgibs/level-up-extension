--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	ModifierManager.addModWindowPresets(_tModifierWindowPresets);
	ModifierManager.addKeyExclusionSets(_tModifierExclusionSets);

	for k,v in pairs(_tDataModuleSets) do
		for _,v2 in ipairs(v) do
			Desktop.addDataModuleSet(k, v2);
		end
	end
end

-- Shown in Modifiers window
-- NOTE: Set strings for "modifier_category_*" and "modifier_label_*"
_tModifierWindowPresets =
{
	{
		sCategory = "expertise",
		tPresets = {
			"EXP_D4",
			"EXP_D6",
			"EXP_D8",
			"EXP_D10",
			"EXP_D12",
		}
	},
};
_tModifierExclusionSets =
{
	{ "EXP_D4", "EXP_D6", "EXP_D8", "EXP_D10", "EXP_D12" },
};

-- Shown in Campaign Setup window
_tDataModuleSets =
{
	["client"] =
	{
		{
			name = "Level Up - Core Rules",
			modules =
			{
				{ name = "Level Up Advanced 5e Adventurer's Guide", storeid = "ENP5ELUA5EAG", displayname = "Adventurer's Guide" },
			},
		},
		{
			name = "Level Up - All Rules",
			modules =
			{
				{ name = "Level Up Advanced 5e Adventurer's Guide", storeid = "ENP5ELUA5EAG", displayname = "Adventurer's Guide" },
			},
		},
	},
	["host"] =
	{
		{
			name = "Level Up - Core Rules",
			modules =
			{
				{ name = "Level Up Advanced 5e Adventurer's Guide", storeid = "ENP5ELUA5EAG", displayname = "Adventurer's Guide" },
				{ name = "Level Up 5e Monstrous Menagerie", storeid = "ENP5ELUA5EMM", displayname = "Monstrous Menagerie" },
				{ name = "Level Up Advanced 5E Trials and Treasures", storeid = "ENP5ELUA5ETT", displayname = "Trials and Treasures" },

			},
		},
		{
			name = "Level Up - All Rules",
			modules =
			{
				{ name = "Level Up Advanced 5e Adventurer's Guide", storeid = "ENP5ELUA5EAG", displayname = "Adventurer's Guide" },
				{ name = "Level Up 5e Monstrous Menagerie", storeid = "ENP5ELUA5EMM", displayname = "Monstrous Menagerie" },
				{ name = "Level Up Advanced 5E Trials and Treasures", storeid = "ENP5ELUA5ETT", displayname = "Trials and Treasures" },
			},
		},
	},
};
