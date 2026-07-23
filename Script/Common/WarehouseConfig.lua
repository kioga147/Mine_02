--- 玩家仓库配置（对齐策划「七、设施升级 / 玩家仓库」）
--- 初始自动解锁 50 格；每次升级 +100 格，消耗 5000 金币或 50 绿洲币（约 5R）
local WarehouseConfig = {
    GoldItemId = 8310002,
    InitialSlots = 50,
    --- 硬上限：需高于「初始 + 多次升级」；引擎无独立 AddWarehouseMax API，靠组件 MaxWarehouseCapacity
    MaxSlots = 10050,
    SlotsPerUpgrade = 100,
    UpgradeGoldCost = 5000,
    UpgradeOasisCost = 50,
    --- 打开面板：0 全屏 / 1 半屏 / nil 默认；Mode 2 = 背包 + 仓库
    OpenPanelStyle = nil,
    OpenPanelMode = 2,
    --- 绿洲币商品 ID：0 表示走软扣费（校验余额，便于联调）
    OasisProductId = 0,
    AllowSoftOasisSpend = true,
}

function WarehouseConfig.GetUpgradeGoldCost()
    return math.floor(tonumber(WarehouseConfig.UpgradeGoldCost) or 5000)
end

function WarehouseConfig.GetUpgradeOasisCost()
    return math.floor(tonumber(WarehouseConfig.UpgradeOasisCost) or 50)
end

function WarehouseConfig.GetSlotsPerUpgrade()
    return math.floor(tonumber(WarehouseConfig.SlotsPerUpgrade) or 100)
end

function WarehouseConfig.GetInitialSlots()
    return math.floor(tonumber(WarehouseConfig.InitialSlots) or 50)
end

function WarehouseConfig.GetMaxSlots()
    return math.floor(tonumber(WarehouseConfig.MaxSlots) or 10050)
end

--- 当前容量还能再升几级（受 MaxSlots 限制）
function WarehouseConfig.CanUpgrade(CurrentCapacity)
    CurrentCapacity = math.floor(tonumber(CurrentCapacity) or 0)
    local Next = CurrentCapacity + WarehouseConfig.GetSlotsPerUpgrade()
    return Next <= WarehouseConfig.GetMaxSlots()
end

return WarehouseConfig
