---@class BP_BackpackComponentV2_Custom_C:BP_BackpackComponentV2_C
--Edit Below--
local BP_BackpackComponentV2_Custom = {} 

local MAX_WEIGHT_CAPACITY = 100
local NORMAL_SPEED_SCALE = 2.0

local ITEM_WEIGHT_TABLE = {
    [8310000] = 1,
    [8310003] = 2,
    [8310004] = 3,
    [8310005] = 4,
    [8310006] = 5,
    [8310007] = 6,
    [8310008] = 7,
    [8310009] = 8,
    [8310010] = 9,
    [8310011] = 10,
    [8310012] = 1,
    [8310013] = 1,
    [8310014] = 1,
    [8310015] = 1,
    [8310016] = 1,
    [8310017] = 1,
}

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

local function CheckAutoUpgrade(Player)
    local currentCapacity = UGCBackpackSystemV2.GetCellCapacity(Player)
    local maxCapacity = UGCBackpackSystemV2.GetMaxCellCapacity(Player)
    local playerCoins = UGCBackpackSystemV2.GetItemCountV2(Player, COIN_ITEM_ID)
    
    for level = 1, 9 do
        local currentConfig = BACKPACK_LEVEL_CONFIG[level]
        local nextConfig = BACKPACK_LEVEL_CONFIG[level + 1]
        
        if currentCapacity == currentConfig.Capacity then
            if playerCoins >= nextConfig.Cost then
                if nextConfig.Capacity <= maxCapacity then
                    local capacityIncrease = nextConfig.Capacity - currentConfig.Capacity
                    UGCBackpackSystemV2.RemoveItemV2(Player, COIN_ITEM_ID, nextConfig.Cost)
                    UGCBackpackSystemV2.AddCellCapacity(Player, capacityIncrease)
                    ugcprint(string.format("[背包升级] %d→%d (容量%d→%d) 消耗%d金币",
                        level, level + 1, currentConfig.Capacity, nextConfig.Capacity, nextConfig.Cost))
                    return true
                end
            end
            break
        end
    end
    
    return false
end

local function GetItemWeight(DefineID)
    if DefineID and DefineID.TypeSpecificID then
        local itemID = DefineID.TypeSpecificID
        if ITEM_WEIGHT_TABLE[itemID] then
            return ITEM_WEIGHT_TABLE[itemID]
        end
    end
    return 1
end

local function GetCurrentTotalWeight(Player)
    local totalWeight = 0
    for itemID, weight in pairs(ITEM_WEIGHT_TABLE) do
        local count = UGCBackpackSystemV2.GetItemCountV2(Player, itemID) or 0
        if count > 0 then
            totalWeight = totalWeight + weight * count
        end
    end
    return totalWeight
end

local function GetRemainingWeight(Player)
    return MAX_WEIGHT_CAPACITY - GetCurrentTotalWeight(Player)
end

local function _GetPlayerPawn(Player)
    if Player == nil then return nil end
    if UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
        local Ok, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Player)
        if Ok and Pawn then return Pawn end
    end
    if Player.GetPawn then
        local Ok, Pawn = pcall(Player.GetPawn, Player)
        if Ok and Pawn then return Pawn end
    end
    if Player.Pawn then
        return Player.Pawn
    end
    return Player
end

local function _NotifyPawnUpdateSpeed(Player)
    if Player == nil then return end
    local Pawn = _GetPlayerPawn(Player)
    if Pawn and Pawn.UpdateMoveSpeed then
        Pawn:UpdateMoveSpeed()
    end
end

function BP_BackpackComponentV2_Custom.UpdateWeightSpeed(Player)
    _NotifyPawnUpdateSpeed(Player)
end

function BP_BackpackComponentV2_Custom.GetBackpackWeightInfo(Player)
    local currentWeight = GetCurrentTotalWeight(Player)
    return {
        CurrentWeight = currentWeight,
        MaxWeight = MAX_WEIGHT_CAPACITY,
        RemainingWeight = MAX_WEIGHT_CAPACITY - currentWeight
    }
end

---func 背包初始化函数，玩家登录后执行一次(服务端调用)
function BP_BackpackComponentV2_Custom:InitEventAfterPlayerEnter()
    if BP_BackpackComponentV2_Custom.SuperClass.InitEventAfterPlayerEnter then
        pcall(function()
            BP_BackpackComponentV2_Custom.SuperClass.InitEventAfterPlayerEnter(self)
        end)
    end
    -- 玩家仓库：初始自动解锁 50 格（对齐策划）
    local Initial = 50
    local OkCfg, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.WarehouseConfig")
    end)
    if OkCfg and type(Mod) == "table" and Mod.GetInitialSlots then
        Initial = Mod.GetInitialSlots()
    end
    local Player = self:GetOwner()
    if Player == nil or not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetWarehouseCellCapacity then
        return
    end
    local Cap = math.floor(tonumber(UGCBackpackSystemV2.GetWarehouseCellCapacity(Player)) or 0)
    if Cap >= Initial then
        return
    end
    local Need = Initial - Cap
    local Ok = pcall(UGCBackpackSystemV2.AddWarehouseCellCapacity, Player, Need)
    if Ok then
        ugcprint(string.format("[仓库] 初始容量 %d→%d", Cap, Cap + Need))
    end
    _NotifyPawnUpdateSpeed(Player)
end

---func 能否添加物品进背包(服务端调用)
---@param ItemID number 物品ID
---@param Count number 物品数量
---@return number 允许添加物品数量
function BP_BackpackComponentV2_Custom:CanAddItemV2(ItemID, Count)
    local slotAllowed = BP_BackpackComponentV2_Custom.SuperClass.CanAddItemV2(self, ItemID, Count)
    if slotAllowed <= 0 then
        return 0
    end
    local Player = self:GetOwner()
    local remainingWeight = GetRemainingWeight(Player)
    if remainingWeight <= 0 then
        return 0
    end
    local itemWeight = ITEM_WEIGHT_TABLE[ItemID] or 1
    local maxByWeight = math.floor(remainingWeight / itemWeight)
    return math.min(slotAllowed, maxByWeight)
end

---func 能否添加物品进背包(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
---@return number 允许添加物品数量
function BP_BackpackComponentV2_Custom:CanAddItemByDefineIDV2(DefineID, Count)
    local slotAllowed = BP_BackpackComponentV2_Custom.SuperClass.CanAddItemByDefineIDV2(self, DefineID, Count)
    if slotAllowed <= 0 then
        return 0
    end
    local Player = self:GetOwner()
    local remainingWeight = GetRemainingWeight(Player)
    if remainingWeight <= 0 then
        return 0
    end
    local itemWeight = GetItemWeight(DefineID)
    local maxByWeight = math.floor(remainingWeight / itemWeight)
    return math.min(slotAllowed, maxByWeight)
end

---func 当背包添加物品后回调(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
function BP_BackpackComponentV2_Custom:OnAddItemV2(DefineID, Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnAddItemV2(self, DefineID, Count)
    local Player = self:GetOwner()
    CheckAutoUpgrade(Player)
    _NotifyPawnUpdateSpeed(Player)
end

---func 能否合并物品(新添加物品能否与已有格子物品堆叠, 格子物品即物品实例)(服务端调用)
---@param ItemDefineID userdata 格子物品DefineID
---@param CountNow number 当前格子的物品数量
---@param MergeCount number 要合并到格子的新物品数量
---@return number 能合并到该格子的物品数量
function BP_BackpackComponentV2_Custom:CanMergeItemV2(ItemDefineID, CountNow, MergeCount)
    return BP_BackpackComponentV2_Custom.SuperClass.CanMergeItemV2(self, ItemDefineID, CountNow, MergeCount)
end

---func 当合并物品后回调(新添加物品与已有格子物品堆叠, 格子物品即物品实例)(服务端调用)
---@param ItemDefineID userdata 格子物品DefineID
---@param OldCount number 合并前格子的物品数量
---@param MergeCount number 合并到该格子的新物品数量
function BP_BackpackComponentV2_Custom:OnMergeItemV2(ItemDefineID, OldCount, MergeCount)
    BP_BackpackComponentV2_Custom.SuperClass.OnMergeItemV2(self, ItemDefineID, OldCount, MergeCount)
    local Player = self:GetOwner()
    CheckAutoUpgrade(Player)
    _NotifyPawnUpdateSpeed(Player)
end

---func 能否移除物品(服务端调用)
---@param ItemDefineID userdata 物品DefineID
---@param Count number 需要移除的物品数量
---@return number 允许移除物品数量
function BP_BackpackComponentV2_Custom:CanRemoveItemV2(ItemDefineID, Count)
    return BP_BackpackComponentV2_Custom.SuperClass.CanRemoveItemV2(self, ItemDefineID, Count)
end

---func 移除物品后回调(服务端调用)
---@param ItemDefineID userdata 物品DefineID，移除后可能不存在于背包
---@param Count number 已移除的物品数量
function BP_BackpackComponentV2_Custom:OnRemoveItemV2(ItemDefineID, Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnRemoveItemV2(self, ItemDefineID, Count)
    _NotifyPawnUpdateSpeed(self:GetOwner())
end

---func 能否丢弃物品(服务端调用)
---@param ItemDefineID userdata 物品DefineID
---@param Count number 需要丢弃的物品数量
---@return number 允许丢弃的物品数量
function BP_BackpackComponentV2_Custom:CanDropItemV2(ItemDefineID, Count)
    return BP_BackpackComponentV2_Custom.SuperClass.CanDropItemV2(self, ItemDefineID, Count)
end

---func 丢弃物品后回调(服务端调用)
---@param ItemDefineID userdata 物品DefineID，丢弃后物品可能不存在于背包
---@param Count number 已丢弃的物品数量
function BP_BackpackComponentV2_Custom:OnDropItemV2(ItemDefineID, Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnDropItemV2(self, ItemDefineID, Count)
    _NotifyPawnUpdateSpeed(self:GetOwner())
end

---func 能否使用物品(服务端调用)
---@param ItemDefineID userdata 物品DefineID
---@return bool 物品能否使用
function BP_BackpackComponentV2_Custom:CanUseItemV2(ItemDefineID)
    return BP_BackpackComponentV2_Custom.SuperClass.CanUseItemV2(self, ItemDefineID)
end

---func 使用物品后回调(服务端调用)
---@param ItemDefineID userdata 物品DefineID
function BP_BackpackComponentV2_Custom:OnUseItemV2(ItemDefineID)
    BP_BackpackComponentV2_Custom.SuperClass.OnUseItemV2(self, ItemDefineID)
    _NotifyPawnUpdateSpeed(self:GetOwner())
end

---func 取消使用物品后回调(服务端调用) 装备/投掷物 取消使用/卸下。 注：药品不会触发此回调
---@param ItemDefineID userdata 物品DefineID
function BP_BackpackComponentV2_Custom:OnDisuseItemV2(ItemDefineID)
    BP_BackpackComponentV2_Custom.SuperClass.OnDisuseItemV2(self, ItemDefineID)
end

---func 物品能否附加到此背包槽位(服务端调用)
---@param SlotName string 槽位名称Tag
---@param ItemDefineID userdata 物品DefineID
---@return bool 能否附加
function BP_BackpackComponentV2_Custom:CanAttachToSlot(SlotName, ItemDefineID)
    return BP_BackpackComponentV2_Custom.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID)
end

---func 物品附加到背包槽位后回调(服务端调用)
---@param SlotName string 槽位名称Tag
---@param ItemDefineID userdata 物品DefineID
function BP_BackpackComponentV2_Custom:OnAttachToSlot(SlotName, ItemDefineID)
    BP_BackpackComponentV2_Custom.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID)
end

---func 物品从背包槽位移除后回调(服务端调用)
---@param SlotName string 槽位名称Tag
---@param ItemDefineID userdata 物品DefineID
function BP_BackpackComponentV2_Custom:OnDetachBySlot(SlotName, ItemDefineID)
    BP_BackpackComponentV2_Custom.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID)
end

---func 处理超过格子容量的物品(服务端调用) 物品在进入背包后，如果数量超过格子容量，会调用此函数处理。比如在丢弃了背包后，背包中的物品数量溢出，需要调用此函数处理
---@param ItemDefineID userdata 物品DefineID
---@param Count number 溢出物品数量
function BP_BackpackComponentV2_Custom:HandleExceedCellCapacity(ItemDefineID, Count)
    BP_BackpackComponentV2_Custom.SuperClass.HandleExceedCellCapacity(self, ItemDefineID, Count)
end

return BP_BackpackComponentV2_Custom