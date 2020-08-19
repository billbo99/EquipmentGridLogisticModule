battitem = table.deepcopy(data.raw["item"]["battery-equipment"])
battequip = table.deepcopy(data.raw["battery-equipment"]["battery-equipment"])

log("a")

data:extend(
    {
        {
            type = "item",
            name = "EquipmentGridLogisticModule",
            icon = "__EquipmentGridLogisticModule__/graphics/icons/requester-active-provider.png",
            icon_size = 64,
            order = "EquipmentGridLogisticModule",
            stack_size = 1,
            stackable = false,
            placed_as_equipment_result = "EquipmentGridLogisticModule"
        },
        {
            type = "item",
            name = "EquipmentGridLogisticModule_buffer",
            icon = "__EquipmentGridLogisticModule__/graphics/icons/buffer-active-provider.png",
            icon_size = 64,
            order = "EquipmentGridLogisticModule",
            stack_size = 1,
            stackable = false,
            placed_as_equipment_result = "EquipmentGridLogisticModule_buffer",
            flags = {"hidden"}
        },
        {
            type = "item",
            name = "EquipmentGridLogisticModule-requester",
            icon = "__EquipmentGridLogisticModule__/graphics/icons/requester-active-provider.png",
            icon_size = 64,
            flags = {"hidden"},
            order = "EquipmentGridLogisticModule",
            stack_size = 10
        },
        {
            type = "item",
            name = "EquipmentGridLogisticModule-provider",
            icon = "__EquipmentGridLogisticModule__/graphics/icons/requester-active-provider.png",
            icon_size = 64,
            flags = {"hidden"},
            order = "EquipmentGridLogisticModule",
            stack_size = 10
        },
        {
            type = "battery-equipment",
            name = "EquipmentGridLogisticModule",
            sprite = {
                filename = "__EquipmentGridLogisticModule__/graphics/icons/requester-active-provider.png",
                width = 64,
                height = 64,
                priority = "medium"
            },
            energy_source = {
                buffer_capacity = "0J",
                input_flow_limit = "0W",
                output_flow_limit = "0W",
                type = "electric",
                usage_priority = "secondary-input"
            },
            shape = {
                type = "full",
                height = 1,
                width = 1
            },
            categories = {
                "EquipmentGridLogisticModule"
            }
        },
        {
            type = "battery-equipment",
            name = "EquipmentGridLogisticModule_buffer",
            sprite = {
                filename = "__EquipmentGridLogisticModule__/graphics/icons/buffer-active-provider.png",
                width = 64,
                height = 64,
                priority = "medium"
            },
            energy_source = {
                buffer_capacity = "0J",
                input_flow_limit = "0W",
                output_flow_limit = "0W",
                type = "electric",
                usage_priority = "secondary-input"
            },
            shape = {
                type = "full",
                height = 1,
                width = 1
            },
            categories = {
                "EquipmentGridLogisticModule"
            }
        }
    }
)
