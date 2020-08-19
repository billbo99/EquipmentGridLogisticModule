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

local function checkAndFillAmmo(vehicle)
    if vehicle.valid then
        -- game.print(vehicle.type)
        if vehicle.type == "spider-vehicle" then
            trunk = vehicle.get_inventory(defines.inventory.car_trunk)
            ammo = vehicle.get_inventory(defines.inventory.car_ammo)
        end
    end
end

local function vehicleRelevant(vehicle)
    if (vehicle.type == "car" or vehicle.type == "cargo-wagon" or vehicle.type == "spider-vehicle") and vehicle.grid ~= nil then
        local contents = vehicle.grid.get_contents()
        if contents["EquipmentGridLogisticModule"] ~= nil or contents["EquipmentGridLogisticModule_buffer"] ~= nil then
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

        local contents = vehicle.grid.get_contents()
        if contents["EquipmentGridLogisticModule_buffer"] ~= nil then
            unit.request_from_buffers = true
        else
            unit.request_from_buffers = false
        end

        -- get the next scheduled execution tick
        local schedule_tick = (math.floor(game.tick / nth) * nth) + nth
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
            if vehicle.type == "spider-vehicle" then
                trunk = vehicle.get_inventory(defines.inventory.car_trunk)
            end
            if vehicle.type == "car" then
                trunk = vehicle.get_inventory(defines.inventory.car_trunk)
            end
            if vehicle.type == "cargo-wagon" then
                trunk = vehicle.get_inventory(defines.inventory.cargo_wagon)
            end

            local input = requester.get_inventory(defines.inventory.chest)
            local output = provider.get_inventory(defines.inventory.chest)

            for name, count in pairs(input.get_contents()) do
                local moved = trunk.insert({name = name, count = count})
                if moved ~= count then
                    note("need to spill onto ground")
                    unit.vehicle.surface.spill_item_stack(unit.vehicle.position, {name = name, count = count - moved}, nil, unit.vehicle.force)
                end
            end

            for name, count in pairs(output.get_contents()) do
                local moved = trunk.insert({name = name, count = count})
                if moved ~= count then
                    note("need to spill onto ground")
                    unit.vehicle.surface.spill_item_stack(unit.vehicle.position, {name = name, count = count - moved}, nil, unit.vehicle.force)
                end
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
    local speed = 0
    if vehicle.type == "spider-vehicle" then
        trunk = vehicle.get_inventory(defines.inventory.car_trunk)
        speed = 0
    end
    if vehicle.type == "car" then
        trunk = vehicle.get_inventory(defines.inventory.car_trunk)
        speed = vehicle.speed
    end
    if vehicle.type == "cargo-wagon" then
        trunk = vehicle.get_inventory(defines.inventory.cargo_wagon)
        speed = vehicle.speed
    end

    return trunk.is_filtered() and math.abs(speed) < 0.1 and vehicle.surface.find_logistic_network_by_position(vehicle.position, vehicle.force) ~= nil
end

local function vehicleProcess(vehicle)
    note("vehicleProcess " .. vehicle.unit_number)

    local unit = mod.vehicles[vehicle.unit_number]
    local requester = unit.requester
    local provider = unit.provider
    if unit.max_provider_slot_count and unit.max_provider_slot_count > 0 then
        provider.get_inventory(defines.inventory.chest).set_bar(unit.max_provider_slot_count + 1)
    elseif settings.startup["EGLM_hidden_active_provider_chest_unload_size"].value > 1 then
        local bar_size = math.min(settings.startup["EGLM_hidden_active_provider_chest_unload_size"].value, settings.startup["EGLM_hidden_active_provider_chest_size"].value)
        provider.get_inventory(defines.inventory.chest).set_bar(bar_size + 1)
    else
        provider.get_inventory(defines.inventory.chest).set_bar(2)
    end

    if unit.request_from_buffers ~= nil then
        requester.request_from_buffers = unit.request_from_buffers
    end

    local trunk = nil
    if vehicle.type == "spider-vehicle" then
        trunk = vehicle.get_inventory(defines.inventory.car_trunk)
    end
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
        local left_behind = count - moved
        if left_behind > 0 then
            local stack = {name = name, count = left_behind}
            if output.can_insert(stack) then
                output.insert(stack)
                input.remove(stack)
            end
        end
    end

    if vehicle.burner ~= nil then
        local inv = vehicle.burner.inventory
        for name, _ in pairs(inv.get_contents()) do
            if name ~= nil then
                local available = trunk.get_item_count(name)
                if available > 0 then
                    local stack = {name = name, count = available}
                    if inv.can_insert(stack) then
                        local moved = vehicle.burner.inventory.insert(stack)
                        if moved > 0 then
                            trunk.remove({name = name, count = moved})
                        end
                    end
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

    for i = 1, requester.request_slot_count, 1 do
        requester.clear_request_slot(i)
    end

    local i = 1
    for name, count in pairs(requests) do
        if i > (unit.max_requester_slot_count or 6) then
            break
        end
        if requester.logistic_network and requester.logistic_network.get_item_count(name) > 0 then
            requester.set_request_slot({name = name, count = count}, i)
            i = i + 1
        end
    end
end

-- defines.train_state.on_the_path	Normal state -- following the path.
-- defines.train_state.path_lost	Had path and lost it -- must stop.
-- defines.train_state.no_schedule	Doesn't have anywhere to go.
-- defines.train_state.no_path	Has no path and is stopped.
-- defines.train_state.arrive_signal	Braking before a rail signal.
-- defines.train_state.wait_signal	Waiting at a signal.
-- defines.train_state.arrive_station	Braking before a station.
-- defines.train_state.wait_station	Waiting at a station.
-- defines.train_state.manual_control_stop	Switched to manual control and has to stop.
-- defines.train_state.manual_control	Can move if user explicitly sits in and rides the train.

local function OnTrainChangedState(event)
    local train = event.train
    local old_state = event.old_state
    local early_exit = true

    -- only care has stopped at a station or has left a station
    if train.state == defines.train_state.wait_station or old_state == defines.train_state.wait_station then
        for _, wagon in pairs(train.cargo_wagons) do
            local id = wagon.unit_number
            if mod.vehicles[id] then
                early_exit = false
            end
        end
    end

    -- only care about trains with cargo wagons that are being tracked.
    if early_exit then
        return
    end

    if train.state == defines.train_state.wait_station then
        if train.station and train.station.get_merged_signals() then
            for _, item in pairs(train.station.get_merged_signals()) do
                if item.signal and item.signal.type == "virtual" then
                    if item.signal.name == "logistics-active-provider" and item.count > 0 then
                        for _, wagon in pairs(train.cargo_wagons) do
                            local id = wagon.unit_number
                            if mod.vehicles[id] then
                                mod.vehicles[id].max_provider_slot_count = min(item.count, 48)
                            end
                        end
                    end
                    if item.signal.name == "logistics-requester" and item.count > 0 then
                        for _, wagon in pairs(train.cargo_wagons) do
                            local id = wagon.unit_number
                            if mod.vehicles[id] then
                                mod.vehicles[id].max_requester_slot_count = min(item.count, 48)
                            end
                        end
                    end
                    if item.signal.name == "logistics-request-from-buffer" then
                        for _, wagon in pairs(train.cargo_wagons) do
                            local id = wagon.unit_number
                            if mod.vehicles[id] then
                                mod.vehicles[id].request_from_buffers = true
                            end
                        end
                    end
                end
            end
        end
    end
    if old_state == defines.train_state.wait_station then
        for _, wagon in pairs(train.cargo_wagons) do
            local id = wagon.unit_number
            if mod.vehicles[id] then
                mod.vehicles[id].request_from_buffers = false
                mod.vehicles[id].max_provider_slot_count = nil
                mod.vehicles[id].max_requester_slot_count = nil
            end
        end
    end
end

local function OnEntityCreated(event)
    InitState()
    local entity = event.created_entity

    if entity.valid and (entity.type == "car" or entity.type == "cargo-wagon" or entity.type == "spider-vehicle") then
        vehicleRegister(entity)
    end
end

local function OnEntityRemoved(event)
    InitState()
    local entity = event.entity

    if entity.valid and (entity.type == "car" or entity.type == "cargo-wagon" or entity.type == "spider-vehicle") then
        vehicleUnregister(entity)
    end
end

local function vehicleFromGrid(grid)
    for _, surface in pairs(game.surfaces) do
        local vehicles = surface.find_entities_filtered({type = {"car", "cargo-wagon", "spider-vehicle"}})
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
    if equipment.name == "EquipmentGridLogisticModule" or equipment.name == "EquipmentGridLogisticModule_buffer" then
        local vehicle = vehicleFromGrid(event.grid)
        if vehicle ~= nil then
            vehicleRegister(vehicle)
        end
    end
end

local function OnRemovedEquipment(event)
    local equipment = event.equipment
    if equipment.name == "EquipmentGridLogisticModule" or equipment.name == "EquipmentGridLogisticModule_buffer" then
        local vehicle = vehicleFromGrid(event.grid)
        if vehicle ~= nil then
            vehicleUnregister(vehicle)
        end
    end
end

local function OnEntityCloned(event)
    local src = event.source
    local dst = event.destination

    InitState()
    if dst.valid and (dst.type == "car" or dst.type == "cargo-wagon" or dst.type == "spider-vehicle") then
        vehicleRegister(dst)
    end
end

local function OnNthTick(event)
    InitState()
    -- if there is no queued event for this tick then there is nothing todo
    local queue = {}
    for schedule_tick, work in pairs(mod.queues) do
        if schedule_tick <= event.tick then
            for _, job in pairs(work) do
                table.insert(queue, job)
            end
            mod.queues[schedule_tick] = nil
        end
    end

    if #queue == 0 then
        return
    end

    for _, vehicle in ipairs(queue) do
        if vehicle.valid and mod.vehicles[vehicle.unit_number] ~= nil then
            local unit = mod.vehicles[vehicle.unit_number]

            checkAndFillAmmo(vehicle)

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
    script.on_event({defines.events.on_train_changed_state}, OnTrainChangedState)
    script.on_event({defines.events.on_entity_cloned}, OnEntityCloned)
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

script.on_event(
    "battery-rotate",
    function(e)
        local module_table = {
            ["EquipmentGridLogisticModule"] = "EquipmentGridLogisticModule_buffer",
            ["EquipmentGridLogisticModule_buffer"] = "EquipmentGridLogisticModule"
        }
        local player = game.players[e.player_index]
        if player.cursor_stack and player.cursor_stack.valid_for_read and module_table[player.cursor_stack.name] then
            player.cursor_stack.set_stack {
                name = module_table[player.cursor_stack.name],
                count = player.cursor_stack.count
            }
        end
    end
)

remote.add_interface(
    "EquipmentGridLogisticModule",
    {
        on_entity_deployed = function(e)
            local entity = e.entity
            InitState()
            if entity.valid and (entity.type == "car" or entity.type == "cargo-wagon" or entity.type == "spider-vehicle") then
                vehicleRegister(entity)
            end
        end
    }
)
