---@class Basic_MiningVehicle_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Basic_MiningVehicle = {} 
local VEHICLE_REPAIR_ID = 1

local function GetPlayerPawnFromItem(Item)
    if not Item then
        ugcprint("[矿车物品] ❌ Item为空")
        return nil
    end
    
    local Owner = nil
    local GetOwnerOk = pcall(function() Owner = Item:GetOwner() end)
    if GetOwnerOk and Owner then
        ugcprint("[矿车物品] 直接获取持有者:", tostring(Owner))
        if Owner.SetMineCarMode then
            return Owner
        end
        
        local Parent = nil
        local GetParentOk = pcall(function() Parent = Owner:GetOwner() end)
        if GetParentOk and Parent and Parent.SetMineCarMode then
            ugcprint("[矿车物品] 通过父级获取PlayerPawn:", tostring(Parent))
            return Parent
        end
        
        local Controller = nil
        local GetCtrlOk = pcall(function() Controller = Owner:GetController() end)
        if GetCtrlOk and Controller then
            ugcprint("[矿车物品] 获取Controller:", tostring(Controller))
            if UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local Ok, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Controller)
                if Ok and Pawn and Pawn.SetMineCarMode then
                    ugcprint("[矿车物品] 通过Controller获取PlayerPawn:", tostring(Pawn))
                    return Pawn
                end
            end
        end
    end
    
    if Item.GetInstigator then
        local Instigator = nil
        local GetInstOk = pcall(function() Instigator = Item:GetInstigator() end)
        if GetInstOk and Instigator and Instigator.SetMineCarMode then
            ugcprint("[矿车物品] 通过GetInstigator获取PlayerPawn:", tostring(Instigator))
            return Instigator
        end
    end
    
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawns then
        local Ok, Pawns = pcall(UGCGameSystem.GetAllPlayerPawns)
        if Ok and Pawns and type(Pawns) == "table" and #Pawns > 0 then
            ugcprint("[矿车物品] 获取所有PlayerPawn数量:", #Pawns)
            for _, Pawn in ipairs(Pawns) do
                if Pawn and Pawn.SetMineCarMode then
                    ugcprint("[矿车物品] ✅ 找到PlayerPawn:", tostring(Pawn))
                    return Pawn
                end
            end
        end
    end
    
    if UE_GetPlayerPawn then
        local Pawn = UE_GetPlayerPawn()
        if Pawn and Pawn.SetMineCarMode then
            ugcprint("[矿车物品] ✅ 通过UE_GetPlayerPawn获取:", tostring(Pawn))
            return Pawn
        end
    end
    
    ugcprint("[矿车物品] ❌ 无法找到PlayerPawn")
    return nil
end

local function IsVehicleBroken(Player)
    if Player == nil or Player.GetController == nil then
        return false
    end
    local Ok, PC = pcall(function()
        return Player:GetController()
    end)
    if not Ok or PC == nil or PC.GetVehicleRepairStatus == nil then
        return false
    end
    local StatusOk, Status = pcall(function()
        return PC:GetVehicleRepairStatus(VEHICLE_REPAIR_ID)
    end)
    return StatusOk and type(Status) == "table" and (Status.bBroken == true or Status.bPendingCheck == true)
end

local function StopMineCarVisual(Player)
    if Player == nil then
        return
    end
    if Player.DoSetMineCarMode then
        Player:DoSetMineCarMode(false)
    elseif Player.SetMineCarMode then
        Player:SetMineCarMode(false)
    end
end

local function RequestBeginTrip(Player)
    if Player == nil or Player.GetController == nil then
        return false
    end
    local Ok, PC = pcall(function()
        return Player:GetController()
    end)
    if not Ok or PC == nil then
        return false
    end
    if UGCGameSystem.IsServer() and PC.Server_BeginMineCarTrip then
        PC:Server_BeginMineCarTrip(VEHICLE_REPAIR_ID)
        return true
    elseif PC.RequestBeginMineCarTrip then
        PC:RequestBeginMineCarTrip(VEHICLE_REPAIR_ID)
        return true
    end
    return false
end

function Basic_MiningVehicle:CanUseV2()
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        ugcprint("[矿车物品] 初级采矿车已损坏，需要先维修")
        return false
    end
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        ugcprint("[矿车物品] 矿车模式已激活，无法重复使用")
        return false
    end
    return Basic_MiningVehicle.SuperClass.CanUseV2(self);
end

function Basic_MiningVehicle:OnUseV2()
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        ugcprint("[VehicleRepair] Basic mining vehicle is broken; repair required")
        return
    end
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        ugcprint("[VehicleRepair] Mine car mode already active")
        return
    end

    Basic_MiningVehicle.SuperClass.OnUseV2(self);
    if RequestBeginTrip(Player) then
        return
    end

    ugcprint("[矿车物品] 使用矿车物品，玩家:", tostring(Player))
    
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
    
    local Player = GetPlayerPawnFromItem(self)
    ugcprint("[矿车物品] 取消使用矿车物品，玩家:", tostring(Player))
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
        ugcprint("[矿车物品] ❌ 矿车模式已取消")
    else
        ugcprint("[矿车物品] ❌ 无法获取玩家或SetMineCarMode不存在")
    end
end

function Basic_MiningVehicle:OnEquip()
    Basic_MiningVehicle.SuperClass.OnEquip(self);
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        ugcprint("[VehicleRepair] Basic mining vehicle equip blocked by repair state")
        return
    end
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        return
    end
    RequestBeginTrip(Player)
    
    ugcprint("[矿车物品] 装备矿车物品，变身由武器端处理")
end

function Basic_MiningVehicle:OnUnEquip()
    Basic_MiningVehicle.SuperClass.OnUnEquip(self);
    
    local Player = GetPlayerPawnFromItem(self)
    ugcprint("[矿车物品] 卸下矿车物品，玩家:", tostring(Player))
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
        ugcprint("[矿车物品] ❌ 卸下时取消矿车模式")
    else
        ugcprint("[矿车物品] ❌ 卸下时无法获取玩家")
    end
end

return Basic_MiningVehicle
