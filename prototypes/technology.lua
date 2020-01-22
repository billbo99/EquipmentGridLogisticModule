data:extend(
    {
        {
            type = "technology",
            name = "EquipmentGridLogisticModule",
            icon = "__EquipmentGridLogisticModule__/icon.png",
            icon_size = 32,
            effects = {
                {type = "unlock-recipe", recipe = "EquipmentGridLogisticModule"}
            },
            prerequisites = {
                "automobilism",
                "logistic-system"
            },
            unit = {
                count = 150,
                ingredients = {
                    {"automation-science-pack", 1},
                    {"logistic-science-pack", 1},
                    {"chemical-science-pack", 1}
                },
                time = 30
            },
            order = "EquipmentGridLogisticModule"
        }
    }
)
