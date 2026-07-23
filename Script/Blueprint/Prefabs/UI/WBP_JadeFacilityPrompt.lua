---@class WBP_JadeFacilityPrompt_C:UUserWidget
---@field PromptCard UBorder
---@field PromptRoot UVerticalBox
---@field Txt_Prompt UTextBlock
---@field Btn_Enter UButton
---@field Txt_Enter UTextBlock
---@field Btn_Unlock UButton
---@field Txt_Unlock UTextBlock
---@field Btn_Quick UButton
---@field Txt_Quick UTextBlock
---@field Btn_Manual UButton
---@field Txt_Manual UTextBlock
---@field Btn_Close UButton
---@field Txt_Close UTextBlock
--Edit Below--
--- 模式选择层：解锁 / 快速鉴定 / 手动鉴定 / 关闭（不直接进 5×5）
local WBP_JadeFacilityPrompt = {
    bBound = false,
    Callbacks = nil, -- { OnUnlock, OnQuick, OnManual, OnClose }
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

function WBP_JadeFacilityPrompt:ApplyPromptLayout()
    local Card = GetW(self, "PromptCard")
    local Slot = GetCanvasSlot(Card)
    if Slot then
        pcall(function()
            if Slot.SetAnchors then
                Slot:SetAnchors({ Minimum = { X = 0.5, Y = 0.78 }, Maximum = { X = 0.5, Y = 0.78 } })
            end
            if Slot.SetAlignment then
                Slot:SetAlignment({ X = 0.5, Y = 0.5 })
            end
            if Slot.SetAutoSize then
                Slot:SetAutoSize(true)
            end
            if Slot.SetPosition then
                Slot:SetPosition({ X = 0, Y = 0 })
            end
            if Slot.SetZOrder then
                Slot:SetZOrder(50)
            end
        end)
    end

    -- 旧「进入」隐藏；模式选择用解锁/快速/手动/关闭
    SetVisible(GetW(self, "Btn_Enter"), false)
    SetVisible(GetW(self, "Gap_Prompt"), false)

    local TxtUnlock = GetW(self, "Txt_Unlock")
    if TxtUnlock and TxtUnlock.SetText then
        TxtUnlock:SetText("解锁鉴定所 (15000)")
    end
    local TxtQuick = GetW(self, "Txt_Quick")
    if TxtQuick and TxtQuick.SetText then
        TxtQuick:SetText("快速鉴定 (3000)")
    end
    local TxtManual = GetW(self, "Txt_Manual")
    if TxtManual and TxtManual.SetText then
        TxtManual:SetText("手动鉴定")
    end
    local TxtClose = GetW(self, "Txt_Close")
    if TxtClose and TxtClose.SetText then
        TxtClose:SetText("关闭")
    end
end

--- Status: { bUnlocked, JadeCount, GoldCount, UnlockCost, QuickCost, LastMsg }
function WBP_JadeFacilityPrompt:RefreshShopState(Status)
    Status = Status or {}
    local bUnlocked = Status.bUnlocked == true
    local JadeCount = tonumber(Status.JadeCount) or 0
    local GoldCount = tonumber(Status.GoldCount) or 0
    local UnlockCost = tonumber(Status.UnlockCost) or 15000
    local QuickCost = tonumber(Status.QuickCost) or 3000
    local LastMsg = tostring(Status.LastMsg or "")

    local Txt = GetW(self, "Txt_Prompt")
    if Txt and Txt.SetText then
        local Line
        if not bUnlocked then
            Line = string.format("玉石鉴定所 · 请先解锁（%d 金币，当前 %d）", UnlockCost, GoldCount)
        else
            Line = string.format("玉石鉴定所 · 请选择模式（玉石 x%d · 金币 %d）", JadeCount, GoldCount)
        end
        if LastMsg ~= "" then
            Line = Line .. "\n" .. LastMsg
        end
        Txt:SetText(Line)
    end

    -- 未解锁：只显示解锁 + 关闭；已解锁：快速 + 手动 + 关闭
    SetVisible(GetW(self, "Btn_Unlock"), not bUnlocked)
    SetVisible(GetW(self, "Gap_Unlock"), not bUnlocked)
    SetVisible(GetW(self, "Btn_Quick"), bUnlocked)
    SetVisible(GetW(self, "Gap_Quick"), bUnlocked)
    SetVisible(GetW(self, "Btn_Manual"), bUnlocked)
    SetVisible(GetW(self, "Gap_Manual"), bUnlocked)
    SetVisible(GetW(self, "Btn_Close"), true)
    SetVisible(GetW(self, "Gap_Close"), true)

    local BtnUnlock = GetW(self, "Btn_Unlock")
    if BtnUnlock and BtnUnlock.SetIsEnabled then
        BtnUnlock:SetIsEnabled(GoldCount >= UnlockCost)
    end
    local BtnQuick = GetW(self, "Btn_Quick")
    if BtnQuick and BtnQuick.SetIsEnabled then
        BtnQuick:SetIsEnabled(JadeCount >= 1 and GoldCount >= QuickCost)
    end
    local BtnManual = GetW(self, "Btn_Manual")
    if BtnManual and BtnManual.SetIsEnabled then
        BtnManual:SetIsEnabled(JadeCount >= 1)
    end
end

function WBP_JadeFacilityPrompt:SetShopCallbacks(Callbacks)
    self.Callbacks = Callbacks or {}
end

function WBP_JadeFacilityPrompt:Construct()
    self:ApplyPromptLayout()
    if self.bBound then
        return
    end
    self.bBound = true

    local BtnUnlock = GetW(self, "Btn_Unlock")
    if BtnUnlock and BtnUnlock.OnClicked then
        BtnUnlock.OnClicked:Add(self.OnUnlockClicked, self)
    end
    local BtnQuick = GetW(self, "Btn_Quick")
    if BtnQuick and BtnQuick.OnClicked then
        BtnQuick.OnClicked:Add(self.OnQuickClicked, self)
    end
    local BtnManual = GetW(self, "Btn_Manual")
    if BtnManual and BtnManual.OnClicked then
        BtnManual.OnClicked:Add(self.OnManualClicked, self)
    end
    local BtnClose = GetW(self, "Btn_Close")
    if BtnClose and BtnClose.OnClicked then
        BtnClose.OnClicked:Add(self.OnCloseClicked, self)
    end
end

function WBP_JadeFacilityPrompt:Destruct()
    local pairsList = {
        { "Btn_Unlock", "OnUnlockClicked" },
        { "Btn_Quick", "OnQuickClicked" },
        { "Btn_Manual", "OnManualClicked" },
        { "Btn_Close", "OnCloseClicked" },
    }
    for _, Info in ipairs(pairsList) do
        local Btn = GetW(self, Info[1])
        if Btn and Btn.OnClicked then
            pcall(function()
                Btn.OnClicked:Remove(self[Info[2]], self)
            end)
        end
    end
    self.bBound = false
    self.Callbacks = nil
end

function WBP_JadeFacilityPrompt:OnUnlockClicked()
    if self.Callbacks and self.Callbacks.OnUnlock then
        pcall(self.Callbacks.OnUnlock)
    end
end

function WBP_JadeFacilityPrompt:OnQuickClicked()
    if self.Callbacks and self.Callbacks.OnQuick then
        pcall(self.Callbacks.OnQuick)
    end
end

function WBP_JadeFacilityPrompt:OnManualClicked()
    if self.Callbacks and self.Callbacks.OnManual then
        pcall(self.Callbacks.OnManual)
    end
end

function WBP_JadeFacilityPrompt:OnCloseClicked()
    if self.Callbacks and self.Callbacks.OnClose then
        pcall(self.Callbacks.OnClose)
    end
end

-- 兼容旧接口
function WBP_JadeFacilityPrompt:SetEnterCallback(Callback)
    self.Callbacks = self.Callbacks or {}
    self.Callbacks.OnManual = Callback
end

function WBP_JadeFacilityPrompt:OnEnterClicked()
    self:OnManualClicked()
end

return WBP_JadeFacilityPrompt
