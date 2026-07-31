---@class UGCPlayerPawn_C:BP_PlayerPawn_TopDown_C
--Edit Below--
local UGCPlayerPawn = {}

local NORMAL_SPEED_SCALE = 2.0
local SPRINT_SPEED_SCALE = 3.0
local MINE_CAR_SPEED_SCALE = 4.0
local MIN_SPEED_SCALE = 0.5
local MAX_WEIGHT_CAPACITY = 100

local SPRINT_INPUT_ACTION = "UGCReservedAction_01"
local SPRINT_INPUT_TAGS = {
    SPRINT_INPUT_ACTION,
    "Input.Action." .. SPRINT_INPUT_ACTION,
}
local SPRINT_TOGGLE_DEBOUNCE = 0.25
local SPRINT_KEY_NAMES = { "LeftShift", "RightShift" }

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

local BP_BackpackComponentV2_Custom = nil
local function GetBackpackComponent()
    if not BP_BackpackComponentV2_Custom then
        if UGCGameSystem and UGCGameSystem.UGCRequire then
            local Ok, Mod = pcall(UGCGameSystem.UGCRequire, "Script.GamePartCustom.BackpackV2.BP_BackpackComponentV2_Custom")
            if Ok and Mod then
                BP_BackpackComponentV2_Custom = Mod
            end
        end
    end
    return BP_BackpackComponentV2_Custom
end

local function CalculateWeightSpeed(Player)
    if not Player then
        return NORMAL_SPEED_SCALE
    end
    local curWeight = 0
    if BP_BackpackComponentV2_Custom and BP_BackpackComponentV2_Custom.GetBackpackWeightInfo then
        local info = BP_BackpackComponentV2_Custom.GetBackpackWeightInfo(Player)
        if info and info.CurrentWeight then
            curWeight = info.CurrentWeight
        end
    end
    local ratio = math.min(curWeight / MAX_WEIGHT_CAPACITY, 1.0)
    local speedScale = NORMAL_SPEED_SCALE * (1.0 - ratio * 0.5)
    return speedScale
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
        local targetSpeed = CalculateWeightSpeed(Pawn)
        if Pawn.bSprintToggleEnabled == true then
            targetSpeed = math.min(SPRINT_SPEED_SCALE, targetSpeed * 1.5)
        end
        targetSpeed = math.max(targetSpeed, MIN_SPEED_SCALE)
        local curSpeed = UGCAttributeSystem.GetGameAttributeValue(Pawn, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale) or 0
        if curSpeed < MIN_SPEED_SCALE or curSpeed > NORMAL_SPEED_SCALE * 1.5 or math.abs(curSpeed - targetSpeed) > 0.01 then
            UGCAttributeSystem.SetGameAttributeValue(Pawn, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, targetSpeed)
        end
    end
end

local function ClearSprintMovementRuntime(Pawn)
    if not Pawn then
        return
    end
    if UGCAttributeSystem then
        local AdditiveAttr = UGCNativeGameAttributeType and UGCNativeGameAttributeType.Character_AdditiveSpeedValueWrapper
            or "AdditiveSpeedValueWrapper"
        if AdditiveAttr ~= nil then
            pcall(UGCAttributeSystem.SetGameAttributeValue, Pawn, AdditiveAttr, 0)
        end
    end
    if Pawn.ConsumeMovementInputVector then
        pcall(Pawn.ConsumeMovementInputVector, Pawn)
    end
    local MC = Pawn.CharacterMovement
    if MC then
        if MC.ConsumeInputVector then
            pcall(MC.ConsumeInputVector, MC)
        end
        pcall(function()
            MC.Acceleration = { X = 0, Y = 0, Z = 0 }
            MC.Velocity = { X = 0, Y = 0, Z = 0 }
        end)
    end
end

local function GetLocalPC()
    if UGCGameSystem and UGCGameSystem.GetLocalPlayerController then
        local Ok, PC = pcall(UGCGameSystem.GetLocalPlayerController)
        if Ok then
            return PC
        end
    end
    return nil
end

local function WasKeyJustPressed(PC, KeyName)
    if PC == nil then
        return false
    end

    local OkDirect, DirectPressed = pcall(function()
        return PC:WasInputKeyJustPressed(KeyName)
    end)
    if OkDirect and DirectPressed == true then
        return true
    end

    local InputLib = rawget(_G, "UKismetInputLibrary")
    if InputLib ~= nil and InputLib.GetKeyByName ~= nil then
        local OkKey, Key = pcall(InputLib.GetKeyByName, KeyName)
        if OkKey and Key ~= nil then
            local OkPressed, Pressed = pcall(function()
                return PC:WasInputKeyJustPressed(Key)
            end)
            if OkPressed and Pressed == true then
                return true
            end
        end
    end

    return false
end

local function PollSprintToggleKey(Pawn)
    if not Pawn then
        return
    end
    if UGCGameSystem and UGCGameSystem.IsServer and UGCGameSystem.IsServer() then
        return
    end

    local LocalPawn = UGCGameSystem and UGCGameSystem.GetLocalPlayerPawn and UGCGameSystem.GetLocalPlayerPawn()
    if LocalPawn ~= Pawn then
        return
    end

    local PC = GetLocalPC()
    for _, KeyName in ipairs(SPRINT_KEY_NAMES) do
        if WasKeyJustPressed(PC, KeyName) then
            Pawn._sprintToggleRequested = true
            ugcprint("[SprintToggle] fallback key pressed:", KeyName)
            return
        end
    end
end

local function GetInputValueSafe(Pawn, InputName)
    local InputSystem = rawget(_G, "UGCInputSystem")
    if Pawn == nil or InputSystem == nil or InputSystem.GetInputValue == nil then
        return 0
    end
    local Ok, Value = pcall(InputSystem.GetInputValue, Pawn, InputName)
    if Ok then
        return tonumber(Value) or 0
    end
    return 0
end

local function IsLiveMoveInputActive(Pawn)
    local Forward = GetInputValueSafe(Pawn, "MoveForwardWin")
    local Right = GetInputValueSafe(Pawn, "MoveRightWin")
    return math.abs(Forward) > 0.05 or math.abs(Right) > 0.05
end

local function DisableDefaultSprintInput(Pawn)
    local ControllerSystem = rawget(_G, "UGCPlayerControllerSystem")
    if ControllerSystem == nil or ControllerSystem.DisableJoyStickSprint == nil then
        return
    end

    local PC = GetLocalPC()
    if PC == nil and UGCGameSystem and UGCGameSystem.GetPlayerControllerByPlayerPawn then
        local Ok, Result = pcall(UGCGameSystem.GetPlayerControllerByPlayerPawn, Pawn)
        if Ok then
            PC = Result
        end
    end

    if PC ~= nil then
        pcall(ControllerSystem.DisableJoyStickSprint, PC)
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
    self.bSprintToggleEnabled = false
    self._sprintToggleRequested = false
    self._lastSprintToggleTime = 0
    self._mineCarMaxHealth = 0
    self._mineCarHealthDelegate = nil
    DisableDefaultSprintInput(self)
    if not UGCGameSystem.IsServer() and self.BindSprintToggleInput then
        self:BindSprintToggleInput()
    end
    UpdateMoveSpeed(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 0)
    
    ugcprint("[PlayerPawn] 初始化移动速度保护机制, bIsMineCarMode=false")
end

function UGCPlayerPawn:SetMineCarMode(bEnable)
    ugcprint("[矿车模式] 设置矿车模式:", bEnable)
    
    local IsServer = false
    if UGCGameSystem and UGCGameSystem.IsServer then
        IsServer = UGCGameSystem.IsServer()
    elseif UE_IsServer then
        IsServer = UE_IsServer()
    end
    
    ugcprint("[矿车模式] 当前是否服务器:", IsServer)
    
    if UGCPersistEffectSystem then
        local BaseComp = UGCPersistEffectSystem.GetPersistBaseComponentByContent(self)
        ugcprint("[矿车模式] PersistBaseComponent:", tostring(BaseComp))
    end
    
    if IsServer then
        ugcprint("[矿车模式] 已在服务器端，直接执行")
        self:DoSetMineCarMode(bEnable)
    else
        ugcprint("[矿车模式] 在客户端，发送RPC到服务器")
        if self.Server_SetMineCarMode then
            self:Server_SetMineCarMode(bEnable)
        else
            ugcprint("[矿车模式] ❌ Server_SetMineCarMode RPC不存在")
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
            ugcprint("[矿车模式] ⚠️ 矿车模式已激活")
            return
        end
        
        self.bIsMineCarMode = true
        UpdateMoveSpeed(self)
        
        if UGCPlayerPawnSystem and UGCPlayerPawnSystem.SetIsInvincible then
            pcall(UGCPlayerPawnSystem.SetIsInvincible, self, true)
            ugcprint("[矿车模式] ✅ 矿车模式无敌已开启")
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
                ugcprint("[矿车模式] ✅ 生命值保护已开启 (MaxHealth:", self._mineCarMaxHealth, ")")
            end
        end
        
        local BuffPath = "/Game/Mine_02/Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C"
        
        if UGCPersistEffectSystem then
            ugcprint("[矿车模式] 准备添加变身Buff")
            
            local BuffClass = nil
            if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
                local FullPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C')
                ugcprint("[矿车模式] Buff完整路径:", FullPath)
                
                BuffClass = UGCObjectUtility.LoadClass(FullPath)
                ugcprint("[矿车模式] LoadClass结果:", tostring(BuffClass))
            end
            
            if not BuffClass then
                ugcprint("[矿车模式] ⚠️ LoadClass失败，尝试直接使用路径")
                BuffClass = BuffPath
            end
            
            local Ok, Result = pcall(UGCPersistEffectSystem.AddBuffByClass, self, BuffClass)
            if Ok then
                ugcprint("[矿车模式] ✅ AddBuffByClass调用成功")
                
                local GetBuffsOk, Buffs = pcall(UGCPersistEffectSystem.GetBuffsByClass, self, BuffClass)
                if GetBuffsOk and Buffs and type(Buffs) == "table" and #Buffs > 0 then
                    ugcprint("[矿车模式] ✅ 确认Buff已添加，数量:", #Buffs)
                else
                    ugcprint("[矿车模式] ⚠️ GetBuffsByClass结果:", tostring(Buffs))
                end
            else
                ugcprint("[矿车模式] ❌ AddBuffByClass调用失败:", tostring(Result))
            end
        else
            ugcprint("[矿车模式] ❌ UGCPersistEffectSystem不可用")
        end
        
        ugcprint("[矿车模式] ✅ 已切换到矿车模式, 移动速度已更新")
    else
        self.bIsMineCarMode = false
        
        if UGCPlayerPawnSystem and UGCPlayerPawnSystem.SetIsInvincible then
            pcall(UGCPlayerPawnSystem.SetIsInvincible, self, false)
            ugcprint("[矿车模式] ✅ 矿车模式无敌已关闭")
        end
        
        if UGCGameSystem and UGCGameSystem.IsServer() then
            if self._mineCarHealthDelegate and UGCAttributeSystem.RemoveGameAttributeChangedDelegate then
                UGCAttributeSystem.RemoveGameAttributeChangedDelegate(self, UGCNativeGameAttributeType.Character_Health, self._mineCarHealthDelegate)
                self._mineCarHealthDelegate = nil
                ugcprint("[矿车模式] ✅ 生命值保护已关闭")
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
            if Ok then
                ugcprint("[矿车模式] ✅ 已移除变身Buff")
            else
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
                                ugcprint("[矿车模式] ✅ 已移除BasicVehicle技能实例")
                            end
                        end
                    end
                end
            end
        end
        
        local MovementComp = self.CharacterMovement
        if MovementComp then
            local Ok, InputVec = pcall(MovementComp.ConsumeInputVector, MovementComp)
            if Ok and InputVec then
                local X, Y, Z = InputVec.X, InputVec.Y, InputVec.Z
                ugcprint(string.format("[矿车模式] 已清除输入向量: (%.2f, %.2f, %.2f)", X or 0, Y or 0, Z or 0))
            end
            
            pcall(function()
                MovementComp.Acceleration = {X = 0, Y = 0, Z = 0}
                MovementComp.Velocity = {X = 0, Y = 0, Z = 0}
                ugcprint("[矿车模式] 已重置加速度和速度")
            end)
            
            if UGCTimerManagerSystem and UGCTimerManagerSystem.SetTimer then
                UGCTimerManagerSystem.SetTimer(function()
                    if self and UE.IsValid(self) then
                        local MC = self.CharacterMovement
                        if MC then
                            pcall(MC.ConsumeInputVector, MC)
                            ugcprint("[矿车模式] 延迟安全清除: 已再次清除输入")
                        end
                    end
                end, 0.1, false)
            end
        end
        
        UpdateMoveSpeed(self)
        
        ugcprint("[矿车模式] ❌ 已退出矿车模式, 移动状态已清除")
    end
end

function UGCPlayerPawn:IsMineCarMode()
    return self.bIsMineCarMode == true
end

function UGCPlayerPawn:UpdateMoveSpeed()
    UpdateMoveSpeed(self)
end

function UGCPlayerPawn:Server_SetSprintToggle(bEnable)
    if self.bIsMineCarMode then
        self.bSprintToggleEnabled = false
        return
    end
    self.bSprintToggleEnabled = bEnable == true
    if self.bSprintToggleEnabled ~= true then
        ClearSprintMovementRuntime(self)
    end
    UpdateMoveSpeed(self)
end

function UGCPlayerPawn:Server_ResetMoveSpeedAfterSprint()
    self:Server_SetSprintToggle(false)
end

function UGCPlayerPawn:BindSprintToggleInput()
    local InputSystem = rawget(_G, "UGCInputSystem")
    local TriggerEnum = rawget(_G, "ETriggerEvent")
    if InputSystem == nil or InputSystem.BindInputMapping == nil or TriggerEnum == nil then
        ugcprint("[SprintToggle] input mapping api missing")
        return
    end

    self._sprintInputBindingHandles = self._sprintInputBindingHandles or {}
    for _, TagName in ipairs(SPRINT_INPUT_TAGS) do
        for _, EventName in ipairs({ "Started", "Triggered" }) do
            local TriggerEvent = TriggerEnum[EventName]
            if TriggerEvent ~= nil then
                local Ok, Handle = pcall(InputSystem.BindInputMapping, self, TagName, TriggerEvent, self.OnSprintToggleInput)
                if Ok then
                    table.insert(self._sprintInputBindingHandles, Handle)
                end
            end
        end
    end
    ugcprint("[SprintToggle] bound input action:", SPRINT_INPUT_ACTION)
end

function UGCPlayerPawn:OnSprintToggleInput(InputValue, ElapsedTime, TriggeredTime, InputTag)
    self._sprintToggleRequested = true
end

local _lastFrameDeltaTime = 0
local _stuckInputRecoveryCooldown = 0
local _diagnosticLogTimer = 0
local _inputState = {
    lastVelocity = {X = 0, Y = 0, Z = 0},
    lastInputMag = 0,
    wasMoving = false,
    stoppedFrames = 0,
    noLiveInputMovingFrames = 0,
    sprintReleaseResetDelay = 0,
    wasSprintDown = false,
}

local function RecoverStuckInput(Pawn)
    if not Pawn then return end
    
    -- ugcprint("[输入恢复] ========== 开始恢复 ==========")
    
    if Pawn.ConsumeMovementInputVector then
        pcall(Pawn.ConsumeMovementInputVector, Pawn)
    end

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
    --     LeftPressed = "hidden"
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
    local STOP_SPEED_SQ = 2500
    local STUCK_INPUT_THRESHOLD = 0.15
    local STUCK_FRAMES = 3
    
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
    
    local bLiveMoveInput = IsLiveMoveInputActive(Pawn)
    if DeltaTime > FRAME_DROP_THRESHOLD and _lastFrameDeltaTime > FRAME_DROP_THRESHOLD and not bLiveMoveInput then
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

local function DetectAndRecoverStuckInputStrict(Pawn, DeltaTime)
    if not Pawn then return end

    local LocalPawn = UGCGameSystem and UGCGameSystem.GetLocalPlayerPawn and UGCGameSystem.GetLocalPlayerPawn()
    if not LocalPawn or LocalPawn ~= Pawn then
        return
    end

    local RECOVERY_COOLDOWN = 0.5
    local STOP_SPEED_SQ = 2500
    local STUCK_INPUT_THRESHOLD = 0.15
    local STUCK_FRAMES = 3

    if _stuckInputRecoveryCooldown > 0 then
        _stuckInputRecoveryCooldown = _stuckInputRecoveryCooldown - DeltaTime
    end

    local bLiveMoveInput = IsLiveMoveInputActive(Pawn)
    local MC = Pawn.CharacterMovement
    if MC == nil then
        _lastFrameDeltaTime = DeltaTime
        return
    end

    local SpeedSq = 0
    local OkV, Velocity = pcall(function() return MC.Velocity end)
    if OkV and Velocity then
        SpeedSq = (Velocity.X or 0)^2 + (Velocity.Y or 0)^2 + (Velocity.Z or 0)^2
    end

    local PendingMag = 0
    local OkPI, InputVec = pcall(MC.GetPendingInputVector, MC)
    if OkPI and InputVec then
        PendingMag = math.sqrt((InputVec.X or 0)^2 + (InputVec.Y or 0)^2 + (InputVec.Z or 0)^2)
    end

    if not bLiveMoveInput and (SpeedSq > STOP_SPEED_SQ or PendingMag > STUCK_INPUT_THRESHOLD) then
        _inputState.noLiveInputMovingFrames = (_inputState.noLiveInputMovingFrames or 0) + 1
    else
        _inputState.noLiveInputMovingFrames = 0
    end

    if _inputState.noLiveInputMovingFrames >= STUCK_FRAMES and _stuckInputRecoveryCooldown <= 0 then
        _stuckInputRecoveryCooldown = RECOVERY_COOLDOWN
        _inputState.noLiveInputMovingFrames = 0
        RecoverStuckInput(Pawn)
    end

    _lastFrameDeltaTime = DeltaTime
end

local function HandleSprintToggleInput(Pawn)
    if not Pawn or Pawn.bIsMineCarMode then
        return
    end

    if Pawn._sprintToggleRequested ~= true then
        return
    end
    Pawn._sprintToggleRequested = false

    local Now = 0
    if os and os.clock then
        Now = os.clock()
    end
    if Pawn._lastSprintToggleTime and Now > 0 and Now - Pawn._lastSprintToggleTime < SPRINT_TOGGLE_DEBOUNCE then
        return
    end
    Pawn._lastSprintToggleTime = Now

    Pawn.bSprintToggleEnabled = not (Pawn.bSprintToggleEnabled == true)
    ugcprint("[SprintToggle] toggled:", tostring(Pawn.bSprintToggleEnabled))
    if Pawn.Server_SetSprintToggle then
        pcall(Pawn.Server_SetSprintToggle, Pawn, Pawn.bSprintToggleEnabled == true)
    end

    if Pawn.bSprintToggleEnabled ~= true then
        ClearSprintMovementRuntime(Pawn)
        RecoverStuckInput(Pawn)
        if Pawn.Server_ResetMoveSpeedAfterSprint then
            pcall(Pawn.Server_ResetMoveSpeedAfterSprint, Pawn)
        end
    end
end

function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)
    
    DetectAndRecoverStuckInputStrict(self, DeltaTime)
    PollSprintToggleKey(self)
    HandleSprintToggleInput(self)
    
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
    return "Server_SetMineCarMode", "Server_SetSprintToggle", "Server_ResetMoveSpeedAfterSprint"
end

return UGCPlayerPawn
