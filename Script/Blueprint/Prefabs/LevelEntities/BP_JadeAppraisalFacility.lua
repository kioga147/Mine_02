---@class BP_JadeAppraisalFacility_C:AActor
---@field PromptAnchor USceneComponent
---@field InteractTrigger USphereComponent
---@field BuildingMesh UStaticMeshComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local BP_JadeAppraisalFacility = {
    bLocalPlayerInside = false,
    bPromptDismissed = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    RefreshTimer = nil,
}

local PROMPT_UI_PATH = "Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C"
local PROMPT_SHOW_DISTANCE = 360
local PROMPT_HIDE_DISTANCE = 520
local PROMPT_REFRESH_INTERVAL = 0.5

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

local function GetActorLocationSafe(Actor)
    if Actor == nil then
        return nil
    end
    local Ok, Loc = pcall(function()
        return Actor:K2_GetActorLocation()
    end)
    if Ok then
        return Loc
    end
    return nil
end

local function GetComponentLocationSafe(Component)
    if Component == nil then
        return nil
    end
    local Ok, Loc = pcall(function()
        return Component:K2_GetComponentLocation()
    end)
    if Ok then
        return Loc
    end
    return nil
end

local function GetDistanceSq(A, B)
    if A == nil or B == nil then
        return nil
    end
    local DX = (tonumber(A.X) or 0) - (tonumber(B.X) or 0)
    local DY = (tonumber(A.Y) or 0) - (tonumber(B.Y) or 0)
    local DZ = (tonumber(A.Z) or 0) - (tonumber(B.Z) or 0)
    return DX * DX + DY * DY + DZ * DZ
end

function BP_JadeAppraisalFacility:ReceiveBeginPlay()
    if BP_JadeAppraisalFacility.SuperClass and BP_JadeAppraisalFacility.SuperClass.ReceiveBeginPlay then
        pcall(BP_JadeAppraisalFacility.SuperClass.ReceiveBeginPlay, self)
    end

    self:StartRefreshTimer()

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
        Trigger.bGenerateOverlapEvents = true
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

    if BP_JadeAppraisalFacility.SuperClass and BP_JadeAppraisalFacility.SuperClass.ReceiveEndPlay then
        pcall(BP_JadeAppraisalFacility.SuperClass.ReceiveEndPlay, self)
    end
end

function BP_JadeAppraisalFacility:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    if self.bPromptDismissed then
        return
    end
    if self.bLocalPlayerInside and (self.PromptWidget ~= nil or self.bPromptOpening) then
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
    if self:IsLocalPlayerNear(PROMPT_HIDE_DISTANCE) then
        return
    end
    self.bLocalPlayerInside = false
    self.bPromptDismissed = false
    ugcprint("[JadeFacility] 本机玩家离开范围")
    self:HidePrompt()
end

function BP_JadeAppraisalFacility:IsLocalPlayerNear(Distance)
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    local PawnLoc = GetActorLocationSafe(LocalPawn)
    local FacilityLoc = GetComponentLocationSafe(self.InteractTrigger)
        or GetComponentLocationSafe(self.PromptAnchor)
        or GetActorLocationSafe(self)
    local DistSq = GetDistanceSq(PawnLoc, FacilityLoc)
    if DistSq == nil then
        return false
    end
    return DistSq <= Distance * Distance
end

function BP_JadeAppraisalFacility:StartRefreshTimer()
    self:StopRefreshTimer()
    if UGCTimerUtility == nil or UGCTimerUtility.CreateLuaTimer == nil then
        return
    end
    local Facility = self
    local Ok, Handle = pcall(function()
        return UGCTimerUtility.CreateLuaTimer(PROMPT_REFRESH_INTERVAL, function()
            local bNearShow = Facility:IsLocalPlayerNear(PROMPT_SHOW_DISTANCE)
            local bNearHide = Facility:IsLocalPlayerNear(PROMPT_HIDE_DISTANCE)

            if bNearShow then
                Facility.bLocalPlayerInside = true
                if Facility.bPromptDismissed ~= true then
                    Facility:ShowPrompt()
                end
                if Facility.PromptWidget ~= nil then
                    Facility:RefreshPromptUI()
                end
                return
            end

            if not bNearHide then
                Facility.bLocalPlayerInside = false
                Facility.bPromptDismissed = false
                Facility:HidePrompt()
            end
        end, true)
    end)
    if Ok then
        self.RefreshTimer = Handle
    end
end

function BP_JadeAppraisalFacility:StopRefreshTimer()
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
    PC.OnJadeManualUIOpened = nil
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
        if not self.bLocalPlayerInside or self.bPromptDismissed then
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
    self.bPromptDismissed = true
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
        ugcprint("[JadeFacility] 手动鉴定忽略：玩家不在范围内")
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        ugcprint("[JadeFacility] 手动鉴定忽略：无本地 PC")
        return
    end
    ugcprint("[JadeFacility] 请求手动鉴定（服务端开会话）")
    -- 不要先 HidePrompt：失败时提示层还在，才能显示 Notify；成功开鉴定 UI 后再收起
    local Facility = self
    PC.OnJadeManualUIOpened = function()
        Facility:HidePrompt()
    end
    if PC.RequestBeginManualAppraisal then
        PC:RequestBeginManualAppraisal()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_BeginManualAppraisal")
    end
end

return BP_JadeAppraisalFacility
