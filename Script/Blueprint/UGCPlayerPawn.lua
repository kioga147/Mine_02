---@class UGCPlayerPawn_C:BP_PlayerPawn_TopDown_C
--Edit Below--
local UGCPlayerPawn = {}

local NORMAL_SPEED_SCALE = 2.0
local MINE_CAR_SPEED_SCALE = 4.0
local MIN_SPEED_SCALE = 0.5

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

local lastAxeLevel = 0
local lastWeaponName = ""

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)
    
    self.bIsMineCarMode = false
    self.bWasMineCarMode = false
    self._mineCarMaxHealth = 0
    self._mineCarHealthDelegate = nil
    UpdateMoveSpeed(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 0)
    
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

function UGCPlayerPawn:DoSetMineCarMode(bEnable)
    if bEnable then
        if self.bIsMineCarMode then
            return
        end
        
        self.bIsMineCarMode = true
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
        
        local BuffPath = "/Game/Mine_02/Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C"
        
        if UGCPersistEffectSystem then
            local BuffClass = nil
            if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
                local FullPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C')
                BuffClass = UGCObjectUtility.LoadClass(FullPath)
            end
            
            if not BuffClass then
                BuffClass = BuffPath
            end
            
            local Ok, Result = pcall(UGCPersistEffectSystem.AddBuffByClass, self, BuffClass)
            if not Ok then
                ugcprint("[矿车模式] ❌ AddBuffByClass调用失败:", tostring(Result))
            end
        end
        
        ugcprint("[矿车模式] ✅ 已切换到矿车模式")
    else
        self.bIsMineCarMode = false
        
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
        
        local BuffPath = "/Game/Mine_02/Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C"
        
        if UGCPersistEffectSystem then
            local BuffClass = nil
            if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
                local FullPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C')
                BuffClass = UGCObjectUtility.LoadClass(FullPath)
            end
            
            if not BuffClass then
                BuffClass = BuffPath
            end
            
            local Ok, Result = pcall(UGCPersistEffectSystem.RemoveBuffByClass, self, BuffClass)
            if not Ok then
                ugcprint("[矿车模式] ❌ 移除变身Buff失败:", tostring(Result))
            end
            
            local SkillPaths = {
                "Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C"
            }
            for _, SkillPath in ipairs(SkillPaths) do
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
            if weapon.GetName then
                currentWeaponName = tostring(weapon:GetName())
            end
            
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
    
    if axeLevel ~= lastAxeLevel then
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
