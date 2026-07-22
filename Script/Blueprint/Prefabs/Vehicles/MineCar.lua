---@class MineCar_C:VH_Dacia_3_New_C
---@field UGCVehicleSeat3 UUGCVehicleSeatComponent
---@field UGCVehicleSeat2 UUGCVehicleSeatComponent
---@field UGCVehicleSeat1 UUGCVehicleSeatComponent
---@field UGCVehicleSeat UUGCVehicleSeatComponent
---@field UGCWheeledVehicleComponent_BP UGCWheeledVehicleComponent_BP_C
--Edit Below--
local MineCar = {}
 
--[[
function MineCar:ReceiveBeginPlay()
    MineCar.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function MineCar:ReceiveTick(DeltaTime)
    MineCar.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function MineCar:ReceiveEndPlay()
    MineCar.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function MineCar:GetReplicatedProperties()
    return
end
--]]

--[[
function MineCar:GetAvailableServerRPCs()
    return
end
--]]

return MineCar