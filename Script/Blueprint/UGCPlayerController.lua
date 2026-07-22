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
                [6] = { Name = "玉石矿脉", PadX = 22000, PadY = 29200, PadZ = 220 },
            },
            GetZone = function(ZoneId)
                return MineTeleportConfig.Zones[tonumber(ZoneId) or 0]
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
local UNLOCK_COST = 15000
local QUICK_COST = 3000
local JADE_BASE_VALUE = 600
local JADE_CELL_COUNT = 25
local MINE_TELEPORT_UNLOCK_COST = MineTeleportConfig.UnlockCost or 8500
local MINE_TELEPORT_COST = MineTeleportConfig.TeleportCost or 3000

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
    ClearManualSession(self)

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
    if not IsJadeShopUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_JadeShopNotify",
            "请先解锁玉石鉴定所（" .. tostring(UNLOCK_COST) .. " 金币）"
        )
        return
    end
    if GetJadeCount(self) < 1 then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "背包中没有未鉴定玉石")
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
    UnrealNetwork.CallUnrealRPC(self, self, "Client_OpenJadeAppraisal")
end

--- 服务端翻格：随机等级并回传权威价值
function UGCPlayerController:Server_RevealJadeCell(Index)
    Index = math.floor(tonumber(Index) or -1)
    if Index < 0 or Index >= JADE_CELL_COUNT then
        return
    end
    local Session = GetManualSession(self)
    if not Session then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "鉴定会话无效，请重新进入")
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
    UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeCellRevealed", Index, Level, ValueInt)
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
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "出售失败：无鉴定会话")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_CloseJadeAppraisal")
        return
    end
    local SellValue = math.floor((Session.CurrentValue or 0) + 0.5)
    if SellValue < 0 then
        SellValue = 0
    end
    if not RemoveOneJade(self) then
        ClearManualSession(self)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "出售失败：没有玉石")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_CloseJadeAppraisal")
        return
    end
    if SellValue > 0 then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, SellValue)
    end
    ClearManualSession(self)
    ugcprint("[Jade] 出售结算 value=" .. tostring(SellValue))
    UnrealNetwork.CallUnrealRPC(
        self, self, "Client_JadeShopNotify",
        "售出成功：获得 " .. tostring(SellValue) .. " 金币"
    )
    UnrealNetwork.CallUnrealRPC(self, self, "Client_CloseJadeAppraisal")
end

--- 关闭面板不卖：清会话，不扣玉石
function UGCPlayerController:Server_CancelManualAppraisal()
    ClearManualSession(self)
    ugcprint("[Jade] 手动鉴定会话已取消")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_CloseJadeAppraisal")
end

--- 解锁鉴定所（15000）
function UGCPlayerController:Server_UnlockJadeShop()
    if IsJadeShopUnlocked(self) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "鉴定所已解锁")
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopUnlocked")
        return
    end
    if not TryRemoveGold(self, UNLOCK_COST) then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_JadeShopNotify",
            "金币不足，解锁需要 " .. tostring(UNLOCK_COST)
        )
        return
    end
    self.bJadeShopUnlocked = true
    ugcprint("[Jade] 鉴定所已解锁")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopUnlocked")
    UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "解锁成功！可进行鉴定")
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
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_JadeShopNotify",
            "请先解锁玉石鉴定所（" .. tostring(UNLOCK_COST) .. " 金币）"
        )
        return
    end
    if GetJadeCount(self) < 1 then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "背包中没有未鉴定玉石")
        return
    end
    if GetGoldCount(self) < QUICK_COST then
        UnrealNetwork.CallUnrealRPC(
            self, self, "Client_JadeShopNotify",
            "金币不足，快速鉴定需要 " .. tostring(QUICK_COST)
        )
        return
    end
    if not TryRemoveGold(self, QUICK_COST) then
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "扣费失败")
        return
    end
    if not RemoveOneJade(self) then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, QUICK_COST)
        UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeShopNotify", "没有玉石，已退回费用")
        return
    end
    local Roll = math.random(0, 10000)
    if Roll > 0 then
        UGCBackpackSystemV2.AddItemV2(self, GOLD_ITEM_ID, Roll)
    end
    ugcprint("[Jade] 快速鉴定结果=" .. tostring(Roll))
    UnrealNetwork.CallUnrealRPC(self, self, "Client_JadeQuickResult", Roll)
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
    UnrealNetwork.CallUnrealRPC(self, self, "Server_UnlockJadeShop")
end

function UGCPlayerController:RequestQuickAppraiseJade()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_QuickAppraiseJade")
end

function UGCPlayerController:RequestBeginManualAppraisal()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_BeginManualAppraisal")
end

function UGCPlayerController:RequestRevealJadeCell(Index)
    UnrealNetwork.CallUnrealRPC(self, self, "Server_RevealJadeCell", Index)
end

function UGCPlayerController:RequestSellAppraisedJade()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_SellAppraisedJade")
end

function UGCPlayerController:RequestCancelManualAppraisal()
    UnrealNetwork.CallUnrealRPC(self, self, "Server_CancelManualAppraisal")
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

function UGCPlayerController:GetAvailableServerRPCs()
    return "Server_SellAppraisedJade", "Server_UnlockJadeShop", "Server_QuickAppraiseJade",
        "Server_BeginManualAppraisal", "Server_RevealJadeCell", "Server_CancelManualAppraisal",
        "Server_UnlockMineTeleport", "Server_TeleportToMineZone"
end

function UGCPlayerController:GetAvailableClientRPCs()
    return "Client_OpenJadeAppraisal", "Client_CloseJadeAppraisal",
        "Client_JadeShopNotify", "Client_JadeShopUnlocked", "Client_JadeQuickResult",
        "Client_JadeCellRevealed",
        "Client_MineTeleportNotify", "Client_MineTeleportUnlocked", "Client_MineTeleported"
end

function UGCPlayerController:GetReplicatedProperties()
    return "bJadeShopUnlocked", "bMineTeleportUnlocked"
end

return UGCPlayerController
