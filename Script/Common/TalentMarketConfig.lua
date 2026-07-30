--- 人才市场配置（对齐策划「七、设施升级 / 人才市场」）
--- 雇佣完成后产出随机矿物；当前结算发入 V2 背包，后续可再接严格入仓库流程。
local TalentMarketConfig = {
    UnlockCost = 5000,
    GoldItemId = 8310002,
    WorkerOrder = { 1, 2, 3 },
    Workers = {
        [1] = {
            Name = "低级工人",
            HireCost = 1000,
            DurationSec = 1800,
            RewardCount = 50,
            MinMineLevel = 1,
            MaxMineLevel = 3,
        },
        [2] = {
            Name = "中级工人",
            HireCost = 10000,
            DurationSec = 1800,
            RewardCount = 100,
            MinMineLevel = 1,
            MaxMineLevel = 4,
        },
        [3] = {
            Name = "高级矿工",
            HireCost = 100000,
            DurationSec = 900,
            RewardCount = 200,
            MinMineLevel = 3,
            MaxMineLevel = 5,
        },
    },
    OrePool = {
        { ItemId = 8310000, Name = "石头", MineLevel = 1 },
        { ItemId = 8310003, Name = "煤矿", MineLevel = 1 },
        { ItemId = 8310004, Name = "粗铁矿", MineLevel = 2 },
        { ItemId = 8310005, Name = "粗铜矿", MineLevel = 2 },
        { ItemId = 8310006, Name = "石英矿", MineLevel = 2 },
        { ItemId = 8310007, Name = "粗金矿", MineLevel = 3 },
        { ItemId = 8310008, Name = "铝土矿", MineLevel = 3 },
        { ItemId = 8310009, Name = "钻石矿", MineLevel = 4 },
        { ItemId = 8310010, Name = "红宝石矿", MineLevel = 4 },
        { ItemId = 8310011, Name = "玉矿石", MineLevel = 5 },
    },
}

function TalentMarketConfig.GetWorker(WorkerId)
    return TalentMarketConfig.Workers[math.floor(tonumber(WorkerId) or 0)]
end

function TalentMarketConfig.GetFirstWorkerId()
    return TalentMarketConfig.WorkerOrder[1] or 1
end

function TalentMarketConfig.NextWorkerId(CurrentId)
    local Order = TalentMarketConfig.WorkerOrder
    local Cur = math.floor(tonumber(CurrentId) or 0)
    for i, Id in ipairs(Order) do
        if Id == Cur then
            return Order[(i % #Order) + 1]
        end
    end
    return TalentMarketConfig.GetFirstWorkerId()
end

function TalentMarketConfig.GetPoolForWorker(WorkerId)
    local Worker = TalentMarketConfig.GetWorker(WorkerId)
    if Worker == nil then
        return {}
    end
    local MinLevel = math.floor(tonumber(Worker.MinMineLevel) or 1)
    local MaxLevel = math.floor(tonumber(Worker.MaxMineLevel) or 1)
    local Pool = {}
    for _, Ore in ipairs(TalentMarketConfig.OrePool) do
        local Level = math.floor(tonumber(Ore.MineLevel) or 0)
        if Level >= MinLevel and Level <= MaxLevel then
            Pool[#Pool + 1] = Ore
        end
    end
    return Pool
end

function TalentMarketConfig.RollRewards(WorkerId)
    local Worker = TalentMarketConfig.GetWorker(WorkerId)
    if Worker == nil then
        return nil
    end
    local Pool = TalentMarketConfig.GetPoolForWorker(WorkerId)
    if #Pool <= 0 then
        return nil
    end
    local Count = math.floor(tonumber(Worker.RewardCount) or 0)
    local Rewards = {}
    for _ = 1, Count do
        local Ore = Pool[math.random(1, #Pool)]
        local ItemId = math.floor(tonumber(Ore.ItemId) or 0)
        Rewards[ItemId] = (Rewards[ItemId] or 0) + 1
    end
    return Rewards
end

function TalentMarketConfig.FormatDuration(DurationSec)
    local Sec = math.max(0, math.floor(tonumber(DurationSec) or 0))
    local Min = math.floor(Sec / 60)
    if Min >= 1 then
        return tostring(Min) .. "分钟"
    end
    return tostring(Sec) .. "秒"
end

function TalentMarketConfig.FormatRewards(Rewards)
    if type(Rewards) ~= "table" then
        return ""
    end
    local Names = {}
    for ItemId, Count in pairs(Rewards) do
        local Name = tostring(ItemId)
        for _, Ore in ipairs(TalentMarketConfig.OrePool) do
            if Ore.ItemId == ItemId then
                Name = Ore.Name
                break
            end
        end
        Names[#Names + 1] = string.format("%s x%d", Name, math.floor(tonumber(Count) or 0))
    end
    table.sort(Names)
    return table.concat(Names, "、")
end

return TalentMarketConfig
