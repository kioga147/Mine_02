---@class BP_MinerShop_C:AActor
---@field InteractTrigger USphereComponent
---@field BuildingMesh UStaticMeshComponent
---@field DefaultSceneRoot USceneComponent
--Edit Below--
local ShopConfig = nil
do
    local ok, mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.Common.ShopConfig')
    end)
    if ok and type(mod) == 'table' then ShopConfig = mod else ShopConfig = {} end
end

local BP_MinerShop = {
    bLocalPlayerInside = false,
    bPromptDismissed = false,
    PromptWidget = nil,
    SelectedToolIndex = 1,
    bPromptOpening = false,
    OwnedToolCache = {},
    BpLevelCache = 1,
    RefreshTimer = nil,
}

local PROMPT_UI_PATH = 'Asset/Blueprint/Prefabs/UI/WBP_JadeFacilityPrompt.WBP_JadeFacilityPrompt_C'
local PROMPT_HIDE_DISTANCE = 420
local PROMPT_REFRESH_INTERVAL = 0.5

local function GetLocalPC()
    return UGCGameSystem.GetLocalPlayerController()
end

local function GetW(Widget, Name)
    if not Widget then return nil end
    if Widget[Name] then return Widget[Name] end
    if Widget.GetWidgetFromName then
        local ok, w = pcall(function() return Widget:GetWidgetFromName(Name) end)
        if ok then return w end
    end
    return nil
end

local function SetText(Widget, Text)
    if Widget and Widget.SetText then
        pcall(function() Widget:SetText(tostring(Text or '')) end)
    end
end

local function SetEnabled(Widget, bEnable)
    if Widget and Widget.SetIsEnabled then
        pcall(function() Widget:SetIsEnabled(bEnable) end)
    end
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
    local AX = tonumber(A.X or A.x) or 0
    local AY = tonumber(A.Y or A.y) or 0
    local AZ = tonumber(A.Z or A.z) or 0
    local BX = tonumber(B.X or B.x) or 0
    local BY = tonumber(B.Y or B.y) or 0
    local BZ = tonumber(B.Z or B.z) or 0
    local DX = AX - BX
    local DY = AY - BY
    local DZ = AZ - BZ
    return DX * DX + DY * DY + DZ * DZ
end

function BP_MinerShop:IsCurrentToolOwned()
    local pc = GetLocalPC()
    if not pc then return false end
    local tool = ShopConfig.GetTool(self.SelectedToolIndex)
    if not tool or not tool.ItemId then return false end
    if self.OwnedToolCache[self.SelectedToolIndex] then return true end
    if not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetItemCountV2 then return false end
    local ok, count = pcall(UGCBackpackSystemV2.GetItemCountV2, pc, tool.ItemId)
    local got = ok and (tonumber(count) or 0) > 0
    if got then self.OwnedToolCache[self.SelectedToolIndex] = true end
    return got
end

function BP_MinerShop:ReceiveBeginPlay()
    local tri = self.InteractTrigger
    if not tri then return end
    if tri.SetGenerateOverlapEvents then
        tri:SetGenerateOverlapEvents(true)
    else
        tri.bGenerateOverlapEvents = true
    end
    if tri.SetSphereRadius then
        tri:SetSphereRadius(80)
    elseif tri.SphereRadius ~= nil then
        tri.SphereRadius = 80
    end
    tri.OnComponentBeginOverlap:Add(self.OnEnter, self)
    tri.OnComponentEndOverlap:Add(self.OnLeave, self)
    self:StartRefreshTimer()
end

function BP_MinerShop:OnEnter(_, OtherActor)
    if OtherActor ~= UGCGameSystem.GetLocalPlayerPawn() then return end
    self.bLocalPlayerInside = true
    if self.bPromptDismissed then return end
    self:ShowPrompt()
end

function BP_MinerShop:OnLeave(_, OtherActor)
    if OtherActor ~= UGCGameSystem.GetLocalPlayerPawn() then return end
    self.bLocalPlayerInside = false
    self.bPromptDismissed = false
    self:HidePrompt()
end

function BP_MinerShop:IsLocalPlayerNear(Distance)
    local LocalPawn = UGCGameSystem.GetLocalPlayerPawn()
    local PawnLoc = GetActorLocationSafe(LocalPawn)
    local ShopLoc = GetComponentLocationSafe(self.InteractTrigger) or GetActorLocationSafe(self)
    local DistSq = GetDistanceSq(PawnLoc, ShopLoc)
    if DistSq == nil then
        return false
    end
    return DistSq <= Distance * Distance
end

function BP_MinerShop:StartRefreshTimer()
    self:StopRefreshTimer()
    if UGCTimerUtility == nil or UGCTimerUtility.CreateLuaTimer == nil then
        return
    end
    local Shop = self
    local Ok, Handle = pcall(function()
        return UGCTimerUtility.CreateLuaTimer(PROMPT_REFRESH_INTERVAL, function()
            if Shop.PromptWidget ~= nil and not Shop:IsLocalPlayerNear(PROMPT_HIDE_DISTANCE) then
                Shop.bLocalPlayerInside = false
                Shop.bPromptDismissed = false
                Shop:HidePrompt()
            end
        end, true)
    end)
    if Ok then
        self.RefreshTimer = Handle
    end
end

function BP_MinerShop:StopRefreshTimer()
    local Handle = self.RefreshTimer
    self.RefreshTimer = nil
    if Handle ~= nil and UGCTimerUtility and UGCTimerUtility.RemoveLuaTimer then
        pcall(function()
            UGCTimerUtility.RemoveLuaTimer(Handle)
        end)
    end
end

function BP_MinerShop:ShowPrompt()
    if self.PromptWidget or self.bPromptOpening then
        if self.PromptWidget then self:RefreshUI() end
        return
    end
    if self.bPromptDismissed then
        return
    end
    self.bPromptOpening = true
    if self.PromptWidget then pcall(function() self.PromptWidget:SetShopCallbacks(nil) end); pcall(function() self.PromptWidget:RemoveFromParent() end); self.PromptWidget = nil end
    local pc = GetLocalPC(); if pc then pc.OnShopNotify = nil end
    local path = UGCGameSystem.GetUGCResourcesFullPath(PROMPT_UI_PATH)
    UGCWidgetManagerSystem.CreateWidgetAsync(path, function(Widget)
        self.bPromptOpening = false
        if not Widget or not self.bLocalPlayerInside then
            if Widget and Widget.RemoveFromParent then Widget:RemoveFromParent() end
            return
        end
        self.PromptWidget = Widget
        UGCWidgetManagerSystem.AddToSlot(Widget, 'UI.UISlot.MainUISlot_High', 0, {
            Anchors = {
                Minimum = Vector2D.New(0.22, 0.01),
                Maximum = Vector2D.New(0.78, 0.18)
            }
        })
        if Widget.ApplyPromptLayout then
            pcall(function() Widget:ApplyPromptLayout() end)
        end
        -- hide gaps
        local function H(w,n) local x=GetW(w,n); if x then pcall(function() x:SetVisibility(1) end) end end
        H(Widget,'Gap_Unlock'); H(Widget,'Gap_Quick'); H(Widget,'Gap_Manual'); H(Widget,'Gap_Close')
        local F = self
        Widget:SetShopCallbacks({
            OnUnlock = function() F:OnSwitchTool() end,
            OnQuick  = function() F:OnBuyTool() end,
            OnManual = function() F:OnUpgradeBackpack() end,
            OnClose  = function() F:OnClose() end,
        })
        local pc = GetLocalPC()
        if pc then
            pc.OnShopNotify = function(Msg)
                if F.bLocalPlayerInside and F.PromptWidget then
                    -- immediate cache update
                    if Msg and string.find(Msg, '成功') then
                        if string.find(Msg, '购买') then
                            F.OwnedToolCache[F.SelectedToolIndex] = true
                        elseif string.find(Msg, '背包升级') then
                            F.BpLevelCache = F.BpLevelCache + 1
                        end
                    end
                    F:RefreshUI()
                end
            end
        end
        self:RefreshUI()
    end)
end

function BP_MinerShop:OnClose()
    self.bPromptDismissed = true
    self:HidePrompt()
end

function BP_MinerShop:HidePrompt()
    self.bPromptOpening = false
    local pc = GetLocalPC()
    if pc then pc.OnShopNotify = nil end
    if self.PromptWidget then
        pcall(function() self.PromptWidget:SetShopCallbacks(nil) end)
        if self.PromptWidget.RemoveFromParent then
            pcall(function() self.PromptWidget:RemoveFromParent() end)
        end
        self.PromptWidget = nil
    end
end

function BP_MinerShop:OnSwitchTool()
    if not self.bLocalPlayerInside then return end
    self.SelectedToolIndex = ShopConfig.NextToolIndex(self.SelectedToolIndex)
    self:RefreshUI()
end

function BP_MinerShop:OnBuyTool()
    if not self.bLocalPlayerInside then return end
    if self:IsCurrentToolOwned() then return end
    local pc = GetLocalPC()
    if not pc then return end
    UnrealNetwork.CallUnrealRPC(pc, pc, 'Server_BuyTool', self.SelectedToolIndex)
end

function BP_MinerShop:OnUpgradeBackpack()
    if not self.bLocalPlayerInside then return end
    local pc = GetLocalPC()
    if not pc then return end
    UnrealNetwork.CallUnrealRPC(pc, pc, 'Server_UpgradeBackpack')
end

function BP_MinerShop:RefreshUI()
    local W = self.PromptWidget
    if not W then return end

    local tool = ShopConfig.GetTool(self.SelectedToolIndex)
    local tName = (tool and tool.Name) or '?'
    local tCost = (tool and tool.Cost) or 0
    local tRange = (tool and tool.Range) or '?'
    local tDmg = (tool and tool.Damage) or 0
    local tLv = (tool and tool.MineLevel) or 0
    local owned = self:IsCurrentToolOwned()

    SetText(GetW(W, 'Txt_Unlock'), '切换工具')
    if owned then
        SetText(GetW(W, 'Txt_Quick'), tName .. ' (已拥有)')
    else
        SetText(GetW(W, 'Txt_Quick'), '购买 ' .. tName .. ' (' .. tCost .. '金)')
    end
    SetEnabled(GetW(W, 'Btn_Quick'), not owned)

    local pc = GetLocalPC()
    local bpLv = self.BpLevelCache or 1
    if pc and pc.BackpackLevel and tonumber(pc.BackpackLevel) > bpLv then 
        bpLv = pc.BackpackLevel
        self.BpLevelCache = bpLv
    end
    local maxLv = ShopConfig.GetMaxBackpackLevel()
    local curCfg = ShopConfig.GetBackpackLevel(bpLv)
    local curSlots = (curCfg and curCfg.Slots) or 10

    if bpLv >= maxLv then
        SetText(GetW(W, 'Txt_Manual'), '背包已满级 (' .. curSlots .. '格)')
    else
        local nextCfg = ShopConfig.GetBackpackLevel(bpLv + 1)
        local nextSlots = (nextCfg and nextCfg.Slots) or curSlots
        local bpCost = (nextCfg and nextCfg.Cost) or 0
        SetText(GetW(W, 'Txt_Manual'), '背包 Lv.' .. bpLv .. '->' .. (bpLv+1) .. ' (' .. nextSlots .. '格) ' .. bpCost .. '金')
    end
    SetEnabled(GetW(W, 'Btn_Manual'), bpLv < maxLv)

    SetText(GetW(W, 'Txt_Close'), '关闭')

    local st = owned and 'OWNED' or 'BUYABLE'
    local detail = tName .. ' [' .. st .. '] | Dmg:' .. tDmg .. ' Lv:' .. tLv .. ' | BP:' .. curSlots .. '格(Lv.' .. bpLv .. '/' .. maxLv .. ')'
    SetText(GetW(W, 'Txt_Prompt'), detail)
end
function BP_MinerShop:ReceiveEndPlay()
    self:StopRefreshTimer()
    self:HidePrompt()
    local tri = self.InteractTrigger
    if tri then
        if tri.OnComponentBeginOverlap then
            pcall(function() tri.OnComponentBeginOverlap:Remove(self.OnEnter, self) end)
        end
        if tri.OnComponentEndOverlap then
            pcall(function() tri.OnComponentEndOverlap:Remove(self.OnLeave, self) end)
        end
    end
end

return BP_MinerShop
