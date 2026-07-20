---@class Copper_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Advanced_MiningTruck = {}
 
function Advanced_MiningTruck:OnEnableSkill_BP()
    Advanced_MiningTruck.SuperClass.OnEnableSkill_BP(self)
end

function Advanced_MiningTruck:OnDisableSkill_BP()
    Advanced_MiningTruck.SuperClass.OnDisableSkill_BP(self)
end

function Advanced_MiningTruck:OnActivateSkill_BP()
    Advanced_MiningTruck.SuperClass.OnActivateSkill_BP(self)
end

function Advanced_MiningTruck:OnDeActivateSkill_BP()
    Advanced_MiningTruck.SuperClass.OnDeActivateSkill_BP(self)
end

function Advanced_MiningTruck:CanActivateSkill_BP()
    return Advanced_MiningTruck.SuperClass.CanActivateSkill_BP(self)
end

return Advanced_MiningTruck