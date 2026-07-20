---@class Iron_pickaxe_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Iron_pickaxe = {}
 
--[[
function Iron_pickaxe:ReceiveBeginPlay()
    Iron_pickaxe.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function Iron_pickaxe:ReceiveTick(DeltaTime)
    Iron_pickaxe.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function Iron_pickaxe:ReceiveEndPlay()
    Iron_pickaxe.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function Iron_pickaxe:GetReplicatedProperties()
    return
end
--]]

--[[
function Iron_pickaxe:GetAvailableServerRPCs()
    return
end
--]]

return Iron_pickaxe