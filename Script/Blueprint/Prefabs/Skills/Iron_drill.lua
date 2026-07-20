---@class Iron_drill_C:PESkillTemplate_Base_C
--Edit Below--
local Iron_drill = {}
 
function Iron_drill:OnEnableSkill_BP()
    Iron_drill.SuperClass.OnEnableSkill_BP(self)
end

function Iron_drill:OnDisableSkill_BP()
    Iron_drill.SuperClass.OnDisableSkill_BP(self)
end

function Iron_drill:OnActivateSkill_BP()
    Iron_drill.SuperClass.OnActivateSkill_BP(self)
end

function Iron_drill:OnDeActivateSkill_BP()
    Iron_drill.SuperClass.OnDeActivateSkill_BP(self)
end

function Iron_drill:CanActivateSkill_BP()
    return Iron_drill.SuperClass.CanActivateSkill_BP(self)
end

return Iron_drill