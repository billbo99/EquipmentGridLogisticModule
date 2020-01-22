-- make a separate equipment-grid for fluid wagons
if data.raw["equipment-grid"]["wagon-equipment-grid"] then
    local r = table.deepcopy(data.raw["equipment-grid"]["wagon-equipment-grid"])
    r.name = "fluid-wagon-equipment-grid"
    data:extend({r})
    for i, entity in pairs(data.raw["fluid-wagon"]) do
        if entity.equipment_grid == "wagon-equipment-grid" then
            entity.equipment_grid = "fluid-wagon-equipment-grid"
        end
    end
end

-- now for each vehicle with an inventory add the equipment category, "EquipmentGridLogisticModule"
local grids_to_update = {}

for i, entity in pairs(data.raw["car"]) do
    if entity.equipment_grid ~= nil then
        grids_to_update[entity.equipment_grid] = true
    end
end

for i, entity in pairs(data.raw["cargo-wagon"]) do
    if entity.equipment_grid ~= nil then
        grids_to_update[entity.equipment_grid] = true
    end
end

for k, v in pairs(grids_to_update) do
    table.insert(data.raw["equipment-grid"][k].equipment_categories, "EquipmentGridLogisticModule")
end
