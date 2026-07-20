---@class Gold_ore_C:BP_UGC_DamagableActor_C
---@field HittBox UBoxComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local Gold_ore = {
    ShakeTime = 0,
    ShakeSpeed = 0,
    ShakeAmplitude = 0
}

UGCGameSystem.UGCRequire('Script.GameAttribute.game_attribute_type')
local MiningSystem = UGCGameSystem.UGCRequire('Script.GamePartCustom.MiningSystem')

function Gold_ore:ReceiveBeginPlay()
    self.ShakeTime = 0
    self.CacheZ = self.StaticMesh:GetRelativeTransform().Translation.Z
end

---受击前置事件
---生效范围：服务器
---@param Damage float 伤害值
---@param EventInstigator AController 伤害来源的Controller
---@param DamageCauser AActor 伤害来源
---@param DamageContext FGameMagnitudeContext 伤害上下文
---@return boolean @是否允许受击
function Gold_ore:PreTakeDamageEvent(Damage, EventInstigator, DamageCauser, DamageContext)
    local mineLevel = UGCAttributeSystem.GetGameAttributeValue(self, "MineLevel")
    ugcprint("[矿石挖掘] 金矿等级:", mineLevel)
    
    local axeLevel = MiningSystem.GetAxeLevelFromDamageCauser(DamageCauser)
    ugcprint("[矿石挖掘] 镐子等级:", axeLevel)
    
    if not MiningSystem.CanMine(mineLevel, axeLevel) then
        ugcprint("[矿石挖掘] ❌ 镐子等级不足！需要等级", mineLevel, "的镐子，当前镐子等级", axeLevel)
        return false
    end
    
    ugcprint("[矿石挖掘] ✅ 镐子等级足够，可以挖掘")
    return true
end

---受击后置事件
---生效范围：服务器
---@param Damage float 伤害值
---@param EventInstigator AController 伤害来源的Controller
---@param DamageCauser AActor 伤害来源
---@param DamageContext FGameMagnitudeContext  伤害上下文
function Gold_ore:PostTakeDamageEvent(Damage, EventInstigator, DamageCauser, DamageContext)
    local CurrentHP = UGCAttributeSystem.GetGameAttributeValue(self, UGCNativeGameAttributeType.Character_Health)
    local CurrentMaxHP = UGCAttributeSystem.GetGameAttributeValue(self, UGCNativeGameAttributeType.Character_HealthMax)
    local Rate = CurrentHP / CurrentMaxHP

    if Rate < 1 and Rate > 0.5 then
        self.ShakeAmplitude = 4
        self.ShakeSpeed = 1
    elseif Rate <= 0.5 then
        self.ShakeAmplitude = 9
        self.ShakeSpeed = 6
    end
end

function Gold_ore:GetReplicatedProperties()
    return 'ShakeSpeed', 'ShakeAmplitude'
end

function Gold_ore:ReceiveTick(DeltaTime)
    if not UGCGameSystem.IsServer() then
        if self.ShakeAmplitude > 0 and self.ShakeSpeed > 0 then
            self.ShakeTime = self.ShakeTime + DeltaTime
            
            local ShakeX = math.sin(self.ShakeTime * self.ShakeSpeed * 2 * math.pi) * self.ShakeAmplitude
            local ShakeY = math.cos(self.ShakeTime * self.ShakeSpeed * 2 * math.pi * 1.5) * self.ShakeAmplitude * 0.7
            
            local NewLocation = Vector.New(ShakeX, ShakeY, self.CacheZ)
            self.StaticMesh:K2_SetRelativeLocation(NewLocation, false, nil, false)
        end
    end

end

---死亡事件
---生效范围：服务器
---@param KillingDamage float 杀死伤害值
---@param EventInstigator AController 杀死来源的Controller
---@param DamageCauser AActor 杀死来源
---@param DamageEvent FDamageEvent 杀死事件
---@param DamageTypeID FDamageType 杀死类型
function Gold_ore:BPDie(KillingDamage, EventInstigator,DamageCauser,DamageEvent,DamageTypeID)
    self.ShakeAmplitude = 0
    self.ShakeSpeed = 0
    self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})
end


return Gold_ore