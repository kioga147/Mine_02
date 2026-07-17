---@class UGCPlayerPawn_C:BP_PlayerPawn_TopDown_C
--Edit Below--
local UGCPlayerPawn = {}

local HEAVY_WEIGHT_THRESHOLD = 100
local NORMAL_SPEED_SCALE = 2.0
local HEAVY_SPEED_SCALE = 1.0

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)
    
    UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
    ugcprint("[背包负重] 玩家出生 - 初始移动速度倍率:", NORMAL_SPEED_SCALE)
end

function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)
    
    local backpackWeightInfo = BP_BackpackComponentV2_Custom.GetBackpackWeightInfo(self)
    if backpackWeightInfo then
        ugcprint("[背包负重] Tick检查 - 当前重量:", backpackWeightInfo.CurrentWeight, "kg, 阈值:", HEAVY_WEIGHT_THRESHOLD, "kg")
        
        if backpackWeightInfo.CurrentWeight >= HEAVY_WEIGHT_THRESHOLD then
            UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, HEAVY_SPEED_SCALE)
            ugcprint("[背包负重] 超重！移动速度倍率设为:", HEAVY_SPEED_SCALE)
        else
            UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
            ugcprint("[背包负重] 负重正常, 移动速度倍率:", NORMAL_SPEED_SCALE)
        end
    else
        ugcprint("[背包负重] Tick检查 - 获取背包重量信息失败")
    end
end

function UGCPlayerPawn:ReceiveEndPlay()
    UGCPlayerPawn.SuperClass.ReceiveEndPlay(self) 
end

--[[
function UGCPlayerPawn:GetAvailableServerRPCs()
    return
end
--]]

function UGCPlayerPawn:GetReplicatedProperties()
    return {"__SubObjectRepList", "Lazy"}
end


return UGCPlayerPawn