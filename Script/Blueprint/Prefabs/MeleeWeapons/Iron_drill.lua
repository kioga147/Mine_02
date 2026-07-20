---@class Iron_drill_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Iron_drill = {}
 
--[[
function Iron_drill:ReceiveBeginPlay()
    Iron_drill.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Iron_drill:ReceiveTick(DeltaTime)
    Iron_drill.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Iron_drill:ReceiveEndPlay()
    Iron_drill.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Iron_drill:GetReplicatedProperties()
    return
end
--]]

--[[
function Iron_drill:GetAvailableServerRPCs()
    return
end
--]]

return Iron_drill