---@class BP_OreSmeltingFacility_C:AActor
---@field BuildingMesh UStaticMeshComponent
---@field InteractTrigger USphereComponent
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
            DurationSec = 600,
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

local BP_OreSmeltingFacility = {
    bLocalPlayerInside = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedFurnace = 1,
    SelectedOreId = 8310004,
    SelectedCount = 1,
    --- cycle: 1=炉 2=矿 3=数量 4=支付方式(解锁炉)
    FocusMode = 1,
    --- 0=金币 1=绿洲币
    PayType = 0,
    RefreshTimer = nil,
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

local function NowSec()
    return tonumber(os.time()) or 0
end

local function FormatRemain(EndTime)
    local Remain = math.floor((tonumber(EndTime) or 0) - NowSec())
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
    self.FocusMode = 1
    self.PayType = 0

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
        if Trigger.SetGenerateOverlapEvents then
            Trigger:SetGenerateOverlapEvents(true)
        else
            Trigger.bGenerateOverlapEvents = true
        end
        if Trigger.SetSphereRadius then
            Trigger:SetSphereRadius(280)
        elseif Trigger.SphereRadius ~= nil then
            Trigger.SphereRadius = 280
        end
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
    self:StopRefreshTimer()
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
    if self.bLocalPlayerInside then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[SmeltFacility] 本机玩家进入加工厂")
    self:ShowPrompt()
end

function BP_OreSmeltingFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    ugcprint("[SmeltFacility] 本机玩家离开加工厂")
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

function BP_OreSmeltingFacility:StartRefreshTimer()
    self:StopRefreshTimer()
    if UGCTimerUtility == nil or UGCTimerUtility.CreateLuaTimer == nil then
        return
    end
    local Facility = self
    local Ok, Handle = pcall(function()
        return UGCTimerUtility.CreateLuaTimer(1.0, function()
            if Facility.bLocalPlayerInside and Facility.PromptWidget ~= nil then
                Facility:RefreshPromptUI()
            end
        end, true)
    end)
    if Ok then
        self.RefreshTimer = Handle
    end
end

function BP_OreSmeltingFacility:StopRefreshTimer()
    local Handle = self.RefreshTimer
    self.RefreshTimer = nil
    if Handle == nil then
        return
    end
    if UGCTimerUtility and UGCTimerUtility.RemoveLuaTimer then
        pcall(function()
            UGCTimerUtility.RemoveLuaTimer(Handle)
        end)
    end
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
    elseif PlantLevel < 2 then
        UnlockTxt = string.format("升级工厂 (%d)", Status.UpgradeCost or 10000)
    elseif FurnaceCount < 5 then
        local Next = FurnaceCount + 1
        local Cost = SmeltingConfig.GetFurnaceCost(Next) or { Oasis = 100 }
        if self.PayType == 1 or Cost.Gold == nil then
            UnlockTxt = string.format("解锁炉%d (绿洲%d)", Next, Cost.Oasis or 100)
        else
            UnlockTxt = string.format("解锁炉%d (金%d)", Next, Cost.Gold)
        end
    else
        UnlockTxt = "炉位已满"
    end

    local ActionTxt = "开始精炼"
    if State == SMELT_STATE_RUNNING then
        ActionTxt = string.format("跳过 (%d绿洲)", Status.SkipOasisCost or 50)
    elseif State == SMELT_STATE_READY then
        ActionTxt = "收取产物"
    end

    local CycleTxt
    if self.FocusMode == 1 then
        CycleTxt = string.format("切炉·当前%d", self.SelectedFurnace)
    elseif self.FocusMode == 2 then
        CycleTxt = string.format("切矿·%s", tostring(Recipe.Name))
    elseif self.FocusMode == 3 then
        CycleTxt = string.format("切量·x%d", self.SelectedCount)
    else
        CycleTxt = (self.PayType == 1) and "支付·绿洲币" or "支付·金币"
    end

    SetText(GetW(Widget, "Txt_Unlock"), UnlockTxt)
    SetText(GetW(Widget, "Txt_Quick"), ActionTxt)
    SetText(GetW(Widget, "Txt_Manual"), CycleTxt)
    SetText(GetW(Widget, "Txt_Close"), "关闭")
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
    self:ApplyLabels(Widget, Status)

    local PlantLevel = math.floor(tonumber(Status.PlantLevel) or 1)
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    local Recipe = SmeltingConfig.GetRecipe(self.SelectedOreId) or { Name = "?" }
    local Slot = (Status.Slots and Status.Slots[self.SelectedFurnace]) or {}
    local State = math.floor(tonumber(Slot.State) or 0)
    local StateTxt = "空闲"
    if State == SMELT_STATE_RUNNING then
        StateTxt = "精炼中 " .. FormatRemain(Slot.EndTime)
    elseif State == SMELT_STATE_READY then
        StateTxt = "可收取"
    end

    local Line
    if not bUnlocked then
        Line = string.format(
            "矿石加工厂 · 解锁 %d 金币（当前 %d）",
            Status.UnlockCost or 10000,
            Status.GoldCount or 0
        )
    else
        Line = string.format(
            "加工厂 Lv%d · 炉%d/%d[%s] · %s x%d · 煤%d · 金%d · 绿洲%d",
            PlantLevel,
            self.SelectedFurnace,
            math.max(FurnaceCount, 1),
            StateTxt,
            tostring(Recipe.Name),
            self.SelectedCount,
            Status.CoalCount or 0,
            Status.GoldCount or 0,
            Status.OasisTicket or 0
        )
        if PlantLevel < 2 then
            Line = Line .. " · 一级仅可炼二级矿"
        end
    end
    if Status.LastMsg and Status.LastMsg ~= "" then
        Line = Line .. "\n" .. tostring(Status.LastMsg)
    end
    SetText(GetW(Widget, "Txt_Prompt"), Line)
end

function BP_OreSmeltingFacility:ShowPrompt()
    if self.PromptWidget ~= nil or self.bPromptOpening then
        if self.PromptWidget then
            self:RefreshPromptUI()
        end
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
        if not self.bLocalPlayerInside then
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
                OnQuick = function()
                    Facility:OnActionClicked()
                end,
                OnManual = function()
                    Facility:OnCycleClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        self:StartRefreshTimer()
        ugcprint("[SmeltFacility] 加工厂面板已显示")
    end)
end

function BP_OreSmeltingFacility:HidePrompt()
    self.bPromptOpening = false
    self:StopRefreshTimer()
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
    self:HidePrompt()
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
    if PlantLevel < 2 then
        if PC.RequestUpgradeSmeltingPlant then
            PC:RequestUpgradeSmeltingPlant()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UpgradeSmeltingPlant")
        end
        return
    end
    local FurnaceCount = math.floor(tonumber(Status.FurnaceCount) or 0)
    if FurnaceCount >= 5 then
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
    local FurnaceCount = math.max(math.floor(tonumber(Status.FurnaceCount) or 1), 1)

    -- 线性轮换：炉 → 矿 → 量 → 支付，每项内部先滚完再进下一项
    if self.FocusMode == 1 then
        self.SelectedFurnace = self.SelectedFurnace + 1
        if self.SelectedFurnace > FurnaceCount then
            self.SelectedFurnace = 1
            self.FocusMode = 2
        end
    elseif self.FocusMode == 2 then
        local Old = self.SelectedOreId
        local First = SmeltingConfig.FirstRecipeId(PlantLevel)
        self.SelectedOreId = SmeltingConfig.NextRecipeId(Old, PlantLevel)
        if self.SelectedOreId == First then
            self.FocusMode = 3
        end
    elseif self.FocusMode == 3 then
        local Old = self.SelectedCount
        self.SelectedCount = SmeltingConfig.NextCount(Old)
        if self.SelectedCount == 1 or self.SelectedCount <= Old then
            self.FocusMode = 4
        end
    else
        self.PayType = (self.PayType == 0) and 1 or 0
        if self.PayType == 0 then
            self.FocusMode = 1
        end
    end
    self:RefreshPromptUI()
end

return BP_OreSmeltingFacility
