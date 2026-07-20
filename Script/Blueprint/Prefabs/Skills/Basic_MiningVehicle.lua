---@class Copper_pickaxe_C:PESkillTemplate_Base_C
--Edit Below--
local Basic_MiningVehicle = {}
 
function Basic_MiningVehicle:OnEnableSkill_BP()
    Basic_MiningVehicle.SuperClass.OnEnableSkill_BP(self)
end

function Basic_MiningVehicle:OnDisableSkill_BP()
    Basic_MiningVehicle.SuperClass.OnDisableSkill_BP(self)
end

function Basic_MiningVehicle:OnActivateSkill_BP()
    Basic_MiningVehicle.SuperClass.OnActivateSkill_BP(self)
end

function Basic_MiningVehicle:OnDeActivateSkill_BP()
    Basic_MiningVehicle.SuperClass.OnDeActivateSkill_BP(self)
end

function Basic_MiningVehicle:CanActivateSkill_BP()
    return Basic_MiningVehicle.SuperClass.CanActivateSkill_BP(self)
end

return Basic_MiningVehicle