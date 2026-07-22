--- 矿区传送大厅配置（Mine_02-main）
--- 解锁 8500 / 单次传送 3000
--- 落点围绕出生点与现有矿区临时标定，可按实装再调
local MineTeleportConfig = {
    UnlockCost = 8500,
    TeleportCost = 3000,
    Zones = {
        [1] = { Name = "石滩", PadX = 20000, PadY = 28000, PadZ = 220, VolumeLabel = "MineZone_01_StoneBeach" },
        [2] = { Name = "煤矿场", PadX = 21000, PadY = 28000, PadZ = 220, VolumeLabel = "MineZone_02_CoalField" },
        [3] = { Name = "黄铜矿脉", PadX = 22000, PadY = 28000, PadZ = 220, VolumeLabel = "MineZone_03_CopperVein" },
        [4] = { Name = "深层矿区", PadX = 20000, PadY = 29200, PadZ = 220, VolumeLabel = "MineZone_04_DeepMine" },
        [5] = { Name = "宝石矿区", PadX = 21000, PadY = 29200, PadZ = 220, VolumeLabel = "MineZone_05_GemMine" },
        [6] = { Name = "玉石矿脉", PadX = 22000, PadY = 29200, PadZ = 220, VolumeLabel = "MineZone_06_JadeVein" },
    },
}

function MineTeleportConfig.GetZone(ZoneId)
    return MineTeleportConfig.Zones[tonumber(ZoneId) or 0]
end

function MineTeleportConfig.GetZoneCount()
    return 6
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

return MineTeleportConfig
