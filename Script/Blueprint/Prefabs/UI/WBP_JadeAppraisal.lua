---@class WBP_JadeAppraisal_C:UAEUserWidget
---@field Btn_Close UButton
---@field Btn_ConfirmNo UButton
---@field Btn_ConfirmYes UButton
---@field Btn_Sell UButton
---@field Cell_0 UButton
---@field Cell_1 UButton
---@field Cell_2 UButton
---@field Cell_3 UButton
---@field Cell_4 UButton
---@field Cell_5 UButton
---@field Cell_6 UButton
---@field Cell_7 UButton
---@field Cell_8 UButton
---@field Cell_9 UButton
---@field Cell_10 UButton
---@field Cell_11 UButton
---@field Cell_12 UButton
---@field Cell_13 UButton
---@field Cell_14 UButton
---@field Cell_15 UButton
---@field Cell_16 UButton
---@field Cell_17 UButton
---@field Cell_18 UButton
---@field Cell_19 UButton
---@field Cell_20 UButton
---@field Cell_21 UButton
---@field Cell_22 UButton
---@field Cell_23 UButton
---@field Cell_24 UButton
--Edit Below--
local BASE_VALUE = 600
local CELL_COUNT = 25
-- 对齐 Preview/WBP_JadeAppraisal_Preview.html（玉石深绿 + 金边卡片）
-- 注：UMG 无 CSS 渐变，适当提高不透明度与饱和度以贴近预览观感
local COLOR = {
    Brand = { R = 0.90, G = 0.78, B = 0.45, A = 1 },
    Title = { R = 0.93, G = 0.98, B = 0.95, A = 1 },
    ValueLabel = { R = 0.50, G = 0.90, B = 0.75, A = 1 },
    Value = { R = 0.98, G = 0.88, B = 0.55, A = 1 },
    ValueFlash = { R = 1.00, G = 0.97, B = 0.82, A = 1 },
    Hint = { R = 0.78, G = 0.94, B = 0.87, A = 0.78 },
    Legend = { R = 0.78, G = 0.94, B = 0.87, A = 0.70 },
    Corner = { R = 0.90, G = 0.78, B = 0.45, A = 0.90 },
    Dim = { R = 0.02, G = 0.05, B = 0.04, A = 0.72 },
    -- 外框金边（靠 Padding 露出一圈）
    PanelEdge = { R = 0.85, G = 0.72, B = 0.40, A = 0.95 },
    PanelBg = { R = 0.035, G = 0.095, B = 0.078, A = 0.96 },
    GoldLine = { R = 0.98, G = 0.88, B = 0.55, A = 0.95 },
    ValueCardEdge = { R = 0.50, G = 0.90, B = 0.75, A = 0.75 },
    ValueCard = { R = 0.08, G = 0.28, B = 0.22, A = 0.92 },
    GridFrameEdge = { R = 0.45, G = 0.85, B = 0.70, A = 0.55 },
    GridFrame = { R = 0.04, G = 0.12, B = 0.10, A = 0.65 },
    CellIdleBg = { R = 0.09, G = 0.24, B = 0.20, A = 1 },
    CellIdleTxt = { R = 0.78, G = 0.94, B = 0.87, A = 0.70 },
    CellHoverBg = { R = 0.18, G = 0.42, B = 0.34, A = 1 },
    CellHoverTxt = { R = 0.93, G = 0.98, B = 0.95, A = 1 },
    CellSelectedBg = { R = 0.92, G = 0.78, B = 0.38, A = 1 },
    CellSelectedTxt = { R = 0.12, G = 0.10, B = 0.04, A = 1 },
    CellFlashBg = { R = 0.98, G = 0.88, B = 0.55, A = 1 },
    CellFlashTxt = { R = 1.00, G = 0.98, B = 0.90, A = 1 },
    SellBg = { R = 0.16, G = 0.52, B = 0.40, A = 1 },
    SellHoverBg = { R = 0.28, G = 0.65, B = 0.50, A = 1 },
    SellTxt = { R = 0.93, G = 0.98, B = 0.95, A = 1 },
    CloseBg = { R = 0.35, G = 0.14, B = 0.12, A = 0.88 },
    CloseHoverBg = { R = 0.55, G = 0.24, B = 0.20, A = 1 },
    CloseTxt = { R = 0.95, G = 0.78, B = 0.74, A = 1 },
    ToastTxt = { R = 0.98, G = 0.88, B = 0.55, A = 1 },
    ConfirmDim = { R = 0.02, G = 0.05, B = 0.04, A = 0.18 },
    ConfirmEdge = { R = 0.85, G = 0.72, B = 0.40, A = 0.95 },
    ConfirmBg = { R = 0.05, G = 0.14, B = 0.11, A = 0.98 },
    ConfirmTxt = { R = 0.93, G = 0.98, B = 0.95, A = 1 },
    ConfirmYesBg = { R = 0.16, G = 0.52, B = 0.40, A = 1 },
    ConfirmNoBg = { R = 0.35, G = 0.14, B = 0.12, A = 0.92 },
}
local LEVEL_COLOR = {
    [1] = {
        Bg = { R = 0.18, G = 0.24, B = 0.21, A = 1 },
        Txt = { R = 0.65, G = 0.70, B = 0.66, A = 1 },
    },
    [2] = {
        Bg = { R = 0.16, G = 0.32, B = 0.25, A = 1 },
        Txt = { R = 0.60, G = 0.82, B = 0.70, A = 1 },
    },
    [3] = {
        Bg = { R = 0.14, G = 0.48, B = 0.35, A = 1 },
        Txt = { R = 0.55, G = 0.95, B = 0.80, A = 1 },
    },
    [4] = {
        Bg = { R = 0.42, G = 0.35, B = 0.14, A = 1 },
        Txt = { R = 0.98, G = 0.88, B = 0.55, A = 1 },
    },
    [5] = {
        Bg = { R = 0.55, G = 0.44, B = 0.20, A = 1 },
        Txt = { R = 1.00, G = 0.98, B = 0.88, A = 1 },
    },
}
local WBP_JadeAppraisal = {
    CurrentValue = BASE_VALUE,
    Opened = nil,
    bSelling = false,
    bBound = false,
    Hovered = nil,
    PendingConfirm = nil, -- 弹窗待确认的格子索引；已翻开格子不再弹窗
    bRevealPending = false, -- 等待服务端翻格回包
}
local function GetW(self, Name)
    if self[Name] ~= nil then
        return self[Name]
    end
    if self.GetWidgetFromName then
        return self:GetWidgetFromName(Name)
    end
    return nil
end
-- Mine_02 控件树中 SizeBox 名为 Cell_N_Wrapper（对齐 TESTWK 的 CellBox_N）
local function GetCellBox(self, Index)
    local Box = GetW(self, "CellBox_" .. tostring(Index))
    if Box then
        return Box
    end
    return GetW(self, "Cell_" .. tostring(Index) .. "_Wrapper")
end
local function MakeColor(C)
    if not C then
        return nil
    end
    if LinearColor and LinearColor.New then
        return LinearColor.New(C.R, C.G, C.B, C.A or 1)
    end
    return { R = C.R, G = C.G, B = C.B, A = C.A or 1 }
end
-- TextBlock 需要 FSlateColor，不能直接传 FLinearColor
local function MakeSlateColor(C)
    if not C then
        return nil
    end
    return {
        SpecifiedColor = { R = C.R, G = C.G, B = C.B, A = C.A or 1 },
        ColorUseRule = 0, -- UseColor_Specified
    }
end
local function ColorToHexRGB(C)
    if not C then
        return "FFFFFF"
    end
    local function Byte(V)
        local N = math.floor((V or 0) * 255 + 0.5)
        if N < 0 then N = 0 end
        if N > 255 then N = 255 end
        return string.format("%02X", N)
    end
    return Byte(C.R) .. Byte(C.G) .. Byte(C.B)
end
local function MakeVec2(X, Y)
    if Vector2D and Vector2D.New then
        return Vector2D.New(X, Y)
    end
    return nil
end
local function SetTextColor(Widget, C)
    if not Widget or not C then
        return
    end
    -- 优先官方 Hex API（本工程多处使用）
    if Widget.SetColorRGBStr then
        local Ok = pcall(function()
            Widget:SetColorRGBStr(ColorToHexRGB(C))
        end)
        if Ok then
            if Widget.SetOpacity and C.A and C.A < 0.999 then
                pcall(function()
                    Widget:SetOpacity(C.A)
                end)
            end
            return
        end
    end
    local Slate = MakeSlateColor(C)
    if Widget.SetColorAndOpacity then
        local Ok = pcall(function()
            Widget:SetColorAndOpacity(Slate)
        end)
        if Ok then
            return
        end
        -- 回退：部分环境可接受 LinearColor
        pcall(function()
            Widget:SetColorAndOpacity(MakeColor(C))
        end)
    elseif Widget.ColorAndOpacity ~= nil then
        Widget.ColorAndOpacity = Slate
    end
end
local function SetButtonBg(Btn, C)
    if not Btn or not C then
        return
    end
    local Col = MakeColor(C)
    local Plain = { R = C.R, G = C.G, B = C.B, A = C.A or 1 }
    if Btn.SetBackgroundColor then
        pcall(function()
            Btn:SetBackgroundColor(Col or Plain)
        end)
    end
    if Btn.BackgroundColor ~= nil then
        Btn.BackgroundColor = Col or Plain
    end
    -- 同步 WidgetStyle 各态 Tint，避免默认白底盖住主题色
    local Style = Btn.WidgetStyle
    if Style then
        local function TintBrush(Brush)
            if not Brush then
                return
            end
            if Brush.TintColor ~= nil then
                Brush.TintColor = MakeSlateColor(C)
            end
            if Brush.TintColor == nil and Brush.ResourceObject == nil then
                -- 某些版本 Tint 直接是 LinearColor
                pcall(function()
                    Brush.TintColor = Plain
                end)
            end
        end
        TintBrush(Style.Normal)
        TintBrush(Style.Hovered)
        TintBrush(Style.Pressed)
        TintBrush(Style.Disabled)
        Btn.WidgetStyle = Style
    end
end
local function SetBorderBg(Border, C)
    if not Border or not C then
        return
    end
    local Col = MakeColor(C)
    local Plain = { R = C.R, G = C.G, B = C.B, A = C.A or 1 }
    if Border.SetBrushColor then
        pcall(function()
            Border:SetBrushColor(Col or Plain)
        end)
    end
    if Border.BrushColor ~= nil then
        Border.BrushColor = Col or Plain
    end
    -- 同步 Background.Tint，确保无贴图 Border 也能显色
    local Bg = Border.Background
    if Bg then
        if Bg.TintColor ~= nil then
            local Ok = pcall(function()
                Bg.TintColor = MakeSlateColor(C)
            end)
            if not Ok then
                Bg.TintColor = Plain
            end
        end
        Border.Background = Bg
    end
end
-- 嵌套 Border 通过 Padding 露出外层描边（对齐 Preview 金边）
local function SetBorderPadding(Border, L, T, R, B)
    if not Border then
        return
    end
    T = T or L
    R = R or L
    B = B or T
    local Pad = { Left = L, Top = T, Right = R, Bottom = B }
    if Border.SetPadding then
        pcall(function()
            Border:SetPadding(Pad)
        end)
    elseif Border.Padding ~= nil then
        Border.Padding = Pad
    end
end
local function SetOpacity(Widget, Alpha)
    if Widget and Widget.SetRenderOpacity then
        Widget:SetRenderOpacity(Alpha)
    end
end
local function SetScale(Widget, X, Y)
    if not Widget or not Widget.SetRenderScale then
        return
    end
    local V = MakeVec2(X, Y or X)
    if V then
        Widget:SetRenderScale(V)
    end
end
local function IsSelfValid(self)
    if not self then
        return false
    end
    if UGCObjectUtility and UGCObjectUtility.IsObjectValid then
        return UGCObjectUtility.IsObjectValid(self)
    end
    return true
end
local function DelayCall(Name, Delay, Callback)
    if not UGCTimerUtility or not UGCTimerUtility.CreateLuaTimer then
        Callback()
        return
    end
    UGCTimerUtility.RemoveLuaTimerByName(Name)
    UGCTimerUtility.CreateLuaTimer(Delay, Callback, false, Name)
end
local function GetCanvasSlot(Widget)
    if not Widget then
        return nil
    end
    if UGCWidgetManagerSystem and UGCWidgetManagerSystem.SlotAsCanvasSlot then
        local Ok, Slot = pcall(function()
            return UGCWidgetManagerSystem.SlotAsCanvasSlot(Widget)
        end)
        if Ok and Slot then
            return Slot
        end
    end
    if WidgetLayoutLibrary and WidgetLayoutLibrary.SlotAsCanvasSlot then
        local Ok, Slot = pcall(function()
            return WidgetLayoutLibrary.SlotAsCanvasSlot(Widget)
        end)
        if Ok and Slot then
            return Slot
        end
    end
    return Widget.Slot
end
local function SetCanvasFill(Widget, ZOrder)
    local Slot = GetCanvasSlot(Widget)
    if not Slot then
        return false
    end
    if Slot.SetAnchors then
        Slot:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } })
    end
    if Slot.SetOffsets then
        Slot:SetOffsets({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
    elseif Slot.SetPosition and Slot.SetSize then
        Slot:SetPosition({ X = 0, Y = 0 })
    end
    if Slot.SetAutoSize then
        Slot:SetAutoSize(false)
    end
    if Slot.SetAlignment then
        Slot:SetAlignment({ X = 0.5, Y = 0.5 })
    end
    if ZOrder and Slot.SetZOrder then
        Slot:SetZOrder(ZOrder)
    end
    return true
end
local function SetCanvasCenterAuto(Widget, ZOrder)
    local Slot = GetCanvasSlot(Widget)
    if not Slot then
        return false
    end
    if Slot.SetAnchors then
        Slot:SetAnchors({ Minimum = { X = 0.5, Y = 0.5 }, Maximum = { X = 0.5, Y = 0.5 } })
    end
    if Slot.SetAlignment then
        Slot:SetAlignment({ X = 0.5, Y = 0.5 })
    end
    if Slot.SetPosition then
        Slot:SetPosition({ X = 0, Y = 0 })
    end
    if Slot.SetAutoSize then
        Slot:SetAutoSize(true)
    end
    if ZOrder and Slot.SetZOrder then
        Slot:SetZOrder(ZOrder)
    end
    return true
end

-- 水平居中、上下贴合画布（用左右等宽边距，避免 Left=-W/2 在部分环境下偏左）
local function SetCanvasVFillCenterH(Widget, PanelW, PadY, ViewW, ViewH, ZOrder)
    local Slot = GetCanvasSlot(Widget)
    if not Slot then
        return false
    end
    PadY = PadY or 8
    PanelW = PanelW or 360
    ViewW = ViewW or 1280
    ViewH = ViewH or 720
    local PadX = math.max(0, (ViewW - PanelW) * 0.5)
    if Slot.SetAnchors then
        Slot:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } })
    end
    if Slot.SetAlignment then
        Slot:SetAlignment({ X = 0.5, Y = 0.5 })
    end
    if Slot.SetAutoSize then
        Slot:SetAutoSize(false)
    end
    if Slot.SetOffsets then
        Slot:SetOffsets({
            Left = PadX,
            Top = PadY,
            Right = PadX,
            Bottom = PadY,
        })
    elseif Slot.SetPosition and Slot.SetSize then
        Slot:SetPosition({ X = PadX, Y = PadY })
        Slot:SetSize({ X = PanelW, Y = math.max(1, ViewH - PadY * 2) })
    end
    if ZOrder and Slot.SetZOrder then
        Slot:SetZOrder(ZOrder)
    end
    return true
end

local function SetTextFontSize(Widget, Size)
    if not Widget or not Size then
        return
    end
    local Ok = pcall(function()
        if Widget.Font ~= nil then
            Widget.Font.Size = Size
        end
        if Widget.SetFont and Widget.Font then
            Widget:SetFont(Widget.Font)
        end
    end)
    return Ok
end
local function SetSizeBoxWH(Box, W, H)
    if not Box then
        return
    end
    if W and Box.SetWidthOverride then
        Box:SetWidthOverride(W)
    elseif W then
        Box.bOverride_WidthOverride = true
        Box.WidthOverride = W
    end
    if H and Box.SetHeightOverride then
        Box:SetHeightOverride(H)
    elseif H then
        Box.bOverride_HeightOverride = true
        Box.HeightOverride = H
    end
end
-- VerticalBox / Border 子项水平居中
local function SetSlotHAlignCenter(Widget)
    if not Widget then
        return
    end
    local Slot = Widget.Slot
    if not Slot then
        return
    end
    local Center = 2 -- EHorizontalAlignment.HAlign_Center
    if EHorizontalAlignment and EHorizontalAlignment.HAlign_Center ~= nil then
        Center = EHorizontalAlignment.HAlign_Center
    end
    if Slot.SetHorizontalAlignment then
        pcall(function()
            Slot:SetHorizontalAlignment(Center)
        end)
    elseif Slot.HorizontalAlignment ~= nil then
        Slot.HorizontalAlignment = Center
    end
end
local function GetLocalViewportSize()
    local W, H = 1280, 720
    if UGCWidgetManagerSystem then
        if UGCWidgetManagerSystem.GetViewportSize then
            local Size = UGCWidgetManagerSystem.GetViewportSize()
            if Size then
                W = Size.X or Size.x or W
                H = Size.Y or Size.y or H
            end
        end
        if UGCWidgetManagerSystem.GetViewportScale then
            local Scale = UGCWidgetManagerSystem.GetViewportScale()
            if Scale and Scale > 0.01 then
                W = W / Scale
                H = H / Scale
            end
        end
    end
    return W, H
end
local function ApplyLevelToValue(Value, Level)
    if Level == 5 then
        return Value + 1200
    elseif Level == 4 then
        return Value + 800
    elseif Level == 3 then
        return Value + 200
    elseif Level == 2 then
        return Value * (2 / 3)
    elseif Level == 1 then
        return Value * 0.5
    end
    return Value
end
local function SetWidgetCollapsed(Widget)
    if not Widget or not Widget.SetVisibility then
        return
    end
    local Vis = 1 -- ESlateVisibility.Collapsed
    if ESlateVisibility and ESlateVisibility.Collapsed ~= nil then
        Vis = ESlateVisibility.Collapsed
    end
    pcall(function()
        Widget:SetVisibility(Vis)
    end)
end
local function SetWidgetVisible(Widget)
    if not Widget or not Widget.SetVisibility then
        return
    end
    local Vis = 0 -- ESlateVisibility.Visible
    if ESlateVisibility and ESlateVisibility.Visible ~= nil then
        Vis = ESlateVisibility.Visible
    end
    pcall(function()
        Widget:SetVisibility(Vis)
    end)
end
local function SetWidgetSelfHitTestInvisible(Widget)
    if not Widget or not Widget.SetVisibility then
        return
    end
    local Vis = 3 -- ESlateVisibility.SelfHitTestInvisible
    if ESlateVisibility and ESlateVisibility.SelfHitTestInvisible ~= nil then
        Vis = ESlateVisibility.SelfHitTestInvisible
    end
    pcall(function()
        Widget:SetVisibility(Vis)
    end)
end
local function SetCanvasFixedCenter(Widget, W, H, ZOrder)
    local Slot = GetCanvasSlot(Widget)
    if not Slot then
        return false
    end
    if Slot.SetAnchors then
        Slot:SetAnchors({ Minimum = { X = 0.5, Y = 0.5 }, Maximum = { X = 0.5, Y = 0.5 } })
    end
    if Slot.SetAlignment then
        Slot:SetAlignment({ X = 0.5, Y = 0.5 })
    end
    if Slot.SetAutoSize then
        Slot:SetAutoSize(false)
    end
    if Slot.SetPosition then
        Slot:SetPosition({ X = -(W or 280) * 0.5, Y = -(H or 160) * 0.5 })
    end
    if Slot.SetSize then
        Slot:SetSize({ X = W or 280, Y = H or 160 })
    end
    if ZOrder and Slot.SetZOrder then
        Slot:SetZOrder(ZOrder)
    end
    return true
end
-- 顶部水平居中（锚点居中 + Alignment，Position.X 必须为 0，避免 -W/2 偏左）
local function SetCanvasTopCenter(Widget, W, H, TopPad, ZOrder)
    local Slot = GetCanvasSlot(Widget)
    if not Slot then
        return false
    end
    W = W or 320
    H = H or 170
    TopPad = TopPad or 24
    if Slot.SetAnchors then
        Slot:SetAnchors({ Minimum = { X = 0.5, Y = 0 }, Maximum = { X = 0.5, Y = 0 } })
    end
    if Slot.SetAlignment then
        Slot:SetAlignment({ X = 0.5, Y = 0 })
    end
    if Slot.SetAutoSize then
        Slot:SetAutoSize(false)
    end
    -- 点锚点时 Offsets: Left/Top=位置，Right/Bottom=宽高
    if Slot.SetOffsets then
        pcall(function()
            Slot:SetOffsets({ Left = 0, Top = TopPad, Right = W, Bottom = H })
        end)
    end
    if Slot.SetPosition then
        Slot:SetPosition({ X = 0, Y = TopPad })
    end
    if Slot.SetSize then
        Slot:SetSize({ X = W, Y = H })
    end
    if ZOrder and Slot.SetZOrder then
        Slot:SetZOrder(ZOrder)
    end
    return true
end
function WBP_JadeAppraisal:ApplyPreviewFonts()
    -- 字号比例对齐 Preview（UMG 约为 HTML 的 0.7～0.8）
    -- Txt_Brand 已隐藏，不再设字号
    SetTextFontSize(GetW(self, "Txt_Title"), 22)
    SetTextFontSize(GetW(self, "Txt_ValueLabel"), 12)
    SetTextFontSize(GetW(self, "Txt_Value"), 30)
    SetTextFontSize(GetW(self, "Txt_Hint"), 12)
    SetTextFontSize(GetW(self, "Txt_Legend"), 10)
    SetTextFontSize(GetW(self, "Txt_Sell"), 14)
    SetTextFontSize(GetW(self, "Txt_Close"), 14)
    for _, Name in ipairs({ "Txt_CornerTL", "Txt_CornerTR", "Txt_CornerBL", "Txt_CornerBR" }) do
        SetTextFontSize(GetW(self, Name), 12)
    end
    for Index = 0, CELL_COUNT - 1 do
        SetTextFontSize(GetW(self, "Txt_Cell_" .. tostring(Index)), 16)
    end
end
function WBP_JadeAppraisal:ApplyScreenLayout()
    SetCanvasFill(self, 0)
    local DimBox = GetW(self, "DimOverlayBox")
    SetCanvasFill(DimBox, 0)
    if DimBox then
        if DimBox.ClearWidthOverride then
            DimBox:ClearWidthOverride()
        end
        if DimBox.ClearHeightOverride then
            DimBox:ClearHeightOverride()
        end
    end

    local ViewW, ViewH = GetLocalViewportSize()
    local bPortrait = ViewH >= ViewW

    -- 背景始终按视口高度上下拉伸，保证出售/关闭落在 PanelEdge/PanelBg 内
    local PadY = math.max(4, ViewH * 0.012)
    local PanelH = math.max(280, ViewH - PadY * 2)
    local PanelW
    if bPortrait then
        PanelW = math.min(ViewW * 0.94, ViewW - 10)
        PanelW = math.max(PanelW, ViewW * 0.88)
    else
        -- 横屏：宽度适中，高度贴满视口（横屏高度）
        PanelW = math.min(math.max(ViewW * 0.38, 380), 520)
        PanelW = math.min(PanelW, ViewW * 0.50)
    end

    local Gap = bPortrait and 8 or 7
    local BtnH = bPortrait and 44 or 40
    -- 显式预留下方按钮+四角装饰，避免 Chrome 低估导致按钮溢出框外
    local TopChrome = 155   -- 顶角/标题/价值/提示/图例/间距
    local BottomChrome = 18 + BtnH + 22 + 16 -- Gap_BeforeBottom + 按钮行 + 底角 + 内边距
    local ChromeH = TopChrome + BottomChrome

    local CellBudgetH = PanelH - ChromeH - Gap * 4
    local CellBudgetW = PanelW - 40
    local Cell = math.floor(math.min(CellBudgetH, CellBudgetW) / 5)
    if bPortrait then
        Cell = math.max(36, math.min(68, Cell))
    else
        Cell = math.max(32, math.min(52, Cell))
    end
    -- 若仍可能顶破高度，再压一档格子
    local NeedH = ChromeH + Cell * 5 + Gap * 4
    if NeedH > PanelH then
        Cell = math.max(28, math.floor((PanelH - ChromeH - Gap * 4) / 5))
    end

    local GridW = Cell * 5 + Gap * 4
    if GridW + 36 > PanelW then
        PanelW = math.min(ViewW - 10, GridW + 40)
    end

    local PanelEdge = GetW(self, "PanelEdge")
    -- 横竖屏都上下拉伸，并用等宽左右边距居中
    SetCanvasVFillCenterH(PanelEdge, PanelW, PadY, ViewW, ViewH, 10)
    self.LayoutScale = 1
    SetScale(PanelEdge, 1, 1)

    self:ApplyPreviewFonts()

    SetWidgetCollapsed(GetW(self, "Txt_Brand"))
    SetWidgetCollapsed(GetW(self, "Gap_AfterBrand"))
    -- 去掉无意义横线装饰
    SetWidgetCollapsed(GetW(self, "GoldTopLineBox"))
    SetWidgetCollapsed(GetW(self, "GoldTopLine"))
    SetWidgetCollapsed(GetW(self, "TitleDeco"))
    SetWidgetCollapsed(GetW(self, "TitleLineLBox"))
    SetWidgetCollapsed(GetW(self, "TitleLineRBox"))
    SetWidgetCollapsed(GetW(self, "TitleDecoMid"))
    SetWidgetCollapsed(GetW(self, "TitleLineL"))
    SetWidgetCollapsed(GetW(self, "TitleLineR"))

    SetSizeBoxWH(GetW(self, "Gap_AfterBrand"), nil, 0)
    SetSizeBoxWH(GetW(self, "Gap_AfterTitle"), nil, 8)
    SetSizeBoxWH(GetW(self, "Gap_AfterValue"), nil, 8)
    SetSizeBoxWH(GetW(self, "Gap_AfterHint"), nil, 6)
    SetSizeBoxWH(GetW(self, "Gap_AfterLegend"), nil, 8)
    SetSizeBoxWH(GetW(self, "Gap_BeforeBottom"), nil, 18)
    SetSizeBoxWH(GetW(self, "Gap_ValueLabel"), nil, 4)
    SetSizeBoxWH(GetW(self, "ValueNumBox"), math.min(220, PanelW - 48), 36)

    -- RootBox/PanelBg 与 PanelEdge 同高，背景拉满把按钮包住
    local RootWrap = GetW(self, "RootBox_Wrapper")
    if RootWrap then
        SetSizeBoxWH(RootWrap, PanelW, PanelH)
        if RootWrap.SetMinDesiredWidth then
            RootWrap:SetMinDesiredWidth(PanelW)
        end
        if RootWrap.SetMinDesiredHeight then
            RootWrap:SetMinDesiredHeight(PanelH)
        end
        if RootWrap.SetMaxDesiredWidth then
            RootWrap:SetMaxDesiredWidth(PanelW)
        end
        if RootWrap.SetMaxDesiredHeight then
            RootWrap:SetMaxDesiredHeight(PanelH)
        end
    end

    for Row = 0, 4 do
        for Col = 0, 4 do
            local Idx = Row * 5 + Col
            SetSizeBoxWH(GetCellBox(self, Idx), Cell, Cell)
            if Col < 4 then
                SetSizeBoxWH(GetW(self, string.format("GapH_%d_%d", Row, Col)), Gap, Cell)
            end
        end
        if Row < 4 then
            SetSizeBoxWH(GetW(self, "GapV_" .. tostring(Row)), GridW, Gap)
        end
        SetSlotHAlignCenter(GetW(self, "Row_" .. tostring(Row)))
    end

    local FramePad = 14
    local GridOuterW = GridW + FramePad
    local GridOuterH = Cell * 5 + Gap * 4 + FramePad
    local GridOuter = GetW(self, "GridFrameEdge_Wrapper") or GetW(self, "GridFrameEdge")
    SetSizeBoxWH(GridOuter, GridOuterW, GridOuterH)
    SetSlotHAlignCenter(GridOuter)
    SetSlotHAlignCenter(GetW(self, "GridFrameEdge"))
    SetSlotHAlignCenter(GetW(self, "GridBox"))

    local SellW = math.floor(PanelW * 0.52)
    local CloseW = math.floor(PanelW * 0.30)
    local SidePad = math.max(8, math.floor((PanelW - SellW - CloseW - 10) * 0.5))
    SetSizeBoxWH(GetW(self, "SellBox"), SellW, BtnH)
    SetSizeBoxWH(GetW(self, "CloseBox"), CloseW, BtnH)
    SetSizeBoxWH(GetW(self, "GapBottomBtn"), 10, BtnH)
    SetSizeBoxWH(GetW(self, "BottomLeftPad"), SidePad, BtnH)
    SetSizeBoxWH(GetW(self, "BottomRightPad"), SidePad, BtnH)
    SetSizeBoxWH(GetW(self, "CornerTopMid"), math.max(80, PanelW - 40), 6)
    SetSizeBoxWH(GetW(self, "CornerBottomMid"), math.max(80, PanelW - 40), 6)

    -- 确认弹窗：挂在根画布顶部水平居中（放大，不挡格子）
    SetWidgetCollapsed(GetW(self, "ConfirmOverlayBox"))
    SetWidgetCollapsed(GetW(self, "ConfirmDim"))
    local CardW = math.min(360, math.max(300, PanelW * 0.88))
    local CardH = bPortrait and 168 or 156
    local BtnW = math.floor((CardW - 48) * 0.40)
    local ConfirmBtnH = 44
    local TopPad = math.max(16, PadY + (bPortrait and 28 or 20))
    SetCanvasTopCenter(GetW(self, "ConfirmCardEdge"), CardW, CardH, TopPad, 60)
    SetBorderPadding(GetW(self, "ConfirmCard"), 22, 20, 22, 18)
    SetSizeBoxWH(GetW(self, "Gap_ConfirmMsg"), nil, 16)
    SetSizeBoxWH(GetW(self, "ConfirmYesBox"), BtnW, ConfirmBtnH)
    SetSizeBoxWH(GetW(self, "ConfirmNoBox"), BtnW, ConfirmBtnH)
    SetSizeBoxWH(GetW(self, "Gap_ConfirmBtn"), 16, ConfirmBtnH)
    SetSlotHAlignCenter(GetW(self, "Txt_Confirm"))
    SetSlotHAlignCenter(GetW(self, "ConfirmBtnRow"))
    SetTextFontSize(GetW(self, "Txt_Confirm"), 20)
    SetTextFontSize(GetW(self, "Txt_ConfirmYes"), 15)
    SetTextFontSize(GetW(self, "Txt_ConfirmNo"), 15)
    if not self.PendingConfirm then
        SetWidgetCollapsed(GetW(self, "ConfirmCardEdge"))
    end

    ugcprint(string.format(
        "[Jade] ScreenLayout view=%.0fx%.0f panel=%.0fx%.0f cell=%d btnH=%d vfill=1",
        ViewW, ViewH, PanelW, PanelH, Cell, BtnH
    ))
end

function WBP_JadeAppraisal:ApplyTheme()
    SetBorderBg(GetW(self, "DimOverlay"), COLOR.Dim)
    SetBorderBg(GetW(self, "PanelEdge"), COLOR.PanelEdge)
    SetBorderBg(GetW(self, "PanelBg"), COLOR.PanelBg)
    -- 外金边 / 内玉边：靠 Padding 露出外层颜色
    SetBorderPadding(GetW(self, "PanelEdge"), 2, 2, 2, 2)
    SetBorderPadding(GetW(self, "PanelBg"), 14, 12, 14, 18)
    SetWidgetCollapsed(GetW(self, "GoldTopLineBox"))
    SetWidgetCollapsed(GetW(self, "GoldTopLine"))
    SetWidgetCollapsed(GetW(self, "TitleDeco"))
    SetWidgetCollapsed(GetW(self, "TitleLineL"))
    SetWidgetCollapsed(GetW(self, "TitleLineR"))
    SetBorderBg(GetW(self, "ValueCardEdge"), COLOR.ValueCardEdge)
    SetBorderBg(GetW(self, "ValueCard"), COLOR.ValueCard)
    SetBorderPadding(GetW(self, "ValueCardEdge"), 1, 1, 1, 1)
    SetBorderPadding(GetW(self, "ValueCard"), 12, 10, 12, 10)
    SetBorderBg(GetW(self, "GridFrameEdge"), COLOR.GridFrameEdge)
    SetBorderBg(GetW(self, "GridFrame"), COLOR.GridFrame)
    SetBorderPadding(GetW(self, "GridFrameEdge"), 1, 1, 1, 1)
    SetBorderPadding(GetW(self, "GridFrame"), 6, 6, 6, 6)
    -- 四角括号装饰（对齐 Preview 的 L 形角线）
    local Corners = {
        { "Txt_CornerTL", "┌" },
        { "Txt_CornerTR", "┐" },
        { "Txt_CornerBL", "└" },
        { "Txt_CornerBR", "┘" },
    }
    for _, Item in ipairs(Corners) do
        local Corner = GetW(self, Item[1])
        if Corner then
            if Corner.SetText then
                Corner:SetText(Item[2])
            end
            SetTextColor(Corner, COLOR.Corner)
        end
    end
    local TxtBrand = GetW(self, "Txt_Brand")
    SetWidgetCollapsed(TxtBrand)
    SetWidgetCollapsed(GetW(self, "Gap_AfterBrand"))
    local TxtTitle = GetW(self, "Txt_Title")
    if TxtTitle then
        if TxtTitle.SetText then
            TxtTitle:SetText("玉石鉴定")
        end
        SetTextColor(TxtTitle, COLOR.Title)
    end
    local TxtHint = GetW(self, "Txt_Hint")
    if TxtHint then
        if TxtHint.SetText then
            TxtHint:SetText("点击格子揭示品相（1～5 级等概率）· 可随时出售")
        end
        SetTextColor(TxtHint, COLOR.Hint)
    end
    local TxtLegend = GetW(self, "Txt_Legend")
    if TxtLegend then
        if TxtLegend.SetText then
            TxtLegend:SetText("■1 折半   ■2 ×2/3   ■3 +200   ■4 +800   ■5 +1200")
        end
        SetTextColor(TxtLegend, COLOR.Legend)
    end
    local TxtValueLabel = GetW(self, "Txt_ValueLabel")
    if TxtValueLabel then
        if TxtValueLabel.SetText then
            TxtValueLabel:SetText("当前价值")
        end
        SetTextColor(TxtValueLabel, COLOR.ValueLabel)
    end
    local TxtValue = GetW(self, "Txt_Value")
    if TxtValue then
        SetTextColor(TxtValue, COLOR.Value)
    end
    local BtnSell = GetW(self, "Btn_Sell")
    SetButtonBg(BtnSell, COLOR.SellBg)
    local TxtSell = GetW(self, "Txt_Sell")
    if TxtSell then
        if TxtSell.SetText then
            TxtSell:SetText("出售结算")
        end
        SetTextColor(TxtSell, COLOR.SellTxt)
    end
    local BtnClose = GetW(self, "Btn_Close")
    SetButtonBg(BtnClose, COLOR.CloseBg)
    local TxtClose = GetW(self, "Txt_Close")
    if TxtClose then
        if TxtClose.SetText then
            TxtClose:SetText("关闭")
        end
        SetTextColor(TxtClose, COLOR.CloseTxt)
    end
    -- 确认弹窗主题（无全屏深遮罩，避免挡住格子高亮）
    SetWidgetCollapsed(GetW(self, "ConfirmDim"))
    SetBorderBg(GetW(self, "ConfirmCardEdge"), COLOR.ConfirmEdge)
    SetBorderBg(GetW(self, "ConfirmCard"), COLOR.ConfirmBg)
    SetBorderPadding(GetW(self, "ConfirmCardEdge"), 2, 2, 2, 2)
    SetBorderPadding(GetW(self, "ConfirmCard"), 16, 14, 16, 14)
    local TxtConfirm = GetW(self, "Txt_Confirm")
    if TxtConfirm then
        if TxtConfirm.SetText then
            TxtConfirm:SetText("确定是这一格吗")
        end
        SetTextColor(TxtConfirm, COLOR.ConfirmTxt)
    end
    SetButtonBg(GetW(self, "Btn_ConfirmYes"), COLOR.ConfirmYesBg)
    local TxtYes = GetW(self, "Txt_ConfirmYes")
    if TxtYes then
        if TxtYes.SetText then
            TxtYes:SetText("确定")
        end
        SetTextColor(TxtYes, COLOR.SellTxt)
    end
    SetButtonBg(GetW(self, "Btn_ConfirmNo"), COLOR.ConfirmNoBg)
    local TxtNo = GetW(self, "Txt_ConfirmNo")
    if TxtNo then
        if TxtNo.SetText then
            TxtNo:SetText("取消")
        end
        SetTextColor(TxtNo, COLOR.CloseTxt)
    end
    if not self.PendingConfirm then
        SetWidgetCollapsed(GetW(self, "ConfirmCardEdge"))
        SetWidgetCollapsed(GetW(self, "ConfirmOverlayBox"))
    end
    -- 未翻开格子统一闲置色（避免蓝图默认白底）
    for Index = 0, CELL_COUNT - 1 do
        if self.Opened and self.Opened[Index] then
            self:ApplyCellLevelStyle(Index, self.Opened[Index])
        else
            self:ApplyCellIdleStyle(Index)
        end
    end
    self:ApplyPreviewFonts()
end
function WBP_JadeAppraisal:ApplyCellIdleStyle(Index)
    local Btn = GetW(self, "Cell_" .. tostring(Index))
    local Txt = GetW(self, "Txt_Cell_" .. tostring(Index))
    local Box = GetCellBox(self, Index)
    SetButtonBg(Btn, COLOR.CellIdleBg)
    SetTextColor(Txt, COLOR.CellIdleTxt)
    SetOpacity(Btn, 1)
    SetScale(Box or Btn, 1, 1)
end
function WBP_JadeAppraisal:ApplyCellHoverStyle(Index)
    local Btn = GetW(self, "Cell_" .. tostring(Index))
    local Txt = GetW(self, "Txt_Cell_" .. tostring(Index))
    local Box = GetCellBox(self, Index)
    SetButtonBg(Btn, COLOR.CellHoverBg)
    SetTextColor(Txt, COLOR.CellHoverTxt)
    -- 对齐 Preview: translateY(-2px) 近似为轻微放大
    SetScale(Box or Btn, 1.06, 1.06)
end
function WBP_JadeAppraisal:ApplyCellSelectedStyle(Index)
    local Btn = GetW(self, "Cell_" .. tostring(Index))
    local Txt = GetW(self, "Txt_Cell_" .. tostring(Index))
    local Box = GetCellBox(self, Index)
    SetButtonBg(Btn, COLOR.CellSelectedBg)
    SetTextColor(Txt, COLOR.CellSelectedTxt)
    SetOpacity(Btn, 1)
    SetScale(Box or Btn, 1.12, 1.12)
end
function WBP_JadeAppraisal:ApplyCellLevelStyle(Index, Level)
    local Style = LEVEL_COLOR[Level]
    if not Style then
        return
    end
    local Btn = GetW(self, "Cell_" .. tostring(Index))
    local Txt = GetW(self, "Txt_Cell_" .. tostring(Index))
    local Box = GetCellBox(self, Index)
    SetButtonBg(Btn, Style.Bg)
    SetTextColor(Txt, Style.Txt)
    SetOpacity(Btn, 1)
    SetScale(Box or Btn, 1, 1)
end
function WBP_JadeAppraisal:PlayRevealFx(Index, Level)
    local Btn = GetW(self, "Cell_" .. tostring(Index))
    local Txt = GetW(self, "Txt_Cell_" .. tostring(Index))
    local Box = GetCellBox(self, Index)
    local Target = Box or Btn
    local TimerA = "JadeRevealA_" .. tostring(Index)
    local TimerB = "JadeRevealB_" .. tostring(Index)
    -- 金闪翻开
    SetButtonBg(Btn, COLOR.CellFlashBg)
    SetTextColor(Txt, COLOR.CellFlashTxt)
    SetOpacity(Btn, 0.35)
    SetScale(Target, 0.86, 0.86)
    DelayCall(TimerA, 0.06, function()
        if not IsSelfValid(self) then
            return
        end
        SetOpacity(Btn, 1)
        SetScale(Target, 1.08, 1.08)
        self:ApplyCellLevelStyle(Index, Level)
        SetScale(Target, 1.08, 1.08)
        DelayCall(TimerB, 0.12, function()
            if not IsSelfValid(self) then
                return
            end
            SetScale(Target, 1, 1)
            self:ApplyCellLevelStyle(Index, Level)
        end)
    end)
end
function WBP_JadeAppraisal:PlayValueBump()
    local Txt = GetW(self, "Txt_Value")
    local Box = GetW(self, "ValueNumBox")
    local Target = Box or Txt
    if not Txt then
        return
    end
    SetTextColor(Txt, COLOR.ValueFlash)
    SetScale(Target, 1.12, 1.12)
    DelayCall("JadeValueBump", 0.18, function()
        if not IsSelfValid(self) then
            return
        end
        SetTextColor(Txt, COLOR.Value)
        SetScale(Target, 1, 1)
    end)
end
function WBP_JadeAppraisal:PlayOpenIntro()
    local Panel = GetW(self, "PanelEdge") or GetW(self, "PanelBg")
    if not Panel then
        return
    end
    -- 对齐 Preview rise：略缩小淡入后弹回
    local BaseScale = self.LayoutScale or 1
    SetOpacity(Panel, 0)
    SetScale(Panel, BaseScale * 0.97, BaseScale * 0.97)
    DelayCall("JadeOpenIntro", 0.03, function()
        if not IsSelfValid(self) then
            return
        end
        SetOpacity(Panel, 1)
        SetScale(Panel, BaseScale * 1.01, BaseScale * 1.01)
        DelayCall("JadeOpenIntroSettle", 0.10, function()
            if not IsSelfValid(self) then
                return
            end
            SetScale(Panel, BaseScale, BaseScale)
        end)
    end)
end
function WBP_JadeAppraisal:BindActionHovers()
    local BtnSell = GetW(self, "Btn_Sell")
    if BtnSell then
        self.OnSellHovered = function()
            if not self.bSelling then
                SetButtonBg(BtnSell, COLOR.SellHoverBg)
            end
        end
        self.OnSellUnhovered = function()
            SetButtonBg(BtnSell, COLOR.SellBg)
        end
        if BtnSell.OnHovered then
            BtnSell.OnHovered:Add(self.OnSellHovered, self)
        end
        if BtnSell.OnUnhovered then
            BtnSell.OnUnhovered:Add(self.OnSellUnhovered, self)
        end
    end
    local BtnClose = GetW(self, "Btn_Close")
    if BtnClose then
        self.OnCloseHovered = function()
            SetButtonBg(BtnClose, COLOR.CloseHoverBg)
        end
        self.OnCloseUnhovered = function()
            SetButtonBg(BtnClose, COLOR.CloseBg)
        end
        if BtnClose.OnHovered then
            BtnClose.OnHovered:Add(self.OnCloseHovered, self)
        end
        if BtnClose.OnUnhovered then
            BtnClose.OnUnhovered:Add(self.OnCloseUnhovered, self)
        end
    end
end
function WBP_JadeAppraisal:Construct()
    self.CurrentValue = BASE_VALUE
    self.Opened = {}
    self.Hovered = {}
    self.PendingConfirm = nil
    self.bSelling = false
    self.bRevealPending = false
    self.bBound = false
    local BtnSell = GetW(self, "Btn_Sell")
    if BtnSell and BtnSell.OnClicked then
        BtnSell.OnClicked:Add(self.OnSellClicked, self)
    end
    local BtnClose = GetW(self, "Btn_Close")
    if BtnClose and BtnClose.OnClicked then
        BtnClose.OnClicked:Add(self.OnCloseClicked, self)
    end
    local BtnYes = GetW(self, "Btn_ConfirmYes")
    if BtnYes and BtnYes.OnClicked then
        BtnYes.OnClicked:Add(self.OnConfirmYesClicked, self)
    end
    local BtnNo = GetW(self, "Btn_ConfirmNo")
    if BtnNo and BtnNo.OnClicked then
        BtnNo.OnClicked:Add(self.OnConfirmNoClicked, self)
    end
    self:ApplyTheme()
    self:BindActionHovers()
    self:RefreshValueText()
    self:BindCells()
    self:HideConfirmDialog()
    self:ApplyScreenLayout()
    -- AddToSlot / 控件树就绪后再刷一次主题与布局，确保颜色落地
    DelayCall("JadeScreenLayout", 0.05, function()
        if not IsSelfValid(self) then
            return
        end
        self:ApplyTheme()
        self:ApplyScreenLayout()
        self:RefreshValueText()
        if not self.PendingConfirm then
            self:HideConfirmDialog()
        end
    end)
    self:PlayOpenIntro()
end
function WBP_JadeAppraisal:Destruct()
    if UGCTimerUtility and UGCTimerUtility.RemoveLuaTimerByName then
        UGCTimerUtility.RemoveLuaTimerByName("JadeValueBump")
        UGCTimerUtility.RemoveLuaTimerByName("JadeOpenIntro")
        UGCTimerUtility.RemoveLuaTimerByName("JadeOpenIntroSettle")
        UGCTimerUtility.RemoveLuaTimerByName("JadeScreenLayout")
        for Index = 0, CELL_COUNT - 1 do
            UGCTimerUtility.RemoveLuaTimerByName("JadeRevealA_" .. tostring(Index))
            UGCTimerUtility.RemoveLuaTimerByName("JadeRevealB_" .. tostring(Index))
        end
    end
    local BtnSell = GetW(self, "Btn_Sell")
    if BtnSell then
        if BtnSell.OnClicked then
            BtnSell.OnClicked:Remove(self.OnSellClicked, self)
        end
        if BtnSell.OnHovered and self.OnSellHovered then
            BtnSell.OnHovered:Remove(self.OnSellHovered, self)
        end
        if BtnSell.OnUnhovered and self.OnSellUnhovered then
            BtnSell.OnUnhovered:Remove(self.OnSellUnhovered, self)
        end
    end
    local BtnClose = GetW(self, "Btn_Close")
    if BtnClose then
        if BtnClose.OnClicked then
            BtnClose.OnClicked:Remove(self.OnCloseClicked, self)
        end
        if BtnClose.OnHovered and self.OnCloseHovered then
            BtnClose.OnHovered:Remove(self.OnCloseHovered, self)
        end
        if BtnClose.OnUnhovered and self.OnCloseUnhovered then
            BtnClose.OnUnhovered:Remove(self.OnCloseUnhovered, self)
        end
    end
    local BtnYes = GetW(self, "Btn_ConfirmYes")
    if BtnYes and BtnYes.OnClicked then
        BtnYes.OnClicked:Remove(self.OnConfirmYesClicked, self)
    end
    local BtnNo = GetW(self, "Btn_ConfirmNo")
    if BtnNo and BtnNo.OnClicked then
        BtnNo.OnClicked:Remove(self.OnConfirmNoClicked, self)
    end
    for Index = 0, CELL_COUNT - 1 do
        local Btn = GetW(self, "Cell_" .. tostring(Index))
        if Btn then
            if Btn.OnClicked then
                Btn.OnClicked:Remove(self["OnCellClicked_" .. tostring(Index)], self)
            end
            if Btn.OnHovered then
                Btn.OnHovered:Remove(self["OnCellHovered_" .. tostring(Index)], self)
            end
            if Btn.OnUnhovered then
                Btn.OnUnhovered:Remove(self["OnCellUnhovered_" .. tostring(Index)], self)
            end
        end
    end
end
function WBP_JadeAppraisal:RefreshValueText()
    local TxtLabel = GetW(self, "Txt_ValueLabel")
    if TxtLabel and TxtLabel.SetText then
        TxtLabel:SetText("当前价值")
        SetTextColor(TxtLabel, COLOR.ValueLabel)
    end
    local Txt = GetW(self, "Txt_Value")
    if Txt then
        Txt:SetText(tostring(math.floor(self.CurrentValue + 0.5)))
        SetTextColor(Txt, COLOR.Value)
    end
end
function WBP_JadeAppraisal:SetCellText(Index, Text)
    local Txt = GetW(self, "Txt_Cell_" .. tostring(Index))
    if Txt then
        Txt:SetText(Text)
    end
end
function WBP_JadeAppraisal:BindCells()
    if self.bBound then
        return
    end
    self.bBound = true
    for Index = 0, CELL_COUNT - 1 do
        local Btn = GetW(self, "Cell_" .. tostring(Index))
        self:SetCellText(Index, "?")
        self:ApplyCellIdleStyle(Index)
        if Btn then
            local ClickName = "OnCellClicked_" .. tostring(Index)
            self[ClickName] = function(WidgetSelf)
                WidgetSelf:OnCellClicked(Index)
            end
            if Btn.OnClicked then
                Btn.OnClicked:Add(self[ClickName], self)
            end
            local HoverName = "OnCellHovered_" .. tostring(Index)
            self[HoverName] = function(WidgetSelf)
                if WidgetSelf.bSelling or WidgetSelf.Opened[Index] then
                    return
                end
                WidgetSelf.Hovered[Index] = true
                if WidgetSelf.PendingConfirm == Index then
                    WidgetSelf:ApplyCellSelectedStyle(Index)
                    return
                end
                WidgetSelf:ApplyCellHoverStyle(Index)
            end
            if Btn.OnHovered then
                Btn.OnHovered:Add(self[HoverName], self)
            end
            local UnhoverName = "OnCellUnhovered_" .. tostring(Index)
            self[UnhoverName] = function(WidgetSelf)
                WidgetSelf.Hovered[Index] = nil
                if WidgetSelf.Opened[Index] then
                    return
                end
                -- 待确认选中格保持高亮
                if WidgetSelf.PendingConfirm == Index then
                    WidgetSelf:ApplyCellSelectedStyle(Index)
                    return
                end
                WidgetSelf:ApplyCellIdleStyle(Index)
            end
            if Btn.OnUnhovered then
                Btn.OnUnhovered:Add(self[UnhoverName], self)
            end
        end
    end
end
function WBP_JadeAppraisal:ShowConfirmDialog(Index)
    self.PendingConfirm = Index
    local TxtConfirm = GetW(self, "Txt_Confirm")
    if TxtConfirm and TxtConfirm.SetText then
        TxtConfirm:SetText("确定是这一格吗")
        SetTextColor(TxtConfirm, COLOR.ConfirmTxt)
    end
    self:ApplyCellSelectedStyle(Index)
    SetWidgetCollapsed(GetW(self, "ConfirmOverlayBox"))
    SetWidgetCollapsed(GetW(self, "ConfirmDim"))
    SetWidgetVisible(GetW(self, "ConfirmCardEdge"))
    -- 打开时再刷一次布局，确保放大后水平居中
    self:ApplyScreenLayout()
    SetWidgetVisible(GetW(self, "ConfirmCardEdge"))
end

function WBP_JadeAppraisal:HideConfirmDialog()
    local Prev = self.PendingConfirm
    self.PendingConfirm = nil
    SetWidgetCollapsed(GetW(self, "ConfirmCardEdge"))
    SetWidgetCollapsed(GetW(self, "ConfirmOverlayBox"))
    if Prev ~= nil and not (self.Opened and self.Opened[Prev]) then
        if self.Hovered and self.Hovered[Prev] then
            self:ApplyCellHoverStyle(Prev)
        else
            self:ApplyCellIdleStyle(Prev)
        end
    end
end

--- 应用服务端翻格结果（等级与价值均来自服务端）
function WBP_JadeAppraisal:ApplyServerReveal(Index, Level, NewValue)
    self.bRevealPending = false
    Index = math.floor(tonumber(Index) or -1)
    Level = math.floor(tonumber(Level) or 0)
    NewValue = math.floor(tonumber(NewValue) or 0)
    if Index < 0 or Index >= CELL_COUNT then
        return
    end
    if self.Opened and self.Opened[Index] then
        return
    end
    if not self.Opened then
        self.Opened = {}
    end
    self.Opened[Index] = Level
    self.Hovered[Index] = nil
    self:HideConfirmDialog()
    self:SetCellText(Index, tostring(Level))
    self:PlayRevealFx(Index, Level)
    local Btn = GetW(self, "Cell_" .. tostring(Index))
    if Btn and Btn.SetIsEnabled then
        Btn:SetIsEnabled(false)
    end
    self.CurrentValue = NewValue
    self:RefreshValueText()
    self:PlayValueBump()
end

function WBP_JadeAppraisal:OnCellClicked(Index)
    if self.bSelling or self.bRevealPending then
        return
    end
    -- 已翻开的格子不再弹窗
    if self.Opened[Index] then
        return
    end
    if self.PendingConfirm ~= nil then
        return
    end
    self:ShowConfirmDialog(Index)
end

function WBP_JadeAppraisal:OnConfirmYesClicked()
    local Index = self.PendingConfirm
    if Index == nil or self.bSelling or self.bRevealPending then
        self:HideConfirmDialog()
        return
    end
    if self.Opened[Index] then
        self:HideConfirmDialog()
        return
    end
    -- 向服务端请求翻格，本地不 math.random
    self.bRevealPending = true
    self:HideConfirmDialog()
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.RequestRevealJadeCell then
        PC:RequestRevealJadeCell(Index)
    elseif PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_RevealJadeCell", Index)
    else
        self.bRevealPending = false
    end
end

function WBP_JadeAppraisal:OnConfirmNoClicked()
    self:HideConfirmDialog()
end

function WBP_JadeAppraisal:OnSellClicked()
    if self.bSelling or self.bRevealPending then
        return
    end
    self.bSelling = true
    self:HideConfirmDialog()
    -- 展示本地预估；实际结算金额以服务端会话为准
    local PreviewValue = math.floor(self.CurrentValue + 0.5)
    if PreviewValue < 0 then
        PreviewValue = 0
    end
    for Index = 0, CELL_COUNT - 1 do
        local Btn = GetW(self, "Cell_" .. tostring(Index))
        if Btn and Btn.SetIsEnabled then
            Btn:SetIsEnabled(false)
        end
    end
    local BtnSell = GetW(self, "Btn_Sell")
    if BtnSell and BtnSell.SetIsEnabled then
        BtnSell:SetIsEnabled(false)
    end
    local TxtHint = GetW(self, "Txt_Hint")
    if TxtHint and TxtHint.SetText then
        TxtHint:SetText("结算中 · 预估 " .. tostring(PreviewValue) .. " 金币")
        SetTextColor(TxtHint, COLOR.ToastTxt)
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.RequestSellAppraisedJade then
        PC:RequestSellAppraisedJade()
    elseif PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_SellAppraisedJade")
    end
end

function WBP_JadeAppraisal:OnCloseClicked()
    if self.bSelling then
        return
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    if PC and PC.RequestCancelManualAppraisal then
        PC:RequestCancelManualAppraisal()
        return
    end
    if PC then
        UnrealNetwork.CallUnrealRPC(PC, PC, "Server_CancelManualAppraisal")
        return
    end
    if self.RemoveFromParent then
        self:RemoveFromParent()
    end
end
return WBP_JadeAppraisal