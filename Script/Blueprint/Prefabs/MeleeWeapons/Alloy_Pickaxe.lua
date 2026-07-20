---@class Alloy_Pickaxe_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Alloy_Pickaxe = {}
 
--[[
function Alloy_Pickaxe:ReceiveBeginPlay()
    Alloy_Pickaxe.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Alloy_Pickaxe:ReceiveTick(DeltaTime)
    Alloy_Pickaxe.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Alloy_Pickaxe:ReceiveEndPlay()
    Alloy_Pickaxe.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Alloy_Pickaxe:GetReplicatedProperties()
    return
end
--]]

--[[
function Alloy_Pickaxe:GetAvailableServerRPCs()
    return
end
--]]

return Alloy_Pickaxe