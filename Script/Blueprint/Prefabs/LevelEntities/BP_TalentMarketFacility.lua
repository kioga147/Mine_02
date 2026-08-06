---@class BP_TalentMarketFacility_C:BP_MineTeleportHall_C
---@field BuildingMesh UStaticMeshComponent
---@field InteractTrigger USphereComponent
---@field PromptAnchor USceneComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 人才市场：解锁后雇佣矿工，完成后领取随机矿物。
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
            GetWorker = function(WorkerId)
                local Map = {
                    [1] = { Name = "低级工人", HireCost = 1000, DurationSec = 1800, RewardCount = 50, MinMineLevel = 1, MaxMineLevel = 3 },
                    [2] = { Name = "中级工人", HireCost = 10000, DurationSec = 1800, RewardCount = 100, MinMineLevel = 1, MaxMineLevel = 4 },
                    [3] = { Name = "高级矿工", HireCost = 100000, DurationSec = 900, RewardCount = 200, MinMineLevel = 3, MaxMineLevel = 5 },
                }
                return Map[math.floor(tonumber(WorkerId) or 0)]
            end,
            FormatDuration = function(DurationSec)
                return tostring(math.floor((tonumber(DurationSec) or 0) / 60)) .. "分钟"
            end,
        }
    end
end

local BP_TalentMarketFacility = {
    bLocalPlayerInside = false,
    bPromptDismissed = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedWorkerId = 1,
    RefreshTimer = nil,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"
local JOB_IDLE = 0
local JOB_RUNNING = 1
local JOB_READY = 2

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
            Widget:SetWrapTextAt(1180)
        end)
    end
    if Widget.SetClipping then
        pcall(function()
            Widget:SetClipping(1)
        end)
    end
    if Widget.SetRenderScale then
        pcall(function()
            Widget:SetRenderScale({ X = 0.88, Y = 0.88 })
        end)
    end
end

local function ShortTalentMessage(Msg)
    Msg = tostring(Msg or "")
    if Msg == "" then
        return ""
    end
    local Remain = string.match(Msg, "剩余(%d+)个")
    if Remain ~= nil then
        return "背包未装完：剩余" .. tostring(Remain) .. "个，清理后再领取"
    end
    if string.find(Msg, "已放入背包", 1, true) then
        return "领取成功：矿物已放入背包"
    end
    if string.find(Msg, "已存入仓库", 1, true) then
        return "领取成功：矿物已存入仓库"
    end
    if string.find(Msg, "带回", 1, true) and string.find(Msg, "矿物：", 1, true) then
        return "领取成功：矿物已放入背包"
    end
    return Msg
end

local function ColorToHexRGB(C)
    local function Byte(V)
        local N = math.floor((V or 0) * 255 + 0.5)
        if N < 0 then N = 0 end
        if N > 255 then N = 255 end
        return string.format("%02X", N)
    end
    return Byte(C.R) .. Byte(C.G) .. Byte(C.B)
end

local function MakeSlateColor(C)
    return {
        SpecifiedColor = { R = C.R, G = C.G, B = C.B, A = C.A or 1 },
        ColorUseRule = 0,
    }
end

local function SetTextColor(Widget, C)
    if not Widget or not C then
        return
    end
    if Widget.SetColorRGBStr then
        local Ok = pcall(function()
            Widget:SetColorRGBStr(ColorToHexRGB(C))
        end)
        if Ok then
            return
        end
    end
    if Widget.SetColorAndOpacity then
        pcall(function()
            Widget:SetColorAndOpacity(MakeSlateColor(C))
        end)
    elseif Widget.ColorAndOpacity ~= nil then
        Widget.ColorAndOpacity = MakeSlateColor(C)
    end
end

local function FormatRemainingTime(Sec)
    Sec = math.max(0, math.floor(tonumber(Sec) or 0))
    if Sec >= 60 then
        return string.format("%d分%02d秒", math.floor(Sec / 60), Sec % 60)
    end
    return tostring(Sec) .. "秒"
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

function BP_TalentMarketFacility:ReceiveBeginPlay()
    self.SelectedWorkerId = TalentMarketConfig.GetFirstWorkerId()

    local Trigger = self.InteractTrigger
    if Trigger == nil then
        ugcprint("[TalentMarket] InteractTrigger 缺失")
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
    ugcprint("[TalentMarket] Overlap 已绑定")
end

function BP_TalentMarketFacility:ReceiveEndPlay()
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

function BP_TalentMarketFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) or self.bLocalPlayerInside or self.bPromptDismissed or IsLocalPlayerMineCarMode() then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[TalentMarket] 本机玩家进入人才市场")
    self:ShowPrompt()
end

function BP_TalentMarketFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    self.bPromptDismissed = false
    ugcprint("[TalentMarket] 本机玩家离开人才市场")
    self:HidePrompt()
end

function BP_TalentMarketFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Facility = self
    PC.OnTalentMarketNotify = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnTalentMarketUnlocked = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnTalentJobChanged = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
end

function BP_TalentMarketFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    PC.OnTalentMarketNotify = nil
    PC.OnTalentMarketUnlocked = nil
    PC.OnTalentJobChanged = nil
end

function BP_TalentMarketFacility:StartRefreshTimer()
    self:StopRefreshTimer()
    if UGCTimerUtility == nil or UGCTimerUtility.CreateLuaTimer == nil then
        return
    end
    local Facility = self
    local Ok, Handle = pcall(function()
        return UGCTimerUtility.CreateLuaTimer(1.0, function()
            if Facility.bLocalPlayerInside and Facility.PromptWidget ~= nil then
                if IsLocalPlayerMineCarMode() then
                    Facility.bPromptDismissed = true
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

function BP_TalentMarketFacility:StopRefreshTimer()
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

function BP_TalentMarketFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetTalentMarketStatus then
        local Ok, Status = pcall(function()
            return PC:GetTalentMarketStatus(self.SelectedWorkerId)
        end)
        if Ok and type(Status) == "table" then
            return Status
        end
    end
    local Worker = TalentMarketConfig.GetWorker(self.SelectedWorkerId) or {}
    return {
        bUnlocked = PC and PC.bTalentMarketUnlocked == true,
        UnlockCost = TalentMarketConfig.UnlockCost or 5000,
        GoldCount = 0,
        WorkerId = self.SelectedWorkerId,
        WorkerName = Worker.Name or "?",
        HireCost = Worker.HireCost or 0,
        DurationText = TalentMarketConfig.FormatDuration(Worker.DurationSec or 0),
        RewardCount = Worker.RewardCount or 0,
        MinMineLevel = Worker.MinMineLevel or 1,
        MaxMineLevel = Worker.MaxMineLevel or 1,
        JobState = JOB_IDLE,
        LastMsg = PC and PC.TalentMarketLastMsg or "",
    }
end

function BP_TalentMarketFacility:ApplyLabels(Widget, Status)
    if Widget == nil then
        return
    end
    Status = Status or {}
    local JobState = math.floor(tonumber(Status.JobState) or JOB_IDLE)
    local WorkerName = tostring(Status.WorkerName or "?")

    local MainTxt
    if Status.bUnlocked ~= true then
        MainTxt = string.format("解锁人才市场 (%d金)", tonumber(Status.UnlockCost) or 5000)
    elseif JobState == JOB_READY then
        MainTxt = "领取矿物"
    elseif JobState == JOB_RUNNING then
        MainTxt = "矿工外出中 " .. FormatRemainingTime(Status.RemainingSec)
    else
        MainTxt = string.format("雇佣%s (%d金)", WorkerName, tonumber(Status.HireCost) or 0)
    end

    SetText(GetW(Widget, "Txt_Unlock"), MainTxt)
    if JobState == JOB_RUNNING then
        SetText(GetW(Widget, "Txt_Quick"), "剩余·" .. FormatRemainingTime(Status.RemainingSec))
    else
        SetText(GetW(Widget, "Txt_Quick"), "工人·" .. WorkerName)
    end
    SetText(GetW(Widget, "Txt_Manual"), "打开仓库")
    SetText(GetW(Widget, "Txt_Close"), "关闭")
end

function BP_TalentMarketFacility:RefreshPromptUI()
    if IsLocalPlayerMineCarMode() then
        self.bPromptDismissed = true
        self:HidePrompt()
        return
    end

    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end
    local Status = self:GetStatus()

    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState({
                bUnlocked = true,
                JadeCount = 0,
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

    local JobState = math.floor(tonumber(Status.JobState) or JOB_IDLE)
    local CanMain = true
    if Status.bUnlocked ~= true then
        CanMain = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.UnlockCost) or 5000)
    elseif JobState == JOB_RUNNING then
        CanMain = false
    elseif JobState == JOB_IDLE then
        CanMain = (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.HireCost) or 0)
    end

    SetEnabled(GetW(Widget, "Btn_Unlock"), CanMain)
    SetEnabled(GetW(Widget, "Btn_Quick"), Status.bUnlocked == true and JobState == JOB_IDLE)
    SetEnabled(GetW(Widget, "Btn_Manual"), Status.bUnlocked == true)
    SetEnabled(GetW(Widget, "Btn_Close"), true)
    self:ApplyLabels(Widget, Status)

    local Line
    if Status.bUnlocked ~= true then
        Line = string.format("人才市场 · 解锁 %d 金币（当前 %d）", tonumber(Status.UnlockCost) or 5000, tonumber(Status.GoldCount) or 0)
    elseif JobState == JOB_RUNNING then
        Line = string.format(
            "人才市场 · %s挖矿中 · 剩余 %s",
            tostring(Status.JobWorkerName or "矿工"),
            FormatRemainingTime(Status.RemainingSec)
        )
    elseif JobState == JOB_READY then
        Line = string.format("人才市场 · %s已返回 · 可领取 %d 个矿物", tostring(Status.JobWorkerName or "矿工"), tonumber(Status.RewardTotal) or 0)
    else
        Line = string.format(
            "人才市场 · %s · %s · 产出%d个%d-%d级矿物",
            tostring(Status.WorkerName or "?"),
            tostring(Status.DurationText or ""),
            tonumber(Status.RewardCount) or 0,
            tonumber(Status.MinMineLevel) or 1,
            tonumber(Status.MaxMineLevel) or 1
        )
    end
    if Status.LastMsg and Status.LastMsg ~= "" then
        local ShortMsg = ShortTalentMessage(Status.LastMsg)
        if ShortMsg ~= "" then
            Line = Line .. "\n" .. ShortMsg
        end
    end
    local PromptText = GetW(Widget, "Txt_Prompt")
    FitPromptText(PromptText)
    SetText(PromptText, Line)
    SetTextColor(PromptText, { R = 0.08, G = 0.10, B = 0.12, A = 1 })
end

function BP_TalentMarketFacility:ShowPrompt()
    if IsLocalPlayerMineCarMode() then
        self.bPromptDismissed = true
        self:HidePrompt()
        return
    end

    if self.PromptWidget ~= nil or self.bPromptOpening then
        if self.PromptWidget then
            self:RefreshPromptUI()
            if self.RefreshTimer == nil then
                self:StartRefreshTimer()
            end
        end
        return
    end
    self.bPromptOpening = true
    self:BindPCCallbacks()

    local Path = UGCGameSystem.GetUGCResourcesFullPath(PROMPT_UI_PATH)
    UGCWidgetManagerSystem.CreateWidgetAsync(Path, function(Widget)
        self.bPromptOpening = false
        if not Widget then
            ugcprint("[TalentMarket] 提示 UI 创建失败")
            return
        end
        if not self.bLocalPlayerInside or IsLocalPlayerMineCarMode() then
            self.bPromptDismissed = IsLocalPlayerMineCarMode()
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
                    Facility:OnCycleWorkerClicked()
                end,
                OnManual = function()
                    Facility:OnOpenWarehouseClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[TalentMarket] 人才市场面板已显示")
        self:StartRefreshTimer()
    end)
end

function BP_TalentMarketFacility:HidePrompt()
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

function BP_TalentMarketFacility:OnCloseClicked()
    self.bPromptDismissed = true
    self:HidePrompt()
end

function BP_TalentMarketFacility:OnCycleWorkerClicked()
    if not self.bLocalPlayerInside then
        return
    end
    self.SelectedWorkerId = TalentMarketConfig.NextWorkerId(self.SelectedWorkerId)
    self:RefreshPromptUI()
end

function BP_TalentMarketFacility:OnMainClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local Status = self:GetStatus()
    local JobState = math.floor(tonumber(Status.JobState) or JOB_IDLE)
    if Status.bUnlocked ~= true then
        if PC.RequestUnlockTalentMarket then
            PC:RequestUnlockTalentMarket()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockTalentMarket")
        end
    elseif JobState == JOB_READY then
        if PC.RequestCollectTalentJob then
            PC:RequestCollectTalentJob()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_CollectTalentJob")
        end
    elseif JobState == JOB_IDLE then
        if PC.RequestHireTalentWorker then
            PC:RequestHireTalentWorker(self.SelectedWorkerId)
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_HireTalentWorker", self.SelectedWorkerId)
        end
    end
end

function BP_TalentMarketFacility:OnOpenWarehouseClicked()
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    if PC.OpenWarehousePanel then
        PC:OpenWarehousePanel()
    elseif UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanelStyle then
        UGCBackpackSystemV2.OpenBackpackPanelStyle(nil, 2)
    elseif UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanel then
        UGCBackpackSystemV2.OpenBackpackPanel(2)
    end
    self:HidePrompt()
end

return BP_TalentMarketFacility
