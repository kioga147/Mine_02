---@class Copper_drill_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Copper_drill = {}
 
function Copper_drill:ReceiveBeginPlay()
    Copper_drill.SuperClass.ReceiveBeginPlay(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 1)
end

function Copper_drill:ReceiveEndPlay()
    Copper_drill.SuperClass.ReceiveEndPlay(self) 
end

function Copper_drill:GetReplicatedProperties()
    return
end

function Copper_drill:GetAvailableServerRPCs()
    return
end

return Copper_drill