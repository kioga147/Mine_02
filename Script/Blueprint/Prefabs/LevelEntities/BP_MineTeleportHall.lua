---@class BP_MineTeleportHall_C:AActor
---@field PromptAnchor USceneComponent
---@field InteractTrigger USphereComponent
---@field BuildingMesh UStaticMeshComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 矿区传送大厅：解锁 8500，传送一次 3000
--- 复用鉴定所提示 UI：解锁 / 传送(当前矿区) / 切换矿区 / 关闭
local MineTeleportConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.MineTeleportConfig")
    end)
    if Ok and type(Mod) == "table" then
        MineTeleportConfig = Mod
    else
        MineTeleportConfig = {
            UnlockCost = 8500,
            TeleportCost = 3000,
            Zones = {
                [1] = { Name = "石滩" },
                [2] = { Name = "煤矿场" },
                [3] = { Name = "黄铜矿脉" },
                [4] = { Name = "深层矿区" },
                [5] = { Name = "宝石矿区" },
            },
            GetZone = function(ZoneId)
                return MineTeleportConfig.Zones[tonumber(ZoneId) or 0]
            end,
            NextZoneId = function(CurrentId)
                local Id = (tonumber(CurrentId) or 1) + 1
                if Id > 5 then
                    Id = 1
                end
                return Id
            end,
        }
    end
end

local BP_MineTeleportHall = {
    bLocalPlayerInside = false,
    PromptWidget = nil,
    bPromptOpening = false,
    bOverlapBound = false,
    SelectedZoneId = 1,
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
        return Widget:GetWidgetFromName(Name)
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

function BP_MineTeleportHall:ReceiveBeginPlay()
    if BP_MineTeleportHall.SuperClass and BP_MineTeleportHall.SuperClass.ReceiveBeginPlay then
        pcall(BP_MineTeleportHall.SuperClass.ReceiveBeginPlay, self)
    end

    self.SelectedZoneId = 1

    local Trigger = GetInteractTrigger(self)
    if Trigger == nil then
        ugcprint("[MineTeleport] InteractTrigger 缺失")
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
    ugcprint("[MineTeleport] Overlap 已绑定")
end

function BP_MineTeleportHall:ReceiveEndPlay()
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

    if BP_MineTeleportHall.SuperClass and BP_MineTeleportHall.SuperClass.ReceiveEndPlay then
        pcall(BP_MineTeleportHall.SuperClass.ReceiveEndPlay, self)
    end
end

function BP_MineTeleportHall:OnTriggerBeginOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    if self.bLocalPlayerInside then
        return
    end
    self.bLocalPlayerInside = true
    ugcprint("[MineTeleport] 本机玩家进入传送大厅")
    self:ShowPrompt()
end

function BP_MineTeleportHall:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
    ugcprint("[MineTeleport] 本机玩家离开传送大厅")
    self:HidePrompt()
end

function BP_MineTeleportHall:BindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local Facility = self
    PC.OnMineTeleportNotify = function(Msg)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnMineTeleportUnlocked = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
    end
    PC.OnMineTeleported = function(ZoneId)
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
        ugcprint("[MineTeleport] 已传送 ZoneId=" .. tostring(ZoneId))
    end
end

function BP_MineTeleportHall:UnbindPCCallbacks()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    PC.OnMineTeleportNotify = nil
    PC.OnMineTeleportUnlocked = nil
    PC.OnMineTeleported = nil
end

function BP_MineTeleportHall:ApplyTeleportPromptLabels(Widget)
    if Widget == nil then
        return
    end
    if Widget.ApplyPromptLayout then
        pcall(function()
            Widget:ApplyPromptLayout()
        end)
    end

    local UnlockCost = MineTeleportConfig.UnlockCost
    local TeleportCost = MineTeleportConfig.TeleportCost
    local Zone = MineTeleportConfig.GetZone(self.SelectedZoneId) or { Name = "?" }

    SetText(GetW(Widget, "Txt_Unlock"), string.format("解锁传送大厅 (%d)", UnlockCost))
    SetText(GetW(Widget, "Txt_Quick"), string.format("传送·%s (%d)", Zone.Name, TeleportCost))
    SetText(GetW(Widget, "Txt_Manual"), "切换下一矿区")
    SetText(GetW(Widget, "Txt_Close"), "关闭")
end

function BP_MineTeleportHall:RefreshPromptUI()
    local Widget = self.PromptWidget
    if Widget == nil then
        return
    end

    local PC = GetLocalPC()
    local Status = nil
    if PC and PC.GetMineTeleportStatus then
        Status = PC:GetMineTeleportStatus()
    else
        Status = {
            bUnlocked = PC and PC.bMineTeleportUnlocked == true,
            GoldCount = 0,
            UnlockCost = MineTeleportConfig.UnlockCost,
            TeleportCost = MineTeleportConfig.TeleportCost,
            SelectedZoneId = self.SelectedZoneId,
            LastMsg = PC and PC.MineTeleportLastMsg or "",
        }
    end

    -- 把矿区选择同步进状态，并借用鉴定 UI 的 RefreshShopState 显隐按钮
    Status.SelectedZoneId = self.SelectedZoneId
    Status.JadeCount = 1 -- 借用字段：保证「快速/手动」在解锁后可见（鉴定 UI 用 JadeCount 无关此处）
    Status.QuickCost = MineTeleportConfig.TeleportCost

    self:ApplyTeleportPromptLabels(Widget)
    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState(Status)
        end)
    end

    -- Refresh 后再覆盖文案（避免鉴定所默认文案盖掉）
    self:ApplyTeleportPromptLabels(Widget)

    local Zone = MineTeleportConfig.GetZone(self.SelectedZoneId) or { Name = "?" }
    local Line
    if not Status.bUnlocked then
        Line = string.format(
            "矿区传送大厅 · 请先解锁（%d 金币，当前 %d）",
            Status.UnlockCost or MineTeleportConfig.UnlockCost,
            Status.GoldCount or 0
        )
    else
        Line = string.format(
            "矿区传送大厅 · 当前目标：%s · 传送 %d 金币（余额 %d）%s",
            Zone.Name,
            Status.TeleportCost or MineTeleportConfig.TeleportCost,
            Status.GoldCount or 0,
            (Status.LastMsg and Status.LastMsg ~= "") and (" · " .. Status.LastMsg) or ""
        )
    end
    SetText(GetW(Widget, "Txt_Prompt"), Line)
end

function BP_MineTeleportHall:ShowPrompt()
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
            ugcprint("[MineTeleport] 提示 UI 创建失败")
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

        local Facility = self
        if Widget.SetShopCallbacks then
            Widget:SetShopCallbacks({
                OnUnlock = function()
                    Facility:OnUnlockClicked()
                end,
                OnQuick = function()
                    Facility:OnTeleportClicked()
                end,
                OnManual = function()
                    Facility:OnCycleZoneClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        end
        self:RefreshPromptUI()
        ugcprint("[MineTeleport] 大厅面板已显示")
    end)
end

function BP_MineTeleportHall:HidePrompt()
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

function BP_MineTeleportHall:OnCloseClicked()
    self:HidePrompt()
end

function BP_MineTeleportHall:OnUnlockClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    ugcprint("[MineTeleport] 请求解锁")
    if PC.RequestUnlockMineTeleport then
        PC:RequestUnlockMineTeleport()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockMineTeleport")
    end
end

function BP_MineTeleportHall:OnTeleportClicked()
    if not self.bLocalPlayerInside then
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        return
    end
    local ZoneId = self.SelectedZoneId or 1
    ugcprint("[MineTeleport] 请求传送 ZoneId=" .. tostring(ZoneId))
    if PC.RequestTeleportToMineZone then
        PC:RequestTeleportToMineZone(ZoneId)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportToMineZone", ZoneId)
    end
end

function BP_MineTeleportHall:OnCycleZoneClicked()
    if not self.bLocalPlayerInside then
        return
    end
    self.SelectedZoneId = MineTeleportConfig.NextZoneId(self.SelectedZoneId)
    local Zone = MineTeleportConfig.GetZone(self.SelectedZoneId)
    ugcprint("[MineTeleport] 切换目标 -> " .. tostring(self.SelectedZoneId) .. " " .. (Zone and Zone.Name or "?"))
    self:RefreshPromptUI()
end

return BP_MineTeleportHall
