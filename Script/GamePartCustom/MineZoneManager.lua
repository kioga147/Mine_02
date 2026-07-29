local MineZoneManager = {}

local MineZoneConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.MineZoneConfig")
    end)
    if Ok and type(Mod) == "table" then
        MineZoneConfig = Mod
    else
        MineZoneConfig = nil
        ugcprint("[MineZoneManager] MineZoneConfig 加载失败")
    end
end

local ORE_CLASS_CACHE = {}

local ZONE_ACTORS = {}

local RESPAWN_TIMERS = {}

local _bInitialized = false

local _CachedWorldContext = nil

function MineZoneManager._GetWorldContext()
    if _CachedWorldContext ~= nil and UGCObjectUtility.IsObjectValid(_CachedWorldContext) then
        return _CachedWorldContext
    end

    local ok, pc = pcall(UGCGameSystem.GetLocalPlayerController)
    if ok and pc and UGCObjectUtility.IsObjectValid(pc) then
        _CachedWorldContext = pc
        return pc
    end

    if UGCGameSystem.GetGameState then
        local ok2, gs = pcall(UGCGameSystem.GetGameState)
        if ok2 and gs and UGCObjectUtility.IsObjectValid(gs) then
            _CachedWorldContext = gs
            return gs
        end
    end

    if UGCGameSystem.GetGameMode then
        local ok3, gm = pcall(UGCGameSystem.GetGameMode)
        if ok3 and gm and UGCObjectUtility.IsObjectValid(gm) then
            _CachedWorldContext = gm
            return gm
        end
    end

    return nil
end

function MineZoneManager.PreloadOreClasses()
    if ORE_CLASS_CACHE._loaded then
        return
    end
    ORE_CLASS_CACHE._loaded = true

    if MineZoneConfig == nil then
        ugcprint("[MineZoneManager] 配置不存在，跳过预加载")
        return
    end

    local oreKeys = MineZoneConfig.GetAllOreKeys()
    for _, oreKey in ipairs(oreKeys) do
        local path = MineZoneConfig.GetOrePath(oreKey)
        if path then
            local fullPath = UGCGameSystem.GetUGCResourcesFullPath(path)
            local ok, class = pcall(function()
                return UGCObjectUtility.LoadClass(fullPath)
            end)
            if ok and class then
                ORE_CLASS_CACHE[oreKey] = class
            else
                ugcprint("[MineZoneManager] ⚠️ 加载矿石类失败: " .. oreKey)
            end
        end
    end
end

function MineZoneManager.GetOreClass(OreKey)
    return ORE_CLASS_CACHE[OreKey]
end

function MineZoneManager._FindZoneByPosition(X, Y, Z)
    if MineZoneConfig == nil then
        return nil
    end

    for _, zoneId in ipairs(MineZoneConfig.GetZoneIds()) do
        local zone = MineZoneConfig.GetZone(zoneId)
        if zone then
            local dx = X - (zone.CenterX or 0)
            local dy = Y - (zone.CenterY or 0)
            local rx = zone.RadiusX or 1000
            local ry = zone.RadiusY or 1000
            if math.abs(dx) <= rx and math.abs(dy) <= ry then
                return zoneId
            end
        end
    end
    return nil
end

local _PendingSummary = false

function MineZoneManager._PrintZoneSummary()
    _PendingSummary = false
    local total = 0
    local zoneSummaries = {}
    for zoneId, actors in pairs(ZONE_ACTORS) do
        local count = 0
        for _, entry in ipairs(actors) do
            if entry.Actor and UGCObjectUtility.IsObjectValid(entry.Actor) then
                count = count + 1
            end
        end
        if count > 0 then
            local zone = MineZoneConfig and MineZoneConfig.GetZone(zoneId)
            local zoneName = zone and zone.Name or ("Zone" .. tostring(zoneId))
            table.insert(zoneSummaries, string.format("%s=%d", zoneName, count))
            total = total + count
        end
    end
    if total > 0 then
        ugcprint(string.format("[MineZoneManager] 📊 矿石注册汇总: 总计=%d | %s",
            total, table.concat(zoneSummaries, ", ")))
    end
end

function MineZoneManager._ScheduleSummary()
    if _PendingSummary then
        return
    end
    _PendingSummary = true
    UGCTimerUtility.CreateLuaTimer(2.0, function()
        MineZoneManager._PrintZoneSummary()
    end, false)
end

function MineZoneManager.RegisterOre(Actor, OreKey)
    if not UGCGameSystem.IsServer() then
        return
    end
    if Actor == nil or OreKey == nil then
        return
    end
    if _bInitialized ~= true then
        MineZoneManager.Initialize()
    end

    local location = nil
    local ok, loc = pcall(function()
        return Actor:K2_GetActorLocation()
    end)
    if not (ok and loc) then
        return
    end

    local x = location.X
    local y = location.Y
    local z = location.Z

    local zoneId = MineZoneManager._FindZoneByPosition(x, y, z)
    if zoneId == nil then
        return
    end

    if not ZONE_ACTORS[zoneId] then
        ZONE_ACTORS[zoneId] = {}
    end

    for _, entry in ipairs(ZONE_ACTORS[zoneId]) do
        if entry.Actor == Actor then
            return
        end
    end

    table.insert(ZONE_ACTORS[zoneId], {
        Actor = Actor,
        OreKey = OreKey,
        X = x,
        Y = y,
        Z = z,
        OriginalX = x,
        OriginalY = y,
        OriginalZ = z,
    })

    MineZoneManager._ScheduleSummary()
end

function MineZoneManager.SpawnOreForRespawn(OreKey, X, Y, Z, ZoneId)
    if not UGCGameSystem.IsServer() then
        return nil
    end

    local oreClass = MineZoneManager.GetOreClass(OreKey)
    if oreClass == nil then
        ugcprint("[MineZoneManager] 矿石类未加载: " .. tostring(OreKey))
        return nil
    end

    local worldContext = MineZoneManager._GetWorldContext()
    if worldContext == nil then
        ugcprint("[MineZoneManager] 无法获取WorldContext，跳过生成")
        return nil
    end

    local location = Vector.New(X, Y, Z)
    local rotation = Rotator.New(0, 0, 0)
    local scale = Vector.New(1, 1, 1)

    local ok, actor = pcall(function()
        return UGCActorComponentUtility.SpawnActor(
            worldContext,
            oreClass,
            location,
            rotation,
            scale,
            nil
        )
    end)

    if ok and actor then
        ugcprint(string.format(
            "[MineZoneManager] 🔄 矿石重生: %s at (%.0f,%.0f,%.0f)",
            tostring(OreKey), X, Y, Z
        ))
        return actor
    else
        ugcprint(string.format(
            "[MineZoneManager] ⚠️ 矿石重生失败: %s at (%.0f,%.0f,%.0f)",
            tostring(OreKey), X, Y, Z
        ))
        return nil
    end
end

function MineZoneManager.OnOreDestroyed(ZoneId, OreKey, Actor)
    if not UGCGameSystem.IsServer() then
        return
    end

    local zone = MineZoneConfig and MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return
    end

    local spawnInfo = nil
    if ZONE_ACTORS[ZoneId] then
        for i, entry in ipairs(ZONE_ACTORS[ZoneId]) do
            if entry.Actor == Actor then
                spawnInfo = entry
                table.remove(ZONE_ACTORS[ZoneId], i)
                break
            end
        end
    end

    if spawnInfo == nil then
        ugcprint("[MineZoneManager] 未找到矿石记录: ZoneId=" .. tostring(ZoneId))
        return
    end

    local respawnSec = 5
    for _, oreEntry in ipairs(zone.OreDist or {}) do
        if oreEntry.OreKey == OreKey then
            respawnSec = oreEntry.RespawnSec or 5
            break
        end
    end

    if respawnSec <= 0 then
        respawnSec = 5
    end

    ugcprint(string.format(
        "[MineZoneManager] 💥 %s被采集 (%.0f,%.0f,%.0f) | %ds后重生",
        tostring(OreKey),
        spawnInfo.OriginalX or spawnInfo.X,
        spawnInfo.OriginalY or spawnInfo.Y,
        spawnInfo.OriginalZ or spawnInfo.Z,
        respawnSec
    ))

    local timerKey = string.format("respawn_%d_%s_%d", ZoneId, OreKey, os.time())
    RESPAWN_TIMERS[timerKey] = true

    local origX = spawnInfo.OriginalX or spawnInfo.X
    local origY = spawnInfo.OriginalY or spawnInfo.Y
    local origZ = spawnInfo.OriginalZ or spawnInfo.Z

    UGCTimerUtility.CreateLuaTimer(respawnSec, function()
        if RESPAWN_TIMERS[timerKey] then
            RESPAWN_TIMERS[timerKey] = nil
        end

        MineZoneManager.SpawnOreForRespawn(OreKey, origX, origY, origZ, ZoneId)
    end, false)
end

function MineZoneManager.GetZoneOreCount(ZoneId)
    local actors = ZONE_ACTORS[ZoneId]
    if actors == nil then
        return 0
    end
    local count = 0
    for _, entry in ipairs(actors) do
        if entry.Actor and UGCObjectUtility.IsObjectValid(entry.Actor) then
            count = count + 1
        end
    end
    return count
end

function MineZoneManager.GetAllZoneOreCount()
    local total = 0
    for zoneId, actors in pairs(ZONE_ACTORS) do
        for _, entry in ipairs(actors) do
            if entry.Actor and UGCObjectUtility.IsObjectValid(entry.Actor) then
                total = total + 1
            end
        end
    end
    return total
end

function MineZoneManager.Initialize()
    if not UGCGameSystem.IsServer() then
        return
    end

    if _bInitialized then
        return
    end

    _bInitialized = true

    ugcprint("[MineZoneManager] 矿区系统启动...")
    MineZoneManager.PreloadOreClasses()
end

function MineZoneManager.GetZoneIdByActor(Actor)
    if Actor == nil then
        return nil, nil
    end

    for zoneId, actors in pairs(ZONE_ACTORS) do
        for _, entry in ipairs(actors) do
            if entry.Actor == Actor then
                return zoneId, entry.OreKey
            end
        end
    end

    return nil, nil
end

return MineZoneManager