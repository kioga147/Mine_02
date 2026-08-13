---@class WBP_TitleBar_C:UGCGenericCharacterPositionWidget
---@field CanvasPanel_0 UCanvasPanel
---@field CanvasPanel_309 UCanvasPanel
---@field Icon_Image UImage
---@field InScreenPnl UCanvasPanel
---@field TextBlock_0 UTextBlock
--Edit Below--
local WBP_TitleBar = { bInitDoOnce = false }
local TitleConfig = nil
local TitleTimerSeq = 0

local TITLE_ICON_TARGET_WIDTH = 120

local function NextTitleTimerName()
    TitleTimerSeq = TitleTimerSeq + 1
    return "TitleBarRefresh_" .. tostring(TitleTimerSeq)
end

local function LoadTitleConfig()
    if TitleConfig then
        return TitleConfig
    end
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.TitleConfig")
    end)
    if Ok and type(Mod) == "table" then
        TitleConfig = Mod
    else
        TitleConfig = {}
    end
    return TitleConfig
end

local function GetSafeTitleID(Owner)
    if Owner == nil then
        return 0
    end
    local Ok, ID = pcall(function()
        local Value = Owner.CurrentTitleID
        if Value == nil then
            Value = Owner.ClientCurrentTitleID
        end
        return Value
    end)
    if Ok and ID ~= nil then
        return math.floor(tonumber(ID) or 0)
    end
    return 0
end

local function GetLocalPC()
    if UGCGameSystem and UGCGameSystem.GetLocalPlayerController then
        local Ok, PC = pcall(UGCGameSystem.GetLocalPlayerController)
        if Ok and PC then
            return PC
        end
    end
    return nil
end

local function GetLocalPawnByPC(PC)
    if PC and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
        local Ok, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, PC)
        if Ok and Pawn then
            return Pawn
        end
    end
    return nil
end

local function GetTargetDesc(Target)
    if Target == nil then
        return "nil"
    end
    local Ok, Name = pcall(function()
        return Target:GetName()
    end)
    if Ok and Name ~= nil then
        return tostring(Name)
    end
    return tostring(Target)
end

local function GetTextureSize(Texture)
    if not Texture then
        return 0, 0
    end
    local W, H = 0, 0
    if Texture.Blueprint_GetSizeX then
        local OkW, VW = pcall(Texture.Blueprint_GetSizeX, Texture)
        if OkW then W = math.floor(tonumber(VW) or 0) end
    end
    if Texture.Blueprint_GetSizeY then
        local OkH, VH = pcall(Texture.Blueprint_GetSizeY, Texture)
        if OkH then H = math.floor(tonumber(VH) or 0) end
    end
    if W <= 0 and Texture.ImportedSize then
        local S = Texture.ImportedSize
        W = math.floor(tonumber(S and S.X) or 0)
        H = math.floor(tonumber(S and S.Y) or 0)
    end
    return W, H
end

local function ApplyTitleIconSize(Widget, Texture)
    if not Widget or not Widget.Icon_Image then
        return
    end
    local TW, TH = GetTextureSize(Texture)
    if TW <= 0 or TH <= 0 then
        return
    end
    local Ratio = TH / TW
    local TargetW = TITLE_ICON_TARGET_WIDTH
    local TargetH = math.max(8, math.floor(TargetW * Ratio))
    local Slot = Widget.Icon_Image.Slot
    if Slot and Slot.SetSize then
        pcall(Slot.SetSize, Slot, { X = TargetW, Y = TargetH })
        ugcprint(string.format("[称号Bar] 图标尺寸: %dx%d -> %dx%d", TW, TH, TargetW, TargetH))
    end
    if Widget.CanvasPanel_309 and Widget.CanvasPanel_309.Slot and Widget.CanvasPanel_309.Slot.SetSize then
        pcall(Widget.CanvasPanel_309.Slot.SetSize, Widget.CanvasPanel_309.Slot, { X = TargetW, Y = TargetH })
    end
end

function WBP_TitleBar:GetCurrentTitleID()
    local ID = GetSafeTitleID(self._TargetActor)
    if ID > 0 then
        return ID
    end
    ID = GetSafeTitleID(self.OwnerCharacter)
    if ID > 0 then
        return ID
    end
    local PC = GetLocalPC()
    if PC then
        ID = GetSafeTitleID(PC)
        if ID > 0 then
            return ID
        end
        ID = GetSafeTitleID(GetLocalPawnByPC(PC))
        if ID > 0 then
            return ID
        end
    end
    return 0
end

function WBP_TitleBar:RefreshTitle()
    local Cfg = LoadTitleConfig()
    local TitleID = self:GetCurrentTitleID()
    if self._LastLogTitleID ~= TitleID then
        self._LastLogTitleID = TitleID
        ugcprint(string.format("[称号Bar] RefreshTitle: TitleID=%d TargetActor=%s",
            TitleID, GetTargetDesc(self._TargetActor)))
    end
    local Entry = nil
    if Cfg and Cfg.Get then
        Entry = Cfg.Get(TitleID)
    end
    if self.Icon_Image == nil then
        return
    end
    if TitleID == self._LastTitleID and self._IconLoaded then
        return
    end
    self._LastTitleID = TitleID
    if Entry and Entry.IconPath then
        local FullPath = UGCGameSystem.GetUGCResourcesFullPath(Entry.IconPath)
        if not FullPath or FullPath == '' then
            ugcprint("[称号Bar] 图标路径转换失败: " .. tostring(Entry.IconPath))
            self._IconLoaded = false
            return
        end
        local OkTex, Texture = pcall(UGCObjectUtility.LoadObject, FullPath)
        if OkTex and Texture then
            self.Icon_Image:SetBrushFromTexture(Texture, true)
            ApplyTitleIconSize(self, Texture)
            self._IconLoaded = true
            ugcprint("[称号Bar] 图标加载成功: " .. tostring(Entry.IconPath) .. " FullPath=" .. tostring(FullPath))
        else
            self._IconLoaded = false
            ugcprint("[称号Bar] 图标加载失败: " .. tostring(Entry.IconPath) .. " FullPath=" .. tostring(FullPath))
        end
        self.Icon_Image:SetVisibility(ESlateVisibility.Visible)
    else
        self.Icon_Image:SetVisibility(ESlateVisibility.Collapsed)
        self._IconLoaded = false
    end
end

function WBP_TitleBar:Event_InitParam(InParam, InDestinPos, InTargetActor)
    if InTargetActor ~= nil then
        self._TargetActor = InTargetActor
    end
    if self.SetStateWidgetPanel then
        pcall(self.SetStateWidgetPanel, self, self.InScreenPnl, self.OutScreenPnl, self.InArrowWidget, nil, nil)
    end
    if self.SetVisibility then
        pcall(self.SetVisibility, self, ESlateVisibility.HitTestInvisible)
    end
    if self._TitleRefreshTimer == nil and Timer and Timer.InsertTimer then
        self._TitleRefreshTimer = Timer.InsertTimer(1.0, function()
            if UE.IsValid(self) then
                self:RefreshTitle()
            end
        end, true, NextTitleTimerName(), 0)
    end
    self:RefreshTitle()
end

function WBP_TitleBar:Event_InitParamEnd()
    self:RefreshTitle()
end

function WBP_TitleBar:Destruct()
    if self._TitleRefreshTimer ~= nil and Timer and Timer.RemoveTimer then
        Timer.RemoveTimer(self._TitleRefreshTimer)
        self._TitleRefreshTimer = nil
    end
end

-- [Editor Generated Lua] function define Begin:
function WBP_TitleBar:LuaInit()
	if self.bInitDoOnce then
		return;
	end
	self.bInitDoOnce = true;
	-- [Editor Generated Lua] BindingProperty Begin:
	-- [Editor Generated Lua] BindingProperty End;
	
	-- [Editor Generated Lua] BindingEvent Begin:
	-- [Editor Generated Lua] BindingEvent End;
end

function WBP_TitleBar:TextBlock_0_Text(ReturnValue)
	return "";
end

-- [Editor Generated Lua] function define End;

return WBP_TitleBar