UGCGameSystem.UGCRequire('Script.GameAttribute.game_attribute_type')
local MiningSystem = UGCGameSystem.UGCRequire('Script.GamePartCustom.MiningSystem')
local UGCGlobalDamageCalculation = {}

function UGCGlobalDamageCalculation:GetCalculationResult(Context, ExtraResult)
    local VictimActor				= UGCAttributeSystem.GetVictimFromContext(Context)      --受害者
    local Causer					= UGCAttributeSystem.GetCauserFromContext(Context)      --枪等武器或者人(空手情况)
    local InstigatorController      = UGCAttributeSystem.GetInstigatorFromContext(Context)  --攻击者的Controller
    local CauserActor = UGCGameSystem.GetPlayerPawnByPlayerController(InstigatorController)  --攻击者角色
    
    local mineLevel = UGCAttributeSystem.GetGameAttributeValue(VictimActor, "MineLevel")
    if mineLevel and mineLevel > 0 then
        local axeLevel = MiningSystem.GetAxeLevelFromDamageCauser(Causer)
        
        if axeLevel > 0 and axeLevel < mineLevel then
            return 0, ExtraResult
        end
        
        local SkillAttack = UGCAttributeSystem.GetSourceMagnitudeFromContext(Context)
        return SkillAttack, ExtraResult
    end
    
    local SkillAttack = UGCAttributeSystem.GetSourceMagnitudeFromContext(Context)
    
    local CurrentSignalHP = UGCAttributeSystem.GetGameAttributeValue(VictimActor, "SignalHP")
    local MaxSignalHP = UGCAttributeSystem.GetGameAttributeValueMax(VictimActor, "SignalHP")
    
    if CurrentSignalHP and MaxSignalHP and MaxSignalHP > 0 then
        local SignalHPPercent = (CurrentSignalHP / MaxSignalHP) * 100
        
        if SignalHPPercent > 0 and SignalHPPercent <= 25 then
            SkillAttack = SkillAttack * 1.8
        elseif SignalHPPercent > 25 and SignalHPPercent <= 50 then
            SkillAttack = SkillAttack * 1.5
        elseif SignalHPPercent > 50 and SignalHPPercent <= 75 then
            SkillAttack = SkillAttack * 1.2
        end
    end
    
    return SkillAttack, ExtraResult
end

return UGCGlobalDamageCalculation