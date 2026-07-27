---@class MidVehicle_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local MidVehicle = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}

function MidVehicle:OnApply_BP()
    MidVehicle.SuperClass.OnApply_BP(self)
    if not self:HasAuthority() then
        local Character = self:GetNetOwnerActor()
        self.ParticleSystemComponent = GameplayStatics.SpawnEmitterAttachedToActor(self.Particle, Character.Mesh, "root", Vector.New(0,0,10), Rotator.New(0, 0, 0), Vector.New(1, 1, 1), EAttachLocation.SnapToTarget, true)
    end
end

function MidVehicle:OnDisableSkill_BP()
    MidVehicle.SuperClass.OnDisableSkill_BP(self)
end

function MidVehicle:OnUnApply_BP()
    MidVehicle.SuperClass.OnUnApply_BP(self)
    if not self:HasAuthority() then
        if self.ParticleSystemComponent then
            self.ParticleSystemComponent:K2_DestroyComponent()
            self.ParticleSystemComponent = nil
        end
    end
end

function MidVehicle:OnActivateSkill_BP()
    MidVehicle.SuperClass.OnActivateSkill_BP(self)
end

function MidVehicle:OnDeActivateSkill_BP()
    MidVehicle.SuperClass.OnDeActivateSkill_BP(self)
end

function MidVehicle:CanActivateSkill_BP()
    return MidVehicle.SuperClass.CanActivateSkill_BP(self)
end

return MidVehicle
