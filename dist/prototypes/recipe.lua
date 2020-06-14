data:extend(
    {
        {
            type = "recipe",
            name = "EquipmentGridLogisticModule",
            category = "crafting",
            subgroup = "transport",
            enabled = false,
            icon = "__EquipmentGridLogisticModule__/icon.png",
            icon_size = 32,
            hidden = false,
            energy_required = 10.0,
            ingredients = {
                {type = "item", name = "logistic-chest-requester", amount = 1},
                {type = "item", name = "logistic-chest-active-provider", amount = 1}
            },
            results = {
                {type = "item", name = "EquipmentGridLogisticModule", amount = 1}
            },
            order = "EquipmentGridLogisticModule"
        }
    }
)
