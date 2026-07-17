---@class BP_BackpackComponentV2_Custom_C:BP_BackpackComponentV2_C
--Edit Below--
local BP_BackpackComponentV2_Custom = {} 

local MAX_WEIGHT_CAPACITY = 100

local function GetItemWeight(DefineID)
    local weight = 1
    
    local itemID = UGCItemSystem.GetItemID(DefineID)
    ugcprint("[背包负重] GetItemWeight - DefineID:", DefineID, "ItemID:", itemID)
    
    local itemHandle = UGCItemSystemV2.GetConfigItemHandle(itemID)
    if itemHandle then
        ugcprint("[背包负重] itemHandle存在, 类型:", type(itemHandle))
        if itemHandle.UnitWeightConfig then
            weight = itemHandle.UnitWeightConfig
            ugcprint("[背包负重] 使用UnitWeightConfig:", weight)
        elseif itemHandle.ItemWeight then
            weight = itemHandle.ItemWeight
            ugcprint("[背包负重] 使用ItemWeight:", weight)
        elseif itemHandle.Weight then
            weight = itemHandle.Weight
            ugcprint("[背包负重] 使用Weight:", weight)
        else
            ugcprint("[背包负重] itemHandle无重量属性, 使用默认值1")
            for k, v in pairs(itemHandle) do
                ugcprint("[背包负重] itemHandle属性:", k, "=", v)
            end
        end
    else
        ugcprint("[背包负重] itemHandle不存在, 使用默认值1")
    end
    
    return tonumber(weight) or 1
end

local function GetCurrentTotalWeight(Player)
    local totalWeight = 0
    
    local backpackComponent = UGCBackpackSystemV2.GetBackpackComponentV2(Player)
    if backpackComponent then
        ugcprint("[背包负重] 获取背包组件成功")
        local allItemDefineIDs = backpackComponent:GetAllItemDefineIDsV2()
        if allItemDefineIDs then
            ugcprint("[背包负重] 背包物品数量:", #allItemDefineIDs)
            for _, defineID in ipairs(allItemDefineIDs) do
                local count = backpackComponent:GetItemCountByDefineIDV2(defineID)
                local weight = GetItemWeight(defineID)
                ugcprint("[背包负重] 物品:", defineID, "数量:", count, "单重:", weight, "总重:", count * weight)
                totalWeight = totalWeight + weight * count
            end
        else
            ugcprint("[背包负重] allItemDefineIDs为空")
        end
    else
        ugcprint("[背包负重] 获取背包组件失败")
    end
    
    ugcprint("[背包负重] 当前总重量:", totalWeight, "kg")
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
    ugcprint("[背包负重] CanAddItemV2 被调用 - ItemID:", ItemID, "Count:", Count)
    local Player = self:GetOwner()
    local remainingWeight = GetRemainingWeight(Player)
    local itemWeight = 1
    
    local itemHandle = UGCItemSystemV2.GetConfigItemHandle(ItemID)
    if itemHandle then
        if itemHandle.UnitWeightConfig then
            itemWeight = itemHandle.UnitWeightConfig
        elseif itemHandle.ItemWeight then
            itemWeight = itemHandle.ItemWeight
        elseif itemHandle.Weight then
            itemWeight = itemHandle.Weight
        end
    end
    
    local maxCount = math.floor(remainingWeight / itemWeight)
    local result = math.min(Count, maxCount)
    ugcprint("[背包负重] CanAddItemV2 结果 - 物品重量:", itemWeight, "剩余负重:", remainingWeight, "允许数量:", result)
    return result
end

---func 能否添加物品进背包(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
---@return number 允许添加物品数量
function BP_BackpackComponentV2_Custom:CanAddItemByDefineIDV2(DefineID, Count)
    ugcprint("[背包负重] CanAddItemByDefineIDV2 被调用 - DefineID:", DefineID, "Count:", Count)
    local Player = self:GetOwner()
    local remainingWeight = GetRemainingWeight(Player)
    local itemWeight = GetItemWeight(DefineID)
    local maxCount = math.floor(remainingWeight / itemWeight)
    local result = math.min(Count, maxCount)
    ugcprint("[背包负重] CanAddItemByDefineIDV2 结果 - 物品重量:", itemWeight, "剩余负重:", remainingWeight, "允许数量:", result)
    return result
end

---func 当背包添加物品后回调(服务端调用)
---@param DefineID userdata 物品DefineID
---@param Count number 物品数量
function BP_BackpackComponentV2_Custom:OnAddItemV2(DefineID, Count)
    ugcprint("[背包负重] ====== 物品添加成功 ======")
    ugcprint("[背包负重] OnAddItemV2 - DefineID:", DefineID, "Count:", Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnAddItemV2(self, DefineID, Count)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    ugcprint("[背包负重] 添加后总重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
    
    if currentWeight >= MAX_WEIGHT_CAPACITY then
        ugcprint("[背包负重] 警告: 背包已超重！速度将降低！")
    else
        ugcprint("[背包负重] 背包负重正常")
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
    ugcprint("[背包负重] ====== 物品移除 ======")
    ugcprint("[背包负重] OnRemoveItemV2 - DefineID:", ItemDefineID, "Count:", Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnRemoveItemV2(self, ItemDefineID, Count)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    ugcprint("[背包负重] 移除后总重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
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
    ugcprint("[背包负重] OnDropItemV2 - DefineID:", ItemDefineID, "Count:", Count)
    BP_BackpackComponentV2_Custom.SuperClass.OnDropItemV2(self, ItemDefineID, Count)
    
    local Player = self:GetOwner()
    local currentWeight = GetCurrentTotalWeight(Player)
    ugcprint("[背包负重] 丢弃后总重量:", currentWeight, "kg /", MAX_WEIGHT_CAPACITY, "kg")
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