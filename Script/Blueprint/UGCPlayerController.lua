---@class UGCPlayerController_C:BP_PlayerController_TopDown_C
---@field RankingListComponent RankingListComponent_C
---@field TaskTemplateComponent TaskTemplateComponent_C
--Edit Below--
local MineTeleportConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.MineTeleportConfig")
    end)
    if Ok and type(Mod) == "table" then
        MineTeleportConfig = Mod
    else
        MineTeleportConfig = {
            UnlockCost = 8500,
            TeleportCost = 3000,
            Zones = {
                [1] = { Name = "石滩", PadX = 20830, PadY = 24940, PadZ = 220 },
                [2] = { Name = "煤矿场", PadX = 24450, PadY = 27560, PadZ = 220 },
                [3] = { Name = "黄铜矿脉", PadX = 23070, PadY = 31820, PadZ = 220 },
                [4] = { Name = "深层矿区", PadX = 18600, PadY = 31820, PadZ = 220 },
                [5] = { Name = "宝石矿区", PadX = 17220, PadY = 27560, PadZ = 220 },
            },
            GetZone = function(ZoneId)
                return MineTeleportConfig.Zones[tonumber(ZoneId) or 0]
            end,
        }
    end
end

local OreRecycleConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.OreRecycleConfig")
    end)
    if Ok and type(Mod) == "table" then
        OreRecycleConfig = Mod
    else
        OreRecycleConfig = {
            GoldItemId = 8310002,
            Prices = {
                [8310000] = { Name = "石头", Price = 50 },
                [8310003] = { Name = "煤矿", Price = 75 },
                [8310004] = { Name = "粗铁矿", Price = 100 },
                [8310005] = { Name = "粗铜矿", Price = 85 },
                [8310006] = { Name = "石英矿", Price = 120 },
                [8310007] = { Name = "粗金矿", Price = 250 },
                [8310008] = { Name = "铝土矿", Price = 180 },
                [8310009] = { Name = "钻石矿", Price = 800 },
                [8310010] = { Name = "红宝石矿", Price = 500 },
                [8310011] = { Name = "玉矿石（未鉴定）", Price = 600 },
                [8310012] = { Name = "精炼铁矿", Price = 200 },
                [8310013] = { Name = "精炼铜矿", Price = 170 },
                [8310014] = { Name = "精炼金矿", Price = 500 },
                [8310015] = { Name = "精炼铝矿", Price = 360 },
                [8310016] = { Name = "精加工钻石", Price = 1600 },
                [8310017] = { Name = "精加工红宝石", Price = 1000 },
            },
            GetEntry = function(ItemId)
                return OreRecycleConfig.Prices[tonumber(ItemId) or -1]
            end,
            GetPrice = function(ItemId)
                local E = OreRecycleConfig.GetEntry(ItemId)
                return E and E.Price or nil
            end,
            GetName = function(ItemId)
                local E = OreRecycleConfig.GetEntry(ItemId)
                return E and E.Name or "?"
            end,
            ResolveSellCount = function(Owned, Requested)
                Owned = math.floor(tonumber(Owned) or 0)
                Requested = math.floor(tonumber(Requested) or 0)
                if Owned <= 0 then
                    return 0
                end
                if Requested < 0 then
                    return Owned
                end
                if Requested <= 0 or Requested > Owned then
                    return 0
                end
                return Requested
            end,
        }
    end
end

local ShopV2ProductConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.ShopV2ProductConfig")
    end)
    if Ok and type(Mod) == "table" then
        ShopV2ProductConfig = Mod
    else
        ShopV2ProductConfig = {}
    end
end

local TitleConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.TitleConfig")
    end)
    if Ok and type(Mod) == "table" then
        TitleConfig = Mod
    else
        TitleConfig = {}
    end
end

local WarehouseConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.WarehouseConfig")
    end)
    if Ok and type(Mod) == "table" then
        WarehouseConfig = Mod
    else
        WarehouseConfig = {
            InitialSlots = 50,
            MaxSlots = 10050,
            SlotsPerUpgrade = 100,
            UpgradeGoldCost = 5000,
            UpgradeOasisCost = 50,
            OpenPanelStyle = nil,
            OpenPanelMode = 2,
            AllowSoftOasisSpend = true,
            GetUpgradeGoldCost = function()
                return 5000
            end,
            GetUpgradeOasisCost = function()
                return 50
            end,
            GetSlotsPerUpgrade = function()
                return 100
            end,
            GetInitialSlots = function()
                return 50
            end,
            GetMaxSlots = function()
                return 10050
            end,
            CanUpgrade = function(CurrentCapacity)
                CurrentCapacity = math.floor(tonumber(CurrentCapacity) or 0)
                return (CurrentCapacity + 100) <= 10050
            end,
        }
    end
end

local JadeCollectionConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.JadeCollectionConfig")
    end)
    if Ok and type(Mod) == "table" then
        JadeCollectionConfig = Mod
    else
        JadeCollectionConfig = {
            SlotCount = 5,
            BaseValue = 600,
            StateEmpty = 0,
            StateRaw = 1,
            StateAppraised = 2,
            TotalCells = 25,
            GetSlotCount = function()
                return 5
            end,
            GetBaseValue = function()
                return 600
            end,
            GetTotalCells = function()
                return 25
            end,
            GetStateName = function(State, OpenedCount, TotalCells)
                State = math.floor(tonumber(State) or 0)
                OpenedCount = math.floor(tonumber(OpenedCount) or 0)
                TotalCells = math.floor(tonumber(TotalCells) or 25)
                if State == 1 then
                    return "Raw Jade"
                end
                if State == 2 then
                    if TotalCells > 0 and OpenedCount >= TotalCells then
                        return "Fully Appraised Jade"
                    end
                    return "Partially Appraised Jade"
                end
                return "Empty Slot"
            end,
        }
    end
end

local TalentMarketConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.TalentMarketConfig")
    end)
    if Ok and type(Mod) == "table" then
        TalentMarketConfig = Mod
    else
        TalentMarketConfig = {
            UnlockCost = 5000,
            GoldItemId = 8310002,
            WorkerOrder = { 1, 2, 3 },
            Workers = {
                [1] = { Name = "低级工人", HireCost = 1000, DurationSec = 60, RewardCount = 50, MinMineLevel = 1, MaxMineLevel = 3 },
                [2] = { Name = "中级工人", HireCost = 10000, DurationSec = 60, RewardCount = 100, MinMineLevel = 1, MaxMineLevel = 4 },
                [3] = { Name = "高级矿工", HireCost = 100000, DurationSec = 60, RewardCount = 200, MinMineLevel = 3, MaxMineLevel = 5 },
            },
            OrePool = {
                { ItemId = 8310000, Name = "石头", MineLevel = 1 },
                { ItemId = 8310003, Name = "煤矿", MineLevel = 1 },
                { ItemId = 8310004, Name = "粗铁矿", MineLevel = 2 },
                { ItemId = 8310005, Name = "粗铜矿", MineLevel = 2 },
                { ItemId = 8310006, Name = "石英矿", MineLevel = 2 },
                { ItemId = 8310007, Name = "粗金矿", MineLevel = 3 },
                { ItemId = 8310008, Name = "铝土矿", MineLevel = 3 },
                { ItemId = 8310009, Name = "钻石矿", MineLevel = 4 },
                { ItemId = 8310010, Name = "红宝石矿", MineLevel = 4 },
                { ItemId = 8310011, Name = "玉矿石", MineLevel = 5 },
            },
            GetWorker = function(WorkerId)
                return TalentMarketConfig.Workers[math.floor(tonumber(WorkerId) or 0)]
            end,
            GetFirstWorkerId = function()
                return 1
            end,
            NextWorkerId = function(CurrentId)
                local Cur = math.floor(tonumber(CurrentId) or 0)
                if Cur == 1 then
                    return 2
                elseif Cur == 2 then
                    return 3
                end
                return 1
            end,
            RollRewards = function(WorkerId)
                local Worker = TalentMarketConfig.GetWorker(WorkerId)
                if Worker == nil then
                    return nil
                end
                local Pool = {}
                for _, Ore in ipairs(TalentMarketConfig.OrePool) do
                    if Ore.MineLevel >= Worker.MinMineLevel and Ore.MineLevel <= Worker.MaxMineLevel then
                        Pool[#Pool + 1] = Ore
                    end
                end
                local Rewards = {}
                for _ = 1, math.floor(tonumber(Worker.RewardCount) or 0) do
                    local Ore = Pool[math.random(1, #Pool)]
                    Rewards[Ore.ItemId] = (Rewards[Ore.ItemId] or 0) + 1
                end
                return Rewards
            end,
            FormatDuration = function(DurationSec)
                return tostring(math.floor((tonumber(DurationSec) or 0) / 60)) .. "分钟"
            end,
            FormatRewards = function(Rewards)
                local Lines = {}
                for ItemId, Count in pairs(Rewards or {}) do
                    Lines[#Lines + 1] = tostring(ItemId) .. " x" .. tostring(Count)
                end
                table.sort(Lines)
                return table.concat(Lines, "、")
            end,
        }
    end
end

local VehicleRepairConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.VehicleRepairConfig")
    end)
    if Ok and type(Mod) == "table" then
        VehicleRepairConfig = Mod
    else
        VehicleRepairConfig = {
            UnlockCost = 5000,
            RepairCost = 1000,
            DamageChance = 10,
            GoldItemId = 8310002,
            VehicleOrder = { 1, 2, 3 },
            Vehicles = {
                [1] = { ItemId = 8310025, Name = "初级采矿车", RangeText = "3x3", MineLevel = 2 },
                [2] = { ItemId = 8310024, Name = "中级采矿车", RangeText = "5x5", MineLevel = 4 },
                [3] = { ItemId = 8310023, Name = "高级采矿车", RangeText = "7x7", MineLevel = 5 },
            },
            GetVehicle = function(VehicleId)
                local Id = math.floor(tonumber(VehicleId) or 0)
                if VehicleRepairConfig.Vehicles[Id] then
                    return VehicleRepairConfig.Vehicles[Id], Id
                end
                for Key, Vehicle in pairs(VehicleRepairConfig.Vehicles) do
                    if math.floor(tonumber(Vehicle.ItemId) or 0) == Id then
                        return Vehicle, Key
                    end
                end
                return nil, 0
            end,
            GetFirstVehicleId = function()
                return 1
            end,
            NextVehicleId = function(CurrentId)
                local Cur = math.floor(tonumber(CurrentId) or 0)
                if Cur == 1 then
                    return 2
                elseif Cur == 2 then
                    return 3
                end
                return 1
            end,
            RollDamage = function()
                return math.random(1, 100) <= 10
            end,
        }
    end
end

local SmeltingConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.SmeltingConfig")
    end)
    if Ok and type(Mod) == "table" then
        SmeltingConfig = Mod
    else
        SmeltingConfig = {
            PlantUnlockCost = 10000,
            PlantUpgradeCost = 10000,
            MaxBatchCount = 50,
            DurationSec = 60,
            SkipOasisCost = 50,
            CoalItemId = 8310003,
            GoldItemId = 8310002,
            AllowSoftOasisSpend = true,
            OasisProductIds = { Skip = 0, Furnace = 0 },
            FurnaceUnlock = {
                [2] = { Gold = 20000, Oasis = 100 },
                [3] = { Gold = 40000, Oasis = 100 },
                [4] = { Gold = 100000, Oasis = 100 },
                [5] = { Gold = nil, Oasis = 100 },
            },
            Recipes = {
                [8310004] = { Name = "粗铁矿", OutputId = 8310012, OutputName = "精炼铁矿", MineLevel = 2 },
                [8310005] = { Name = "粗铜矿", OutputId = 8310013, OutputName = "精炼铜矿", MineLevel = 2 },
                [8310007] = { Name = "粗金矿", OutputId = 8310014, OutputName = "精炼金矿", MineLevel = 3 },
                [8310008] = { Name = "铝土矿", OutputId = 8310015, OutputName = "精炼铝矿", MineLevel = 3 },
                [8310009] = { Name = "钻石矿", OutputId = 8310016, OutputName = "精加工钻石", MineLevel = 4 },
                [8310010] = { Name = "红宝石矿", OutputId = 8310017, OutputName = "精加工红宝石", MineLevel = 4 },
            },
            RecipeOrder = { 8310004, 8310005, 8310007, 8310008, 8310009, 8310010 },
            GetRecipe = function(ItemId)
                return SmeltingConfig.Recipes[tonumber(ItemId) or 0]
            end,
            GetMaxMineLevelForPlant = function(PlantLevel)
                if math.floor(tonumber(PlantLevel) or 1) >= 2 then
                    return 99
                end
                return 2
            end,
            CanRefine = function(ItemId, PlantLevel)
                local Recipe = SmeltingConfig.GetRecipe(ItemId)
                if Recipe == nil then
                    return false
                end
                return (tonumber(Recipe.MineLevel) or 99) <= SmeltingConfig.GetMaxMineLevelForPlant(PlantLevel)
            end,
            GetFurnaceCost = function(Slot)
                return SmeltingConfig.FurnaceUnlock[math.floor(tonumber(Slot) or 0)]
            end,
            FirstRecipeId = function(PlantLevel)
                for _, Id in ipairs(SmeltingConfig.RecipeOrder) do
                    if SmeltingConfig.CanRefine(Id, PlantLevel) then
                        return Id
                    end
                end
                return SmeltingConfig.RecipeOrder[1]
            end,
            NextRecipeId = function(CurrentId, PlantLevel)
                return SmeltingConfig.FirstRecipeId(PlantLevel)
            end,
            NextCount = function(Current)
                local Presets = { 1, 5, 10, 25, 50 }
                local Cur = math.floor(tonumber(Current) or 1)
                for i, V in ipairs(Presets) do
                    if V == Cur then
                        return Presets[(i % #Presets) + 1]
                    end
                end
                return 1
            end,
        }
    end
end

local ShopConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.ShopConfig")
    end)
    if Ok and type(Mod) == "table" then
        ShopConfig = Mod
    else
        ShopConfig = {
            GoldItemId = 8310002,
            Tools = {},
            BackpackLevels = {},
            GetTool = function() return nil end,
            GetToolCount = function() return 0 end,
            GetBackpackLevel = function() return nil end,
            GetMaxBackpackLevel = function() return 0 end,
        }
    end
end

-- 付费/商业化系统
local PaymentSystem = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.GamePartCustom.PaymentSystem")
    end)
    if Ok and type(Mod) == "table" then
        PaymentSystem = Mod
    end
end

-- 玉石鉴定逻辑对齐 TESTWK；物品 ID 使用 Mine_02 现有表：
-- 8310011 = 玉矿石（未鉴定） Mine_10
-- 8310018 = 玉石 Mine_17（兼容；当前与 8310011 同为可鉴定原料，鉴定出售直接发金币、不产出 8310018）
-- 8310002 = 金币 Coin
-- 注意：取消鉴定时「返回/产出何种物品」需策划讨论后再定（当前实现为开会话前不扣玉，关闭仅清会话）。
local JADE_ITEM_ID = 8310011
local JADE_ITEM_ID_LEGACY = 8310018
local GOLD_ITEM_ID = 8310002
-- 铜镐 ItemID（与物品表 / MiningSystem 一致）
local COPPER_PICKAXE_ITEM_ID = 8310026
-- 测试币 ItemID（商店自定义货币，对应 UGCObject 表 1001）
local TEST_COIN_ITEM_ID = 1001
local UNLOCK_COST = 15000
local QUICK_COST = 3000
local JADE_BASE_VALUE = 600
local JADE_CELL_COUNT = 25
local MINE_TELEPORT_UNLOCK_COST = MineTeleportConfig.UnlockCost or 8500
local MINE_TELEPORT_COST = MineTeleportConfig.TeleportCost or 3000
local INITIAL_PICKAXE_DELAY_SEC = 8.0
local INITIAL_PICKAXE_RETRY_SEC = 3.0
local INITIAL_PICKAXE_EQUIP_DELAY_SEC = 2.0
local INITIAL_PICKAXE_MAX_RETRY = 8
local MELEE_WEAPON_SLOT = 4
local MELEE_SLOT_NAME = "EquipmentSlot.Core.MeleeSlot"
local INITIAL_PICKAXE_SWITCH_DELAY_SEC = 1.0

local function GetBackpackCapacity(PC)
    if not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetCellCapacity then return 0 end
    local Ok, Cap = pcall(UGCBackpackSystemV2.GetCellCapacity, PC)
    return (Ok and Cap) and math.floor(tonumber(Cap) or 0) or 0
end

local function GetBackpackLevelFromCapacity(Capacity)
    Capacity = math.floor(tonumber(Capacity) or 0)
    local Level = 1
    if ShopConfig and ShopConfig.GetMaxBackpackLevel then
        for Lv = 1, ShopConfig.GetMaxBackpackLevel() do
            local Cfg = ShopConfig.GetBackpackLevel(Lv)
            if Cfg and Capacity >= Cfg.Slots then
                Level = Lv
            end
        end
    end
    return Level
end

local function GetItemCount(PC, ItemID)
    if not PC or not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetItemCountV2 then
        return 0
    end
    local Ok, Count = pcall(UGCBackpackSystemV2.GetItemCountV2, PC, ItemID)
    if Ok then
        return tonumber(Count) or 0
    end
    return 0
end

local function GetJadeCount(PC)
    return GetItemCount(PC, JADE_ITEM_ID) + GetItemCount(PC, JADE_ITEM_ID_LEGACY)
end

local function GetGoldCount(PC)
    return GetItemCount(PC, GOLD_ITEM_ID)
end

local function RemoveOneJade(PC)
    local CountNew = GetItemCount(PC, JADE_ITEM_ID)
    if CountNew >= 1 then
        UGCBackpackSystemV2.RemoveItemV2(PC, JADE_ITEM_ID, 1)
        return true
    end
    local CountOld = GetItemCount(PC, JADE_ITEM_ID_LEGACY)
    if CountOld >= 1 then
        UGCBackpackSystemV2.RemoveItemV2(PC, JADE_ITEM_ID_LEGACY, 1)
        return true
    end
    return false
end

local function TryRemoveGold(PC, Amount)
    Amount = math.floor(tonumber(Amount) or 0)
    if Amount <= 0 then
        return true
    end
    if GetGoldCount(PC) < Amount then
        return false
    end
    UGCBackpackSystemV2.RemoveItemV2(PC, GOLD_ITEM_ID, Amount)
    return true
end

local function IsJadeShopUnlocked(PC)
    return PC ~= nil and PC.bJadeShopUnlocked == true
end

local function IsMineTeleportUnlocked(PC)
    return PC ~= nil and PC.bMineTeleportUnlocked == true
end

local function TeleportPawnTo(PC, X, Y, Z)
    ugcprint(string.format("[Teleport] ? 开始传送 (%.0f,%.0f,%.0f)", X, Y, Z))
    
    ugcprint("[Teleport] ① ForceStopMineCarMode...")
    pcall(function()
        local PawnStop = GetPawnByControllerSafe(PC)
        if PawnStop and PawnStop.SetMineCarMode then
            PawnStop:SetMineCarMode(false)
        end
    end)
    ugcprint("[Teleport] ① ForceStopMineCarMode 完成")

    local Pawn = nil
    ugcprint("[Teleport] ② 尝试获取 Pawn...")
    if PC then
        if PC.GetPlayerCharacterSafety then
            local Ok, P = pcall(function()
                return PC:GetPlayerCharacterSafety()
            end)
            ugcprint(string.format("[Teleport] ②a GetPlayerCharacterSafety: Ok=%s, Pawn=%s", tostring(Ok), tostring(P)))
            if Ok then Pawn = P end
        end
        if Pawn == nil and PC.K2_GetPawn then
            local Ok, P = pcall(function()
                return PC:K2_GetPawn()
            end)
            ugcprint(string.format("[Teleport] ②b K2_GetPawn: Ok=%s, Pawn=%s", tostring(Ok), tostring(P)))
            if Ok then Pawn = P end
        end
    end
    if Pawn == nil and UGCGameSystem and UGCGameSystem.GetPlayerPawn then
        local Ok, P = pcall(UGCGameSystem.GetPlayerPawn, PC)
        ugcprint(string.format("[Teleport] ②c GetPlayerPawn: Ok=%s, Pawn=%s", tostring(Ok), tostring(P)))
        if Ok then Pawn = P end
    end
    if Pawn == nil then
        ugcprint("[Teleport] ❌ 找不到 Pawn")
        return false
    end
    ugcprint(string.format("[Teleport] ② Pawn 获取成功: %s", tostring(Pawn)))

    pcall(function()
        if Pawn.SetMineCarMode then Pawn:SetMineCarMode(false) end
    end)

    local Loc = Vector.New(X, Y, Z)
    ugcprint(string.format("[Teleport] ③ 目标位置: %s", tostring(Loc)))

    -- 方案1: K2_TeleportTo (仅2个参数: DestLocation, DestRotation)
    if Pawn.K2_TeleportTo then
        ugcprint("[Teleport] 尝试 K2_TeleportTo(2参数)")
        local Ok1, Err1 = pcall(function()
            Pawn:K2_TeleportTo(Loc, Pawn:K2_GetActorRotation())
        end)
        ugcprint(string.format("[Teleport] K2_TeleportTo: Ok=%s, Err=%s", tostring(Ok1), tostring(Err1)))
        if Ok1 then
            local curLoc = Pawn:K2_GetActorLocation()
            if curLoc and math.abs(curLoc.X - X) < 100 then
                ugcprint("[Teleport] ✅ K2_TeleportTo 成功")
                return true
            else
                ugcprint(string.format("[Teleport] K2_TeleportTo 位置不匹配: curX=%.0f, expected=%.0f",
                    curLoc and curLoc.X or 0, X))
            end
        end
    end

    -- 方案2: K2_SetActorLocation (3参数: NewLocation, bSweep, SweepHitResult)
    if Pawn.K2_SetActorLocation then
        ugcprint("[Teleport] 尝试 K2_SetActorLocation(3参数)")
        local Ok2, Err2 = pcall(function()
            Pawn:K2_SetActorLocation(Loc, false, nil)
        end)
        ugcprint(string.format("[Teleport] K2_SetActorLocation: Ok=%s, Err=%s", tostring(Ok2), tostring(Err2)))
        if Ok2 then
            local curLoc = Pawn:K2_GetActorLocation()
            if curLoc and math.abs(curLoc.X - X) < 100 then
                ugcprint("[Teleport] ✅ K2_SetActorLocation 成功")
                return true
            else
                ugcprint(string.format("[Teleport] K2_SetActorLocation 位置不匹配: curX=%.0f, expected=%.0f",
                    curLoc and curLoc.X or 0, X))
            end
        end
    end

    -- 方案3: SetActorLocation (UE 原生, 可能不存在)
    if Pawn.SetActorLocation then
        ugcprint("[Teleport] 尝试 SetActorLocation")
        local Ok3, Err3 = pcall(function()
            Pawn:SetActorLocation(Loc)
        end)
        ugcprint(string.format("[Teleport] SetActorLocation: Ok=%s, Err=%s", tostring(Ok3), tostring(Err3)))
        if Ok3 then
            local curLoc = Pawn:K2_GetActorLocation()
            if curLoc and math.abs(curLoc.X - X) < 100 then
                ugcprint("[Teleport] ✅ SetActorLocation 成功")
                return true
            end
        end
    end

    ugcprint("[Teleport] ❌ 所有方案均失败")
    return false
end

--- 与 WBP_JadeAppraisal 价值公式一致（仅服务端记账）
local function ApplyLevelToValue(Value, Level)
    if Level == 5 then
        return Value + 1200
    elseif Level == 4 then
        return Value + 800
    elseif Level == 3 then
        return Value + 200
    elseif Level == 2 then
        return Value * (2 / 3)
    elseif Level == 1 then
        return Value * 0.5
    end
    return Value
end

local function ClearManualSession(PC)
    if PC then
        PC.JadeManualSession = nil
    end
end

local function GetManualSession(PC)
    local Session = PC and PC.JadeManualSession
    if Session and Session.Active then
        return Session
    end
    return nil
end

--- 是否为本机操控的 PlayerController（含 ListenServer 主机）
local function IsLocalPC(PC)
    if not PC then
        return false
    end
    local LocalPC = UGCGameSystem.GetLocalPlayerController()
    return LocalPC ~= nil and LocalPC == PC
end

--- ListenServer 主机上 Client RPC 往往不会回投到本机，本机直调；远端仍走 RPC
local function InvokeClient(PC, FuncName, ...)
    if not PC or not FuncName then
        return
    end
    if IsLocalPC(PC) and type(PC[FuncName]) == "tion" then
        PC[FuncName](PC, ...)
        return
    end
    UnrealNetwork.CallUnrealRPC(PC, PC, FuncName, ...)
end

--- 已在服务端（含 ListenServer 主机）时直调 Server_，避免 RPC 丢失
local function InvokeServer(PC, FuncName, ...)
    if not PC or not FuncName then
        return
    end
    if UGCGameSystem.IsServer() and type(PC[FuncName]) == "tion" then
        PC[FuncName](PC, ...)
        return
    end
    UnrealNetwork.CallUnrealRPC(PC, PC, FuncName, ...)
end

local function GetJadeCollectionSlotCount()
    if JadeCollectionConfig and JadeCollectionConfig.GetSlotCount then
        return math.max(1, math.floor(tonumber(JadeCollectionConfig.GetSlotCount()) or 5))
    end
    return 5
end

local function GetJadeCollectionTotalCells()
    if JadeCollectionConfig and JadeCollectionConfig.GetTotalCells then
        return math.max(1, math.floor(tonumber(JadeCollectionConfig.GetTotalCells()) or JADE_CELL_COUNT))
    end
    return JADE_CELL_COUNT
end

local function GetJadeCollectionBaseValue()
    if JadeCollectionConfig and JadeCollectionConfig.GetBaseValue then
        return math.max(0, math.floor(tonumber(JadeCollectionConfig.GetBaseValue()) or JADE_BASE_VALUE))
    end
    return JADE_BASE_VALUE
end

local function ClampJadeCollectionSlot(Slot)
    local SlotCount = GetJadeCollectionSlotCount()
    Slot = math.floor(tonumber(Slot) or 1)
    if Slot < 1 then
        Slot = 1
    elseif Slot > SlotCount then
        Slot = SlotCount
    end
    return Slot
end

local function GetJadeOwnerName(PC)
    if PC then
        if PC.PlayerState ~= nil then
            local Ok, Name = pcall(function()
                if PC.PlayerState.GetPlayerName then
                    return PC.PlayerState:GetPlayerName()
                end
                return PC.PlayerState.PlayerName
            end)
            if Ok and Name ~= nil and tostring(Name) ~= "" then
                return tostring(Name)
            end
        end
        local Ok, Name = pcall(function()
            if PC.GetName then
                return PC:GetName()
            end
            return nil
        end)
        if Ok and Name ~= nil and tostring(Name) ~= "" then
            return tostring(Name)
        end
    end
    return "玩家"
end

local function CountOpenedJadeCells(Opened)
    local Count = 0
    if type(Opened) == "table" then
        for _ in pairs(Opened) do
            Count = Count + 1
        end
    end
    return Count
end

local function CreateJadeCollectionDisplay(State, Value, OwnerName, OpenedCount, TotalCells)
    return {
        State = math.floor(tonumber(State) or 0),
        Value = math.max(0, math.floor(tonumber(Value) or 0)),
        OwnerName = tostring(OwnerName or ""),
        OpenedCount = math.max(0, math.floor(tonumber(OpenedCount) or 0)),
        TotalCells = math.max(1, math.floor(tonumber(TotalCells) or GetJadeCollectionTotalCells())),
    }
end

local function EnsureJadeCollectionDisplays(PC)
    if not PC then
        return {}
    end
    local SlotCount = GetJadeCollectionSlotCount()
    if type(PC.JadeCollectionDisplays) ~= "table" then
        PC.JadeCollectionDisplays = {}
    end
    for Slot = 1, SlotCount do
        local Display = PC.JadeCollectionDisplays[Slot]
        if type(Display) ~= "table" then
            PC.JadeCollectionDisplays[Slot] = CreateJadeCollectionDisplay(
                JadeCollectionConfig.StateEmpty, 0, "", 0, GetJadeCollectionTotalCells()
            )
        end
    end
    return PC.JadeCollectionDisplays
end

local function CopyJadeCollectionDisplays(Displays)
    local Result = {}
    local SlotCount = GetJadeCollectionSlotCount()
    for Slot = 1, SlotCount do
        local Display = Displays and Displays[Slot] or nil
        if type(Display) ~= "table" then
            Display = CreateJadeCollectionDisplay(JadeCollectionConfig.StateEmpty, 0, "", 0, GetJadeCollectionTotalCells())
        end
        Result[Slot] = CreateJadeCollectionDisplay(
            Display.State,
            Display.Value,
            Display.OwnerName,
            Display.OpenedCount,
            Display.TotalCells
        )
    end
    return Result
end

local function EncodeJadeCollectionDisplays(Displays)
    local Parts = {}
    local SlotCount = GetJadeCollectionSlotCount()
    for Slot = 1, SlotCount do
        local Display = Displays and Displays[Slot] or nil
        if type(Display) ~= "table" then
            Display = CreateJadeCollectionDisplay(JadeCollectionConfig.StateEmpty, 0, "", 0, GetJadeCollectionTotalCells())
        end
        local OwnerName = tostring(Display.OwnerName or "")
        OwnerName = string.gsub(OwnerName, "[|,]", " ")
        Parts[#Parts + 1] = table.concat({
            tostring(Slot),
            tostring(math.floor(tonumber(Display.State) or 0)),
            tostring(math.floor(tonumber(Display.Value) or 0)),
            tostring(math.floor(tonumber(Display.OpenedCount) or 0)),
            tostring(math.floor(tonumber(Display.TotalCells) or GetJadeCollectionTotalCells())),
            OwnerName,
        }, ",")
    end
    return table.concat(Parts, "|")
end

local function DecodeJadeCollectionDisplays(Encoded)
    local Displays = {}
    Encoded = tostring(Encoded or "")
    for Part in string.gmatch(Encoded, "([^|]+)") do
        local SlotRaw, StateRaw, ValueRaw, OpenedRaw, TotalRaw, OwnerRaw =
            string.match(Part, "^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),(.*)$")
        local Slot = ClampJadeCollectionSlot(SlotRaw)
        Displays[Slot] = CreateJadeCollectionDisplay(
            tonumber(StateRaw) or 0,
            tonumber(ValueRaw) or 0,
            OwnerRaw or "",
            tonumber(OpenedRaw) or 0,
            tonumber(TotalRaw) or GetJadeCollectionTotalCells()
        )
    end
    return CopyJadeCollectionDisplays(Displays)
end

local function GetJadeCollectionCandidate(PC)
    local Session = GetManualSession(PC)
    if Session then
        return {
            Value = math.max(0, math.floor(tonumber(Session.CurrentValue) or JADE_BASE_VALUE)),
            OpenedCount = CountOpenedJadeCells(Session.Opened),
            TotalCells = GetJadeCollectionTotalCells(),
            bFromActiveSession = true,
        }
    end
    local Candidate = PC and PC.JadeCollectionCandidate
    if type(Candidate) ~= "table" and not UGCGameSystem.IsServer() then
        Candidate = PC and PC.ClientJadeCollectionCandidate
    end
    if type(Candidate) ~= "table" then
        return nil
    end
    return {
        Value = math.max(0, math.floor(tonumber(Candidate.Value) or JADE_BASE_VALUE)),
        OpenedCount = math.max(0, math.floor(tonumber(Candidate.OpenedCount) or 0)),
        TotalCells = math.max(1, math.floor(tonumber(Candidate.TotalCells) or GetJadeCollectionTotalCells())),
        bFromActiveSession = false,
    }
end

local function SaveJadeCollectionCandidateFromSession(PC, Session)
    if not PC or type(Session) ~= "table" then
        return
    end
    PC.JadeCollectionCandidate = {
        Value = math.max(0, math.floor(tonumber(Session.CurrentValue) or JADE_BASE_VALUE)),
        OpenedCount = CountOpenedJadeCells(Session.Opened),
        TotalCells = GetJadeCollectionTotalCells(),
    }
end

local function SyncJadeCollectionToClient(PC)
    local Displays = EnsureJadeCollectionDisplays(PC)
    local Candidate = GetJadeCollectionCandidate(PC)
    InvokeClient(
        PC,
        "Client_JadeCollectionSync",
        GetJadeCollectionSlotCount(),
        EncodeJadeCollectionDisplays(Displays),
        Candidate ~= nil and 1 or 0,
        Candidate and Candidate.Value or 0,
        Candidate and Candidate.OpenedCount or 0,
        Candidate and Candidate.TotalCells or GetJadeCollectionTotalCells()
    )
end

local UGCPlayerController = {}

function UGCPlayerController:OnStartFire(Press)
    self.Character = UGCGameSystem.GetLocalPlayerPawn()

    local CurrentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(self.Character)
    if CurrentWeapon then
        if Press then
            UGCGunSystem.StartFire(CurrentWeapon)
        else
            UGCGunSystem.StopFire(CurrentWeapon)
        end
    end
end

function UGCPlayerController:ReceiveBeginPlay()
    UGCPlayerController.SuperClass.ReceiveBeginPlay(self)
    if self.BackpackLevel == nil then
        self.BackpackLevel = 1
    end
    if self.bJadeShopUnlocked == nil then
        self.bJadeShopUnlocked = false
    end
    if self.bMineTeleportUnlocked == nil then
        self.bMineTeleportUnlocked = false
    end
    if self.bTalentMarketUnlocked == nil then
        self.bTalentMarketUnlocked = false
    end
    if self.bVehicleRepairUnlocked == nil then
        self.bVehicleRepairUnlocked = false
    end
    if self.bSmelterUnlocked == nil then
        self.bSmelterUnlocked = false
    end
    if self.SmelterPlantLevel == nil then
        self.SmelterPlantLevel = 1
    end
    if self.UnlockedFurnaceCount == nil then
        self.UnlockedFurnaceCount = 0
    end
    if self.SmeltSessions == nil then
        self.SmeltSessions = {}
    end
    if self.ClientSmeltSlots == nil then
        self.ClientSmeltSlots = {}
    end
    if self.JadeCollectionDisplays == nil then
        self.JadeCollectionDisplays = {}
    end
    if self.ClientJadeCollectionDisplays == nil then
        self.ClientJadeCollectionDisplays = {}
    end

    self.JadeCollectionCandidate = nil
    ClearManualSession(self)

    if UGCGameSystem.IsServer() then
        self:StartWealthRankTimer()
        self._WarehouseInitRetry = 0
        local InitWarehouseLater = nil
        InitWarehouseLater = function()
            if not UGCObjectUtility.IsObjectValid(self) then
                return
            end
            self:EnsureWarehouseInitialCapacity()
            self._WarehouseInitRetry = (self._WarehouseInitRetry or 0) + 1
            local Cap = 0
            if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetWarehouseCellCapacity then
                local OkCap, RetCap = pcall(UGCBackpackSystemV2.GetWarehouseCellCapacity, self)
                Cap = OkCap and math.floor(tonumber(RetCap) or 0) or 0
            end
            if self._WarehouseInitRetry < 5 and Cap < WarehouseConfig.GetInitialSlots() then
                UGCTimerUtility.CreateLuaTimer(1.0, InitWarehouseLater, false)
            end
        end
        UGCTimerUtility.CreateLuaTimer(1.0, InitWarehouseLater, false)
        -- 开局发放铜镐（迁自 Mine_03，延后等 Pawn/背包就绪）
        -- 初始装备发放（条件轮询，等待背包系统就绪）
        local function TryGiveStarterKit(PC, Attempt)
            if not UGCObjectUtility.IsObjectValid(PC) then return end
            local ok, cnt = pcall(UGCBackpackSystemV2.GetItemCountV2, PC, GOLD_ITEM_ID)
            if not ok then
                if Attempt < 15 then
                    UGCTimerUtility.CreateLuaTimer(2.0, function()
                        if UGCObjectUtility.IsObjectValid(PC) then
                            TryGiveStarterKit(PC, Attempt + 1)
                        end
                    end, false)
                else
                    ugcprint("[初始装备] 背包系统超时未就绪，放弃发放")
                end
                return
            end
            if cnt < 1000 then
                UGCBackpackSystemV2.AddItemV2(PC, GOLD_ITEM_ID, 1000 - cnt)
            end
    -- 测试币：独立发放，已有铜镐也补足，避免跳过
    if UGCGamePartSystem and UGCGamePartSystem.VirtualItemManager then
        local ok2 = pcall(function()
            local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
            if VIM then
                local Have = 0
                if VIM.GetItemNum then
                    local OkNum, Num = pcall(VIM.GetItemNum, VIM, TEST_COIN_ITEM_ID, PC)
                    if OkNum and Num then
                        Have = tonumber(Num) or 0
                    end
                end
                if Have < 99999 and VIM.AddVirtualItem then
                    VIM:AddVirtualItem(PC, TEST_COIN_ITEM_ID, 99999 - Have)
                    ugcprint("[初始装备] 测试币补足至 99999（已有 " .. Have .. "）")
                else
                    ugcprint("[初始装备] 测试币已足够：" .. Have)
                end
            end
        end)
        if not ok2 then
            ugcprint("[初始装备] 测试币发放失败（VirtualItemManager 未就绪）")
        end
    end


    -- 测试币独立补发（带重试，确保 VIM 就绪后再给，放在铜镐检查之前确保一定执行）
    local function GiveTestCurrency(Attempt)
        if not UGCObjectUtility.IsObjectValid(self) then return end
        if Attempt > 10 then
            ugcprint("[初始装备] 测试币补发失败（VIM 超时未就绪）")
            return
        end
        if not UGCGamePartSystem or not UGCGamePartSystem.VirtualItemManager then
            UGCTimerUtility.CreateLuaTimer(2.0, function()
                GiveTestCurrency(Attempt + 1)
            end, false)
            return
        end
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        local Have = 0
        if VIM.GetItemNum then
            local OkNum, Num = pcall(VIM.GetItemNum, VIM, TEST_COIN_ITEM_ID, self)
            if OkNum and Num then
                Have = tonumber(Num) or 0
            end
        end
        if Have < 99999 then
            VIM:AddVirtualItem(self, TEST_COIN_ITEM_ID, 99999 - Have)
            ugcprint("[初始装备] 测试币补足至 99999（已有 " .. Have .. "）")
        else
            ugcprint("[初始装备] 测试币已足够：" .. Have)
        end
    end
    GiveTestCurrency(1)
    local alreadyOwned = GetItemCount(PC, COPPER_PICKAXE_ITEM_ID)
    if alreadyOwned > 0 then
        ugcprint("[初始装备] 已拥有铜镐，跳过发放")
        return
    end
    UGCBackpackSystemV2.AddItemV2(PC, COPPER_PICKAXE_ITEM_ID, 1)
    ugcprint("[初始装备] 发放完成：金币1000 + 铜镐")
        end
        -- 背包等级恢复：以官方持久容量反推（解决重进恢复一级）
        self.BackpackLevel = GetBackpackLevelFromCapacity(GetBackpackCapacity(self))
        ugcprint("[背包等级] 恢复为 Lv" .. tostring(self.BackpackLevel) .. " 容量=" .. tostring(GetBackpackCapacity(self)))
        local OkMaxCap, MaxCap = pcall(UGCBackpackSystemV2.GetMaxCellCapacity, self)
        ugcprint("[背包] 容量上限=" .. tostring(OkMaxCap and MaxCap) .. "（永久目标 240）")
        TryGiveStarterKit(self, 1)
        self:BindShopV2Gift(1)
        pcall(function()
            self:BindTitleItemListener(1)
            self:InitTitleState(1)
        end)
    end

    -- 商店模板V2：通过 AddToViewport 添加"打开商城"调试按钮
    local function InitShopV2TestButton(PC)
        if not PC then return end

        -- 加载商店模块
        UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage.Script.ShopV2.ShopV2Manager")
        UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage.Script.Common.Common")

        -- 创建并注册主商店 UI
        local MainUIClass = UE.LoadClass(UGCGameSystem.GetUGCResourcesFullPath(
            "ExtendResource/ShopV2/OfficialPackage/Asset/ShopV2/Arts_UI/UIBP/ShopV2_MainUI_UIBP.ShopV2_MainUI_UIBP_C"))
        if MainUIClass and ShopV2Manager then
            local MainUI = UserWidget.NewWidgetObjectBP(PC, MainUIClass)
            if MainUI then
                MainUI:AddToViewport(10050)
                MainUI:SetVisibility(ESlateVisibility.Collapsed)
                ShopV2Manager:RegisterMainUI(MainUI)
            end
        end

        -- 创建打开商城按钮
        local ButtonClass = UE.LoadClass(UGCGameSystem.GetUGCResourcesFullPath(
            "ExtendResource/ShopV2/OfficialPackage/Asset/ShopV2/Blueprint/ShopV2_OpenShopButton_UIBP.ShopV2_OpenShopButton_UIBP_C"))
        if ButtonClass then
            local Button = UserWidget.NewWidgetObjectBP(PC, ButtonClass)
            if Button then
                Button:AddToViewport(1000)
                PC.ShopV2TestButton = Button
                print("[ShopV2] 按钮已添加")
            end
        end
    end

    local function InitLocalJoystick()
        if self.bLocalJoystickInit then
            return
        end
        if not IsLocalPC(self) then
            return
        end
        self.bLocalJoystickInit = true

        GMP.GlobalMessage.BindUObject(self, "InputAction.StartFire", self, self.OnStartFire)

        local WidgetPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/Blueprint/BP_RightJoystick.BP_RightJoystick_C")
        if not self.RightJoyStickWidget then
            UGCWidgetManagerSystem.CreateWidgetAsync(WidgetPath, function(Widget)
                if Widget and not self.RightJoyStickWidget then
                    self.RightJoyStickWidget = Widget
                    UGCWidgetManagerSystem.AddToSlot(Widget, "UI.UISlot.MainUISlot_High")
                end
            end)
        end

        -- 商店模板V2：通过 AddToViewport 添加"打开商城"调试按钮
        InitShopV2TestButton(self)
    end

    -- 注意：进场不要创建鉴定 UI，否则会卡死
    if not UGCGameSystem.IsServer() then
        InitLocalJoystick()
    else
        UGCTimerUtility.CreateLuaTimer(0.3, function()
            if UGCObjectUtility.IsObjectValid(self) then
                InitLocalJoystick()
            end
        end, false)
    end

    -- 悬浮按钮（使用 WBP_RechargeFloatingBtn）
    if not UGCGameSystem.IsServer() then
        UGCTimerUtility.CreateLuaTimer(1.0, function()
            if not UGCObjectUtility.IsObjectValid(self) then return end
            local widgetPath = UGCGameSystem.GetUGCResourcesFullPath("Asset/Blueprint/Prefabs/UI/WBP_RechargeFloatingBtn.WBP_RechargeFloatingBtn_C")
            if not widgetPath or widgetPath == "" then
                ugcprint("[Recharge] WBP_RechargeFloatingBtn path not found")
                return
            end
            UGCWidgetManagerSystem.CreateWidgetAsync(widgetPath, function(Widget)
                if Widget and UGCObjectUtility.IsObjectValid(self) then
                    self.RechargeFloatingBtn = Widget
                    UGCWidgetManagerSystem.AddToSlot(Widget, "UI.UISlot.MainUISlot_High")
                    ugcprint("[Recharge] FloatingBtn created")
                end
            end)
        end, false)
    end
end
--- 开局发放铜镐（Mine_03 逻辑；ItemID = 8310026）
function UGCPlayerController:GiveInitialCopperPickaxe()
    if not UGCGameSystem.IsServer() then
        return
    end
    if not UGCObjectUtility.IsObjectValid(self) then
        return
    end

    local function ScheduleRetry(DelaySec)
        self._InitialPickaxeRetry = math.floor(tonumber(self._InitialPickaxeRetry) or 0) + 1
        if self._InitialPickaxeRetry > INITIAL_PICKAXE_MAX_RETRY then
            ugcprint("[初始装备] 发放铜镐重试次数已达上限，放弃")
            return
        end
        UGCTimerUtility.CreateLuaTimer(DelaySec, function()
            if UGCObjectUtility.IsObjectValid(self) then
                self:GiveInitialCopperPickaxe()
            end
        end, false)
    end

    local PlayerPawn = nil
    if UGCGameSystem.GetPlayerPawnByPlayerController then
        local Ok, P = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, self)
        if Ok then
            PlayerPawn = P
        end
    end
    if PlayerPawn == nil and UGCGameSystem.GetPlayerPawn then
        local Ok, P = pcall(UGCGameSystem.GetPlayerPawn, self)
        if Ok then
            PlayerPawn = P
        end
    end
    if PlayerPawn == nil then
        ugcprint("[初始装备] 获取 PlayerPawn 失败，稍后重试")
        ScheduleRetry(INITIAL_PICKAXE_RETRY_SEC)
        return
    end

    -- 背包 API 与本工程其它逻辑一致：以 PlayerController 为 Owner
    local CurrentCount = GetItemCount(self, COPPER_PICKAXE_ITEM_ID)
    ugcprint("[初始装备] 当前铜镐数量=" .. tostring(CurrentCount))

    if CurrentCount <= 0 then
        local OkAdd = pcall(function()
            UGCBackpackSystemV2.AddItemV2(self, COPPER_PICKAXE_ITEM_ID, 1)
        end)
        local NewCount = GetItemCount(self, COPPER_PICKAXE_ITEM_ID)
        if OkAdd and NewCount > 0 then
            ugcprint("[初始装备] 已发放铜镐到背包")
            UGCTimerUtility.CreateLuaTimer(INITIAL_PICKAXE_EQUIP_DELAY_SEC, function()
                if UGCObjectUtility.IsObjectValid(self) then
                    self:EquipCopperPickaxe()
                end
            end, false)
        else
            ugcprint("[初始装备] 添加铜镐失败，稍后重试")
            ScheduleRetry(5.0)
        end
        return
    end

    ugcprint("[初始装备] 铜镐已存在，尝试装备")
    self:EquipCopperPickaxe()
end

function UGCPlayerController:EquipCopperPickaxe()
    if not UGCGameSystem.IsServer() then
        return
    end
    if not UGCObjectUtility.IsObjectValid(self) then
        return
    end
    if not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetItemDefineIDsByIDV2 then
        ugcprint("[初始装备] 背包 API 不可用，跳过装备")
        return
    end

    local function ResolvePawn()
        local Pawn = nil
        if UGCGameSystem.GetPlayerPawnByPlayerController then
            local Ok, P = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, self)
            if Ok then
                Pawn = P
            end
        end
        if Pawn == nil and UGCGameSystem.GetPlayerPawn then
            local Ok, P = pcall(UGCGameSystem.GetPlayerPawn, self)
            if Ok then
                Pawn = P
            end
        end
        return Pawn
    end

    local Ok, DefineIDs = pcall(UGCBackpackSystemV2.GetItemDefineIDsByIDV2, self, COPPER_PICKAXE_ITEM_ID)
    if not Ok or DefineIDs == nil or #DefineIDs <= 0 then
        ugcprint("[初始装备] 未找到铜镐实例，无法装备")
        return
    end

    local FirstDefineID = DefineIDs[1]
    local Equipped = false

    -- 优先装到近战槽（Mine_03），失败再回退任意槽
    if UGCBackpackSystemV2.EquipItemV2 then
        local OkMelee = pcall(UGCBackpackSystemV2.EquipItemV2, self, MELEE_SLOT_NAME, FirstDefineID)
        if OkMelee then
            Equipped = true
            ugcprint("[初始装备] 已装备铜镐到近战槽")
        end
    end
    if not Equipped and UGCBackpackSystemV2.EquipItemToAnySlotV2 then
        local OkAny = pcall(UGCBackpackSystemV2.EquipItemToAnySlotV2, self, FirstDefineID)
        if OkAny then
            Equipped = true
            ugcprint("[初始装备] 已装备铜镐到任意可用槽")
        end
    end
    if not Equipped then
        ugcprint("[初始装备] 装备铜镐失败")
        return
    end

    -- 延迟切到手持近战（Mine_03 SwitchWeaponBySlot）
    UGCTimerUtility.CreateLuaTimer(INITIAL_PICKAXE_SWITCH_DELAY_SEC, function()
        if not UGCObjectUtility.IsObjectValid(self) then
            return
        end
        local Pawn = ResolvePawn()
        if Pawn == nil then
            ugcprint("[初始装备] 切枪失败：无 PlayerPawn")
            return
        end
        if UGCWeaponManagerSystem == nil or UGCWeaponManagerSystem.SwitchWeaponBySlot == nil then
            ugcprint("[初始装备] SwitchWeaponBySlot 不可用")
            return
        end
        local OkSwitch = pcall(UGCWeaponManagerSystem.SwitchWeaponBySlot, Pawn, MELEE_WEAPON_SLOT, true)
        ugcprint("[初始装备] SwitchWeaponBySlot(4) ok=" .. tostring(OkSwitch))
    end, false)
end

function UGCPlayerController:GetJadeShopStatus()
    return {
        bUnlocked = IsJadeShopUnlocked(self),
        JadeCount = GetJadeCount(self),
        GoldCount = GetGoldCount(self),
        UnlockCost = UNLOCK_COST,
        QuickCost = QUICK_COST,
        LastMsg = self.JadeShopLastMsg or "",
    }
end

function UGCPlayerController:Client_JadeShopNotify(Msg)
    Msg = tostring(Msg or "")
    self.JadeShopLastMsg = Msg
    ugcprint("[Jade] Notify: " .. Msg)
    if self.OnJadeShopNotify then
        pcall(self.OnJadeShopNotify, Msg)
    end
end

local function NotifyJadeManualUIOpened(PC)
    if PC and PC.OnJadeManualUIOpened then
        pcall(PC.OnJadeManualUIOpened)
        PC.OnJadeManualUIOpened = nil
    end
end

--- 仅本机创建面板（由服务端 Begin 成功后 Client_Open 调用）
function UGCPlayerController:OpenJadeAppraisalUI()
    if not IsLocalPC(self) then
        ugcprint("[Jade] 非本地PC，跳过开UI")
        return false
    end

    -- 面板已在：仍通知设施收起提示层，避免连点手动鉴定后提示层残留
    if self.JadeAppraisalWidget then
        ugcprint("[Jade] 面板已存在，通知打开完成")
        NotifyJadeManualUIOpened(self)
        return true
    end

    -- 正在异步创建：保留 OnJadeManualUIOpened，等回调里通知
    if self.bOpeningJadeUI then
        ugcprint("[Jade] 面板正在打开，等待回调通知")
        return false
    end

    self.bOpeningJadeUI = true
    ugcprint("[Jade] 开始打开鉴定面板")

    local Path = UGCGameSystem.GetUGCResourcesFullPath(
        "Asset/Blueprint/Prefabs/UI/WBP_JadeAppraisal.WBP_JadeAppraisal_C"
    )
    UGCWidgetManagerSystem.CreateWidgetAsync(Path, function(Widget)
        self.bOpeningJadeUI = false
        if not Widget then
            ugcprint("[Jade] CreateWidgetAsync 返回空")
            return
        end
        if self.JadeAppraisalWidget then
            -- 丢弃重复实例，仍通知提示层收起
            if Widget.RemoveFromParent then
                pcall(function()
                    Widget:RemoveFromParent()
                end)
            end
            NotifyJadeManualUIOpened(self)
            return
        end
        self.JadeAppraisalWidget = Widget
        UGCWidgetManagerSystem.AddToSlot(Widget, "UI.UISlot.MainUISlot_High")
        if Widget.ApplyScreenLayout then
            Widget:ApplyScreenLayout()
        end
        ugcprint("[Jade] 鉴定面板已挂载")
        NotifyJadeManualUIOpened(self)
    end)
    return true
end

function UGCPlayerController:Client_OpenJadeAppraisal()
    ugcprint("[Jade] Client_OpenJadeAppraisal")
    -- 每次 Begin 都是新会话：先拆掉旧面板，避免 UI 重置而服务端仍沿用旧价值
    if self.JadeAppraisalWidget then
        if self.JadeAppraisalWidget.RemoveFromParent then
            pcall(function()
                self.JadeAppraisalWidget:RemoveFromParent()
            end)
        end
        self.JadeAppraisalWidget = nil
    end
    self.bOpeningJadeUI = false
    self:OpenJadeAppraisalUI()
end

function UGCPlayerController:Client_CloseJadeAppraisal()
    if self.JadeAppraisalWidget then
        if self.JadeAppraisalWidget.RemoveFromParent then
            self.JadeAppraisalWidget:RemoveFromParent()
        end
        self.JadeAppraisalWidget = nil
    end
    self.bOpeningJadeUI = false
end

--- 服务端开启手动鉴定会话（权威价值从这里开始记账）
function UGCPlayerController:Server_BeginManualAppraisal()
    ugcprint("[Jade] Server_BeginManualAppraisal unlocked="
        .. tostring(IsJadeShopUnlocked(self))
        .. " jade=" .. tostring(GetJadeCount(self)))
    if not IsJadeShopUnlocked(self) then
        InvokeClient(
            self, "Client_JadeShopNotify",
            "请先解锁玉石鉴定所（" .. tostring(UNLOCK_COST) .. " 金币）"
        )
        return
    end
    if GetJadeCount(self) < 1 then
        InvokeClient(self, "Client_JadeShopNotify", "背包中没有未鉴定玉石")
        return
    end
    if not RemoveOneJade(self) then
        InvokeClient(self, "Client_JadeShopNotify", "Jade consume failed")
        return
    end
    -- 每次进入手动鉴定都重建会话，与客户端新面板（BASE_VALUE / 空格）对齐
    self.JadeManualSession = {
        Active = true,
        CurrentValue = JADE_BASE_VALUE,
        Opened = {},
        Consumed = true,
    }
    ugcprint("[Jade] 手动鉴定会话已创建 value=" .. tostring(JADE_BASE_VALUE))
    -- 关键：ListenServer 主机必须直调，否则鉴定 UI 不会出现
    InvokeClient(self, "Client_OpenJadeAppraisal")
end

--- 服务端翻格：随机等级并回传权威价值
function UGCPlayerController:Server_RevealJadeCell(Index)
    Index = math.floor(tonumber(Index) or -1)
    if Index < 0 or Index >= JADE_CELL_COUNT then
        return
    end
    local Session = GetManualSession(self)
    if not Session then
        InvokeClient(self, "Client_JadeShopNotify", "鉴定会话无效，请重新进入")
        return
    end
    if Session.Opened[Index] ~= nil then
        return
    end
    local Level = math.random(1, 5)
    Session.Opened[Index] = Level
    Session.CurrentValue = ApplyLevelToValue(Session.CurrentValue, Level)
    local ValueInt = math.floor(Session.CurrentValue + 0.5)
    if ValueInt < 0 then
        ValueInt = 0
    end
    ugcprint(string.format("[Jade] Reveal cell=%d level=%d value=%d", Index, Level, ValueInt))
    self:Server_UpdateJadeTitleTask(ValueInt)
    InvokeClient(self, "Client_JadeCellRevealed", Index, Level, ValueInt)
end

function UGCPlayerController:Client_JadeCellRevealed(Index, Level, NewValue)
    Index = math.floor(tonumber(Index) or -1)
    Level = math.floor(tonumber(Level) or 0)
    NewValue = math.floor(tonumber(NewValue) or 0)
    local Widget = self.JadeAppraisalWidget
    if Widget and Widget.ApplyServerReveal then
        pcall(function()
            Widget:ApplyServerReveal(Index, Level, NewValue)
        end)
    end
end

--- 出售：只用服务端会话价值，忽略客户端金额
function UGCPlayerController:Server_SellAppraisedJade()
    local Session = GetManualSession(self)
    if not Session then
        InvokeClient(self, "Client_JadeShopNotify", "出售失败：无鉴定会话")
        InvokeClient(self, "Client_CloseJadeAppraisal")
        return
    end
    local SellValue = math.floor((Session.CurrentValue or 0) + 0.5)
    if SellValue < 0 then
        SellValue = 0
    end
    if Session.Consumed ~= true then
        if not RemoveOneJade(self) then
            ClearManualSession(self)
            InvokeClient(self, "Client_JadeShopNotify", "出售失败：没有玉石")
            InvokeClient(self, "Client_CloseJadeAppraisal")
            return
        end
    end
    if SellValue > 0 then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, SellValue)
    end
    self.JadeCollectionCandidate = nil
    ClearManualSession(self)
    ugcprint("[Jade] 出售结算 value=" .. tostring(SellValue))
    InvokeClient(self, "Client_JadeShopNotify", "售出成功：获得 " .. tostring(SellValue) .. " 金币")
    InvokeClient(self, "Client_CloseJadeAppraisal")
end

--- 关闭面板不卖：清会话，不扣玉石
--- 取消鉴定返回的物品需策划讨论（若改为开会话时扣玉，关闭时退回哪一 ItemID 待定）
function UGCPlayerController:Server_CancelManualAppraisal()
    SaveJadeCollectionCandidateFromSession(self, GetManualSession(self))
    ClearManualSession(self)
    InvokeClient(self, "Client_JadeCollectionNotify", "Jade appraisal record saved for collection")
    SyncJadeCollectionToClient(self)
    ugcprint("[Jade] 手动鉴定会话已取消")
    InvokeClient(self, "Client_CloseJadeAppraisal")
end

--- 解锁鉴定所（15000）
function UGCPlayerController:Server_UnlockJadeShop()
    if IsJadeShopUnlocked(self) then
        InvokeClient(self, "Client_JadeShopNotify", "鉴定所已解锁")
        InvokeClient(self, "Client_JadeShopUnlocked")
        return
    end
    if not TryRemoveGold(self, UNLOCK_COST) then
        InvokeClient(
            self, "Client_JadeShopNotify",
            "金币不足，解锁需要 " .. tostring(UNLOCK_COST)
        )
        return
    end
    self.bJadeShopUnlocked = true
    ugcprint("[Jade] 鉴定所已解锁")
    InvokeClient(self, "Client_JadeShopUnlocked")
    InvokeClient(self, "Client_JadeShopNotify", "解锁成功！可进行鉴定")
end

function UGCPlayerController:Client_JadeShopUnlocked()
    self.bJadeShopUnlocked = true
    ugcprint("[Jade] Client 同步：已解锁")
    if self.OnJadeShopUnlocked then
        pcall(self.OnJadeShopUnlocked)
    end
end

--- 快速鉴定：花 3000，随机 0～10000
function UGCPlayerController:Server_QuickAppraiseJade()
    if not IsJadeShopUnlocked(self) then
        InvokeClient(
            self, "Client_JadeShopNotify",
            "请先解锁玉石鉴定所（" .. tostring(UNLOCK_COST) .. " 金币）"
        )
        return
    end
    -- 手动鉴定进行中禁止快速鉴定，避免扣走会话对应的玉石
    if GetManualSession(self) then
        InvokeClient(self, "Client_JadeShopNotify", "请先结束当前手动鉴定（出售或关闭）")
        return
    end
    if GetJadeCount(self) < 1 then
        InvokeClient(self, "Client_JadeShopNotify", "背包中没有未鉴定玉石")
        return
    end
    if GetGoldCount(self) < QUICK_COST then
        InvokeClient(
            self, "Client_JadeShopNotify",
            "金币不足，快速鉴定需要 " .. tostring(QUICK_COST)
        )
        return
    end
    if not TryRemoveGold(self, QUICK_COST) then
        InvokeClient(self, "Client_JadeShopNotify", "扣费失败")
        return
    end
    if not RemoveOneJade(self) then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, QUICK_COST)
        InvokeClient(self, "Client_JadeShopNotify", "没有玉石，已退回费用")
        return
    end
    local Roll = math.random(0, 10000)
    self:Server_UpdateJadeTitleTask(Roll)
    if Roll > 0 then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, Roll)
    end
    ugcprint("[Jade] 快速鉴定结果=" .. tostring(Roll))
    InvokeClient(self, "Client_JadeQuickResult", Roll)
end

function UGCPlayerController:Client_JadeQuickResult(Roll)
    Roll = math.floor(tonumber(Roll) or 0)
    local Msg = "快速鉴定完成：获得 " .. tostring(Roll) .. " 金币"
    self:Client_JadeShopNotify(Msg)
    if self.OnJadeQuickResult then
        pcall(self.OnJadeQuickResult, Roll)
    end
end

function UGCPlayerController:RequestUnlockJadeShop()
    InvokeServer(self, "Server_UnlockJadeShop")
end

function UGCPlayerController:RequestQuickAppraiseJade()
    InvokeServer(self, "Server_QuickAppraiseJade")
end

function UGCPlayerController:RequestBeginManualAppraisal()
    InvokeServer(self, "Server_BeginManualAppraisal")
end

function UGCPlayerController:RequestRevealJadeCell(Index)
    InvokeServer(self, "Server_RevealJadeCell", Index)
end

function UGCPlayerController:RequestSellAppraisedJade()
    InvokeServer(self, "Server_SellAppraisedJade")
end

function UGCPlayerController:RequestCancelManualAppraisal()
    InvokeServer(self, "Server_CancelManualAppraisal")
end

--- ========== 玉石收藏室 ==========

function UGCPlayerController:GetJadeCollectionStatus(SelectedSlot)
    local Slot = ClampJadeCollectionSlot(SelectedSlot)
    local Displays = self.ClientJadeCollectionDisplays
    if UGCGameSystem.IsServer() then
        Displays = EnsureJadeCollectionDisplays(self)
    elseif type(Displays) ~= "table" then
        Displays = {}
    end
    Displays = CopyJadeCollectionDisplays(Displays)

    local CurrentDisplay = Displays[Slot] or CreateJadeCollectionDisplay(
        JadeCollectionConfig.StateEmpty, 0, "", 0, GetJadeCollectionTotalCells()
    )
    local Candidate = GetJadeCollectionCandidate(self)
    local StateName = "Empty Slot"
    if JadeCollectionConfig and JadeCollectionConfig.GetStateName then
        StateName = JadeCollectionConfig.GetStateName(
            CurrentDisplay.State,
            CurrentDisplay.OpenedCount,
            CurrentDisplay.TotalCells
        )
    end

    return {
        bUnlocked = true,
        SlotCount = GetJadeCollectionSlotCount(),
        SelectedSlot = Slot,
        Displays = Displays,
        CurrentDisplay = CurrentDisplay,
        CurrentStateName = StateName,
        RawJadeCount = GetJadeCount(self),
        JadeCount = GetJadeCount(self),
        bHasCandidate = Candidate ~= nil,
        CandidateValue = Candidate and Candidate.Value or 0,
        CandidateOpenedCount = Candidate and Candidate.OpenedCount or 0,
        CandidateTotalCells = Candidate and Candidate.TotalCells or GetJadeCollectionTotalCells(),
        OwnerName = GetJadeOwnerName(self),
        LastMsg = self.JadeCollectionLastMsg or "",
    }
end

function UGCPlayerController:Client_JadeCollectionNotify(Msg)
    Msg = tostring(Msg or "")
    self.JadeCollectionLastMsg = Msg
    ugcprint("[JadeCollection] Notify: " .. Msg)
    if self.OnJadeCollectionNotify then
        pcall(self.OnJadeCollectionNotify, Msg)
    end
end

function UGCPlayerController:Client_JadeCollectionSync(
    SlotCount, EncodedDisplays, HasCandidate, CandidateValue, CandidateOpenedCount, CandidateTotalCells)
    SlotCount = math.max(1, math.floor(tonumber(SlotCount) or GetJadeCollectionSlotCount()))
    self.ClientJadeCollectionSlotCount = SlotCount
    self.ClientJadeCollectionDisplays = DecodeJadeCollectionDisplays(EncodedDisplays)
    if math.floor(tonumber(HasCandidate) or 0) > 0 then
        self.ClientJadeCollectionCandidate = {
            Value = math.max(0, math.floor(tonumber(CandidateValue) or 0)),
            OpenedCount = math.max(0, math.floor(tonumber(CandidateOpenedCount) or 0)),
            TotalCells = math.max(1, math.floor(tonumber(CandidateTotalCells) or GetJadeCollectionTotalCells())),
        }
    else
        self.ClientJadeCollectionCandidate = nil
    end
    if self.OnJadeCollectionSync then
        pcall(self.OnJadeCollectionSync)
    end
end

function UGCPlayerController:Server_RequestJadeCollectionSync()
    SyncJadeCollectionToClient(self)
end

function UGCPlayerController:Server_PlaceRawJadeInCollection(Slot)
    Slot = ClampJadeCollectionSlot(Slot)
    local Displays = EnsureJadeCollectionDisplays(self)
    local Existing = Displays[Slot]
    if Existing and math.floor(tonumber(Existing.State) or 0) ~= JadeCollectionConfig.StateEmpty then
        InvokeClient(self, "Client_JadeCollectionNotify", "Collection slot occupied")
        SyncJadeCollectionToClient(self)
        return
    end
    if GetJadeCount(self) < 1 or not RemoveOneJade(self) then
        InvokeClient(self, "Client_JadeCollectionNotify", "No jade in backpack")
        SyncJadeCollectionToClient(self)
        return
    end
    Displays[Slot] = CreateJadeCollectionDisplay(
        JadeCollectionConfig.StateRaw,
        GetJadeCollectionBaseValue(),
        GetJadeOwnerName(self),
        0,
        GetJadeCollectionTotalCells()
    )
    self.JadeCollectionLastMsg = "Raw jade placed"
    SyncJadeCollectionToClient(self)
    InvokeClient(self, "Client_JadeCollectionNotify", self.JadeCollectionLastMsg)
end

function UGCPlayerController:Server_PlaceManualJadeInCollection(Slot)
    Slot = ClampJadeCollectionSlot(Slot)
    local Displays = EnsureJadeCollectionDisplays(self)
    local Existing = Displays[Slot]
    if Existing and math.floor(tonumber(Existing.State) or 0) ~= JadeCollectionConfig.StateEmpty then
        InvokeClient(self, "Client_JadeCollectionNotify", "Collection slot occupied")
        SyncJadeCollectionToClient(self)
        return
    end
    local Candidate = GetJadeCollectionCandidate(self)
    if Candidate == nil then
        InvokeClient(self, "Client_JadeCollectionNotify", "No appraisal record to display")
        SyncJadeCollectionToClient(self)
        return
    end
    Displays[Slot] = CreateJadeCollectionDisplay(
        JadeCollectionConfig.StateAppraised,
        Candidate.Value,
        GetJadeOwnerName(self),
        Candidate.OpenedCount,
        Candidate.TotalCells
    )
    if Candidate.bFromActiveSession then
        ClearManualSession(self)
        InvokeClient(self, "Client_CloseJadeAppraisal")
    end
    self.JadeCollectionCandidate = nil
    self.JadeCollectionLastMsg = "Appraised jade placed"
    SyncJadeCollectionToClient(self)
    InvokeClient(self, "Client_JadeCollectionNotify", self.JadeCollectionLastMsg)
end

function UGCPlayerController:Server_ClearJadeCollectionSlot(Slot)
    Slot = ClampJadeCollectionSlot(Slot)
    local Displays = EnsureJadeCollectionDisplays(self)
    local Existing = Displays[Slot]
    local State = Existing and math.floor(tonumber(Existing.State) or 0) or JadeCollectionConfig.StateEmpty
    if Existing == nil or State == JadeCollectionConfig.StateEmpty then
        InvokeClient(self, "Client_JadeCollectionNotify", "Collection slot is empty")
        SyncJadeCollectionToClient(self)
        return
    end
    local Msg = "玉石已取回"
    if State == JadeCollectionConfig.StateAppraised then
        local SellValue = math.max(0, math.floor(tonumber(Existing.Value) or 0))
        if SellValue > 0 then
            local Ok = pcall(function()
                UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, SellValue)
            end)
            if not Ok then
                InvokeClient(self, "Client_JadeCollectionNotify", "出售失败，请重试")
                SyncJadeCollectionToClient(self)
                return
            end
        end
        Msg = "鉴定玉石已出售：+" .. tostring(SellValue) .. " 金币"
    else
        local Ok = pcall(function()
            UGCBackpackSystemV2.AddItemV2(self, JADE_ITEM_ID, 1)
        end)
        if not Ok then
            InvokeClient(self, "Client_JadeCollectionNotify", "取回失败，请重试")
            SyncJadeCollectionToClient(self)
            return
        end
        Msg = "玉石原石已取回"
    end
    Displays[Slot] = CreateJadeCollectionDisplay(
        JadeCollectionConfig.StateEmpty,
        0,
        "",
        0,
        GetJadeCollectionTotalCells()
    )
    self.JadeCollectionLastMsg = Msg
    SyncJadeCollectionToClient(self)
    InvokeClient(self, "Client_JadeCollectionNotify", self.JadeCollectionLastMsg)
end

function UGCPlayerController:RequestSyncJadeCollection()
    InvokeServer(self, "Server_RequestJadeCollectionSync")
end

function UGCPlayerController:RequestPlaceRawJadeInCollection(Slot)
    InvokeServer(self, "Server_PlaceRawJadeInCollection", Slot)
end

function UGCPlayerController:RequestPlaceManualJadeInCollection(Slot)
    InvokeServer(self, "Server_PlaceManualJadeInCollection", Slot)
end

function UGCPlayerController:RequestClearJadeCollectionSlot(Slot)
    InvokeServer(self, "Server_ClearJadeCollectionSlot", Slot)
end

--- ========== 矿区传送大厅 ==========

function UGCPlayerController:GetMineTeleportStatus()
    return {
        bUnlocked = IsMineTeleportUnlocked(self),
        GoldCount = GetGoldCount(self),
        UnlockCost = MINE_TELEPORT_UNLOCK_COST,
        TeleportCost = MINE_TELEPORT_COST,
        ReturnCost = 0,
        LastMsg = self.MineTeleportLastMsg or "",
    }
end

function UGCPlayerController:Client_MineTeleportNotify(Msg)
    Msg = tostring(Msg or "")
    self.MineTeleportLastMsg = Msg
    ugcprint("[MineTeleport] Notify: " .. Msg)
    if self.OnMineTeleportNotify then
        pcall(self.OnMineTeleportNotify, Msg)
    end
end

function UGCPlayerController:Server_UnlockMineTeleport()
    if IsMineTeleportUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportNotify", "传送大厅已解锁")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportUnlocked")
        return
    end
    if not TryRemoveGold(self, MINE_TELEPORT_UNLOCK_COST) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_MineTeleportNotify",
            "金币不足，解锁需要 " .. tostring(MINE_TELEPORT_UNLOCK_COST)
        )
        return
    end
    self.bMineTeleportUnlocked = true
    ugcprint("[MineTeleport] 传送大厅已解锁")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportUnlocked")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportNotify", "解锁成功！可传送至各矿区")
end

function UGCPlayerController:Client_MineTeleportUnlocked()
    self.bMineTeleportUnlocked = true
    ugcprint("[MineTeleport] Client 同步：已解锁")
    if self.OnMineTeleportUnlocked then
        pcall(self.OnMineTeleportUnlocked)
    end
end

function UGCPlayerController:Server_TeleportToMineZone(ZoneId)
    ZoneId = math.floor(tonumber(ZoneId) or 0)
    ugcprint(string.format("[MineTeleport] ? 收到传送请求: ZoneId=%d", ZoneId))
    local Zone = MineTeleportConfig.GetZone(ZoneId)
    if Zone == nil then
        ugcprint("[MineTeleport] ❌ 无效矿区 ID: " .. tostring(ZoneId))
        UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportNotify", "无效矿区")
        return
    end
    if not IsMineTeleportUnlocked(self) then
        ugcprint("[MineTeleport] ❌ 传送大厅未解锁")
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_MineTeleportNotify",
            "请先解锁传送大厅（" .. tostring(MINE_TELEPORT_UNLOCK_COST) .. " 金币）"
        )
        return
    end
    if not self.bTeleportVIP then
        if GetGoldCount(self) < MINE_TELEPORT_COST then
            UnrealNetwork.CallUnrealRPC(
                self, self, "Client_MineTeleportNotify",
                "金币不足，传送需要 " .. tostring(MINE_TELEPORT_COST)
            )
            return
        end
        if not TryRemoveGold(self, MINE_TELEPORT_COST) then
            UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportNotify", "扣费失败")
            return
        end
    end
    ugcprint(string.format("[MineTeleport] ⚡ 传送至 %s (%.0f,%.0f,%.0f)",
        Zone.Name, Zone.PadX, Zone.PadY, Zone.PadZ))

    -- 优先通过客户端 RPC 执行传送（listen-server 下客户端拥有移动权限）
    ugcprint("[MineTeleport] ? 发送 Client_ExecuteTeleport RPC")
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_ExecuteTeleport",
        Zone.PadX, Zone.PadY, Zone.PadZ
    )

    -- 同时在服务端也尝试传送（双保险）
    local Ok = TeleportPawnTo(self, Zone.PadX, Zone.PadY, Zone.PadZ)
    ugcprint(string.format("[MineTeleport] TeleportPawnTo 返回: %s", tostring(Ok)))

    ugcprint(string.format("[MineTeleport] ✅ 传送流程完成至 %s", Zone.Name))
    UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleported", ZoneId)
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_MineTeleportNotify",
        "已传送至「" .. tostring(Zone.Name) .. "」"
    )
end

function UGCPlayerController:Client_MineTeleported(ZoneId)
    ZoneId = math.floor(ZoneId or 0)
    ugcprint(string.format("[MineTeleport] 客户端收到传送完成: ZoneId=%d", ZoneId))
    if self.OnMineTeleported then
        pcall(self.OnMineTeleported, ZoneId)
    end
end

function UGCPlayerController:Client_ExecuteTeleport(X, Y, Z)
    X = tonumber(X) or 0
    Y = tonumber(Y) or 0
    Z = tonumber(Z) or 0
    ugcprint(string.format("[Teleport-Client] ? 客户端执行传送 (%.0f,%.0f,%.0f)", X, Y, Z))

    local Pawn = nil
    if self.GetPlayerCharacterSafety then
        local Ok, P = pcall(function() return self:GetPlayerCharacterSafety() end)
        if Ok then Pawn = P end
    end
    if Pawn == nil and self.K2_GetPawn then
        local Ok, P = pcall(function() return self:K2_GetPawn() end)
        if Ok then Pawn = P end
    end
    if Pawn == nil then
        ugcprint("[Teleport-Client] ❌ 客户端找不到 Pawn")
        return
    end

    local Loc = Vector.New(X, Y, Z)
    ugcprint(string.format("[Teleport-Client] Pawn=%s, Loc=%s", tostring(Pawn), tostring(Loc)))

    if Pawn.K2_TeleportTo then
        ugcprint("[Teleport-Client] 尝试 K2_TeleportTo(2参数)")
        local Ok, Err = pcall(function()
            Pawn:K2_TeleportTo(Loc, Pawn:K2_GetActorRotation())
        end)
        ugcprint(string.format("[Teleport-Client] K2_TeleportTo: Ok=%s, Err=%s", tostring(Ok), tostring(Err)))
        if Ok then
            local curLoc = Pawn:K2_GetActorLocation()
            if curLoc and math.abs(curLoc.X - X) < 100 then
                ugcprint("[Teleport-Client] ✅ 客户端传送成功")
                return
            end
        end
    end

    if Pawn.K2_SetActorLocation then
        ugcprint("[Teleport-Client] 尝试 K2_SetActorLocation")
        local Ok, Err = pcall(function()
            Pawn:K2_SetActorLocation(Loc, false, nil)
        end)
        ugcprint(string.format("[Teleport-Client] K2_SetActorLocation: Ok=%s, Err=%s", tostring(Ok), tostring(Err)))
        if Ok then
            local curLoc = Pawn:K2_GetActorLocation()
            if curLoc and math.abs(curLoc.X - X) < 100 then
                ugcprint("[Teleport-Client] ✅ 客户端传送成功(方案2)")
                return
            end
        end
    end

    ugcprint("[Teleport-Client] ❌ 客户端传送失败")
end

function UGCPlayerController:RequestUnlockMineTeleport()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UnlockMineTeleport")
end

function UGCPlayerController:RequestTeleportToMineZone(ZoneId)
    ugcprint(string.format("[MineTeleport] ? 发送RPC请求: Server_TeleportToMineZone(%d)", ZoneId))
    UnrealNetwork.CallUnrealRPC(self, self, "Server_TeleportToMineZone", ZoneId)
end

function UGCPlayerController:RequestReturnToSpawn()
    ugcprint("[MineTeleport] ? 发送RPC请求: Server_ReturnToSpawn")
    UnrealNetwork.CallUnrealRPC(self, self, "Server_ReturnToSpawn")
end

function UGCPlayerController:Server_ReturnToSpawn()
    ugcprint("[MineTeleport] ? 收到返回出生点请求")

    if not IsMineTeleportUnlocked(self) then
        ugcprint("[MineTeleport] ❌ 传送大厅未解锁，无法返回出生点")
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_MineTeleportNotify",
            "请先解锁传送大厅"
        )
        return
    end

    local spawnPoint = MineTeleportConfig.GetSpawnPoint()
    local sx = spawnPoint and spawnPoint.X or 0
    local sy = spawnPoint and spawnPoint.Y or 0
    local sz = spawnPoint and spawnPoint.Z or 220

    ugcprint(string.format("[MineTeleport] ? 返回出生点 (%.0f,%.0f,%.0f) - 免费", sx, sy, sz))

    -- 客户端 RPC 执行传送
    ugcprint("[MineTeleport] ? 发送 Client_ExecuteTeleport RPC")
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_ExecuteTeleport", sx, sy, sz
    )

    -- 服务端也尝试传送
    local Ok = TeleportPawnTo(self, sx, sy, sz)
    ugcprint(string.format("[MineTeleport] TeleportPawnTo 返回: %s", tostring(Ok)))

    ugcprint("[MineTeleport] ✅ 返回出生点完成")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_MineReturnedToSpawn")
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_MineTeleportNotify",
        "已返回出生点"
    )
end

function UGCPlayerController:Client_MineReturnedToSpawn()
    ugcprint("[MineTeleport] 客户端收到返回出生点完成")
    if self.OnMineReturnedToSpawn then
        pcall(self.OnMineReturnedToSpawn)
    end
end

--- ========== 矿石加工厂 / 冶炼 ==========

local SMELT_STATE_IDLE = 0
local SMELT_STATE_RUNNING = 1
local SMELT_STATE_READY = 2

local function NowSec()
    local T = nil
    if UGCGameSystem and UGCGameSystem.GetServerTimeSec then
        local Ok, ServerTime = pcall(UGCGameSystem.GetServerTimeSec)
        if Ok then
            T = ServerTime
        end
    end
    if T == nil then
        T = os.time()
    end
    return tonumber(T) or 0
end

local function LocalClockSec()
    local Ok, T = pcall(os.time)
    if Ok then
        return tonumber(T) or 0
    end
    return 0
end

local function GetOasisTicket()
    if UGCCommoditySystem == nil or UGCCommoditySystem.GetTicket == nil then
        return 0
    end
    local Ok, Ticket = pcall(UGCCommoditySystem.GetTicket)
    if Ok then
        return math.floor(tonumber(Ticket) or 0)
    end
    return 0
end

local function FormatSmeltOasisR(Cost)
    local N = math.floor(tonumber(Cost) or 0)
    if N <= 0 then
        return "0r"
    end
    if N % 10 == 0 then
        return tostring(math.floor(N / 10)) .. "r"
    end
    return tostring(N) .. "绿洲币"
end

local function EnsureSmeltSessions(PC)
    if PC.SmeltSessions == nil then
        PC.SmeltSessions = {}
    end
end

local function GetSmeltSlot(PC, Slot)
    EnsureSmeltSessions(PC)
    local S = PC.SmeltSessions[Slot]
    if S == nil then
        S = {
            State = SMELT_STATE_IDLE,
            InputId = 0,
            Count = 0,
            EndTime = 0,
            OutputId = 0,
        }
        PC.SmeltSessions[Slot] = S
    end
    return S
end

local function RefreshSmeltSlotState(SlotData, NowOverride)
    if SlotData == nil then
        return
    end
    if SlotData.State == SMELT_STATE_RUNNING then
        local EndTime = tonumber(SlotData.EndTime) or 0
        local CurTime = tonumber(NowOverride) or NowSec()
        if EndTime > 0 and CurTime >= EndTime then
            SlotData.State = SMELT_STATE_READY
        end
    end
end

local function EstimateSmeltServerNow(PC)
    if UGCGameSystem.IsServer() then
        return NowSec()
    end
    local ServerBase = tonumber(PC and PC.SmeltServerNow) or 0
    local LocalBase = tonumber(PC and PC.SmeltLocalSyncSec) or 0
    if ServerBase > 0 and LocalBase > 0 then
        local Elapsed = math.max(0, LocalClockSec() - LocalBase)
        return ServerBase + Elapsed
    end
    return nil
end

local function IsSmelterUnlocked(PC)
    return PC ~= nil and PC.bSmelterUnlocked == true
end

local function SyncSmeltSlotToClient(PC, Slot)
    local Data = GetSmeltSlot(PC, Slot)
    local ServerNow = NowSec()
    RefreshSmeltSlotState(Data, ServerNow)
    UnrealNetwork.CallUnrealRPC(
        PC, PC, "Client_SmeltSlotSync",
        Slot,
        Data.State or SMELT_STATE_IDLE,
        Data.InputId or 0,
        Data.Count or 0,
        Data.EndTime or 0,
        Data.OutputId or 0,
        ServerNow
    )
end

local function SyncAllSmeltSlots(PC)
    local Count = math.floor(tonumber(PC.UnlockedFurnaceCount) or 0)
    for Slot = 1, math.max(Count, 1) do
        SyncSmeltSlotToClient(PC, Slot)
    end
end

local function TryRemoveItems(PC, ItemId, Amount)
    Amount = math.floor(tonumber(Amount) or 0)
    ItemId = math.floor(tonumber(ItemId) or 0)
    if Amount <= 0 or ItemId <= 0 then
        return true
    end
    if GetItemCount(PC, ItemId) < Amount then
        return false
    end
    local Ok = pcall(function()
        UGCBackpackSystemV2.RemoveItemV2(PC, ItemId, Amount)
    end)
    return Ok and true or false
end

local function TryAddItems(PC, ItemId, Amount)
    Amount = math.floor(tonumber(Amount) or 0)
    ItemId = math.floor(tonumber(ItemId) or 0)
    if Amount <= 0 or ItemId <= 0 then
        return true
    end
    local Ok = pcall(function()
        UGCBackpackSystemV2.AddItemV2(PC, ItemId, Amount)
    end)
    return Ok and true or false
end

local function GetBackpackDefineIDsByItemId(PC, ItemId)
    ItemId = math.floor(tonumber(ItemId) or 0)
    if PC == nil or ItemId <= 0 or UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.GetItemDefineIDsByIDV2 == nil then
        return {}
    end
    local Ok, DefineIDs = pcall(UGCBackpackSystemV2.GetItemDefineIDsByIDV2, PC, ItemId)
    if Ok and DefineIDs ~= nil then
        return DefineIDs
    end
    return {}
end

local function GetDefineIDListCount(DefineIDs)
    if DefineIDs == nil then
        return 0
    end
    local Ok, Count = pcall(function()
        return #DefineIDs
    end)
    if Ok then
        return math.floor(tonumber(Count) or 0)
    end
    return 0
end

local function GetBackpackCountByDefineID(PC, DefineID)
    if PC == nil or DefineID == nil or UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.GetItemCountByDefineIDV2 == nil then
        return 0
    end
    local Ok, Count = pcall(UGCBackpackSystemV2.GetItemCountByDefineIDV2, PC, DefineID)
    if Ok then
        return math.floor(tonumber(Count) or 0)
    end
    return 0
end

local function GetWarehouseItemCountSafe(PC, ItemId)
    ItemId = math.floor(tonumber(ItemId) or 0)
    if PC == nil or ItemId <= 0 or UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.GetWarehouseItemCount == nil then
        return 0
    end
    local Ok, Count = pcall(UGCBackpackSystemV2.GetWarehouseItemCount, PC, ItemId)
    if Ok then
        return math.floor(tonumber(Count) or 0)
    end
    return 0
end

local function GetWarehouseCapacitySafe(PC)
    if PC == nil or UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.GetWarehouseCellCapacity == nil then
        return 0
    end
    local Ok, Cap = pcall(UGCBackpackSystemV2.GetWarehouseCellCapacity, PC)
    if Ok then
        return math.floor(tonumber(Cap) or 0)
    end
    return 0
end

local function EnsureInitialWarehouseCapacityForReward(PC)
    if PC == nil or UGCBackpackSystemV2 == nil then
        return
    end
    if UGCBackpackSystemV2.GetWarehouseCellCapacity == nil or UGCBackpackSystemV2.AddWarehouseCellCapacity == nil then
        return
    end
    local Initial = 50
    if WarehouseConfig ~= nil and WarehouseConfig.GetInitialSlots ~= nil then
        Initial = WarehouseConfig.GetInitialSlots()
    end
    local Cap = GetWarehouseCapacitySafe(PC)
    if Cap < Initial then
        pcall(UGCBackpackSystemV2.AddWarehouseCellCapacity, PC, Initial - Cap)
    end
end

local function TryMoveBackpackItemToWarehouse(PC, ItemId, Amount)
    Amount = math.floor(tonumber(Amount) or 0)
    ItemId = math.floor(tonumber(ItemId) or 0)
    if Amount <= 0 or ItemId <= 0 then
        return 0
    end
    if UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.PutInWarehouse == nil then
        return 0
    end

    EnsureInitialWarehouseCapacityForReward(PC)

    local Before = GetWarehouseItemCountSafe(PC, ItemId)
    local Remain = Amount
    local DefineIDs = GetBackpackDefineIDsByItemId(PC, ItemId)
    local MovedTotal = 0
    for Index = 1, GetDefineIDListCount(DefineIDs) do
        if Remain <= 0 then
            break
        end
        local DefineID = DefineIDs[Index]
        local StackCount = GetBackpackCountByDefineID(PC, DefineID)
        if StackCount > 0 then
            local MoveCount = math.min(StackCount, Remain)
            local Ok, Ret = pcall(UGCBackpackSystemV2.PutInWarehouse, PC, DefineID, MoveCount)
            if Ok and Ret ~= false then
                MovedTotal = MovedTotal + MoveCount
                Remain = math.max(0, Remain - MoveCount)
            end
            local After = GetWarehouseItemCountSafe(PC, ItemId)
            local MovedNow = math.max(0, After - Before)
            if MovedNow > MovedTotal then
                MovedTotal = math.min(Amount, MovedNow)
                Remain = math.max(0, Amount - MovedTotal)
            end
            if MovedTotal >= Amount then
                return Amount
            end
        end
    end
    return math.max(0, math.min(Amount, MovedTotal))
end

local function TryAddItemsToWarehouseViaBackpack(PC, ItemId, Amount)
    Amount = math.floor(tonumber(Amount) or 0)
    ItemId = math.floor(tonumber(ItemId) or 0)
    if Amount <= 0 or ItemId <= 0 then
        return true, 0, 0
    end
    EnsureInitialWarehouseCapacityForReward(PC)
    if GetWarehouseCapacitySafe(PC) <= 0 then
        ugcprint("[TalentMarket] 仓库容量未初始化，停止发放 ItemId=" .. tostring(ItemId) .. " Amount=" .. tostring(Amount))
        return true, 0, 0
    end
    local ExistingCount = GetItemCount(PC, ItemId)
    if ExistingCount > 0 then
        TryMoveBackpackItemToWarehouse(PC, ItemId, ExistingCount)
    end
    local TotalAdded = 0
    local TotalMoved = 0
    local Guard = 0
    while TotalAdded < Amount and Guard < Amount + 8 do
        Guard = Guard + 1
        local RequestCount = Amount - TotalAdded
        local Ok, AddedCount = pcall(function()
            return UGCBackpackSystemV2.AddItemV2(PC, ItemId, RequestCount)
        end)
        if not Ok then
            return false, TotalMoved, TotalAdded
        end
        AddedCount = math.floor(tonumber(AddedCount) or 0)
        if AddedCount <= 0 then
            break
        end
        TotalAdded = TotalAdded + AddedCount
        local Moved = TryMoveBackpackItemToWarehouse(PC, ItemId, AddedCount)
        TotalMoved = TotalMoved + Moved
        if Moved < AddedCount then
            break
        end
    end
    return true, TotalMoved, TotalAdded
end

function UGCPlayerController:Client_SmeltNotify(Msg)
    Msg = tostring(Msg or "")
    self.SmeltLastMsg = Msg
    ugcprint("[Smelt] Notify: " .. Msg)
    if self.OnSmeltNotify then
        pcall(self.OnSmeltNotify, Msg)
    end
end

function UGCPlayerController:Client_SmelterUnlocked()
    self.bSmelterUnlocked = true
    if self.UnlockedFurnaceCount == nil or self.UnlockedFurnaceCount < 1 then
        self.UnlockedFurnaceCount = 1
    end
    if self.OnSmelterUnlocked then
        pcall(self.OnSmelterUnlocked)
    end
end

function UGCPlayerController:Client_SmelterPlantLevel(Level)
    self.SmelterPlantLevel = math.floor(tonumber(Level) or 1)
    if self.OnSmelterStateChanged then
        pcall(self.OnSmelterStateChanged)
    end
end

function UGCPlayerController:Client_FurnaceCount(Count)
    self.UnlockedFurnaceCount = math.floor(tonumber(Count) or 0)
    if self.OnSmelterStateChanged then
        pcall(self.OnSmelterStateChanged)
    end
end

function UGCPlayerController:Client_SmeltSlotSync(Slot, State, InputId, Count, EndTime, OutputId, ServerNow)
    Slot = math.floor(tonumber(Slot) or 0)
    if Slot < 1 or Slot > 5 then
        return
    end
    ServerNow = tonumber(ServerNow) or 0
    if ServerNow > 0 then
        self.SmeltServerNow = ServerNow
        self.SmeltLocalSyncSec = LocalClockSec()
    end
    if self.ClientSmeltSlots == nil then
        self.ClientSmeltSlots = {}
    end
    self.ClientSmeltSlots[Slot] = {
        State = math.floor(tonumber(State) or 0),
        InputId = math.floor(tonumber(InputId) or 0),
        Count = math.floor(tonumber(Count) or 0),
        EndTime = math.floor(tonumber(EndTime) or 0),
        OutputId = math.floor(tonumber(OutputId) or 0),
    }
    if self.OnSmelterStateChanged then
        pcall(self.OnSmelterStateChanged)
    end
end

function UGCPlayerController:GetSmeltingStatus()
    local PlantLevel = math.floor(tonumber(self.SmelterPlantLevel) or 1)
    local FurnaceCount = math.floor(tonumber(self.UnlockedFurnaceCount) or 0)
    local Slots = {}
    local Source = self.ClientSmeltSlots
    local bServer = UGCGameSystem.IsServer()
    local StatusNow = EstimateSmeltServerNow(self)
    if bServer then
        EnsureSmeltSessions(self)
        Source = self.SmeltSessions
    end
    for Slot = 1, 5 do
        local Data = Source and Source[Slot] or nil
        if Data then
            if bServer or StatusNow ~= nil then
                RefreshSmeltSlotState(Data, StatusNow)
            end
            Slots[Slot] = {
                State = Data.State or SMELT_STATE_IDLE,
                InputId = Data.InputId or 0,
                Count = Data.Count or 0,
                EndTime = Data.EndTime or 0,
                OutputId = Data.OutputId or 0,
            }
        else
            Slots[Slot] = {
                State = SMELT_STATE_IDLE,
                InputId = 0,
                Count = 0,
                EndTime = 0,
                OutputId = 0,
            }
        end
    end
    return {
        bUnlocked = IsSmelterUnlocked(self),
        PlantLevel = PlantLevel,
        FurnaceCount = FurnaceCount,
        GoldCount = GetGoldCount(self),
        CoalCount = GetItemCount(self, SmeltingConfig.CoalItemId),
        OasisTicket = GetOasisTicket(),
        UnlockCost = SmeltingConfig.PlantUnlockCost,
        UpgradeCost = SmeltingConfig.PlantUpgradeCost,
        SkipOasisCost = SmeltingConfig.SkipOasisCost,
        MaxBatch = SmeltingConfig.MaxBatchCount,
        DurationSec = SmeltingConfig.DurationSec,
        ServerNow = StatusNow or 0,
        Slots = Slots,
        LastMsg = self.SmeltLastMsg or "",
    }
end

function UGCPlayerController:Server_UnlockSmeltingPlant()
    if IsSmelterUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "加工厂已解锁")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmelterUnlocked")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_FurnaceCount", self.UnlockedFurnaceCount or 1)
        return
    end
    local Cost = SmeltingConfig.PlantUnlockCost
    if not TryRemoveGold(self, Cost) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "金币不足，解锁需要 " .. tostring(Cost)
        )
        return
    end
    self.bSmelterUnlocked = true
    self.SmelterPlantLevel = 1
    self.UnlockedFurnaceCount = 1
    EnsureSmeltSessions(self)
    ugcprint("[Smelt] 加工厂已解锁")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_SmelterUnlocked")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_SmelterPlantLevel", 1)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_FurnaceCount", 1)
    SyncAllSmeltSlots(self)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "解锁成功！获得 1 座冶炼炉")
end

function UGCPlayerController:Server_UpgradeSmeltingPlant()
    if not IsSmelterUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "请先解锁加工厂（" .. tostring(SmeltingConfig.PlantUnlockCost) .. " 金币）"
        )
        return
    end
    local Level = math.floor(tonumber(self.SmelterPlantLevel) or 1)
    if Level >= 2 then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "加工厂已是最高级，可精炼全部粗矿")
        return
    end
    local Cost = SmeltingConfig.PlantUpgradeCost
    if not TryRemoveGold(self, Cost) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "金币不足，升级需要 " .. tostring(Cost)
        )
        return
    end
    self.SmelterPlantLevel = 2
    UnrealNetwork.CallUnrealRPC(self, self, "Client_SmelterPlantLevel", 2)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "升级成功！可精炼全部粗制矿物")
end

--- PayType: 0=金币 1=绿洲币
function UGCPlayerController:Server_UnlockFurnace(Slot, PayType)
    Slot = math.floor(tonumber(Slot) or 0)
    PayType = math.floor(tonumber(PayType) or 0)
    if not IsSmelterUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "请先解锁加工厂")
        return
    end
    local Cur = math.floor(tonumber(self.UnlockedFurnaceCount) or 0)
    if Slot ~= Cur + 1 then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "请按顺序解锁下一座炉（当前已解锁 " .. tostring(Cur) .. "）"
        )
        return
    end
    if Slot < 2 or Slot > 5 then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "无效炉号")
        return
    end
    local Cost = SmeltingConfig.GetFurnaceCost(Slot)
    if Cost == nil then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "无此炉位配置")
        return
    end

    if PayType == 0 then
        local GoldCost = Cost.Gold
        if GoldCost == nil then
            UnrealNetwork.CallUnrealRPC(
                self, self, "Client_SmeltNotify",
                "第5座冶炼炉仅可用 " .. FormatSmeltOasisR(Cost.Oasis or 100) .. " 解锁"
            )
            return
        end
        if not TryRemoveGold(self, GoldCost) then
            UnrealNetwork.CallUnrealRPC(
                self, self, "Client_SmeltNotify",
                "金币不足，需要 " .. tostring(GoldCost) .. "（也可用 " .. FormatSmeltOasisR(Cost.Oasis or 100) .. "）"
            )
            return
        end
    else
        local OasisCost = tonumber(Cost.Oasis) or 100
        if not self:_ConsumeOasisOrReject(OasisCost, "解锁冶炼炉") then
            return
        end
    end

    self.UnlockedFurnaceCount = Slot
    GetSmeltSlot(self, Slot)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_FurnaceCount", Slot)
    SyncSmeltSlotToClient(self, Slot)
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_SmeltNotify",
        "已解锁第 " .. tostring(Slot) .. " 座冶炼炉"
    )
end

--- 返回 true=已扣费或软通过；false=已 Notify 失败
function UGCPlayerController:_ConsumeOasisOrReject(Cost, Reason)
    Cost = math.floor(tonumber(Cost) or 0)
    Reason = tostring(Reason or "操作")
    if Cost <= 0 then
        return true
    end
    local HasAPI = (UGCCommoditySystem ~= nil and UGCCommoditySystem.GetTicket ~= nil)
    local Ticket = GetOasisTicket()
    if HasAPI and Ticket < Cost then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "绿洲币不足，" .. Reason .. "需要 " .. FormatSmeltOasisR(Cost) .. "（当前 " .. tostring(Ticket) .. "绿洲币）"
        )
        return false
    end
    if not SmeltingConfig.AllowSoftOasisSpend then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "请在 SmeltingConfig.OasisProductIds 配置绿洲币商品后购买（" .. Reason .. " " .. FormatSmeltOasisR(Cost) .. "）"
        )
        return false
    end
    -- 软扣费：未接商城商品时仅校验余额（API 不可用则放行联调），正式上线请配 ProductId + BuyUGCCommodity2
    ugcprint("[Smelt] SoftOasisSpend cost=" .. tostring(Cost) .. " reason=" .. Reason .. " ticket=" .. tostring(Ticket) .. " hasAPI=" .. tostring(HasAPI))
    return true
end

function UGCPlayerController:Server_StartSmelt(Slot, ItemId, Count)
    Slot = math.floor(tonumber(Slot) or 0)
    ItemId = math.floor(tonumber(ItemId) or 0)
    Count = math.floor(tonumber(Count) or 0)
    if not IsSmelterUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "请先解锁加工厂")
        return
    end
    local FurnaceCount = math.floor(tonumber(self.UnlockedFurnaceCount) or 0)
    if Slot < 1 or Slot > FurnaceCount then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "冶炼炉未解锁")
        return
    end
    if Count < 1 or Count > SmeltingConfig.MaxBatchCount then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "一次最多精炼 " .. tostring(SmeltingConfig.MaxBatchCount) .. " 个"
        )
        return
    end
    local PlantLevel = math.floor(tonumber(self.SmelterPlantLevel) or 1)
    local Recipe = SmeltingConfig.GetRecipe(ItemId)
    if Recipe == nil then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "该矿物不可精炼")
        return
    end
    if not SmeltingConfig.CanRefine(ItemId, PlantLevel) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "当前工厂等级仅可精炼二级矿物，请先升级（" .. tostring(SmeltingConfig.PlantUpgradeCost) .. "）"
        )
        return
    end
    local SlotData = GetSmeltSlot(self, Slot)
    RefreshSmeltSlotState(SlotData)
    if SlotData.State == SMELT_STATE_RUNNING then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "该炉正在精炼中")
        return
    end
    if SlotData.State == SMELT_STATE_READY then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "请先收取完成的精炼产物")
        return
    end

    local CoalId = SmeltingConfig.CoalItemId
    if GetItemCount(self, ItemId) < Count then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "粗矿数量不足")
        return
    end
    if not self.bInfiniteFuel then
        if GetItemCount(self, CoalId) < Count then
            UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "煤矿不足（1 粗矿需 1 煤矿）")
            return
        end
    end
    if not TryRemoveItems(self, ItemId, Count) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "扣除粗矿失败")
        return
    end
    if not self.bInfiniteFuel then
        if not TryRemoveItems(self, CoalId, Count) then
            TryAddItems(self, ItemId, Count)
            UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "扣除煤矿失败，已退回粗矿")
            return
        end
    end

    SlotData.State = SMELT_STATE_RUNNING
    SlotData.InputId = ItemId
    SlotData.Count = Count
    SlotData.OutputId = Recipe.OutputId
    SlotData.EndTime = NowSec() + math.floor(tonumber(SmeltingConfig.DurationSec) or 600)
    SyncSmeltSlotToClient(self, Slot)
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_SmeltNotify",
        string.format(
            "开始精炼 %s x%d（约 %d 分钟）",
            tostring(Recipe.Name or ItemId),
            Count,
            math.floor((SmeltingConfig.DurationSec or 600) / 60)
        )
    )
end

function UGCPlayerController:Server_SkipSmelt(Slot)
    Slot = math.floor(tonumber(Slot) or 0)
    if not IsSmelterUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "请先解锁加工厂")
        return
    end
    local FurnaceCount = math.floor(tonumber(self.UnlockedFurnaceCount) or 0)
    if Slot < 1 or Slot > FurnaceCount then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "冶炼炉未解锁")
        return
    end
    local SlotData = GetSmeltSlot(self, Slot)
    RefreshSmeltSlotState(SlotData)
    if SlotData.State ~= SMELT_STATE_RUNNING then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "当前没有进行中的精炼")
        return
    end
    local Cost = SmeltingConfig.SkipOasisCost or 50
    if not self:_ConsumeOasisOrReject(Cost, "跳过精炼") then
        return
    end
    SlotData.State = SMELT_STATE_READY
    SlotData.EndTime = NowSec()
    SyncSmeltSlotToClient(self, Slot)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "已跳过等待，可收取产物")
end

function UGCPlayerController:Server_CollectSmelt(Slot)
    Slot = math.floor(tonumber(Slot) or 0)
    if not IsSmelterUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "请先解锁加工厂")
        return
    end
    local FurnaceCount = math.floor(tonumber(self.UnlockedFurnaceCount) or 0)
    if Slot < 1 or Slot > FurnaceCount then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "冶炼炉未解锁")
        return
    end
    local SlotData = GetSmeltSlot(self, Slot)
    RefreshSmeltSlotState(SlotData)
    if SlotData.State == SMELT_STATE_RUNNING then
        SyncSmeltSlotToClient(self, Slot)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "精炼尚未完成")
        return
    end
    if SlotData.State ~= SMELT_STATE_READY then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "没有可收取的产物")
        return
    end
    local OutputId = math.floor(tonumber(SlotData.OutputId) or 0)
    local Count = math.floor(tonumber(SlotData.Count) or 0)
    if OutputId <= 0 or Count <= 0 then
        SlotData.State = SMELT_STATE_IDLE
        SlotData.InputId = 0
        SlotData.Count = 0
        SlotData.EndTime = 0
        SlotData.OutputId = 0
        SyncSmeltSlotToClient(self, Slot)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "产物数据异常，已清空炉位")
        return
    end
    if not TryAddItems(self, OutputId, Count) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "发放产物失败，请稍后重试")
        return
    end
    local Recipe = SmeltingConfig.GetRecipe(SlotData.InputId)
    local OutName = (Recipe and Recipe.OutputName) or tostring(OutputId)
    SlotData.State = SMELT_STATE_IDLE
    SlotData.InputId = 0
    SlotData.Count = 0
    SlotData.EndTime = 0
    SlotData.OutputId = 0
    SyncSmeltSlotToClient(self, Slot)
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_SmeltNotify",
        "收取成功：" .. tostring(OutName) .. " x" .. tostring(Count)
    )
end

function UGCPlayerController:RequestUnlockSmeltingPlant()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UnlockSmeltingPlant")
end

function UGCPlayerController:RequestUpgradeSmeltingPlant()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UpgradeSmeltingPlant")
end

function UGCPlayerController:RequestUnlockFurnace(Slot, PayType)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UnlockFurnace", Slot, PayType)
end

function UGCPlayerController:RequestStartSmelt(Slot, ItemId, Count)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_StartSmelt", Slot, ItemId, Count)
end

function UGCPlayerController:RequestSkipSmelt(Slot)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_SkipSmelt", Slot)
end

function UGCPlayerController:RequestCollectSmelt(Slot)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_CollectSmelt", Slot)
end

--- ========== 人才市场 ==========

local TALENT_JOB_IDLE = 0
local TALENT_JOB_RUNNING = 1
local TALENT_JOB_READY = 2

local function IsTalentMarketUnlocked(PC)
    return PC ~= nil and PC.bTalentMarketUnlocked == true
end

local function EnsureTalentJob(PC)
    if PC.TalentJob == nil then
        PC.TalentJob = {
            State = TALENT_JOB_IDLE,
            WorkerId = 0,
            EndTime = 0,
            Rewards = nil,
        }
    end
    return PC.TalentJob
end

local function RefreshTalentJobState(Job)
    if Job == nil then
        return
    end
    if Job.State == TALENT_JOB_RUNNING and NowSec() >= (tonumber(Job.EndTime) or 0) then
        Job.State = TALENT_JOB_READY
    end
end

local function GetTalentRewardTotal(Rewards)
    local Total = 0
    if type(Rewards) == "table" then
        for _, Count in pairs(Rewards) do
            Total = Total + math.floor(tonumber(Count) or 0)
        end
    end
    return Total
end

local function GetTalentRewardItemName(ItemId)
    ItemId = math.floor(tonumber(ItemId) or 0)
    for _, Ore in ipairs(TalentMarketConfig.OrePool or {}) do
        if math.floor(tonumber(Ore.ItemId) or 0) == ItemId then
            return tostring(Ore.Name or ItemId)
        end
    end
    return tostring(ItemId)
end

local function BuildTalentRewardEntries(Rewards)
    local Entries = {}
    if type(Rewards) ~= "table" then
        return Entries
    end

    local Seen = {}
    for _, Ore in ipairs(TalentMarketConfig.OrePool or {}) do
        local ItemId = math.floor(tonumber(Ore.ItemId) or 0)
        local Count = math.floor(tonumber(Rewards[ItemId] or Rewards[tostring(ItemId)]) or 0)
        if ItemId > 0 and Count > 0 then
            Entries[#Entries + 1] = {
                ItemId = ItemId,
                Count = Count,
                Name = tostring(Ore.Name or ItemId),
            }
            Seen[ItemId] = true
        end
    end

    local ExtraEntries = {}
    for RawItemId, RawCount in pairs(Rewards) do
        local ItemId = math.floor(tonumber(RawItemId) or 0)
        local Count = math.floor(tonumber(RawCount) or 0)
        if ItemId > 0 and Count > 0 and not Seen[ItemId] then
            ExtraEntries[#ExtraEntries + 1] = {
                ItemId = ItemId,
                Count = Count,
                Name = GetTalentRewardItemName(ItemId),
            }
        end
    end
    table.sort(ExtraEntries, function(A, B)
        return (A.ItemId or 0) < (B.ItemId or 0)
    end)
    for _, Entry in ipairs(ExtraEntries) do
        Entries[#Entries + 1] = Entry
    end

    return Entries
end

local function FormatTalentRewardEntries(Entries)
    if type(Entries) ~= "table" or #Entries <= 0 then
        return "无"
    end
    local Names = {}
    for _, Entry in ipairs(Entries) do
        local Count = math.floor(tonumber(Entry.Count) or 0)
        if Count > 0 then
            Names[#Names + 1] = tostring(Entry.Name or GetTalentRewardItemName(Entry.ItemId)) .. " x" .. tostring(Count)
        end
    end
    if #Names <= 0 then
        return "无"
    end
    return table.concat(Names, "、")
end

local function TryAddTalentRewardToBackpack(PC, ItemId, Amount)
    ItemId = math.floor(tonumber(ItemId) or 0)
    Amount = math.floor(tonumber(Amount) or 0)
    if ItemId <= 0 or Amount <= 0 then
        return true, 0
    end
    if PC == nil or UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.AddItemV2 == nil then
        return false, 0
    end

    local Ok, AddedCount = pcall(UGCBackpackSystemV2.AddItemV2, PC, ItemId, Amount)
    if not Ok then
        ugcprint("[TalentMarket] AddItemV2 failed ItemId=" .. tostring(ItemId) .. " Amount=" .. tostring(Amount))
        return false, 0
    end

    AddedCount = math.floor(tonumber(AddedCount) or 0)
    AddedCount = math.max(0, math.min(Amount, AddedCount))
    return true, AddedCount
end

local function SyncTalentJobToClient(PC)
    local Job = EnsureTalentJob(PC)
    RefreshTalentJobState(Job)
    local Summary = FormatTalentRewardEntries(BuildTalentRewardEntries(Job.Rewards or {}))
    local RemainingSec = math.max(0, math.floor((tonumber(Job.EndTime) or 0) - NowSec()))
    InvokeClient(
        PC, "Client_TalentJobSync",
        Job.State or TALENT_JOB_IDLE,
        Job.WorkerId or 0,
        Job.EndTime or 0,
        GetTalentRewardTotal(Job.Rewards),
        Summary,
        RemainingSec
    )
end

function UGCPlayerController:GetTalentMarketStatus(WorkerId)
    local Job = EnsureTalentJob(self)
    local bClientJob = false
    if not UGCGameSystem.IsServer() and type(self.ClientTalentJob) == "table" then
        Job = self.ClientTalentJob
        bClientJob = true
    end
    local RemainingSec = 0
    if bClientJob then
        local SyncRemaining = tonumber(Job.SyncRemainingSec)
        local SyncLocalTime = tonumber(Job.SyncLocalTimeSec)
        if SyncRemaining ~= nil and SyncLocalTime ~= nil and SyncLocalTime > 0 then
            local Elapsed = math.max(0, LocalClockSec() - SyncLocalTime)
            RemainingSec = math.max(0, math.floor(SyncRemaining - Elapsed))
        else
            RemainingSec = math.max(0, math.floor((tonumber(Job.EndTime) or 0) - NowSec()))
        end
        if Job.State == TALENT_JOB_RUNNING and RemainingSec <= 0 then
            Job.State = TALENT_JOB_READY
        end
    else
        RefreshTalentJobState(Job)
        RemainingSec = math.max(0, math.floor((tonumber(Job.EndTime) or 0) - NowSec()))
    end
    WorkerId = math.floor(tonumber(WorkerId) or 0)
    if TalentMarketConfig.GetWorker(WorkerId) == nil then
        WorkerId = TalentMarketConfig.GetFirstWorkerId()
    end
    local Worker = TalentMarketConfig.GetWorker(WorkerId) or {}
    return {
        bUnlocked = IsTalentMarketUnlocked(self),
        UnlockCost = TalentMarketConfig.UnlockCost or 5000,
        GoldCount = GetGoldCount(self),
        WorkerId = WorkerId,
        WorkerName = Worker.Name or "?",
        HireCost = Worker.HireCost or 0,
        DurationSec = Worker.DurationSec or 0,
        DurationText = TalentMarketConfig.FormatDuration(Worker.DurationSec or 0),
        RewardCount = Worker.RewardCount or 0,
        MinMineLevel = Worker.MinMineLevel or 1,
        MaxMineLevel = Worker.MaxMineLevel or 1,
        JobState = Job.State or TALENT_JOB_IDLE,
        JobWorkerId = Job.WorkerId or 0,
        JobWorkerName = (TalentMarketConfig.GetWorker(Job.WorkerId or 0) or {}).Name or "",
        EndTime = Job.EndTime or 0,
        RemainingSec = RemainingSec,
        RewardTotal = math.floor(tonumber(Job.RewardTotal) or GetTalentRewardTotal(Job.Rewards)),
        RewardSummary = tostring(Job.RewardSummary or TalentMarketConfig.FormatRewards(Job.Rewards or {})),
        LastMsg = self.TalentMarketLastMsg or "",
    }
end

function UGCPlayerController:Client_TalentMarketNotify(Msg)
    Msg = tostring(Msg or "")
    self.TalentMarketLastMsg = Msg
    ugcprint("[TalentMarket] Notify: " .. Msg)
    if self.OnTalentMarketNotify then
        pcall(self.OnTalentMarketNotify, Msg)
    end
end

function UGCPlayerController:Client_TalentMarketUnlocked()
    self.bTalentMarketUnlocked = true
    if self.OnTalentMarketUnlocked then
        pcall(self.OnTalentMarketUnlocked)
    end
end

function UGCPlayerController:Client_TalentJobSync(State, WorkerId, EndTime, RewardTotal, RewardSummary, RemainingSec)
    local SyncRemaining = tonumber(RemainingSec)
    if SyncRemaining == nil then
        SyncRemaining = math.max(0, math.floor((tonumber(EndTime) or 0) - NowSec()))
    end
    self.ClientTalentJob = {
        State = math.floor(tonumber(State) or TALENT_JOB_IDLE),
        WorkerId = math.floor(tonumber(WorkerId) or 0),
        EndTime = math.floor(tonumber(EndTime) or 0),
        RewardTotal = math.floor(tonumber(RewardTotal) or 0),
        RewardSummary = tostring(RewardSummary or ""),
        SyncRemainingSec = math.max(0, math.floor(SyncRemaining)),
        SyncLocalTimeSec = LocalClockSec(),
    }
    if self.OnTalentJobChanged then
        pcall(self.OnTalentJobChanged)
    end
end

function UGCPlayerController:Server_UnlockTalentMarket()
    if not UGCGameSystem.IsServer() then
        return
    end
    if IsTalentMarketUnlocked(self) then
        InvokeClient(self, "Client_TalentMarketUnlocked")
        InvokeClient(self, "Client_TalentMarketNotify", "人才市场已解锁")
        return
    end
    local Cost = math.floor(tonumber(TalentMarketConfig.UnlockCost) or 5000)
    if not TryRemoveGold(self, Cost) then
        InvokeClient(self, "Client_TalentMarketNotify", "金币不足，解锁需要 " .. tostring(Cost))
        return
    end
    self.bTalentMarketUnlocked = true
    ugcprint("[TalentMarket] 人才市场已解锁")
    InvokeClient(self, "Client_TalentMarketUnlocked")
    InvokeClient(self, "Client_TalentMarketNotify", "解锁成功！可以雇佣矿工")
end

function UGCPlayerController:Server_HireTalentWorker(WorkerId)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not IsTalentMarketUnlocked(self) then
        InvokeClient(
            self, "Client_TalentMarketNotify",
            "请先解锁人才市场（" .. tostring(TalentMarketConfig.UnlockCost or 5000) .. " 金币）"
        )
        return
    end
    WorkerId = math.floor(tonumber(WorkerId) or 0)
    local Worker = TalentMarketConfig.GetWorker(WorkerId)
    if Worker == nil then
        InvokeClient(self, "Client_TalentMarketNotify", "工人类型无效")
        return
    end
    local Job = EnsureTalentJob(self)
    RefreshTalentJobState(Job)
    if Job.State == TALENT_JOB_RUNNING then
        local Remaining = math.max(0, math.floor((tonumber(Job.EndTime) or 0) - NowSec()))
        InvokeClient(self, "Client_TalentMarketNotify", "已有矿工外出中，剩余 " .. TalentMarketConfig.FormatDuration(Remaining))
        SyncTalentJobToClient(self)
        return
    end
    if Job.State == TALENT_JOB_READY then
        InvokeClient(self, "Client_TalentMarketNotify", "已有矿工完成，请先领取矿物")
        SyncTalentJobToClient(self)
        return
    end
    local Cost = math.floor(tonumber(Worker.HireCost) or 0)
    if not TryRemoveGold(self, Cost) then
        InvokeClient(self, "Client_TalentMarketNotify", "金币不足，雇佣需要 " .. tostring(Cost))
        return
    end
    if not self.bTalentRandomSeeded then
        self.bTalentRandomSeeded = true
        math.randomseed(NowSec() + GetGoldCount(self) + WorkerId)
    end
    local Rewards = TalentMarketConfig.RollRewards(WorkerId)
    if type(Rewards) ~= "table" then
        TryAddItems(self, GOLD_ITEM_ID, Cost)
        InvokeClient(self, "Client_TalentMarketNotify", "矿工奖励池配置错误，已退回费用")
        return
    end
    Job.State = TALENT_JOB_RUNNING
    Job.WorkerId = WorkerId
    Job.EndTime = NowSec() + math.floor(tonumber(Worker.DurationSec) or 0)
    Job.Rewards = Rewards
    local Msg = string.format(
        "已雇佣%s，%s后完成，预计带回%d个矿物",
        tostring(Worker.Name or "?"),
        TalentMarketConfig.FormatDuration(Worker.DurationSec or 0),
        GetTalentRewardTotal(Rewards)
    )
    ugcprint("[TalentMarket] " .. Msg)
    InvokeClient(self, "Client_TalentMarketNotify", Msg)
    SyncTalentJobToClient(self)
end

function UGCPlayerController:Server_CollectTalentJob()
    if not UGCGameSystem.IsServer() then
        return
    end
    local Job = EnsureTalentJob(self)
    RefreshTalentJobState(Job)
    if Job.State == TALENT_JOB_IDLE then
        InvokeClient(self, "Client_TalentMarketNotify", "当前没有外出的矿工")
        return
    end
    if Job.State == TALENT_JOB_RUNNING then
        local Remaining = math.max(0, math.floor((tonumber(Job.EndTime) or 0) - NowSec()))
        InvokeClient(self, "Client_TalentMarketNotify", "矿工还在挖矿，剩余 " .. TalentMarketConfig.FormatDuration(Remaining))
        SyncTalentJobToClient(self)
        return
    end
    local Rewards = Job.Rewards or {}
    local Total = GetTalentRewardTotal(Rewards)
    if Total <= 0 then
        self.TalentJob = nil
        InvokeClient(self, "Client_TalentMarketNotify", "奖励为空，已重置任务")
        SyncTalentJobToClient(self)
        return
    end
    local Entries = BuildTalentRewardEntries(Rewards)
    local DeliveredTotal = 0
    local RemainingRewards = {}
    local bBackpackFull = false
    for _, Entry in ipairs(Entries) do
        local ItemId = math.floor(tonumber(Entry.ItemId) or 0)
        local Count = math.floor(tonumber(Entry.Count) or 0)
        if Count > 0 then
            if bBackpackFull then
                RemainingRewards[ItemId] = (RemainingRewards[ItemId] or 0) + Count
            else
                local Ok, Added = TryAddTalentRewardToBackpack(self, ItemId, Count)
                if not Ok then
                    InvokeClient(self, "Client_TalentMarketNotify", "发放矿物失败，请稍后重试")
                    SyncTalentJobToClient(self)
                    return
                end
                DeliveredTotal = DeliveredTotal + math.floor(tonumber(Added) or 0)
                if Added < Count then
                    RemainingRewards[ItemId] = (RemainingRewards[ItemId] or 0) + (Count - Added)
                    bBackpackFull = true
                end
            end
        end
    end
    local Worker = TalentMarketConfig.GetWorker(Job.WorkerId or 0) or {}
    local Summary = FormatTalentRewardEntries(Entries)
    local RemainingTotal = GetTalentRewardTotal(RemainingRewards)
    if RemainingTotal > 0 then
        Job.Rewards = RemainingRewards
        Job.State = TALENT_JOB_READY
        local RemainingSummary = FormatTalentRewardEntries(BuildTalentRewardEntries(RemainingRewards))
        local Msg = string.format(
            "%s奖励只领取了%d/%d个：%s；背包容量不足，剩余%d个待领取：%s",
            tostring(Worker.Name or "矿工"),
            DeliveredTotal,
            Total,
            Summary,
            RemainingTotal,
            RemainingSummary
        )
        ugcprint("[TalentMarket] " .. Msg)
        InvokeClient(self, "Client_TalentMarketNotify", Msg)
        SyncTalentJobToClient(self)
        return
    end
    self.TalentJob = nil
    local Msg = string.format(
        "%s带回%d个矿物：%s，已放入背包",
        tostring(Worker.Name or "矿工"),
        Total,
        Summary
    )
    ugcprint("[TalentMarket] " .. Msg)
    InvokeClient(self, "Client_TalentMarketNotify", Msg)
    SyncTalentJobToClient(self)
end

function UGCPlayerController:RequestUnlockTalentMarket()
    InvokeServer(self, "Server_UnlockTalentMarket")
end

function UGCPlayerController:RequestHireTalentWorker(WorkerId)
    InvokeServer(self, "Server_HireTalentWorker", WorkerId)
end

function UGCPlayerController:RequestCollectTalentJob()
    InvokeServer(self, "Server_CollectTalentJob")
end

--- ========== 采矿车维修处 ==========

local VEHICLE_STATE_READY = 0
local VEHICLE_STATE_ACTIVE = 1
local VEHICLE_STATE_PENDING_CHECK = 2
local VEHICLE_STATE_BROKEN = 3

local function GetPawnByControllerSafe(PC)
    if PC ~= nil and UGCGameSystem ~= nil and UGCGameSystem.GetPlayerPawnByPlayerController ~= nil then
        local Ok, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, PC)
        if Ok and Pawn ~= nil then
            return Pawn
        end
    end

    if UE_GetPlayerPawn then
        local Ok, Pawn = pcall(UE_GetPlayerPawn)
        if Ok and Pawn ~= nil then
            return Pawn
        end
    end

    if UGCGameSystem ~= nil and UGCGameSystem.GetAllPlayerPawns ~= nil then
        local Ok, Pawns = pcall(UGCGameSystem.GetAllPlayerPawns)
        if Ok and type(Pawns) == "table" then
            for _, Pawn in ipairs(Pawns) do
                if Pawn and Pawn.SetMineCarMode then
                    return Pawn
                end
            end
        end
    end

    return nil
end

local function IsVehicleRepairUnlocked(PC)
    return PC ~= nil and PC.bVehicleRepairUnlocked == true
end

local function EnsureVehicleRepairBrokenMap(PC)
    if PC == nil then
        return {}
    end
    if PC.VehicleRepairBrokenMap == nil then
        PC.VehicleRepairBrokenMap = {}
    end
    return PC.VehicleRepairBrokenMap
end

local function EnsureVehicleRepairStateMap(PC)
    if PC == nil then
        return {}
    end
    if PC.VehicleRepairStateMap == nil then
        PC.VehicleRepairStateMap = {}
    end
    return PC.VehicleRepairStateMap
end

local function GetVehicleStateMapForRead(PC)
    if PC == nil then
        return {}
    end
    if not UGCGameSystem.IsServer() and type(PC.ClientVehicleRepairStateMap) == "table" then
        return PC.ClientVehicleRepairStateMap
    end
    return EnsureVehicleRepairStateMap(PC)
end

local function GetMiningVehicleState(PC, VehicleId)
    local _, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Key <= 0 then
        return VEHICLE_STATE_READY
    end
    local Map = GetVehicleStateMapForRead(PC)
    local State = tonumber(Map[Key])
    if State ~= nil then
        return State
    end
    local BrokenMap = nil
    if PC ~= nil and not UGCGameSystem.IsServer() and type(PC.ClientVehicleRepairBrokenMap) == "table" then
        BrokenMap = PC.ClientVehicleRepairBrokenMap
    else
        BrokenMap = EnsureVehicleRepairBrokenMap(PC)
    end
    return BrokenMap[Key] == true and VEHICLE_STATE_BROKEN or VEHICLE_STATE_READY
end

local function IsMiningVehicleBroken(PC, VehicleId)
    return GetMiningVehicleState(PC, VehicleId) == VEHICLE_STATE_BROKEN
end

local function IsMiningVehiclePendingCheck(PC, VehicleId)
    return GetMiningVehicleState(PC, VehicleId) == VEHICLE_STATE_PENDING_CHECK
end

local function SetMiningVehicleState(PC, VehicleId, State)
    local _, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Key <= 0 then
        return 0
    end
    State = math.floor(tonumber(State) or VEHICLE_STATE_READY)
    EnsureVehicleRepairStateMap(PC)[Key] = State
    EnsureVehicleRepairBrokenMap(PC)[Key] = State == VEHICLE_STATE_BROKEN
    return Key
end

local function SetMiningVehicleBroken(PC, VehicleId, bBroken)
    return SetMiningVehicleState(PC, VehicleId, bBroken == true and VEHICLE_STATE_BROKEN or VEHICLE_STATE_READY)
end

local function SyncVehicleRepairStateToClient(PC, VehicleId)
    local _, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Key <= 0 then
        return
    end
    local State = GetMiningVehicleState(PC, Key)
    InvokeClient(PC, "Client_VehicleRepairState", Key, State == VEHICLE_STATE_BROKEN and 1 or 0, State)
end

local function NotifyVehicleRepair(PC, Msg)
    InvokeClient(PC, "Client_VehicleRepairNotify", Msg)
end

local function ForceStopMineCarMode(PC)
    local Pawn = GetPawnByControllerSafe(PC)
    if Pawn and Pawn.SetMineCarMode then
        Pawn:SetMineCarMode(false)
    end
    InvokeClient(PC, "Client_ForceStopMineCarMode")
end

local function IsPawnMineCarMode(PC)
    local Pawn = GetPawnByControllerSafe(PC)
    if Pawn and Pawn.IsMineCarMode then
        local Ok, bMineCar = pcall(function()
            return Pawn:IsMineCarMode()
        end)
        if Ok and bMineCar == true then
            return true, Pawn
        end
    end
    return false, Pawn
end

local function ApplyMineCarModeForVehicle(PC, Vehicle, bForceRefresh)
    local Pawn = GetPawnByControllerSafe(PC)
    if Pawn and Pawn.SetMineCarMode then
        if bForceRefresh and Pawn.IsMineCarMode then
            local Ok, bMineCar = pcall(function()
                return Pawn:IsMineCarMode()
            end)
            if Ok and bMineCar == true then
                Pawn:SetMineCarMode(false)
            end
        end
        UGCAttributeSystem.SetGameAttributeValue(Pawn, "AxeLevel", math.floor(tonumber(Vehicle.MineLevel) or 0))
        Pawn:SetMineCarMode(true)
        return true
    end
    return false
end

local function ShouldThrottleMineCarBeginTrip(PC, Key)
    if PC == nil or Key == nil then
        return false
    end
    if PC.MineCarBeginTripTimeMap == nil then
        PC.MineCarBeginTripTimeMap = {}
    end
    local Now = nil
    if UGCGameSystem and UGCGameSystem.GetServerTimeSec then
        local Ok, ServerTime = pcall(UGCGameSystem.GetServerTimeSec)
        if Ok and type(ServerTime) == "number" then
            Now = ServerTime
        end
    end
    if Now == nil then
        Now = os.clock()
    end
    local Last = tonumber(PC.MineCarBeginTripTimeMap[Key]) or 0
    PC.MineCarBeginTripTimeMap[Key] = Now
    return Last > 0 and (Now - Last) < 0.25
end

local function EnsureVehicleRepairRandomSeed(PC, VehicleId)
    if PC.bVehicleRepairRandomSeeded then
        return
    end
    PC.bVehicleRepairRandomSeeded = true
    math.randomseed(NowSec() + GetGoldCount(PC) + math.floor(tonumber(VehicleId) or 0) + 37)
end

function UGCPlayerController:Server_BeginMineCarTrip(VehicleId)
    if not UGCGameSystem.IsServer() then
        return
    end
    local Vehicle, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Vehicle == nil then
        NotifyVehicleRepair(self, "采矿车类型无效")
        return
    end
    if GetItemCount(self, Vehicle.ItemId) <= 0 then
        NotifyVehicleRepair(self, "背包中没有" .. tostring(Vehicle.Name or "采矿车"))
        return
    end

    if ShouldThrottleMineCarBeginTrip(self, Key) then
        ugcprint("[MineCarTrip] duplicate begin trip ignored", Key)
        return
    end

    local State = GetMiningVehicleState(self, Key)
    if State == VEHICLE_STATE_BROKEN then
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "已损坏，请回维修处维修后再使用")
        SyncVehicleRepairStateToClient(self, Key)
        ForceStopMineCarMode(self)
        return
    end
    if State == VEHICLE_STATE_PENDING_CHECK then
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "需要返程检查，请回维修处检查后再使用")
        SyncVehicleRepairStateToClient(self, Key)
        ForceStopMineCarMode(self)
        return
    end

    if State == VEHICLE_STATE_ACTIVE then
        self.ActiveMiningVehicleId = Key
        SyncVehicleRepairStateToClient(self, Key)
        ugcprint("[MineCarTrip] active vehicle requested again; refresh mode", Key)
        if ApplyMineCarModeForVehicle(self, Vehicle, true) then
            NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "正在使用中，已恢复车身")
        else
            NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "正在使用中，但恢复车身失败")
        end
        return
    end

    local ActiveId = tonumber(self.ActiveMiningVehicleId) or 0
    if ActiveId > 0 then
        if ActiveId == Key then
            SyncVehicleRepairStateToClient(self, Key)
            if ApplyMineCarModeForVehicle(self, Vehicle, true) then
                NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "正在使用中，已恢复车身")
            else
                NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "正在使用中，但恢复车身失败")
            end
            return
        end

        local bPawnMineCarMode = IsPawnMineCarMode(self)
        if bPawnMineCarMode then
            local ActiveVehicle = VehicleRepairConfig.GetVehicle(ActiveId)
            if ActiveVehicle ~= nil then
                ugcprint("[MineCarTrip] active vehicle mismatch; restoring active vehicle", ActiveId, "request", Key)
                ApplyMineCarModeForVehicle(self, ActiveVehicle, true)
                SyncVehicleRepairStateToClient(self, ActiveId)
            end
            NotifyVehicleRepair(self, "已有采矿车正在使用中，已恢复车身，请先返程")
            return
        end

        SetMiningVehicleState(self, ActiveId, VEHICLE_STATE_PENDING_CHECK)
        SyncVehicleRepairStateToClient(self, ActiveId)
        self.ActiveMiningVehicleId = 0
        ugcprint("[MineCarTrip] stale active vehicle cleared to pending check", ActiveId, "request", Key)
        NotifyVehicleRepair(self, "上一辆采矿车已返程，请到维修处检查")
    end

    self.ActiveMiningVehicleId = Key
    SetMiningVehicleState(self, Key, VEHICLE_STATE_ACTIVE)

    if ApplyMineCarModeForVehicle(self, Vehicle) then
        SyncVehicleRepairStateToClient(self, Key)
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "已出车")
        return
    end

    self.ActiveMiningVehicleId = 0
    SetMiningVehicleState(self, Key, VEHICLE_STATE_READY)
    SyncVehicleRepairStateToClient(self, Key)
    ugcprint("[MineCarTrip] failed to apply mine car mode", Key)
    NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "出车失败，请重新使用")
end

function UGCPlayerController:Server_EndMineCarTrip(VehicleId)
    if not UGCGameSystem.IsServer() then
        return
    end
    local Vehicle, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Vehicle == nil then
        return
    end
    local State = GetMiningVehicleState(self, Key)
    if State ~= VEHICLE_STATE_ACTIVE and (tonumber(self.ActiveMiningVehicleId) or 0) ~= Key then
        return
    end

    local Pawn = GetPawnByControllerSafe(self)
    if Pawn and Pawn.IsMineCarMode and Pawn:IsMineCarMode() and Pawn.SetMineCarMode then
        Pawn:SetMineCarMode(false)
    end

    self.ActiveMiningVehicleId = 0
    SetMiningVehicleState(self, Key, VEHICLE_STATE_PENDING_CHECK)
    SyncVehicleRepairStateToClient(self, Key)
    NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "已返程，请到维修处检查")
end

function UGCPlayerController:GetVehicleRepairStatus(VehicleId)
    local Vehicle, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Vehicle == nil then
        Key = VehicleRepairConfig.GetFirstVehicleId()
        Vehicle = VehicleRepairConfig.GetVehicle(Key)
    end
    Vehicle = Vehicle or {}
    local ItemId = math.floor(tonumber(Vehicle.ItemId) or 0)
    local VehicleState = GetMiningVehicleState(self, Key)
    return {
        bUnlocked = IsVehicleRepairUnlocked(self),
        UnlockCost = VehicleRepairConfig.UnlockCost or 5000,
        RepairCost = VehicleRepairConfig.RepairCost or 1000,
        DamageChance = VehicleRepairConfig.DamageChance or 10,
        GoldCount = GetGoldCount(self),
        VehicleId = Key,
        VehicleItemId = ItemId,
        VehicleName = Vehicle.Name or "?",
        RangeText = Vehicle.RangeText or "",
        MineLevel = Vehicle.MineLevel or 0,
        OwnedCount = GetItemCount(self, ItemId),
        VehicleState = VehicleState,
        bActive = VehicleState == VEHICLE_STATE_ACTIVE,
        bPendingCheck = VehicleState == VEHICLE_STATE_PENDING_CHECK,
        bBroken = VehicleState == VEHICLE_STATE_BROKEN,
        LastMsg = self.VehicleRepairLastMsg or "",
    }
end

function UGCPlayerController:Client_VehicleRepairNotify(Msg)
    Msg = tostring(Msg or "")
    self.VehicleRepairLastMsg = Msg
    ugcprint("[VehicleRepair] Notify: " .. Msg)
    if UGCWidgetManagerSystem and UGCWidgetManagerSystem.ShowTipsUIWithPC then
        pcall(function()
            UGCWidgetManagerSystem.ShowTipsUIWithPC(Msg, self)
        end)
    end
    if self.OnVehicleRepairNotify then
        pcall(self.OnVehicleRepairNotify, Msg)
    end
end

function UGCPlayerController:Client_VehicleRepairUnlocked()
    self.bVehicleRepairUnlocked = true
    if self.OnVehicleRepairUnlocked then
        pcall(self.OnVehicleRepairUnlocked)
    end
end

function UGCPlayerController:Client_VehicleRepairState(VehicleId, bBroken, VehicleState)
    local _, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Key <= 0 then
        return
    end
    if self.ClientVehicleRepairBrokenMap == nil then
        self.ClientVehicleRepairBrokenMap = {}
    end
    if self.ClientVehicleRepairStateMap == nil then
        self.ClientVehicleRepairStateMap = {}
    end
    self.ClientVehicleRepairBrokenMap[Key] = (tonumber(bBroken) or 0) ~= 0
    self.ClientVehicleRepairStateMap[Key] = math.floor(tonumber(VehicleState) or (self.ClientVehicleRepairBrokenMap[Key] and VEHICLE_STATE_BROKEN or VEHICLE_STATE_READY))
    if self.ClientVehicleRepairStateMap[Key] == VEHICLE_STATE_ACTIVE then
        local Pawn = GetPawnByControllerSafe(self)
        if Pawn and Pawn.DoSetMineCarMode then
            Pawn:DoSetMineCarMode(true)
        elseif Pawn then
            Pawn.bIsMineCarMode = true
        end
    elseif self.ClientVehicleRepairStateMap[Key] == VEHICLE_STATE_BROKEN or self.ClientVehicleRepairStateMap[Key] == VEHICLE_STATE_PENDING_CHECK then
        self:Client_ForceStopMineCarMode()
    end
    if self.OnVehicleRepairStateChanged then
        pcall(self.OnVehicleRepairStateChanged, Key)
    end
end

function UGCPlayerController:Client_ForceStopMineCarMode()
    local Pawn = GetPawnByControllerSafe(self)
    if Pawn and Pawn.DoSetMineCarMode then
        Pawn:DoSetMineCarMode(false)
    elseif Pawn and Pawn.SetMineCarMode then
        Pawn:SetMineCarMode(false)
    end
end

function UGCPlayerController:Server_UnlockVehicleRepair()
    if not UGCGameSystem.IsServer() then
        return
    end
    if IsVehicleRepairUnlocked(self) then
        InvokeClient(self, "Client_VehicleRepairUnlocked")
        NotifyVehicleRepair(self, "采矿车维修处已解锁")
        return
    end
    local Cost = math.floor(tonumber(VehicleRepairConfig.UnlockCost) or 5000)
    if not TryRemoveGold(self, Cost) then
        NotifyVehicleRepair(self, "金币不足，解锁需要 " .. tostring(Cost))
        return
    end
    self.bVehicleRepairUnlocked = true
    ugcprint("[VehicleRepair] 采矿车维修处已解锁")
    InvokeClient(self, "Client_VehicleRepairUnlocked")
    NotifyVehicleRepair(self, "解锁成功！采矿车返程后可在这里检修")
end

function UGCPlayerController:Server_CheckVehicleReturn(VehicleId)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not IsVehicleRepairUnlocked(self) then
        NotifyVehicleRepair(self, "请先解锁采矿车维修处（" .. tostring(VehicleRepairConfig.UnlockCost or 5000) .. " 金币）")
        return
    end
    local Vehicle, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Vehicle == nil then
        NotifyVehicleRepair(self, "采矿车类型无效")
        return
    end
    if GetItemCount(self, Vehicle.ItemId) <= 0 then
        NotifyVehicleRepair(self, "背包中没有" .. tostring(Vehicle.Name or "采矿车"))
        return
    end
    local State = GetMiningVehicleState(self, Key)
    if State == VEHICLE_STATE_ACTIVE then
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "正在使用中，请先返程")
        SyncVehicleRepairStateToClient(self, Key)
        return
    end
    if State == VEHICLE_STATE_BROKEN then
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "已损坏，请先维修")
        SyncVehicleRepairStateToClient(self, Key)
        ForceStopMineCarMode(self)
        return
    end
    if State ~= VEHICLE_STATE_PENDING_CHECK then
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "当前不需要返程检查")
        SyncVehicleRepairStateToClient(self, Key)
        return
    end
    EnsureVehicleRepairRandomSeed(self, Key)
    if VehicleRepairConfig.RollDamage() then
        SetMiningVehicleBroken(self, Key, true)
        SyncVehicleRepairStateToClient(self, Key)
        ForceStopMineCarMode(self)
        NotifyVehicleRepair(self, "返程检查：" .. tostring(Vehicle.Name or "采矿车") .. "损坏了，需要维修")
        return
    end
    SetMiningVehicleState(self, Key, VEHICLE_STATE_READY)
    SyncVehicleRepairStateToClient(self, Key)
    NotifyVehicleRepair(self, "返程检查：" .. tostring(Vehicle.Name or "采矿车") .. "状态良好")
end

function UGCPlayerController:Server_RepairMiningVehicle(VehicleId)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not IsVehicleRepairUnlocked(self) then
        NotifyVehicleRepair(self, "请先解锁采矿车维修处")
        return
    end
    local Vehicle, Key = VehicleRepairConfig.GetVehicle(VehicleId)
    if Vehicle == nil then
        NotifyVehicleRepair(self, "采矿车类型无效")
        return
    end
    if GetItemCount(self, Vehicle.ItemId) <= 0 then
        NotifyVehicleRepair(self, "背包中没有" .. tostring(Vehicle.Name or "采矿车"))
        return
    end
    if not IsMiningVehicleBroken(self, Key) then
        NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "无需维修")
        SyncVehicleRepairStateToClient(self, Key)
        return
    end
    local Cost = math.floor(tonumber(VehicleRepairConfig.RepairCost) or 1000)
    if not TryRemoveGold(self, Cost) then
        NotifyVehicleRepair(self, "金币不足，维修需要 " .. tostring(Cost))
        return
    end
    SetMiningVehicleBroken(self, Key, false)
    SyncVehicleRepairStateToClient(self, Key)
    NotifyVehicleRepair(self, tostring(Vehicle.Name or "采矿车") .. "维修完成，消耗 " .. tostring(Cost) .. " 金币")
end

function UGCPlayerController:Server_RepairVehicle(VehicleId)
    self:Server_RepairMiningVehicle(VehicleId)
end

function UGCPlayerController:MarkMiningVehicleReturned(VehicleId)
    if UGCGameSystem.IsServer() then
        self:Server_EndMineCarTrip(VehicleId)
    else
        self:RequestEndMineCarTrip(VehicleId)
    end
end

function UGCPlayerController:RequestBeginMineCarTrip(VehicleId)
    InvokeServer(self, "Server_BeginMineCarTrip", VehicleId)
end

function UGCPlayerController:RequestEndMineCarTrip(VehicleId)
    InvokeServer(self, "Server_EndMineCarTrip", VehicleId)
end

function UGCPlayerController:RequestUnlockVehicleRepair()
    InvokeServer(self, "Server_UnlockVehicleRepair")
end

function UGCPlayerController:RequestCheckVehicleReturn(VehicleId)
    InvokeServer(self, "Server_CheckVehicleReturn", VehicleId)
end

function UGCPlayerController:RequestRepairMiningVehicle(VehicleId)
    InvokeServer(self, "Server_RepairMiningVehicle", VehicleId)
end

function UGCPlayerController:RequestRepairVehicle(VehicleId)
    InvokeServer(self, "Server_RepairVehicle", VehicleId)
end

--- 矿石回收处：初始自动解锁，按策划价格表回收
function UGCPlayerController:GetOreRecycleStatus(ItemId)
    ItemId = math.floor(tonumber(ItemId) or 0)
    local Entry = OreRecycleConfig.GetEntry(ItemId)
    return {
        GoldCount = GetGoldCount(self),
        OwnedCount = GetItemCount(self, ItemId),
        UnitPrice = Entry and Entry.Price or 0,
        ItemName = Entry and Entry.Name or "?",
        LastMsg = self.OreRecycleLastMsg or "",
    }
end

function UGCPlayerController:Client_OreRecycleNotify(Msg)
    Msg = tostring(Msg or "")
    self.OreRecycleLastMsg = Msg
    ugcprint("[OreRecycle] Notify: " .. Msg)
    if self.OnOreRecycleNotify then
        pcall(self.OnOreRecycleNotify, Msg)
    end
end

function UGCPlayerController:Server_RecycleOre(ItemId, Count)
    if not UGCGameSystem.IsServer() then
        return
    end
    ItemId = math.floor(tonumber(ItemId) or 0)
    Count = math.floor(tonumber(Count) or 0)
    local Entry = OreRecycleConfig.GetEntry(ItemId)
    if Entry == nil then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_OreRecycleNotify", "该物品不可回收")
        return
    end
    local Owned = GetItemCount(self, ItemId)
    local SellCount = OreRecycleConfig.ResolveSellCount(Owned, Count)
    if SellCount <= 0 then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_OreRecycleNotify", "库存不足，无法回收")
        return
    end
    local UnitPrice = math.floor(tonumber(Entry.Price) or 0)
    local Gain = SellCount * UnitPrice
    if Gain <= 0 then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_OreRecycleNotify", "回收价格无效")
        return
    end
    if not TryRemoveItems(self, ItemId, SellCount) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_OreRecycleNotify", "扣除矿石失败")
        return
    end
    if not TryAddItems(self, GOLD_ITEM_ID, Gain) then
        -- 回滚矿石
        TryAddItems(self, ItemId, SellCount)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_OreRecycleNotify", "发放金币失败")
        return
    end
    local Msg = string.format(
        "已回收 %s x%d，获得 %d 金币",
        tostring(Entry.Name or ItemId),
        SellCount,
        Gain
    )
    ugcprint("[OreRecycle] " .. Msg)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_OreRecycleNotify", Msg)
end

function UGCPlayerController:RequestRecycleOre(ItemId, Count)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_RecycleOre", ItemId, Count)
end

--- 玩家仓库：初始自动解锁；升级扩容
local function GetWarehouseCapacity(PC)
    if not PC or not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetWarehouseCellCapacity then
        return 0
    end
    local Ok, Cap = pcall(UGCBackpackSystemV2.GetWarehouseCellCapacity, PC)
    if Ok then
        return math.floor(tonumber(Cap) or 0)
    end
    return 0
end

local function GetWarehouseMaxCapacity(PC)
    if not PC or not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetWarehouseMaxCellCapacity then
        return WarehouseConfig.GetMaxSlots()
    end
    local Ok, Cap = pcall(UGCBackpackSystemV2.GetWarehouseMaxCellCapacity, PC)
    if Ok then
        local V = math.floor(tonumber(Cap) or 0)
        if V > 0 then
            return V
        end
    end
    return WarehouseConfig.GetMaxSlots()
end

local function TryAddWarehouseCapacity(PC, AddCount)
    AddCount = math.floor(tonumber(AddCount) or 0)
    if AddCount <= 0 then
        return true
    end
    if not PC or not UGCBackpackSystemV2 or not UGCBackpackSystemV2.AddWarehouseCellCapacity then
        return false
    end
    local Ok, Ret = pcall(UGCBackpackSystemV2.AddWarehouseCellCapacity, PC, AddCount)
    if not Ok then
        return false
    end
    if Ret == false then
        return false
    end
    return true
end

function UGCPlayerController:EnsureWarehouseInitialCapacity()
    if not UGCGameSystem.IsServer() then
        return
    end
    local Initial = WarehouseConfig.GetInitialSlots()
    local Cap = GetWarehouseCapacity(self)
    if Cap >= Initial then
        return
    end
    local Need = Initial - Cap
    if TryAddWarehouseCapacity(self, Need) then
        ugcprint("[Warehouse] 初始容量已解锁: " .. tostring(Cap) .. " -> " .. tostring(GetWarehouseCapacity(self)))
    else
        ugcprint("[Warehouse] 初始容量解锁失败 Cap=" .. tostring(Cap) .. " Need=" .. tostring(Need))
    end
end

function UGCPlayerController:GetWarehouseStatus()
    self:EnsureWarehouseInitialCapacity()
    local Cap = GetWarehouseCapacity(self)
    local MaxCap = GetWarehouseMaxCapacity(self)
    local ConfigMax = WarehouseConfig.GetMaxSlots()
    if MaxCap < ConfigMax then
        MaxCap = ConfigMax
    end
    return {
        bUnlocked = true,
        Capacity = Cap,
        MaxCapacity = MaxCap,
        GoldCount = GetGoldCount(self),
        OasisTicket = GetOasisTicket(),
        UpgradeGoldCost = WarehouseConfig.GetUpgradeGoldCost(),
        UpgradeOasisCost = WarehouseConfig.GetUpgradeOasisCost(),
        SlotsPerUpgrade = WarehouseConfig.GetSlotsPerUpgrade(),
        bCanUpgrade = WarehouseConfig.CanUpgrade(Cap) and Cap < MaxCap,
        LastMsg = self.WarehouseLastMsg or "",
    }
end

function UGCPlayerController:Client_WarehouseNotify(Msg)
    Msg = tostring(Msg or "")
    self.WarehouseLastMsg = Msg
    ugcprint("[Warehouse] Notify: " .. Msg)
    if self.OnWarehouseNotify then
        pcall(self.OnWarehouseNotify, Msg)
    end
end

function UGCPlayerController:_ConsumeOasisForWarehouse(Cost, Reason)
    Cost = math.floor(tonumber(Cost) or 0)
    Reason = tostring(Reason or "操作")
    if Cost <= 0 then
        return true
    end
    local HasAPI = (UGCCommoditySystem ~= nil and UGCCommoditySystem.GetTicket ~= nil)
    local Ticket = GetOasisTicket()
    if HasAPI and Ticket < Cost then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_WarehouseNotify",
            "绿洲币不足，" .. Reason .. "需要 " .. tostring(Cost) .. "（当前 " .. tostring(Ticket) .. "）"
        )
        return false
    end
    local AllowSoft = WarehouseConfig.AllowSoftOasisSpend
    if AllowSoft == nil then
        AllowSoft = SmeltingConfig and SmeltingConfig.AllowSoftOasisSpend
    end
    if not AllowSoft then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_WarehouseNotify",
            "请在 WarehouseConfig.OasisProductId 配置绿洲币商品后购买（" .. Reason .. " " .. tostring(Cost) .. "）"
        )
        return false
    end
    ugcprint("[Warehouse] SoftOasisSpend cost=" .. tostring(Cost) .. " reason=" .. Reason .. " ticket=" .. tostring(Ticket))
    return true
end

--- PayType: 0=金币 1=绿洲币
function UGCPlayerController:Server_UpgradeWarehouse(PayType)
    if not UGCGameSystem.IsServer() then
        return
    end
    PayType = math.floor(tonumber(PayType) or 0)
    self:EnsureWarehouseInitialCapacity()

    local Cap = GetWarehouseCapacity(self)
    local AddSlots = WarehouseConfig.GetSlotsPerUpgrade()
    local MaxCap = GetWarehouseMaxCapacity(self)
    local ConfigMax = WarehouseConfig.GetMaxSlots()
    local HardMax = math.max(MaxCap, ConfigMax)

    if Cap + AddSlots > HardMax then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_WarehouseNotify", "仓库已达容量上限")
        return
    end
    if not WarehouseConfig.CanUpgrade(Cap) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_WarehouseNotify", "仓库已达容量上限")
        return
    end

    if PayType == 1 then
        local OasisCost = WarehouseConfig.GetUpgradeOasisCost()
        if not self:_ConsumeOasisForWarehouse(OasisCost, "升级仓库") then
            return
        end
    else
        local GoldCost = WarehouseConfig.GetUpgradeGoldCost()
        if not TryRemoveGold(self, GoldCost) then
            UnrealNetwork.CallUnrealRPC(
                self, self, "Client_WarehouseNotify",
                "金币不足，升级需要 " .. tostring(GoldCost)
            )
            return
        end
    end

    if not TryAddWarehouseCapacity(self, AddSlots) then
        if PayType ~= 1 then
            TryAddItems(self, GOLD_ITEM_ID, WarehouseConfig.GetUpgradeGoldCost())
        end
        UnrealNetwork.CallUnrealRPC(self, self, "Client_WarehouseNotify", "扩容失败，已退回费用")
        return
    end

    local NewCap = GetWarehouseCapacity(self)
    local PayTxt = (PayType == 1)
        and (tostring(WarehouseConfig.GetUpgradeOasisCost()) .. " 绿洲币")
        or (tostring(WarehouseConfig.GetUpgradeGoldCost()) .. " 金币")
    local Msg = string.format("仓库升级成功：%d → %d 格（消耗 %s）", Cap, NewCap, PayTxt)
    ugcprint("[Warehouse] " .. Msg)
    UnrealNetwork.CallUnrealRPC(self, self, "Client_WarehouseNotify", Msg)
end

function UGCPlayerController:RequestUpgradeWarehouse(PayType)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UpgradeWarehouse", PayType)
end

--- 客户端打开「背包 + 仓库」面板
function UGCPlayerController:OpenWarehousePanel()
    if UGCGameSystem.IsServer() and not IsLocalPC(self) then
        return
    end
    local Style = WarehouseConfig.OpenPanelStyle
    local Mode = math.floor(tonumber(WarehouseConfig.OpenPanelMode) or 2)
    if UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanelStyle then
        pcall(function()
            UGCBackpackSystemV2.OpenBackpackPanelStyle(Style, Mode)
        end)
        return
    end
    if UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanel then
        pcall(function()
            UGCBackpackSystemV2.OpenBackpackPanel(Mode)
        end)
    end
end

function UGCPlayerController:GetAvailableServerRPCs()
    return "Server_SellAppraisedJade", "Server_UnlockJadeShop", "Server_QuickAppraiseJade",
        "Server_BeginManualAppraisal", "Server_RevealJadeCell", "Server_CancelManualAppraisal",
"Server_RequestJadeCollectionSync", "Server_PlaceRawJadeInCollection",
        "Server_PlaceManualJadeInCollection", "Server_ClearJadeCollectionSlot",
        "Server_UnlockMineTeleport", "Server_TeleportToMineZone", "Server_ReturnToSpawn",
        "Server_UnlockSmeltingPlant", "Server_UpgradeSmeltingPlant", "Server_UnlockFurnace",
        "Server_StartSmelt", "Server_SkipSmelt", "Server_CollectSmelt",
        "Server_RecycleOre","Server_UpgradeWarehouse","Server_BuyTool","Server_UpgradeBackpack","Server_QueryBackpackLevel","Server_SwitchTitle"
end

function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_OpenJadeAppraisal", "Client_CloseJadeAppraisal",
        "Client_JadeShopNotify", "Client_JadeShopUnlocked", "Client_JadeQuickResult",
        "Client_JadeCellRevealed",
        "Client_JadeCollectionNotify", "Client_JadeCollectionSync",
        "Client_MineTeleportNotify", "Client_MineTeleportUnlocked", "Client_MineTeleported",
        "Client_MineTeleportHallEntered", "Client_MineTeleportHallLeft",
        "Client_ExecuteTeleport", "Client_MineReturnedToSpawn",
        "Client_SmeltNotify", "Client_SmelterUnlocked", "Client_SmelterPlantLevel",
        "Client_FurnaceCount", "Client_SmeltSlotSync",
        "Client_TalentMarketNotify", "Client_TalentMarketUnlocked", "Client_TalentJobSync",
        "Client_VehicleRepairNotify", "Client_VehicleRepairUnlocked", "Client_VehicleRepairState", "Client_ForceStopMineCarMode",
        "Client_OreRecycleNotify",
        "Client_WarehouseNotify",
        "Client_ShopNotify","Client_BackpackLevelSync","Client_TitleNotify","Client_EnsureTitleBarAdded","Client_EnsureAllTitleBars","Client_SyncTitleState"
end

-- ============ 矿工百货商店 RPC ============

-- 玩家当前背包等级（存 PC 上）
-- 初始为 1 级（10格），ReceiveBeginPlay 里初始化

-- 服务端：购买工具
function UGCPlayerController:Server_BuyTool(ToolIndex)
    -- 1. 安全检查：只在服务端执行
    if not UGCGameSystem.IsServer() then return end

    ToolIndex = tonumber(ToolIndex) or 0
    local tool = ShopConfig.GetTool(ToolIndex)
    
    -- 2. 检查工具是否存在
    if not tool then
        InvokeClient(self, "Client_ShopNotify", "工具不存在")
        return
    end
    
    -- 2.5. 检查是否已拥有该工具
    local alreadyOwned = GetItemCount(self, tool.ItemId)
    if alreadyOwned > 0 then
        InvokeClient(self, "Client_ShopNotify", "已拥有该工具，无需重复购买")
        return
    end

    -- 3. 检查是否免费（初始工具不用买）
    if tool.Cost <= 0 then
        -- 直接发工具，不收金币
        UGCBackpackSystemV2.AddItemV2(self, tool.ItemId, 1)
        InvokeClient(self, "Client_ShopNotify",
            "获得初始工具：" .. tool.Name)
        return
    end

    -- 4. 检查金币是否够
    local myGold = GetItemCount(self, ShopConfig.GoldItemId)
    if myGold < tool.Cost then
        InvokeClient(self, "Client_ShopNotify",
            "金币不足！需要 " .. tool.Cost .. " 金（当前 " .. myGold .. " 金）")
        return
    end

    -- 5. 扣金币
    UGCBackpackSystemV2.RemoveItemV2(self, ShopConfig.GoldItemId, tool.Cost)

    -- 6. 发工具到背包
    UGCBackpackSystemV2.AddItemV2(self, tool.ItemId, 1)

    -- 7. 通知客户端
    InvokeClient(self, "Client_ShopNotify",
        "购买成功！获得 " .. tool.Name .. "（消耗 " .. tool.Cost .. " 金）")
end

-- 唯一服务端写入入口：所有背包等级/容量修改都必须经过 ApplyBackpackLevel
function UGCPlayerController:ApplyBackpackLevel(TargetLevel)
    if not UGCGameSystem.IsServer() then
        return false
    end
    if not ShopConfig or not ShopConfig.GetBackpackLevel or not ShopConfig.GetMaxBackpackLevel then
        return false
    end
    TargetLevel = math.floor(tonumber(TargetLevel) or 1)
    local MaxLevel = ShopConfig.GetMaxBackpackLevel()
    TargetLevel = math.max(1, math.min(TargetLevel, MaxLevel))
    local CurLevel = math.floor(tonumber(self.BackpackLevel) or 1)
    if TargetLevel <= CurLevel then
        return false
    end
    local TargetCfg = ShopConfig.GetBackpackLevel(TargetLevel)
    if not TargetCfg or not TargetCfg.Slots then
        return false
    end

    -- 先保证容量上限足够，再补齐到目标等级对应的格子数
    if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetMaxCellCapacity and UGCBackpackSystemV2.AddMaxCellCapacity then
        local OkM, MaxCap = pcall(UGCBackpackSystemV2.GetMaxCellCapacity, self)
        if OkM and MaxCap and tonumber(MaxCap) < TargetCfg.Slots then
            pcall(UGCBackpackSystemV2.AddMaxCellCapacity, self, TargetCfg.Slots - tonumber(MaxCap))
            ugcprint("[背包] 容量上限提升至 " .. tostring(TargetCfg.Slots))
        end
    end

    if UGCBackpackSystemV2 and UGCBackpackSystemV2.AddCellCapacity then
        local CurCap = GetBackpackCapacity(self)
        local Delta = TargetCfg.Slots - CurCap
        if Delta > 0 then
            local Ok = pcall(UGCBackpackSystemV2.AddCellCapacity, self, Delta)
            ugcprint("[背包] 扩容 " .. tostring(Delta) .. " 格 ok=" .. tostring(Ok) .. " 当前容量=" .. tostring(GetBackpackCapacity(self)))
        end
    end

    self.BackpackLevel = TargetLevel
    InvokeClient(self, "Client_BackpackLevelSync", TargetLevel, GetBackpackCapacity(self))
    ugcprint("[背包] 等级变更 Lv" .. tostring(CurLevel) .. " -> Lv" .. tostring(TargetLevel))
    return true
end

-- 服务端：升级背包
function UGCPlayerController:Server_UpgradeBackpack()
    if not UGCGameSystem.IsServer() then return end

    -- 1. 使用服务端唯一权威等级，不再反推容量
    local curLevel = math.floor(tonumber(self.BackpackLevel) or 1)
    local maxLevel = ShopConfig.GetMaxBackpackLevel()

    -- 2. 检查是否满级
    if curLevel >= maxLevel then
        InvokeClient(self, "Client_ShopNotify", "背包已满级！")
        return
    end

    local nextLevel = curLevel + 1
    local nextCfg = ShopConfig.GetBackpackLevel(nextLevel)
    if not nextCfg then
        InvokeClient(self, "Client_ShopNotify", "背包升级配置错误")
        return
    end

    -- 3. 检查金币
    local myGold = GetItemCount(self, ShopConfig.GoldItemId)
    if myGold < nextCfg.Cost then
        InvokeClient(self, "Client_ShopNotify",
            "金币不足！升级到" .. nextLevel .. "级背包需要 " .. nextCfg.Cost .. " 金（当前 " .. myGold .. " 金）")
        return
    end

    -- 4. 扣金币
    UGCBackpackSystemV2.RemoveItemV2(self, ShopConfig.GoldItemId, nextCfg.Cost)

    -- 5. 统一走唯一服务端写入入口
    local Ok = self:ApplyBackpackLevel(nextLevel)
    if not Ok then
        ugcprint("[背包] ApplyBackpackLevel 失败，退回升级金币")
        if UGCBackpackSystemV2 and UGCBackpackSystemV2.AddItemV2 then
            pcall(UGCBackpackSystemV2.AddItemV2, self, ShopConfig.GoldItemId, nextCfg.Cost)
        end
        return
    end

    -- 6. 通知客户端
    InvokeClient(self, "Client_ShopNotify",
        "背包升级成功！" .. curLevel .. "级 → " .. nextLevel .. "级（" .. nextCfg.Slots .. "格，消耗 " .. nextCfg.Cost .. " 金）")
end

-- 客户端：收到商店通知
-- 客户端向服务端查询当前背包等级（Minershop 打开时调用，解决 BackpackLevel 不复制导致的显示脱节）
function UGCPlayerController:Server_QueryBackpackLevel()
    if not UGCGameSystem.IsServer() then return end
    local Lv = math.floor(tonumber(self.BackpackLevel) or 1)
    self.BackpackLevel = Lv
    InvokeClient(self, "Client_BackpackLevelSync", Lv, GetBackpackCapacity(self))
end

function UGCPlayerController:Client_BackpackLevelSync(Level, Capacity)
    self.BackpackLevel = tonumber(Level) or 1
    if self.OnBackpackLevelSynced then
        pcall(self.OnBackpackLevelSynced, self.BackpackLevel, Capacity)
    end
end

function UGCPlayerController:Client_ShopNotify(Msg)
    Msg = tostring(Msg or "")
    print("[Shop] " .. Msg)
    self.ShopLastMsg = Msg
    if self.OnShopNotify then
        pcall(self.OnShopNotify, Msg)
    end
end

-- ============ ShopV2 悬浮商店礼包发放（服务端） ============

function UGCPlayerController:GetShopItemName(ItemId)
    ItemId = tonumber(ItemId) or 0
    if ShopConfig and ShopConfig.Tools then
        for _, Tool in pairs(ShopConfig.Tools) do
            if Tool.ItemId == ItemId then
                return Tool.Name
            end
        end
    end
    if OreRecycleConfig and OreRecycleConfig.GetName then
        local Name = OreRecycleConfig.GetName(ItemId)
        if Name and Name ~= "?" then
            return Name
        end
    end
    if ItemId == JADE_ITEM_ID then
        return "玉矿石"
    end
    return tostring(ItemId)
end

function UGCPlayerController:GiveRandomOres(Count)
    Count = math.floor(tonumber(Count) or 0)
    if Count <= 0 then
        return
    end
    local Pool = OreRecycleConfig and OreRecycleConfig.ItemOrder
    if not Pool or #Pool == 0 then
        return
    end
    local Added = 0
    for _ = 1, Count do
        local Idx = math.random(#Pool)
        local OkAdd, AddRet = pcall(UGCBackpackSystemV2.AddItemV2, self, Pool[Idx], 1)
        if OkAdd and (AddRet == nil or (tonumber(AddRet) or 0) >= 1) then
            Added = Added + 1
        end
    end
    ugcprint("[商店礼包] 随机矿物实发 " .. Added .. "/" .. Count)
    if UGCItemSystemV2 and UGCItemSystemV2.GetItemMaxNumberOfStacksV2 and Pool and Pool[1] then
        local OkS, Stack = pcall(UGCItemSystemV2.GetItemMaxNumberOfStacksV2, Pool[1])
        ugcprint("[商店礼包] 矿物 " .. tostring(Pool[1]) .. " 最大堆叠=" .. tostring(Stack))
    end
    ugcprint("[商店礼包] 随机矿物实发 " .. Added .. "/" .. Count)
    if Added < Count then
        InvokeClient(self, "Client_ShopNotify", "背包空间不足，随机矿物只发放 " .. Added .. " 个")
    end
end

function UGCPlayerController:UpgradeBackpackTo(TargetLevel)
    TargetLevel = math.floor(tonumber(TargetLevel) or 1)
    if not ShopConfig then
        return false
    end
    local MaxLevel = ShopConfig.GetMaxBackpackLevel()
    TargetLevel = math.min(TargetLevel, MaxLevel)
    local Ok = self:ApplyBackpackLevel(TargetLevel)
    if Ok then
        ugcprint("[商店礼包] 背包升级至 Lv" .. tostring(TargetLevel))
    end
    return Ok
end

function UGCPlayerController:GiveShopGift(Gift, Num)
    if not Gift then
        return
    end
    Num = math.max(1, math.floor(tonumber(Num) or 1))
    local Parts = {}

    if Gift.Items then
        for _, ItemInfo in ipairs(Gift.Items) do
            local ItemId = ItemInfo[1]
            local ItemNum = (ItemInfo[2] or 1) * Num
            local OkAdd, AddRet = pcall(UGCBackpackSystemV2.AddItemV2, self, ItemId, ItemNum)
            local RealNum = (OkAdd and AddRet ~= nil) and (tonumber(AddRet) or ItemNum) or 0
            if RealNum < ItemNum then
                InvokeClient(self, "Client_ShopNotify", "背包空间不足：" .. self:GetShopItemName(ItemId) .. " 只发放 " .. RealNum .. " 个")
            end
            table.insert(Parts, tostring(RealNum) .. "x" .. self:GetShopItemName(ItemId))
        end
    end

    if Gift.JadeCount and Gift.JadeCount > 0 then
        local JadeNum = Gift.JadeCount * Num
        local OkAdd, AddRet = pcall(UGCBackpackSystemV2.AddItemV2, self, JADE_ITEM_ID, JadeNum)
        local RealJade = (OkAdd and AddRet ~= nil) and (tonumber(AddRet) or JadeNum) or 0
        if RealJade < JadeNum then
            InvokeClient(self, "Client_ShopNotify", "背包空间不足：玉矿石只发放 " .. RealJade .. " 个")
        end
        table.insert(Parts, tostring(RealJade) .. "x玉矿石")
        if UGCItemSystemV2 and UGCItemSystemV2.GetItemMaxNumberOfStacksV2 then
            local OkS, Stack = pcall(UGCItemSystemV2.GetItemMaxNumberOfStacksV2, JADE_ITEM_ID)
            ugcprint("[商店礼包] 玉矿石(8310011) 最大堆叠=" .. tostring(Stack))
        end
    end

    if Gift.RandomOreCount and Gift.RandomOreCount > 0 then
        self:GiveRandomOres(Gift.RandomOreCount * Num)
        table.insert(Parts, "随机矿物x" .. tostring(Gift.RandomOreCount * Num))
    end

    if Gift.BackpackLevel and Gift.BackpackLevel > 0 then
        local OkLv = self:UpgradeBackpackTo(Gift.BackpackLevel)
        if OkLv then
            table.insert(Parts, "背包Lv" .. tostring(Gift.BackpackLevel))
        end
    end

    if Gift.Flag then
        self[Gift.Flag] = true
        if Gift.Flag == "bAutoPickup" then
            self:StartAutoPickup()
        end
    end

    local Msg = "获得" .. Gift.Name
    if #Parts > 0 then
        Msg = Msg .. "：" .. table.concat(Parts, " + ")
    end
    ugcprint("[商店礼包] " .. Msg)
    InvokeClient(self, "Client_ShopNotify", Msg)
end

-- 自动拾取：服务端定时检测附近拾取物并自动入包（官方 API 组合）
local AUTO_PICKUP_RANGE = 200
function UGCPlayerController:StartAutoPickup()
    if self._bAutoPickupRunning then return end
    self._bAutoPickupRunning = true
    ugcprint("[自动拾取] 已开启（范围 " .. AUTO_PICKUP_RANGE .. "）")
    self:TickAutoPickup()
end

function UGCPlayerController:StopAutoPickup()
    self._bAutoPickupRunning = false
    ugcprint("[自动拾取] 已关闭")
end

function UGCPlayerController:TickAutoPickup()
    if not self._bAutoPickupRunning then return end
    if not self.bAutoPickup or not UGCObjectUtility.IsObjectValid(self) then
        self:StopAutoPickup()
        return
    end
    local Pawn = self:GetPawn()
    if Pawn and UGCItemSystemV2 and UGCItemSystemV2.FindPickupWrapperActorByRange and UGCItemSystemV2.TryPickupWrapperItem then
        local OkPos, Pos = pcall(function() return Pawn:GetActorLocation() end)
        if OkPos and Pos then
            local OkList, Wrappers = pcall(UGCItemSystemV2.FindPickupWrapperActorByRange, Pos, AUTO_PICKUP_RANGE)
            if OkList and type(Wrappers) == "table" then
                for _, W in ipairs(Wrappers) do
                    pcall(UGCItemSystemV2.TryPickupWrapperItem, Pawn, W, nil, nil, true)
                end
            end
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.5, function()
            if UGCObjectUtility.IsObjectValid(self) and self._bAutoPickupRunning then
                self:TickAutoPickup()
            end
        end, false)
    end
end

function UGCPlayerController:OnShopV2ItemAdded(Result)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not Result or Result.bSucceeded == false then
        return
    end
    if not Result.ItemList then
        return
    end
    for ItemID, Num in pairs(Result.ItemList) do
        local Gift = ShopV2ProductConfig and ShopV2ProductConfig.GetGift(ItemID)
        if Gift then
            self:GiveShopGift(Gift, Num)
        end
    end
end

function UGCPlayerController:BindShopV2Gift(Attempt)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not UGCObjectUtility.IsObjectValid(self) then
        return
    end
    if self._bShopV2GiftBinded then
        return
    end
    if UGCGamePartSystem and UGCGamePartSystem.VirtualItemManager then
        local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        if VIM and VIM.AddItemResultDelegate then
            VIM.AddItemResultDelegate:Add(self.OnShopV2ItemAdded, self)
            self._bShopV2GiftBinded = true
            ugcprint("[商店礼包] 服务端监听 AddItemResultDelegate 成功")
            return
        end
    end
    Attempt = math.floor(tonumber(Attempt) or 1)
    if Attempt < 15 then
        UGCTimerUtility.CreateLuaTimer(1.0, function()
            if UGCObjectUtility.IsObjectValid(self) then
                self:BindShopV2Gift(Attempt + 1)
            end
        end, false)
    end
end

-- ============ 付费/商业化 RPC ============

--- 客户端发起购买商品（绿洲币）
--- @param ProductId number 商品ID，如 9000001
--- @param Count number 购买数量，通常为1
function UGCPlayerController:RequestBuyProduct(ProductId, Count)
    ProductId = math.floor(tonumber(ProductId) or 0)
    Count = math.floor(tonumber(Count) or 1)
    if PaymentSystem and PaymentSystem.BuyProduct then
        PaymentSystem.BuyProduct(ProductId, Count)
    else
        InvokeClient(self, "Client_PaymentNotify", "付费系统不可用")
    end
end

--- 客户端发起使用虚拟物品
--- @param CommodityId number 虚拟物品ID，如 1001
--- @param Count number 使用数量
function UGCPlayerController:RequestUseCommodity(CommodityId, Count)
    CommodityId = math.floor(tonumber(CommodityId) or 0)
    Count = math.floor(tonumber(Count) or 1)
    if PaymentSystem and PaymentSystem.UseCommodity then
        PaymentSystem.UseCommodity(CommodityId, Count)
    else
        InvokeClient(self, "Client_PaymentNotify", "付费系统不可用")
    end
end

--- 显示绿洲币充值入口UI（仅客户端）
function UGCPlayerController:RequestShowRechargeUI()
    if PaymentSystem and PaymentSystem.ShowRechargeUI then
        PaymentSystem.ShowRechargeUI()
    end
end

--- 获取绿洲币余额（客户端）
function UGCPlayerController:GetOasisTicket()
    if PaymentSystem and PaymentSystem.GetTicketCount then
        return PaymentSystem.GetTicketCount()
    end
    return 0
end

--- 获取启元币余额
function UGCPlayerController:GetActiveCoinCount()
    if not UGCCommoditySystem or not UGCCommoditySystem.GetActiveCoin then
        return 0
    end
    local ok, coin = pcall(UGCCommoditySystem.GetActiveCoin)
    if ok then
        return math.floor(tonumber(coin) or 0)
    end
    return 0
end

--- 获取已拥有的虚拟物品列表
function UGCPlayerController:GetPaymentCommodityList()
    if PaymentSystem and PaymentSystem.GetCommodityList then
        return PaymentSystem.GetCommodityList()
    end
    return {}
end

--- 查询指定虚拟物品数量
function UGCPlayerController:GetPaymentCommodityCount(CommodityId)
    if PaymentSystem and PaymentSystem.GetCommodityCount then
        return PaymentSystem.GetCommodityCount(CommodityId)
    end
    return 0
end

--- 服务端：商业化道具效果 - 给玩家物品
function UGCPlayerController:Server_PaymentGiveItem(ItemId, Count)
    if not UGCGameSystem.IsServer() then return end
    ItemId = math.floor(tonumber(ItemId) or 0)
    Count = math.floor(tonumber(Count) or 1)
    if ItemId <= 0 then
        InvokeClient(self, "Client_PaymentNotify", "物品ID无效")
        return
    end
    if not UGCBackpackSystemV2 or not UGCBackpackSystemV2.AddItemV2 then
        InvokeClient(self, "Client_PaymentNotify", "背包系统不可用")
        return
    end
    local ok, err = pcall(function()
        UGCBackpackSystemV2.AddItemV2(self, ItemId, Count)
    end)
    if ok then
        ugcprint(string.format("[Payment] ✅ 商业化发放物品: ItemId=%d, Count=%d", ItemId, Count))
        InvokeClient(self, "Client_PaymentNotify",
            string.format("发放物品成功：ID=%d x%d", ItemId, Count))
    else
        ugcprint(string.format("[Payment] ❌ 发放物品失败: %s", tostring(err)))
        InvokeClient(self, "Client_PaymentNotify", "发放物品失败")
    end
end

--- 服务端：商业化道具效果 - 升级背包等级
function UGCPlayerController:Server_PaymentUpgradeBackpack(TargetLevel)
    if not UGCGameSystem.IsServer() then return end
    TargetLevel = math.floor(tonumber(TargetLevel) or 3)
    if not self.BackpackLevel then
        self.BackpackLevel = 1
    end
    if self.BackpackLevel >= TargetLevel then
        InvokeClient(self, "Client_PaymentNotify",
            string.format("背包已经是 %d 级，无需升级", self.BackpackLevel))
        return
    end
    self.BackpackLevel = TargetLevel
    ugcprint(string.format("[Payment] ✅ 背包等级升级至 %d", TargetLevel))
    InvokeClient(self, "Client_PaymentNotify",
        string.format("背包升级成功：当前 %d 级", TargetLevel))
    if self.OnBackpackLevelChanged then
        pcall(self.OnBackpackLevelChanged)
    end
end

--- 客户端：付费系统通知
function UGCPlayerController:Client_PaymentNotify(Msg)
    Msg = tostring(Msg or "")
    self.PaymentLastMsg = Msg
    ugcprint("[Payment] Notify: " .. Msg)
    if self.OnPaymentNotify then
        pcall(self.OnPaymentNotify, Msg)
    end
end

-- ============ 财富排行榜 ============

local RANK_ID_WEALTH = 1
local GOLD_ITEM_ID = 8310002
local RANK_UPDATE_INTERVAL = 5.0

function UGCPlayerController:StartWealthRankTimer()
    if not UGCGameSystem.IsServer() then
        return
    end
    if self._WealthRankTimerStarted then
        return
    end
    self._WealthRankTimerStarted = true
    self._LastRankScore = -1
    ugcprint('[财富榜] 启动排行榜分数更新定时器')
    self._WealthRankTimer = UGCTimerUtility.CreateLuaTimer(RANK_UPDATE_INTERVAL, function()
        if UGCObjectUtility.IsObjectValid(self) then
            self:UpdateWealthRankScore()
        end
    end, true)
end

function UGCPlayerController:UpdateWealthRankScore()
    if not UGCGameSystem.IsServer() then
        return
    end
    local PC = self
    if not PC or not UGCObjectUtility.IsObjectValid(PC) then
        return
    end
    local GoldCount = 0
    if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetItemCountV2 then
        local Ok, Cnt = pcall(UGCBackpackSystemV2.GetItemCountV2, PC, GOLD_ITEM_ID)
        if Ok then
            GoldCount = math.floor(tonumber(Cnt) or 0)
        end
    end
    self:Server_RefreshTitleProgress(GoldCount)
    if GoldCount == self._LastRankScore then
        return
    end
    self._LastRankScore = GoldCount
    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager")
    if not UE.IsValid(RankingListGlobalActor) then
        ugcprint('[财富榜] RankingListGlobalActor 无效')
        return
    end
    local UID = 0
    if PC.GetInt64PlayerKey then
        UID = PC:GetInt64PlayerKey()
    end
    if UID <= 0 then
        ugcprint('[财富榜] UID 无效')
        return
    end
    local Ok, Err = pcall(RankingListGlobalActor.UpdateScore, RankingListGlobalActor, PC, UID, RANK_ID_WEALTH, GoldCount, false)
    if Ok then
        ugcprint(string.format('[财富榜] 更新排行榜分数: UID=%d, Score=%d', UID, GoldCount))
    else
        ugcprint(string.format('[财富榜] 更新排行榜分数失败: %s', tostring(Err)))
    end
end

-- ============ 成就称号系统 ============

local TITLE_BAR_WIDGET_PATH = 'Asset/Blueprint/Prefabs/UI/WBP_TitleBar.WBP_TitleBar_C'
local TITLE_BAR_OFFSET = { X = 0, Y = 0, Z = 180 }
local TITLE_MINE_COUNT_ITEM_ID = 1057
-- 当前阶段只验证任务进度与发奖，自动佩戴/头顶 UI 后续阶段再开启
local TITLE_AUTO_EQUIP_ENABLED = true
local TITLE_BAR_UI_ENABLED = true

local function GetVirtualItemManagerSafe()
    if UGCGamePartSystem and UGCGamePartSystem.VirtualItemManager then
        local Ok, V = pcall(function()
            return UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
        end)
        if Ok then
            return V
        end
    end
    return nil
end

function UGCPlayerController:GetUnlockedTitleIDs()
    local IDs = {}
    if not TitleConfig or not TitleConfig.GetAllTitles then
        return IDs
    end
    local VIM = GetVirtualItemManagerSafe()
    if not VIM or not VIM.GetItemNum then
        if self and self.ClientUnlockedTitleIDs and type(self.ClientUnlockedTitleIDs) == "table" then
            for _, ID in ipairs(self.ClientUnlockedTitleIDs) do
                table.insert(IDs, math.floor(tonumber(ID) or 0))
            end
        end
        return IDs
    end
    for _, TitleID in ipairs(TitleConfig.GetAllTitles()) do
        local Entry = TitleConfig.Get(TitleID)
        if Entry then
            local OkNum, Num = pcall(VIM.GetItemNum, VIM, Entry.UnlockItemID, self)
            if OkNum and math.floor(tonumber(Num) or 0) > 0 then
                table.insert(IDs, TitleID)
            end
        end
    end
    return IDs
end

function UGCPlayerController:IsTitleUnlocked(TitleID)
    TitleID = math.floor(tonumber(TitleID) or 0)
    local IDs = self:GetUnlockedTitleIDs()
    for _, ID in ipairs(IDs) do
        if ID == TitleID then
            return true
        end
    end
    return false
end

function UGCPlayerController:GetCurrentTitleID()
    local Pawn = GetPawnByControllerSafe(self)
    if Pawn and Pawn.CurrentTitleID ~= nil then
        return math.floor(tonumber(Pawn.CurrentTitleID) or 0)
    end
    return 0
end

function UGCPlayerController:GetTitleListForUI()
    local List = {}
    if not TitleConfig or not TitleConfig.GetAllTitles then
        return List
    end
    local UnlockedMap = {}
    for _, ID in ipairs(self:GetUnlockedTitleIDs()) do
        UnlockedMap[ID] = true
    end
    local CurrentID = self:GetCurrentTitleID()
    if CurrentID <= 0 and self.ClientCurrentTitleID then
        CurrentID = math.floor(tonumber(self.ClientCurrentTitleID) or 0)
    end
    for _, TitleID in ipairs(TitleConfig.GetAllTitles()) do
        local Entry = TitleConfig.Get(TitleID)
        if Entry then
            table.insert(List, {
                TitleID = TitleID,
                Name = Entry.Name,
                Desc = Entry.Desc,
                IconPath = Entry.IconPath,
                Unlocked = UnlockedMap[TitleID] == true,
                Equipped = TitleID == CurrentID,
            })
        end
    end
    return List
end

function UGCPlayerController:RequestSwitchTitle(TitleID)
    TitleID = math.floor(tonumber(TitleID) or 0)
    InvokeServer(self, "Server_SwitchTitle", TitleID)
end

function UGCPlayerController:Server_SwitchTitle(TitleID)
    if not UGCGameSystem.IsServer() then
        return
    end
    TitleID = math.floor(tonumber(TitleID) or 0)
    local Entry = TitleConfig and TitleConfig.Get and TitleConfig.Get(TitleID)
    if not Entry then
        InvokeClient(self, "Client_TitleNotify", "称号不存在")
        return
    end
    if not self:IsTitleUnlocked(TitleID) then
        InvokeClient(self, "Client_TitleNotify", "未解锁该称号")
        return
    end
    if self:GetCurrentTitleID() == TitleID then
        InvokeClient(self, "Client_TitleNotify", "已佩戴该称号")
        return
    end
    local VIM = GetVirtualItemManagerSafe()
    if not VIM or not VIM.RemoveVirtualItem or not VIM.AddVirtualItem then
        InvokeClient(self, "Client_TitleNotify", "虚拟物品系统未就绪")
        return
    end
    if TitleConfig.GetAllTitles then
        for _, OtherID in ipairs(TitleConfig.GetAllTitles()) do
            local Other = TitleConfig.Get(OtherID)
            if Other and Other.EquipItemID then
                local OkNum, Num = pcall(VIM.GetItemNum, VIM, Other.EquipItemID, self)
                if OkNum and math.floor(tonumber(Num) or 0) > 0 then
                    pcall(VIM.RemoveVirtualItem, VIM, self, Other.EquipItemID, math.floor(tonumber(Num) or 0))
                end
            end
        end
    end
    pcall(VIM.AddVirtualItem, VIM, self, Entry.EquipItemID, 1)
    local Pawn = GetPawnByControllerSafe(self)
    if Pawn and UGCObjectUtility.IsObjectValid(Pawn) then
        Pawn:SetCurrentTitleID(TitleID)
    end
    ugcprint(string.format("[称号] 切换成功: TitleID=%d Name=%s", TitleID, tostring(Entry.Name)))
    InvokeClient(self, "Client_TitleNotify", "已佩戴称号：" .. tostring(Entry.Name))
    InvokeClient(self, "Client_SyncTitleState", TitleID, table.concat(self:GetUnlockedTitleIDs(), ","))
    self:NotifyAllClientsTitleChanged()
end

function UGCPlayerController:Client_TitleNotify(Msg)
    Msg = tostring(Msg or "")
    self.TitleLastMsg = Msg
    ugcprint("[称号] Notify: " .. Msg)
    if self.OnTitleNotify then
        pcall(self.OnTitleNotify, Msg)
    end
end

function UGCPlayerController:Client_SyncTitleState(CurrentID, UnlockedIDsStr)
    self.ClientCurrentTitleID = math.floor(tonumber(CurrentID) or 0)
    self.ClientUnlockedTitleIDs = {}
    if type(UnlockedIDsStr) == "table" then
        self.ClientUnlockedTitleIDs = UnlockedIDsStr
    elseif type(UnlockedIDsStr) == "string" and UnlockedIDsStr ~= "" then
        for Token in string.gmatch(UnlockedIDsStr, "([^,]+)") do
            local ID = math.floor(tonumber(Token) or 0)
            if ID > 0 then
                table.insert(self.ClientUnlockedTitleIDs, ID)
            end
        end
    end
    ugcprint(string.format("[称号] 客户端状态同步: Current=%d Unlocked=%d",
        self.ClientCurrentTitleID, #self.ClientUnlockedTitleIDs))
    if self._OnTitleSwitched then
        pcall(self._OnTitleSwitched, self.ClientCurrentTitleID)
    end
end

function UGCPlayerController:Server_EquipTitleIfNone(TitleID)
    if not UGCGameSystem.IsServer() then
        return false
    end
    TitleID = math.floor(tonumber(TitleID) or 0)
    if self:GetCurrentTitleID() ~= 0 then
        return false
    end
    local Entry = TitleConfig and TitleConfig.Get and TitleConfig.Get(TitleID)
    if not Entry then
        return false
    end
    local VIM = GetVirtualItemManagerSafe()
    if not VIM or not VIM.GetItemNum or not VIM.AddVirtualItem then
        return false
    end
    local OkEquipNum, EquipNum = pcall(VIM.GetItemNum, VIM, Entry.EquipItemID, self)
    if OkEquipNum and math.floor(tonumber(EquipNum) or 0) > 0 then
        return false
    end
    pcall(VIM.AddVirtualItem, VIM, self, Entry.EquipItemID, 1)
    local Pawn = GetPawnByControllerSafe(self)
    if Pawn and UGCObjectUtility.IsObjectValid(Pawn) then
        Pawn:SetCurrentTitleID(TitleID)
    end
    ugcprint(string.format("[称号] 自动佩戴首个解锁称号: TitleID=%d", TitleID))
    return true
end

local function GetTaskManagerGlobalSafe()
    if UGCGamePartSystem and UGCGamePartSystem.GetGamePartGlobalActor then
        local Ok, TM = pcall(UGCGamePartSystem.GetGamePartGlobalActor, "TaskManager")
        if Ok and TM then
            return TM
        end
    end
    return nil
end

function UGCPlayerController:GetTitleTaskIndex(TitleID)
    TitleID = math.floor(tonumber(TitleID) or 0)
    local TaskIndex = 0
    if TitleConfig and TitleConfig.GetTaskIndex then
        TaskIndex = math.floor(tonumber(TitleConfig.GetTaskIndex(TitleID)) or 0)
    end
    if TaskIndex <= 0 then
        return nil
    end
    local TaskLineName = "成就"
    if TitleConfig and TitleConfig.GetTaskLineName then
        TaskLineName = TitleConfig.GetTaskLineName() or TaskLineName
    end
    return {
        TaskLineName = TaskLineName,
        PercentTaskIndex = TaskIndex,
        LevelTaskLevelIndex = 0,
        LevelTaskIndex = 0,
    }
end

function UGCPlayerController:Server_UpdateTitleTaskProgress(TitleID, Progress, IsIncremental)
    if not UGCGameSystem.IsServer() then
        return
    end
    TitleID = math.floor(tonumber(TitleID) or 0)
    local Entry = TitleConfig and TitleConfig.Get and TitleConfig.Get(TitleID)
    if not Entry then
        return
    end
    local TM = GetTaskManagerGlobalSafe()
    if not TM or not TM.UpdateTaskProgress then
        ugcprint(string.format("[称号] 任务系统未就绪，跳过任务进度更新 TitleID=%d", TitleID))
        return
    end
    local TaskIndex = self:GetTitleTaskIndex(TitleID)
    if not TaskIndex then
        return
    end
    Progress = math.max(0, math.floor(tonumber(Progress) or 0))
    local Target = 0
    if TitleConfig and TitleConfig.GetTaskTarget then
        Target = math.floor(tonumber(TitleConfig.GetTaskTarget(TitleID)) or 0)
    end
    if Target > 0 then
        Progress = math.min(Progress, Target)
    end
    local Ok, Err = pcall(TM.UpdateTaskProgress, TM, TaskIndex, self, Progress, IsIncremental == true)
    if Ok then
        ugcprint(string.format("[称号] 任务进度更新 TitleID=%d TaskIndex=%d Progress=%d Inc=%s",
            TitleID, TaskIndex.PercentTaskIndex, Progress, tostring(IsIncremental == true)))
    else
        ugcprint(string.format("[称号] 任务进度更新失败 TitleID=%d Err=%s", TitleID, tostring(Err)))
    end
end

function UGCPlayerController:Server_UpdateCashTitleProgress(GoldCount)
    if not UGCGameSystem.IsServer() then
        return
    end
    GoldCount = math.floor(tonumber(GoldCount) or 0)
    for _, TitleID in ipairs({ 1011, 1012, 1013 }) do
        local Target = 0
        if TitleConfig and TitleConfig.GetTaskTarget then
            Target = math.floor(tonumber(TitleConfig.GetTaskTarget(TitleID)) or 0)
        end
        if Target > 0 then
            self:Server_UpdateTitleTaskProgress(TitleID, GoldCount, false)
        end
    end
end

function UGCPlayerController:Server_RefreshTitleProgress(OptionalGoldCount)
    if not UGCGameSystem.IsServer() then
        return
    end
    -- 閲戝竵浠诲姟杩涘害
    local GoldCount = OptionalGoldCount
    if GoldCount == nil then
        GoldCount = 0
        if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetItemCountV2 then
            local OkGold, Gold = pcall(UGCBackpackSystemV2.GetItemCountV2, self, GOLD_ITEM_ID)
            if OkGold then
                GoldCount = math.floor(tonumber(Gold) or 0)
            end
        end
    end
    self:Server_UpdateCashTitleProgress(GoldCount)
    -- 采矿车任务进度
    if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetItemCountV2 then
        for _, VehicleID in ipairs({8310023, 8310024, 8310025}) do
            local OkCnt, Cnt = pcall(UGCBackpackSystemV2.GetItemCountV2, self, VehicleID)
            if OkCnt and math.floor(tonumber(Cnt) or 0) > 0 then
                self:Server_UpdateTitleTaskProgress(1014, 1, false)
                break
            end
        end
    end
    -- 鎸栫熆璁℃暟浠诲姟杩涘害
    local VIM = GetVirtualItemManagerSafe()
    if VIM and VIM.GetItemNum then
        local OkMine, MineNum = pcall(VIM.GetItemNum, VIM, TITLE_MINE_COUNT_ITEM_ID, self)
        if OkMine then
            local MineCount = math.floor(tonumber(MineNum) or 0)
            if MineCount > 0 then
                self:Server_UpdateTitleTaskProgress(1017, MineCount, false)
            end
        end
    end
end

function UGCPlayerController:Server_AddMineOreCount(Count)
    if not UGCGameSystem.IsServer() then
        return
    end
    Count = math.floor(tonumber(Count) or 1)
    if Count <= 0 then
        return
    end
    local VIM = GetVirtualItemManagerSafe()
    if not VIM or not VIM.AddVirtualItem or not VIM.GetItemNum then
        return
    end
    local OkNum, Num = pcall(VIM.GetItemNum, VIM, TITLE_MINE_COUNT_ITEM_ID, self)
    local Have = OkNum and math.floor(tonumber(Num) or 0) or 0
    local OkAdd, AddErr = pcall(VIM.AddVirtualItem, VIM, self, TITLE_MINE_COUNT_ITEM_ID, Count)
    if not OkAdd then
        ugcprint(string.format("[称号] 挖矿计数物品添加失败: %s", tostring(AddErr)))
        return
    end
    local New = Have + Count
    ugcprint(string.format("[称号] 挖矿计数 +%d => %d", Count, New))
    self:Server_UpdateTitleTaskProgress(1017, New, false)
end

function UGCPlayerController:Server_CompleteTutorialTitleTask()
    if not UGCGameSystem.IsServer() then
        return
    end
    self:Server_UpdateTitleTaskProgress(1015, 1, false)
end

function UGCPlayerController:Server_UpdateJadeTitleTask(Value)
    if not UGCGameSystem.IsServer() then
        return
    end
    Value = math.floor(tonumber(Value) or 0)
    local Target = 2000
    if TitleConfig and TitleConfig.GetTaskTarget then
        Target = math.floor(tonumber(TitleConfig.GetTaskTarget(1016)) or 2000)
    end
    self:Server_UpdateTitleTaskProgress(1016, Value, false)
end

function UGCPlayerController:ValidateTitleTaskRewards()
    if not TitleConfig or not TitleConfig.GetAllTitles then
        return
    end
    local TM = GetTaskManagerGlobalSafe()
    if not TM or not TM.GetTaskAwardList then
        return
    end
    for _, TitleID in ipairs(TitleConfig.GetAllTitles()) do
        local Entry = TitleConfig.Get(TitleID)
        if Entry then
            local Ok, AwardList = pcall(TM.GetTaskAwardList, TM, TitleID)
            local Count = 0
            if Ok and AwardList then
                local OkPairs, C = pcall(function()
                    local N = 0
                    for _ in pairs(AwardList) do
                        N = N + 1
                    end
                    return N
                end)
                if OkPairs then
                    Count = math.floor(tonumber(C) or 0)
                end
            end
            if Count > 0 then
                ugcprint(string.format("[称号] 任务奖励配置正常: TitleID=%d 奖励数=%d", TitleID, Count))
            else
                ugcprint(string.format("[称号] 警告: 任务 %d 未配置奖励，领取不会发放虚拟物品", TitleID))
            end
        end
    end
end

function UGCPlayerController:OnTitleItemAdded(Result)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not Result or Result.bSucceeded == false then
        return
    end
    if not Result.ItemList then
        return
    end
    local SelfKey = 0
    if self.GetInt64PlayerKey then
        SelfKey = math.floor(tonumber(self:GetInt64PlayerKey()) or 0)
    end
    local PlayerKey = Result.PlayerKey
    if SelfKey > 0 and PlayerKey ~= nil and math.floor(tonumber(PlayerKey) or 0) ~= SelfKey then
        return
    end
    for ItemID, Num in pairs(Result.ItemList) do
        local Entry, TitleID = nil, nil
        if TitleConfig and TitleConfig.GetByUnlockItemID then
            Entry, TitleID = TitleConfig.GetByUnlockItemID(ItemID)
        end
        if Entry and TitleID then
            ugcprint(string.format("[称号] 解锁凭证到账: TitleID=%d Name=%s Num=%s", TitleID, tostring(Entry.Name), tostring(Num)))
            if TITLE_AUTO_EQUIP_ENABLED then
                local OkEquip = self:Server_EquipTitleIfNone(TitleID)
                if OkEquip then
                    InvokeClient(self, "Client_TitleNotify", "已自动佩戴称号：" .. tostring(Entry.Name))
                    InvokeClient(self, "Client_SyncTitleState", TitleID, table.concat(self:GetUnlockedTitleIDs(), ","))
                    self:NotifyAllClientsTitleChanged()
                end
            end
        end
    end
end

function UGCPlayerController:BindTitleItemListener(Attempt)
    if not UGCGameSystem.IsServer() then
        return
    end
    if self._bTitleItemListenerBinded then
        return
    end
    local VIM = GetVirtualItemManagerSafe()
    if VIM and VIM.AddItemResultDelegate then
        VIM.AddItemResultDelegate:Add(self.OnTitleItemAdded, self)
        self._bTitleItemListenerBinded = true
        ugcprint("[称号] 服务端监听 AddItemResultDelegate 成功")
        return
    end
    Attempt = math.floor(tonumber(Attempt) or 1)
    if Attempt < 15 then
        UGCTimerUtility.CreateLuaTimer(1.0, function()
            if UGCObjectUtility.IsObjectValid(self) then
                self:BindTitleItemListener(Attempt + 1)
            end
        end, false)
    end
end

function UGCPlayerController:InitTitleState(Attempt)
    if not UGCGameSystem.IsServer() then
        return
    end
    if not UGCObjectUtility.IsObjectValid(self) then
        return
    end
    local VIM = GetVirtualItemManagerSafe()
    if not VIM or not VIM.GetItemNum then
        Attempt = math.floor(tonumber(Attempt) or 1)
        if Attempt < 15 then
            UGCTimerUtility.CreateLuaTimer(1.0, function()
                if UGCObjectUtility.IsObjectValid(self) then
                    self:InitTitleState(Attempt + 1)
                end
            end, false)
        end
        return
    end
    local CurrentID = 0
    if TitleConfig and TitleConfig.GetAllTitles then
        for _, TitleID in ipairs(TitleConfig.GetAllTitles()) do
            local Entry = TitleConfig.Get(TitleID)
            if Entry then
                local OkNum, Num = pcall(VIM.GetItemNum, VIM, Entry.EquipItemID, self)
                if OkNum and math.floor(tonumber(Num) or 0) > 0 then
                    CurrentID = TitleID
                    break
                end
            end
        end
    end
    if TITLE_AUTO_EQUIP_ENABLED and CurrentID == 0 and TitleConfig and TitleConfig.GetAllTitles then
        for _, TitleID in ipairs(TitleConfig.GetAllTitles()) do
            local Entry = TitleConfig.Get(TitleID)
            if Entry then
                local OkNum, Num = pcall(VIM.GetItemNum, VIM, Entry.UnlockItemID, self)
                if OkNum and math.floor(tonumber(Num) or 0) > 0 then
                    CurrentID = TitleID
                    pcall(VIM.AddVirtualItem, VIM, self, Entry.EquipItemID, 1)
                    break
                end
            end
        end
    end
    local Pawn = GetPawnByControllerSafe(self)
    if not Pawn or not UGCObjectUtility.IsObjectValid(Pawn) then
        Attempt = math.floor(tonumber(Attempt) or 1)
        if Attempt < 15 then
            UGCTimerUtility.CreateLuaTimer(1.0, function()
                if UGCObjectUtility.IsObjectValid(self) then
                    self:InitTitleState(Attempt + 1)
                end
            end, false)
        end
        return
    end
    -- 先同步 Pawn 上的当前称号，避免后续自动解锁时重复佩戴
    Pawn:SetCurrentTitleID(CurrentID)
    self:Server_RefreshTitleProgress()
    self:ValidateTitleTaskRewards()
    local FinalID = self:GetCurrentTitleID()
    ugcprint(string.format("[称号] 初始化完成: CurrentTitleID=%d", FinalID))
    InvokeClient(self, "Client_SyncTitleState", FinalID, table.concat(self:GetUnlockedTitleIDs(), ","))
    if TITLE_BAR_UI_ENABLED then
        self:EnsureTitleBarAdded(1)
    else
        ugcprint("[称号] 当前阶段跳过头顶称号 UI")
    end
end

function UGCPlayerController:EnsureTitleBarAdded(Attempt)
    if not UGCGameSystem.IsServer() then
        return
    end
    local Pawn = GetPawnByControllerSafe(self)
    if not Pawn or not UGCObjectUtility.IsObjectValid(Pawn) then
        Attempt = math.floor(tonumber(Attempt) or 1)
        if Attempt < 15 then
            UGCTimerUtility.CreateLuaTimer(1.0, function()
                if UGCObjectUtility.IsObjectValid(self) then
                    self:EnsureTitleBarAdded(Attempt + 1)
                end
            end, false)
        end
        return
    end
    ugcprint("[称号] 服务端广播客户端头顶UI创建 RPC")
    self:NotifyAllClientsTitleChanged()
end

function UGCPlayerController:NotifyAllClientsTitleChanged()
    if not UGCGameSystem.IsServer() then
        return
    end
    local AllPC = nil
    if UGCGameSystem and UGCGameSystem.GetAllPlayerController then
        local Ok, PCs = pcall(UGCGameSystem.GetAllPlayerController)
        if Ok then
            AllPC = PCs
        end
    end
    if type(AllPC) ~= "table" then
        InvokeClient(self, "Client_EnsureAllTitleBars")
        return
    end
    for _, PC in ipairs(AllPC) do
        if PC and UGCObjectUtility.IsObjectValid(PC) then
            InvokeClient(PC, "Client_EnsureAllTitleBars")
        end
    end
end

function UGCPlayerController:Client_EnsureTitleBarAdded(Attempt)
    self:Client_EnsureAllTitleBars(Attempt)
end

function UGCPlayerController:Client_EnsureAllTitleBars(Attempt)
    local PC = self
    if not PC or not UGCObjectUtility.IsObjectValid(PC) then
        return
    end
    ugcprint("[称号] 客户端刷新全部玩家头顶UI")
    local AllPawn = nil
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawn then
        local Ok, Pawns = pcall(UGCGameSystem.GetAllPlayerPawn)
        if Ok then
            AllPawn = Pawns
        end
    end
    local Found = false
    if type(AllPawn) == "table" then
        for _, Pawn in ipairs(AllPawn) do
            if Pawn and UGCObjectUtility.IsObjectValid(Pawn) then
                Found = true
                PC:Client_AddTitleBarForPawn(Pawn)
            end
        end
    end
    local OwnPawn = GetPawnByControllerSafe(PC)
    if OwnPawn then
        local OkID, ID = pcall(function()
            return OwnPawn.CurrentTitleID
        end)
        if OkID and ID ~= nil and math.floor(tonumber(ID) or 0) > 0 then
            PC.ClientCurrentTitleID = math.floor(tonumber(ID) or 0)
        end
    end
    if not Found then
        Attempt = math.floor(tonumber(Attempt) or 1)
        if Attempt < 15 then
            UGCTimerUtility.CreateLuaTimer(1.0, function()
                if UGCObjectUtility.IsObjectValid(PC) then
                    PC:Client_EnsureAllTitleBars(Attempt + 1)
                end
            end, false)
        else
            ugcprint("[称号] 客户端获取玩家Pawn列表失败（重试 15 次后放弃）")
        end
    end
end

function UGCPlayerController:Client_AddTitleBarForPawn(Pawn)
    local PC = self
    if not PC or not UGCObjectUtility.IsObjectValid(PC) or not Pawn or not UGCObjectUtility.IsObjectValid(Pawn) then
        return
    end
    if PC._TitleBarIndexByPawn == nil then
        PC._TitleBarIndexByPawn = {}
    end
    if PC._TitleBarIndexByPawn[Pawn] ~= nil then
        PC:Client_RefreshTitleBarForPawn(Pawn)
        return
    end
    local p = UGCGameSystem.GetUGCResourcesFullPath(TITLE_BAR_WIDGET_PATH)
    if not p or p == '' then
        ugcprint("[称号] WBP_TitleBar path not found")
        return
    end
    local PawnName = tostring(Pawn)
    if Pawn and Pawn.GetName then
        local OkName, Name = pcall(Pawn.GetName, Pawn)
        if OkName then
            PawnName = tostring(Name)
        end
    end
    local Ok, Index = pcall(UGCWidgetManagerSystem.AddObjectPositionUI, Pawn, p, TITLE_BAR_OFFSET, true, false, false, true)
    if Ok and Index ~= nil then
        PC._TitleBarIndexByPawn[Pawn] = Index
        ugcprint(string.format("[称号] 客户端头顶称号UI已提交: Pawn=%s Index=%s（负数表示异步加载中）",
            PawnName, tostring(Index)))
        PC:Client_ConfirmTitleBarCreated(Pawn, 1)
    else
        ugcprint(string.format("[称号] 客户端头顶称号UI添加失败: Pawn=%s Ok=%s Err=%s",
            PawnName, tostring(Ok), tostring(Index)))
    end
end

function UGCPlayerController:Client_RefreshTitleBarForPawn(Pawn)
    local PC = self
    local Index = PC and PC._TitleBarIndexByPawn and PC._TitleBarIndexByPawn[Pawn]
    if Index == nil or not Pawn or not UGCObjectUtility.IsObjectValid(Pawn) then
        return
    end
    if UGCWidgetManagerSystem and UGCWidgetManagerSystem.GetObjectPositionUI then
        local Ok, Widget = pcall(UGCWidgetManagerSystem.GetObjectPositionUI, Pawn, Index)
        if Ok and Widget and Widget.RefreshTitle then
            pcall(Widget.RefreshTitle, Widget)
        end
    end
end

function UGCPlayerController:Client_ConfirmTitleBarCreated(Pawn, Attempt)
    local PC = self
    if not PC or not UGCObjectUtility.IsObjectValid(PC) then
        return
    end
    local Index = PC._TitleBarIndexByPawn and PC._TitleBarIndexByPawn[Pawn]
    if Index == nil then
        return
    end
    if Pawn and UGCObjectUtility.IsObjectValid(Pawn) and UGCWidgetManagerSystem and UGCWidgetManagerSystem.GetObjectPositionUI then
        local Ok, Widget = pcall(UGCWidgetManagerSystem.GetObjectPositionUI, Pawn, Index)
        if Ok and Widget ~= nil then
            ugcprint(string.format("[称号] 客户端头顶称号UI创建完成: Index=%s", tostring(Index)))
            if Widget.RefreshTitle then
                pcall(Widget.RefreshTitle, Widget)
            end
            return
        end
    end
    Attempt = math.floor(tonumber(Attempt) or 1)
    if Attempt < 30 then
        UGCTimerUtility.CreateLuaTimer(1.0, function()
            if UGCObjectUtility.IsObjectValid(PC) then
                PC:Client_ConfirmTitleBarCreated(Pawn, Attempt + 1)
            end
        end, false)
    else
        ugcprint("[称号] 客户端等待头顶称号UI创建超时，控件将由系统异步创建")
    end
end

return UGCPlayerController


