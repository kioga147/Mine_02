---@class BP_MineTeleportHall_C:AActor
---@field PromptAnchor USceneComponent
---@field InteractTrigger USphereComponent
---@field BuildingMesh UStaticMeshComponent
---@field DefaultSceneRoot1 USceneComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
--- 矿区传送大厅：解锁 8500，传送矿区 3000，返回出生点 0
--- 复用鉴定所提示 UI：解锁 / 传送(当前矿区) / 返回出生点 / 关闭
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
            ReturnCost = 0,
            SpawnPoint = { X = 20830, Y = 28740, Z = 192 },
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
            GetSpawnPoint = function()
                return MineTeleportConfig.SpawnPoint
            end,
            GetReturnCost = function()
                return 0
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
    bIsReturnHall = false,
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

local function FindNearestZone(self)
    local myPos = self.GetActorLocation and self:GetActorLocation() or nil
    if myPos == nil then
        return 1
    end
    local bestId = 1
    local bestDist = math.huge
    for zid = 1, 5 do
        local zone = MineTeleportConfig and MineTeleportConfig.GetZone(zid)
        if zone then
            local dx = (zone.HallX or zone.PadX or 0) - myPos.X
            local dy = (zone.HallY or zone.PadY or 0) - myPos.Y
            local dist = dx * dx + dy * dy
            if dist < bestDist then
                bestDist = dist
                bestId = zid
            end
        end
    end
    return bestId
end

function BP_MineTeleportHall:ReceiveBeginPlay()
    if BP_MineTeleportHall.SuperClass and BP_MineTeleportHall.SuperClass.ReceiveBeginPlay then
        pcall(BP_MineTeleportHall.SuperClass.ReceiveBeginPlay, self)
    end

    if self.SelectedZoneId == nil or self.SelectedZoneId == 0 then
        self.SelectedZoneId = FindNearestZone(self)
    end

    local Trigger = GetInteractTrigger(self)
    if Trigger == nil then
        ugcprint("[MineTeleport] ❌ InteractTrigger 组件不存在，请在蓝图中添加 USphereComponent 并命名为 InteractTrigger")
        return
    end
    if self.bOverlapBound then
        return
    end
    self.bOverlapBound = true

    pcall(function()
        Trigger.bGenerateOverlapEvents = true
        if Trigger.SetSphereRadius then
            Trigger:SetSphereRadius(300, true)
        elseif Trigger.SphereRadius ~= nil then
            Trigger.SphereRadius = 300
        end
    end)

    if Trigger.OnComponentBeginOverlap then
        Trigger.OnComponentBeginOverlap:Add(self.OnTriggerBeginOverlap, self)
    end
    if Trigger.OnComponentEndOverlap then
        Trigger.OnComponentEndOverlap:Add(self.OnTriggerEndOverlap, self)
    end

    local zoneName = "?"
    local zone = MineTeleportConfig and MineTeleportConfig.GetZone(self.SelectedZoneId)
    if zone then zoneName = zone.Name end
    ugcprint(string.format("[MineTeleport] ✅ 传送大厅初始化完成 (矿区=%s, ZoneId=%d, 触发半径=300)",
        zoneName, self.SelectedZoneId or 1))
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
    self:ShowPrompt()
end

function BP_MineTeleportHall:OnTriggerEndOverlap(
    OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex)
    if not IsLocalPlayerPawn(OtherActor) then
        return
    end
    self.bLocalPlayerInside = false
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
    end
    PC.OnMineReturnedToSpawn = function()
        if Facility.bLocalPlayerInside then
            Facility:RefreshPromptUI()
        end
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
    PC.OnMineReturnedToSpawn = nil
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
    local ReturnCost = MineTeleportConfig.GetReturnCost()
    local Zone = MineTeleportConfig.GetZone(self.SelectedZoneId) or { Name = "?" }

    SetText(GetW(Widget, "Txt_Unlock"), string.format("解锁传送大厅 (%d)", UnlockCost))
    SetText(GetW(Widget, "Txt_Quick"), string.format("传送·%s (%d)", Zone.Name, TeleportCost))
    SetText(GetW(Widget, "Txt_Manual"), "切换矿区")
    SetText(GetW(Widget, "Txt_Enter"), string.format("返回出生点 (%d)", ReturnCost))
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

    local Zone = MineTeleportConfig.GetZone(self.SelectedZoneId) or { Name = "?" }
    Status.Mode = "teleport"
    Status.SelectedZoneId = self.SelectedZoneId
    Status.JadeCount = 1
    Status.QuickCost = Status.TeleportCost or MineTeleportConfig.TeleportCost or 0
    Status.ReturnCost = MineTeleportConfig.GetReturnCost()
    Status.ZoneName = Zone.Name

    self:ApplyTeleportPromptLabels(Widget)
    if Widget.RefreshShopState then
        pcall(function()
            Widget:RefreshShopState(Status)
        end)
    end
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
    ugcprint("[MineTeleport] 📱 加载传送UI: " .. tostring(Path))
    UGCWidgetManagerSystem.CreateWidgetAsync(Path, function(Widget)
        self.bPromptOpening = false
        if not Widget then
            ugcprint("[MineTeleport] ❌ UI加载失败")
            return
        end
        ugcprint("[MineTeleport] ✅ UI加载成功")
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
            ugcprint("[MineTeleport] 🎯 设置UI回调 (SetShopCallbacks)")
            Widget:SetShopCallbacks({
                OnUnlock = function()
                    ugcprint("[MineTeleport] 🖱️ 点击解锁按钮")
                    Facility:OnUnlockClicked()
                end,
                OnQuick = function()
                    ugcprint("[MineTeleport] 🖱️ 点击传送按钮")
                    Facility:OnTeleportClicked()
                end,
                OnManual = function()
                    ugcprint("[MineTeleport] 🖱️ 点击切换矿区按钮")
                    Facility:OnSwitchZoneClicked()
                end,
                OnEnter = function()
                    ugcprint("[MineTeleport] 🖱️ 点击返回出生点按钮")
                    Facility:OnReturnToSpawnClicked()
                end,
                OnClose = function()
                    Facility:OnCloseClicked()
                end,
            })
        else
            ugcprint("[MineTeleport] ⚠️ Widget 没有 SetShopCallbacks 方法")
        end
        self:RefreshPromptUI()
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
        ugcprint("[MineTeleport] ⚠️ 点击解锁但不在大厅内 (bLocalPlayerInside=false)")
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        ugcprint("[MineTeleport] ❌ 解锁失败: PC为nil")
        return
    end
    ugcprint("[MineTeleport] 🔓 开始解锁传送大厅")
    if PC.RequestUnlockMineTeleport then
        PC:RequestUnlockMineTeleport()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_UnlockMineTeleport")
    end
end

function BP_MineTeleportHall:OnSwitchZoneClicked()
    local NextId = MineTeleportConfig.NextZoneId(self.SelectedZoneId)
    local NextZone = MineTeleportConfig.GetZone(NextId)
    local NextName = NextZone and NextZone.Name or tostring(NextId)
    ugcprint(string.format("[MineTeleport] ➡️ 切换矿区: %s(%d) → %s(%d)",
        (MineTeleportConfig.GetZone(self.SelectedZoneId) or {}).Name or "?",
        self.SelectedZoneId,
        NextName, NextId))
    self.SelectedZoneId = NextId
    self:RefreshPromptUI()
end

function BP_MineTeleportHall:OnTeleportClicked()
    if not self.bLocalPlayerInside then
        ugcprint("[MineTeleport] ⚠️ 点击传送但不在大厅内 (bLocalPlayerInside=false)")
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        ugcprint("[MineTeleport] ❌ 传送失败: PC为nil")
        return
    end
    local ZoneId = self.SelectedZoneId or 1
    ugcprint(string.format("[MineTeleport] 🚀 尝试传送至矿区 %d (PC=%s, RequestFunc=%s)",
        ZoneId,
        tostring(PC),
        tostring(PC.RequestTeleportToMineZone ~= nil)))
    if PC.RequestTeleportToMineZone then
        PC:RequestTeleportToMineZone(ZoneId)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportToMineZone", ZoneId)
    end
end

function BP_MineTeleportHall:OnReturnToSpawnClicked()
    if not self.bLocalPlayerInside then
        ugcprint("[MineTeleport] ⚠️ 点击返回出生点但不在大厅内 (bLocalPlayerInside=false)")
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        ugcprint("[MineTeleport] ❌ 返回出生点失败: PC为nil")
        return
    end
    ugcprint(string.format("[MineTeleport] 🏠 返回出生点 (PC=%s)", tostring(PC)))
    if PC.RequestReturnToSpawn then
        PC:RequestReturnToSpawn()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ReturnToSpawn")
    end
end

return BP_MineTeleportHall
