---@class EXDiamond_Drill_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local EXDiamond_Drill = {}
 
--[[
function EXDiamond_Drill:ReceiveBeginPlay()
    EXDiamond_Drill.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function EXDiamond_Drill:ReceiveTick(DeltaTime)
    EXDiamond_Drill.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function EXDiamond_Drill:ReceiveEndPlay()
    EXDiamond_Drill.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function EXDiamond_Drill:GetReplicatedProperties()
    return
end
--]]

--[[
function EXDiamond_Drill:GetAvailableServerRPCs()
    return
end
--]]

return EXDiamond_Drill