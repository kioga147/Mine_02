---@class BP_BackpackComponentV2_Custom_C:BP_BackpackComponentV2_C
--Edit Below--
local BP_BackpackComponentV2_Custom = {}

local MELEE_SLOT_NAME = "EquipmentSlot.Core.MeleeSlot"
local MELEE_WEAPON_SLOT = 4
local MINE_CAR_ITEM_IDS = {
    [8310025] = true,
    [8310024] = true,
    [8310023] = true,
}

local MiningSystem = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.GamePartCustom.MiningSystem")
    end)
    if Ok and type(Mod) == "table" then
        MiningSystem = Mod
    end
end

local function GetItemIdFromDefineID(ItemDefineID)
    if ItemDefineID == nil then
        return 0
    end
    local Ok, Id = pcall(function()
        return ItemDefineID.TypeSpecificID
    end)
    if Ok and Id ~= nil then
        return math.floor(tonumber(Id) or 0)
    end
    return 0
end

local function TryEquipUsedMeleeToHand(PC, ItemDefineID)
    if PC == nil or ItemDefineID == nil then
        return
    end
    local ItemId = GetItemIdFromDefineID(ItemDefineID)
    if ItemId <= 0 or MINE_CAR_ITEM_IDS[ItemId] then
        return
    end
    if MiningSystem == nil then
        local Ok, Mod = pcall(function()
            return UGCGameSystem.UGCRequire("Script.GamePartCustom.MiningSystem")
        end)
        if Ok and type(Mod) == "table" then
            MiningSystem = Mod
        end
    end
    if MiningSystem == nil or not MiningSystem.GetAxeLevelByItemID then
        return
    end
    if MiningSystem.GetAxeLevelByItemID(ItemId) <= 0 then
        return
    end

    local Pawn = nil
    if PC.GetPawn then
        local Ok, P = pcall(PC.GetPawn, PC)
        if Ok then
            Pawn = P
        end
    end
    if Pawn == nil and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
        local Ok, P = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, PC)
        if Ok then
            Pawn = P
        end
    end
    if Pawn == nil or not (Pawn.IsMineCarMode and Pawn:IsMineCarMode()) then
        return
    end

    local Ok, IDs = pcall(UGCBackpackSystemV2.GetItemDefineIDsByIDV2, PC, ItemId)
    if not (Ok and IDs and #IDs > 0) then
        return
    end

    ugcprint("[背包V2] 使用近战物品，切换武器并退出矿车模式")
    pcall(UGCBackpackSystemV2.EquipItemV2, PC, MELEE_SLOT_NAME, IDs[1])
    local function SwitchToMelee()
        if Pawn and UE.IsValid(Pawn)
            and UGCWeaponManagerSystem and UGCWeaponManagerSystem.SwitchWeaponBySlot then
            pcall(UGCWeaponManagerSystem.SwitchWeaponBySlot, Pawn, MELEE_WEAPON_SLOT, true)
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.3, SwitchToMelee, false)
        UGCTimerUtility.CreateLuaTimer(0.5, function()
            if Pawn and UE.IsValid(Pawn) and Pawn.IsMineCarMode and Pawn:IsMineCarMode() then
                ugcprint("[背包V2] 切回近战武器，退出矿车模式恢复人形")
                if Pawn.SetMineCarMode then
                    Pawn:SetMineCarMode(false)
                elseif Pawn.DoSetMineCarMode then
                    Pawn:DoSetMineCarMode(false)
                end
            end
        end, false)
    else
        SwitchToMelee()
        if Pawn and Pawn.IsMineCarMode and Pawn:IsMineCarMode() then
            if Pawn.SetMineCarMode then
                Pawn:SetMineCarMode(false)
            elseif Pawn.DoSetMineCarMode then
                Pawn:DoSetMineCarMode(false)
            end
        end
    end
end


---func 背包初始化函数，玩家登录后执行一次(服务端调用)
function BP_BackpackComponentV2_Custom:InitEventAfterPlayerEnter()
    -- 玩家仓库：初始自动解锁 50 格（对齐策划）
    local Initial = 50
    local MaxWarehouse = 10050
    local OkCfg, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.WarehouseConfig")
    end)
    if OkCfg and type(Mod) == "table" and Mod.GetInitialSlots then
        Initial = Mod.GetInitialSlots()
    end
    if OkCfg and type(Mod) == "table" and Mod.GetMaxSlots then
        MaxWarehouse = Mod.GetMaxSlots()
    end
    local Player = self:GetOwner()
    if Player == nil or not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetWarehouseCellCapacity then
        return
    end
    if MaxWarehouse > 0 then
        pcall(function()
            self.MaxWarehouseCapacity = MaxWarehouse
        end)
        pcall(function()
            self.WarehouseMaxCellCapacity = MaxWarehouse
        end)
    end
    local Cap = math.floor(tonumber(UGCBackpackSystemV2.GetWarehouseCellCapacity(Player)) or 0)
    if Cap >= Initial then
        return
    end
    local Need = Initial - Cap
    local Ok, Ret = pcall(UGCBackpackSystemV2.AddWarehouseCellCapacity, Player, Need)
    ugcprint("[仓库] InitEvent 初始容量", Cap, "->", Cap + Need, "ok=", Ok, "ret=", Ret)
end

---func 能否添加物品进背包(服务端调用)
---@param ItemID number 物品ID
---@param Count number 物品数量
---@return number 允许添加物品数量

---func 能否添加物品进背包(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
---@return number 允许添加物品数量

---func 当背包添加物品后回调(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
function BP_BackpackComponentV2_Custom:OnAddItemV2(DefineID, Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnAddItemV2(self, DefineID, Count)
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
    TryEquipUsedMeleeToHand(self:GetOwner(), ItemDefineID)
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
