---@class Basic_MiningVehicle_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Basic_MiningVehicle = {}
 
--[[
function Basic_MiningVehicle:ReceiveBeginPlay()
    Basic_MiningVehicle.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Basic_MiningVehicle:ReceiveTick(DeltaTime)
    Basic_MiningVehicle.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Basic_MiningVehicle:ReceiveEndPlay()
    Basic_MiningVehicle.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Basic_MiningVehicle:GetReplicatedProperties()
    return
end
--]]

--[[
function Basic_MiningVehicle:GetAvailableServerRPCs()
    return
end
--]]

return Basic_MiningVehicle