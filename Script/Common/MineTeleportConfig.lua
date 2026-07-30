--- 矿区传送大厅配置（Mine_02-main）
--- 解锁 8500 / 单次传送 3000 / 返回出生点 0
--- 5个矿区按五角星(五角形)布局环绕出生点(20830, 28740)，半径4200
--- Pad=传送落点(矿区中心), Hall=大厅位置(矿区边缘朝出生点方向)
local MineTeleportConfig = {
    UnlockCost = 8500,
    TeleportCost = 3000,
    ReturnCost = 0,
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
    return MineTeleportConfig.Zones[tonumber(ZoneId) or 0]
end

function MineTeleportConfig.GetZoneCount()
    return 5
end

function MineTeleportConfig.NextZoneId(CurrentId)
    local N = MineTeleportConfig.GetZoneCount()
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

function MineTeleportConfig.GetReturnCost()
    return MineTeleportConfig.ReturnCost or 0
end

return MineTeleportConfig
