---@class Iron_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Iron_pickaxe = {}
 
function Iron_pickaxe:OnEnableSkill_BP()
    Iron_pickaxe.SuperClass.OnEnableSkill_BP(self)
end

function Iron_pickaxe:OnDisableSkill_BP()
    Iron_pickaxe.SuperClass.OnDisableSkill_BP(self)
end

function Iron_pickaxe:OnActivateSkill_BP()
    Iron_pickaxe.SuperClass.OnActivateSkill_BP(self)
end

function Iron_pickaxe:OnDeActivateSkill_BP()
    Iron_pickaxe.SuperClass.OnDeActivateSkill_BP(self)
end

function Iron_pickaxe:CanActivateSkill_BP()
    return Iron_pickaxe.SuperClass.CanActivateSkill_BP(self)
end

return Iron_pickaxe