---@class Intermediate_MiningTruck_C:Template_Melee_TangDao_Handle_C
--Edit Below--
local MidMineCar = {}
local VEHICLE_REPAIR_ID = 2

local VehicleRepairConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.VehicleRepairConfig")
    end)
    if Ok and type(Mod) == "table" then
        VehicleRepairConfig = Mod
    end
end

local function GetMineCarConfig()
    if VehicleRepairConfig and VehicleRepairConfig.GetVehicle then
        local Vehicle = VehicleRepairConfig.GetVehicle(VEHICLE_REPAIR_ID)
        return Vehicle
    end
    return nil
end

local function GetPlayerPawnFromItem(Item)
    if not Item then
        return nil
    end

    if UGCItemSystemV2 and UGCItemSystemV2.GetOwnBackpackComponent then
        local Ok, Backpack = pcall(UGCItemSystemV2.GetOwnBackpackComponent, Item)
        if Ok and Backpack and Backpack.GetOwner then
            local OkPc, PC = pcall(Backpack.GetOwner, Backpack)
            if OkPc and PC and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local OkPawn, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, PC)
                if OkPawn and Pawn and Pawn.SetMineCarMode then
                    ugcprint("[矿车物品] ✅ 通过官方背包组件获取PlayerPawn")
                    return Pawn
                end
            end
        end
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

local function ApplyMineCarTransform(Player)
    if Player == nil or UGCGameSystem == nil or not UGCGameSystem.IsServer() then
        return
    end
    local Vehicle = GetMineCarConfig()
    if Vehicle == nil then
        ugcprint("[矿车物品] ❌ 未找到矿车配置")
        return
    end
    Player._mineCarAxeLevel = math.floor(tonumber(Vehicle.MineLevel) or 0)
    if Vehicle.SkillPath then
        Player._mineCarSkillPath = Vehicle.SkillPath
    end
    Player._mineCarEquipTime = os.clock()
    ugcprint("[矿车物品] 装备完成，调用变身系统添加矿车Buff")
    local function DoTransform()
        if Player.SetMineCarMode then
            Player:SetMineCarMode(true)
        elseif Player.DoSetMineCarMode then
            Player:DoSetMineCarMode(true)
        end
    end
    if Player.EnsureMineCarInHand then
        Player:EnsureMineCarInHand(DoTransform)
    else
        DoTransform()
    end
end

local function ScheduleApplyMineCarTransform(Player)
    if Player == nil then
        return
    end
    local function DoApply()
        if Player and UE.IsValid(Player) and Player._mineCarItemEquipped == VEHICLE_REPAIR_ID then
            ApplyMineCarTransform(Player)
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.05, DoApply, false)
    else
        DoApply()
    end
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

local function NotifyRepairRequired(Player)
    local Msg = "采矿车无法使用，请回维修处检查/维修后再使用"
    if UGCWidgetManagerSystem and UGCWidgetManagerSystem.ShowTipsUIWithPC then
        local PC = nil
        if Player and Player.GetController then
            pcall(function()
                PC = Player:GetController()
            end)
        end
        pcall(function()
            UGCWidgetManagerSystem.ShowTipsUIWithPC(Msg, PC)
        end)
    end
    ugcprint("[VehicleRepair] " .. Msg)
end

function MidMineCar:CanUseV2()
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        NotifyRepairRequired(Player)
        ugcprint("[矿车物品] 中级采矿车已损坏，需要先维修")
        return false
    end
    -- 不再阻止矿车模式中的使用（点击只是挥舞动作）
    return MidMineCar.SuperClass.CanUseV2(self);
end

function MidMineCar:OnUseV2()
    -- 点击只执行普通物品使用，变身由装备后的OnEquip触发
    ugcprint("[矿车物品] 点击使用")
    MidMineCar.SuperClass.OnUseV2(self)
end

function MidMineCar:OnDisuseV2()
    MidMineCar.SuperClass.OnDisuseV2(self);

    local Player = GetPlayerPawnFromItem(self)
    ugcprint("[矿车物品] 取消使用矿车物品，玩家:", tostring(Player))

    -- 取消使用不再取消矿车模式，只清理技能
    if Player and UGCPersistEffectSystem then
        local FullPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/Blueprint/Prefabs/Skills/MidVehicle.MidVehicle_C")
        local SkillClass = UGCObjectUtility.LoadClass(FullPath)
        if SkillClass then
            local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(Player, SkillClass)
            if ExistSkills and #ExistSkills > 0 then
                for _, SkillInst in ipairs(ExistSkills) do
                    if UE.IsValid(SkillInst) then
                        UGCPersistEffectSystem.RemoveSkillInstance(Player, SkillInst)
                        ugcprint("[矿车物品] ✅ 已移除MidVehicle技能实例")
                    end
                end
            end
        end
    end
end

function MidMineCar:CanEquip()
    local Player = GetPlayerPawnFromItem(self)
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        NotifyRepairRequired(Player)
        ugcprint("[VehicleRepair] Intermediate mining truck CanEquip blocked by repair state")
        return false
    end
    if MidMineCar.SuperClass.CanEquip then
        return MidMineCar.SuperClass.CanEquip(self)
    end
    return true
end

function MidMineCar:OnEquip()
    MidMineCar.SuperClass.OnEquip(self);

    local Player = GetPlayerPawnFromItem(self)
    ugcprint("[矿车物品] 装备完成，玩家:", tostring(Player))
    if Player == nil then
        return
    end
    if IsVehicleBroken(Player) then
        StopMineCarVisual(Player)
        NotifyRepairRequired(Player)
        ugcprint("[矿车物品] 中级采矿车装备被阻止：已损坏")
        return
    end

    -- 官方变身系统：装备矿车物品后延迟添加Transform_Mningcar Buff
    Player._mineCarItemEquipped = VEHICLE_REPAIR_ID
    Player._mineCarEquipTime = os.clock()
    if Player._mineCarTransformPending then
        return
    end
    Player._mineCarTransformPending = true
    ScheduleApplyMineCarTransform(Player)
end

function MidMineCar:OnUnEquip()
    MidMineCar.SuperClass.OnUnEquip(self);

    local Player = GetPlayerPawnFromItem(self)
    ugcprint("[矿车物品] 卸下矿车物品，玩家:", tostring(Player))
    if Player then
        Player._mineCarItemEquipped = nil
        Player._mineCarTransformPending = nil
    end

    -- 卸载矿车物品时通过服务器端结束行程
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        ugcprint("[矿车物品] 卸下矿车物品，退出矿车模式恢复人形")
        if Player.SetMineCarMode then
            Player:SetMineCarMode(false)
        elseif Player.DoSetMineCarMode then
            Player:DoSetMineCarMode(false)
        end
        local Ok, PC = pcall(function()
            return Player:GetController()
        end)
        if Ok and PC then
            if UGCGameSystem.IsServer() and PC.Server_EndMineCarTrip then
                PC:Server_EndMineCarTrip(VEHICLE_REPAIR_ID)
                ugcprint("[矿车物品] ✅ 服务器端结束矿车行程")
            elseif PC.RequestEndMineCarTrip then
                PC:RequestEndMineCarTrip(VEHICLE_REPAIR_ID)
                ugcprint("[矿车物品] ✅ 请求结束矿车行程")
            end
        end
    end
end

return MidMineCar
