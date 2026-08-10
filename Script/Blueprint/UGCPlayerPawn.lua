---@class UGCPlayerPawn_C:BP_PlayerPawn_TopDown_C
--Edit Below--
local UGCPlayerPawn = {}

local NORMAL_SPEED_SCALE = 2.0
local MINE_CAR_SPEED_SCALE = 4.0
local MIN_SPEED_SCALE = 0.5
local MELEE_WEAPON_SLOT = 4
local MINE_CAR_ITEM_IDS = {
    [8310025] = true,
    [8310024] = true,
    [8310023] = true,
}

local AXE_LEVEL_BY_CLASS = {
    ["copper_pickaxe"] = 1,
    ["copper_drill"] = 1,
    ["basic_miningvehicle"] = 2,
    ["iron_pickaxe"] = 2,
    ["iron_drill"] = 2,
    ["alloy_pickaxe"] = 3,
    ["alloy_drill"] = 3,
    ["diamond_pickaxe"] = 4,
    ["diamond_drill"] = 4,
    ["intermediate_miningtruck"] = 4,
    ["exdiamond_pickaxe"] = 5,
    ["exdiamond_drill"] = 5,
    ["advanced_miningtruck"] = 5,
}


local function CalculateWeightSpeed()
    return NORMAL_SPEED_SCALE
end

local function UpdateMoveSpeed(Pawn)
    if not Pawn then
        return
    end
    local IsServer = false
    if UGCGameSystem and UGCGameSystem.IsServer then
        IsServer = UGCGameSystem.IsServer()
    end
    if not IsServer then
        return
    end

    if Pawn.bIsMineCarMode then
        local curSpeed = UGCAttributeSystem.GetGameAttributeValue(Pawn, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale) or 0
        if curSpeed < MINE_CAR_SPEED_SCALE * 0.9 or curSpeed > MINE_CAR_SPEED_SCALE * 1.1 then
            UGCAttributeSystem.SetGameAttributeValue(Pawn, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, MINE_CAR_SPEED_SCALE)
        end
    else
        local targetSpeed = CalculateWeightSpeed()
        targetSpeed = math.max(targetSpeed, MIN_SPEED_SCALE)
        local curSpeed = UGCAttributeSystem.GetGameAttributeValue(Pawn, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale) or 0
        if curSpeed < MIN_SPEED_SCALE or curSpeed > NORMAL_SPEED_SCALE * 1.5 or math.abs(curSpeed - targetSpeed) > 0.01 then
            UGCAttributeSystem.SetGameAttributeValue(Pawn, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, targetSpeed)
        end
    end
end

local function GetAxeLevelByClassName(ClassName)
    if not ClassName then
        return 0
    end
    local name = tostring(ClassName):lower()
    for classPattern, level in pairs(AXE_LEVEL_BY_CLASS) do
        if string.find(name, classPattern) then
            return level
        end
    end
    return 0
end

local function GetWeaponNameSafe(Weapon)
    if Weapon == nil then
        return ""
    end
    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetWeaponName then
        local Ok, Name = pcall(UGCWeaponManagerSystem.GetWeaponName, Weapon)
        if Ok and Name ~= nil and tostring(Name) ~= "" then
            return tostring(Name)
        end
    end
    if Weapon.GetClass then
        local OkC, Cls = pcall(function()
            return Weapon:GetClass()
        end)
        if OkC and Cls ~= nil and tostring(Cls) ~= "" then
            return tostring(Cls)
        end
    end
    if UGCObjectUtility and UGCObjectUtility.GetObjectName then
        local OkO, ObjName = pcall(UGCObjectUtility.GetObjectName, Weapon)
        if OkO and ObjName ~= nil then
            return tostring(ObjName)
        end
    end
    return ""
end

local function GetWeaponItemIdSafe(Weapon)
    if Weapon == nil or UGCWeaponManagerSystem == nil or UGCWeaponManagerSystem.GetWeaponItemID == nil then
        return 0
    end
    local Ok, Id = pcall(UGCWeaponManagerSystem.GetWeaponItemID, Weapon)
    if Ok and Id ~= nil then
        return math.floor(tonumber(Id) or 0)
    end
    return 0
end

local function IsMineCarWeaponName(Weapon)
    local ItemId = GetWeaponItemIdSafe(Weapon)
    if ItemId > 0 and MINE_CAR_ITEM_IDS[ItemId] then
        return true
    end
    local Name = GetWeaponNameSafe(Weapon)
    local LowerName = string.lower(Name)
    return string.find(LowerName, "miningvehicle") ~= nil or string.find(LowerName, "miningtruck") ~= nil
end

local function IsMineCarInHand(Pawn)
    if Pawn == nil or UGCWeaponManagerSystem == nil then
        return false
    end
    if UGCWeaponManagerSystem.GetWeaponBySlot then
        local OkW, SlotWeapon = pcall(UGCWeaponManagerSystem.GetWeaponBySlot, Pawn, MELEE_WEAPON_SLOT)
        if OkW and SlotWeapon and IsMineCarWeaponName(SlotWeapon) then
            return true
        end
    end
    local Ok, Weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, Pawn)
    return Ok and IsMineCarWeaponName(Weapon)
end

local lastAxeLevel = 0
local lastWeaponName = ""

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)

    self.bIsMineCarMode = false
    self.bWasMineCarMode = false
    self._mineCarMaxHealth = 0
    self._mineCarHealthDelegate = nil
    self._mineCarItemEquipped = nil
    self._mineCarTransformPending = nil
    if UGCGameSystem and UGCGameSystem.IsServer and UGCGameSystem.IsServer() then
        UpdateMoveSpeed(self)
        UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 0)
    end

    ugcprint("[PlayerPawn] 初始化移动速度保护机制, bIsMineCarMode=false")
end

function UGCPlayerPawn:SetMineCarMode(bEnable)
    local IsServer = false
    if UGCGameSystem and UGCGameSystem.IsServer then
        IsServer = UGCGameSystem.IsServer()
    elseif UE_IsServer then
        IsServer = UE_IsServer()
    end

    if IsServer then
        self:DoSetMineCarMode(bEnable)
    else
        if self.Server_SetMineCarMode then
            self:Server_SetMineCarMode(bEnable)
        else
            self:DoSetMineCarMode(bEnable)
        end
    end
end

function UGCPlayerPawn:Server_SetMineCarMode(bEnable)
    ugcprint("[矿车模式] Server_SetMineCarMode:", bEnable)
    self:DoSetMineCarMode(bEnable)
end

local function GetMineCarBuffClass()
    local BuffPath = "/Game/Mine_02/Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C"
    if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
        local FullPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C')
        local LoadOk, BuffClass = pcall(UGCObjectUtility.LoadClass, FullPath)
        if LoadOk and BuffClass then
            return BuffClass
        end
    end
    return BuffPath
end

local function AddMineCarSkill(Pawn)
    if Pawn == nil or Pawn._mineCarSkillPath == nil
        or UGCPersistEffectSystem == nil or UGCPersistEffectSystem.AddSkillByClass == nil then
        return
    end
    local FullPath = UGCGameSystem.GetUGCResourcesFullPath(Pawn._mineCarSkillPath)
    local SkillClass = UGCObjectUtility.LoadClass(FullPath)
    if SkillClass then
        local OkList, ExistSkills = pcall(UGCPersistEffectSystem.GetSkillsByClass, Pawn, SkillClass)
        local Existing = OkList and type(ExistSkills) == "table" and ExistSkills or {}
        for _, S in pairs(Existing) do
            if S ~= nil and S.IsActive then
                ugcprint("[矿车模式] 已存在激活矿车技能，跳过重复添加:", Pawn._mineCarSkillPath)
                return
            end
        end
        local Ok, SkillInst = pcall(UGCPersistEffectSystem.AddSkillByClass, Pawn, SkillClass)
        if Ok and SkillInst then
            ugcprint(string.format("[矿车模式] ✅ 已添加矿车技能: %s", Pawn._mineCarSkillPath))
        else
            ugcprint(string.format("[矿车模式] ❌ 添加矿车技能失败: %s", Pawn._mineCarSkillPath))
        end
    end
end

function UGCPlayerPawn:DoSetMineCarMode(bEnable)
    if bEnable then
        if self.bIsMineCarMode then
            -- 已在矿车模式：先检查变身Buff是否丢失，避免“有判定无车身”
            local BuffClass = GetMineCarBuffClass()
            if UGCPersistEffectSystem and UGCPersistEffectSystem.GetBuffsByClass then
                local Ok, Buffs = pcall(UGCPersistEffectSystem.GetBuffsByClass, self, BuffClass)
                if Ok and (type(Buffs) ~= "table" or #Buffs <= 0) then
                    self._mineCarSuppressBuffCleanup = true
                    pcall(UGCPersistEffectSystem.RemoveBuffByClass, self, BuffClass)
                    local AddOk, Result = pcall(UGCPersistEffectSystem.AddBuffByClass, self, BuffClass)
                    self._mineCarSuppressBuffCleanup = nil
                    ugcprint(string.format("[矿车模式] 变身Buff缺失，重新添加 ok=%s, result=%s",
                        tostring(AddOk), tostring(Result)))
                end
            end
            local mineLevel = self._mineCarAxeLevel or 2
            local curAxeLevel = UGCAttributeSystem.GetGameAttributeValue(self, "AxeLevel")
            if curAxeLevel ~= mineLevel then
                ugcprint(string.format("[矿车模式] 更新AxeLevel: %s -> %d", tostring(curAxeLevel), mineLevel))
                UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", mineLevel)
            end
            AddMineCarSkill(self)
            return
        end

        -- 保存当前AxeLevel用于后续恢复
        local savedAxeLevel = UGCAttributeSystem.GetGameAttributeValue(self, "AxeLevel") or 0
        self._mineCarSavedAxeLevel = savedAxeLevel

        self.bIsMineCarMode = true

        -- 设置矿车模式的AxeLevel
        local mineLevel = self._mineCarAxeLevel or 2
        UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", mineLevel)
        ugcprint(string.format("[矿车模式] 进入矿车模式: 保存原AxeLevel=%s, 设置新AxeLevel=%d",
            tostring(savedAxeLevel), mineLevel))

        UpdateMoveSpeed(self)

        if UGCPlayerPawnSystem and UGCPlayerPawnSystem.SetIsInvincible then
            pcall(UGCPlayerPawnSystem.SetIsInvincible, self, true)
        end

        if UGCGameSystem and UGCGameSystem.IsServer() then
            local curHealth = UGCAttributeSystem.GetGameAttributeValue(self, UGCNativeGameAttributeType.Character_Health)
            local maxHealth = UGCAttributeSystem.GetGameAttributeValue(self, UGCNativeGameAttributeType.Character_HealthMax)
            self._mineCarMaxHealth = maxHealth or curHealth or 100

            if UGCAttributeSystem.AddGameAttributeChangedDelegate and not self._mineCarHealthDelegate then
                self._mineCarHealthDelegate = UGCAttributeSystem.AddGameAttributeChangedDelegate(self, UGCNativeGameAttributeType.Character_Health, function(Owner, AttrName, CurValue)
                    if self and self.bIsMineCarMode and CurValue < self._mineCarMaxHealth then
                        UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_Health, self._mineCarMaxHealth)
                    end
                end)
            end
        end

        local BuffClass = GetMineCarBuffClass()

        if UGCPersistEffectSystem then
            self._mineCarSuppressBuffCleanup = true
            pcall(UGCPersistEffectSystem.RemoveBuffByClass, self, BuffClass)

            local Ok, Result = pcall(UGCPersistEffectSystem.AddBuffByClass, self, BuffClass)
            self._mineCarSuppressBuffCleanup = nil
            if not Ok then
                ugcprint("[矿车模式] ❌ AddBuffByClass调用失败:", tostring(Result))
            end
        end

        -- 变身Buff应用完成后统一添加矿车技能，避免武器自带的未激活技能被引擎卸载后无技能可用
        AddMineCarSkill(self)

        ugcprint("[矿车模式] ✅ 已切换到矿车模式")
    else
        self.bIsMineCarMode = false

        -- 恢复之前保存的AxeLevel
        local savedAxeLevel = self._mineCarSavedAxeLevel or 0
        ugcprint(string.format("[矿车模式] 退出矿车模式: 恢复AxeLevel=%s", tostring(savedAxeLevel)))
        UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", savedAxeLevel)

        self._mineCarAxeLevel = nil
        self._mineCarSavedAxeLevel = nil

        if UGCPlayerPawnSystem and UGCPlayerPawnSystem.SetIsInvincible then
            pcall(UGCPlayerPawnSystem.SetIsInvincible, self, false)
        end

        if UGCGameSystem and UGCGameSystem.IsServer() then
            if self._mineCarHealthDelegate and UGCAttributeSystem.RemoveGameAttributeChangedDelegate then
                UGCAttributeSystem.RemoveGameAttributeChangedDelegate(self, UGCNativeGameAttributeType.Character_Health, self._mineCarHealthDelegate)
                self._mineCarHealthDelegate = nil
            end
            self._mineCarMaxHealth = 0
        end

        local BuffClass = GetMineCarBuffClass()

        if UGCPersistEffectSystem then
            local Ok, Result = pcall(UGCPersistEffectSystem.RemoveBuffByClass, self, BuffClass)
            if not Ok then
                ugcprint("[矿车模式] ❌ 移除变身Buff失败:", tostring(Result))
            end

            -- 移除所有可能的矿车技能（根据存储的路径或所有已知路径）
            local SkillPathsToRemove = {}
            if self._mineCarSkillPath then
                table.insert(SkillPathsToRemove, self._mineCarSkillPath)
            end
            -- 同时检查所有车型的技能，确保清理彻底
            local AllSkillPaths = {
                "Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C",
                "Asset/Blueprint/Prefabs/Skills/MidVehicle.MidVehicle_C",
                "Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C",
            }
            for _, sp in ipairs(AllSkillPaths) do
                local found = false
                for _, ep in ipairs(SkillPathsToRemove) do
                    if ep == sp then found = true; break end
                end
                if not found then
                    table.insert(SkillPathsToRemove, sp)
                end
            end

            for _, SkillPath in ipairs(SkillPathsToRemove) do
                local FullPath = UGCGameSystem.GetUGCResourcesFullPath(SkillPath)
                local SkillClass = UGCObjectUtility.LoadClass(FullPath)
                if SkillClass then
                    local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(self, SkillClass)
                    if ExistSkills and #ExistSkills > 0 then
                        for _, SkillInst in ipairs(ExistSkills) do
                            if UE.IsValid(SkillInst) then
                                UGCPersistEffectSystem.RemoveSkillInstance(self, SkillInst)
                            end
                        end
                    end
                end
            end
            self._mineCarSkillPath = nil
        end

        local MovementComp = self.CharacterMovement
        if MovementComp then
            pcall(function()
                MovementComp.ConsumeInputVector(MovementComp)
                MovementComp.Acceleration = {X = 0, Y = 0, Z = 0}
                MovementComp.Velocity = {X = 0, Y = 0, Z = 0}
            end)

            if UGCTimerManagerSystem and UGCTimerManagerSystem.SetTimer then
                UGCTimerManagerSystem.SetTimer(function()
                    if self and UE.IsValid(self) then
                        local MC = self.CharacterMovement
                        if MC then
                            pcall(MC.ConsumeInputVector, MC)
                        end
                    end
                end, 0.1, false)
            end
        end

        UpdateMoveSpeed(self)

        ugcprint("[矿车模式] 已退出矿车模式")
    end
end

function UGCPlayerPawn:IsMineCarMode()
    return self.bIsMineCarMode == true
end

function UGCPlayerPawn:EnsureMineCarInHand(OnInHand)
    local Pawn = self
    if Pawn._mineCarEnsureInHandActive then
        return
    end
    Pawn._mineCarEnsureInHandActive = true
    local Attempts = 0
    local bSentSwitch = false
    local function TrySwitch()
        if Pawn == nil or not UE.IsValid(Pawn) then
            Pawn._mineCarEnsureInHandActive = nil
            if OnInHand then OnInHand() end
            return
        end
        if IsMineCarInHand(Pawn) then
            ugcprint("[矿车模式] 矿车已持在手上")
            Pawn._mineCarEnsureInHandActive = nil
            if OnInHand then OnInHand() end
            return
        end
        Attempts = Attempts + 1
        if Attempts > 20 then
            local Cur = nil
            if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetCurrentWeapon then
                local OkC, W = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, Pawn)
                if OkC then
                    Cur = W
                end
            end
            ugcprint("[矿车模式] 矿车切换到手上超时，当前武器ItemID=" .. tostring(GetWeaponItemIdSafe(Cur)))
            Pawn._mineCarEnsureInHandActive = nil
            if OnInHand then OnInHand() end
            return
        end
        -- 装备动画通常 0.4 秒内完成，首次检测失败后立即补一次切枪
        if not bSentSwitch and Attempts >= 2
            and UGCWeaponManagerSystem and UGCWeaponManagerSystem.SwitchWeaponBySlot then
            pcall(UGCWeaponManagerSystem.SwitchWeaponBySlot, Pawn, MELEE_WEAPON_SLOT, false)
            bSentSwitch = true
        end
        if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
            UGCTimerUtility.CreateLuaTimer(0.1, TrySwitch, false)
        else
            TrySwitch()
        end
    end
    TrySwitch()
end

function UGCPlayerPawn:UGC_EquipWeaponEvent(Slot)
    if UGCPlayerPawn.SuperClass.UGC_EquipWeaponEvent then
        UGCPlayerPawn.SuperClass.UGC_EquipWeaponEvent(self, Slot)
    end
    local Pawn = self
    local function CheckWeaponState()
        if Pawn == nil or not UE.IsValid(Pawn) then
            return
        end
        if not (Pawn.IsMineCarMode and Pawn:IsMineCarMode()) then
            return
        end
        if Pawn._mineCarItemEquipped ~= nil then
            local EquipTime = tonumber(Pawn._mineCarEquipTime) or 0
            local Now = os.clock()
            if Now - EquipTime > 1.5 then
                if not IsMineCarInHand(Pawn) then
                    ugcprint("[矿车模式] 已切换其他武器，清理矿车状态")
                    Pawn._mineCarItemEquipped = nil
                    if Pawn.SetMineCarMode then
                        Pawn:SetMineCarMode(false)
                    end
                    return
                end
            end
            Pawn:EnsureMineCarInHand()
        else
            ugcprint("[矿车模式] 已切换到其他武器，恢复人形")
            if Pawn.SetMineCarMode then
                Pawn:SetMineCarMode(false)
            end
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.35, CheckWeaponState, false)
    else
        CheckWeaponState()
    end
end

function UGCPlayerPawn:UpdateMoveSpeed()
    UpdateMoveSpeed(self)
end

local _lastFrameDeltaTime = 0
local _stuckInputRecoveryCooldown = 0
local _diagnosticLogTimer = 0
local _inputState = {
    lastVelocity = {X = 0, Y = 0, Z = 0},
    lastInputMag = 0,
    wasMoving = false,
    stoppedFrames = 0,
}

local function RecoverStuckInput(Pawn)
    if not Pawn then return end

    -- ugcprint("[输入恢复] ========== 开始恢复 ==========")

    local MC = Pawn.CharacterMovement
    if not MC then
        -- ugcprint("[输入恢复] CharacterMovement不存在，跳过")
        return
    end

    local OkCV, ConsumedVec = pcall(MC.ConsumeInputVector, MC)
    -- if OkCV and ConsumedVec then
    --     local Mag = math.sqrt((ConsumedVec.X or 0)^2 + (ConsumedVec.Y or 0)^2 + (ConsumedVec.Z or 0)^2)
    --     ugcprint(string.format("[输入恢复] ConsumeInputVector成功: (%.2f,%.2f,%.2f) 幅度=%.2f",
    --         ConsumedVec.X or 0, ConsumedVec.Y or 0, ConsumedVec.Z or 0, Mag))
    -- else
    --     ugcprint(string.format("[输入恢复] ConsumeInputVector: ok=%s, err=%s", tostring(OkCV), tostring(ConsumedVec)))
    -- end

    pcall(function()
        MC.Acceleration = {X = 0, Y = 0, Z = 0}
        MC.Velocity = {X = 0, Y = 0, Z = 0}
    end)
    -- ugcprint("[输入恢复] 已重置Acceleration和Velocity")

    local LocalPC = UGCGameSystem and UGCGameSystem.GetLocalPlayerController and UGCGameSystem.GetLocalPlayerController()
    if not LocalPC then
        -- ugcprint("[输入恢复] 无法获取LocalPlayerController，跳过摇杆重置")
        return
    end

    if not LocalPC.RightJoyStickWidget then
        -- ugcprint("[输入恢复] RightJoyStickWidget不存在，跳过摇杆重置")
        return
    end

    local Widget = LocalPC.RightJoyStickWidget
    -- ugcprint(string.format("[输入恢复] 找到Widget: %s", tostring(Widget)))

    if Widget.ResetJoystickInput then
        -- ugcprint("[输入恢复] 调用ResetJoystickInput...")
        pcall(Widget.ResetJoystickInput, Widget)
        -- ugcprint("[输入恢复] ResetJoystickInput完成")
    else
        -- ugcprint("[输入恢复] Widget无ResetJoystickInput方法")
    end

    if Widget.Left then
        local Left = Widget.Left
        -- ugcprint(string.format("[输入恢复] Left摇杆存在: %s, bIsPressed=%s",
        --     tostring(Left), tostring(Left.bIsPressed)))

        if Left.ClearTouchInput then
            -- ugcprint("[输入恢复] 调用Left:ClearTouchInput...")
            pcall(Left.ClearTouchInput, Left)
            -- ugcprint(string.format("[输入恢复] ClearTouchInput: ok=%s", tostring(OkCTI)))
        else
            -- ugcprint("[输入恢复] Left无ClearTouchInput方法")
        end

        if Left.ReleaseAllPointerCapture then
            -- ugcprint("[输入恢复] 调用Left:ReleaseAllPointerCapture...")
            pcall(Left.ReleaseAllPointerCapture, Left)
            -- ugcprint(string.format("[输入恢复] ReleaseAllPointerCapture: ok=%s", tostring(OkRPC)))
        else
            -- ugcprint("[输入恢复] Left无ReleaseAllPointerCapture方法")
        end

        pcall(function()
            Left.bIsPressed = false
            Left.CurrentVector = nil
        end)
        -- ugcprint(string.format("[输入恢复] 已强制清除Left状态: bIsPressed=%s", tostring(Left.bIsPressed)))
    else
        -- ugcprint("[输入恢复] Widget.Left不存在")
    end

    -- ugcprint("[输入恢复] ========== 恢复完成 ==========")
end

local function PrintDiagnosticLog(Pawn, DeltaTime)
    if not Pawn then return end

    -- 诊断日志已注释，保留逻辑但不输出
    -- local MC = Pawn.CharacterMovement
    -- if not MC then return end
    --
    -- local OkV, Velocity = pcall(function() return MC.Velocity end)
    -- local OkI, InputVec = pcall(MC.GetPendingInputVector, MC)
    --
    -- local Vx, Vy, Vz = 0, 0, 0
    -- local SpeedSq = 0
    -- if OkV and Velocity then
    --     Vx = Velocity.X or 0
    --     Vy = Velocity.Y or 0
    --     Vz = Velocity.Z or 0
    --     SpeedSq = Vx*Vx + Vy*Vy + Vz*Vz
    -- end
    --
    -- local Ix, Iy, Iz = 0, 0, 0
    -- local InputMag = 0
    -- if OkI and InputVec then
    --     Ix = InputVec.X or 0
    --     Iy = InputVec.Y or 0
    --     Iz = InputVec.Z or 0
    --     InputMag = math.sqrt(Ix*Ix + Iy*Iy + Iz*Iz)
    -- end
    --
    -- local IsMoving = SpeedSq > 100
    -- if _inputState.wasMoving and not IsMoving then
    --     _inputState.stoppedFrames = _inputState.stoppedFrames + 1
    --     if _inputState.stoppedFrames > 10 then
    --         ugcprint(string.format("[诊断] 已停止移动 %d 帧，速度=(%.2f,%.2f,%.2f) 输入=%.3f",
    --             _inputState.stoppedFrames, Vx, Vy, Vz, InputMag))
    --         _inputState.stoppedFrames = 0
    --     end
    -- else
    --     _inputState.stoppedFrames = 0
    -- end
    -- _inputState.wasMoving = IsMoving
    -- _inputState.lastVelocity = {X = Vx, Y = Vy, Z = Vz}
    -- _inputState.lastInputMag = InputMag
    --
    -- local LocalPC = UGCGameSystem and UGCGameSystem.GetLocalPlayerController and UGCGameSystem.GetLocalPlayerController()
    -- local LeftPressed = "N/A"
    -- if LocalPC and LocalPC.RightJoyStickWidget and LocalPC.RightJoyStickWidget.Left then
    --     LeftPressed = tostring(LocalPC.RightJoyStickWidget.Left.bIsPressed)
    -- end
    --
    -- ugcprint(string.format("[诊断] DT=%.3f 速度=(%.1f,%.1f,%.1f) 输入=(%.2f,%.2f,%.2f) Mag=%.3f MineCar=%s LeftPressed=%s",
    --     DeltaTime, Vx, Vy, Vz, Ix, Iy, Iz, InputMag,
    --     tostring(Pawn.bIsMineCarMode), LeftPressed))
end

local function DetectAndRecoverStuckInput(Pawn, DeltaTime)
    if not Pawn then return end

    local FRAME_DROP_THRESHOLD = 0.15
    local RECOVERY_COOLDOWN = 0.5
    local DIAG_INTERVAL = 0.5

    _diagnosticLogTimer = _diagnosticLogTimer + DeltaTime
    if _diagnosticLogTimer >= DIAG_INTERVAL then
        _diagnosticLogTimer = 0
        PrintDiagnosticLog(Pawn, DeltaTime)
    end

    if _stuckInputRecoveryCooldown > 0 then
        _stuckInputRecoveryCooldown = _stuckInputRecoveryCooldown - DeltaTime
    end

    local LocalPawn = UGCGameSystem and UGCGameSystem.GetLocalPlayerPawn and UGCGameSystem.GetLocalPlayerPawn()
    if not LocalPawn or LocalPawn ~= Pawn then
        return
    end

    if DeltaTime > FRAME_DROP_THRESHOLD and _lastFrameDeltaTime > FRAME_DROP_THRESHOLD then
        if _stuckInputRecoveryCooldown <= 0 then
            _stuckInputRecoveryCooldown = RECOVERY_COOLDOWN
            -- ugcprint(string.format("[输入恢复] 检测到连续帧跌落: DT=%.3f, LastDT=%.3f", DeltaTime, _lastFrameDeltaTime))
            RecoverStuckInput(Pawn)
        end
    end

    local MC = Pawn.CharacterMovement
    if MC and _stuckInputRecoveryCooldown <= 0 then
        local OkV, Velocity = pcall(function() return MC.Velocity end)
        if OkV and Velocity then
            local SpeedSq = (Velocity.X or 0)^2 + (Velocity.Y or 0)^2 + (Velocity.Z or 0)^2
            if SpeedSq > 10000 then
                local OkPI, InputVec = pcall(MC.GetPendingInputVector, MC)
                if OkPI and InputVec then
                    local Mag = math.sqrt((InputVec.X or 0)^2 + (InputVec.Y or 0)^2 + (InputVec.Z or 0)^2)
                    if Mag > 0.5 then
                        _stuckInputRecoveryCooldown = RECOVERY_COOLDOWN
                        -- ugcprint(string.format("[输入恢复] 检测到移动卡住: SpeedSq=%.0f, InputMag=%.2f", SpeedSq, Mag))
                        RecoverStuckInput(Pawn)
                    end
                end
            end
        end
    end

    _lastFrameDeltaTime = DeltaTime
end

function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)

    DetectAndRecoverStuckInput(self, DeltaTime)

    if self.bIsMineCarMode then
        return
    end

    local axeLevel = 0
    local currentWeaponName = ""

    if UGCWeaponManagerSystem.GetCurrentWeapon then
        local weapon = UGCWeaponManagerSystem.GetCurrentWeapon(self)

        if weapon then
            currentWeaponName = GetWeaponNameSafe(weapon)

            local attrAxeLevel = UGCAttributeSystem.GetGameAttributeValue(weapon, "AxeLevel") or 0
            local classAxeLevel = 0

            if weapon.GetClass then
                classAxeLevel = GetAxeLevelByClassName(weapon:GetClass())
            end

            axeLevel = attrAxeLevel > 0 and attrAxeLevel or classAxeLevel

            if axeLevel ~= lastAxeLevel or currentWeaponName ~= lastWeaponName then
                ugcprint("[镐子装备] 装备:", currentWeaponName, "| 等级:", axeLevel)
                lastAxeLevel = axeLevel
                lastWeaponName = currentWeaponName
            end
        else
            if lastWeaponName ~= "" then
                ugcprint("[镐子装备] 未持有武器")
                lastWeaponName = ""
                lastAxeLevel = 0
            end
        end
    end

    if axeLevel ~= lastAxeLevel
        and UGCGameSystem and UGCGameSystem.IsServer and UGCGameSystem.IsServer() then
        UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", axeLevel)
    end
end

function UGCPlayerPawn:ReceiveEndPlay()
    UGCPlayerPawn.SuperClass.ReceiveEndPlay(self)
end

function UGCPlayerPawn:GetReplicatedProperties()
    return {"__SubObjectRepList", "Lazy"}
end

function UGCPlayerPawn:GetAvailableServerRPCs()
    return "Server_SetMineCarMode"
end

return UGCPlayerPawn
