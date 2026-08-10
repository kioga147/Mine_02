---@class Advanced_MiningTruck_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Advanced_MiningTruck = {}
local VEHICLE_REPAIR_ID = 3
local MELEE_WEAPON_SLOT = 4

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

local function AttachCurrentWeaponToBack(PlayerPawn)
    if PlayerPawn and UGCWeaponManagerSystem and UGCWeaponManagerSystem.CurrentWeaponAttachToBack then
        pcall(UGCWeaponManagerSystem.CurrentWeaponAttachToBack, PlayerPawn)
    end
end

local function NotifyRepairRequired(PlayerPawn)
    local Msg = "采矿车无法使用，请回维修处检查/维修后再使用"
    if UGCWidgetManagerSystem and UGCWidgetManagerSystem.ShowTipsUIWithPC then
        local PC = nil
        if PlayerPawn and PlayerPawn.GetController then
            pcall(function()
                PC = PlayerPawn:GetController()
            end)
        end
        pcall(function()
            UGCWidgetManagerSystem.ShowTipsUIWithPC(Msg, PC)
        end)
    end
    ugcprint("[VehicleRepair] " .. Msg)
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

local function GetWeaponName(Weapon)
    local Name = ""
    if Weapon and Weapon.GetName then
        local NameOk, Result = pcall(function()
            return Weapon:GetName()
        end)
        if NameOk and Result ~= nil then
            Name = tostring(Result)
        end
    end
    return Name
end

local function IsWeaponMineCarByName(Weapon)
    local Name = GetWeaponName(Weapon)
    return string.find(Name, "MiningVehicle") ~= nil or string.find(Name, "MiningTruck") ~= nil
end

local function IsCurrentWeaponMineCar(PlayerPawn)
    if PlayerPawn == nil or UGCWeaponManagerSystem == nil or UGCWeaponManagerSystem.GetCurrentWeapon == nil then
        return false
    end
    local Ok, Weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, PlayerPawn)
    if not Ok or Weapon == nil then
        return false
    end
    return IsWeaponMineCarByName(Weapon)
end

local function IsMineCarInHand(PlayerPawn)
    if PlayerPawn == nil or UGCWeaponManagerSystem == nil then
        return false
    end

    -- 优先用当前手持槽判断，切换完成后槽位就是 SWPS_MeleeWeapon
    if UGCWeaponManagerSystem.GetCurrentWeaponSlot then
        local Ok, Slot = pcall(UGCWeaponManagerSystem.GetCurrentWeaponSlot, PlayerPawn)
        local SlotNum = Ok and math.floor(tonumber(Slot) or -1) or -1
        local SlotStr = Ok and tostring(Slot or "") or ""
        if SlotNum == MELEE_WEAPON_SLOT or string.find(SlotStr, "Melee") ~= nil then
            if UGCWeaponManagerSystem.GetWeaponBySlot then
                local OkW, SlotWeapon = pcall(UGCWeaponManagerSystem.GetWeaponBySlot, PlayerPawn, MELEE_WEAPON_SLOT)
                if OkW and SlotWeapon then
                    return IsWeaponMineCarByName(SlotWeapon)
                end
            end
            return IsCurrentWeaponMineCar(PlayerPawn)
        end
    end

    return IsCurrentWeaponMineCar(PlayerPawn)
end

function Advanced_MiningTruck:ReceiveBeginPlay()
    Advanced_MiningTruck.SuperClass.ReceiveBeginPlay(self)

    ugcprint("[矿车武器] ==================== 高级采矿车武器开始 ====================")

    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    if not PlayerPawn then
        ugcprint("[矿车武器] ❌ 无法获取玩家Pawn")
        return
    end

    if IsVehicleBroken(PlayerPawn) then
        StopMineCarVisual(PlayerPawn)
        AttachCurrentWeaponToBack(PlayerPawn)
        NotifyRepairRequired(PlayerPawn)
        ugcprint("[矿车武器] 高级采矿车已损坏，阻止激活矿车模式")
        return
    end

    -- 变身由物品OnEquip在服务器端触发，武器端只负责补技能
    if PlayerPawn.IsMineCarMode and PlayerPawn:IsMineCarMode() then
        self:AddMineCarSkill(PlayerPawn)
    else
        ugcprint("[矿车武器] 等待物品OnEquip触发变身")
    end

    ugcprint("[矿车武器] ==================== 高级采矿车武器结束 ====================")
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

    ugcprint("[矿车武器] ==================== 高级采矿车武器销毁 ====================")

    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    if not PlayerPawn then
        ugcprint("[矿车武器] ❌ 无法获取玩家Pawn")
        return
    end

    -- 武器销毁时清理技能（DoSetMineCarMode也会清理，但双重保险）
    if UGCPersistEffectSystem then
        local SkillPaths = {
            "Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C"
        }
        for _, SkillPath in ipairs(SkillPaths) do
            local FullPath = UGCGameSystem.GetUGCResourcesFullPath(SkillPath)
            local SkillClass = UGCObjectUtility.LoadClass(FullPath)
            if SkillClass then
                local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn, SkillClass)
                if ExistSkills and #ExistSkills > 0 then
                    for _, SkillInst in ipairs(ExistSkills) do
                        if UE.IsValid(SkillInst) then
                            UGCPersistEffectSystem.RemoveSkillInstance(PlayerPawn, SkillInst)
                            ugcprint("[矿车武器] ✅ 已移除MaxVehicle技能实例")
                        end
                    end
                end
            end
        end
    end

    -- 武器销毁不再直接取消矿车模式，由物品OnUnEquip通过服务器处理
    local function EndTripIfSwitchedAway()
        if PlayerPawn.IsMineCarMode and PlayerPawn:IsMineCarMode() and not IsMineCarInHand(PlayerPawn) then
            ugcprint("[MineCarTrip] 切换武器离开矿车，请求结束行程")
            RequestEndTrip(PlayerPawn)
        else
            ugcprint("[MineCarTrip] 矿车武器销毁，等待服务器处理")
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.3, EndTripIfSwitchedAway, false)
    else
        EndTripIfSwitchedAway()
    end

    ugcprint("[矿车武器] ==================== 高级采矿车武器销毁结束 ====================")
end

function Advanced_MiningTruck:GetReplicatedProperties()
    return
end

function Advanced_MiningTruck:GetAvailableServerRPCs()
    return
end

return Advanced_MiningTruck
