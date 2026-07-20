---@class Sword_01_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Alloy_drill = {} 

--[[经典背包事件]]--
--[[
--- func 处理物品的拾取(服务端生效)
---@return bool @是否拾取该物品, 返回true才能拾取进背包
-- function Alloy_drill:HandlePickup(ItemContainer, PickupInfo, Reason)
--    return Alloy_drill.SuperClass.HandlePickup(self, ItemContainer, PickupInfo, Reason)
-- end

--- func 处理物品的丢弃(服务端生效)
---@return bool @是否丢弃该物品, 返回true才会丢弃
-- function Alloy_drill:HandleDrop(InCount, Reason)
--    return Alloy_drill.SuperClass.HandleDrop(self, InCount, Reason)
-- end

--- func 处理物品的取出(服务端生效)
---@return number @可取出物品数量
-- function Alloy_drill:HandleTake(TakeCount, TotalCount)
--    return Alloy_drill.SuperClass.HandleTake(self, TakeCount, TotalCount)
-- end

--- func 处理物品的使用(服务端生效)
---@return bool @使用是否成功
-- function Alloy_drill:HandleUse(Target, Reason)
--    return Alloy_drill.SuperClass.HandleUse(self, Target, Reason) 
-- end

--- func 处理物品的取消使用(服务端生效)
---@return bool @取消使用是否成功
-- function Alloy_drill:HandleDisuse(Reason)
--    return Alloy_drill.SuperClass.HandleDisuse(self, Reason) 
-- end

--- func 尝试取消使用物品，仅尝试(服务端生效)
---@return bool @物品能否取消使用
-- function Alloy_drill:HandleTryDisuse(Reason)
--    return Alloy_drill.SuperClass.HandleTryDisuse(self, Reason)
-- end

--- func 处理物品的有效性(服务端生效)
-- function Alloy_drill:HandleEnable(bEnable)
--    Alloy_drill.SuperClass.HandleEnable(self, bEnable)
-- end

--- func 处理物品的清除(服务端生效)
---@return bool @清除物品是否成功
-- function Alloy_drill:HanldeCleared()
--    return Alloy_drill.SuperClass.HanldeCleared(self)
-- end
]]--

--[[V2背包事件]]--
--[[
--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function Alloy_drill:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return Alloy_drill.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function Alloy_drill:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     Alloy_drill.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function Alloy_drill:CanUseV2()
--     return Alloy_drill.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function Alloy_drill:OnUseV2()
--     Alloy_drill.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function Alloy_drill:OnDisuseV2()
--     Alloy_drill.SuperClass.OnDisuseV2(self);
-- end

--- func 其他物品能否附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Alloy_drill:CanAttachToSlot(SlotName, ItemDefineID)
--     return Alloy_drill.SuperClass.CanAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当其他物品附加到此槽位(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Alloy_drill:OnAttachToSlot(SlotName, ItemDefineID)
--     Alloy_drill.SuperClass.OnAttachToSlot(self, SlotName, ItemDefineID);
-- end

--- func 当物品从此槽位移除(服务端生效)
---@param SlotName string 槽位名称
---@param ItemDefineID userdata 物品ID
-- function Alloy_drill:OnDetachBySlot(SlotName, ItemDefineID)
--     Alloy_drill.SuperClass.OnDetachBySlot(self, SlotName, ItemDefineID);
-- end

--- func 能否Attach到Parent物品上, 如果Parent为空物品, 说明将被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
---@return bool 能否Attach
-- function Alloy_drill:CanAttach(ParentDefineID, SlotName)
--     return Alloy_drill.SuperClass.CanAttach(self, ParentDefineID, SlotName);
-- end

--- func 当Attach到Parent物品上, 如果Parent为空物品, 说明是被Attach到背包装备槽位(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function Alloy_drill:OnAttach(ParentDefineID, SlotName)
--     Alloy_drill.SuperClass.OnAttach(self, ParentDefineID, SlotName);
-- end

--- func 当从Parent物品上解除Attach, 如果Parent为空物品, 说明是从背包装备槽位解除装备(服务端生效)
---@param ParentDefineID userdata 父物品ID
---@param SlotName string 槽位名称
-- function Alloy_drill:OnDetach(ParentDefineID, SlotName)
--     Alloy_drill.SuperClass.OnDetach(self, ParentDefineID, SlotName);
-- end

--- func 当物品被装备前，检查能否装备(服务端生效)
---@return bool 能否装备
-- function Alloy_drill:CanEquip()
--     return Alloy_drill.SuperClass.CanEquip(self);
-- end

--- func 当物品被装备回调(服务端生效)
-- function Alloy_drill:OnEquip()
--     Alloy_drill.SuperClass.OnEquip(self);
-- end

--- func 当物品被卸下回调(服务端生效)
-- function Alloy_drill:OnUnEquip()
--     Alloy_drill.SuperClass.OnUnEquip(self);
-- end

--- func 当物品在背包中被交换槽位前，检查能否交换(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
---@return 能否交换到新槽位
-- function Alloy_drill:CanSwapEquipSlot(OldSlotName, NewSlotName)
--     return Alloy_drill.SuperClass.CanSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end

--- func 当物品被交换到新装备槽位后回调(服务端生效)
---@param OldSlotName string 旧槽位名称
---@param NewSlotName string 新槽位名称
-- function Alloy_drill:OnSwapEquipSlot(OldSlotName, NewSlotName)
        Alloy_drill.SuperClass.OnSwapEquipSlot(self, OldSlotName, NewSlotName);
-- end
]]--


return Alloy_drill