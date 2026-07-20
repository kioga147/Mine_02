---@class Advanced_MiningTruck_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Advanced_MiningTruck = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function Advanced_MiningTruck:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return Advanced_MiningTruck.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function Advanced_MiningTruck:HandleDrop(InCount, Reason)
--    return Advanced_MiningTruck.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function Advanced_MiningTruck:HandleTake(TakeCount, TotalCount)
--    return Advanced_MiningTruck.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function Advanced_MiningTruck:HandleUse(Target, Reason)
--    return Advanced_MiningTruck.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function Advanced_MiningTruck:HandleDisuse(Reason)
--    return Advanced_MiningTruck.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function Advanced_MiningTruck:HandleTryDisuse(Reason)
--    return Advanced_MiningTruck.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function Advanced_MiningTruck:HandleEnable(bEnable)
--    Advanced_MiningTruck.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function Advanced_MiningTruck:HanldeCleared()
--    return Advanced_MiningTruck.SuperClass.HanldeCleared(self)
-- end
]]--

--[[V2背包事件]]--
--[[
--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function Advanced_MiningTruck:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return Advanced_MiningTruck.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function Advanced_MiningTruck:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     Advanced_MiningTruck.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function Advanced_MiningTruck:CanUseV2()
--     return Advanced_MiningTruck.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function Advanced_MiningTruck:OnUseV2()
--     Advanced_MiningTruck.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function Advanced_MiningTruck:OnDisuseV2()
--     Advanced_MiningTruck.SuperClass.OnDisuseV2(self);
-- end

--- func 其他物品能否附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Advanced_MiningTruck:CanAttachToSlot(SlotName, ItemDefineID)
--     return Advanced_MiningTruck.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当其他物品附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Advanced_MiningTruck:OnAttachToSlot(SlotName, ItemDefineID)
--     Advanced_MiningTruck.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当物品从此槽位移除(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Advanced_MiningTruck:OnDetachBySlot(SlotName, ItemDefineID)
--     Advanced_MiningTruck.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID);
-- end

--- func 能否Attach到Parent物品上, 如果Parent为空物品, 说明将被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
---@return bool 能否Attach
-- function Advanced_MiningTruck:CanAttach(ParentDefineID, SlotName)
--     return Advanced_MiningTruck.SuperClass.CanAttach(self, ParentDefineID, SlotName);
-- end

--- func 当Attach到Parent物品上, 如果Parent为空物品, 说明是被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function Advanced_MiningTruck:OnAttach(ParentDefineID, SlotName)
--     Advanced_MiningTruck.SuperClass.OnAttach(self, ParentDefineID, SlotName);
-- end

--- func 当从Parent物品上解除Attach, 如果Parent为空物品, 说明是从背包装备槽位解除装备(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function Advanced_MiningTruck:OnDetach(ParentDefineID, SlotName)
--     Advanced_MiningTruck.SuperClass.OnDetach(self, ParentDefineID, SlotName);
-- end

--- func 当物品被装备前，检查能否装备(服务端生效)
---@return bool 能否装备
-- function Advanced_MiningTruck:CanEquip()
--     return Advanced_MiningTruck.SuperClass.CanEquip(self);
-- end

--- func 当物品被装备回调(服务端生效)
-- function Advanced_MiningTruck:OnEquip()
--     Advanced_MiningTruck.SuperClass.OnEquip(self);
-- end

--- func 当物品被卸下回调(服务端生效)
-- function Advanced_MiningTruck:OnUnEquip()
--     Advanced_MiningTruck.SuperClass.OnUnEquip(self);
-- end

--- func 当物品在背包中被交换槽位前，检查能否交换(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
---@return 能否交换到新槽位
-- function Advanced_MiningTruck:CanSwapEquipSlot(OldSlotName, NewSlotName)
--     return Advanced_MiningTruck.SuperClass.CanSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end

--- func 当物品被交换到新装备槽位后回调(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
-- function Advanced_MiningTruck:OnSwapEquipSlot(OldSlotName, NewSlotName)
        Advanced_MiningTruck.SuperClass.OnSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end
]]--


return Advanced_MiningTruck