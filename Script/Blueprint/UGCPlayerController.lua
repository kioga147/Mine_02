---@class UGCPlayerController_C:BP_PlayerController_TopDown_C
---@field BuffClassTable ULuaArrayHelper<UClass>
---@field BuffClassTable1 ULuaArrayHelper<UClass>
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
                [1] = { Name = "石滩", PadX = 20000, PadY = 28000, PadZ = 220 },
                [2] = { Name = "煤矿场", PadX = 21000, PadY = 28000, PadZ = 220 },
                [3] = { Name = "黄铜矿脉", PadX = 22000, PadY = 28000, PadZ = 220 },
                [4] = { Name = "深层矿区", PadX = 20000, PadY = 29200, PadZ = 220 },
                [5] = { Name = "宝石矿区", PadX = 21000, PadY = 29200, PadZ = 220 },
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
            DurationSec = 600,
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

-- 玉石鉴定逻辑对齐 TESTWK；物品 ID 使用 Mine_02 现有表：
-- 8310011 = 玉矿石（未鉴定） Mine_10
-- 8310018 = 玉石 Mine_17（兼容）
-- 8310002 = 金币 Coin
local JADE_ITEM_ID = 8310011
local JADE_ITEM_ID_LEGACY = 8310018
local GOLD_ITEM_ID = 8310002
-- 铜镐 ItemID（与物品表 / MiningSystem 一致）
local COPPER_PICKAXE_ITEM_ID = 8310026
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
    local Pawn = nil
    if PC then
        if PC.GetPlayerCharacterSafety then
            local Ok, P = pcall(function()
                return PC:GetPlayerCharacterSafety()
            end)
            if Ok then
                Pawn = P
            end
        end
        if Pawn == nil and PC.K2_GetPawn then
            local Ok, P = pcall(function()
                return PC:K2_GetPawn()
            end)
            if Ok then
                Pawn = P
            end
        end
    end
    if Pawn == nil and UGCGameSystem and UGCGameSystem.GetPlayerPawn then
        local Ok, P = pcall(UGCGameSystem.GetPlayerPawn, PC)
        if Ok then
            Pawn = P
        end
    end
    if Pawn == nil then
        return false
    end

    local Loc = { X = X, Y = Y, Z = Z }
    if Vector and Vector.New then
        Loc = Vector.New(X, Y, Z)
    elseif FVector then
        Loc = FVector(X, Y, Z)
    end

    local Ok = false
    if Pawn.K2_TeleportTo then
        Ok = pcall(function()
            Pawn:K2_TeleportTo(Loc, Pawn:K2_GetActorRotation())
        end)
    end
    if not Ok and Pawn.K2_SetActorLocation then
        Ok = pcall(function()
            Pawn:K2_SetActorLocation(Loc, false, nil, true)
        end)
    end
    if not Ok and Pawn.SetActorLocation then
        Ok = pcall(function()
            Pawn:SetActorLocation(Loc)
        end)
    end
    return Ok and true or false
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
    if IsLocalPC(PC) and type(PC[FuncName]) == "function" then
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
    if UGCGameSystem.IsServer() and type(PC[FuncName]) == "function" then
        PC[FuncName](PC, ...)
        return
    end
    UnrealNetwork.CallUnrealRPC(PC, PC, FuncName, ...)
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

    if self.bJadeShopUnlocked == nil then
        self.bJadeShopUnlocked = false
    end
    if self.bMineTeleportUnlocked == nil then
        self.bMineTeleportUnlocked = false
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
    ClearManualSession(self)

    if UGCGameSystem.IsServer() then
        self:EnsureWarehouseInitialCapacity()
        -- 开局发放铜镐（迁自 Mine_03，延后等 Pawn/背包就绪）
        self._InitialPickaxeRetry = 0
        UGCTimerUtility.CreateLuaTimer(INITIAL_PICKAXE_DELAY_SEC, function()
            if UGCObjectUtility.IsObjectValid(self) then
                self:GiveInitialCopperPickaxe()
            end
        end, false)
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

--- 仅本机创建面板（由服务端 Begin 成功后 Client_Open 调用）
function UGCPlayerController:OpenJadeAppraisalUI()
    if self.JadeAppraisalWidget or self.bOpeningJadeUI then
        ugcprint("[Jade] 面板已存在或正在打开")
        return false
    end
    if not IsLocalPC(self) then
        ugcprint("[Jade] 非本地PC，跳过开UI")
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
            return
        end
        self.JadeAppraisalWidget = Widget
        UGCWidgetManagerSystem.AddToSlot(Widget, "UI.UISlot.MainUISlot_High")
        if Widget.ApplyScreenLayout then
            Widget:ApplyScreenLayout()
        end
        ugcprint("[Jade] 鉴定面板已挂载")
        if self.OnJadeManualUIOpened then
            pcall(self.OnJadeManualUIOpened)
            self.OnJadeManualUIOpened = nil
        end
    end)
    return true
end

function UGCPlayerController:Client_OpenJadeAppraisal()
    ugcprint("[Jade] Client_OpenJadeAppraisal")
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
    if not GetManualSession(self) then
        self.JadeManualSession = {
            Active = true,
            CurrentValue = JADE_BASE_VALUE,
            Opened = {},
        }
        ugcprint("[Jade] 手动鉴定会话已创建 value=" .. tostring(JADE_BASE_VALUE))
    end
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
    if not RemoveOneJade(self) then
        ClearManualSession(self)
        InvokeClient(self, "Client_JadeShopNotify", "出售失败：没有玉石")
        InvokeClient(self, "Client_CloseJadeAppraisal")
        return
    end
    if SellValue > 0 then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, SellValue)
    end
    ClearManualSession(self)
    ugcprint("[Jade] 出售结算 value=" .. tostring(SellValue))
    InvokeClient(self, "Client_JadeShopNotify", "售出成功：获得 " .. tostring(SellValue) .. " 金币")
    InvokeClient(self, "Client_CloseJadeAppraisal")
end

--- 关闭面板不卖：清会话，不扣玉石
function UGCPlayerController:Server_CancelManualAppraisal()
    ClearManualSession(self)
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

--- ========== 矿区传送大厅 ==========

function UGCPlayerController:GetMineTeleportStatus()
    return {
        bUnlocked = IsMineTeleportUnlocked(self),
        GoldCount = GetGoldCount(self),
        UnlockCost = MINE_TELEPORT_UNLOCK_COST,
        TeleportCost = MINE_TELEPORT_COST,
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
    local Zone = MineTeleportConfig.GetZone(ZoneId)
    if Zone == nil then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportNotify", "无效矿区")
        return
    end
    if not IsMineTeleportUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_MineTeleportNotify",
            "请先解锁传送大厅（" .. tostring(MINE_TELEPORT_UNLOCK_COST) .. " 金币）"
        )
        return
    end
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
    local Ok = TeleportPawnTo(self, Zone.PadX, Zone.PadY, Zone.PadZ)
    if not Ok then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, MINE_TELEPORT_COST)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleportNotify", "传送失败，已退回费用")
        return
    end
    ugcprint("[MineTeleport] 传送至 " .. tostring(Zone.Name) .. " (" .. tostring(ZoneId) .. ")")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_MineTeleported", ZoneId)
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_MineTeleportNotify",
        "已传送至「" .. tostring(Zone.Name) .. "」"
    )
end

function UGCPlayerController:Client_MineTeleported(ZoneId)
    ZoneId = math.floor(tonumber(ZoneId) or 0)
    if self.OnMineTeleported then
        pcall(self.OnMineTeleported, ZoneId)
    end
end

function UGCPlayerController:RequestUnlockMineTeleport()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UnlockMineTeleport")
end

function UGCPlayerController:RequestTeleportToMineZone(ZoneId)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_TeleportToMineZone", ZoneId)
end

--- ========== 矿石加工厂 / 冶炼 ==========

local SMELT_STATE_IDLE = 0
local SMELT_STATE_RUNNING = 1
local SMELT_STATE_READY = 2

local function NowSec()
    local T = os.time()
    return tonumber(T) or 0
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

local function RefreshSmeltSlotState(SlotData)
    if SlotData == nil then
        return
    end
    if SlotData.State == SMELT_STATE_RUNNING then
        local EndTime = tonumber(SlotData.EndTime) or 0
        if EndTime > 0 and NowSec() >= EndTime then
            SlotData.State = SMELT_STATE_READY
        end
    end
end

local function IsSmelterUnlocked(PC)
    return PC ~= nil and PC.bSmelterUnlocked == true
end

local function SyncSmeltSlotToClient(PC, Slot)
    local Data = GetSmeltSlot(PC, Slot)
    RefreshSmeltSlotState(Data)
    UnrealNetwork.CallUnrealRPC(
        PC, PC, "Client_SmeltSlotSync",
        Slot,
        Data.State or SMELT_STATE_IDLE,
        Data.InputId or 0,
        Data.Count or 0,
        Data.EndTime or 0,
        Data.OutputId or 0
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

function UGCPlayerController:Client_SmeltSlotSync(Slot, State, InputId, Count, EndTime, OutputId)
    Slot = math.floor(tonumber(Slot) or 0)
    if Slot < 1 or Slot > 5 then
        return
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
    if UGCGameSystem.IsServer() then
        EnsureSmeltSessions(self)
        Source = self.SmeltSessions
    end
    for Slot = 1, 5 do
        local Data = Source and Source[Slot] or nil
        if Data then
            RefreshSmeltSlotState(Data)
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
                "第5座冶炼炉仅可用 100 绿洲币解锁"
            )
            return
        end
        if not TryRemoveGold(self, GoldCost) then
            UnrealNetwork.CallUnrealRPC(
                self, self, "Client_SmeltNotify",
                "金币不足，需要 " .. tostring(GoldCost) .. "（也可用 100 绿洲币）"
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
            "绿洲币不足，" .. Reason .. "需要 " .. tostring(Cost) .. "（当前 " .. tostring(Ticket) .. "）"
        )
        return false
    end
    if not SmeltingConfig.AllowSoftOasisSpend then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_SmeltNotify",
            "请在 SmeltingConfig.OasisProductIds 配置绿洲币商品后购买（" .. Reason .. " " .. tostring(Cost) .. "）"
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
    if GetItemCount(self, CoalId) < Count then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "煤矿不足（1 粗矿需 1 煤矿）")
        return
    end
    if not TryRemoveItems(self, ItemId, Count) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "扣除粗矿失败")
        return
    end
    if not TryRemoveItems(self, CoalId, Count) then
        TryAddItems(self, ItemId, Count)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_SmeltNotify", "扣除煤矿失败，已退回粗矿")
        return
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
        "Server_UnlockMineTeleport", "Server_TeleportToMineZone",
        "Server_UnlockSmeltingPlant", "Server_UpgradeSmeltingPlant", "Server_UnlockFurnace",
        "Server_StartSmelt", "Server_SkipSmelt", "Server_CollectSmelt",
        "Server_RecycleOre",
        "Server_UpgradeWarehouse"
end

function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_OpenJadeAppraisal", "Client_CloseJadeAppraisal",
        "Client_JadeShopNotify", "Client_JadeShopUnlocked", "Client_JadeQuickResult",
        "Client_JadeCellRevealed",
        "Client_MineTeleportNotify", "Client_MineTeleportUnlocked", "Client_MineTeleported",
        "Client_SmeltNotify", "Client_SmelterUnlocked", "Client_SmelterPlantLevel",
        "Client_FurnaceCount", "Client_SmeltSlotSync",
        "Client_OreRecycleNotify",
        "Client_WarehouseNotify"
end

function UGCPlayerController:GetReplicatedProperties()
    return "bJadeShopUnlocked", "bMineTeleportUnlocked",
        "bSmelterUnlocked", "SmelterPlantLevel", "UnlockedFurnaceCount"
end

return UGCPlayerController
