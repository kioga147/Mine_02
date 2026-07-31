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

-- 3x3网格生成配置：每个矿区按网格布局生成矿石
local GRID_CONFIG = {
    GridSizeX = 3,
    GridSizeY = 3,
    SpacingX = 300,
    SpacingY = 300,
}

local ZONES = {
    [1] = {
        Name = "石滩",
        CenterX = 20830,
        CenterY = 24540,
        CenterZ = 220,
        RadiusX = 800,
        RadiusY = 600,
        UseGrid = true,
        GridConfig = { GridSizeX = 3, GridSizeY = 3, SpacingX = 200, SpacingY = 200 },
        RespawnMode = "AllAtOnce",
        RespawnDelay = 1,
        OreDist = {
            { OreKey = "Stone",   Count = 9,  RespawnSec = 0 },
        },
        SpecialDrop = {
            OreKey = "JadeOre",
            Chance = 0.01,
            Count = 1,
        },
    },
    [2] = {
        Name = "煤矿场",
        CenterX = 24830,
        CenterY = 27440,
        CenterZ = 220,
        RadiusX = 700,
        RadiusY = 500,
        UseGrid = true,
        GridConfig = { GridSizeX = 3, GridSizeY = 3, SpacingX = 250, SpacingY = 250 },
        RespawnMode = "NoPlayers",
        RespawnDelay = 2,
        OreDist = {
            { OreKey = "Coal",    Count = 7, RespawnSec = 8 },
            { OreKey = "Stone",   Count = 2, RespawnSec = 5 },
        },
    },
    [3] = {
        Name = "黄铜矿脉",
        CenterX = 23300,
        CenterY = 32140,
        CenterZ = 220,
        RadiusX = 600,
        RadiusY = 500,
        UseGrid = true,
        GridConfig = { GridSizeX = 3, GridSizeY = 3, SpacingX = 250, SpacingY = 250 },
        RespawnMode = "NoPlayers",
        RespawnDelay = 2,
        OreDist = {
            { OreKey = "CopperOre", Count = 5, RespawnSec = 10 },
            { OreKey = "IronOre",   Count = 3, RespawnSec = 10 },
            { OreKey = "Stone",     Count = 1, RespawnSec = 5 },
        },
    },
    [4] = {
        Name = "深层矿区",
        CenterX = 18360,
        CenterY = 32140,
        CenterZ = 220,
        RadiusX = 800,
        RadiusY = 600,
        UseGrid = true,
        GridConfig = { GridSizeX = 3, GridSizeY = 3, SpacingX = 280, SpacingY = 280 },
        RespawnMode = "NoPlayers",
        RespawnDelay = 2,
        OreDist = {
            { OreKey = "Quartz",    Count = 3, RespawnSec = 15 },
            { OreKey = "Bauxite",   Count = 2, RespawnSec = 15 },
            { OreKey = "GoldOre",   Count = 2, RespawnSec = 20 },
            { OreKey = "Stone",     Count = 1, RespawnSec = 5 },
            { OreKey = "Diamond",   Count = 1, RespawnSec = 600 },
        },
    },
    [5] = {
        Name = "宝石矿区",
        CenterX = 16840,
        CenterY = 27440,
        CenterZ = 220,
        RadiusX = 700,
        RadiusY = 500,
        UseGrid = true,
        GridConfig = { GridSizeX = 3, GridSizeY = 3, SpacingX = 280, SpacingY = 280 },
        RespawnMode = "NoPlayers",
        RespawnDelay = 2,
        OreDist = {
            { OreKey = "Diamond", Count = 3, RespawnSec = 30 },
            { OreKey = "RubyOre", Count = 3, RespawnSec = 30 },
            { OreKey = "JadeOre", Count = 2, RespawnSec = 45 },
            { OreKey = "Stone",   Count = 1, RespawnSec = 5 },
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

    -- 检查是否使用网格生成
    if zone.UseGrid and zone.GridConfig then
        local gridConfig = zone.GridConfig
        local gridSizeX = gridConfig.GridSizeX or 3
        local gridSizeY = gridConfig.GridSizeY or 3
        local spacingX = gridConfig.SpacingX or 300
        local spacingY = gridConfig.SpacingY or 300
        local totalGridCells = gridSizeX * gridSizeY

        -- 收集所有需要生成的矿石
        local oreQueue = {}
        for _, oreEntry in ipairs(zone.OreDist) do
            for i = 1, (oreEntry.Count or 0) do
                table.insert(oreQueue, {
                    OreKey = oreEntry.OreKey,
                    RespawnSec = oreEntry.RespawnSec or 10,
                    IsSpecial = oreEntry.IsSpecial or false,
                })
            end
        end

        -- 如果矿石总数少于网格数，用最后一个矿石类型填充
        while #oreQueue < totalGridCells do
            local lastEntry = zone.OreDist[#zone.OreDist]
            if lastEntry then
                table.insert(oreQueue, {
                    OreKey = lastEntry.OreKey,
                    RespawnSec = lastEntry.RespawnSec or 10,
                    IsSpecial = lastEntry.IsSpecial or false,
                })
            else
                break
            end
        end

        -- 按网格位置分配矿石
        local oreIndex = 1
        for gridY = 0, gridSizeY - 1 do
            for gridX = 0, gridSizeX - 1 do
                if oreIndex <= #oreQueue then
                    local oreData = oreQueue[oreIndex]
                    local offsetX = (gridX - (gridSizeX - 1) / 2) * spacingX
                    local offsetY = (gridY - (gridSizeY - 1) / 2) * spacingY
                    local offsetZ = math.random(-20, 20)

                    table.insert(positions, {
                        OreKey = oreData.OreKey,
                        X = zone.CenterX + offsetX,
                        Y = zone.CenterY + offsetY,
                        Z = zone.CenterZ + offsetZ,
                        RespawnSec = oreData.RespawnSec,
                        IsSpecial = oreData.IsSpecial,
                        GridX = gridX,
                        GridY = gridY,
                    })
                    oreIndex = oreIndex + 1
                end
            end
        end
    else
        -- 原有随机生成逻辑
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
    end

    return positions
end

function MineZoneConfig.GetSpecialDrop(ZoneId)
    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil or zone.SpecialDrop == nil then
        return nil
    end
    return zone.SpecialDrop
end

function MineZoneConfig.IsUseGrid(ZoneId)
    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return false
    end
    return zone.UseGrid == true
end

function MineZoneConfig.GetRespawnMode(ZoneId)
    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return "Individual"
    end
    return zone.RespawnMode or "Individual"
end

function MineZoneConfig.GetRespawnDelay(ZoneId)
    local zone = MineZoneConfig.GetZone(ZoneId)
    if zone == nil then
        return 5
    end
    return zone.RespawnDelay or 5
end

return MineZoneConfig
