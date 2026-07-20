---@class Copper_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Copper_pickaxe = {}
 
function Copper_pickaxe:OnEnableSkill_BP()
    Copper_pickaxe.SuperClass.OnEnableSkill_BP(self)
end

function Copper_pickaxe:OnDisableSkill_BP()
    Copper_pickaxe.SuperClass.OnDisableSkill_BP(self)
end

function Copper_pickaxe:OnActivateSkill_BP()
    Copper_pickaxe.SuperClass.OnActivateSkill_BP(self)
end

function Copper_pickaxe:OnDeActivateSkill_BP()
    Copper_pickaxe.SuperClass.OnDeActivateSkill_BP(self)
end

function Copper_pickaxe:CanActivateSkill_BP()
    return Copper_pickaxe.SuperClass.CanActivateSkill_BP(self)
end

return Copper_pickaxe