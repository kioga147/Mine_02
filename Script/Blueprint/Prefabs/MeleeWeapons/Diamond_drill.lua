---@class Diamond_drill_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Diamond_drill = {}
 
function Diamond_drill:ReceiveBeginPlay()
    Diamond_drill.SuperClass.ReceiveBeginPlay(self)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 4)
end

function Diamond_drill:ReceiveEndPlay()
    Diamond_drill.SuperClass.ReceiveEndPlay(self) 
end

function Diamond_drill:GetReplicatedProperties()
    return
end

function Diamond_drill:GetAvailableServerRPCs()
    return
end

return Diamond_drill