local base = "__base__/graphics/icons/"
local mod = "__EquipmentGridLogisticModule__/graphics/icons/"

data:extend(
    {
        {
            type = "item-subgroup",
            name = "EquipmentGridLogisticModule",
            group = "signals",
            order = "EquipmentGridLogisticModule"
        }
    }
)

data:extend(
    {
        {
            type = "virtual-signal",
            name = "logistics-requester",
            icons = {
                {icon = base .. "cargo-wagon.png", icon_size = 64, icon_mipmaps = 4},
                {icon = base .. "logistic-chest-requester.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, -8}}
            },
            subgroup = "EquipmentGridLogisticModule",
            order = "logistics-requester"
        },
        -- {
        --     type = "virtual-signal",
        --     name = "logistics-passive-provider",
        --     icons = {
        --         {icon = base .. "cargo-wagon.png", icon_size = 64, icon_mipmaps = 4},
        --         {icon = base .. "logistic-chest-passive-provider.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, -8}}
        --     },
        --     subgroup = "EquipmentGridLogisticModule",
        --     order = "logistics-passive-provider"
        -- },
        {
            type = "virtual-signal",
            name = "logistics-active-provider",
            icons = {
                {icon = base .. "cargo-wagon.png", icon_size = 64, icon_mipmaps = 4},
                {icon = base .. "logistic-chest-active-provider.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, -8}}
            },
            subgroup = "EquipmentGridLogisticModule",
            order = "logistics-active-provider"
        },
        -- {
        --     type = "virtual-signal",
        --     name = "logistics-buffer",
        --     icons = {
        --         {icon = base .. "cargo-wagon.png", icon_size = 64, icon_mipmaps = 4},
        --         {icon = base .. "logistic-chest-buffer.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, -8}}
        --     },
        --     subgroup = "EquipmentGridLogisticModule",
        --     order = "logistics-buffer"
        -- },
        -- {
        --     type = "virtual-signal",
        --     name = "logistics-storage",
        --     icons = {
        --         {icon = base .. "cargo-wagon.png", icon_size = 64, icon_mipmaps = 4},
        --         {icon = base .. "logistic-chest-storage.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, -8}}
        --     },
        --     subgroup = "EquipmentGridLogisticModule",
        --     order = "logistics-storage"
        -- },
        {
            type = "virtual-signal",
            name = "logistics-request-from-buffer",
            icons = {
                {icon = mod .. "blank32.png", icon_size = 32},
                {icon = base .. "logistic-chest-buffer.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {-8, -8}},
                {icon = base .. "logistic-chest-requester.png", icon_size = 64, icon_mipmaps = 4, scale = 0.25, shift = {8, 8}},
                {icon = mod .. "red_bottom_right.png", icon_size = 32}
            },
            subgroup = "EquipmentGridLogisticModule",
            order = "logistics-storage"
        }
    }
)
