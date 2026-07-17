---@class BP_BackpackComponentV2_Custom_C:BP_BackpackComponentV2_C
--Edit Below--
local BP_BackpackComponentV2_Custom = {} 

local MAX_WEIGHT_CAPACITY = 100

local function GetItemWeight(DefineID)
    local weight = 1
    ugcprint("[背包负重] GetItemWeight 开始 - DefineID:", DefineID)
    
    if DefineID and DefineID.TypeSpecificID then
        local itemID = DefineID.TypeSpecificID
        ugcprint("[背包负重] 物品ID:", itemID)
        
        local itemHandle = UGCItemSystemV2.GetConfigItemHandle(itemID)
        if itemHandle then
            ugcprint("[背包负重] itemHandle存在")
            if itemHandle.UnitWeightConfig then
                weight = itemHandle.UnitWeightConfig
                ugcprint("[背包负重] 读取UnitWeightConfig成功:", weight)
            else
                ugcprint("[背包负重] itemHandle无UnitWeightConfig属性，使用默认值1")
            end
        else
            ugcprint("[背包负重] itemHandle不存在，使用默认值1")
        end
    else
        ugcprint("[背包负重] DefineID无效，使用默认值1")
    end
    
    ugcprint("[背包负重] GetItemWeight 结束 - 重量:", weight)
    return tonumber(weight) or 1
end

local function GetCurrentTotalWeight(Player)
    local totalWeight = 0
    ugcprint("[背包负重] GetCurrentTotalWeight 开始 - Player:", Player)
    
    local allItemDefineIDs = UGCBackpackSystemV2.GetAllItemDefineIDsV2(Player)
    if allItemDefineIDs then
        ugcprint("[背包负重] 获取物品列表成功，数量:", #allItemDefineIDs)
        for _, defineID in ipairs(allItemDefineIDs) do
            local count = UGCBackpackSystemV2.GetItemCountByDefineIDV2(Player, defineID)
            local weight = GetItemWeight(defineID)
            ugcprint("[背包负重] 物品:", defineID, "数量:", count, "单重:", weight, "小计:", count * weight)
            totalWeight = totalWeight + weight * count
        end
    else
        ugcprint("[背包负重] 获取物品列表失败或为空")
    end
    
    ugcprint("[背包负重] GetCurrentTotalWeight 结束 - 当前总重量:", totalWeight, "kg")
    return totalWeight
end

local function GetRemainingWeight(Player)
    local currentWeight = GetCurrentTotalWeight(Player)
    local remaining = MAX_WEIGHT_CAPACITY - currentWeight
    ugcprint("[背包负重] 剩余负重:", remaining, "kg")
    return remaining
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
-- function BP_BackpackComponentV2_Custom:InitEventAfterPlayerEnter()
-- end

---func 能否添加物品进背包(服务端调用)
---@param ItemID number 物品ID
---@param Count number 物品数量
---@return number 允许添加物品数量
function BP_BackpackComponentV2_Custom:CanAddItemV2(ItemID, Count)
    ugcprint("[背包负重] ====== CanAddItemV2 ======")
    ugcprint("[背包负重] ItemID:", ItemID, "Count:", Count)
    
    local Player = self:GetOwner()
    local remainingWeight = GetRemainingWeight(Player)
    ugcprint("[背包负重] 剩余负重:", remainingWeight, "kg")
    
    local itemWeight = 1
    local itemHandle = UGCItemSystemV2.GetConfigItemHandle(ItemID)
    if itemHandle and itemHandle.UnitWeightConfig then
        itemWeight = itemHandle.UnitWeightConfig
    end
    ugcprint("[背包负重] 物品单重:", itemWeight, "kg")
    
    local maxCount = math.floor(remainingWeight / itemWeight)
    local result = math.min(Count, maxCount)
    ugcprint("[背包负重] 允许添加数量:", result)
    
    if result < Count then
        ugcprint("[背包负重] ⚠️ 超重警告！无法添加全部物品，已限制数量")
    end
    
    ugcprint("[背包负重] ===========================")
    return result
end

---func 能否添加物品进背包(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
---@return number 允许添加物品数量
function BP_BackpackComponentV2_Custom:CanAddItemByDefineIDV2(DefineID, Count)
    ugcprint("[背包负重] ====== CanAddItemByDefineIDV2 ======")
    ugcprint("[背包负重] DefineID:", DefineID, "Count:", Count)
    
    local Player = self:GetOwner()
    local remainingWeight = GetRemainingWeight(Player)
    ugcprint("[背包负重] 剩余负重:", remainingWeight, "kg")
    
    local itemWeight = GetItemWeight(DefineID)
    ugcprint("[背包负重] 物品单重:", itemWeight, "kg")
    
    local maxCount = math.floor(remainingWeight / itemWeight)
    local result = math.min(Count, maxCount)
    ugcprint("[背包负重] 允许添加数量:", result)
    
    if result < Count then
        ugcprint("[背包负重] ⚠️ 超重警告！无法添加全部物品，已限制数量")
    end
    
    ugcprint("[背包负重] =======================================")
    return result
end

---func 当背包添加物品后回调(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
function BP_BackpackComponentV2_Custom:OnAddItemV2(DefineID, Count)
    ugcprint("[背包负重] ====== 物品添加成功 ======")
    ugcprint("[背包负重] DefineID:", DefineID, "Count:", Count)
    
    BP_BackpackComponentV2_Custom.SuperClass.OnAddItemV2(self, DefineID, Count)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    
    ugcprint("[背包负重] 当前背包重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
    
    if currentWeight >= MAX_WEIGHT_CAPACITY then
        ugcprint("[背包负重] ❌❌❌ 背包已超重！移动速度将降低！")
    elseif currentWeight >= MAX_WEIGHT_CAPACITY * 0.8 then
        ugcprint("[背包负重] ⚠️ 背包接近负重上限！")
    else
        ugcprint("[背包负重] ✅ 背包负重正常")
    end
    
    ugcprint("[背包负重] =======================")
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
    ugcprint("[背包负重] ====== 物品合并 ======")
    ugcprint("[背包负重] ItemDefineID:", ItemDefineID, "OldCount:", OldCount, "MergeCount:", MergeCount)
    
    BP_BackpackComponentV2_Custom.SuperClass.OnMergeItemV2(self, ItemDefineID, OldCount, MergeCount)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    
    ugcprint("[背包负重] 当前背包重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
    
    if currentWeight >= MAX_WEIGHT_CAPACITY then
        ugcprint("[背包负重] ❌❌❌ 背包已超重！移动速度将降低！")
    end
    
    ugcprint("[背包负重] =======================")
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
    ugcprint("[背包负重] ====== 物品移除 ======")
    ugcprint("[背包负重] ItemDefineID:", ItemDefineID, "Count:", Count)
    
    BP_BackpackComponentV2_Custom.SuperClass.OnRemoveItemV2(self, ItemDefineID, Count)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    
    ugcprint("[背包负重] 当前背包重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
    
    if currentWeight < MAX_WEIGHT_CAPACITY then
        ugcprint("[背包负重] ✅ 背包负重正常")
    end
    
    ugcprint("[背包负重] =======================")
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
    ugcprint("[背包负重] ====== 物品丢弃 ======")
    ugcprint("[背包负重] ItemDefineID:", ItemDefineID, "Count:", Count)
    
    BP_BackpackComponentV2_Custom.SuperClass.OnDropItemV2(self, ItemDefineID, Count)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    
    ugcprint("[背包负重] 当前背包重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
    
    if currentWeight < MAX_WEIGHT_CAPACITY then
        ugcprint("[背包负重] ✅ 背包负重正常")
    end
    
    ugcprint("[背包负重] =======================")
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