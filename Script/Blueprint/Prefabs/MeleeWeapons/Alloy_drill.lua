---@class Alloy_drill_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Alloy_drill = {}
 
function Alloy_drill:ReceiveBeginPlay()
    Alloy_drill.SuperClass.ReceiveBeginPlay(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 3)
end

function Alloy_drill:ReceiveEndPlay()
    Alloy_drill.SuperClass.ReceiveEndPlay(self) 
end

function Alloy_drill:GetReplicatedProperties()
    return
end

function Alloy_drill:GetAvailableServerRPCs()
    return
end

return Alloy_drill