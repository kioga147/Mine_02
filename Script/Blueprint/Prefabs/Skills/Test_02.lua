---@class Test_02_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local Test_02 = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}
 
function Test_02:OnApply_BP()
    Test_02.SuperClass.OnApply_BP(self)
    print("Test_02:OnApply_BP")
    if not self:HasAuthority() then
        local Character = self:GetNetOwnerActor()
        self.ParticleSystemComponent = GameplayStatics.SpawnEmitterAttachedToActor(self.Particle, Character.Mesh, "root", Vector.New(0,0,10), Rotator.New(0, 0, 0), Vector.New(1, 1, 1), EAttachLocation.SnapToTarget, true)
    end
end

function Test_02:OnDisableSkill_BP()
    Test_02.SuperClass.OnDisableSkill_BP(self)

end

function Test_02:OnUnApply_BP()
    Test_02.SuperClass.OnUnApply_BP(self)
    print("Test_02:OnUnApply_BP")
    if not self:HasAuthority() then
        if (self.ParticleSystemComponent) then
            self.ParticleSystemComponent:K2_DestroyComponent()
        end
    end
end

function Test_02:OnActivateSkill_BP()
    Test_02.SuperClass.OnActivateSkill_BP(self)
end

function Test_02:OnDeActivateSkill_BP()
    Test_02.SuperClass.OnDeActivateSkill_BP(self)
end

function Test_02:CanActivateSkill_BP()
    return Test_02.SuperClass.CanActivateSkill_BP(self)
end

return Test_02