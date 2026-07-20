---@class Sword_01_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local EXDiamond_Drill = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function EXDiamond_Drill:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return EXDiamond_Drill.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function EXDiamond_Drill:HandleDrop(InCount, Reason)
--    return EXDiamond_Drill.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function EXDiamond_Drill:HandleTake(TakeCount, TotalCount)
--    return EXDiamond_Drill.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function EXDiamond_Drill:HandleUse(Target, Reason)
--    return EXDiamond_Drill.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function EXDiamond_Drill:HandleDisuse(Reason)
--    return EXDiamond_Drill.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function EXDiamond_Drill:HandleTryDisuse(Reason)
--    return EXDiamond_Drill.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function EXDiamond_Drill:HandleEnable(bEnable)
--    EXDiamond_Drill.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function EXDiamond_Drill:HanldeCleared()
--    return EXDiamond_Drill.SuperClass.HanldeCleared(self)
-- end
]]--

--[[V2背包事件]]--
--[[
--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function EXDiamond_Drill:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return EXDiamond_Drill.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function EXDiamond_Drill:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     EXDiamond_Drill.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function EXDiamond_Drill:CanUseV2()
--     return EXDiamond_Drill.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function EXDiamond_Drill:OnUseV2()
--     EXDiamond_Drill.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function EXDiamond_Drill:OnDisuseV2()
--     EXDiamond_Drill.SuperClass.OnDisuseV2(self);
-- end

--- func 其他物品能否附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function EXDiamond_Drill:CanAttachToSlot(SlotName, ItemDefineID)
--     return EXDiamond_Drill.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当其他物品附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function EXDiamond_Drill:OnAttachToSlot(SlotName, ItemDefineID)
--     EXDiamond_Drill.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当物品从此槽位移除(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function EXDiamond_Drill:OnDetachBySlot(SlotName, ItemDefineID)
--     EXDiamond_Drill.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID);
-- end

--- func 能否Attach到Parent物品上, 如果Parent为空物品, 说明将被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
---@return bool 能否Attach
-- function EXDiamond_Drill:CanAttach(ParentDefineID, SlotName)
--     return EXDiamond_Drill.SuperClass.CanAttach(self, ParentDefineID, SlotName);
-- end

--- func 当Attach到Parent物品上, 如果Parent为空物品, 说明是被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function EXDiamond_Drill:OnAttach(ParentDefineID, SlotName)
--     EXDiamond_Drill.SuperClass.OnAttach(self, ParentDefineID, SlotName);
-- end

--- func 当从Parent物品上解除Attach, 如果Parent为空物品, 说明是从背包装备槽位解除装备(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function EXDiamond_Drill:OnDetach(ParentDefineID, SlotName)
--     EXDiamond_Drill.SuperClass.OnDetach(self, ParentDefineID, SlotName);
-- end

--- func 当物品被装备前，检查能否装备(服务端生效)
---@return bool 能否装备
-- function EXDiamond_Drill:CanEquip()
--     return EXDiamond_Drill.SuperClass.CanEquip(self);
-- end

--- func 当物品被装备回调(服务端生效)
-- function EXDiamond_Drill:OnEquip()
--     EXDiamond_Drill.SuperClass.OnEquip(self);
-- end

--- func 当物品被卸下回调(服务端生效)
-- function EXDiamond_Drill:OnUnEquip()
--     EXDiamond_Drill.SuperClass.OnUnEquip(self);
-- end

--- func 当物品在背包中被交换槽位前，检查能否交换(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
---@return 能否交换到新槽位
-- function EXDiamond_Drill:CanSwapEquipSlot(OldSlotName, NewSlotName)
--     return EXDiamond_Drill.SuperClass.CanSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end

--- func 当物品被交换到新装备槽位后回调(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
-- function EXDiamond_Drill:OnSwapEquipSlot(OldSlotName, NewSlotName)
        EXDiamond_Drill.SuperClass.OnSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end
]]--


return EXDiamond_Drill