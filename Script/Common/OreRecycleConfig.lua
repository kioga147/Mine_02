--- 矿石回收处配置（对齐策划「四、矿石价格表」）
--- 初始自动解锁；鉴定后的玉石(8310018)走鉴定所出售，不在此回收。
local OreRecycleConfig = {
    GoldItemId = 8310002,
    --- 数量预设：-1 表示全部出售该矿
    CountPresets = { 1, 5, 10, 25, 50, -1 },
    Prices = {
        [8310000] = { Name = "石头", Price = 50 },
        [8310003] = { Name = "煤矿", Price = 75 },
        [8310004] = { Name = "粗铁矿", Price = 100 },
        [8310005] = { Name = "粗铜矿", Price = 85 },
        [8310006] = { Name = "石英矿", Price = 120 },
        [8310007] = { Name = "粗金矿", Price = 250 },
        [8310008] = { Name = "铝土矿", Price = 180 },
        [8310009] = { Name = "钻石矿", Price = 800 },
        [8310010] = { Name = "红宝石矿", Price = 500 },
        [8310011] = { Name = "玉矿石（未鉴定）", Price = 600 },
        [8310012] = { Name = "精炼铁矿", Price = 200 },
        [8310013] = { Name = "精炼铜矿", Price = 170 },
        [8310014] = { Name = "精炼金矿", Price = 500 },
        [8310015] = { Name = "精炼铝矿", Price = 360 },
        [8310016] = { Name = "精加工钻石", Price = 1600 },
        [8310017] = { Name = "精加工红宝石", Price = 1000 },
    },
    ItemOrder = {
        8310000, 8310003, 8310004, 8310005, 8310006, 8310007, 8310008, 8310009,
        8310010, 8310011, 8310012, 8310013, 8310014, 8310015, 8310016, 8310017,
    },
}

function OreRecycleConfig.GetEntry(ItemId)
    return OreRecycleConfig.Prices[tonumber(ItemId) or -1]
end

function OreRecycleConfig.GetPrice(ItemId)
    local Entry = OreRecycleConfig.GetEntry(ItemId)
    return Entry and Entry.Price or nil
end

function OreRecycleConfig.GetName(ItemId)
    local Entry = OreRecycleConfig.GetEntry(ItemId)
    return Entry and Entry.Name or "?"
end

function OreRecycleConfig.IsRecyclable(ItemId)
    return OreRecycleConfig.GetEntry(ItemId) ~= nil
end

function OreRecycleConfig.NextItemId(CurrentId)
    local Order = OreRecycleConfig.ItemOrder
    local Start = 1
    local Cur = tonumber(CurrentId) or 0
    for i, Id in ipairs(Order) do
        if Id == Cur then
            Start = i + 1
            break
        end
    end
    local N = #Order
    local Idx = ((Start - 1) % N) + 1
    return Order[Idx]
end

function OreRecycleConfig.NextCount(Current)
    local Presets = OreRecycleConfig.CountPresets
    local Cur = math.floor(tonumber(Current) or 1)
    for i, V in ipairs(Presets) do
        if V == Cur then
            return Presets[(i % #Presets) + 1]
        end
    end
    return Presets[1]
end

function OreRecycleConfig.ResolveSellCount(Owned, Requested)
    Owned = math.floor(tonumber(Owned) or 0)
    Requested = math.floor(tonumber(Requested) or 0)
    if Owned <= 0 then
        return 0
    end
    if Requested < 0 then
        return Owned
    end
    if Requested <= 0 then
        return 0
    end
    if Requested > Owned then
        return 0
    end
    return Requested
end

return OreRecycleConfig
