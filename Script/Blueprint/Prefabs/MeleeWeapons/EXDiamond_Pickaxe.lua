---@class EXDiamond_Pickaxe_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local EXDiamond_Pickaxe = {}
 
--[[
function EXDiamond_Pickaxe:ReceiveBeginPlay()
    EXDiamond_Pickaxe.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function EXDiamond_Pickaxe:ReceiveTick(DeltaTime)
    EXDiamond_Pickaxe.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function EXDiamond_Pickaxe:ReceiveEndPlay()
    EXDiamond_Pickaxe.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function EXDiamond_Pickaxe:GetReplicatedProperties()
    return
end
--]]

--[[
function EXDiamond_Pickaxe:GetAvailableServerRPCs()
    return
end
--]]

return EXDiamond_Pickaxe