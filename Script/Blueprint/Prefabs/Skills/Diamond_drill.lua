---@class Diamond_drill_C:PESkillTemplate_Base_C
--Edit Below--
local Diamond_drill = {}
 
function Diamond_drill:OnEnableSkill_BP()
    Diamond_drill.SuperClass.OnEnableSkill_BP(self)
end

function Diamond_drill:OnDisableSkill_BP()
    Diamond_drill.SuperClass.OnDisableSkill_BP(self)
end

function Diamond_drill:OnActivateSkill_BP()
    Diamond_drill.SuperClass.OnActivateSkill_BP(self)
end

function Diamond_drill:OnDeActivateSkill_BP()
    Diamond_drill.SuperClass.OnDeActivateSkill_BP(self)
end

function Diamond_drill:CanActivateSkill_BP()
    return Diamond_drill.SuperClass.CanActivateSkill_BP(self)
end

return Diamond_drill