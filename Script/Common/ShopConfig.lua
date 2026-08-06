-- 矿工百货商店配置
local ShopConfig = {
    GoldItemId = 8310002,

    -- ========== 工具升级表 ==========
    Tools = {
        [1]  = { ItemId = 8310026, Name = "铜镐",         Range = 1,  Damage = 1,   MineLevel = 1, Cost = 0 },
        [2]  = { ItemId = 8310030, Name = "铁镐",         Range = 1,  Damage = 2,   MineLevel = 2, Cost = 1000 },
        [3]  = { ItemId = 8310027, Name = "铜钻头",       Range = 3,  Damage = 1,   MineLevel = 1, Cost = 2000 },
        [4]  = { ItemId = 8310019, Name = "铁钻头",       Range = 5,  Damage = 2,   MineLevel = 2, Cost = 4000 },
        [5]  = { ItemId = 8310028, Name = "合金镐",       Range = 1,  Damage = 4,   MineLevel = 3, Cost = 6000 },
        [6]  = { ItemId = 8310029, Name = "合金钻头",     Range = 5,  Damage = 4,   MineLevel = 3, Cost = 20000 },
        [7]  = { ItemId = 8310022, Name = "钻石镐",       Range = 1,  Damage = 50,  MineLevel = 4, Cost = 15000 },
        [8]  = { ItemId = 8310001, Name = "钻石钻头",     Range = 7,  Damage = 50,  MineLevel = 4, Cost = 60000 },
        [9]  = { ItemId = 8310020, Name = "强化钻石镐",   Range = 1,  Damage = 100, MineLevel = 5, Cost = 30000 },
        [10] = { ItemId = 8310021, Name = "强化钻石钻头", Range = 9,  Damage = 100, MineLevel = 5, Cost = 100000 },
        [11] = { ItemId = 8310025, Name = "初级采矿车",   Range = "3x3", Damage = 100, MineLevel = 2, Cost = 25000 },
        [12] = { ItemId = 8310024, Name = "中级采矿车",   Range = "5x5", Damage = 100, MineLevel = 4, Cost = 150000 },
        [13] = { ItemId = 8310023, Name = "高级采矿车",   Range = "7x7", Damage = 100, MineLevel = 5, Cost = 300000 },
    },

    -- ========== 背包升级表 ==========
    BackpackLevels = {
        [1]  = { Slots = 10,  Cost = 0 },
        [2]  = { Slots = 15,  Cost = 1500 },
        [3]  = { Slots = 20,  Cost = 4000 },
        [4]  = { Slots = 40,  Cost = 10000 },
        [5]  = { Slots = 60,  Cost = 20000 },
        [6]  = { Slots = 80,  Cost = 50000 },
        [7]  = { Slots = 100, Cost = 100000 },
        [8]  = { Slots = 140, Cost = 200000 },
        [9]  = { Slots = 180, Cost = 400000 },
        [10] = { Slots = 240, Cost = 1000000 },
    },
}

-- ========== 工具辅助函数 ==========

function ShopConfig.GetTool(index)
    return ShopConfig.Tools[tonumber(index) or 0]
end

function ShopConfig.GetToolCount()
    return #ShopConfig.Tools
end

-- 切换下一种工具
function ShopConfig.NextToolIndex(current)
    local n = ShopConfig.GetToolCount()
    local cur = tonumber(current) or 0
    local next = cur + 1
    if next > n then next = 1 end
    return next
end

-- 切换上一种工具
function ShopConfig.PrevToolIndex(current)
    local n = ShopConfig.GetToolCount()
    local cur = tonumber(current) or 0
    local prev = cur - 1
    if prev < 1 then prev = n end
    return prev
end

-- ========== 背包辅助函数 ==========

function ShopConfig.GetBackpackLevel(level)
    return ShopConfig.BackpackLevels[tonumber(level) or 0]
end

function ShopConfig.GetMaxBackpackLevel()
    return #ShopConfig.BackpackLevels
end

return ShopConfig
