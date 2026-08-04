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

-- 引入掉落系统
local MineTestDropConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.MineTestDropConfig")
    end)
    if Ok and type(Mod) == "table" then
        MineTestDropConfig = Mod
    end
end

local ORE_CLASS_CACHE = {}

local ZONE_ACTORS = {}

local RESPAWN_TIMERS = {}

local _GROUP_RESPAWNING = {}

local _PLAYER_CHECK_TIMERS = {}

local _bInitialized = false

local _bAllZonesSpawned = false

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
        ugcprint("[MineZoneManager] RegisterOre: 参数 nil")
        return
    end
    if _bInitialized ~= true then
        MineZoneManager.Initialize()
    end

    local ok, loc = pcall(function()
        return Actor:K2_GetActorLocation()
    end)
    if not (ok and loc) then
        ugcprint("[MineZoneManager] RegisterOre: 获取位置失败")
        return
    end

    local x = loc.X
    local y = loc.Y
    local z = loc.Z

    local zoneId = MineZoneManager._FindZoneByPosition(x, y, z)
    if zoneId == nil then
        ugcprint(string.format("[MineZoneManager] RegisterOre: 位置(%.0f,%.0f)不在任何矿区", x, y))
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

function MineZoneManager._CountPlayersInZone(ZoneId)
    local zone = MineZoneConfig and MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return 0
    end

    local pcList = nil
    local ok, result = pcall(function()
        return UGCGameSystem.GetAllPlayerController(false)
    end)
    if ok and result then
        pcList = result
    end

    if pcList == nil then
        return 0
    end

    local count = 0
    for _, pc in ipairs(pcList) do
        if pc and UGCObjectUtility.IsObjectValid(pc) then
            local pawn = pc:K2_GetPawn()
            if pawn and UGCObjectUtility.IsObjectValid(pawn) then
                local okLoc, loc = pcall(function()
                    return pawn:K2_GetActorLocation()
                end)
                if okLoc and loc then
                    local dx = loc.X - (zone.CenterX or 0)
                    local dy = loc.Y - (zone.CenterY or 0)
                    if math.abs(dx) <= (zone.RadiusX or 1000)
                        and math.abs(dy) <= (zone.RadiusY or 1000) then
                        count = count + 1
                    end
                end
            end
        end
    end

    return count
end

function MineZoneManager._ScheduleNoPlayersLoop(ZoneId, ZoneName)
    if _PLAYER_CHECK_TIMERS[ZoneId] then
        return
    end
    _PLAYER_CHECK_TIMERS[ZoneId] = true

    local checkInterval = 1.0
    UGCTimerUtility.CreateLuaTimer(checkInterval, function()
        if not _PLAYER_CHECK_TIMERS[ZoneId] then
            return
        end

        local players = MineZoneManager._CountPlayersInZone(ZoneId)
        if players > 0 then
            _PLAYER_CHECK_TIMERS[ZoneId] = nil
            MineZoneManager._ScheduleNoPlayersLoop(ZoneId, ZoneName)
        else
            _PLAYER_CHECK_TIMERS[ZoneId] = nil
            _GROUP_RESPAWNING[ZoneId] = true
            local delay = MineZoneConfig and MineZoneConfig.GetRespawnDelay(ZoneId) or 2
            ugcprint(string.format(
                "[MineZoneManager] 矿区%s已无人，%.1f秒后集体刷新",
                ZoneName, delay))
            UGCTimerUtility.CreateLuaTimer(delay, function()
                _GROUP_RESPAWNING[ZoneId] = nil
                ugcprint(string.format(
                    "[MineZoneManager] 🔄 无人刷新矿区: %s", ZoneName))
                MineZoneManager.SpawnZoneOres(ZoneId)
            end, false)
        end
    end, false)
end

function MineZoneManager.SpawnOreForRespawn(OreKey, X, Y, Z, ZoneId)
    if not UGCGameSystem.IsServer() then
        return nil
    end

    local oreClass = MineZoneManager.GetOreClass(OreKey)
    if oreClass == nil then
        ugcprint(string.format("[MineZoneManager] ❌ 矿石类未加载: %s", tostring(OreKey)))
        return nil
    end

    local worldContext = MineZoneManager._GetWorldContext()
    if worldContext == nil then
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
        return actor
    else
        ugcprint(string.format("[MineZoneManager] ❌ 矿石生成失败: %s at (%.0f,%.0f,%.0f)", tostring(OreKey), X, Y, Z))
        return nil
    end
end

function MineZoneManager.OnOreDestroyed(ZoneId, OreKey, Actor, EventInstigator)
    if not UGCGameSystem.IsServer() then
        return
    end

    local zone = MineZoneConfig and MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        ugcprint(string.format("[MineZoneManager] OnOreDestroyed: 矿区%d配置不存在", ZoneId))
        return
    end

    local respawnMode = MineZoneConfig and MineZoneConfig.GetRespawnMode(ZoneId) or "Individual"
    local bAllAtOnce = (respawnMode == "AllAtOnce")
    local bNoPlayers = (respawnMode == "NoPlayers")

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
        return
    end

    local origX = spawnInfo.OriginalX or spawnInfo.X
    local origY = spawnInfo.OriginalY or spawnInfo.Y
    local origZ = spawnInfo.OriginalZ or spawnInfo.Z

    -- 全矿区集体刷新模式
    if bAllAtOnce then
        local remainingCount = MineZoneManager.GetZoneOreCount(ZoneId)

        if remainingCount == 0 and not _GROUP_RESPAWNING[ZoneId] then
            _GROUP_RESPAWNING[ZoneId] = true
            local delay = MineZoneConfig and MineZoneConfig.GetRespawnDelay(ZoneId) or 1
            ugcprint(string.format("[MineZoneManager] 矿区%s矿石已全部挖完，%.1f秒后集体刷新",
                zone.Name or tostring(ZoneId), delay))

            UGCTimerUtility.CreateLuaTimer(delay, function()
                _GROUP_RESPAWNING[ZoneId] = nil
                ugcprint(string.format("[MineZoneManager] 🔄 集体刷新矿区: %s", zone.Name or tostring(ZoneId)))
                MineZoneManager.SpawnZoneOres(ZoneId)
            end, false)
        end
        return
    end

    -- 矿区无人时集体刷新模式
    if bNoPlayers then
        local remainingCount = MineZoneManager.GetZoneOreCount(ZoneId)
        if remainingCount == 0 and not _GROUP_RESPAWNING[ZoneId] and not _PLAYER_CHECK_TIMERS[ZoneId] then
            local zoneName = zone.Name or tostring(ZoneId)
            ugcprint(string.format(
                "[MineZoneManager] 矿区%s矿石已全部挖完，等待无人时刷新",
                zoneName))
            MineZoneManager._ScheduleNoPlayersLoop(ZoneId, zoneName)
        end
        return
    end

    -- 独立刷新模式（原有逻辑）
    local respawnSec = 5
    for _, oreEntry in ipairs(zone.OreDist or {}) do
        if oreEntry.OreKey == OreKey then
            respawnSec = oreEntry.RespawnSec or 5
            break
        end
    end

    if respawnSec <= 0 then
        MineZoneManager.SpawnOreForRespawn(OreKey, origX, origY, origZ, ZoneId)
        return
    end

    local timerKey = string.format("respawn_%d_%s_%d", ZoneId, OreKey, os.time())
    RESPAWN_TIMERS[timerKey] = true

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

    MineZoneManager.PreloadOreClasses()
end

-- 生成指定矿区的矿石
function MineZoneManager.SpawnZoneOres(ZoneId)
    if not UGCGameSystem.IsServer() then
        return
    end

    if MineZoneConfig == nil then
        return
    end

    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return
    end

    local positions = MineZoneConfig.GenerateSpawnPositions(ZoneId)
    local spawnCount = 0
    local failCount = 0

    for _, posInfo in ipairs(positions) do
        local actor = MineZoneManager.SpawnOreForRespawn(
            posInfo.OreKey, posInfo.X, posInfo.Y, posInfo.Z, ZoneId
        )
        if actor then
            MineZoneManager.RegisterOre(actor, posInfo.OreKey)
            spawnCount = spawnCount + 1
        else
            failCount = failCount + 1
        end
    end

    if failCount > 0 then
        ugcprint(string.format(
            "[MineZoneManager] 矿区%s: 成功=%d, 失败=%d",
            zone.Name or "未知", spawnCount, failCount
        ))
    end
end

-- 生成所有矿区的矿石
function MineZoneManager.SpawnAllZones()
    if not UGCGameSystem.IsServer() then
        return
    end

    if not _bInitialized then
        MineZoneManager.Initialize()
    end

    if _bAllZonesSpawned then
        return
    end
    _bAllZonesSpawned = true

    local zoneIds = MineZoneConfig and MineZoneConfig.GetZoneIds() or {}
    for _, zoneId in ipairs(zoneIds) do
        MineZoneManager.SpawnZoneOres(zoneId)
    end

    ugcprint("[MineZoneManager] ✅ 矿区矿石生成完成")
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