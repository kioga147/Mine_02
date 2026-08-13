--- 全自动采矿工厂配置（新增设施：解锁费50万，60秒/周期，自动采矿+加工+售卖）
--- 前置条件：解锁所有采矿车（初/中/高级）、矿石加工厂、人才市场、玉石鉴定所、采矿车维修处、矿区传送大厅
--- 默认保留未鉴定玉石；关闭保留则自动走快速鉴定（0花费版）后与其他矿石一起自动售卖
local AutoMineFactoryConfig = {
    --- 解锁费用
    UnlockCost = 500000,
    --- 金币 ItemId（与其他设施统一）
    GoldItemId = 8310002,
    --- 未鉴定玉石 ItemId
    JadeOreItemId = 8310011,
    --- 产出周期：每 60 秒一个周期
    CycleSec = 60,
    --- 每个周期基础产出矿物数量（不加矿工）
    BaseOreCountPerCycle = 60,
    --- 矿工档位（与人才市场语义对齐，加成是"每周期叠加产出"）
    WorkerOrder = { 1, 2, 3 },
    Workers = {
        [1] = {
            Name = "初级加工矿工",
            HireCost = 0,          --- 0 表示仅切换档位，不额外扣费
            BonusOreCount = 0,     --- 不增加数量，只影响品质范围
            MinMineLevel = 1,
            MaxMineLevel = 3,
            Desc = "1~3 级矿物，无额外产出加成",
        },
        [2] = {
            Name = "中级加工矿工",
            HireCost = 0,
            BonusOreCount = 10,    --- 每周期多产出 10 个
            MinMineLevel = 1,
            MaxMineLevel = 4,
            Desc = "1~4 级矿物，每周期多 10 个",
        },
        [3] = {
            Name = "高级加工矿工",
            HireCost = 0,
            BonusOreCount = 20,    --- 每周期多产出 20 个
            MinMineLevel = 3,
            MaxMineLevel = 5,
            Desc = "3~5 级矿物（含玉石），每周期多 20 个",
        },
    },
    --- 矿物池（复用 OreRecycleConfig 可回收的矿物 + 玉矿石）
    OrePool = {
        { ItemId = 8310000, Name = "石头",     MineLevel = 1 },
        { ItemId = 8310003, Name = "煤矿",     MineLevel = 1 },
        { ItemId = 8310004, Name = "粗铁矿",   MineLevel = 2 },
        { ItemId = 8310005, Name = "粗铜矿",   MineLevel = 2 },
        { ItemId = 8310006, Name = "石英矿",   MineLevel = 2 },
        { ItemId = 8310007, Name = "粗金矿",   MineLevel = 3 },
        { ItemId = 8310008, Name = "铝土矿",   MineLevel = 3 },
        { ItemId = 8310009, Name = "钻石矿",   MineLevel = 4 },
        { ItemId = 8310010, Name = "红宝石矿", MineLevel = 4 },
        { ItemId = 8310011, Name = "玉矿石",   MineLevel = 5 },
    },
    --- 玉石快速鉴定：工厂版 0 花费，随机 0~10000（与策划玉石鉴定所对齐但不扣费）
    JadeQuickAppraise = {
        MinValue = 0,
        MaxValue = 10000,
    },
    --- 默认是否保留未鉴定玉石：true=保留进背包/仓库，false=自动鉴定后一起卖
    DefaultKeepJade = true,
}

function AutoMineFactoryConfig.GetWorker(WorkerId)
    return AutoMineFactoryConfig.Workers[math.floor(tonumber(WorkerId) or 0)]
end

function AutoMineFactoryConfig.GetFirstWorkerId()
    return AutoMineFactoryConfig.WorkerOrder[1] or 1
end

function AutoMineFactoryConfig.NextWorkerId(CurrentId)
    local Order = AutoMineFactoryConfig.WorkerOrder
    local Cur = math.floor(tonumber(CurrentId) or 0)
    for i, Id in ipairs(Order) do
        if Id == Cur then
            return Order[(i % #Order) + 1]
        end
    end
    return AutoMineFactoryConfig.GetFirstWorkerId()
end

--- 按当前矿工档位过滤矿物池
function AutoMineFactoryConfig.GetPoolForWorker(WorkerId)
    local Worker = AutoMineFactoryConfig.GetWorker(WorkerId)
    if Worker == nil then
        return {}
    end
    local MinLevel = math.floor(tonumber(Worker.MinMineLevel) or 1)
    local MaxLevel = math.floor(tonumber(Worker.MaxMineLevel) or 1)
    local Pool = {}
    for _, Ore in ipairs(AutoMineFactoryConfig.OrePool) do
        local Level = math.floor(tonumber(Ore.MineLevel) or 0)
        if Level >= MinLevel and Level <= MaxLevel then
            Pool[#Pool + 1] = Ore
        end
    end
    return Pool
end

--- 计算本周期总产出数
function AutoMineFactoryConfig.GetTotalOreCountPerCycle(WorkerId)
    local Base = math.floor(tonumber(AutoMineFactoryConfig.BaseOreCountPerCycle) or 60)
    local Worker = AutoMineFactoryConfig.GetWorker(WorkerId)
    local Bonus = 0
    if Worker ~= nil then
        Bonus = math.floor(tonumber(Worker.BonusOreCount) or 0)
    end
    return Base + Bonus
end

--- 产出一周期的矿物（聚合表：ItemId -> Count）
function AutoMineFactoryConfig.RollCycleRewards(WorkerId)
    local Pool = AutoMineFactoryConfig.GetPoolForWorker(WorkerId)
    if #Pool <= 0 then
        return nil
    end
    local Count = AutoMineFactoryConfig.GetTotalOreCountPerCycle(WorkerId)
    local Rewards = {}
    for _ = 1, Count do
        local Ore = Pool[math.random(1, #Pool)]
        local ItemId = math.floor(tonumber(Ore.ItemId) or 0)
        Rewards[ItemId] = (Rewards[ItemId] or 0) + 1
    end
    return Rewards
end

--- 玉石快速鉴定：工厂版不扣费，返回随机价值
function AutoMineFactoryConfig.RollJadeQuickValue()
    local Cfg = AutoMineFactoryConfig.JadeQuickAppraise or {}
    local MinV = math.floor(tonumber(Cfg.MinValue) or 0)
    local MaxV = math.floor(tonumber(Cfg.MaxValue) or 10000)
    return math.random(MinV, MaxV)
end

--- 格式化奖励（用于提示语）
function AutoMineFactoryConfig.FormatRewards(Rewards)
    if type(Rewards) ~= "table" then
        return ""
    end
    local Names = {}
    for ItemId, Count in pairs(Rewards) do
        local Name = tostring(ItemId)
        for _, Ore in ipairs(AutoMineFactoryConfig.OrePool) do
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

--- 格式化剩余时间
function AutoMineFactoryConfig.FormatRemainingTime(Sec)
    Sec = math.max(0, math.floor(tonumber(Sec) or 0))
    if Sec >= 60 then
        return string.format("%d分%02d秒", math.floor(Sec / 60), Sec % 60)
    end
    return tostring(Sec) .. "秒"
end

return AutoMineFactoryConfig
