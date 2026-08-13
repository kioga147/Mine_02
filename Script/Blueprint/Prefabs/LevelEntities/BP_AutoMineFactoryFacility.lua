---@class BP_AutoMineFactoryFacility_C:BP_MineTeleportHall_C
--Edit Below--
--- 全自动采矿工厂：解锁后每 60s 自动产出 60+ 随机矿物，可切换矿工档位、可选择玉石是否保留
local AutoMineFactoryConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.AutoMineFactoryConfig")
    end)
    if Ok and type(Mod) == "table" then
        AutoMineFactoryConfig = Mod
    else
        AutoMineFactoryConfig = {
            UnlockCost = 500000,
            CycleSec = 60,
            BaseOreCountPerCycle = 60,
            DefaultKeepJade = true,
            GetFirstWorkerId = function() return 1 end,
            NextWorkerId = function(CurrentId)
                local Cur = math.floor(tonumber(CurrentId) or 0)
                if Cur == 1 then return 2 elseif Cur == 2 then return 3 end
                return 1
            end,
            GetWorker = function(WorkerId)
                local Map = {
                    [1] = { Name = "初级加工矿工", BonusOreCount = 0,  MinMineLevel = 1, MaxMineLevel = 3, Desc = "1~3 级矿物" },
                    [2] = { Name = "中级加工矿工", BonusOreCount = 10, MinMineLevel = 1, MaxMineLevel = 4, Desc = "1~4 级，+10个/周期" },
                    [3] = { Name = "高级加工矿工", BonusOreCount = 20, MinMineLevel = 3, MaxMineLevel = 5, Desc = "3~5 级含玉石，+20个/周期" },
                }
                return Map[math.floor(tonumber(WorkerId) or 0)]
            end,
            FormatRemainingTime = function(Sec)
                Sec = math.max(0, math.floor(tonumber(Sec) or 0))
                if Sec >= 60 then return string.format("%d分%02d秒", math.floor(Sec / 60), Sec % 60) end
                return tostring(Sec) .. "秒"
            end,
            FormatRewards = function(Rewards)
                if type(Rewards) ~= "table" then return "" end
                local N = {}
                for Id, C in pairs(Rewards) do N[#N+1] = tostring(Id) .. "x" .. tostring(math.floor(tonumber(C) or 0)) end
                table.sort(N)
                return table.concat(N, "、")
            end,
        }
    end
end

local BP_AutoMineFactoryFacility = {
    bLocalPlayerInside = false,
    bPromptDismissed = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedWorkerId = 1,
    RefreshTimer = nil,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"

-- 工厂运行状态
local FACTORY_IDLE = 0       -- 未产出
local FACTORY_RUNNING = 1    -- 周期进行中
local FACTORY_READY = 2      -- 产出已完成，待领取/自动售卖

local function IsLocalPlayerPawn(OtherActor)
    if OtherActor == nil then return false end
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    return LocalPawn ~= nil and LocalPawn == OtherActor
end

local function IsLocalPlayerMineCarMode()
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    if LocalPawn ~= nil and LocalPawn.IsMineCarMode then
        local Ok, Result = pcall(function() return LocalPawn:IsMineCarMode() end)
        if Ok and Result == true then return true end
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC ~= nil and type(PC.ClientVehicleRepairStateMap) == "table" then
        for _, State in pairs(PC.ClientVehicleRepairStateMap) do
            if math.floor(tonumber(State) or 0) == 1 then return true end
        end
    end
    return false
end

local function GetLocalPC()
    return UGCGameSystem.GetLocalPlayerController()
end

local function GetW(Widget, Name)
    if Widget == nil then return nil end
    if Widget[Name] ~= nil then return Widget[Name] end
    if Widget.GetWidgetFromName then
        local Ok, W = pcall(function() return Widget:GetWidgetFromName(Name) end)
        if Ok then return W end
    end
    return nil
end

local function SetText(Widget, Text)
    if Widget and Widget.SetText then
        pcall(function() Widget:SetText(Text) end)
    end
end

local function FitPromptText(Widget)
    if Widget == nil then return end
    if Widget.SetAutoWrapText then pcall(function() Widget:SetAutoWrapText(true) end) end
    if Widget.SetWrapTextAt then pcall(function() Widget:SetWrapTextAt(1180) end) end
    if Widget.SetClipping then pcall(function() Widget:SetClipping(1) end) end
    if Widget.SetRenderScale then pcall(function() Widget:SetRenderScale({ X = 0.88, Y = 0.88 }) end) end
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
    return { SpecifiedColor = { R = C.R, G = C.G, B = C.B, A = C.A or 1 }, ColorUseRule = 0 }
end

local function SetTextColor(Widget, C)
    if not Widget or not C then return end
    if Widget.SetColorRGBStr then
        local Ok = pcall(function() Widget:SetColorRGBStr(ColorToHexRGB(C)) end)
        if Ok then return end
    end
    if Widget.SetColorAndOpacity then
        pcall(function() Widget:SetColorAndOpacity(MakeSlateColor(C)) end)
    elseif Widget.ColorAndOpacity ~= nil then
        Widget.ColorAndOpacity = MakeSlateColor(C)
    end
end

local function SetVisible(Widget, bShow)
    if not Widget or not Widget.SetVisibility then return end
    local Vis = bShow and ((ESlateVisibility and ESlateVisibility.Visible) or 0)
        or ((ESlateVisibility and ESlateVisibility.Collapsed) or 1)
    pcall(function() Widget:SetVisibility(Vis) end)
end

local function SetEnabled(Widget, bEnabled)
    if Widget and Widget.SetIsEnabled then
        pcall(function() Widget:SetIsEnabled(bEnabled) end)
    end
end

function BP_AutoMineFactoryFacility:ReceiveBeginPlay()
    -- 不调用父类 ReceiveBeginPlay，避免矿区传送大厅的 overlap 和 UI 逻辑干扰
    self.SelectedWorkerId = AutoMineFactoryConfig.GetFirstWorkerId()

    local Trigger = self.InteractTrigger
    if Trigger == nil then
        ugcprint("[AutoMineFactory] InteractTrigger 缺失")
        return
    end
    if self.bOverlapBound then return end
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
    ugcprint("[AutoMineFactory] Overlap 已绑定")
end

function BP_AutoMineFactoryFacility:ReceiveEndPlay()
    self:UnbindPCCallbacks()
    self:StopRefreshTimer()
    local Trigger = self.InteractTrigger
    if Trigger and self.bOverlapBound then
        if Trigger.OnComponentBeginOverlap then
            pcall(function() Trigger.OnComponentBeginOverlap:Remove(self.OnTriggerBeginOverlap, self) end)
        end
        if Trigger.OnComponentEndOverlap then
            pcall(function() Trigger.OnComponentEndOverlap:Remove(self.OnTriggerEndOverlap, self) end)
        end
    end
    self.bOverlapBound = false
    self:HidePrompt()
end

function BP_AutoMineFactoryFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) or self.bLocalPlayerInside or self.bPromptDismissed or IsLocalPlayerMineCarMode() then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[AutoMineFactory] 本机玩家进入全自动采矿工厂")
    self:ShowPrompt()
end

function BP_AutoMineFactoryFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then return end
    self.bLocalPlayerInside = false
    self.bPromptDismissed = false
    ugcprint("[AutoMineFactory] 本机玩家离开全自动采矿工厂")
    self:HidePrompt()
end

function BP_AutoMineFactoryFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if PC == nil then return end
    local Facility = self
    PC.OnAutoMineFactoryNotify = function()
        if Facility.bLocalPlayerInside then Facility:RefreshPromptUI() end
    end
    PC.OnAutoMineFactoryUnlocked = function()
        if Facility.bLocalPlayerInside then Facility:RefreshPromptUI() end
    end
    PC.OnAutoMineFactoryStateChanged = function()
        if Facility.bLocalPlayerInside then Facility:RefreshPromptUI() end
    end
    PC.OnAutoMineFactoryKeepJadeToggled = function()
        if Facility.bLocalPlayerInside then Facility:RefreshPromptUI() end
    end
    PC.OnAutoMineFactoryWorkerChanged = function()
        if Facility.bLocalPlayerInside then Facility:RefreshPromptUI() end
    end
end

function BP_AutoMineFactoryFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if PC == nil then return end
    PC.OnAutoMineFactoryNotify = nil
    PC.OnAutoMineFactoryUnlocked = nil
    PC.OnAutoMineFactoryStateChanged = nil
    PC.OnAutoMineFactoryKeepJadeToggled = nil
    PC.OnAutoMineFactoryWorkerChanged = nil
end

function BP_AutoMineFactoryFacility:StartRefreshTimer()
    self:StopRefreshTimer()
    if UGCTimerUtility == nil or UGCTimerUtility.CreateLuaTimer == nil then return end
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
    if Ok then self.RefreshTimer = Handle end
end

function BP_AutoMineFactoryFacility:StopRefreshTimer()
    local Handle = self.RefreshTimer
    self.RefreshTimer = nil
    if Handle == nil then return end
    if UGCTimerUtility and UGCTimerUtility.RemoveLuaTimer then
        pcall(function() UGCTimerUtility.RemoveLuaTimer(Handle) end)
    end
end

function BP_AutoMineFactoryFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetAutoMineFactoryStatus then
        local Ok, Status = pcall(function()
            return PC:GetAutoMineFactoryStatus(self.SelectedWorkerId)
        end)
        if Ok and type(Status) == "table" then return Status end
    end
    local Worker = AutoMineFactoryConfig.GetWorker(self.SelectedWorkerId) or {}
    return {
        bUnlocked = PC and PC.bAutoMineFactoryUnlocked == true,
        bPreconditionsMet = PC and PC.bAutoMineFactoryPreconditionsMet == true,
        UnlockCost = AutoMineFactoryConfig.UnlockCost or 500000,
        GoldCount = 0,
        WorkerId = self.SelectedWorkerId,
        WorkerName = Worker.Name or "?",
        WorkerDesc = Worker.Desc or "",
        BonusOreCount = Worker.BonusOreCount or 0,
        MinMineLevel = Worker.MinMineLevel or 1,
        MaxMineLevel = Worker.MaxMineLevel or 1,
        CycleSec = AutoMineFactoryConfig.CycleSec or 60,
        BaseCount = AutoMineFactoryConfig.BaseOreCountPerCycle or 60,
        bKeepJade = AutoMineFactoryConfig.DefaultKeepJade ~= false,
        State = FACTORY_IDLE,
        LastMsg = PC and PC.AutoMineFactoryLastMsg or "",
        PreconditionHint = "",
    }
end

function BP_AutoMineFactoryFacility:ApplyLabels(Widget, Status)
    if Widget == nil then return end
    Status = Status or {}
    local State = math.floor(tonumber(Status.State) or FACTORY_IDLE)
    local WorkerName = tostring(Status.WorkerName or "?")

    local MainTxt
    if Status.bUnlocked ~= true then
        if Status.bPreconditionsMet ~= true then
            MainTxt = "前置条件未达成"
        else
            MainTxt = string.format("解锁全自动采矿工厂 (%d金)", tonumber(Status.UnlockCost) or 500000)
        end
    elseif State == FACTORY_READY then
        if Status.bKeepJade then
            MainTxt = "领取本周期矿物"
        else
            MainTxt = "自动售卖本周期产出"
        end
    elseif State == FACTORY_RUNNING then
        MainTxt = "采矿中 " .. AutoMineFactoryConfig.FormatRemainingTime(Status.RemainingSec)
    else
        MainTxt = "启动采矿周期"
    end

    SetText(GetW(Widget, "Txt_Unlock"), MainTxt)
    SetText(GetW(Widget, "Txt_Quick"), "矿工·" .. WorkerName)
    if Status.bKeepJade then
        SetText(GetW(Widget, "Txt_Manual"), "玉石：保留入库")
    else
        SetText(GetW(Widget, "Txt_Manual"), "玉石：自动鉴定售卖")
    end
    SetText(GetW(Widget, "Txt_Close"), "关闭")
end

function BP_AutoMineFactoryFacility:RefreshPromptUI()
    if IsLocalPlayerMineCarMode() then
        self.bPromptDismissed = true
        self:HidePrompt()
        return
    end

    local Widget = self.PromptWidget
    if Widget == nil then return end
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

    local State = math.floor(tonumber(Status.State) or FACTORY_IDLE)
    local CanMain = true
    if Status.bUnlocked ~= true then
        CanMain = (Status.bPreconditionsMet == true)
            and (tonumber(Status.GoldCount) or 0) >= (tonumber(Status.UnlockCost) or 500000)
    elseif State == FACTORY_RUNNING then
        CanMain = false
    elseif State == FACTORY_IDLE then
        CanMain = true
    end

    SetEnabled(GetW(Widget, "Btn_Unlock"), CanMain)
    SetEnabled(GetW(Widget, "Btn_Quick"), Status.bUnlocked == true and State ~= FACTORY_RUNNING)
    SetEnabled(GetW(Widget, "Btn_Manual"), Status.bUnlocked == true)
    SetEnabled(GetW(Widget, "Btn_Close"), true)
    self:ApplyLabels(Widget, Status)

    local Line
    if Status.bUnlocked ~= true then
        if Status.bPreconditionsMet ~= true then
            Line = string.format(
                "全自动采矿工厂 · 前置未达成：%s",
                tostring(Status.PreconditionHint or "需先解锁：所有采矿车+矿石加工厂+人才市场+鉴定所+维修处+传送大厅")
            )
        else
            Line = string.format(
                "全自动采矿工厂 · 解锁 %d 金币（当前 %d）",
                tonumber(Status.UnlockCost) or 500000,
                tonumber(Status.GoldCount) or 0
            )
        end
    elseif State == FACTORY_RUNNING then
        Line = string.format(
            "全自动采矿工厂 · %s采矿中 · 剩余 %s · 每周期产出约 %d 个",
            tostring(Status.WorkerName or "矿工"),
            AutoMineFactoryConfig.FormatRemainingTime(Status.RemainingSec),
            tonumber(Status.TotalPerCycle) or 60
        )
    elseif State == FACTORY_READY then
        if Status.bKeepJade then
            Line = string.format(
                "全自动采矿工厂 · 产出已完成 · 共 %d 个矿物：%s · 点击领取（玉石保留）",
                tonumber(Status.RewardTotal) or 0,
                tostring(Status.RewardSummary or "")
            )
        else
            Line = string.format(
                "全自动采矿工厂 · 产出已完成 · 共 %d 个矿物（玉石已鉴定）· 点击售卖预计获得 %d 金",
                tonumber(Status.RewardTotal) or 0,
                tonumber(Status.EstimatedSellGold) or 0
            )
        end
    else
        Line = string.format(
            "全自动采矿工厂 · %s · 每 %s 产出约 %d 个 %d~%d 级矿物 · 玉石模式：%s",
            tostring(Status.WorkerDesc or Status.WorkerName or "?"),
            AutoMineFactoryConfig.FormatRemainingTime(Status.CycleSec or 60),
            tonumber(Status.TotalPerCycle) or (Status.BaseCount + Status.BonusOreCount) or 60,
            tonumber(Status.MinMineLevel) or 1,
            tonumber(Status.MaxMineLevel) or 1,
            Status.bKeepJade and "保留入库" or "自动鉴定售卖"
        )
    end
    if Status.LastMsg and Status.LastMsg ~= "" then
        Line = Line .. "\n" .. tostring(Status.LastMsg)
    end
    local PromptText = GetW(Widget, "Txt_Prompt")
    FitPromptText(PromptText)
    SetText(PromptText, Line)
    SetTextColor(PromptText, { R = 0.08, G = 0.10, B = 0.12, A = 1 })
end

function BP_AutoMineFactoryFacility:ShowPrompt()
    if IsLocalPlayerMineCarMode() then
        self.bPromptDismissed = true
        self:HidePrompt()
        return
    end

    if self.PromptWidget ~= nil or self.bPromptOpening then
        if self.PromptWidget then
            self:RefreshPromptUI()
            if self.RefreshTimer == nil then self:StartRefreshTimer() end
        end
        return
    end
    self.bPromptOpening = true
    self:BindPCCallbacks()

    local Path = UGCGameSystem.GetUGCResourcesFullPath(PROMPT_UI_PATH)
    UGCWidgetManagerSystem.CreateWidgetAsync(Path, function(Widget)
        self.bPromptOpening = false
        if not Widget then
            ugcprint("[AutoMineFactory] 提示 UI 创建失败")
            return
        end
        if not self.bLocalPlayerInside or IsLocalPlayerMineCarMode() then
            self.bPromptDismissed = IsLocalPlayerMineCarMode()
            if Widget.RemoveFromParent then
                pcall(function() Widget:RemoveFromParent() end)
            end
            return
        end
        self.PromptWidget = Widget
        UGCWidgetManagerSystem.AddToSlot(Widget, "UI.UISlot.MainUISlot_High")
        if Widget.ApplyPromptLayout then
            pcall(function() Widget:ApplyPromptLayout() end)
        end
        local Facility = self
        if Widget.SetShopCallbacks then
            Widget:SetShopCallbacks({
                OnUnlock = function() Facility:OnMainClicked() end,
                OnQuick = function() Facility:OnCycleWorkerClicked() end,
                OnManual = function() Facility:OnToggleKeepJadeClicked() end,
                OnClose = function() Facility:OnCloseClicked() end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[AutoMineFactory] 全自动采矿工厂面板已显示")
        self:StartRefreshTimer()
    end)
end

function BP_AutoMineFactoryFacility:HidePrompt()
    self.bPromptOpening = false
    self:UnbindPCCallbacks()
    self:StopRefreshTimer()
    local Widget = self.PromptWidget
    self.PromptWidget = nil
    if Widget == nil then return end
    if Widget.SetShopCallbacks then
        pcall(function() Widget:SetShopCallbacks(nil) end)
    end
    if Widget.RemoveFromParent then
        pcall(function() Widget:RemoveFromParent() end)
    end
end

function BP_AutoMineFactoryFacility:OnCloseClicked()
    self.bPromptDismissed = true
    self:HidePrompt()
end

function BP_AutoMineFactoryFacility:OnCycleWorkerClicked()
    if not self.bLocalPlayerInside then return end
    self.SelectedWorkerId = AutoMineFactoryConfig.NextWorkerId(self.SelectedWorkerId)
    local PC = GetLocalPC()
    if PC and PC.RequestSetAutoMineFactoryWorker then
        PC:RequestSetAutoMineFactoryWorker(self.SelectedWorkerId)
    elseif PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SetAutoMineFactoryWorker", self.SelectedWorkerId)
    end
    self:RefreshPromptUI()
end

function BP_AutoMineFactoryFacility:OnToggleKeepJadeClicked()
    if not self.bLocalPlayerInside then return end
    local PC = GetLocalPC()
    if PC == nil then return end
    if PC.RequestToggleAutoMineFactoryKeepJade then
        PC:RequestToggleAutoMineFactoryKeepJade()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ToggleAutoMineFactoryKeepJade")
    end
end

function BP_AutoMineFactoryFacility:OnMainClicked()
    if not self.bLocalPlayerInside then return end
    local PC = GetLocalPC()
    if PC == nil then return end
    local Status = self:GetStatus()
    local State = math.floor(tonumber(Status.State) or FACTORY_IDLE)

    if Status.bUnlocked ~= true then
        if PC.RequestUnlockAutoMineFactory then
            PC:RequestUnlockAutoMineFactory()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockAutoMineFactory")
        end
    elseif State == FACTORY_READY then
        if Status.bKeepJade then
            if PC.RequestCollectAutoMineFactory then
                PC:RequestCollectAutoMineFactory()
            else
                UnrealNetwork.CallUnrealRPC(PC, PC, "Server_CollectAutoMineFactory")
            end
        else
            if PC.RequestSellAutoMineFactory then
                PC:RequestSellAutoMineFactory()
            else
                UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SellAutoMineFactory")
            end
        end
    elseif State == FACTORY_IDLE then
        if PC.RequestStartAutoMineFactory then
            PC:RequestStartAutoMineFactory()
        else
            UnrealNetwork.CallUnrealRPC(PC, PC, "Server_StartAutoMineFactory")
        end
    end
end

return BP_AutoMineFactoryFacility
