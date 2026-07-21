---@class Advanced_MiningTruck_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Advanced_MiningTruck = {}
 
function Advanced_MiningTruck:ReceiveBeginPlay()
    Advanced_MiningTruck.SuperClass.ReceiveBeginPlay(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 5)
end

function Advanced_MiningTruck:ReceiveEndPlay()
    Advanced_MiningTruck.SuperClass.ReceiveEndPlay(self) 
end

function Advanced_MiningTruck:GetReplicatedProperties()
    return
end

function Advanced_MiningTruck:GetAvailableServerRPCs()
    return
end

return Advanced_MiningTruck