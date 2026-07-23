--- 矿石加工厂 / 冶炼配置（Mine_02）
--- 石英不进配方；铝土 → 精炼铝；跳过 50 绿洲币（对应约 5R）
local SmeltingConfig = {
    PlantUnlockCost = 10000,
    PlantUpgradeCost = 10000,
    MaxBatchCount = 50,
    DurationSec = 600,
    SkipOasisCost = 50,
    CoalItemId = 8310003,
    GoldItemId = 8310002,
    --- 绿洲币商品 ID：在平台商城配置后填入；0 表示走软扣费（仅校验余额，便于联调）
    OasisProductIds = {
        Skip = 0,
        Furnace = 0,
    },
    --- ProductId==0 时是否允许软扣费（校验 GetTicket 后直接发货）。正式上线建议 false + 配好商品。
    AllowSoftOasisSpend = true,
    --- 炉号 → 解锁费用（第 1 炉随工厂解锁赠送）
    FurnaceUnlock = {
        [2] = { Gold = 20000, Oasis = 100 },
        [3] = { Gold = 40000, Oasis = 100 },
        [4] = { Gold = 100000, Oasis = 100 },
        [5] = { Gold = nil, Oasis = 100 },
    },
    --- 粗矿配方：MineLevel 用于工厂等级门槛（一级仅可炼 MineLevel<=2）
    Recipes = {
        [8310004] = { Name = "粗铁矿", OutputId = 8310012, OutputName = "精炼铁矿", MineLevel = 2 },
        [8310005] = { Name = "粗铜矿", OutputId = 8310013, OutputName = "精炼铜矿", MineLevel = 2 },
        [8310007] = { Name = "粗金矿", OutputId = 8310014, OutputName = "精炼金矿", MineLevel = 3 },
        [8310008] = { Name = "铝土矿", OutputId = 8310015, OutputName = "精炼铝矿", MineLevel = 3 },
        [8310009] = { Name = "钻石矿", OutputId = 8310016, OutputName = "精加工钻石", MineLevel = 4 },
        [8310010] = { Name = "红宝石矿", OutputId = 8310017, OutputName = "精加工红宝石", MineLevel = 4 },
    },
    --- UI 循环用的粗矿顺序
    RecipeOrder = { 8310004, 8310005, 8310007, 8310008, 8310009, 8310010 },
    CountPresets = { 1, 5, 10, 25, 50 },
}

function SmeltingConfig.GetRecipe(ItemId)
    return SmeltingConfig.Recipes[tonumber(ItemId) or 0]
end

function SmeltingConfig.GetMaxMineLevelForPlant(PlantLevel)
    PlantLevel = math.floor(tonumber(PlantLevel) or 1)
    if PlantLevel >= 2 then
        return 99
    end
    return 2
end

function SmeltingConfig.CanRefine(ItemId, PlantLevel)
    local Recipe = SmeltingConfig.GetRecipe(ItemId)
    if Recipe == nil then
        return false
    end
    return (tonumber(Recipe.MineLevel) or 99) <= SmeltingConfig.GetMaxMineLevelForPlant(PlantLevel)
end

function SmeltingConfig.GetFurnaceCost(Slot)
    return SmeltingConfig.FurnaceUnlock[math.floor(tonumber(Slot) or 0)]
end

function SmeltingConfig.NextRecipeId(CurrentId, PlantLevel)
    local Order = SmeltingConfig.RecipeOrder
    local Start = 1
    local Cur = tonumber(CurrentId) or 0
    for i, Id in ipairs(Order) do
        if Id == Cur then
            Start = i + 1
            break
        end
    end
    local N = #Order
    for Offset = 0, N - 1 do
        local Idx = ((Start - 1 + Offset) % N) + 1
        local Id = Order[Idx]
        if SmeltingConfig.CanRefine(Id, PlantLevel) then
            return Id
        end
    end
    return Order[1]
end

function SmeltingConfig.FirstRecipeId(PlantLevel)
    for _, Id in ipairs(SmeltingConfig.RecipeOrder) do
        if SmeltingConfig.CanRefine(Id, PlantLevel) then
            return Id
        end
    end
    return SmeltingConfig.RecipeOrder[1]
end

function SmeltingConfig.NextCount(Current)
    local Presets = SmeltingConfig.CountPresets
    local Cur = math.floor(tonumber(Current) or 1)
    for i, V in ipairs(Presets) do
        if V == Cur then
            return Presets[(i % #Presets) + 1]
        end
    end
    return Presets[1]
end

return SmeltingConfig
