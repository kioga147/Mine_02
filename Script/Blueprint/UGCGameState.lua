---@class UGCGameState_C:BP_UGCGameState_C
--Edit Below--
UGCGameSystem.UGCRequire('Script.Common.ue_enum_custom')

local PaymentSystem = nil
do
    local ok, mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.GamePartCustom.PaymentSystem')
    end)
    if ok and type(mod) == 'table' then PaymentSystem = mod end
end

local UGCGameState = {}; 

function UGCGameState:ReceiveBeginPlay()
    UGCGameState.SuperClass.ReceiveBeginPlay(self)

    -- 初始化商业化/付费系统（绑定购买/使用结果委托 + 显示充值入口）
    if PaymentSystem and PaymentSystem.Initialize then
        pcall(function()
            PaymentSystem.Initialize()
        end)
    end
end

function UGCGameState:ReceiveEndPlay()
    if PaymentSystem and PaymentSystem.Cleanup then
        pcall(function()
            PaymentSystem.Cleanup()
        end)
    end
end

return UGCGameState;