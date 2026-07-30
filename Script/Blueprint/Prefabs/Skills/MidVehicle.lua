---@class MidVehicle_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local MidVehicle = {
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

function MidVehicle:OnApply_BP()
    MidVehicle.SuperClass.OnApply_BP(self)
    if not self:HasAuthority() then
        DestroyParticle(self)
    end
end

function MidVehicle:OnDisableSkill_BP()
    MidVehicle.SuperClass.OnDisableSkill_BP(self)
    DestroyParticle(self)
end

function MidVehicle:OnUnApply_BP()
    MidVehicle.SuperClass.OnUnApply_BP(self)
    DestroyParticle(self)
end

function MidVehicle:OnActivateSkill_BP()
    MidVehicle.SuperClass.OnActivateSkill_BP(self)
end

function MidVehicle:OnDeActivateSkill_BP()
    MidVehicle.SuperClass.OnDeActivateSkill_BP(self)
    DestroyParticle(self)
end

function MidVehicle:CanActivateSkill_BP()
    return MidVehicle.SuperClass.CanActivateSkill_BP(self)
end

return MidVehicle
