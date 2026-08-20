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
            SpawnCost = 0,
            SPAWN_ZONE_ID = 6,
            SpawnPoint = { X = 21045.953125, Y = 28685.033203, Z = 201.396744 },
            Zones = {
                [1] = { Name = "石滩" },
                [2] = { Name = "煤矿场" },
                [3] = { Name = "黄铜矿脉" },
                [4] = { Name = "深层矿区" },
                [5] = { Name = "宝石矿区" },
            },
            GetZone = function(ZoneId)
                local Id = tonumber(ZoneId) or 0
                if Id == 6 then
                    return { Name = "出生点", IsSpawn = true }
                end
                return MineTeleportConfig.Zones[Id]
            end,
            GetTotalCount = function() return 6 end,
            IsSpawnZone = function(ZoneId) return tonumber(ZoneId) == 6 end,
            GetTeleportCost = function(ZoneId)
                if tonumber(ZoneId) == 6 then return 0 end
                return 3000
            end,
            GetSpawnPoint = function()
                return MineTeleportConfig.SpawnPoint
            end,
            NextZoneId = function(CurrentId)
                local Id = (tonumber(CurrentId) or 1) + 1
                if Id > 6 then Id = 1 end
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

    Trigger.bGenerateOverlapEvents = true
    if Trigger.SphereRadius ~= nil then
        Trigger.SphereRadius = 300
    end
    if Trigger.SetSphereRadius then
        pcall(function() Trigger:SetSphereRadius(300) end)
    end

    local overlapOk, overlapErr = pcall(function()
        if Trigger.OnComponentBeginOverlap then
            Trigger.OnComponentBeginOverlap:Add(self.OnTriggerBeginOverlap, self)
        end
        if Trigger.OnComponentEndOverlap then
            Trigger.OnComponentEndOverlap:Add(self.OnTriggerEndOverlap, self)
        end
    end)

    local curRadius = 0
    pcall(function() curRadius = Trigger.SphereRadius end)

    local zoneName = "?"
    local zone = MineTeleportConfig and MineTeleportConfig.GetZone(self.SelectedZoneId)
    if zone then zoneName = zone.Name end
    ugcprint(string.format("[MineTeleport] ✅ 传送大厅初始化 (矿区=%s, ZoneId=%d, 半径=%.0f, Overlap=%s, BindOk=%s)",
        zoneName, self.SelectedZoneId or 1, curRadius,
        tostring(Trigger.bGenerateOverlapEvents), tostring(overlapOk)))
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
    local Zone = MineTeleportConfig.GetZone(self.SelectedZoneId) or { Name = "?" }
    local IsSpawn = MineTeleportConfig.IsSpawnZone(self.SelectedZoneId)
    local TargetCost = MineTeleportConfig.GetTeleportCost(self.SelectedZoneId)

    SetText(GetW(Widget, "Txt_Unlock"), string.format("解锁大厅 (%d)", UnlockCost))
    if IsSpawn then
        SetText(GetW(Widget, "Txt_Quick"), string.format("返回出生点 (%d)", TargetCost))
    else
        SetText(GetW(Widget, "Txt_Quick"), string.format("传送·%s (%d)", Zone.Name, TargetCost))
    end
    SetText(GetW(Widget, "Txt_Manual"), "切换")
    SetText(GetW(Widget, "Txt_Enter"), "")
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
    Status.ZoneName = Zone.Name
    Status.TargetCost = MineTeleportConfig.GetTeleportCost(self.SelectedZoneId)
    Status.TargetIsSpawn = MineTeleportConfig.IsSpawnZone(self.SelectedZoneId)

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
            ugcprint("[MineTeleport] 🎯 设置UI回调")
            Widget:SetShopCallbacks({
                OnUnlock = function()
                    ugcprint("[MineTeleport] 🖱️ 解锁")
                    Facility:OnUnlockClicked()
                end,
                OnQuick = function()
                    if MineTeleportConfig.IsSpawnZone(Facility.SelectedZoneId) then
                        ugcprint("[MineTeleport] 🖱️ 返回出生点")
                        Facility:OnReturnToSpawnClicked()
                    else
                        ugcprint("[MineTeleport] 🖱️ 传送至矿区")
                        Facility:OnTeleportClicked()
                    end
                end,
                OnManual = function()
                    ugcprint("[MineTeleport] 🖱️ 切换")
                    Facility:OnSwitchZoneClicked()
                end,
                OnEnter = function()
                    ugcprint("[MineTeleport] 🖱️ Enter(未使用)")
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
    local NextName = NextZone and NextZone.Name or "?"
    ugcprint(string.format("[MineTeleport] ➡️ 切换: → %s", NextName))
    self.SelectedZoneId = NextId
    self:RefreshPromptUI()
end

function BP_MineTeleportHall:OnTeleportClicked()
    if not self.bLocalPlayerInside then
        ugcprint("[MineTeleport] ⚠️ 不在大厅内")
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        ugcprint("[MineTeleport] ❌ 传送失败: PC为nil")
        return
    end
    local ZoneId = self.SelectedZoneId or 1
    local IsSpawn = MineTeleportConfig.IsSpawnZone(ZoneId)

    if IsSpawn then
        ugcprint("[MineTeleport] 🏠 转发生: 出生点")
        self:OnReturnToSpawnClicked()
        return
    end

    local Zone = MineTeleportConfig.GetZone(ZoneId) or {}
    local Cost = MineTeleportConfig.GetTeleportCost(ZoneId)
    ugcprint(string.format("[MineTeleport] 🚀 传送至 %s (矿区%d, 费用%d)",
        Zone.Name or "?", ZoneId, Cost))
    if PC.RequestTeleportToMineZone then
        PC:RequestTeleportToMineZone(ZoneId)
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_TeleportToMineZone", ZoneId)
    end
end

function BP_MineTeleportHall:OnReturnToSpawnClicked()
    if not self.bLocalPlayerInside then
        ugcprint("[MineTeleport] ⚠️ 不在大厅内")
        return
    end
    local PC = GetLocalPC()
    if PC == nil then
        ugcprint("[MineTeleport] ❌ 返回出生点失败: PC为nil")
        return
    end
    local spawn = MineTeleportConfig.GetSpawnPoint()
    local sx = spawn and spawn.X or 0
    local sy = spawn and spawn.Y or 0
    local sz = spawn and spawn.Z or 192
    ugcprint(string.format("[MineTeleport] 🏠 返回出生点 (%.0f,%.0f,%.0f)", sx, sy, sz))
    if PC.RequestReturnToSpawn then
        PC:RequestReturnToSpawn()
    else
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_ReturnToSpawn")
    end
end

return BP_MineTeleportHall
