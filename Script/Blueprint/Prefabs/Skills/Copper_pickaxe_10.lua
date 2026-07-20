---@class Copper_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Copper_pickaxe_10 = {}
 
function Copper_pickaxe_10:OnEnableSkill_BP()
    Copper_pickaxe_10.SuperClass.OnEnableSkill_BP(self)
end

function Copper_pickaxe_10:OnDisableSkill_BP()
    Copper_pickaxe_10.SuperClass.OnDisableSkill_BP(self)
end

function Copper_pickaxe_10:OnActivateSkill_BP()
    Copper_pickaxe_10.SuperClass.OnActivateSkill_BP(self)
end

function Copper_pickaxe_10:OnDeActivateSkill_BP()
    Copper_pickaxe_10.SuperClass.OnDeActivateSkill_BP(self)
end

function Copper_pickaxe_10:CanActivateSkill_BP()
    return Copper_pickaxe_10.SuperClass.CanActivateSkill_BP(self)
end

return Copper_pickaxe_10