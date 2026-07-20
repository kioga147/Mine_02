---@class Copper_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Copper_pickaxe_11 = {}
 
function Copper_pickaxe_11:OnEnableSkill_BP()
    Copper_pickaxe_11.SuperClass.OnEnableSkill_BP(self)
end

function Copper_pickaxe_11:OnDisableSkill_BP()
    Copper_pickaxe_11.SuperClass.OnDisableSkill_BP(self)
end

function Copper_pickaxe_11:OnActivateSkill_BP()
    Copper_pickaxe_11.SuperClass.OnActivateSkill_BP(self)
end

function Copper_pickaxe_11:OnDeActivateSkill_BP()
    Copper_pickaxe_11.SuperClass.OnDeActivateSkill_BP(self)
end

function Copper_pickaxe_11:CanActivateSkill_BP()
    return Copper_pickaxe_11.SuperClass.CanActivateSkill_BP(self)
end

return Copper_pickaxe_11