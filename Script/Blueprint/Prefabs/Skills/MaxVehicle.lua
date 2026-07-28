---@class MaxVehicle_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local MaxVehicle = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}

function MaxVehicle:OnApply_BP()
    MaxVehicle.SuperClass.OnApply_BP(self)
    if not self:HasAuthority() then
        local Character = self:GetNetOwnerActor()
        self.ParticleSystemComponent = GameplayStatics.SpawnEmitterAttachedToActor(self.Particle, Character.Mesh, "root", Vector.New(0,0,10), Rotator.New(0, 0, 0), Vector.New(1, 1, 1), EAttachLocation.SnapToTarget, true)
    end
end

function MaxVehicle:OnDisableSkill_BP()
    MaxVehicle.SuperClass.OnDisableSkill_BP(self)
end

function MaxVehicle:OnUnApply_BP()
    MaxVehicle.SuperClass.OnUnApply_BP(self)
    if not self:HasAuthority() then
        if self.ParticleSystemComponent then
            self.ParticleSystemComponent:K2_DestroyComponent()
            self.ParticleSystemComponent = nil
        end
    end
end

function MaxVehicle:OnActivateSkill_BP()
    MaxVehicle.SuperClass.OnActivateSkill_BP(self)
end

function MaxVehicle:OnDeActivateSkill_BP()
    MaxVehicle.SuperClass.OnDeActivateSkill_BP(self)
end

function MaxVehicle:CanActivateSkill_BP()
    return MaxVehicle.SuperClass.CanActivateSkill_BP(self)
end

return MaxVehicle
