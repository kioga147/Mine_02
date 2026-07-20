---@class Copper_pickaxe_C:BP_UGC_MeleeWeap_Pan_C
---@field AttrModify UAttrModifyComponent
--Edit Below--
local Copper_pickaxe = {}
 
--[[
function Copper_pickaxe:ReceiveBeginPlay()
    Copper_pickaxe.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Copper_pickaxe:ReceiveTick(DeltaTime)
    Copper_pickaxe.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Copper_pickaxe:ReceiveEndPlay()
    Copper_pickaxe.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Copper_pickaxe:GetReplicatedProperties()
    return
end
--]]

--[[
function Copper_pickaxe:GetAvailableServerRPCs()
    return
end
--]]

return Copper_pickaxe