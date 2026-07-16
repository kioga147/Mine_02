---@class BP_RightJoystick_C:UUserWidget
---@field Left UVirtualJoystick
---@field Right UVirtualJoystick
---@field EnableRightJoystickFire bool
---@field DeadZoneRange float
---@field FireModeAuto ULuaSetHelper<EWeaponTypeNew>
---@field FireModeSingle ULuaSetHelper<EWeaponTypeNew>
---@field MeleeThrowWeaponClass UClass
---@field ShootWeaponClass UClass
--Edit Below--
local BP_RightJoystick = { 
    bInitDoOnce = false,
    Character = nil,
    bIsFiring = false,
    bFirePrepared = false,
    LastWeaponType = nil,
    PreparedWeapon = nil,  -- 记录准备开火的武器实例
} 

---@param Character ASTExtraPlayerCharacter
---@param Weapon ASTExtraWeapon_Throw
local function CastMeleeSkill(Character, Weapon)
    for k, v in pairs(Weapon.WeaponSkillConfigs) do
        if v.bIsBindFireBtn then
            local SoftClassPathString = KismetSystemLibrary.Conv_SoftClassReferenceToString(v.SkillTemplateClass)
            local Cls = UGCObjectUtility.LoadClass(SoftClassPathString)
            local PersistEffectComp = Character:GetPersistBaseComponent()
            local PESkills = PersistEffectComp:GetPersistEffectDataByClass(Cls, false)
            if PESkills and #PESkills > 0 then
                PESkills[1]:ActivateSkill()
            end
        end
    end
end

---让指定的武器开火
---@param Weapon ASTExtraWeapon 
function BP_RightJoystick:FireByWeapon(Weapon)
    if UGCObjectUtility.IsA(Weapon, self.ShootWeaponClass) then
        ---可射击武器
        UGCGunSystem.StartFire(Weapon)
    elseif UGCObjectUtility.IsA(Weapon, self.MeleeThrowWeaponClass) then
        ---投掷物和近战武器
        if Weapon:GetWeaponTypeNew() == EWeaponTypeNew.EWeaponTypeNew_Melee then
            ---近战武器
            CastMeleeSkill(self.Character, Weapon)
        elseif Weapon:GetWeaponTypeNew() == EWeaponTypeNew.EWeaponTypeNew_ThrownObj then
            ---投掷物

        end
    end
end
---让指定的武器停止开火
---@param Weapon ASTExtraWeapon 
function BP_RightJoystick:StopFireByWeapon(Weapon)
    if UGCObjectUtility.IsA(Weapon, self.ShootWeaponClass) then
        ---可射击武器
        UGCGunSystem.StopFire(Weapon)
    elseif UGCObjectUtility.IsA(Weapon, self.MeleeThrowWeaponClass) then
        if Weapon:GetWeaponTypeNew() == EWeaponTypeNew.EWeaponTypeNew_ThrownObj then
            ---投掷物

        end
    end
end

function BP_RightJoystick:Construct()
    self.Character = UGCGameSystem.GetLocalPlayerPawn()

    local function OnRightMoved(Joystick, _Vector2D)
        
        -- 计算摇杆距离
        local DistanceSquared = UGCMathUtility.VSizeSquared2D(_Vector2D)
        local DeadZoneSquared = self.DeadZoneRange * self.DeadZoneRange
        
        -- 超过死区范围的处理
        if DistanceSquared > DeadZoneSquared then
            if self.EnableRightJoystickFire then
                local CurrentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(self.Character)
                if CurrentWeapon and CurrentWeapon.GetWeaponTypeNew then
                    local Type = CurrentWeapon:GetWeaponTypeNew()
                    self.LastWeaponType = Type
                    
                    -- 全自动枪械处理
                    if self.FireModeAuto:Contains(Type) then
                        -- 开始持续开火
                        if not self.bIsFiring then
                            self.bIsFiring = true
                            self.Character:StartFire()
                        end
                    -- 单发枪械处理
                    elseif self.FireModeSingle:Contains(Type) then
                        -- 记录准备开火状态和武器实例
                        self.bFirePrepared = true
                        self.PreparedWeapon = CurrentWeapon
                    end
                end
            end
        -- 在死区范围内的处理
        else
            -- 全自动枪械停止开火
            if self.bIsFiring and self.EnableRightJoystickFire then
                local CurrentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(self.Character)
                if CurrentWeapon then
                    self:StopFireByWeapon(CurrentWeapon)
                    self.bIsFiring = false
                end
            end
            
            -- 单发枪械清除准备状态（回到死区不开火）
            self.bFirePrepared = false
            self.PreparedWeapon = nil
        end
    end
	self.Right.OnMoved:Add(OnRightMoved, self)
    local function OnRightReleased()
        -- 停止全自动开火
        if self.bIsFiring and self.EnableRightJoystickFire then
            local CurrentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(self.Character)
            if CurrentWeapon then
                self:StopFireByWeapon(CurrentWeapon)
                self.bIsFiring = false
            end
        end
        
        -- 单发枪械执行开火（检查是否为同一个武器）
        if self.bFirePrepared and self.EnableRightJoystickFire then
            local CurrentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(self.Character)
            -- 只有当前武器与准备开火的武器是同一个时才执行开火
            local Type = CurrentWeapon:GetWeaponTypeNew()
            if CurrentWeapon and CurrentWeapon == self.PreparedWeapon then
                self.Character:StartFire()       
            end
        end
        
        -- 清除所有状态
        self.bIsFiring = false
        self.bFirePrepared = false
        self.PreparedWeapon = nil
        self.LastWeaponType = nil
    end
	self.Right.OnReleased:Add(OnRightReleased, self)
end


-- function BP_RightJoystick:Tick(MyGeometry, InDeltaTime)

-- end

-- function BP_RightJoystick:Destruct()

-- end

return BP_RightJoystick