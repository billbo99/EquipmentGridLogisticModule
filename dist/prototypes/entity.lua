local r = table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
r.name = "EquipmentGridLogisticModule-requester"
r.place_result = "EquipmentGridLogisticModule-requester"
r.collision_mask = {}
r.minable = nil
r.flags = {
    "hidden",
    "hide-alt-info",
    "not-selectable-in-game",
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
r.bounding_box = {{0, 0}, {0, 0}}
r.selection_box = {{0, 0}, {0, 0}}
r.selectable_in_game = false
local min_size = math.min(settings.startup["EGLM_hidden_requester_logistics_request_size"].value, settings.startup["EGLM_hidden_requester_chest_size"].value)
r.logistic_slots_count = min_size -- made bigger to handle large cargo vehicles like cargo airplane
r.inventory_size = settings.startup["EGLM_hidden_requester_chest_size"].value -- made bigger to handle large cargo vehicles like cargo airplane

data:extend({r})

local p = table.deepcopy(data.raw["logistic-container"]["logistic-chest-active-provider"])
p.name = "EquipmentGridLogisticModule-provider"
p.place_result = "EquipmentGridLogisticModule-provider"
p.bounding_box = {{0, 0}, {0, 0}}
p.selection_box = {{0, 0}, {0, 0}}
p.collision_mask = {}
p.minable = nil
p.flags = {
    "hidden",
    "hide-alt-info",
    "not-selectable-in-game",
    "player-creation",
    "not-rotatable",
    "not-repairable",
    "not-on-map",
    "not-deconstructable",
    "not-blueprintable",
    "not-flammable"
}
p.animation = {
    layers = {
        {
            filename = "__EquipmentGridLogisticModule__/nothing.png",
            width = 32,
            height = 32
        }
    }
}
p.selectable_in_game = false
p.inventory_size = settings.startup["EGLM_hidden_active_provider_chest_size"].value

data:extend({p})
