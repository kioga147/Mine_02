UGCGameSystem.UGCRequire('Script.GameAttribute.game_attribute_type')
local UGCGlobalRecoveryCalculation = {}

function UGCGlobalRecoveryCalculation:GetCalculationResult(Context, ExtraResult)
    local BeRecoveredActor				= UGCAttributeSystem.GetVictimFromContext(Context)      --接受治疗者
    local Causer					= UGCAttributeSystem.GetCauserFromContext(Context)      --枪等武器或者人(空手情况)
    local InstigatorController      = UGCAttributeSystem.GetInstigatorFromContext(Context)  --治疗发起者的Controller
    local CauserActor = UGCGameSystem.GetPlayerPawnByPlayerController(InstigatorController) --治疗发起者
    print("[UGCGlobalRecoveryCalculation] Context CauserActor --->"..tostring(CauserActor))
    print("[UGCGlobalRecoveryCalculation] Context BeRecoveredActor --->"..tostring(BeRecoveredActor))  
    
    local RecoveredValue = UGCAttributeSystem.GetSourceMagnitudeFromContext(Context)
    return RecoveredValue, ExtraResult
end

return UGCGlobalRecoveryCalculation