---@class Act_01_C:PESkillTemplate_Base_C
--Edit Below--
local Act_2 = {}
 
function Act_2:OnEnableSkill_BP()
    Act_2.SuperClass.OnEnableSkill_BP(self)
end

function Act_2:OnDisableSkill_BP()
    Act_2.SuperClass.OnDisableSkill_BP(self)
end

function Act_2:OnActivateSkill_BP()
    Act_2.SuperClass.OnActivateSkill_BP(self)
end

function Act_2:OnDeActivateSkill_BP()
    Act_2.SuperClass.OnDeActivateSkill_BP(self)
end

function Act_2:CanActivateSkill_BP()
    return Act_2.SuperClass.CanActivateSkill_BP(self)
end

return Act_2