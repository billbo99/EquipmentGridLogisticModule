data:extend(
    {
        {
            type = "recipe-category",
            name = "EquipmentGridLogisticModule"
        }
    }
)

local r = table.deepcopy(data.raw["equipment-category"]["armor"])
r.name = "EquipmentGridLogisticModule"

data:extend({r})
