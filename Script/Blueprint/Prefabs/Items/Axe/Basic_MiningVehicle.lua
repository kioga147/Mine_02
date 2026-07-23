---@class Basic_MiningVehicle_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Basic_MiningVehicle = {} 

function Basic_MiningVehicle:CanUseV2()
    local Player = self:GetOwner()
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        ugcprint("[矿车物品] 矿车模式已激活，无法重复使用")
        return false
    end
    return Basic_MiningVehicle.SuperClass.CanUseV2(self);
end

function Basic_MiningVehicle:OnUseV2()
    Basic_MiningVehicle.SuperClass.OnUseV2(self);
    
    local Player = self:GetOwner()
    ugcprint("[矿车物品] 使用矿车物品，持有者:", tostring(Player))
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(true)
        UGCAttributeSystem.SetGameAttributeValue(Player, "AxeLevel", 2)
        ugcprint("[矿车物品] ✅ 矿车模式已激活")
    else
        ugcprint("[矿车物品] ❌ 无法获取玩家或SetMineCarMode不存在")
    end
end

function Basic_MiningVehicle:OnDisuseV2()
    Basic_MiningVehicle.SuperClass.OnDisuseV2(self);
    
    local Player = self:GetOwner()
    ugcprint("[矿车物品] 取消使用矿车物品，持有者:", tostring(Player))
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
        ugcprint("[矿车物品] ❌ 矿车模式已取消")
    else
        ugcprint("[矿车物品] ❌ 无法获取玩家或SetMineCarMode不存在")
    end
end

function Basic_MiningVehicle:OnEquip()
    Basic_MiningVehicle.SuperClass.OnEquip(self);
    
    local Player = self:GetOwner()
    ugcprint("[矿车物品] 装备矿车物品，持有者:", tostring(Player))
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(true)
        UGCAttributeSystem.SetGameAttributeValue(Player, "AxeLevel", 2)
        ugcprint("[矿车物品] ✅ 装备时激活矿车模式")
    end
end

function Basic_MiningVehicle:OnUnEquip()
    Basic_MiningVehicle.SuperClass.OnUnEquip(self);
    
    local Player = self:GetOwner()
    ugcprint("[矿车物品] 卸下矿车物品，持有者:", tostring(Player))
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
        ugcprint("[矿车物品] ❌ 卸下时取消矿车模式")
    end
end

return Basic_MiningVehicle