---@class BP_VehicleRepairFacility_C:BP_MineTeleportHall_C
---@field BuildingMesh UStaticMeshComponent
---@field InteractTrigger USphereComponent
---@field PromptAnchor USceneComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 采矿车维修处：解锁后对返程采矿车进行损坏判定和维修。
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
            GetVehicle = function(VehicleId)
                local Map = {
                    [1] = { ItemId = 8310025, Name = "初级采矿车", RangeText = "3x3", MineLevel = 2 },
                    [2] = { ItemId = 8310024, Name = "中级采矿车", RangeText = "5x5", MineLevel = 4 },
                    [3] = { ItemId = 8310023, Name = "高级采矿车", RangeText = "7x7", MineLevel = 5 },
                }
                local Id = math.floor(tonumber(VehicleId) or 0)
                return Map[Id], Id
            end,
        }
    end
end

local BP_VehicleRepairFacility = {
    bLocalPlayerInside = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedVehicleId = 1,
    RefreshTimer = nil,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"

local function IsLocalPlayerPawn(OtherActor)
    if OtherActor == nil then
        return false
    end
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    return LocalPawn ~= nil and LocalPawn == OtherActor
end

local function IsLocalPlayerMineCarMode()
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    if LocalPawn ~= nil and LocalPawn.IsMineCarMode then
        local Ok, Result = pcall(function()
            return LocalPawn:IsMineCarMode()
        end)
        if Ok and Result == true then
            return true
        end
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC ~= nil and type(PC.ClientVehicleRepairStateMap) == "table" then
        for _, State in pairs(PC.ClientVehicleRepairStateMap) do
            if math.floor(tonumber(State) or 0) == 1 then
                return true
            end
        end
    end
    return false
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
    local Vis = bShow and ((ESlateVisibility and ESlateVisibility.Visible) or 0)
        or ((ESlateVisibility and ESlateVisibility.Collapsed) or 1)
    pcall(function()
        Widget:SetVisibility(Vis)
    end)
end

local function SetEnabled(Widget, bEnabled)
    if Widget and Widget.SetIsEnabled then
        pcall(function()
            Widget:SetIsEnabled(bEnabled)
        end)
    end
end

function BP_VehicleRepairFacility:ReceiveBeginPlay()
    self.SelectedVehicleId = VehicleRepairConfig.GetFirstVehicleId()

    local Trigger = self.InteractTrigger
    if Trigger == nil then
        ugcprint("[VehicleRepair] InteractTrigger 缺失")
        return
    end
    if self.bOverlapBound then
        return
    end
    self.bOverlapBound = true

    pcall(function()
        Trigger.bGenerateOverlapEvents = true
        if Trigger.SetSphereRadius then
            Trigger:SetSphereRadius(250, true)
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
    ugcprint("[VehicleRepair] Overlap 已绑定")
end

function BP_VehicleRepairFacility:ReceiveEndPlay()
    self:UnbindPCCallbacks()
    self:StopRefreshTimer()
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

function BP_VehicleRepairFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) or self.bLocalPlayerInside or IsLocalPlayerMineCarMode() then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[VehicleRepair] 本机玩家进入采矿车维修处")
    self:ShowPrompt()
end

function BP_VehicleRepairFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    ugcprint("[VehicleRepair] 本机玩家离开采矿车维修处")
    self:HidePrompt()
end

function BP_VehicleRepairFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Facility = self
    PC.OnVehicleRepairNotify = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnVehicleRepairUnlocked = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnVehicleRepairStateChanged = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
end

function BP_VehicleRepairFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    PC.OnVehicleRepairNotify = nil
    PC.OnVehicleRepairUnlocked = nil
    PC.OnVehicleRepairStateChanged = nil
end

function BP_VehicleRepairFacility:StartRefreshTimer()
    self:StopRefreshTimer()
    if UGCTimerUtility == nil or UGCTimerUtility.CreateLuaTimer == nil then
        return
    end
    local Facility = self
    local Ok, Handle = pcall(function()
        return UGCTimerUtility.CreateLuaTimer(1.0, function()
            if Facility.bLocalPlayerInside and Facility.PromptWidget ~= nil then
                if IsLocalPlayerMineCarMode() then
                    Facility:HidePrompt()
                    return
                end
                Facility:RefreshPromptUI()
            end
        end, true)
    end)
    if Ok then
        self.RefreshTimer = Handle
    end
end

function BP_VehicleRepairFacility:StopRefreshTimer()
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

function BP_VehicleRepairFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetVehicleRepairStatus then
        local Ok, Status = pcall(function()
            return PC:GetVehicleRepairStatus(self.SelectedVehicleId)
        end)
        if Ok and type(Status) == "table" then
            return Status
        end
    end
    local Vehicle = VehicleRepairConfig.GetVehicle(self.SelectedVehicleId) or {}
    return {
        bUnlocked = PC and PC.bVehicleRepairUnlocked == true,
        UnlockCost = VehicleRepairConfig.UnlockCost or 5000,
        RepairCost = VehicleRepairConfig.RepairCost or 1000,
        DamageChance = VehicleRepairConfig.DamageChance or 10,
        GoldCount = 0,
        VehicleId = self.SelectedVehicleId,
        VehicleName = Vehicle.Name or "?",
        RangeText = Vehicle.RangeText or "",
        MineLevel = Vehicle.MineLevel or 0,
        OwnedCount = 0,
        VehicleState = 0,
        bActive = false,
        bPendingCheck = false,
        bBroken = false,
        LastMsg = PC and PC.VehicleRepairLastMsg or "",
    }
end

function BP_VehicleRepairFacility:ApplyLabels(Widget, Status)
    if Widget == nil then
        return
    end
    Status = Status or {}
    local VehicleName = tostring(Status.VehicleName or "?")

    local MainTxt
    if Status.bUnlocked ~= true then
        MainTxt = string.format("解锁维修处 (%d金)", tonumber(Status.UnlockCost) or 5000)
    elseif Status.bBroken == true then
        MainTxt = string.format("维修%s (%d金)", VehicleName, tonumber(Status.RepairCost) or 1000)
    else
        MainTxt = "返程检查"
    end

    if Status.bUnlocked == true and Status.bBroken ~= true then
        if Status.bPendingCheck == true then
            MainTxt = "返程检查"
        elseif Status.bActive == true then
            MainTxt = "车辆使用中"
        else
            MainTxt = "状态良好"
        end
    end

    SetText(GetW(Widget, "Txt_Unlock"), MainTxt)
    SetText(GetW(Widget, "Txt_Quick"), "车辆·" .. VehicleName)
    SetText(GetW(Widget, "Txt_Manual"), "打开背包")
    SetText(GetW(Widget, "Txt_Close"), "关闭")
end

function BP_VehicleRepairFacility:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end
    local Status = self:GetStatus()

    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState({
                bUnlocked = true,
                JadeCount = tonumber(Status.OwnedCount) or 0,
                GoldCount = tonumber(Status.GoldCount) or 0,
                QuickCost = 0,
                LastMsg = "",
            })
        end)
    end

    SetVisible(GetW(Widget, "Btn_Unlock"), true)
    SetVisible(GetW(Widget, "Gap_Unlock"), true)
    SetVisible(GetW(Widget, "Btn_Quick"), Status.bUnlocked == true)
    SetVisible(GetW(Widget, "Gap_Quick"), Status.bUnlocked == true)
    SetVisible(GetW(Widget, "Btn_Manual"), Status.bUnlocked == true)
    SetVisible(GetW(Widget, "Gap_Manual"), Status.bUnlocked == true)

    local CanMain = true
    if Status.bUnlocked ~= true then
        CanMain = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.UnlockCost) or 5000)
    elseif (tonumber(Status.OwnedCount) or 0) <= 0 then
        CanMain = false
    elseif Status.bBroken == true then
        CanMain = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.RepairCost) or 1000)
    end
    if Status.bUnlocked == true and Status.bBroken ~= true and Status.bPendingCheck ~= true then
        CanMain = false
    end

    SetEnabled(GetW(Widget, "Btn_Unlock"), CanMain)
    SetEnabled(GetW(Widget, "Btn_Quick"), Status.bUnlocked == true)
    SetEnabled(GetW(Widget, "Btn_Manual"), Status.bUnlocked == true)
    self:ApplyLabels(Widget, Status)

    local StateText = Status.bBroken == true and "已损坏" or "状态良好"
    if Status.bBroken == true then
        StateText = "已损坏"
    elseif Status.bPendingCheck == true then
        StateText = "待返程检查"
    elseif Status.bActive == true then
        StateText = "使用中"
    else
        StateText = "可使用"
    end
    local Line
    if Status.bUnlocked ~= true then
        Line = string.format("采矿车维修处 · 解锁 %d 金币（当前 %d）", tonumber(Status.UnlockCost) or 5000, tonumber(Status.GoldCount) or 0)
    else
        Line = string.format(
            "采矿车维修处 · %s · %s · %s · 拥有 %d · 返程损坏率 %d%%",
            tostring(Status.VehicleName or "?"),
            tostring(Status.RangeText or ""),
            StateText,
            tonumber(Status.OwnedCount) or 0,
            tonumber(Status.DamageChance) or 10
        )
    end
    if Status.LastMsg and Status.LastMsg ~= "" then
        Line = Line .. "\n" .. tostring(Status.LastMsg)
    end
    SetText(GetW(Widget, "Txt_Prompt"), Line)
end

function BP_VehicleRepairFacility:ShowPrompt()
    if IsLocalPlayerMineCarMode() then
        self:HidePrompt()
        return
    end

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
            ugcprint("[VehicleRepair] 提示 UI 创建失败")
            return
        end
        if not self.bLocalPlayerInside or IsLocalPlayerMineCarMode() then
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
                    Facility:OnMainClicked()
                end,
                OnQuick = function()
                    Facility:OnCycleVehicleClicked()
                end,
                OnManual = function()
                    Facility:OnOpenBackpackClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[VehicleRepair] 采矿车维修处面板已显示")
        self:StartRefreshTimer()
    end)
end

function BP_VehicleRepairFacility:HidePrompt()
    self.bPromptOpening = false
    self:UnbindPCCallbacks()
    self:StopRefreshTimer()
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

function BP_VehicleRepairFacility:OnCloseClicked()
    self:HidePrompt()
end

function BP_VehicleRepairFacility:OnCycleVehicleClicked()
    if not self.bLocalPlayerInside then
        return
    end
    self.SelectedVehicleId = VehicleRepairConfig.NextVehicleId(self.SelectedVehicleId)
    self:RefreshPromptUI()
end

function BP_VehicleRepairFacility:OnMainClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Status = self:GetStatus()
    if Status.bUnlocked ~= true then
        if PC.RequestUnlockVehicleRepair then
            PC:RequestUnlockVehicleRepair()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockVehicleRepair")
        end
    elseif Status.bBroken == true then
        if PC.RequestRepairMiningVehicle then
            PC:RequestRepairMiningVehicle(self.SelectedVehicleId)
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RepairMiningVehicle", self.SelectedVehicleId)
        end
    elseif Status.bPendingCheck == true then
        if PC.RequestCheckVehicleReturn then
            PC:RequestCheckVehicleReturn(self.SelectedVehicleId)
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_CheckVehicleReturn", self.SelectedVehicleId)
        end
    else
        self:RefreshPromptUI()
    end
end

function BP_VehicleRepairFacility:OnOpenBackpackClicked()
    if UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanelStyle then
        UGCBackpackSystemV2.OpenBackpackPanelStyle(nil, 2)
    elseif UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanel then
        UGCBackpackSystemV2.OpenBackpackPanel(2)
    end
    self:HidePrompt()
end

return BP_VehicleRepairFacility
