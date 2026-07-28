---@class Test_02_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local BasicVehicle = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}

function BasicVehicle:OnApply_BP()
    BasicVehicle.SuperClass.OnApply_BP(self)
    if not self:HasAuthority() then
        local Character = self:GetNetOwnerActor()
        self.ParticleSystemComponent = GameplayStatics.SpawnEmitterAttachedToActor(self.Particle, Character.Mesh, "root", Vector.New(0,0,10), Rotator.New(0, 0, 0), Vector.New(1, 1, 1), EAttachLocation.SnapToTarget, true)
    end
end

function BasicVehicle:OnDisableSkill_BP()
    BasicVehicle.SuperClass.OnDisableSkill_BP(self)
end

function BasicVehicle:OnUnApply_BP()
    BasicVehicle.SuperClass.OnUnApply_BP(self)
    if not self:HasAuthority() then
        if self.ParticleSystemComponent then
            self.ParticleSystemComponent:K2_DestroyComponent()
            self.ParticleSystemComponent = nil
        end
    end
end

function BasicVehicle:OnActivateSkill_BP()
    BasicVehicle.SuperClass.OnActivateSkill_BP(self)
end

function BasicVehicle:OnDeActivateSkill_BP()
    BasicVehicle.SuperClass.OnDeActivateSkill_BP(self)
end

function BasicVehicle:CanActivateSkill_BP()
    return BasicVehicle.SuperClass.CanActivateSkill_BP(self)
end

return BasicVehicle
