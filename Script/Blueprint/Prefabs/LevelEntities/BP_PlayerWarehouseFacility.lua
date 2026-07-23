---@class BP_PlayerWarehouseFacility_C:BP_OreRecycleFacility_C
---@field BuildingMesh UStaticMeshComponent
---@field InteractTrigger USphereComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 玩家仓库：初始自动解锁 50 格；升级 +100 格（5000 金 / 50 绿洲币）
--- 复用鉴定所 Prompt UI：升级 / 打开仓库 / 切换支付 / 关闭
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

local BP_PlayerWarehouseFacility = {
    bLocalPlayerInside = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    PayType = 0, -- 0=金币 1=绿洲币
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

function BP_PlayerWarehouseFacility:ReceiveBeginPlay()
    -- 不调用回收处父类 BeginPlay，避免绑定回收逻辑
    self.PayType = 0

    local Trigger = GetInteractTrigger(self)
    if Trigger == nil then
        ugcprint("[Warehouse] InteractTrigger 缺失")
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
    ugcprint("[Warehouse] Overlap 已绑定")
end

function BP_PlayerWarehouseFacility:ReceiveEndPlay()
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

function BP_PlayerWarehouseFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    if self.bLocalPlayerInside then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[Warehouse] 本机玩家进入仓库")
    self:ShowPrompt()
end

function BP_PlayerWarehouseFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    ugcprint("[Warehouse] 本机玩家离开仓库")
    self:HidePrompt()
end

function BP_PlayerWarehouseFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local Facility = self
    PC.OnWarehouseNotify = function(Msg)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
end

function BP_PlayerWarehouseFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    PC.OnWarehouseNotify = nil
end

function BP_PlayerWarehouseFacility:GetStatus()
    local PC = GetLocalPC()
    if PC and PC.GetWarehouseStatus then
        local Ok, Status = pcall(function()
            return PC:GetWarehouseStatus()
        end)
        if Ok and type(Status) == "table" then
            return Status
        end
    end
    return {
        bUnlocked = true,
        Capacity = WarehouseConfig.GetInitialSlots(),
        MaxCapacity = WarehouseConfig.GetMaxSlots(),
        GoldCount = 0,
        OasisTicket = 0,
        UpgradeGoldCost = WarehouseConfig.GetUpgradeGoldCost(),
        UpgradeOasisCost = WarehouseConfig.GetUpgradeOasisCost(),
        SlotsPerUpgrade = WarehouseConfig.GetSlotsPerUpgrade(),
        bCanUpgrade = true,
        LastMsg = PC and PC.WarehouseLastMsg or "",
    }
end

function BP_PlayerWarehouseFacility:ApplyLabels(Widget, Status)
    if Widget == nil then
        return
    end
    Status = Status or {}
    local GoldCost = math.floor(tonumber(Status.UpgradeGoldCost) or WarehouseConfig.GetUpgradeGoldCost())
    local OasisCost = math.floor(tonumber(Status.UpgradeOasisCost) or WarehouseConfig.GetUpgradeOasisCost())
    local AddSlots = math.floor(tonumber(Status.SlotsPerUpgrade) or WarehouseConfig.GetSlotsPerUpgrade())
    local bCanUpgrade = Status.bCanUpgrade ~= false

    local UpgradeTxt
    if not bCanUpgrade then
        UpgradeTxt = "已达上限"
    elseif self.PayType == 1 then
        UpgradeTxt = string.format("升级 +%d (%d绿洲)", AddSlots, OasisCost)
    else
        UpgradeTxt = string.format("升级 +%d (%d金)", AddSlots, GoldCost)
    end

    SetText(GetW(Widget, "Txt_Unlock"), UpgradeTxt)
    SetText(GetW(Widget, "Txt_Quick"), "打开仓库")
    SetText(GetW(Widget, "Txt_Manual"), (self.PayType == 1) and "支付·绿洲币" or "支付·金币")
    SetText(GetW(Widget, "Txt_Close"), "关闭")
end

function BP_PlayerWarehouseFacility:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end
    local Status = self:GetStatus()
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

    SetVisible(GetW(Widget, "Btn_Unlock"), true)
    SetVisible(GetW(Widget, "Gap_Unlock"), true)
    SetVisible(GetW(Widget, "Btn_Quick"), true)
    SetVisible(GetW(Widget, "Gap_Quick"), true)
    SetVisible(GetW(Widget, "Btn_Manual"), true)
    SetVisible(GetW(Widget, "Gap_Manual"), true)

    local bCanUpgrade = Status.bCanUpgrade ~= false
    local BtnUnlock = GetW(Widget, "Btn_Unlock")
    if BtnUnlock and BtnUnlock.SetIsEnabled then
        pcall(function()
            BtnUnlock:SetIsEnabled(bCanUpgrade)
        end)
    end
    local BtnQuick = GetW(Widget, "Btn_Quick")
    if BtnQuick and BtnQuick.SetIsEnabled then
        pcall(function()
            BtnQuick:SetIsEnabled(true)
        end)
    end
    local BtnManual = GetW(Widget, "Btn_Manual")
    if BtnManual and BtnManual.SetIsEnabled then
        pcall(function()
            BtnManual:SetIsEnabled(true)
        end)
    end

    self:ApplyLabels(Widget, Status)

    local Cap = math.floor(tonumber(Status.Capacity) or 0)
    local MaxCap = math.floor(tonumber(Status.MaxCapacity) or 0)
    local Line = string.format(
        "玩家仓库 · 已解锁 %d / %d 格 · 金 %d · 绿洲 %d",
        Cap,
        MaxCap,
        tonumber(Status.GoldCount) or 0,
        tonumber(Status.OasisTicket) or 0
    )
    if Status.LastMsg and Status.LastMsg ~= "" then
        Line = Line .. "\n" .. tostring(Status.LastMsg)
    end
    SetText(GetW(Widget, "Txt_Prompt"), Line)
end

function BP_PlayerWarehouseFacility:ShowPrompt()
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
            ugcprint("[Warehouse] 提示 UI 创建失败")
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
                    Facility:OnUpgradeClicked()
                end,
                OnQuick = function()
                    Facility:OnOpenWarehouseClicked()
                end,
                OnManual = function()
                    Facility:OnCyclePayClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[Warehouse] 仓库面板已显示")
    end)
end

function BP_PlayerWarehouseFacility:HidePrompt()
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

function BP_PlayerWarehouseFacility:OnCloseClicked()
    self:HidePrompt()
end

function BP_PlayerWarehouseFacility:OnCyclePayClicked()
    if not self.bLocalPlayerInside then
        return
    end
    self.PayType = (self.PayType == 0) and 1 or 0
    ugcprint("[Warehouse] 切换支付 -> " .. ((self.PayType == 1) and "绿洲币" or "金币"))
    self:RefreshPromptUI()
end

function BP_PlayerWarehouseFacility:OnUpgradeClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local PayType = self.PayType
    ugcprint("[Warehouse] 请求升级 PayType=" .. tostring(PayType))
    if PC.RequestUpgradeWarehouse then
        PC:RequestUpgradeWarehouse(PayType)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UpgradeWarehouse", PayType)
    end
end

function BP_PlayerWarehouseFacility:OnOpenWarehouseClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    ugcprint("[Warehouse] 打开仓库面板")
    if PC.OpenWarehousePanel then
        PC:OpenWarehousePanel()
    elseif UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanelStyle then
        UGCBackpackSystemV2.OpenBackpackPanelStyle(nil, 2)
    elseif UGCBackpackSystemV2 and UGCBackpackSystemV2.OpenBackpackPanel then
        UGCBackpackSystemV2.OpenBackpackPanel(2)
    end
    -- 打开仓库后收起 Prompt，避免挡操作
    self:HidePrompt()
end

return BP_PlayerWarehouseFacility
