---@class Transform_Mningcar_C:PEBuff_Transform_C
--Edit Below--
local Transform_Mningcar = {
	TargetHealth = 0,
	SkillClass = LoadClass("/Script/ShadowTrackerExtra.PersistEffectSkill"),
	ChangeHealthDelegate = nil,
	CachedSkill = {},
    CachedAppliedSkill = {},
    CachedCapsuleRadius = 40.0,
    CachedCapsuleHeight = 88.0,
    CachedScale = {X=1,Y=1,Z=1},
    RestoreTargetLocation = {},
}

TransformMeshAndAnimType = UE.LoadEnum("/Game/UGC/UGCGame/Buff/BuffTemplate/Transform/TransformMeshAndAnimType")
TransformStaticMeshCollisionType = UE.LoadEnum("/Game/UGC/UGCGame/Buff/BuffTemplate/Transform/TransformStaticMeshCollisionType")


function Transform_Mningcar:OnApply_BP()
	if self:HasAuthority() then
		self:InitExtraHealth()
		self:InitSkill()
        self:InitMesh()
        if self:CheckOverlap() then
            self:OnTransformFailed()
        end
    else
        self:InitMesh()
        self:InitAnim()
        if self:IsAutonomous(true) then
            self:InitCamera()
        end
	end
end


function Transform_Mningcar:OnUnApply_BP()
	if self:HasAuthority() then
        self:RestoreExtraHealth()
        self:RestoreSkill()
        self:RestoreMesh()
    else
        self:RestoreMesh()
        self:RestoreAnim()
        if self:IsAutonomous(true) then
            self:RestoreCamera()
        end
	end
end


function Transform_Mningcar:CheckOverlap()
    local OverlapActors = {}
    local ObjectTypes = {0,1,2,3,4,5,6,7}
    if self.TransformMeshAndAnimType == TransformMeshAndAnimType.Pawn then
        local CapsuleComp = self:GetOwnerActor().CapsuleComponent
        if not CapsuleComp then
            return true
        end
        OverlapActors = UGCActorComponentUtility.GetOverlappingActorsWithPrimitiveComponent(CapsuleComp, UGCActorComponentUtility.GetSceneComponentWorldTransform(CapsuleComp), ObjectTypes, nil, {self:GetOwnerActor()})
    elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Static then
        if self.CollisionType == TransformStaticMeshCollisionType.Capsule then
            local CapsuleComp = self:GetOwnerActor().CapsuleComponent
            if not CapsuleComp then
                return true
            end
            OverlapActors = UGCActorComponentUtility.GetOverlappingActorsWithPrimitiveComponent(CapsuleComp, UGCActorComponentUtility.GetSceneComponentWorldTransform(CapsuleComp), ObjectTypes, nil, {self:GetOwnerActor()})
        elseif self.CollisionType == TransformStaticMeshCollisionType.Box then
            if not self.BoxCollisionComp then
                return true
            end
            OverlapActors = UGCActorComponentUtility.GetOverlappingActorsWithPrimitiveComponent(self.BoxCollisionComp, UGCActorComponentUtility.GetSceneComponentWorldTransform(self.BoxCollisionComp), ObjectTypes, nil, {self:GetOwnerActor()})
        end
    end

    return #OverlapActors > 0
end


function Transform_Mningcar:OnTransformFailed()
    self:RestoreExtraHealth()
    self:RestoreSkill()
    self:RestoreMesh()
    UGCWidgetManagerSystem.ShowTipsUIWithPC("变身失败，空间不足", UGCGameSystem.GetPlayerControllerByPlayerPawn(self:GetOwnerActor()))
    self:Cancel(EPersistEffectUnApplyReason.Cancel)
end


function Transform_Mningcar:InitExtraHealth()
	if not self.EnableExtraHealth then
		self.ExtraHealth = 0
	else
		local TargetHealth = UGCAttributeSystem.GetGameAttributeValue(self:GetOwnerActor(), "Health")
		self.ChangeHealthDelegate = UGCAttributeSystem.AddGameAttributeChangedDelegate(self:GetOwnerActor(), "Health", function(Owner, AttrName, CurValue)
            print("Transform_Mningcar: Health Change, AttrName:" .. AttrName .. ", CurValue: " .. CurValue)
            if CurValue <= TargetHealth then
                self:Cancel(EPersistEffectUnApplyReason.Cancel)
            end
        end)
	end
end


function Transform_Mningcar:RestoreExtraHealth()
    UGCAttributeSystem.RemoveGameAttributeChangedDelegate(self:GetOwnerActor(), "Health", self.ChangeHealthDelegate)
    if self:GetOwnerActor():GetHealth() > self:GetOwnerActor():GetHealthMax() then
        self:GetOwnerActor():SetHealth(self:GetOwnerActor():GetHealthMax(), ERecoveryReasonType.ERecoveryReason_Skill)
    end
end


function Transform_Mningcar:GetExtraHealth()
	if not self.EnableExtraHealth then
		return 0
	else
        return self.ExtraHealth
    end
end

function Transform_Mningcar:GetRestoreExtraHealth()
	if not self.EnableExtraHealth then
		return 0
	else
        return -self.ExtraHealth
    end
end


function Transform_Mningcar:InitSkill()
	local PEComp = UGCPersistEffectSystem.GetPersistBaseComponentByContent(self:GetOwnerActor())
	if not PEComp then
		return
	end

    for _, SkillClass in pairs(self.ApplySkills) do
        local Skill = UGCPersistEffectSystem.AddSkillByClass(self:GetOwnerActor(), SkillClass)
        table.insert(self.CachedAppliedSkill, Skill)
	end
    
    self:ReapplyCurrentWeaponSkills()
end

function Transform_Mningcar:ReapplyCurrentWeaponSkills()
    local PlayerPawn = self:GetOwnerActor()
    if not PlayerPawn then
        return
    end
    
    ugcprint("[矿车变身] 直接添加BasicVehicle技能")
    
    local SkillPath = "Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C"
    local FullPath = UGCGameSystem.GetUGCResourcesFullPath(SkillPath)
    ugcprint("[矿车变身] 技能路径:", FullPath)
    
    local SkillClass = UGCObjectUtility.LoadClass(FullPath)
    if SkillClass then
        ugcprint("[矿车变身] 技能类加载成功:", tostring(SkillClass))
        
        local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn, SkillClass)
        ugcprint("[矿车变身] 已有技能数量:", #ExistSkills)
        
        if #ExistSkills == 0 then
            local Skill = UGCPersistEffectSystem.AddSkillByClass(PlayerPawn, SkillClass, -1)
            if Skill then
                ugcprint("[矿车变身] ✅ 成功添加BasicVehicle技能")
                table.insert(self.CachedAppliedSkill, Skill)
                
                if Skill.OnApply_BP then
                    pcall(Skill.OnApply_BP, Skill)
                    ugcprint("[矿车变身] ✅ 已调用OnApply_BP")
                end
            else
                ugcprint("[矿车变身] ❌ 添加技能失败")
            end
        else
            ugcprint("[矿车变身] ⚠️ 技能已存在")
            local Skill = ExistSkills[1]
            if Skill then
                ugcprint("[矿车变身] 技能状态 IsActive:", tostring(Skill.IsActive))
                local bAlreadyCached = false
                for _, CachedSkill in ipairs(self.CachedAppliedSkill or {}) do
                    if CachedSkill == Skill then
                        bAlreadyCached = true
                        break
                    end
                end
                if not bAlreadyCached then
                    table.insert(self.CachedAppliedSkill, Skill)
                end
            end
        end
    else
        ugcprint("[矿车变身] ❌ 无法加载技能类")
    end
    
    local AllSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn)
    ugcprint("[矿车变身] 玩家当前技能总数:", #AllSkills)
end


function Transform_Mningcar:RestoreSkill()
    for _, PE in pairs(self.CachedAppliedSkill) do
        if UE.IsValid(PE) then
            PE:Cancel(EPersistEffectUnApplyReason.Normal)
        end
    end
    self.CachedAppliedSkill = {}
end


function Transform_Mningcar:InitMesh()
    if self:HasAuthority() then
        if self.TransformMeshAndAnimType == TransformMeshAndAnimType.Pawn then
            self:InitPawnMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Static then
            self:InitStaticMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Preset then
            self:InitPresetMesh()
        end
    else
        if self.TransformMeshAndAnimType == TransformMeshAndAnimType.Pawn then
            self:InitPawnMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Static then
            self:InitStaticMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Preset then
            self:InitPresetMesh()
        end
    end
end


function Transform_Mningcar:InitPawnMesh()
    self.CachedScale = self:GetOwnerActor():GetActorScale3D()
    self:GetOwnerActor():SetActorScale3D(self.TransformScale)
    if self:HasAuthority() then
        --- 大小更改后调整角色位置到地面
        local ActorLocation = self:GetOwnerActor():K2_GetActorLocation()
        ActorLocation.Z = ActorLocation.Z + (self.TransformScale.Z - self.CachedScale.Z) * self:GetOwnerActor().CapsuleComponent:GetUnscaledCapsuleHalfHeight()
        self:GetOwnerActor():DSTeleportToLocationOrRotation(ActorLocation, {}, true, false, true)

        UGCPlayerPawnSystem.ChangeAvatarMesh(self:GetOwnerActor(), self.TransformSkeletalMesh)
        
        if UGCTimerManagerSystem and UGCTimerManagerSystem.SetTimer then
            UGCTimerManagerSystem.SetTimer(function()
                self:ReapplyCurrentWeaponSkills()
            end, 0.5, false)
        else
            self:ReapplyCurrentWeaponSkills()
        end
    end
    
end


function Transform_Mningcar:InitStaticMesh()
    if self:HasAuthority() then
        self:GetOwnerActor():SwitchPoseState(ESTEPoseState.Stand)
    end
    --- Collision
    self.CachedCapsuleRadius = self:GetOwnerActor().CapsuleComponent:GetUnscaledCapsuleRadius()
    self.CachedCapsuleHeight = self:GetOwnerActor().CapsuleComponent:GetUnscaledCapsuleHalfHeight()

    if self.CollisionType == TransformStaticMeshCollisionType.Capsule then
        self:GetOwnerActor().CapsuleComponent:SetCapsuleSize(self.CapsuleRadius, self.CapsuleHeight, true)

        if self:HasAuthority() then
            --- 大小更改后调整角色位置到地面
            local ActorLocation = self:GetOwnerActor():K2_GetActorLocation()
            ActorLocation.Z = ActorLocation.Z + (self.CapsuleHeight - self.CachedCapsuleHeight)
            self:GetOwnerActor():DSTeleportToLocationOrRotation(ActorLocation, {}, true, false, true)
        end
    elseif self.CollisionType == TransformStaticMeshCollisionType.Box then
        -- 设置Capsule高度和Box一致用来检测地面
        self:GetOwnerActor().CapsuleComponent:SetCapsuleSize(1, self.BoxExtend.Z, true)

        self.BoxCollisionComp = STExtraGameplayStatics.DynamicCreateComponents(self:GetOwnerActor(), LoadClass("/Script/Engine.BoxComponent"))
        self.BoxCollisionComp.ComponentTags:Add("TransformCollision")
        self.BoxCollisionComp:K2_AttachToComponent(self:GetOwnerActor().CapsuleComponent, nil, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, true)
        self.BoxCollisionComp:K2_SetRelativeLocationAndRotation({0,0,0}, {0,0,0}, false, nil, false)
        self.BoxCollisionComp:SetBoxExtent(self.BoxExtend, true)
        self.BoxCollisionComp:SetCollisionProfileName("Pawn")

        if self:HasAuthority() then
            UGCPersistEffectSystem.EnterDynamicState(self:GetOwnerActor(), "PawnState.Transformation.BoxCollision")
            --- 大小更改后调整角色位置到地面
            local ActorLocation = self:GetOwnerActor():K2_GetActorLocation()
            ActorLocation.Z = ActorLocation.Z + (self.BoxExtend.Z - self.CachedCapsuleHeight)
            self:GetOwnerActor():DSTeleportToLocationOrRotation(ActorLocation, {}, true, false, true)
        end
    end

    --- Mesh
    self.StaticMesh = STExtraGameplayStatics.DynamicCreateComponents(self:GetOwnerActor(), LoadClass("/Script/Engine.StaticMeshComponent"))
    self.StaticMesh:K2_AttachToComponent(self:GetOwnerActor().MeshContainer, nil, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, true)
    self.StaticMesh:K2_SetRelativeTransform(self.MeshRelativeTransform, false, nil, false)
    self.StaticMesh:SetStaticMesh(self.TransformStaticMesh)
    self.StaticMesh:SetCollisionEnabled(ECollisionEnabled.QueryAndPhysics)

    if not self:HasAuthority() then
        self.HideTask = UGCGameplayTaskSystem.PlayerPawn.SetMaterial.NewTask(self, self:GetNetOwnerActor(), self.HideMaterial)
    end
end


function Transform_Mningcar:InitPresetMesh()
    if self:HasAuthority() then
        self:GetOwnerActor():SwitchPoseState(ESTEPoseState.Stand)
    end
        --- Collision
    self.CachedCapsuleRadius = self:GetOwnerActor().CapsuleComponent:GetUnscaledCapsuleRadius()
    self.CachedCapsuleHeight = self:GetOwnerActor().CapsuleComponent:GetUnscaledCapsuleHalfHeight()

    if self.CollisionType == TransformStaticMeshCollisionType.Capsule then
        self:GetOwnerActor().CapsuleComponent:SetCapsuleSize(self.PresetCapsuleRadius, self.PresetCapsuleHeight, true)

        if self:HasAuthority() then
            --- 大小更改后调整角色位置到地面
            local ActorLocation = self:GetOwnerActor():K2_GetActorLocation()
            ActorLocation.Z = ActorLocation.Z + (self.CapsuleHeight - self.CachedCapsuleHeight)
            self:GetOwnerActor():DSTeleportToLocationOrRotation(ActorLocation, {}, true, false, true)
        end
    elseif self.CollisionType == TransformStaticMeshCollisionType.Box then
        -- 设置Capsule高度和Box一致用来检测地面
        self:GetOwnerActor().CapsuleComponent:SetCapsuleSize(1, self.PresetBoxExtend.Z, true)

        self.BoxCollisionComp = STExtraGameplayStatics.DynamicCreateComponents(self:GetOwnerActor(), LoadClass("/Script/Engine.BoxComponent"))
        self.BoxCollisionComp.ComponentTags:Add("TransformCollision")
        self.BoxCollisionComp:K2_AttachToComponent(self:GetOwnerActor().CapsuleComponent, nil, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, true)
        self.BoxCollisionComp:K2_SetRelativeLocationAndRotation({0,0,0}, {0,0,0}, false, nil, false)
        self.BoxCollisionComp:SetBoxExtent(self.PresetBoxExtend, true)
        self.BoxCollisionComp:SetCollisionProfileName("Pawn")

        if self:HasAuthority() then
            UGCPersistEffectSystem.EnterDynamicState(self:GetOwnerActor(), "PawnState.Transformation.BoxCollision")
            --- 大小更改后调整角色位置到地面
            local ActorLocation = self:GetOwnerActor():K2_GetActorLocation()
            ActorLocation.Z = ActorLocation.Z + (self.PresetBoxExtend.Z - self.CachedCapsuleHeight)
            self:GetOwnerActor():DSTeleportToLocationOrRotation(ActorLocation, {}, true, false, true)
        end
    end

    --- Mesh
    self.SkeletalMeshComp = STExtraGameplayStatics.DynamicCreateComponents(self:GetOwnerActor(), LoadClass("/Script/Engine.SkeletalMeshComponent"))
    self.SkeletalMeshComp:K2_AttachToComponent(self:GetOwnerActor().MeshContainer, nil, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, EAttachmentRule.KeepWorld, true)
    self.SkeletalMeshComp:K2_SetRelativeTransform(self.MeshRelativeTransform, false, nil, false)
    self.SkeletalMeshComp:SetSkeletalMesh(self.TransformSkeletalMesh, true, false, true)
    self.SkeletalMeshComp:SetCollisionEnabled(ECollisionEnabled.QueryAndPhysics)

    if not self:HasAuthority() then
        self.HideTask = UGCGameplayTaskSystem.PlayerPawn.SetMaterial.NewTask(self, self:GetNetOwnerActor(), self.HideMaterial)
    end
end

function Transform_Mningcar:RestoreMesh()
    if self:HasAuthority() then
        if self.TransformMeshAndAnimType == TransformMeshAndAnimType.Pawn then
            self:RestorePawnMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Static then
            self:RestoreStaticMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Preset then
            self:RestorePresetMesh()
        end

        local DetectObjectTypes = {0,1,2,3,4,5,6,7}
        local bSuccess, TargetLocation = UGCSceneQueryUtility.FindPositionToHoldCapsule(self, self.RestoreTargetLocation, self:GetOwnerActor():K2_GetActorRotation(), self.CachedCapsuleRadius, self.CachedCapsuleHeight, {self:GetOwnerActor()}, DetectObjectTypes, 32, true, true)
        if bSuccess then
            print("TargetLocation, X:"..TargetLocation.X..", Y:"..TargetLocation.Y..", Z:"..TargetLocation.Z)
            self:GetOwnerActor():DSTeleportToLocationOrRotation(TargetLocation, {}, true, false, true)
        else
            ---原地被迫还原
            self:GetOwnerActor():DSTeleportToLocationOrRotation(self.RestoreTargetLocation, {}, true, false, true)
        end

    else
        if self.TransformMeshAndAnimType == TransformMeshAndAnimType.Pawn then
            self:RestorePawnMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Static then
            self:RestoreStaticMesh()
        elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Preset then
            self:RestorePresetMesh()
        end
    end
end


function Transform_Mningcar:RestorePawnMesh()
    self:GetOwnerActor():SetActorScale3D(self.CachedScale)

    if self:HasAuthority() then
        --- 大小还原后调整角色位置到地面
        self.RestoreTargetLocation = self:GetOwnerActor():K2_GetActorLocation()
        self.RestoreTargetLocation.Z = self.RestoreTargetLocation.Z + (self.CachedScale.Z - self.TransformScale.Z) * self:GetOwnerActor().CapsuleComponent:GetUnscaledCapsuleHalfHeight()
        
        UGCPawnSystem.RecoverAvatarMesh(self:GetOwnerActor())
    end
end


function Transform_Mningcar:RestoreStaticMesh()
    self.StaticMesh:K2_DestroyComponent(self.StaticMesh)

    if self.CollisionType == TransformStaticMeshCollisionType.Capsule then
        if self:HasAuthority() then
            --- 大小还原后调整角色位置到地面
            self.RestoreTargetLocation = self:GetOwnerActor():K2_GetActorLocation()
            self.RestoreTargetLocation.Z = self.RestoreTargetLocation.Z + (self.CachedCapsuleHeight - self.CapsuleHeight)
        end
    elseif self.CollisionType == TransformStaticMeshCollisionType.Box then
        if UE.IsValid(self.BoxCollisionComp) then
            self.BoxCollisionComp:K2_DestroyComponent(self.BoxCollisionComp)
        end
        if self:HasAuthority() then
            UGCPersistEffectSystem.LeaveDynamicState(self:GetOwnerActor(), "PawnState.Transformation.BoxCollision")
            --- 大小还原后调整角色位置到地面
            self.RestoreTargetLocation = self:GetOwnerActor():K2_GetActorLocation()
            self.RestoreTargetLocation.Z = self.RestoreTargetLocation.Z + (self.CachedCapsuleHeight - self.BoxExtend.Z)
        end
    end
    self:GetOwnerActor().CapsuleComponent:SetCapsuleSize(self.CachedCapsuleRadius, self.CachedCapsuleHeight, true)

    if not self:HasAuthority() then
        if self.HideTask then
            self.HideTask:EndTask()
        end
    end
end


function Transform_Mningcar:RestorePresetMesh()
    self.SkeletalMeshComp:K2_DestroyComponent(self.SkeletalMeshComp)

    if self.CollisionType == TransformStaticMeshCollisionType.Capsule then
        if self:HasAuthority() then
            --- 大小还原后调整角色位置到地面
            self.RestoreTargetLocation = self:GetOwnerActor():K2_GetActorLocation()
            self.RestoreTargetLocation.Z = self.RestoreTargetLocation.Z + (self.CachedCapsuleHeight - self.PresetCapsuleHeight)
        end
    elseif self.CollisionType == TransformStaticMeshCollisionType.Box then
        if UE.IsValid(self.BoxCollisionComp) then
            self.BoxCollisionComp:K2_DestroyComponent(self.BoxCollisionComp)
        end
        if self:HasAuthority() then
            UGCPersistEffectSystem.LeaveDynamicState(self:GetOwnerActor(), "PawnState.Transformation.BoxCollision")
            --- 大小还原后调整角色位置到地面
            self.RestoreTargetLocation = self:GetOwnerActor():K2_GetActorLocation()
            self.RestoreTargetLocation.Z = self.RestoreTargetLocation.Z + (self.CachedCapsuleHeight - self.PresetBoxExtend.Z)
        end
    end
    self:GetOwnerActor().CapsuleComponent:SetCapsuleSize(self.CachedCapsuleRadius, self.CachedCapsuleHeight, true)

    if not self:HasAuthority() then
        if self.HideTask then
            self.HideTask:EndTask()
        end
    end
end


function Transform_Mningcar:InitAnim()
    require("ugc.UGCAPI.UGCGameplayTaskSystem")
    if self.TransformMeshAndAnimType == TransformMeshAndAnimType.Pawn then
        self.AnimTaskHandle = UGCGameplayTaskSystem.PlayerPawn.ReplaceAnim.NewTask(self, self:GetOwnerActor(), self.PawnAnimList:Copy())
    elseif self.TransformMeshAndAnimType == TransformMeshAndAnimType.Preset then
        self.SkeletalMeshComp:SetAnimInstanceClass(self.PresetTransformAnim, true)
    end
end


function Transform_Mningcar:RestoreAnim()
    if self.AnimTaskHandle then
        self.AnimTaskHandle:EndTask()
    end
end


function Transform_Mningcar:InitCamera()
    self.CameraTaskHandle = UGCGameplayTaskSystem.Player.AddCustomCameraData.NewTask(self, self:GetOwnerActor(), self.FadeInSpeed, self.Offset:Copy(), self.AdditiveOffsetFov, self.SpringArmLengthAdditive, self.SpringArmRotation:Copy())
end


function Transform_Mningcar:RestoreCamera()
    if self.CameraTaskHandle then
        self.CameraTaskHandle:EndTask()
    end
end



return Transform_Mningcar