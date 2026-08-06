local BP_Placeholder = {}
 
--[[
function BP_Placeholder:ReceiveBeginPlay()
    BP_Placeholder.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function BP_Placeholder:ReceiveTick(DeltaTime)
    BP_Placeholder.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function BP_Placeholder:ReceiveEndPlay()
    BP_Placeholder.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function BP_Placeholder:GetReplicatedProperties()
    return
end
--]]

--[[
function BP_Placeholder:GetAvailableServerRPCs()
    return
end
--]]

return BP_Placeholder