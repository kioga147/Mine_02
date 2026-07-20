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

local COIN_ITEM_ID = 83100002


---点击上锁格子的响应函数
---生效范围：客户端
---@param DataType number @类型 [0:背包数据, 1:仓库数据]
function BP_BackpackUIComponentV2_Custom:ClickLockBackpackItem(DataType)
    local PlayerController = self:GetOwner()
    local Player = PlayerController:GetPawn()
    
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

---开始运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveBeginPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveBeginPlay(self)
end

---结束运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveEndPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveEndPlay(self)
end

---点击上锁格子后回调(ClickLockBackpackItem重写后不执行)
---@param Panel UUserWidget @弹窗面板，取自ClickLockBackpackItem返回值，可能为nil
-- function BP_BackpackUIComponentV2_Custom:OnClickLockBackpackItem(Panel)
-- end

---是否显示丢弃区域
---生效范围：客户端
---@return boolean @是否显示丢弃区域
-- function BP_BackpackUIComponentV2_Custom:IsDiscardAreaVisible()
-- end

---获取RPC列表 (注意不要使用GetAvailableServerRPCs)
---@return table @RPC函数名列表
-- function BP_BackpackUIComponentV2_Custom:GetUGCAvailableServerRPCs()
--     return {}
-- end

---默认排序函数, 组件上配置
---生效范围: 客户端
---@param Data1 table @物品数据1 {DefineID:物品DefineID, Idx:格子索引}
---@param Data2 table @物品数据2 {DefineID:物品DefineID, Idx:格子索引}
---@return boolean @true:物品1在前, false:物品2在前
-- function BP_BackpackUIComponentV2_Custom.CompareQuality(Data1,Data2)
-- end

---获取背包拖拽控件类
---生效范围：客户端
---@return FSoftClassPath|nil @拖拽控件类，未配置则返回nil
-- function BP_BackpackUIComponentV2_Custom:GetBackpackDragDropWidget()
-- end

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

---背包UI关闭后执行
---@param Panel UUserWidget @背包主界面控件
-- function BP_BackpackUIComponentV2_Custom:OnCloseBattleMainPanel(Panel)
-- end

---打开大厅背包界面(已废弃)
---生效范围：客户端
---@param Mode number @1:背包+装备栏 2:背包+仓库 3:背包+装备栏+仓库
-- function BP_BackpackUIComponentV2_Custom:OpenLobbyBackpackMainUI(Mode)
-- end

---关闭大厅背包界面(已废弃)
---生效范围：客户端
-- function BP_BackpackUIComponentV2_Custom:CloseLobbyPanel()
-- end

---当打开删除弹窗时调用
---@param Panel UUserWidget @面板控件
-- function BP_BackpackUIComponentV2_Custom:OnOpenDeletePanel(Panel)
-- end

---当打开存入取出代币时调用
---@param Panel UUserWidget @面板控件
-- function BP_BackpackUIComponentV2_Custom:OnOpenSaveOrWithDrawPanel(Panel)
-- end

---当打开丢弃物品弹窗时调用
---@param Panel UUserWidget @面板控件
-- function BP_BackpackUIComponentV2_Custom:OnOpenDropItemPanel(Panel)
-- end

return BP_BackpackUIComponentV2_Custom