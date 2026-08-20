---@class BP_JadeCollectionRoomFacility_C:AActor
---@field InteractTrigger UDragonBoatBoxTriggerComponent
---@field BuildingMesh UStaticMeshComponent
---@field PromptAnchor USceneComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local EnterButtonManager = nil
do
    local ok, mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.Common.EnterButtonManager')
    end)
    if ok and type(mod) == 'table' then EnterButtonManager = mod else EnterButtonManager = {} end
end

local BP_JadeCollectionRoomFacility = {
    bLocalPlayerInside = false,
    bPromptDismissed = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedSlot = 1,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"
local INTERACT_RADIUS = 250

local function IsLocalPlayerPawn(OtherActor)
    if OtherActor == nil then
        return false
    end
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    return LocalPawn ~= nil and LocalPawn == OtherActor
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
            Widget:SetText(tostring(Text or ""))
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

local function SetEnabled(Widget, bEnabled)
    if Widget and Widget.SetIsEnabled then
        pcall(function()
            Widget:SetIsEnabled(bEnabled == true)
        end)
    end
end

local function GetDisplayStateName(Status)
    Status = Status or {}
    if Status.CurrentStateName and tostring(Status.CurrentStateName) ~= "" then
        return tostring(Status.CurrentStateName)
    end
    local Display = Status.CurrentDisplay or {}
    local State = math.floor(tonumber(Display.State) or 0)
    if State == 1 then
        return "未鉴定玉石"
    end
    if State == 2 then
        local Opened = math.floor(tonumber(Display.OpenedCount) or 0)
        local Total = math.floor(tonumber(Display.TotalCells) or 25)
        if Total > 0 and Opened >= Total then
            return "完全鉴定玉石"
        end
        return "未完全鉴定玉石"
    end
    return "空展台"
end

function BP_JadeCollectionRoomFacility:ReceiveBeginPlay()

    local Trigger = self.InteractTrigger
    if Trigger == nil then
        ugcprint("[JadeCollectionRoom] InteractTrigger missing")
        return
    end
    if self.bOverlapBound then
        return
    end
    self.bOverlapBound = true

    pcall(function()
        Trigger.bGenerateOverlapEvents = true
    end)

    if Trigger.OnComponentBeginOverlap then
        Trigger.OnComponentBeginOverlap:Add(self.OnTriggerBeginOverlap, self)
    end
    if Trigger.OnComponentEndOverlap then
        Trigger.OnComponentEndOverlap:Add(self.OnTriggerEndOverlap, self)
    end
    ugcprint("[JadeCollectionRoom] Overlap bound")
end

function BP_JadeCollectionRoomFacility:ReceiveEndPlay()
    self:UnbindPCCallbacks()
    local Trigger = self.InteractTrigger
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

function BP_JadeCollectionRoomFacility:OnTriggerBeginOverlap(
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
    self:ShowEnterButton()
end

function BP_JadeCollectionRoomFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    self.bPromptDismissed = false
    EnterButtonManager.Hide(GetLocalPC())
    self:HidePrompt()
end

function BP_JadeCollectionRoomFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local Facility = self
    PC.OnJadeCollectionNotify = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnJadeCollectionSync = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
end

function BP_JadeCollectionRoomFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    PC.OnJadeCollectionNotify = nil
    PC.OnJadeCollectionSync = nil
end

function BP_JadeCollectionRoomFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetJadeCollectionStatus then
        local Ok, Status = pcall(function()
            return PC:GetJadeCollectionStatus(self.SelectedSlot)
        end)
        if Ok and type(Status) == "table" then
            return Status
        end
    end
    return {
        bUnlocked = true,
        SlotCount = 5,
        SelectedSlot = self.SelectedSlot,
        CurrentDisplay = { State = 0, Value = 0, OwnerName = "", OpenedCount = 0, TotalCells = 25 },
        CurrentStateName = "空展台",
        RawJadeCount = 0,
        bHasCandidate = false,
        CandidateValue = 0,
        CandidateOpenedCount = 0,
        CandidateTotalCells = 25,
        LastMsg = PC and PC.JadeCollectionLastMsg or "",
    }
end

function BP_JadeCollectionRoomFacility:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end

    local Status = self:GetStatus()
    local Display = Status.CurrentDisplay or {}
    local State = math.floor(tonumber(Display.State) or 0)
    local bOccupied = State ~= 0
    local Slot = math.floor(tonumber(Status.SelectedSlot) or self.SelectedSlot or 1)
    local SlotCount = math.max(1, math.floor(tonumber(Status.SlotCount) or 5))
    local RawCount = math.floor(tonumber(Status.RawJadeCount) or tonumber(Status.JadeCount) or 0)
    local Value = math.floor(tonumber(Display.Value) or 0)
    local OwnerName = tostring(Display.OwnerName or "")
    local Opened = math.floor(tonumber(Display.OpenedCount) or 0)
    local Total = math.max(1, math.floor(tonumber(Display.TotalCells) or 25))
    local bHasCandidate = Status.bHasCandidate == true

    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState({
                bUnlocked = true,
                JadeCount = math.max(1, RawCount),
                GoldCount = 0,
                QuickCost = 0,
                LastMsg = "",
            })
        end)
    end

    SetVisible(GetW(Widget, "Btn_Unlock"), true)
    SetVisible(GetW(Widget, "Gap_Unlock"), true)
    SetVisible(GetW(Widget, "Btn_Quick"), true)
    SetVisible(GetW(Widget, "Gap_Quick"), true)
    SetVisible(GetW(Widget, "Btn_Manual"), true)
    SetVisible(GetW(Widget, "Gap_Manual"), true)
    SetVisible(GetW(Widget, "Btn_Close"), true)
    SetVisible(GetW(Widget, "Gap_Close"), true)

    SetText(GetW(Widget, "Txt_Unlock"), bOccupied and "取回玉石" or string.format("放入玉矿石 x%d", RawCount))
    SetText(GetW(Widget, "Txt_Quick"), bHasCandidate and "展示鉴定玉石" or "无鉴定记录")
    SetText(GetW(Widget, "Txt_Manual"), string.format("切换展台 %d/%d", Slot, SlotCount))
    SetText(GetW(Widget, "Txt_Close"), "关闭")

    local PrimaryText = string.format("放入玉石原石 x%d", RawCount)
    if bOccupied then
        if State == 2 then
            PrimaryText = string.format("出售鉴定玉石 +%d金", Value)
        else
            PrimaryText = "取回玉石原石"
        end
    end
    SetText(GetW(Widget, "Txt_Unlock"), PrimaryText)

    SetEnabled(GetW(Widget, "Btn_Unlock"), bOccupied or RawCount > 0)
    SetEnabled(GetW(Widget, "Btn_Quick"), (not bOccupied) and bHasCandidate)
    SetEnabled(GetW(Widget, "Btn_Manual"), SlotCount > 1)
    SetEnabled(GetW(Widget, "Btn_Close"), true)

    local Line = string.format("玉石收藏室 · 展台 %d/%d · %s", Slot, SlotCount, GetDisplayStateName(Status))
    if bOccupied then
        Line = Line .. string.format("\n当前价格：%d 金币 · 所有者：%s", Value, OwnerName ~= "" and OwnerName or "玩家")
        if State == 2 then
            Line = Line .. string.format(" · 鉴定 %d/%d", Opened, Total)
        end
    else
        Line = Line .. string.format("\n背包玉石：%d", RawCount)
        if bHasCandidate then
            Line = Line .. string.format(" · 可展示鉴定价：%d 金币", math.floor(tonumber(Status.CandidateValue) or 0))
        end
    end
    if Status.LastMsg and tostring(Status.LastMsg) ~= "" then
        Line = Line .. "\n" .. tostring(Status.LastMsg)
    end
    SetText(GetW(Widget, "Txt_Prompt"), Line)
end

--- 显示进入确认按钮；点击后打开建筑 UI
function BP_JadeCollectionRoomFacility:ShowEnterButton()
    if self.bPromptDismissed then
        return
    end
    if self.PromptWidget ~= nil or self.bPromptOpening then
        return
    end
    if EnterButtonManager and EnterButtonManager.Show then
        EnterButtonManager.Show('玉石收藏室', function()
            self:ShowPrompt()
        end)
    end
end

function BP_JadeCollectionRoomFacility:ShowPrompt()
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
            ugcprint("[JadeCollectionRoom] prompt create failed")
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
                    Facility:OnPrimaryClicked()
                end,
                OnQuick = function()
                    Facility:OnPlaceAppraisedClicked()
                end,
                OnManual = function()
                    Facility:OnCycleSlotClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end

        local PC = GetLocalPC()
        if PC and PC.RequestSyncJadeCollection then
            PC:RequestSyncJadeCollection()
        end
        self:RefreshPromptUI()
        ugcprint("[JadeCollectionRoom] prompt shown")
    end)
end

function BP_JadeCollectionRoomFacility:HidePrompt()
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

function BP_JadeCollectionRoomFacility:OnCloseClicked()
    self.bPromptDismissed = true
    self:HidePrompt()
end

function BP_JadeCollectionRoomFacility:OnPrimaryClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Status = self:GetStatus()
    local Display = Status.CurrentDisplay or {}
    local State = math.floor(tonumber(Display.State) or 0)
    if State ~= 0 then
        if PC.RequestClearJadeCollectionSlot then
            PC:RequestClearJadeCollectionSlot(self.SelectedSlot)
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ClearJadeCollectionSlot", self.SelectedSlot)
        end
        return
    end
    if PC.RequestPlaceRawJadeInCollection then
        PC:RequestPlaceRawJadeInCollection(self.SelectedSlot)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_PlaceRawJadeInCollection", self.SelectedSlot)
    end
end

function BP_JadeCollectionRoomFacility:OnPlaceAppraisedClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    if PC.RequestPlaceManualJadeInCollection then
        PC:RequestPlaceManualJadeInCollection(self.SelectedSlot)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_PlaceManualJadeInCollection", self.SelectedSlot)
    end
end

function BP_JadeCollectionRoomFacility:OnCycleSlotClicked()
    local Status = self:GetStatus()
    local SlotCount = math.max(1, math.floor(tonumber(Status.SlotCount) or 5))
    self.SelectedSlot = math.floor(tonumber(self.SelectedSlot) or 1) + 1
    if self.SelectedSlot > SlotCount then
        self.SelectedSlot = 1
    end
    self:RefreshPromptUI()
end

return BP_JadeCollectionRoomFacility
