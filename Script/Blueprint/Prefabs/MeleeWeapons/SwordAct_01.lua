---@class SwordAct_01_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local SwordAct_01 = {}
 
--[[
function SwordAct_01:ReceiveBeginPlay()
    SwordAct_01.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function SwordAct_01:ReceiveTick(DeltaTime)
    SwordAct_01.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function SwordAct_01:ReceiveEndPlay()
    SwordAct_01.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function SwordAct_01:GetReplicatedProperties()
    return
end
--]]

--[[
function SwordAct_01:GetAvailableServerRPCs()
    return
end
--]]

return SwordAct_01