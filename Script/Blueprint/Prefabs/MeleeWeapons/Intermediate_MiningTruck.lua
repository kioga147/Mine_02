---@class Intermediate_MiningTruck_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Intermediate_MiningTruck = {}
 
function Intermediate_MiningTruck:ReceiveBeginPlay()
    Intermediate_MiningTruck.SuperClass.ReceiveBeginPlay(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 4)
end

function Intermediate_MiningTruck:ReceiveEndPlay()
    Intermediate_MiningTruck.SuperClass.ReceiveEndPlay(self) 
end

function Intermediate_MiningTruck:GetReplicatedProperties()
    return
end

function Intermediate_MiningTruck:GetAvailableServerRPCs()
    return
end

return Intermediate_MiningTruck