---@class PaymentTestUI
---@field PanelWidget UUserWidget|nil
---@field bOpen boolean
---@field pc UGCPlayerController|nil
local PaymentConfig = nil
do
    local ok, mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.Common.PaymentConfig')
    end)
    if ok and type(mod) == 'table' then PaymentConfig = mod end
end

local PaymentTestUI = {
    PanelWidget = nil,
    bOpen = false,
    pc = nil,
    _boundBuyDelegate = nil,
    _boundUseDelegate = nil,
}

local COLOR = {
    Bg = { R = 0.05, G = 0.05, B = 0.08, A = 0.92 },
    Border = { R = 0.30, G = 0.60, B = 0.50, A = 1 },
    Title = { R = 0.90, G = 0.95, B = 0.92, A = 1 },
    SubTitle = { R = 0.70, G = 0.85, B = 0.78, A = 1 },
    NormalBtn = { R = 0.15, G = 0.45, B = 0.35, A = 1 },
    HoverBtn = { R = 0.25, G = 0.60, B = 0.48, A = 1 },
    BuyBtn = { R = 0.60, G = 0.35, B = 0.10, A = 1 },
    UseBtn = { R = 0.15, G = 0.50, B = 0.45, A = 1 },
    CloseBtn = { R = 0.50, G = 0.15, B = 0.10, A = 1 },
    Text = { R = 0.92, G = 0.96, B = 0.94, A = 1 },
    TextDim = { R = 0.55, G = 0.65, B = 0.60, A = 1 },
    Green = { R = 0.40, G = 0.85, B = 0.55, A = 1 },
    Red = { R = 0.90, G = 0.35, B = 0.30, A = 1 },
}

local function GetW(self, Name)
    if self[Name] ~= nil then return self[Name] end
    if self.GetWidgetFromName then return self:GetWidgetFromName(Name) end
    return nil
end

local function MakeColor(C)
    if not C then return nil end
    if LinearColor and LinearColor.New then
        return LinearColor.New(C.R, C.G, C.B, C.A or 1)
    end
    return { R = C.R, G = C.G, B = C.B, A = C.A or 1 }
end

local function SetBtnColor(Btn, C)
    if not Btn then return end
    local Col = MakeColor(C)
    if Btn.SetBackgroundColor then
        pcall(function() Btn:SetBackgroundColor(Col) end)
    end
    if Btn.BackgroundColor then
        Btn.BackgroundColor = Col
    end
    local Style = Btn.WidgetStyle
    if Style then
        local Plain = { R = C.R, G = C.G, B = C.B, A = C.A or 1 }
        local function Tint(Brush)
            if not Brush then return end
            if Brush.TintColor ~= nil then
                if FSlateColor and FSlateColor.New then
                    Brush.TintColor = FSlateColor.New(Col)
                else
                    Brush.TintColor = Plain
                end
            end
        end
        Tint(Style.Normal)
        Tint(Style.Hovered)
        Tint(Style.Pressed)
        Tint(Style.Disabled)
        Btn.WidgetStyle = Style
    end
end

local function SetTextColor(Text, C)
    if not Text then return end
    if Text.SetColorRGBStr then
        local function Byte(V)
            local N = math.floor((V or 0) * 255 + 0.5)
            if N < 0 then N = 0 end
            if N > 255 then N = 255 end
            return string.format("%02X", N)
        end
        pcall(function()
            Text:SetColorRGBStr(Byte(C.R) .. Byte(C.G) .. Byte(C.B))
        end)
    end
end

local function SetText(Text, S)
    if Text and Text.SetText then
        pcall(function() Text:SetText(S) end)
    end
end

local function SetSize(Widget, W, H)
    if not Widget then return end
    if Widget.SetWidthOverride then pcall(function() Widget:SetWidthOverride(W) end) end
    if Widget.SetHeightOverride then pcall(function() Widget:SetHeightOverride(H) end) end
end

local function ApplyFontSize(Widget, Size)
    if not Widget or not Size then return end
    if Widget.Font then
        Widget.Font.Size = Size
    end
end

local function AddButton(Parent, Name, Text, X, Y, W, H, Color, FontSize, OnClick)
    local Btn = UGCWidgetManagerSystem.CreateButton(Parent, Name)
    if not Btn then return nil end
    SetSize(Btn, W, H)
    local Slot = Btn.Slot
    if Slot then
        if Slot.SetAnchors then
            Slot:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 0, Y = 0 } })
        end
        if Slot.SetAlignment then
            Slot:SetAlignment({ X = 0, Y = 0 })
        end
        if Slot.SetPosition then
            Slot:SetPosition({ X = X, Y = Y })
        end
        if Slot.SetSize then
            Slot:SetSize({ X = W, Y = H })
        end
        if Slot.SetAutoSize then
            Slot:SetAutoSize(false)
        end
    end
    SetBtnColor(Btn, Color)

    local Txt = UGCWidgetManagerSystem.CreateTextBlock(Btn, "Txt_" .. Name)
    if Txt then
        local TS = Txt.Slot
        if TS then
            if TS.SetAnchors then
                TS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } })
            end
            if TS.SetOffsets then
                TS:SetOffsets({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
            end
            if TS.SetAlignment then
                TS:SetAlignment({ X = 0.5, Y = 0.5 })
            end
        end
        SetText(Txt, Text)
        SetTextColor(Txt, COLOR.Text)
        ApplyFontSize(Txt, FontSize or 14)
    end

    if Btn.OnClicked then
        Btn.OnClicked:Add(function()
            if PaymentTestUI.bOpen and OnClick then
                OnClick()
            end
        end)
    end

    return Btn
end

function PaymentTestUI.GetPlayerController()
    if PaymentTestUI.pc and UGCObjectUtility and UGCObjectUtility.IsObjectValid and UGCObjectUtility.IsObjectValid(PaymentTestUI.pc) then
        return PaymentTestUI.pc
    end
    local pc = UGCGameSystem.GetLocalPlayerController()
    if pc then
        PaymentTestUI.pc = pc
    end
    return pc
end

function PaymentTestUI.RefreshBalance()
    local pc = PaymentTestUI.GetPlayerController()
    if not pc then return end

    local ticket = 0
    local coin = 0
    if UGCCommoditySystem then
        local ok1, t = pcall(function() return UGCCommoditySystem.GetTicket and UGCCommoditySystem.GetTicket() end)
        if ok1 and t then ticket = math.floor(tonumber(t) or 0) end

        local ok2, c = pcall(function() return UGCCommoditySystem.GetActiveCoin and UGCCommoditySystem.GetActiveCoin() end)
        if ok2 and c then coin = math.floor(tonumber(c) or 0) end
    end

    local TxtTicket = GetW(PaymentTestUI.PanelWidget, "Txt_Ticket")
    if TxtTicket then
        SetText(TxtTicket, string.format("绿洲币: %d", ticket))
        SetTextColor(TxtTicket, COLOR.Green)
    end

    local TxtCoin = GetW(PaymentTestUI.PanelWidget, "Txt_Coin")
    if TxtCoin then
        SetText(TxtCoin, string.format("启元币: %d", coin))
        SetTextColor(TxtCoin, COLOR.Green)
    end
end

function PaymentTestUI.RefreshCommodityList()
    local TxtList = GetW(PaymentTestUI.PanelWidget, "Txt_CommodityList")
    if not TxtList then return end

    local lines = {}
    if UGCCommoditySystem and UGCCommoditySystem.GetUGCCommodityList then
        local ok, list = pcall(function() return UGCCommoditySystem.GetUGCCommodityList() end)
        if ok and list then
            for _, item in ipairs(list) do
                local cid = math.floor(tonumber(item.CommodityID) or 0)
                local cnt = math.floor(tonumber(item.Count) or 0)
                local name = PaymentConfig.GetCommodityName(cid) or ("ID=" .. tostring(cid))
                table.insert(lines, string.format("  %s x%d", name, cnt))
            end
        end
    end

    if #lines == 0 then
        table.insert(lines, "  (暂无商品)")
    end

    SetText(TxtList, table.concat(lines, "\n"))
    SetTextColor(TxtList, COLOR.SubTitle)
end

function PaymentTestUI.RefreshAll()
    PaymentTestUI.RefreshBalance()
    PaymentTestUI.RefreshCommodityList()
end

function PaymentTestUI.OnBuyClicked()
    local pc = PaymentTestUI.GetPlayerController()
    if not pc then return end
    if pc.RequestBuyProduct then
        pc:RequestBuyProduct(9000001, 1)
    end
    PaymentTestUI.RefreshAll()
end

function PaymentTestUI.OnUseIronDrill()
    local pc = PaymentTestUI.GetPlayerController()
    if not pc then return end
    if pc.RequestUseCommodity then
        pc:RequestUseCommodity(1001, 1)
    end
    PaymentTestUI.RefreshAll()
end

function PaymentTestUI.OnUseBackpackTicket()
    local pc = PaymentTestUI.GetPlayerController()
    if not pc then return end
    if pc.RequestUseCommodity then
        pc:RequestUseCommodity(1002, 1)
    end
    PaymentTestUI.RefreshAll()
end

function PaymentTestUI.OnUseJadeOre()
    local pc = PaymentTestUI.GetPlayerController()
    if not pc then return end
    if pc.RequestUseCommodity then
        pc:RequestUseCommodity(1003, 1)
    end
    PaymentTestUI.RefreshAll()
end

function PaymentTestUI.OnShowRechargeClicked()
    local pc = PaymentTestUI.GetPlayerController()
    if not pc then return end
    if pc.RequestShowRechargeUI then
        pc:RequestShowRechargeUI()
    end
end

function PaymentTestUI.OnCloseClicked()
    PaymentTestUI.Close()
end

function PaymentTestUI.BuildPanel()
    if PaymentTestUI.PanelWidget then
        PaymentTestUI.RefreshAll()
        return
    end

    local Panel = UGCWidgetManagerSystem.CreateCanvasPanel(nil, "WBP_PaymentTestUI")
    if not Panel then
        ugcprint("[PaymentTestUI] ❌ 无法创建Canvas面板")
        return
    end
    PaymentTestUI.PanelWidget = Panel

    local ScreenW, ScreenH = 500, 520
    local Slot = Panel.Slot
    if Slot then
        if Slot.SetAnchors then
            Slot:SetAnchors({ Minimum = { X = 0.5, Y = 0.5 }, Maximum = { X = 0.5, Y = 0.5 } })
        end
        if Slot.SetAlignment then
            Slot:SetAlignment({ X = 0.5, Y = 0.5 })
        end
        if Slot.SetPosition then
            Slot:SetPosition({ X = -ScreenW * 0.5, Y = -ScreenH * 0.5 })
        end
        if Slot.SetSize then
            Slot:SetSize({ X = ScreenW, Y = ScreenH })
        end
        if Slot.SetAutoSize then
            Slot:SetAutoSize(false)
        end
    end

    local Bg = UGCWidgetManagerSystem.CreateBorder(Panel, "BgBorder")
    if Bg then
        local BS = Bg.Slot
        if BS then
            if BS.SetAnchors then
                BS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } })
            end
            if BS.SetOffsets then
                BS:SetOffsets({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
            end
        end
        if Bg.SetBrushColor then
            pcall(function() Bg:SetBrushColor(MakeColor(COLOR.Bg)) end)
        end
        if Bg.Background then
            if Bg.Background.TintColor then
                Bg.Background.TintColor = MakeColor(COLOR.Bg)
            end
        end
    end

    local BorderFrame = UGCWidgetManagerSystem.CreateBorder(Panel, "BorderFrame")
    if BorderFrame then
        local BFS = BorderFrame.Slot
        if BFS then
            if BFS.SetAnchors then
                BFS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } })
            end
            if BFS.SetOffsets then
                BFS:SetOffsets({ Left = 2, Top = 2, Right = 2, Bottom = 2 })
            end
        end
        if BorderFrame.SetBrushColor then
            pcall(function() BorderFrame:SetBrushColor(MakeColor(COLOR.Border)) end)
        end
    end

    local Title = UGCWidgetManagerSystem.CreateTextBlock(Panel, "Txt_Title")
    if Title then
        local TS = Title.Slot
        if TS then
            if TS.SetAnchors then
                TS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 0 } })
            end
            if TS.SetOffsets then
                TS:SetOffsets({ Left = 20, Top = 12, Right = 20, Bottom = 50 })
            end
            if TS.SetAlignment then
                TS:SetAlignment({ X = 0.5, Y = 0.5 })
            end
        end
        SetText(Title, "💰 付费功能测试面板")
        SetTextColor(Title, COLOR.Title)
        ApplyFontSize(Title, 20)
    end

    local SubTitle = UGCWidgetManagerSystem.CreateTextBlock(Panel, "Txt_SubTitle")
    if SubTitle then
        local SS = SubTitle.Slot
        if SS then
            if SS.SetAnchors then
                SS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 0 } })
            end
            if SS.SetOffsets then
                SS:SetOffsets({ Left = 20, Top = 46, Right = 20, Bottom = 70 })
            end
            if SS.SetAlignment then
                SS:SetAlignment({ X = 0.5, Y = 0.5 })
            end
        end
        SetText(SubTitle, "PIE调试：购买默认成功，物品测试不清空")
        SetTextColor(SubTitle, COLOR.TextDim)
        ApplyFontSize(SubTitle, 12)
    end

    local TxtTicket = UGCWidgetManagerSystem.CreateTextBlock(Panel, "Txt_Ticket")
    if TxtTicket then
        local TS = TxtTicket.Slot
        if TS then
            if TS.SetAnchors then
                TS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 0.5, Y = 0 } })
            end
            if TS.SetOffsets then
                TS:SetOffsets({ Left = 20, Top = 75, Right = 260, Bottom = 105 })
            end
        end
        SetText(TxtTicket, "绿洲币: --")
        SetTextColor(TxtTicket, COLOR.Green)
        ApplyFontSize(TxtTicket, 16)
    end

    local TxtCoin = UGCWidgetManagerSystem.CreateTextBlock(Panel, "Txt_Coin")
    if TxtCoin then
        local CS = TxtCoin.Slot
        if CS then
            if CS.SetAnchors then
                CS:SetAnchors({ Minimum = { X = 0.5, Y = 0 }, Maximum = { X = 1, Y = 0 } })
            end
            if CS.SetOffsets then
                CS:SetOffsets({ Left = 240, Top = 75, Right = 20, Bottom = 105 })
            end
        end
        SetText(TxtCoin, "启元币: --")
        SetTextColor(TxtCoin, COLOR.Green)
        ApplyFontSize(TxtCoin, 16)
    end

    local Line1 = UGCWidgetManagerSystem.CreateBorder(Panel, "Line1")
    if Line1 then
        local L1S = Line1.Slot
        if L1S then
            if L1S.SetAnchors then
                L1S:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 0 } })
            end
            if L1S.SetOffsets then
                L1S:SetOffsets({ Left = 20, Top = 110, Right = 20, Bottom = 111 })
            end
        end
        if Line1.SetBrushColor then
            pcall(function() Line1:SetBrushColor(MakeColor(COLOR.Border)) end)
        end
    end

    local BtnBuy = AddButton(Panel, "BtnBuy", "🛒 购买: 初级矿工成长礼包 (15绿洲币)",
        20, 120, ScreenW - 40, 44, COLOR.BuyBtn, 14, PaymentTestUI.OnBuyClicked)
    local BtnRecharge = AddButton(Panel, "BtnRecharge", "💳 显示绿洲币充值入口",
        20, 168, ScreenW - 40, 36, COLOR.NormalBtn, 13, PaymentTestUI.OnShowRechargeClicked)

    local Line2 = UGCWidgetManagerSystem.CreateBorder(Panel, "Line2")
    if Line2 then
        local L2S = Line2.Slot
        if L2S.SetAnchors then
            L2S:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 0 } })
        end
        if L2S.SetOffsets then
            L2S:SetOffsets({ Left = 20, Top = 212, Right = 20, Bottom = 213 })
        end
        if Line2.SetBrushColor then
            pcall(function() Line2:SetBrushColor(MakeColor(COLOR.Border)) end)
        end
    end

    local LabelOwned = UGCWidgetManagerSystem.CreateTextBlock(Panel, "LabelOwned")
    if LabelOwned then
        local LS = LabelOwned.Slot
        if LS then
            if LS.SetAnchors then
                LS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 0 } })
            end
            if LS.SetOffsets then
                LS:SetOffsets({ Left = 20, Top = 218, Right = 20, Bottom = 240 })
            end
        end
        SetText(LabelOwned, "📦 已拥有的虚拟物品:")
        SetTextColor(LabelOwned, COLOR.SubTitle)
        ApplyFontSize(LabelOwned, 14)
    end

    local TxtList = UGCWidgetManagerSystem.CreateTextBlock(Panel, "Txt_CommodityList")
    if TxtList then
        local LIS = TxtList.Slot
        if LIS then
            if LIS.SetAnchors then
                LIS:SetAnchors({ Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 0 } })
            end
            if LIS.SetOffsets then
                LIS:SetOffsets({ Left = 20, Top = 240, Right = 20, Bottom = 320 })
            end
        end
        SetText(TxtList, "  (加载中...)")
        SetTextColor(TxtList, COLOR.SubTitle)
        ApplyFontSize(TxtList, 13)
    end

    local BtnUse1 = AddButton(Panel, "BtnUseIronDrill", "使用: 铁钻头 (1001)",
        20, 325, (ScreenW - 60) / 2, 36, COLOR.UseBtn, 13, PaymentTestUI.OnUseIronDrill)
    local BtnUse2 = AddButton(Panel, "BtnUseBackpack", "使用: 背包升级券 (1002)",
        20 + (ScreenW - 60) / 2 + 20, 325, (ScreenW - 60) / 2, 36, COLOR.UseBtn, 13, PaymentTestUI.OnUseBackpackTicket)
    local BtnUse3 = AddButton(Panel, "BtnUseJade", "使用: 玉矿石 x5 (1003)",
        20, 367, ScreenW - 40, 36, COLOR.UseBtn, 13, PaymentTestUI.OnUseJadeOre)

    local BtnClose = AddButton(Panel, "BtnClose", "✕ 关闭",
        ScreenW - 120, ScreenH - 50, 100, 36, COLOR.CloseBtn, 13, PaymentTestUI.OnCloseClicked)

    PaymentTestUI.RefreshAll()
end

function PaymentTestUI.Open()
    if PaymentTestUI.bOpen then
        PaymentTestUI.RefreshAll()
        return
    end

    local pc = PaymentTestUI.GetPlayerController()
    if not pc then
        ugcprint("[PaymentTestUI] ❌ 无法获取PlayerController")
        return
    end

    if not UGCWidgetManagerSystem then
        ugcprint("[PaymentTestUI] ❌ UGCWidgetManagerSystem 不可用")
        return
    end

    PaymentTestUI.bOpen = true
    PaymentTestUI.BuildPanel()

    if PaymentTestUI.PanelWidget then
        UGCWidgetManagerSystem.AddToSlot(PaymentTestUI.PanelWidget, "UI.UISlot.MainUISlot_High")
    end

    ugcprint("[PaymentTestUI] ✅ 付费测试面板已打开 (购买/使用会自动弹出二次确认)")
end

function PaymentTestUI.Close()
    if not PaymentTestUI.bOpen then return end

    PaymentTestUI.bOpen = false

    if PaymentTestUI.PanelWidget then
        UGCWidgetManagerSystem.RemoveFromSlot(PaymentTestUI.PanelWidget, "UI.UISlot.MainUISlot_High")
        PaymentTestUI.PanelWidget = nil
    end

    ugcprint("[PaymentTestUI] 付费测试面板已关闭")
end

function PaymentTestUI.Toggle()
    if PaymentTestUI.bOpen then
        PaymentTestUI.Close()
    else
        PaymentTestUI.Open()
    end
end

function PaymentTestUI.OnPaymentNotification(Msg)
    if not PaymentTestUI.bOpen then return end
    PaymentTestUI.RefreshAll()
end

return PaymentTestUI