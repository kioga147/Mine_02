---@class Advanced_MiningTruck_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Advanced_MiningTruck = {}
local VEHICLE_REPAIR_ID = 3

local function GetPlayerPawnFromWeapon(Weapon)
    local Owner = Weapon:GetOwner()
    
    if Owner then
        if Owner.SetMineCarMode then
            return Owner
        end
        
        if Owner.GetOwner then
            local Parent = Owner:GetOwner()
            if Parent and Parent.SetMineCarMode then
                return Parent
            end
        end
        
        if Owner.GetController then
            local Controller = Owner:GetController()
            if Controller and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local Ok, PlayerPawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Controller)
                if Ok and PlayerPawn and PlayerPawn.SetMineCarMode then
                    return PlayerPawn
                end
            end
        end
    end
    
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawns then
        local Pawns = UGCGameSystem.GetAllPlayerPawns()
        for _, Pawn in ipairs(Pawns) do
            if Pawn and Pawn.SetMineCarMode then
                return Pawn
            end
        end
    end
    
    return nil
end

local function IsVehicleBroken(PlayerPawn)
    if PlayerPawn == nil or PlayerPawn.GetController == nil then
        return false
    end
    local Ok, PC = pcall(function()
        return PlayerPawn:GetController()
    end)
    if not Ok or PC == nil or PC.GetVehicleRepairStatus == nil then
        return false
    end
    local StatusOk, Status = pcall(function()
        return PC:GetVehicleRepairStatus(VEHICLE_REPAIR_ID)
    end)
    return StatusOk and type(Status) == "table" and (Status.bBroken == true or Status.bPendingCheck == true)
end

local function StopMineCarVisual(PlayerPawn)
    if PlayerPawn == nil then
        return
    end
    if PlayerPawn.DoSetMineCarMode then
        PlayerPawn:DoSetMineCarMode(false)
    elseif PlayerPawn.SetMineCarMode then
        PlayerPawn:SetMineCarMode(false)
    end
end

local function GetControllerFromPawn(PlayerPawn)
    if PlayerPawn == nil or PlayerPawn.GetController == nil then
        return nil
    end
    local Ok, PC = pcall(function()
        return PlayerPawn:GetController()
    end)
    if Ok then
        return PC
    end
    return nil
end

local function RequestBeginTrip(PlayerPawn)
    local PC = GetControllerFromPawn(PlayerPawn)
    if PC == nil then
        return
    end
    if UGCGameSystem.IsServer() and PC.Server_BeginMineCarTrip then
        PC:Server_BeginMineCarTrip(VEHICLE_REPAIR_ID)
    elseif PC.RequestBeginMineCarTrip then
        PC:RequestBeginMineCarTrip(VEHICLE_REPAIR_ID)
    end
end

local function RequestEndTrip(PlayerPawn)
    local PC = GetControllerFromPawn(PlayerPawn)
    if PC == nil then
        return
    end
    if UGCGameSystem.IsServer() and PC.Server_EndMineCarTrip then
        PC:Server_EndMineCarTrip(VEHICLE_REPAIR_ID)
    elseif PC.RequestEndMineCarTrip then
        PC:RequestEndMineCarTrip(VEHICLE_REPAIR_ID)
    end
end

local function IsCurrentWeaponMineCar(PlayerPawn)
    if PlayerPawn == nil or UGCWeaponManagerSystem == nil or UGCWeaponManagerSystem.GetCurrentWeapon == nil then
        return false
    end
    local Ok, Weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, PlayerPawn)
    if not Ok or Weapon == nil then
        return false
    end
    local Name = ""
    if Weapon.GetName then
        local NameOk, Result = pcall(function()
            return Weapon:GetName()
        end)
        if NameOk and Result ~= nil then
            Name = tostring(Result)
        end
    end
    return string.find(Name, "MiningVehicle") ~= nil or string.find(Name, "MiningTruck") ~= nil
end

function Advanced_MiningTruck:ReceiveBeginPlay()
    Advanced_MiningTruck.SuperClass.ReceiveBeginPlay(self)
    
    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    if PlayerPawn then
        if IsVehicleBroken(PlayerPawn) then
            StopMineCarVisual(PlayerPawn)
            ugcprint("[MineCarTrip] advanced vehicle blocked by repair state")
            return
        end
        RequestBeginTrip(PlayerPawn)
        return
    end
    
    if PlayerPawn and PlayerPawn.SetMineCarMode then
        if IsVehicleBroken(PlayerPawn) then
            ugcprint("[矿车武器] 高级采矿车已损坏，阻止激活矿车模式")
            return
        end
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, "AxeLevel", 5)
        
        if PlayerPawn.IsMineCarMode and PlayerPawn:IsMineCarMode() then
            return
        end
        
        PlayerPawn:SetMineCarMode(true)
        
        if UGCTimerManagerSystem and UGCTimerManagerSystem.SetTimer then
            UGCTimerManagerSystem.SetTimer(function()
                self:AddMineCarSkill(PlayerPawn)
            end, 1.5, false)
        else
            self:AddMineCarSkill(PlayerPawn)
        end
    end
end

function Advanced_MiningTruck:AddMineCarSkill(PlayerPawn)
    local SkillPaths = {
        "/Mine_02/Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C",
        "/Game/Mine_02/Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C",
        UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C')
    }
    
    local SkillClass = nil
    for _, Path in ipairs(SkillPaths) do
        SkillClass = UGCObjectUtility.LoadClass(Path)
        if SkillClass then
            break
        end
    end
    
    if SkillClass then
        local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn, SkillClass)
        
        if #ExistSkills == 0 then
            local Skill = UGCPersistEffectSystem.AddSkillByClass(PlayerPawn, SkillClass, -1)
            if not Skill then
                ugcprint("[矿车武器] 高级采矿车添加技能失败")
            end
        else
            local Skill = ExistSkills[1]
            if Skill then
                ugcprint("[矿车武器] 高级采矿车技能已存在")
            end
        end
    end
end

function Advanced_MiningTruck:ReceiveEndPlay()
    Advanced_MiningTruck.SuperClass.ReceiveEndPlay(self) 
    
    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    if PlayerPawn then
        local function EndTripIfSwitchedAway()
            if PlayerPawn.IsMineCarMode and PlayerPawn:IsMineCarMode() and not IsCurrentWeaponMineCar(PlayerPawn) then
                ugcprint("[MineCarTrip] advanced weapon EndPlay confirmed switch away; ending trip")
                RequestEndTrip(PlayerPawn)
            else
                ugcprint("[MineCarTrip] advanced weapon EndPlay kept trip; current weapon is still mine car")
            end
        end
        if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
            UGCTimerUtility.CreateLuaTimer(0.3, EndTripIfSwitchedAway, false)
        else
            EndTripIfSwitchedAway()
        end
        return
    end
    
    if PlayerPawn and PlayerPawn.SetMineCarMode then
        PlayerPawn:SetMineCarMode(false)
    end
end

function Advanced_MiningTruck:GetReplicatedProperties()
    return
end

function Advanced_MiningTruck:GetAvailableServerRPCs()
    return
end

return Advanced_MiningTruck
