UGCGameSystem.UGCRequire('Script.GameAttribute.game_attribute_type')
local UGCGlobalDamageCalculation = {}

function UGCGlobalDamageCalculation:GetCalculationResult(Context, ExtraResult)
    local VictimActor				= UGCAttributeSystem.GetVictimFromContext(Context)      --受害者
    local Causer					= UGCAttributeSystem.GetCauserFromContext(Context)      --枪等武器或者人(空手情况)
    local InstigatorController      = UGCAttributeSystem.GetInstigatorFromContext(Context)  --攻击者的Controller
    local CauserActor = UGCGameSystem.GetPlayerPawnByPlayerController(InstigatorController)  --攻击者角色
    print("[UGCGlobalDamageCalculation] Context CauserActor --->"..tostring(CauserActor))
    print("[UGCGlobalDamageCalculation] Context VictimActor --->"..tostring(VictimActor))  
    
     -- 传入的原始伤害数值
    local SkillAttack = UGCAttributeSystem.GetSourceMagnitudeFromContext(Context)
    local CurrentSignalHP = UGCAttributeSystem.GetGameAttributeValue(VictimActor, "SignalHP")       --当前信号值
    print("[UGCGlobalDamageCalculation] Context CurrentSignalHP --->"..tostring(CurrentSignalHP))
    local MaxSignalHP = UGCAttributeSystem.GetGameAttributeValueMax(VictimActor, "SignalHP")       --Max信号值
    print("[UGCGlobalDamageCalculation] Context MaxSignalHP --->"..tostring(MaxSignalHP))

    local SignalHPPercent = (CurrentSignalHP / MaxSignalHP) * 100   --当前信号值百分比

    --根据信号值百分比，调整伤害倍率
    if SignalHPPercent > 0 and SignalHPPercent <= 25 then
        SkillAttack = SkillAttack * 1.8
    elseif SignalHPPercent > 25 and SignalHPPercent <= 50 then
        SkillAttack = SkillAttack * 1.5
    elseif SignalHPPercent > 50 and SignalHPPercent <= 75 then
        SkillAttack = SkillAttack * 1.2
    else
        SkillAttack = SkillAttack * 1
    end
    print("[UGCGlobalDamageCalculation] Context SkillAttack --->"..tostring(SkillAttack))
    
    return SkillAttack, ExtraResult
end

return UGCGlobalDamageCalculation