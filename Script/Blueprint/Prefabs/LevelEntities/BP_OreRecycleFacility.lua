---@class BP_OreRecycleFacility_C:AActor
---@field BuildingMesh UStaticMeshComponent
---@field InteractTrigger USphereComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 矿石回收处：初始自动解锁；复用鉴定所 Prompt UI
--- 切量 / 回收 / 切矿 / 关闭
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
            CountPresets = { 1, 5, 10, 25, 50, -1 },
            Prices = {
                [8310000] = { Name = "石头", Price = 50 },
                [8310003] = { Name = "煤矿", Price = 75 },
                [8310004] = { Name = "粗铁矿", Price = 100 },
                [8310011] = { Name = "玉矿石（未鉴定）", Price = 600 },
            },
            ItemOrder = { 8310000, 8310003, 8310004, 8310011 },
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
            NextItemId = function(CurrentId)
                local Order = OreRecycleConfig.ItemOrder
                local Start = 1
                local Cur = tonumber(CurrentId) or 0
                for i, Id in ipairs(Order) do
                    if Id == Cur then
                        Start = i + 1
                        break
                    end
                end
                return Order[((Start - 1) % #Order) + 1]
            end,
            NextCount = function(Current)
                local Presets = OreRecycleConfig.CountPresets
                local Cur = math.floor(tonumber(Current) or 1)
                for i, V in ipairs(Presets) do
                    if V == Cur then
                        return Presets[(i % #Presets) + 1]
                    end
                end
                return Presets[1]
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

local BP_OreRecycleFacility = {
    bLocalPlayerInside = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedItemId = 8310000,
    SelectedCount = 1,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"

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
    if not Widget or not Widget.SetVisibility then
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

local function FormatCount(Count)
    Count = math.floor(tonumber(Count) or 0)
    if Count < 0 then
        return "全部"
    end
    return "x" .. tostring(Count)
end

function BP_OreRecycleFacility:ReceiveBeginPlay()
    -- 不调用传送大厅父类 BeginPlay，避免绑定传送逻辑
    self.SelectedItemId = OreRecycleConfig.ItemOrder[1] or 8310000
    self.SelectedCount = 1

    local Trigger = GetInteractTrigger(self)
    if Trigger == nil then
        ugcprint("[OreRecycle] InteractTrigger 缺失")
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
            Trigger:SetSphereRadius(250)
        elseif Trigger.SphereRadius ~= nil then
            Trigger.SphereRadius = 250
        end
    end)

    if Trigger.OnComponentBeginOverlap then
        Trigger.OnComponentBeginOverlap:Add(self.OnTriggerBeginOverlap, self)
    end
    if Trigger.OnComponentEndOverlap then
        Trigger.OnComponentEndOverlap:Add(self.OnTriggerEndOverlap, self)
    end
    ugcprint("[OreRecycle] Overlap 已绑定")
end

function BP_OreRecycleFacility:ReceiveEndPlay()
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
end

function BP_OreRecycleFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    if self.bLocalPlayerInside then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[OreRecycle] 本机玩家进入回收处")
    self:ShowPrompt()
end

function BP_OreRecycleFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    ugcprint("[OreRecycle] 本机玩家离开回收处")
    self:HidePrompt()
end

function BP_OreRecycleFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local Facility = self
    PC.OnOreRecycleNotify = function(Msg)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
end

function BP_OreRecycleFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    PC.OnOreRecycleNotify = nil
end

function BP_OreRecycleFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetOreRecycleStatus then
        local Ok, Status = pcall(function()
            return PC:GetOreRecycleStatus(self.SelectedItemId)
        end)
        if Ok and type(Status) == "table" then
            return Status
        end
    end
    return {
        GoldCount = 0,
        OwnedCount = 0,
        UnitPrice = OreRecycleConfig.GetPrice(self.SelectedItemId) or 0,
        ItemName = OreRecycleConfig.GetName(self.SelectedItemId),
        LastMsg = PC and PC.OreRecycleLastMsg or "",
    }
end

function BP_OreRecycleFacility:ApplyLabels(Widget, Status)
    if Widget == nil then
        return
    end
    Status = Status or {}
    local Name = tostring(Status.ItemName or OreRecycleConfig.GetName(self.SelectedItemId))
    local UnitPrice = math.floor(tonumber(Status.UnitPrice) or 0)
    local Owned = math.floor(tonumber(Status.OwnedCount) or 0)
    local SellCount = OreRecycleConfig.ResolveSellCount(Owned, self.SelectedCount)
    local Gain = SellCount * UnitPrice

    SetText(GetW(Widget, "Txt_Unlock"), "切换数量 " .. FormatCount(self.SelectedCount))
    if SellCount > 0 then
        SetText(GetW(Widget, "Txt_Quick"), string.format("回收 %s%s (+%d)", Name, FormatCount(SellCount), Gain))
    else
        SetText(GetW(Widget, "Txt_Quick"), string.format("回收 %s（库存不足）", Name))
    end
    SetText(GetW(Widget, "Txt_Manual"), "切换矿石")
    SetText(GetW(Widget, "Txt_Close"), "关闭")
end

function BP_OreRecycleFacility:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end
    local Status = self:GetStatus()
    local Owned = math.floor(tonumber(Status.OwnedCount) or 0)
    local SellCount = OreRecycleConfig.ResolveSellCount(Owned, self.SelectedCount)
    local UnitPrice = math.floor(tonumber(Status.UnitPrice) or 0)
    local Gain = SellCount * UnitPrice

    -- 借用鉴定 UI：始终已解锁；显示切量/回收/切矿
    local FakeStatus = {
        bUnlocked = true,
        JadeCount = 1,
        GoldCount = tonumber(Status.GoldCount) or 0,
        QuickCost = 0,
        LastMsg = "",
    }
    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState(FakeStatus)
        end)
    end

    -- 强制显示「切量」按钮（鉴定 UI 解锁后会隐藏 Unlock）
    SetVisible(GetW(Widget, "Btn_Unlock"), true)
    SetVisible(GetW(Widget, "Gap_Unlock"), true)
    SetVisible(GetW(Widget, "Btn_Quick"), true)
    SetVisible(GetW(Widget, "Gap_Quick"), true)
    SetVisible(GetW(Widget, "Btn_Manual"), true)
    SetVisible(GetW(Widget, "Gap_Manual"), true)

    local BtnQuick = GetW(Widget, "Btn_Quick")
    if BtnQuick and BtnQuick.SetIsEnabled then
        pcall(function()
            BtnQuick:SetIsEnabled(SellCount > 0)
        end)
    end
    local BtnManual = GetW(Widget, "Btn_Manual")
    if BtnManual and BtnManual.SetIsEnabled then
        pcall(function()
            BtnManual:SetIsEnabled(true)
        end)
    end
    local BtnUnlock = GetW(Widget, "Btn_Unlock")
    if BtnUnlock and BtnUnlock.SetIsEnabled then
        pcall(function()
            BtnUnlock:SetIsEnabled(true)
        end)
    end

    self:ApplyLabels(Widget, Status)

    local Line = string.format(
        "矿石回收处 · %s 单价 %d · 持有 %d · 本次 %s → +%d 金（余额 %d）",
        tostring(Status.ItemName or "?"),
        UnitPrice,
        Owned,
        FormatCount(self.SelectedCount),
        Gain,
        tonumber(Status.GoldCount) or 0
    )
    if Status.LastMsg and Status.LastMsg ~= "" then
        Line = Line .. "\n" .. tostring(Status.LastMsg)
    end
    SetText(GetW(Widget, "Txt_Prompt"), Line)
end

function BP_OreRecycleFacility:ShowPrompt()
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
            ugcprint("[OreRecycle] 提示 UI 创建失败")
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
                    Facility:OnCycleCountClicked()
                end,
                OnQuick = function()
                    Facility:OnSellClicked()
                end,
                OnManual = function()
                    Facility:OnCycleItemClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[OreRecycle] 回收处面板已显示")
    end)
end

function BP_OreRecycleFacility:HidePrompt()
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

function BP_OreRecycleFacility:OnCloseClicked()
    self:HidePrompt()
end

function BP_OreRecycleFacility:OnCycleCountClicked()
    if not self.bLocalPlayerInside then
        return
    end
    self.SelectedCount = OreRecycleConfig.NextCount(self.SelectedCount)
    ugcprint("[OreRecycle] 切换数量 -> " .. FormatCount(self.SelectedCount))
    self:RefreshPromptUI()
end

function BP_OreRecycleFacility:OnCycleItemClicked()
    if not self.bLocalPlayerInside then
        return
    end
    self.SelectedItemId = OreRecycleConfig.NextItemId(self.SelectedItemId)
    ugcprint("[OreRecycle] 切换矿石 -> " .. tostring(self.SelectedItemId) .. " " .. OreRecycleConfig.GetName(self.SelectedItemId))
    self:RefreshPromptUI()
end

function BP_OreRecycleFacility:OnSellClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local ItemId = self.SelectedItemId
    local Count = self.SelectedCount
    ugcprint("[OreRecycle] 请求回收 ItemId=" .. tostring(ItemId) .. " Count=" .. tostring(Count))
    if PC.RequestRecycleOre then
        PC:RequestRecycleOre(ItemId, Count)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RecycleOre", ItemId, Count)
    end
end

return BP_OreRecycleFacility
