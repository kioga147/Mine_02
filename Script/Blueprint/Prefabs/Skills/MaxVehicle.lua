---@class MaxVehicle_C:PESkillPassiveSkillTemplate_C
---@field Particle UParticleSystem
--Edit Below--
local MaxVehicle = {
    SkillBaseClass = nil,
    ParticleSystemComponent = nil
}

local AURA_TARGET_COUNT = 49
local AURA_HALF_SIZE = 1050
local AURA_INTERVAL = 1.0
local AURA_DAMAGE = 100

local MineZoneManager = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.GamePartCustom.MineZoneManager")
    end)
    if Ok and type(Mod) == "table" then
        MineZoneManager = Mod
    end
end

local function DestroyParticle(Skill)
    if Skill and Skill.ParticleSystemComponent then
        pcall(function()
            Skill.ParticleSystemComponent:K2_DestroyComponent()
        end)
        Skill.ParticleSystemComponent = nil
    end
end

local function IsOreInRange(PlayerLoc, OreActor, HalfSize)
    if PlayerLoc == nil or OreActor == nil or OreActor.K2_GetActorLocation == nil then
        return false
    end
    local Ok, Loc = pcall(OreActor.K2_GetActorLocation, OreActor)
    if not (Ok and Loc) then
        return false
    end
    return math.abs(Loc.X - PlayerLoc.X) <= HalfSize
        and math.abs(Loc.Y - PlayerLoc.Y) <= HalfSize
end

local function GetDistanceSq(PlayerLoc, OreActor)
    if PlayerLoc == nil or OreActor == nil or OreActor.K2_GetActorLocation == nil then
        return 0
    end
    local Ok, Loc = pcall(OreActor.K2_GetActorLocation, OreActor)
    if not (Ok and Loc) then
        return 0
    end
    local dx = Loc.X - PlayerLoc.X
    local dy = Loc.Y - PlayerLoc.Y
    return dx * dx + dy * dy
end

local function TickMineCarAura(Skill)
    if Skill == nil or UGCGameSystem == nil or not UGCGameSystem.IsServer() then
        return
    end
    if MineZoneManager == nil then
        local Ok, Mod = pcall(function()
            return UGCGameSystem.UGCRequire("Script.GamePartCustom.MineZoneManager")
        end)
        if Ok and type(Mod) == "table" then
            MineZoneManager = Mod
        end
    end
    if Skill.GetOwnerActor == nil then
        return
    end
    local OkOwner, Owner = pcall(Skill.GetOwnerActor, Skill)
    if not (OkOwner and Owner and Owner.IsMineCarMode and Owner:IsMineCarMode()) then
        return
    end
    local OkLoc, PlayerLoc = pcall(Owner.K2_GetActorLocation, Owner)
    if not (OkLoc and PlayerLoc) then
        return
    end
    local Controller = nil
    if Owner.GetController then
        local OkCtrl, Ctrl = pcall(Owner.GetController, Owner)
        if OkCtrl then
            Controller = Ctrl
        end
    end

    local OreActors = {}
    if MineZoneManager and MineZoneManager.GetAllOreActors then
        local Ok, Actors = pcall(MineZoneManager.GetAllOreActors)
        if Ok and type(Actors) == "table" then
            OreActors = Actors
        end
    end

    local candidates = {}
    for _, Ore in ipairs(OreActors) do
        if Ore and UGCObjectUtility and UGCObjectUtility.IsObjectValid(Ore)
            and IsOreInRange(PlayerLoc, Ore, AURA_HALF_SIZE) then
            table.insert(candidates, Ore)
        end
    end
    table.sort(candidates, function(A, B)
        return GetDistanceSq(PlayerLoc, A) < GetDistanceSq(PlayerLoc, B)
    end)

    local Count = math.min(#candidates, AURA_TARGET_COUNT)
    for i = 1, Count do
        local Ore = candidates[i]
        if Ore and UGCGameSystem.ApplyDamage then
            pcall(UGCGameSystem.ApplyDamage, Ore, AURA_DAMAGE, Controller, Owner, {})
        end
    end
    ugcprint(string.format("[MaxVehicle] 矿车范围伤害: 目标=%d/%d", Count, AURA_TARGET_COUNT))
end

local function ScheduleAuraTick(Skill)
    if Skill == nil then
        return
    end
    local function Next()
        if Skill == nil or not UE.IsValid(Skill) then
            return
        end
        if Skill._MineCarAuraStopped then
            return
        end
        TickMineCarAura(Skill)
        if not Skill._MineCarAuraStopped and UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
            UGCTimerUtility.CreateLuaTimer(AURA_INTERVAL, Next, false)
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(AURA_INTERVAL, Next, false)
    else
        Next()
    end
end

function MaxVehicle:OnApply_BP()
    MaxVehicle.SuperClass.OnApply_BP(self)
    if self:HasAuthority() then
        self._MineCarAuraStopped = nil
        ScheduleAuraTick(self)
    end
    if not self:HasAuthority() then
        DestroyParticle(self)
    end
end

function MaxVehicle:OnDisableSkill_BP()
    MaxVehicle.SuperClass.OnDisableSkill_BP(self)
    self._MineCarAuraStopped = true
    DestroyParticle(self)
end

function MaxVehicle:OnUnApply_BP()
    MaxVehicle.SuperClass.OnUnApply_BP(self)
    self._MineCarAuraStopped = true
    DestroyParticle(self)
end

function MaxVehicle:OnActivateSkill_BP()
    MaxVehicle.SuperClass.OnActivateSkill_BP(self)
end

function MaxVehicle:OnDeActivateSkill_BP()
    MaxVehicle.SuperClass.OnDeActivateSkill_BP(self)
    DestroyParticle(self)
end

function MaxVehicle:CanActivateSkill_BP()
    return MaxVehicle.SuperClass.CanActivateSkill_BP(self)
end

return MaxVehicle
