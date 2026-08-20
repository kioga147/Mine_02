---@class BP_OreSmeltingFacility_C:AActor
---@field InteractTrigger UDragonBoatBoxTriggerComponent
---@field BuildingMesh UStaticMeshComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 矿石加工厂：复用鉴定所 Prompt UI（解锁/操作/切换/关闭）
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
            RecipeOrder = { 8310004, 8310005, 8310007, 8310008, 8310009, 8310010 },
            CountPresets = { 1, 5, 10, 25, 50 },
            Recipes = {
                [8310004] = { Name = "粗铁矿", OutputId = 8310012, OutputName = "精炼铁矿", MineLevel = 2 },
                [8310005] = { Name = "粗铜矿", OutputId = 8310013, OutputName = "精炼铜矿", MineLevel = 2 },
                [8310007] = { Name = "粗金矿", OutputId = 8310014, OutputName = "精炼金矿", MineLevel = 3 },
                [8310008] = { Name = "铝土矿", OutputId = 8310015, OutputName = "精炼铝矿", MineLevel = 3 },
                [8310009] = { Name = "钻石矿", OutputId = 8310016, OutputName = "精加工钻石", MineLevel = 4 },
                [8310010] = { Name = "红宝石矿", OutputId = 8310017, OutputName = "精加工红宝石", MineLevel = 4 },
            },
            GetRecipe = function(ItemId)
                return SmeltingConfig.Recipes[tonumber(ItemId) or 0]
            end,
            CanRefine = function(ItemId, PlantLevel)
                local Recipe = SmeltingConfig.GetRecipe(ItemId)
                if Recipe == nil then
                    return false
                end
                local MaxLv = (math.floor(tonumber(PlantLevel) or 1) >= 2) and 99 or 2
                return (tonumber(Recipe.MineLevel) or 99) <= MaxLv
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
            end,
            NextCount = function(Current)
                local Presets = SmeltingConfig.CountPresets or { 1, 5, 10, 25, 50 }
                local Cur = math.floor(tonumber(Current) or 1)
                for i, V in ipairs(Presets) do
                    if V == Cur then
                        return Presets[(i % #Presets) + 1]
                    end
                end
                return Presets[1]
            end,
            GetFurnaceCost = function(Slot)
                local T = {
                    [2] = { Gold = 20000, Oasis = 100 },
                    [3] = { Gold = 40000, Oasis = 100 },
                    [4] = { Gold = 100000, Oasis = 100 },
                    [5] = { Gold = nil, Oasis = 100 },
                }
                return T[math.floor(tonumber(Slot) or 0)]
            end,
        }
    end
end

local EnterButtonManager = nil
do
    local ok, mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.Common.EnterButtonManager')
    end)
    if ok and type(mod) == 'table' then EnterButtonManager = mod else EnterButtonManager = {} end
end

local BP_OreSmeltingFacility = {
    bLocalPlayerInside = false,
    bPromptDismissed = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedFurnace = 1,
    SelectedOreId = 8310004,
    SelectedCount = 1,
    --- 0=金币 1=绿洲币
    PayType = 0,
    LastFurnaceCount = 0,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"
local SMELT_STATE_IDLE = 0
local SMELT_STATE_RUNNING = 1
local SMELT_STATE_READY = 2

local function IsLocalPlayerPawn(OtherActor)
    if OtherActor == nil then
        return false
    end
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    return LocalPawn ~= nil and LocalPawn == OtherActor
end

local function GetInteractTrigger(self)
    return self.InteractTrigger
end

local function GetLocalPC()
    return UGCGameSystem.GetLocalPlayerController()
end

local function GetW(Widget, Name)
    if Widget == nil then
        return nil
    end
    if Widget[Name] ~= nil then
        return Widget[Name]
    end
    if Widget.GetWidgetFromName then
        local Ok, W = pcall(function()
            return Widget:GetWidgetFromName(Name)
        end)
        if Ok then
            return W
        end
    end
    return nil
end

local function SetText(Widget, Text)
    if Widget and Widget.SetText then
        pcall(function()
            Widget:SetText(Text)
        end)
    end
end

local function SetVisible(Widget, bShow)
    if Widget == nil or Widget.SetVisibility == nil then
        return
    end
    local Vis
    if bShow then
        Vis = (ESlateVisibility and ESlateVisibility.Visible) or 0
    else
        Vis = (ESlateVisibility and ESlateVisibility.Collapsed) or 1
    end
    pcall(function()
        Widget:SetVisibility(Vis)
    end)
end

local function SetEnabled(Widget, bEnabled)
    if Widget == nil or Widget.SetIsEnabled == nil then
        return
    end
    pcall(function()
        Widget:SetIsEnabled(bEnabled == true)
    end)
end

local function FormatOasisR(Cost)
    local N = math.floor(tonumber(Cost) or 0)
    if N <= 0 then
        return "0r"
    end
    if N % 10 == 0 then
        return tostring(math.floor(N / 10)) .. "r"
    end
    return tostring(N) .. "绿洲"
end

local function IsPaymentSwitchAvailable(Status)
    Status = Status or {}
    if Status.bUnlocked ~= true then
        return false
    end
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    if FurnaceCount >= 5 then
        return false
    end
    return SmeltingConfig.GetFurnaceCost(FurnaceCount + 1) ~= nil
end

local function FitPromptText(Widget)
    if Widget == nil then
        return
    end
    if Widget.SetAutoWrapText then
        pcall(function()
            Widget:SetAutoWrapText(true)
        end)
    end
    if Widget.SetWrapTextAt then
        pcall(function()
            Widget:SetWrapTextAt(1160)
        end)
    end
    if Widget.SetClipping then
        pcall(function()
            Widget:SetClipping(1)
        end)
    end
    if Widget.SetRenderScale then
        pcall(function()
            Widget:SetRenderScale({ X = 0.82, Y = 0.82 })
        end)
    end
end

local function FormatCompactNumber(Value)
    local N = math.floor(tonumber(Value) or 0)
    local AbsN = math.abs(N)
    if AbsN >= 100000000 then
        return string.format("%.1f亿", N / 100000000)
    end
    if AbsN >= 10000 then
        return string.format("%.1f万", N / 10000)
    end
    return tostring(N)
end

local function ShortSmeltMessage(Msg)
    Msg = tostring(Msg or "")
    if Msg == "" then
        return ""
    end
    if string.find(Msg, "绿洲币不足", 1, true) then
        local Need, Current = string.match(Msg, "需要%s*(%d+).-[（(]当前%s*(%d+)")
        if Need ~= nil and Current ~= nil then
            return "绿洲不足：需" .. tostring(Need) .. "，现" .. tostring(Current)
        end
        return "绿洲币不足"
    end
    if string.find(Msg, "煤矿不足", 1, true) then
        return "煤矿不足：每个粗矿需要1煤"
    end
    if string.find(Msg, "粗矿数量不足", 1, true) then
        return "粗矿数量不足"
    end
    if string.find(Msg, "开始精炼", 1, true) then
        return ""
    end
    if string.find(Msg, "已跳过等待", 1, true) then
        return "已跳过，可收取产物"
    end
    return Msg
end

local function NowSec()
    return tonumber(os.time()) or 0
end

local function FormatRemain(EndTime, ServerNow)
    local CurTime = tonumber(ServerNow) or 0
    if CurTime <= 0 then
        CurTime = NowSec()
    end
    local Remain = math.floor((tonumber(EndTime) or 0) - CurTime)
    if Remain < 0 then
        Remain = 0
    end
    local M = math.floor(Remain / 60)
    local S = Remain % 60
    return string.format("%d:%02d", M, S)
end

function BP_OreSmeltingFacility:ReceiveBeginPlay()
    if BP_OreSmeltingFacility.SuperClass and BP_OreSmeltingFacility.SuperClass.ReceiveBeginPlay then
        pcall(BP_OreSmeltingFacility.SuperClass.ReceiveBeginPlay, self)
    end

    self.SelectedFurnace = 1
    self.SelectedOreId = SmeltingConfig.FirstRecipeId(1)
    self.SelectedCount = 1
    self.PayType = 0
    self.LastFurnaceCount = 0

    local Trigger = GetInteractTrigger(self)
    if Trigger == nil then
        ugcprint("[SmeltFacility] InteractTrigger 缺失")
        return
    end
    if self.bOverlapBound then
        return
    end
    self.bOverlapBound = true

    pcall(function()
        Trigger.bGenerateOverlapEvents = true
        -- 避免新建蓝图默认无碰撞导致无法触发 Overlap
        if Trigger.SetCollisionProfileName then
            Trigger:SetCollisionProfileName("OverlapAllDynamic")
        elseif Trigger.SetCollisionEnabled then
            local QueryOnly = (ECollisionEnabled and ECollisionEnabled.QueryOnly) or 1
            Trigger:SetCollisionEnabled(QueryOnly)
            if Trigger.SetCollisionResponseToAllChannels then
                local Overlap = (ECollisionResponse and ECollisionResponse.ECR_Overlap) or 2
                Trigger:SetCollisionResponseToAllChannels(Overlap)
            end
        end
    end)

    if Trigger.OnComponentBeginOverlap then
        Trigger.OnComponentBeginOverlap:Add(self.OnTriggerBeginOverlap, self)
    end
    if Trigger.OnComponentEndOverlap then
        Trigger.OnComponentEndOverlap:Add(self.OnTriggerEndOverlap, self)
    end
    ugcprint("[SmeltFacility] Overlap 已绑定")
end

function BP_OreSmeltingFacility:ReceiveEndPlay()
    self:UnbindPCCallbacks()
    local Trigger = GetInteractTrigger(self)
    if Trigger and self.bOverlapBound then
        if Trigger.OnComponentBeginOverlap then
            pcall(function()
                Trigger.OnComponentBeginOverlap:Remove(self.OnTriggerBeginOverlap, self)
            end)
        end
        if Trigger.OnComponentEndOverlap then
            pcall(function()
                Trigger.OnComponentEndOverlap:Remove(self.OnTriggerEndOverlap, self)
            end)
        end
    end
    self.bOverlapBound = false
    self:HidePrompt()

    if BP_OreSmeltingFacility.SuperClass and BP_OreSmeltingFacility.SuperClass.ReceiveEndPlay then
        pcall(BP_OreSmeltingFacility.SuperClass.ReceiveEndPlay, self)
    end
end

function BP_OreSmeltingFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    if self.bPromptDismissed then
        return
    end
    if self.bLocalPlayerInside then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[SmeltFacility] 本机玩家进入加工厂")
    self:ShowEnterButton()
end

function BP_OreSmeltingFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    self.bPromptDismissed = false
    ugcprint("[SmeltFacility] 本机玩家离开加工厂")
    EnterButtonManager.Hide(GetLocalPC())
    self:HidePrompt()
end

function BP_OreSmeltingFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local Facility = self
    PC.OnSmeltNotify = function(Msg)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnSmelterUnlocked = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnSmelterStateChanged = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
end

function BP_OreSmeltingFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    PC.OnSmeltNotify = nil
    PC.OnSmelterUnlocked = nil
    PC.OnSmelterStateChanged = nil
end

function BP_OreSmeltingFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetSmeltingStatus then
        local Ok, Status = pcall(function()
            return PC:GetSmeltingStatus()
        end)
        if Ok and type(Status) == "table" then
            return Status
        end
    end
    return {
        bUnlocked = PC and PC.bSmelterUnlocked == true,
        PlantLevel = (PC and PC.SmelterPlantLevel) or 1,
        FurnaceCount = (PC and PC.UnlockedFurnaceCount) or 0,
        GoldCount = 0,
        CoalCount = 0,
        OasisTicket = 0,
        UnlockCost = SmeltingConfig.PlantUnlockCost,
        UpgradeCost = SmeltingConfig.PlantUpgradeCost,
        SkipOasisCost = SmeltingConfig.SkipOasisCost,
        Slots = {},
        LastMsg = PC and PC.SmeltLastMsg or "",
    }
end

function BP_OreSmeltingFacility:ApplyLabels(Widget, Status)
    if Widget == nil then
        return
    end
    Status = Status or {}
    local bUnlocked = Status.bUnlocked == true
    local PlantLevel = math.floor(tonumber(Status.PlantLevel) or 1)
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    if self.SelectedFurnace < 1 then
        self.SelectedFurnace = 1
    end
    if FurnaceCount > 0 and self.SelectedFurnace > FurnaceCount then
        self.SelectedFurnace = FurnaceCount
    end
    if not SmeltingConfig.CanRefine(self.SelectedOreId, PlantLevel) then
        self.SelectedOreId = SmeltingConfig.FirstRecipeId(PlantLevel)
    end

    local Recipe = SmeltingConfig.GetRecipe(self.SelectedOreId) or { Name = "?" }
    local Slot = (Status.Slots and Status.Slots[self.SelectedFurnace]) or {}
    local State = math.floor(tonumber(Slot.State) or 0)

    local UnlockTxt
    if not bUnlocked then
        UnlockTxt = string.format("解锁加工厂 (%d)", Status.UnlockCost or 10000)
    elseif FurnaceCount < 5 then
        local Next = FurnaceCount + 1
        local Cost = SmeltingConfig.GetFurnaceCost(Next) or { Oasis = 100 }
        if self.PayType == 1 or Cost.Gold == nil then
            UnlockTxt = string.format("解锁炉%d (%s)", Next, FormatOasisR(Cost.Oasis or 100))
        else
            UnlockTxt = string.format("解锁炉%d (金%d)", Next, Cost.Gold)
        end
    elseif PlantLevel < 2 then
        UnlockTxt = string.format("升级工厂 (%d)", Status.UpgradeCost or 10000)
    else
        UnlockTxt = "炉位已满"
    end

    local ActionTxt = "开始精炼"
    if State == SMELT_STATE_RUNNING then
        ActionTxt = string.format("跳过 (%s)", FormatOasisR(Status.SkipOasisCost or 50))
    elseif State == SMELT_STATE_READY then
        ActionTxt = "收取产物"
    end

    local EnterTxt
    if bUnlocked and FurnaceCount > 1 then
        EnterTxt = string.format("切炉·当前%d/%d", self.SelectedFurnace, FurnaceCount)
    elseif bUnlocked and PlantLevel < 2 then
        EnterTxt = string.format("升级工厂 (%d)", Status.UpgradeCost or 10000)
    else
        EnterTxt = string.format("切量·x%d", self.SelectedCount)
    end
    local CycleTxt = string.format("切矿·%s", tostring(Recipe.Name))
    local CloseTxt = "关闭"
    if IsPaymentSwitchAvailable(Status) then
        CloseTxt = (self.PayType == 1) and "切支付·绿洲币" or "切支付·金币"
    end

    SetText(GetW(Widget, "Txt_Enter"), EnterTxt)
    SetText(GetW(Widget, "Txt_Unlock"), UnlockTxt)
    SetText(GetW(Widget, "Txt_Quick"), ActionTxt)
    SetText(GetW(Widget, "Txt_Manual"), CycleTxt)
    SetText(GetW(Widget, "Txt_Close"), CloseTxt)
end

function BP_OreSmeltingFacility:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end
    local Status = self:GetStatus()
    local bUnlocked = Status.bUnlocked == true

    -- 借用鉴定 UI：解锁后显示三个操作按钮
    Status.JadeCount = bUnlocked and 1 or 0
    Status.QuickCost = 0
    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState(Status)
        end)
    end

    SetVisible(GetW(Widget, "Btn_Enter"), bUnlocked)
    SetVisible(GetW(Widget, "Gap_Prompt"), bUnlocked)
    SetVisible(GetW(Widget, "Btn_Unlock"), true)
    SetVisible(GetW(Widget, "Gap_Unlock"), true)
    SetVisible(GetW(Widget, "Btn_Quick"), bUnlocked)
    SetVisible(GetW(Widget, "Gap_Quick"), bUnlocked)
    SetVisible(GetW(Widget, "Btn_Manual"), bUnlocked)
    SetVisible(GetW(Widget, "Gap_Manual"), bUnlocked)
    SetVisible(GetW(Widget, "Btn_Close"), true)
    SetVisible(GetW(Widget, "Gap_Close"), true)

    local PlantLevel = math.floor(tonumber(Status.PlantLevel) or 1)
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    local LastFurnaceCount = math.floor(tonumber(self.LastFurnaceCount) or 0)
    if FurnaceCount > LastFurnaceCount then
        self.SelectedFurnace = FurnaceCount
    end
    self.LastFurnaceCount = FurnaceCount
    local Slot = (Status.Slots and Status.Slots[self.SelectedFurnace]) or {}
    local State = math.floor(tonumber(Slot.State) or 0)
    local bCanMeta = false
    if not bUnlocked then
        bCanMeta = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.UnlockCost) or 10000)
    elseif FurnaceCount < 5 then
        local NextCost = SmeltingConfig.GetFurnaceCost(FurnaceCount + 1)
        if NextCost ~= nil then
            if self.PayType == 1 or NextCost.Gold == nil then
                bCanMeta = true
            else
                bCanMeta = (tonumber(Status.GoldCount) or 0) >= (tonumber(NextCost.Gold) or 0)
            end
        end
    elseif PlantLevel < 2 then
        bCanMeta = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.UpgradeCost) or 10000)
    end
    local bCanEnter = bUnlocked
    if bUnlocked and FurnaceCount > 1 then
        bCanEnter = true
    elseif bUnlocked and PlantLevel < 2 then
        bCanEnter = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.UpgradeCost) or 10000)
    end
    SetEnabled(GetW(Widget, "Btn_Enter"), bCanEnter)
    SetEnabled(GetW(Widget, "Btn_Unlock"), bCanMeta)
    SetEnabled(GetW(Widget, "Btn_Quick"), bUnlocked and FurnaceCount >= 1 and (State == SMELT_STATE_IDLE or State == SMELT_STATE_RUNNING or State == SMELT_STATE_READY))
    SetEnabled(GetW(Widget, "Btn_Manual"), bUnlocked)
    SetEnabled(GetW(Widget, "Btn_Close"), true)

    self:ApplyLabels(Widget, Status)

    local Recipe = SmeltingConfig.GetRecipe(self.SelectedOreId) or { Name = "?" }
    local StateTxt = "空闲"
    if State == SMELT_STATE_RUNNING then
        StateTxt = "精炼中 " .. FormatRemain(Slot.EndTime, Status.ServerNow)
    elseif State == SMELT_STATE_READY then
        StateTxt = "可收取"
    end

    local Line
    local ExtraNotes = {}
    if not bUnlocked then
        Line = string.format(
            "矿石加工厂 · 解锁 %d 金币（当前 %d）",
            Status.UnlockCost or 10000,
            Status.GoldCount or 0
        )
    else
        Line = string.format(
            "加工厂Lv%d · 炉%d/%d · %s\n%s x%d · 煤%s · 金%s · 绿洲%s",
            PlantLevel,
            self.SelectedFurnace,
            math.max(FurnaceCount, 1),
            StateTxt,
            tostring(Recipe.Name),
            self.SelectedCount,
            FormatCompactNumber(Status.CoalCount),
            FormatCompactNumber(Status.GoldCount),
            FormatCompactNumber(Status.OasisTicket)
        )
        if PlantLevel < 2 then
            ExtraNotes[#ExtraNotes + 1] = "一级工厂仅可精炼二级粗矿"
        end
    end
    if Status.LastMsg and Status.LastMsg ~= "" then
        local ShortMsg = ShortSmeltMessage(Status.LastMsg)
        if ShortMsg ~= "" then
            ExtraNotes[#ExtraNotes + 1] = ShortMsg
        end
    end
    if #ExtraNotes > 0 then
        Line = Line .. "\n" .. table.concat(ExtraNotes, " | ")
    end
    local PromptText = GetW(Widget, "Txt_Prompt")
    FitPromptText(PromptText)
    SetText(PromptText, Line)
end

--- 显示进入确认按钮；点击后打开建筑 UI
function BP_OreSmeltingFacility:ShowEnterButton()
    if self.bPromptDismissed then
        return
    end
    if self.PromptWidget ~= nil or self.bPromptOpening then
        return
    end
    if EnterButtonManager and EnterButtonManager.Show then
        EnterButtonManager.Show('矿石加工厂', function()
            self:ShowPrompt()
        end)
    end
end

function BP_OreSmeltingFacility:ShowPrompt()
    if self.PromptWidget ~= nil or self.bPromptOpening then
        if self.PromptWidget then
            self:RefreshPromptUI()
        end
        return
    end
    if self.bPromptDismissed then
        return
    end
    self.bPromptOpening = true
    self:BindPCCallbacks()

    local Path = UGCGameSystem.GetUGCResourcesFullPath(PROMPT_UI_PATH)
    UGCWidgetManagerSystem.CreateWidgetAsync(Path, function(Widget)
        self.bPromptOpening = false
        if not Widget then
            ugcprint("[SmeltFacility] 提示 UI 创建失败")
            return
        end
        if not self.bLocalPlayerInside or self.bPromptDismissed then
            if Widget.RemoveFromParent then
                pcall(function()
                    Widget:RemoveFromParent()
                end)
            end
            return
        end
        if self.PromptWidget ~= nil then
            if Widget.RemoveFromParent then
                pcall(function()
                    Widget:RemoveFromParent()
                end)
            end
            return
        end

        self.PromptWidget = Widget
        UGCWidgetManagerSystem.AddToSlot(Widget, "UI.UISlot.MainUISlot_High")
        if Widget.ApplyPromptLayout then
            pcall(function()
                Widget:ApplyPromptLayout()
            end)
        end

        local Facility = self
        if Widget.SetShopCallbacks then
            Widget:SetShopCallbacks({
                OnUnlock = function()
                    Facility:OnMetaClicked()
                end,
                OnEnter = function()
                    Facility:OnFurnaceUpgradeOrCountClicked()
                end,
                OnQuick = function()
                    Facility:OnActionClicked()
                end,
                OnManual = function()
                    Facility:OnCycleClicked()
                end,
                OnClose = function()
                    Facility:OnCloseOrPaymentClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[SmeltFacility] 加工厂面板已显示")
    end)
end

function BP_OreSmeltingFacility:HidePrompt()
    self.bPromptOpening = false
    self:UnbindPCCallbacks()
    local Widget = self.PromptWidget
    self.PromptWidget = nil
    if Widget == nil then
        return
    end
    if Widget.SetShopCallbacks then
        pcall(function()
            Widget:SetShopCallbacks(nil)
        end)
    end
    if Widget.RemoveFromParent then
        pcall(function()
            Widget:RemoveFromParent()
        end)
    end
end

function BP_OreSmeltingFacility:OnCloseClicked()
    self.bPromptDismissed = true
    self:HidePrompt()
end

function BP_OreSmeltingFacility:OnCloseOrPaymentClicked()
    local Status = self:GetStatus()
    if IsPaymentSwitchAvailable(Status) then
        self.PayType = (self.PayType == 0) and 1 or 0
        self:RefreshPromptUI()
        return
    end
    self:OnCloseClicked()
end

function BP_OreSmeltingFacility:OnMetaClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Status = self:GetStatus()
    if not Status.bUnlocked then
        if PC.RequestUnlockSmeltingPlant then
            PC:RequestUnlockSmeltingPlant()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockSmeltingPlant")
        end
        return
    end
    local PlantLevel = math.floor(tonumber(Status.PlantLevel) or 1)
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    if FurnaceCount >= 5 then
        if PlantLevel < 2 then
            if PC.RequestUpgradeSmeltingPlant then
                PC:RequestUpgradeSmeltingPlant()
            else
                UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UpgradeSmeltingPlant")
            end
        end
        return
    end
    local Next = FurnaceCount + 1
    local Cost = SmeltingConfig.GetFurnaceCost(Next)
    local PayType = self.PayType
    if Cost and Cost.Gold == nil then
        PayType = 1
    end
    if PC.RequestUnlockFurnace then
        PC:RequestUnlockFurnace(Next, PayType)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockFurnace", Next, PayType)
    end
end

function BP_OreSmeltingFacility:OnActionClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Status = self:GetStatus()
    if not Status.bUnlocked then
        return
    end
    local Slot = (Status.Slots and Status.Slots[self.SelectedFurnace]) or {}
    local State = math.floor(tonumber(Slot.State) or 0)
    local Furnace = self.SelectedFurnace

    if State == SMELT_STATE_RUNNING then
        if PC.RequestSkipSmelt then
            PC:RequestSkipSmelt(Furnace)
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SkipSmelt", Furnace)
        end
        return
    end
    if State == SMELT_STATE_READY then
        if PC.RequestCollectSmelt then
            PC:RequestCollectSmelt(Furnace)
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_CollectSmelt", Furnace)
        end
        return
    end
    if PC.RequestStartSmelt then
        PC:RequestStartSmelt(Furnace, self.SelectedOreId, self.SelectedCount)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_StartSmelt", Furnace, self.SelectedOreId, self.SelectedCount)
    end
end

function BP_OreSmeltingFacility:OnCycleClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local Status = self:GetStatus()
    if not Status.bUnlocked then
        return
    end
    local PlantLevel = math.floor(tonumber(Status.PlantLevel) or 1)
    self.SelectedOreId = SmeltingConfig.NextRecipeId(self.SelectedOreId, PlantLevel)
    self:RefreshPromptUI()
end

function BP_OreSmeltingFacility:OnCountClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local Status = self:GetStatus()
    if not Status.bUnlocked then
        return
    end
    self.SelectedCount = SmeltingConfig.NextCount(self.SelectedCount)
    self:RefreshPromptUI()
end

function BP_OreSmeltingFacility:OnFurnaceClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local Status = self:GetStatus()
    if not Status.bUnlocked then
        return
    end
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    if FurnaceCount <= 1 then
        return
    end
    self.SelectedFurnace = math.floor(tonumber(self.SelectedFurnace) or 1) + 1
    if self.SelectedFurnace > FurnaceCount then
        self.SelectedFurnace = 1
    end
    self:RefreshPromptUI()
end

function BP_OreSmeltingFacility:OnFurnaceUpgradeOrCountClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local Status = self:GetStatus()
    if not Status.bUnlocked then
        return
    end
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    if FurnaceCount > 1 then
        self:OnFurnaceClicked()
        return
    end
    local PlantLevel = math.floor(tonumber(Status.PlantLevel) or 1)
    if PlantLevel < 2 then
        local PC = GetLocalPC()
        if PC == nil then
            return
        end
        if PC.RequestUpgradeSmeltingPlant then
            PC:RequestUpgradeSmeltingPlant()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UpgradeSmeltingPlant")
        end
        return
    end
    self:OnCountClicked()
end

return BP_OreSmeltingFacility
