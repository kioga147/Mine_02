---@class EXDiamond_Pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local EXDiamond_Pickaxe = {}
 
function EXDiamond_Pickaxe:OnEnableSkill_BP()
    EXDiamond_Pickaxe.SuperClass.OnEnableSkill_BP(self)
end

function EXDiamond_Pickaxe:OnDisableSkill_BP()
    EXDiamond_Pickaxe.SuperClass.OnDisableSkill_BP(self)
end

function EXDiamond_Pickaxe:OnActivateSkill_BP()
    EXDiamond_Pickaxe.SuperClass.OnActivateSkill_BP(self)
end

function EXDiamond_Pickaxe:OnDeActivateSkill_BP()
    EXDiamond_Pickaxe.SuperClass.OnDeActivateSkill_BP(self)
end

function EXDiamond_Pickaxe:CanActivateSkill_BP()
    return EXDiamond_Pickaxe.SuperClass.CanActivateSkill_BP(self)
end

return EXDiamond_Pickaxe