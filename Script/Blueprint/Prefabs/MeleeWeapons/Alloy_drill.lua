---@class Alloy_drill_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Alloy_drill = {}
 
--[[
function Alloy_drill:ReceiveBeginPlay()
    Alloy_drill.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Alloy_drill:ReceiveTick(DeltaTime)
    Alloy_drill.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Alloy_drill:ReceiveEndPlay()
    Alloy_drill.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Alloy_drill:GetReplicatedProperties()
    return
end
--]]

--[[
function Alloy_drill:GetAvailableServerRPCs()
    return
end
--]]

return Alloy_drill