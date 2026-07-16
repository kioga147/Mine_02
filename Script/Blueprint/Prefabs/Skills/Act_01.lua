---@class Act_01_C:PESkillTemplate_Base_C
--Edit Below--
local Act_01 = {}
 
function Act_01:OnEnableSkill_BP()
    Act_01.SuperClass.OnEnableSkill_BP(self)
end

function Act_01:OnDisableSkill_BP()
    Act_01.SuperClass.OnDisableSkill_BP(self)
end

function Act_01:OnActivateSkill_BP()
    Act_01.SuperClass.OnActivateSkill_BP(self)
end

function Act_01:OnDeActivateSkill_BP()
    Act_01.SuperClass.OnDeActivateSkill_BP(self)
end

function Act_01:CanActivateSkill_BP()
    return Act_01.SuperClass.CanActivateSkill_BP(self)
end

return Act_01