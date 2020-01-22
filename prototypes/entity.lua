local r = table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
r.name = "EquipmentGridLogisticModule-requester"
r.place_result = "EquipmentGridLogisticModule-requester"
r.collision_mask = {}
r.minable = nil
r.flags = {
    "player-creation",
    "not-rotatable",
    "not-repairable",
    "not-on-map",
    "not-deconstructable",
    "not-blueprintable",
    "not-flammable"
}
r.animation = {
    layers = {
        {
            filename = "__EquipmentGridLogisticModule__/nothing.png",
            width = 32,
            height = 32
        }
    }
}
r.selectable_in_game = false
r.logistic_slots_count = 6 -- made bigger to handle large cargo vehicles like cargo airplane
r.inventory_size = 6 -- made bigger to handle large cargo vehicles like cargo airplane

data:extend({r})

local r = table.deepcopy(data.raw["logistic-container"]["logistic-chest-active-provider"])
r.name = "EquipmentGridLogisticModule-provider"
r.place_result = "EquipmentGridLogisticModule-provider"
r.collision_mask = {}
r.minable = nil
r.flags = {
    "player-creation",
    "not-rotatable",
    "not-repairable",
    "not-on-map",
    "not-deconstructable",
    "not-blueprintable",
    "not-flammable"
}
r.animation = {
    layers = {
        {
            filename = "__EquipmentGridLogisticModule__/nothing.png",
            width = 32,
            height = 32
        }
    }
}
r.selectable_in_game = false
r.inventory_size = 1 -- only manage one stack at a time

data:extend({r})
