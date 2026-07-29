local MineZoneConfig = {}

local ORE_PATHS = {
    Stone      = "Asset/Blueprint/Prefabs/LevelEntities/Stone.Stone_C",
    Coal       = "Asset/Blueprint/Prefabs/LevelEntities/Coal.Coal_C",
    IronOre    = "Asset/Blueprint/Prefabs/LevelEntities/Iron_ore.Iron_ore_C",
    CopperOre  = "Asset/Blueprint/Prefabs/LevelEntities/Copper_mine.Copper_mine_C",
    Quartz     = "Asset/Blueprint/Prefabs/LevelEntities/Quartz.Quartz_C",
    GoldOre    = "Asset/Blueprint/Prefabs/LevelEntities/Gold_ore.Gold_ore_C",
    Bauxite    = "Asset/Blueprint/Prefabs/LevelEntities/Bauxite.Bauxite_C",
    Diamond    = "Asset/Blueprint/Prefabs/LevelEntities/Diamond_mine.Diamond_mine_C",
    RubyOre    = "Asset/Blueprint/Prefabs/LevelEntities/Ruby_mine.Ruby_mine_C",
    JadeOre    = "Asset/Blueprint/Prefabs/LevelEntities/Jade_ore.Jade_ore_C",
}

local ZONES = {
    [1] = {
        Name = "石滩",
        CenterX = 20000,
        CenterY = 28000,
        CenterZ = 220,
        RadiusX = 800,
        RadiusY = 600,
        OreDist = {
            { OreKey = "Stone",   Count = 40, RespawnSec = 5 },
            { OreKey = "Stone",   Count = 20, RespawnSec = 3, IsSpecial = true },
        },
        SpecialDrop = {
            OreKey = "JadeOre",
            Chance = 0.01,
        },
    },
    [2] = {
        Name = "煤矿场",
        CenterX = 40000,
        CenterY = 28000,
        CenterZ = 220,
        RadiusX = 700,
        RadiusY = 500,
        OreDist = {
            { OreKey = "Coal",    Count = 35, RespawnSec = 8 },
            { OreKey = "Stone",   Count = 10, RespawnSec = 5 },
            { OreKey = "Diamond", Count = 2,  RespawnSec = 300 },
        },
    },
    [3] = {
        Name = "黄铜矿脉",
        CenterX = 20000,
        CenterY = 8000,
        CenterZ = 220,
        RadiusX = 600,
        RadiusY = 500,
        OreDist = {
            { OreKey = "CopperOre", Count = 25, RespawnSec = 10 },
            { OreKey = "IronOre",   Count = 20, RespawnSec = 10 },
            { OreKey = "Stone",    Count = 10, RespawnSec = 5 },
        },
    },
    [4] = {
        Name = "深层矿区",
        CenterX = 20000,
        CenterY = 48000,
        CenterZ = 220,
        RadiusX = 800,
        RadiusY = 600,
        OreDist = {
            { OreKey = "Quartz",    Count = 20, RespawnSec = 15 },
            { OreKey = "Bauxite",   Count = 18, RespawnSec = 15 },
            { OreKey = "GoldOre",   Count = 12, RespawnSec = 20 },
            { OreKey = "Stone",     Count = 8,  RespawnSec = 5 },
            { OreKey = "Diamond",   Count = 3,  RespawnSec = 600 },
            { OreKey = "RubyOre",   Count = 3,  RespawnSec = 600 },
        },
    },
    [5] = {
        Name = "宝石矿区",
        CenterX = 0,
        CenterY = 28000,
        CenterZ = 220,
        RadiusX = 700,
        RadiusY = 500,
        OreDist = {
            { OreKey = "Diamond", Count = 15, RespawnSec = 30 },
            { OreKey = "RubyOre", Count = 15, RespawnSec = 30 },
            { OreKey = "JadeOre", Count = 8,  RespawnSec = 45 },
            { OreKey = "Stone",   Count = 10, RespawnSec = 5 },
        },
    },
}

function MineZoneConfig.GetZone(ZoneId)
    return ZONES[tonumber(ZoneId) or 0]
end

function MineZoneConfig.GetZoneCount()
    return 5
end

function MineZoneConfig.GetZoneIds()
    local ids = {}
    for id = 1, MineZoneConfig.GetZoneCount() do
        table.insert(ids, id)
    end
    return ids
end

function MineZoneConfig.GetOrePath(OreKey)
    return ORE_PATHS[OreKey]
end

function MineZoneConfig.GetAllOreKeys()
    local keys = {}
    for key, _ in pairs(ORE_PATHS) do
        table.insert(keys, key)
    end
    return keys
end

function MineZoneConfig.GetTotalOreCount(ZoneId)
    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil or zone.OreDist == nil then
        return 0
    end
    local total = 0
    for _, oreEntry in ipairs(zone.OreDist) do
        total = total + (oreEntry.Count or 0)
    end
    return total
end

function MineZoneConfig.GenerateSpawnPositions(ZoneId)
    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return {}
    end

    local positions = {}

    for _, oreEntry in ipairs(zone.OreDist) do
        for i = 1, (oreEntry.Count or 0) do
            local offsetX = math.random(-zone.RadiusX, zone.RadiusX)
            local offsetY = math.random(-zone.RadiusY, zone.RadiusY)
            local offsetZ = math.random(-20, 20)

            table.insert(positions, {
                OreKey = oreEntry.OreKey,
                X = zone.CenterX + offsetX,
                Y = zone.CenterY + offsetY,
                Z = zone.CenterZ + offsetZ,
                RespawnSec = oreEntry.RespawnSec or 10,
                IsSpecial = oreEntry.IsSpecial or false,
            })
        end
    end

    return positions
end

return MineZoneConfig
