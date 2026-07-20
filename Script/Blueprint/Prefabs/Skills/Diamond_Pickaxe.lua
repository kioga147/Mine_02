---@class Diamond_Pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Diamond_Pickaxe = {}
 
function Diamond_Pickaxe:OnEnableSkill_BP()
    Diamond_Pickaxe.SuperClass.OnEnableSkill_BP(self)
end

function Diamond_Pickaxe:OnDisableSkill_BP()
    Diamond_Pickaxe.SuperClass.OnDisableSkill_BP(self)
end

function Diamond_Pickaxe:OnActivateSkill_BP()
    Diamond_Pickaxe.SuperClass.OnActivateSkill_BP(self)
end

function Diamond_Pickaxe:OnDeActivateSkill_BP()
    Diamond_Pickaxe.SuperClass.OnDeActivateSkill_BP(self)
end

function Diamond_Pickaxe:CanActivateSkill_BP()
    return Diamond_Pickaxe.SuperClass.CanActivateSkill_BP(self)
end

return Diamond_Pickaxe