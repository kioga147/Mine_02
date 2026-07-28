---@class UGCGameState_C:BP_UGCGameState_C
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')
local UGCGameState = {}; 

function UGCGameState:ReceiveBeginPlay()
    UGCGameState.SuperClass.ReceiveBeginPlay(self)
end

return UGCGameState;