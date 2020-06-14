data:extend(
    {
        {
            type = "item",
            name = "EquipmentGridLogisticModule",
            icon = "__EquipmentGridLogisticModule__/icon.png",
            icon_size = 32,
            order = "EquipmentGridLogisticModule",
            stack_size = 10,
            placed_as_equipment_result = "EquipmentGridLogisticModule"
        },
        {
            type = "item",
            name = "EquipmentGridLogisticModule-requester",
            icon = "__EquipmentGridLogisticModule__/icon.png",
            icon_size = 32,
            flags = {"hidden"},
            order = "EquipmentGridLogisticModule",
            stack_size = 10
        },
        {
            type = "item",
            name = "EquipmentGridLogisticModule-provider",
            icon = "__EquipmentGridLogisticModule__/icon.png",
            icon_size = 32,
            flags = {"hidden"},
            order = "EquipmentGridLogisticModule",
            stack_size = 10
        },
        {
            type = "battery-equipment",
            name = "EquipmentGridLogisticModule",
            sprite = {
                filename = "__EquipmentGridLogisticModule__/icon.png",
                width = 32,
                height = 32,
                priority = "medium"
            },
            energy_source = {
                buffer_capacity = "1J",
                input_flow_limit = "1W",
                output_flow_limit = "1W",
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
