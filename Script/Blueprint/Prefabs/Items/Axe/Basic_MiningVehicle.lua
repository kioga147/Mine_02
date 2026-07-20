---@class Basic_MiningVehicle_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Basic_MiningVehicle = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function Basic_MiningVehicle:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return Basic_MiningVehicle.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function Basic_MiningVehicle:HandleDrop(InCount, Reason)
--    return Basic_MiningVehicle.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function Basic_MiningVehicle:HandleTake(TakeCount, TotalCount)
--    return Basic_MiningVehicle.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function Basic_MiningVehicle:HandleUse(Target, Reason)
--    return Basic_MiningVehicle.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function Basic_MiningVehicle:HandleDisuse(Reason)
--    return Basic_MiningVehicle.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function Basic_MiningVehicle:HandleTryDisuse(Reason)
--    return Basic_MiningVehicle.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function Basic_MiningVehicle:HandleEnable(bEnable)
--    Basic_MiningVehicle.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function Basic_MiningVehicle:HanldeCleared()
--    return Basic_MiningVehicle.SuperClass.HanldeCleared(self)
-- end
]]--

--[[V2背包事件]]--
--[[
--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function Basic_MiningVehicle:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return Basic_MiningVehicle.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function Basic_MiningVehicle:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     Basic_MiningVehicle.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function Basic_MiningVehicle:CanUseV2()
--     return Basic_MiningVehicle.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function Basic_MiningVehicle:OnUseV2()
--     Basic_MiningVehicle.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function Basic_MiningVehicle:OnDisuseV2()
--     Basic_MiningVehicle.SuperClass.OnDisuseV2(self);
-- end

--- func 其他物品能否附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Basic_MiningVehicle:CanAttachToSlot(SlotName, ItemDefineID)
--     return Basic_MiningVehicle.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当其他物品附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Basic_MiningVehicle:OnAttachToSlot(SlotName, ItemDefineID)
--     Basic_MiningVehicle.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当物品从此槽位移除(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Basic_MiningVehicle:OnDetachBySlot(SlotName, ItemDefineID)
--     Basic_MiningVehicle.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID);
-- end

--- func 能否Attach到Parent物品上, 如果Parent为空物品, 说明将被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
---@return bool 能否Attach
-- function Basic_MiningVehicle:CanAttach(ParentDefineID, SlotName)
--     return Basic_MiningVehicle.SuperClass.CanAttach(self, ParentDefineID, SlotName);
-- end

--- func 当Attach到Parent物品上, 如果Parent为空物品, 说明是被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function Basic_MiningVehicle:OnAttach(ParentDefineID, SlotName)
--     Basic_MiningVehicle.SuperClass.OnAttach(self, ParentDefineID, SlotName);
-- end

--- func 当从Parent物品上解除Attach, 如果Parent为空物品, 说明是从背包装备槽位解除装备(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function Basic_MiningVehicle:OnDetach(ParentDefineID, SlotName)
--     Basic_MiningVehicle.SuperClass.OnDetach(self, ParentDefineID, SlotName);
-- end

--- func 当物品被装备前，检查能否装备(服务端生效)
---@return bool 能否装备
-- function Basic_MiningVehicle:CanEquip()
--     return Basic_MiningVehicle.SuperClass.CanEquip(self);
-- end

--- func 当物品被装备回调(服务端生效)
-- function Basic_MiningVehicle:OnEquip()
--     Basic_MiningVehicle.SuperClass.OnEquip(self);
-- end

--- func 当物品被卸下回调(服务端生效)
-- function Basic_MiningVehicle:OnUnEquip()
--     Basic_MiningVehicle.SuperClass.OnUnEquip(self);
-- end

--- func 当物品在背包中被交换槽位前，检查能否交换(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
---@return 能否交换到新槽位
-- function Basic_MiningVehicle:CanSwapEquipSlot(OldSlotName, NewSlotName)
--     return Basic_MiningVehicle.SuperClass.CanSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end

--- func 当物品被交换到新装备槽位后回调(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
-- function Basic_MiningVehicle:OnSwapEquipSlot(OldSlotName, NewSlotName)
        Basic_MiningVehicle.SuperClass.OnSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end
]]--


return Basic_MiningVehicle