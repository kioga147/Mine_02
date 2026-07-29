---@class Test_02_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local BasicVehicle = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}

local function DestroyParticle(Skill)
    if Skill and Skill.ParticleSystemComponent then
        pcall(function()
            Skill.ParticleSystemComponent:K2_DestroyComponent()
        end)
        Skill.ParticleSystemComponent = nil
    end
end

function BasicVehicle:OnApply_BP()
    BasicVehicle.SuperClass.OnApply_BP(self)
    if not self:HasAuthority() then
        DestroyParticle(self)
    end
end

function BasicVehicle:OnDisableSkill_BP()
    BasicVehicle.SuperClass.OnDisableSkill_BP(self)
    DestroyParticle(self)
end

function BasicVehicle:OnUnApply_BP()
    BasicVehicle.SuperClass.OnUnApply_BP(self)
    DestroyParticle(self)
end

function BasicVehicle:OnActivateSkill_BP()
    BasicVehicle.SuperClass.OnActivateSkill_BP(self)
end

function BasicVehicle:OnDeActivateSkill_BP()
    BasicVehicle.SuperClass.OnDeActivateSkill_BP(self)
    DestroyParticle(self)
end

function BasicVehicle:CanActivateSkill_BP()
    return BasicVehicle.SuperClass.CanActivateSkill_BP(self)
end

return BasicVehicle
