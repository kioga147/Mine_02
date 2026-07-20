---@class EXDiamond_Drill_C:PESkillTemplate_Base_C
--Edit Below--
local EXDiamond_Drill = {}
 
function EXDiamond_Drill:OnEnableSkill_BP()
    EXDiamond_Drill.SuperClass.OnEnableSkill_BP(self)
end

function EXDiamond_Drill:OnDisableSkill_BP()
    EXDiamond_Drill.SuperClass.OnDisableSkill_BP(self)
end

function EXDiamond_Drill:OnActivateSkill_BP()
    EXDiamond_Drill.SuperClass.OnActivateSkill_BP(self)
end

function EXDiamond_Drill:OnDeActivateSkill_BP()
    EXDiamond_Drill.SuperClass.OnDeActivateSkill_BP(self)
end

function EXDiamond_Drill:CanActivateSkill_BP()
    return EXDiamond_Drill.SuperClass.CanActivateSkill_BP(self)
end

return EXDiamond_Drill