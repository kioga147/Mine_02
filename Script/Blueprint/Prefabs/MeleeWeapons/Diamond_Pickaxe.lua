---@class Diamond_Pickaxe_C:BP_UGC_MeleeWeap_Pan_C
---@field AttrModify UAttrModifyComponent
--Edit Below--
local Diamond_Pickaxe = {}
 
--[[
function Diamond_Pickaxe:ReceiveBeginPlay()
    Diamond_Pickaxe.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Diamond_Pickaxe:ReceiveTick(DeltaTime)
    Diamond_Pickaxe.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Diamond_Pickaxe:ReceiveEndPlay()
    Diamond_Pickaxe.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Diamond_Pickaxe:GetReplicatedProperties()
    return
end
--]]

--[[
function Diamond_Pickaxe:GetAvailableServerRPCs()
    return
end
--]]

return Diamond_Pickaxe