---@class BP_BackpackUIComponentV2_Custom_C:BP_BackpackUIComponentV2_C
--Edit Below--
local BP_BackpackUIComponentV2_Custom = {} 

local BACKPACK_LEVEL_CONFIG = {
    [1] = { Capacity = 10, Cost = 0 },
    [2] = { Capacity = 15, Cost = 1500 },
    [3] = { Capacity = 20, Cost = 4000 },
    [4] = { Capacity = 40, Cost = 10000 },
    [5] = { Capacity = 60, Cost = 20000 },
    [6] = { Capacity = 80, Cost = 50000 },
    [7] = { Capacity = 100, Cost = 100000 },
    [8] = { Capacity = 140, Cost = 200000 },
    [9] = { Capacity = 180, Cost = 400000 },
    [10] = { Capacity = 240, Cost = 1000000 },
}

local COIN_ITEM_ID = 8310002

local WarehouseConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.WarehouseConfig")
    end)
    if Ok and type(Mod) == "table" then
        WarehouseConfig = Mod
    else
        WarehouseConfig = {
            UpgradeGoldCost = 5000,
            SlotsPerUpgrade = 100,
            MaxSlots = 10050,
            GetUpgradeGoldCost = function()
                return 5000
            end,
            GetSlotsPerUpgrade = function()
                return 100
            end,
            GetMaxSlots = function()
                return 10050
            end,
            CanUpgrade = function(CurrentCapacity)
                return (math.floor(tonumber(CurrentCapacity) or 0) + 100) <= 10050
            end,
        }
    end
end

local function TryUpgradeBackpack(Player)
    local currentCapacity = UGCBackpackSystemV2.GetCellCapacity(Player)
    local playerCoins = UGCBackpackSystemV2.GetItemCountV2(Player, COIN_ITEM_ID)

    ugcprint("[背包升级] 当前已解锁容量:", currentCapacity, "金币:", playerCoins)

    for level = 1, 9 do
        local currentConfig = BACKPACK_LEVEL_CONFIG[level]
        local nextConfig = BACKPACK_LEVEL_CONFIG[level + 1]

        if currentCapacity == currentConfig.Capacity then
            if playerCoins >= nextConfig.Cost then
                local capacityIncrease = nextConfig.Capacity - currentConfig.Capacity
                UGCBackpackSystemV2.RemoveItemV2(Player, COIN_ITEM_ID, nextConfig.Cost)
                UGCBackpackSystemV2.AddCellCapacity(Player, capacityIncrease)
                ugcprint("[背包升级] 升级成功！等级:", level, "->", level + 1, "容量:", currentConfig.Capacity, "->", nextConfig.Capacity, "消耗金币:", nextConfig.Cost)
            else
                ugcprint("[背包升级] 金币不足！需要:", nextConfig.Cost, "当前:", playerCoins)
            end
            break
        end
    end
end

--- 点击仓库锁格：走服务端升级（支持金币/绿洲币），此处仅发请求用金币档（UI 无支付切换）
local function TryRequestWarehouseUpgrade(PlayerController)
    if PlayerController == nil then
        return
    end
    if PlayerController.RequestUpgradeWarehouse then
        -- 锁格点击默认金币支付；绿洲币请走仓库设施面板切换
        PlayerController:RequestUpgradeWarehouse(0)
        return
    end
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_UpgradeWarehouse", 0)
end

---点击上锁格子的响应函数
---生效范围：客户端
---@param DataType number @类型 [0:背包数据, 1:仓库数据]
function BP_BackpackUIComponentV2_Custom:ClickLockBackpackItem(DataType)
    local PlayerController = self:GetOwner()
    local Player = PlayerController:GetPawn()
    DataType = math.floor(tonumber(DataType) or 0)

    if DataType == 1 then
        local Cap = 0
        if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetWarehouseCellCapacity then
            Cap = math.floor(tonumber(UGCBackpackSystemV2.GetWarehouseCellCapacity(Player)) or 0)
        end
        if not WarehouseConfig.CanUpgrade(Cap) then
            ugcprint("[仓库升级] 已达上限 Cap=", Cap)
            return
        end
        ugcprint("[仓库升级] 锁格请求升级 Cap=", Cap, "Cost=", WarehouseConfig.GetUpgradeGoldCost())
        TryRequestWarehouseUpgrade(PlayerController)
        return
    end

    TryUpgradeBackpack(Player)
end

---开始运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveBeginPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveBeginPlay(self)
end

---结束运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveEndPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveEndPlay(self)
end

---背包UI打开后执行
---@param Panel UUserWidget @背包主界面控件
function BP_BackpackUIComponentV2_Custom:OnOpenBattleMainPanel(Panel)
    BP_BackpackUIComponentV2_Custom.SuperClass.OnOpenBattleMainPanel(self, Panel)
    
    local Player = self:GetOwner()
    local backpackWeightInfo = BP_BackpackComponentV2_Custom.GetBackpackWeightInfo(Player)
    if backpackWeightInfo then
        local weightText = string.format("%dkg/%dkg", math.floor(backpackWeightInfo.CurrentWeight), backpackWeightInfo.MaxWeight)
        
        if Panel and Panel.SetText then
            Panel:SetText(weightText)
        elseif Panel and Panel.GetWidgetFromName then
            local TextWidget = Panel:GetWidgetFromName("WeightText")
            if TextWidget and TextWidget.SetText then
                TextWidget:SetText(weightText)
            end
        end
    end
end

return BP_BackpackUIComponentV2_Custom
