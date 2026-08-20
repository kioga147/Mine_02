--- 矿区传送大厅配置（Mine_02-main）
--- 解锁 8500 / 矿区传送 3000 / 出生点传送 0
--- 传送落点已更新为新地图坐标（2026-08-20）
--- ZoneId 1-5 = 矿区, ZoneId 6 = 出生点
local MineTeleportConfig = {
    UnlockCost = 8500,
    TeleportCost = 3000,
    SpawnCost = 0,
    SPAWN_ZONE_ID = 6,
    SpawnPoint = { X = 21045.953125, Y = 28685.033203, Z = 201.396744 },
    Zones = {
        [1] = {
            Name = "石滩",
            PadX = 21670.898438, PadY = 7234.638672, PadZ = 124.259644,
            HallX = 20830, HallY = 25040, HallZ = 220,
        },
        [2] = {
            Name = "煤矿场",
            PadX = 37576.707031, PadY = 7152.552734, PadZ = 124.240067,
            HallX = 24350, HallY = 27600, HallZ = 220,
        },
        [3] = {
            Name = "黄铜矿脉",
            PadX = 41571.179688, PadY = 32947.742188, PadZ = 124.224442,
            HallX = 23010, HallY = 31740, HallZ = 220,
        },
        [4] = {
            Name = "深层矿区",
            PadX = 36463.558594, PadY = 46880.234375, PadZ = 124.236160,
            HallX = 18660, HallY = 31740, HallZ = 220,
        },
        [5] = {
            Name = "宝石矿区",
            PadX = 13395.021484, PadY = 51551.093750, PadZ = 124.224442,
            HallX = 17320, HallY = 27600, HallZ = 220,
        },
    },
}

function MineTeleportConfig.GetZone(ZoneId)
    local Id = tonumber(ZoneId) or 0
    if Id == MineTeleportConfig.SPAWN_ZONE_ID then
        return {
            Name = "出生点",
            PadX = MineTeleportConfig.SpawnPoint.X,
            PadY = MineTeleportConfig.SpawnPoint.Y,
            PadZ = MineTeleportConfig.SpawnPoint.Z,
            IsSpawn = true,
        }
    end
    return MineTeleportConfig.Zones[Id]
end

function MineTeleportConfig.GetZoneCount()
    return 5
end

function MineTeleportConfig.GetTotalCount()
    return 6
end

function MineTeleportConfig.IsSpawnZone(ZoneId)
    return tonumber(ZoneId) == MineTeleportConfig.SPAWN_ZONE_ID
end

function MineTeleportConfig.NextZoneId(CurrentId)
    local N = MineTeleportConfig.GetTotalCount()
    local Id = tonumber(CurrentId) or 1
    Id = Id + 1
    if Id > N then
        Id = 1
    end
    return Id
end

function MineTeleportConfig.GetSpawnPoint()
    return MineTeleportConfig.SpawnPoint
end

function MineTeleportConfig.GetTeleportCost(ZoneId)
    if MineTeleportConfig.IsSpawnZone(ZoneId) then
        return MineTeleportConfig.SpawnCost or 0
    end
    return MineTeleportConfig.TeleportCost
end

return MineTeleportConfig
