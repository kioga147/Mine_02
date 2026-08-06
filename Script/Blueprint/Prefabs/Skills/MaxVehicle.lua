---@class MaxVehicle_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local MaxVehicle = {
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

function MaxVehicle:OnApply_BP()
    MaxVehicle.SuperClass.OnApply_BP(self)
    if not self:HasAuthority() then
        DestroyParticle(self)
    end
end

function MaxVehicle:OnDisableSkill_BP()
    MaxVehicle.SuperClass.OnDisableSkill_BP(self)
    DestroyParticle(self)
end

function MaxVehicle:OnUnApply_BP()
    MaxVehicle.SuperClass.OnUnApply_BP(self)
    DestroyParticle(self)
end

function MaxVehicle:OnActivateSkill_BP()
    MaxVehicle.SuperClass.OnActivateSkill_BP(self)
end

function MaxVehicle:OnDeActivateSkill_BP()
    MaxVehicle.SuperClass.OnDeActivateSkill_BP(self)
    DestroyParticle(self)
end

function MaxVehicle:CanActivateSkill_BP()
    return MaxVehicle.SuperClass.CanActivateSkill_BP(self)
end

return MaxVehicle
