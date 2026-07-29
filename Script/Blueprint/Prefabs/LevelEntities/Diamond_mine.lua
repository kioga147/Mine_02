---@class Diamond_mine_C:BP_UGC_DamagableActor_C
---@field HittBox UBoxComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local Diamond_mine = {
    ShakeTime = 0,
    ShakeSpeed = 0,
    ShakeAmplitude = 0
}

UGCGameSystem.UGCRequire('Script.GameAttribute.game_attribute_type')
local MiningSystem = UGCGameSystem.UGCRequire('Script.GamePartCustom.MiningSystem')
local MineZoneManager = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.GamePartCustom.MineZoneManager')
    end)
    if Ok and type(Mod) == "table" then
        MineZoneManager = Mod
    end
end

function Diamond_mine:ReceiveBeginPlay()
    self.ShakeTime = 0
    self.CacheZ = self.StaticMesh:GetRelativeTransform().Translation.Z
    if MineZoneManager and UGCGameSystem.IsServer() then
        MineZoneManager.RegisterOre(self, "Diamond")
    end
end

function Diamond_mine:PreOverrideDamage(Damage, EventInstigator, DamageCauser, DamageContext)
    local mineLevel = UGCAttributeSystem.GetGameAttributeValue(self, "MineLevel")
    if not mineLevel or mineLevel <= 0 then
        return Damage
    end
    
    local axeLevel = MiningSystem.GetAxeLevelFromDamageCauser(DamageCauser)
    
    if axeLevel > 0 and axeLevel < mineLevel then
        ugcprint("[矿石等级检查] 等级不足！伤害设为0 (AxeLevel="..axeLevel..", MineLevel="..mineLevel..")")
        return 0
    end
    
    return Damage
end

---受击后置事件
---生效范围：服务器
---@param Damage float 伤害值
---@param EventInstigator AController 伤害来源的Controller
---@param DamageCauser AActor 伤害来源
---@param DamageContext FGameMagnitudeContext  伤害上下文
function Diamond_mine:PostTakeDamageEvent(Damage, EventInstigator, DamageCauser, DamageContext)
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

function Diamond_mine:GetReplicatedProperties()
    return 'ShakeSpeed', 'ShakeAmplitude'
end

function Diamond_mine:ReceiveTick(DeltaTime)
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
function Diamond_mine:BPDie(KillingDamage, EventInstigator,DamageCauser,DamageEvent,DamageTypeID)
    self.ShakeAmplitude = 0
    self.ShakeSpeed = 0
    if MineZoneManager and UGCGameSystem.IsServer() then
        local zoneId, oreKey = MineZoneManager.GetZoneIdByActor(self)
        if zoneId and oreKey then
            MineZoneManager.OnOreDestroyed(zoneId, oreKey, self)
        end
    end
    self.UGCPresetCommonDropItemComponent:StartDrop(self, EventInstigator, {})
end


return Diamond_mine