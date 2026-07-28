---@class Advanced_MiningTruck_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local Advanced_MiningTruck = {} 

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

function Advanced_MiningTruck:CanUseV2()
    local Player = GetPlayerPawnFromItem(self)
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        return false
    end
    return Advanced_MiningTruck.SuperClass.CanUseV2(self);
end

function Advanced_MiningTruck:OnUseV2()
    Advanced_MiningTruck.SuperClass.OnUseV2(self);
    
    local Player = GetPlayerPawnFromItem(self)
    
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
end

function Advanced_MiningTruck:OnUnEquip()
    Advanced_MiningTruck.SuperClass.OnUnEquip(self);
    
    local Player = GetPlayerPawnFromItem(self)
    
    if Player and Player.SetMineCarMode then
        Player:SetMineCarMode(false)
    end
end

return Advanced_MiningTruck
