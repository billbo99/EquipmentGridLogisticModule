-- now for each vehicle with an inventory add the equipment category, "EquipmentGridLogisticModule"
local grids_to_update = {}

for _, entity in pairs(data.raw["car"]) do
    if entity.equipment_grid ~= nil then
        grids_to_update[entity.equipment_grid] = true
    end
end

for _, entity in pairs(data.raw["cargo-wagon"]) do
    if entity.equipment_grid ~= nil then
        grids_to_update[entity.equipment_grid] = true
    end
end

for _, entity in pairs(data.raw["spider-vehicle"]) do
    if entity.equipment_grid ~= nil then
        grids_to_update[entity.equipment_grid] = true
    end
end

for k, _ in pairs(grids_to_update) do
    table.insert(data.raw["equipment-grid"][k].equipment_categories, "EquipmentGridLogisticModule")
end
