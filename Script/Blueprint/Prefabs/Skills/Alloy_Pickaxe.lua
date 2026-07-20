---@class Alloy_Pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Alloy_Pickaxe = {}
 
function Alloy_Pickaxe:OnEnableSkill_BP()
    Alloy_Pickaxe.SuperClass.OnEnableSkill_BP(self)
end

function Alloy_Pickaxe:OnDisableSkill_BP()
    Alloy_Pickaxe.SuperClass.OnDisableSkill_BP(self)
end

function Alloy_Pickaxe:OnActivateSkill_BP()
    Alloy_Pickaxe.SuperClass.OnActivateSkill_BP(self)
end

function Alloy_Pickaxe:OnDeActivateSkill_BP()
    Alloy_Pickaxe.SuperClass.OnDeActivateSkill_BP(self)
end

function Alloy_Pickaxe:CanActivateSkill_BP()
    return Alloy_Pickaxe.SuperClass.CanActivateSkill_BP(self)
end

return Alloy_Pickaxe