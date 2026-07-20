---@class Copper_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Intermediate_MiningTruck = {}
 
function Intermediate_MiningTruck:OnEnableSkill_BP()
    Intermediate_MiningTruck.SuperClass.OnEnableSkill_BP(self)
end

function Intermediate_MiningTruck:OnDisableSkill_BP()
    Intermediate_MiningTruck.SuperClass.OnDisableSkill_BP(self)
end

function Intermediate_MiningTruck:OnActivateSkill_BP()
    Intermediate_MiningTruck.SuperClass.OnActivateSkill_BP(self)
end

function Intermediate_MiningTruck:OnDeActivateSkill_BP()
    Intermediate_MiningTruck.SuperClass.OnDeActivateSkill_BP(self)
end

function Intermediate_MiningTruck:CanActivateSkill_BP()
    return Intermediate_MiningTruck.SuperClass.CanActivateSkill_BP(self)
end

return Intermediate_MiningTruck