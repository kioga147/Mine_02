--- 矿区传送大厅配置（Mine_02-main）
--- 解锁 8500 / 矿区传送 3000 / 出生点传送 0
--- 5个矿区按五角星布局环绕出生点(20830, 28740)，半径4200
--- ZoneId 1-5 = 矿区, ZoneId 6 = 出生点
local MineTeleportConfig = {
    UnlockCost = 8500,
    TeleportCost = 3000,
    SpawnCost = 0,
    SPAWN_ZONE_ID = 6,
    SpawnPoint = { X = 20830, Y = 28740, Z = 192 },
    Zones = {
        [1] = {
            Name = "石滩",
            PadX = 20830, PadY = 24940, PadZ = 220,
            HallX = 20830, HallY = 25040, HallZ = 220,
        },
        [2] = {
            Name = "煤矿场",
            PadX = 24450, PadY = 27560, PadZ = 220,
            HallX = 24350, HallY = 27600, HallZ = 220,
        },
        [3] = {
            Name = "黄铜矿脉",
            PadX = 23070, PadY = 31820, PadZ = 220,
            HallX = 23010, HallY = 31740, HallZ = 220,
        },
        [4] = {
            Name = "深层矿区",
            PadX = 18600, PadY = 31820, PadZ = 220,
            HallX = 18660, HallY = 31740, HallZ = 220,
        },
        [5] = {
            Name = "宝石矿区",
            PadX = 17220, PadY = 27560, PadZ = 220,
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
