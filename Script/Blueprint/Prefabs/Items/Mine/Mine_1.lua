---@class Mine_01_C:Template_ItemHandle_C
--Edit Below--
local Mine_1 = {} 

--[[V2背包事件]]--
--[[
--- func 能否创建物品Handle(服务端生效)
---@return bool @是否允许创建物品Handle, 若不允许，物品也将创建失败
-- function Mine_1:CanCreateItemHandleV2()
--     return Mine_1.SuperClass.CanCreateItemHandleV2(self);
-- end

--- func 当创建物品Handle后回调，可重载并自定义(服务端生效)
--  function Mine_1:OnCreateItemHandleV2()
--     Mine_1.SuperClass.OnCreateItemHandleV2(self);
--  end

--- func 能否销毁物品Handle，可重载并自定义(服务端生效)
---@return bool 是否允许销毁Handle, 若不允许，物品移除或丢弃也可能失败
-- function Mine_1:CanDestoryItemHandleV2()
--     return Mine_1.SuperClass.CanDestoryItemHandleV2(self);
-- end

--- func 销毁物品Handle前回调，可重载并自定义(服务端生效)
-- function Mine_1:OnDestoryItemHandleV2()
--     Mine_1.SuperClass.OnDestoryItemHandleV2(self);
-- end

--- func 能否更新此物品实例，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
---@return 是否允许物品数量更新，若不允许，物品添加或移除操作可能失败
-- function Mine_1:CanUpdateItemCountV2(NewItemCount, OldItemCount)
--     return Mine_1.SuperClass.CanUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 物品数量更新后回调，可重载并自定义(服务端生效)
---@param NewItemCount number 新物品数量
---@param OldItemCount number 旧物品数量
-- function Mine_1:OnUpdateItemCountV2(NewItemCount, OldItemCount)
--     Mine_1.SuperClass.OnUpdateItemCountV2(self, NewItemCount, OldItemCount);
-- end

--- func 能否使用物品，可重载并自定义(服务端生效)
---@return 物品是否能够被使用
-- function Mine_1:CanUseV2()
--     return Mine_1.SuperClass.CanUseV2(self);
-- end

--- func 当物品被使用回调，可重载并自定义(服务端生效)
-- function Mine_1:OnUseV2()
--     Mine_1.SuperClass.OnUseV2(self);
-- end

--- func 当物品被取消使用，与UseItem对应，用于清理状态，应当支持多次调用，不产生额外副作用，移除物品时自动调用，可重载并自定义(服务端生效)
-- function Mine_1:OnDisuseV2()
--     Mine_1.SuperClass.OnDisuseV2(self);
-- end

--- func 当物品开始使用时回调，可重载并自定义(服务端生效)
-- function Mine_1:UGC_OnStartUse()
--     Mine_1.SuperClass.UGC_OnStartUse(self)
-- end

--- func 当物品停止使用时回调，可重载并自定义(服务端生效)，在OnUseV2后调用
-- function Mine_1:UGC_OnStopUse(Reason)
    Mine_1.SuperClass.UGC_OnStopUse(self, Reason)
-- end
]]--

return Mine_1