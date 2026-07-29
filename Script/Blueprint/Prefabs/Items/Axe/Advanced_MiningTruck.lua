---@class Advanced_MiningTruck_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Advanced_MiningTruck = {} 
local VEHICLE_REPAIR_ID = 3

local function GetPlayerPawnFromItem(Item)
    if not Item then
        return nil
    end
    
    local Owner = nil
    local GetOwnerOk = pcall(function() Owner = Item:GetOwner() end)
    if GetOwnerOk and Owner then
        if Owner.SetMineCarMode then
            return Owner
        end
        
        local Parent = nil
        local GetParentOk = pcall(function() Parent = Owner:GetOwner() end)
        if GetParentOk and Parent and Parent.SetMineCarMode then
            return Parent
        end
        
        local Controller = nil
        local GetCtrlOk = pcall(function() Controller = Owner:GetController() end)
        if GetCtrlOk and Controller then
            if UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local Ok, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Controller)
                if Ok and Pawn and Pawn.SetMineCarMode then
                    return Pawn
                end
            end
        end
    end
    
    if Item.GetInstigator then
        local Instigator = nil
        local GetInstOk = pcall(function() Instigator = Item:GetInstigator() end)
        if GetInstOk and Instigator and Instigator.SetMineCarMode then
            return Instigator
        end
    end
    
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawns then
        local Ok, Pawns = pcall(UGCGameSystem.GetAllPlayerPawns)
        if Ok and Pawns and type(Pawns) == "table" and #Pawns > 0 then
            for _, Pawn in ipairs(Pawns) do
                if Pawn and Pawn.SetMineCarMode then
                    return Pawn
                end
            end
        end
    end
    
    if UE_GetPlayerPawn then
        local Pawn = UE_GetPlayerPawn()
        if Pawn and Pawn.SetMineCarMode then
            return Pawn
        end
    end
    
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

function Advanced_MiningTruck:CanUseV2()
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        ugcprint("[矿车物品] 高级采矿车已损坏，需要先维修")
        return false
    end
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        return false
    end
    return Advanced_MiningTruck.SuperClass.CanUseV2(self);
end

function Advanced_MiningTruck:OnUseV2()
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        ugcprint("[VehicleRepair] Advanced mining truck is broken; repair required")
        return
    end
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        ugcprint("[VehicleRepair] Mine car mode already active")
        return
    end

    Advanced_MiningTruck.SuperClass.OnUseV2(self);
    if RequestBeginTrip(Player) then
        return
    end

    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(true)
        UGCAttributeSystem.SetGameAttributeValue(Player, "AxeLevel", 5)
    end
end

function Advanced_MiningTruck:OnDisuseV2()
    Advanced_MiningTruck.SuperClass.OnDisuseV2(self);
    
    local Player = GetPlayerPawnFromItem(self)
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
    end
end

function Advanced_MiningTruck:OnEquip()
    Advanced_MiningTruck.SuperClass.OnEquip(self);
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        ugcprint("[VehicleRepair] Advanced mining truck equip blocked by repair state")
        return
    end
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        return
    end
    RequestBeginTrip(Player)
end

function Advanced_MiningTruck:OnUnEquip()
    Advanced_MiningTruck.SuperClass.OnUnEquip(self);
    
    local Player = GetPlayerPawnFromItem(self)
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
    end
end

return Advanced_MiningTruck
