---@class Alloy_drill_C:PESkillTemplate_Base_C
--Edit Below--
local Alloy_drill = {}
 
function Alloy_drill:OnEnableSkill_BP()
    Alloy_drill.SuperClass.OnEnableSkill_BP(self)
end

function Alloy_drill:OnDisableSkill_BP()
    Alloy_drill.SuperClass.OnDisableSkill_BP(self)
end

function Alloy_drill:OnActivateSkill_BP()
    Alloy_drill.SuperClass.OnActivateSkill_BP(self)
end

function Alloy_drill:OnDeActivateSkill_BP()
    Alloy_drill.SuperClass.OnDeActivateSkill_BP(self)
end

function Alloy_drill:CanActivateSkill_BP()
    return Alloy_drill.SuperClass.CanActivateSkill_BP(self)
end

return Alloy_drill