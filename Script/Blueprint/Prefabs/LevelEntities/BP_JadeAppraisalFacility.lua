---@class BP_JadeAppraisalFacility_C:AActor
---@field PromptAnchor USceneComponent
---@field InteractTrigger USphereComponent
---@field BuildingMesh UStaticMeshComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local BP_JadeAppraisalFacility = {
    bLocalPlayerInside = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
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

function BP_JadeAppraisalFacility:ReceiveBeginPlay()
    if BP_JadeAppraisalFacility.SuperClass and BP_JadeAppraisalFacility.SuperClass.ReceiveBeginPlay then
        pcall(BP_JadeAppraisalFacility.SuperClass.ReceiveBeginPlay, self)
    end

    local Trigger = GetInteractTrigger(self)
    if Trigger == nil then
        ugcprint("[JadeFacility] InteractTrigger 缺失")
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
    end)

    if Trigger.OnComponentBeginOverlap then
        Trigger.OnComponentBeginOverlap:Add(self.OnTriggerBeginOverlap, self)
    end
    if Trigger.OnComponentEndOverlap then
        Trigger.OnComponentEndOverlap:Add(self.OnTriggerEndOverlap, self)
    end
    ugcprint("[JadeFacility] Overlap 已绑定")
end

function BP_JadeAppraisalFacility:ReceiveEndPlay()
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

    if BP_JadeAppraisalFacility.SuperClass and BP_JadeAppraisalFacility.SuperClass.ReceiveEndPlay then
        pcall(BP_JadeAppraisalFacility.SuperClass.ReceiveEndPlay, self)
    end
end

function BP_JadeAppraisalFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    if self.bLocalPlayerInside then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[JadeFacility] 本机玩家进入范围")
    self:ShowPrompt()
end

function BP_JadeAppraisalFacility:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    ugcprint("[JadeFacility] 本机玩家离开范围")
    self:HidePrompt()
end

function BP_JadeAppraisalFacility:BindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local Facility = self
    PC.OnJadeShopNotify = function(Msg)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnJadeShopUnlocked = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnJadeQuickResult = function(Roll)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
        ugcprint("[JadeFacility] 快速鉴定结果=" .. tostring(Roll))
    end
end

function BP_JadeAppraisalFacility:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    PC.OnJadeShopNotify = nil
    PC.OnJadeShopUnlocked = nil
    PC.OnJadeQuickResult = nil
end

function BP_JadeAppraisalFacility:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil or Widget.RefreshShopState == nil then
        return
    end
    local PC = GetLocalPC()
    local Status = nil
    if PC and PC.GetJadeShopStatus then
        Status = PC:GetJadeShopStatus()
    else
        Status = {
            bUnlocked = PC and PC.bJadeShopUnlocked == true,
            JadeCount = 0,
            GoldCount = 0,
            UnlockCost = 15000,
            QuickCost = 3000,
            LastMsg = PC and PC.JadeShopLastMsg or "",
        }
    end
    pcall(function()
        Widget:RefreshShopState(Status)
    end)
end

function BP_JadeAppraisalFacility:ShowPrompt()
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
            ugcprint("[JadeFacility] 提示 UI 创建失败")
            return
        end
        if not self.bLocalPlayerInside then
            if Widget.RemoveFromParent then
                Widget:RemoveFromParent()
            end
            return
        end
        if self.PromptWidget ~= nil then
            if Widget.RemoveFromParent then
                Widget:RemoveFromParent()
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
                    Facility:OnUnlockClicked()
                end,
                OnQuick = function()
                    Facility:OnQuickClicked()
                end,
                OnManual = function()
                    Facility:OnManualClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[JadeFacility] 模式选择层已显示")
    end)
end

function BP_JadeAppraisalFacility:HidePrompt()
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

function BP_JadeAppraisalFacility:OnCloseClicked()
    ugcprint("[JadeFacility] 关闭模式选择")
    self:HidePrompt()
end

function BP_JadeAppraisalFacility:OnUnlockClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    ugcprint("[JadeFacility] 请求解锁")
    if PC.RequestUnlockJadeShop then
        PC:RequestUnlockJadeShop()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockJadeShop")
    end
end

function BP_JadeAppraisalFacility:OnQuickClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    ugcprint("[JadeFacility] 请求快速鉴定")
    if PC.RequestQuickAppraiseJade then
        PC:RequestQuickAppraiseJade()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_QuickAppraiseJade")
    end
end

function BP_JadeAppraisalFacility:OnManualClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    ugcprint("[JadeFacility] 请求手动鉴定（服务端开会话）")
    -- 先收起提示；服务端校验失败会 Notify，走近可再开提示
    self:HidePrompt()
    if PC.RequestBeginManualAppraisal then
        PC:RequestBeginManualAppraisal()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_BeginManualAppraisal")
    end
end

return BP_JadeAppraisalFacility
