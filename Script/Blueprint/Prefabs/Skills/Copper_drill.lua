---@class Copper_drill_C:PESkillTemplate_Base_C
--Edit Below--
local Copper_drill = {}
 
function Copper_drill:OnEnableSkill_BP()
    Copper_drill.SuperClass.OnEnableSkill_BP(self)
end

function Copper_drill:OnDisableSkill_BP()
    Copper_drill.SuperClass.OnDisableSkill_BP(self)
end

function Copper_drill:OnActivateSkill_BP()
    Copper_drill.SuperClass.OnActivateSkill_BP(self)
end

function Copper_drill:OnDeActivateSkill_BP()
    Copper_drill.SuperClass.OnDeActivateSkill_BP(self)
end

function Copper_drill:CanActivateSkill_BP()
    return Copper_drill.SuperClass.CanActivateSkill_BP(self)
end

return Copper_drill