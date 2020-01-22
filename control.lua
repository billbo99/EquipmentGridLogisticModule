local mod = nil
local debug = false
local nth = 20

local max = math.max
local min = math.min

local function InitState()
    mod = global
    mod.vehicles = mod.vehicles or {}
    mod.queues = mod.queues or {}
end

local function serialize(t)
    local s = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            v = serialize(v)
        end
        s[#s + 1] = tostring(k) .. " = " .. tostring(v)
    end
    return "{ " .. table.concat(s, ", ") .. " }"
end

local function note(msg)
    if debug then
        if type(msg) == "table" then
            game.print(serialize(msg))
        else
            game.print(msg)
        end
    end
end

local function vehicleQueue(vehicle, schedule_tick)
    local unit = mod.vehicles[vehicle.unit_number]

    if unit ~= nil and unit.queue == nil then
        local queues = mod.queues
        local queue = queues[schedule_tick]
        if queue == nil then
            queue = {}
            queues[schedule_tick] = queue
        end
        queue[#queue + 1] = vehicle
        unit.queue = schedule_tick
    end
end

local function vehicleRelevant(vehicle)
    if (vehicle.type == "car" or vehicle.type == "cargo-wagon") and vehicle.grid ~= nil then
        local contents = vehicle.grid.get_contents()
        if contents["EquipmentGridLogisticModule"] ~= nil then
            return true
        end
    end
    return false
end

local function vehicleRegister(vehicle)
    if vehicleRelevant(vehicle) then
        note("vehicleRegister " .. vehicle.unit_number)

        local unit = mod.vehicles[vehicle.unit_number] or {vehicle = vehicle}
        mod.vehicles[vehicle.unit_number] = unit

        -- get the next scheduled execution tick
        schedule_tick = (math.floor(game.tick / nth) * nth) + nth
        vehicleQueue(vehicle, schedule_tick)
    end
end

local function vehiclePackup(vehicle)
    local unit = mod.vehicles[vehicle.unit_number]
    if unit ~= nil then
        local requester = unit.requester
        local provider = unit.provider
        if requester ~= nil then
            local trunk = nil
            if vehicle.type == "car" then
                trunk = vehicle.get_inventory(defines.inventory.car_trunk)
            end
            if vehicle.type == "cargo-wagon" then
                trunk = vehicle.get_inventory(defines.inventory.cargo_wagon)
            end

            local input = requester.get_inventory(defines.inventory.chest)
            local output = provider.get_inventory(defines.inventory.chest)

            for name, count in pairs(input.get_contents()) do
                trunk.insert({name = name, count = count})
            end

            for name, count in pairs(output.get_contents()) do
                trunk.insert({name = name, count = count})
            end

            requester.destroy()
            provider.destroy()

            unit.requester = nil
            unit.provider = nil
            note("vehiclePackup " .. vehicle.unit_number)
        end
    end
end

local function vehicleUnregister(vehicle)
    note("vehicleUnregister " .. vehicle.unit_number)
    vehiclePackup(vehicle)
    mod.vehicles[vehicle.unit_number] = nil
end

local function vehicleUnpack(vehicle)
    local unit = mod.vehicles[vehicle.unit_number]
    if unit ~= nil then
        local position = {x = vehicle.position.x - 0.1, y = vehicle.position.y - 0.1}
        if unit.requester == nil then
            unit.requester =
                vehicle.surface.create_entity(
                {
                    name = "EquipmentGridLogisticModule-requester",
                    position = position,
                    force = vehicle.force
                }
            )
            unit.provider =
                vehicle.surface.create_entity(
                {
                    name = "EquipmentGridLogisticModule-provider",
                    position = position,
                    force = vehicle.force
                }
            )
            note("vehicleUnpack " .. vehicle.unit_number)
        else
            unit.requester.teleport(position)
            unit.provider.teleport(position)
        end
    end
end

local function vehicleReady(vehicle)
    local trunk = nil
    if vehicle.type == "car" then
        trunk = vehicle.get_inventory(defines.inventory.car_trunk)
    end
    if vehicle.type == "cargo-wagon" then
        trunk = vehicle.get_inventory(defines.inventory.cargo_wagon)
    end

    return trunk.is_filtered() and math.abs(vehicle.speed) < 0.1 and vehicle.surface.find_logistic_network_by_position(vehicle.position, vehicle.force) ~= nil
end

local function vehicleProcess(vehicle)
    note("vehicleProcess " .. vehicle.unit_number)

    local unit = mod.vehicles[vehicle.unit_number]
    local requester = unit.requester
    local provider = unit.provider

    local trunk = nil
    if vehicle.type == "car" then
        trunk = vehicle.get_inventory(defines.inventory.car_trunk)
    end
    if vehicle.type == "cargo-wagon" then
        trunk = vehicle.get_inventory(defines.inventory.cargo_wagon)
    end

    local input = requester.get_inventory(defines.inventory.chest)
    local output = provider.get_inventory(defines.inventory.chest)

    local requests = {}

    for name, count in pairs(input.get_contents()) do
        local moved = trunk.insert({name = name, count = count})
        if moved > 0 then
            input.remove({name = name, count = moved})
        end
    end

    if vehicle.burner ~= nil then
        local item = vehicle.burner.currently_burning
        if item ~= nil then
            local available = trunk.get_item_count(item.name)
            if available > 0 then
                local moved = vehicle.burner.inventory.insert({name = item.name, count = available})
                if moved > 0 then
                    trunk.remove({name = item.name, count = moved})
                end
            end
        end
    end

    for i = 1, #trunk, 1 do
        local filter = trunk.get_filter(i)
        if filter ~= nil then
            local stack = trunk[i]
            local count = (stack ~= nil and stack.valid_for_read and stack.count) or 0
            local shortfall = max(0, game.item_prototypes[filter].stack_size - count)
            if shortfall > 0 then
                requests[filter] = (requests[filter] or 0) + shortfall
            end
        else
            local stack = trunk[i]
            local count = (stack ~= nil and stack.valid_for_read and stack.count) or 0
            if stack ~= nil and stack.valid_for_read then
                note(i .. " can_insert .. " .. stack.name)
                note(#output)
                note(output.can_insert(stack))
            end
            if count > 0 and stack.valid then
                local moved = output.insert({name = stack.name, count = count})
                note(i .. " " .. stack.name .. " moved " .. moved)
                if moved > 0 then
                    stack.count = stack.count - moved
                end
            end
        end
    end

    for i = 1, 6, 1 do
        requester.clear_request_slot(i)
    end

    local i = 1
    for name, count in pairs(requests) do
        if i > 6 then
            break
        end
        requester.set_request_slot({name = name, count = count}, i)
        i = i + 1
    end
end

local function OnEntityCreated(event)
    InitState()
    local entity = event.created_entity

    if entity.valid and (entity.type == "car" or entity.type == "cargo-wagon") then
        vehicleRegister(entity)
    end
end

local function OnEntityRemoved(event)
    InitState()
    local entity = event.entity

    if entity.valid and (entity.type == "car" or entity.type == "cargo-wagon") then
        vehicleUnregister(entity)
    end
end

local function vehicleFromGrid(grid)
    for _, surface in pairs(game.surfaces) do
        local vehicles = surface.find_entities_filtered({type = {"car", "cargo-wagon"}})
        for _, vehicle in ipairs(vehicles) do
            if vehicle.grid == grid then
                return vehicle
            end
        end
    end
    return nil
end

local function OnPlacedEquipment(event)
    local equipment = event.equipment
    if equipment.name == "EquipmentGridLogisticModule" then
        local vehicle = vehicleFromGrid(event.grid)
        if vehicle ~= nil then
            vehicleRegister(vehicle)
        end
    end
end

local function OnRemovedEquipment(event)
    local equipment = event.equipment
    if equipment == "EquipmentGridLogisticModule" then
        local vehicle = vehicleFromGrid(event.grid)
        if vehicle ~= nil then
            vehicleUnregister(vehicle)
        end
    end
end

local function OnNthTick(event)
    InitState()
    -- if there is no queued event for this tick then there is nothing todo
    local queue = mod.queues ~= nil and mod.queues[game.tick]
    if queue == nil then
        return
    end

    mod.queues[game.tick] = nil

    for _, vehicle in ipairs(queue) do
        if vehicle.valid and mod.vehicles[vehicle.unit_number] ~= nil then
            local unit = mod.vehicles[vehicle.unit_number]

            if vehicleReady(vehicle) then
                note(vehicle.unit_number .. " ready")
                vehicleUnpack(vehicle)
                vehicleProcess(vehicle)
            else
                note(vehicle.unit_number .. " not ready")
                vehiclePackup(vehicle)
            end

            unit.queue = nil
            local schedule_tick = (math.floor(game.tick / nth) * nth) + (nth * 3)
            vehicleQueue(vehicle, schedule_tick)
        end
    end
end

local function attach_events()
    script.on_nth_tick(nth, OnNthTick)
    script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, OnEntityCreated)
    script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}, OnEntityRemoved)
    script.on_event({defines.events.on_player_placed_equipment}, OnPlacedEquipment)
    script.on_event({defines.events.on_player_removed_equipment}, OnRemovedEquipment)
end

script.on_init(
    function()
        InitState()
        attach_events()
    end
)

script.on_load(
    function()
        InitState()
        attach_events()
    end
)
