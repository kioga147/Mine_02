---@class WBP_EnterButton_C:UUserWidget
---@field Btn_Enter UButton
---@field CanvasPanel_Root UCanvasPanel
---@field Txt_BuildingName UTextBlock
--Edit Below--
--- 进入确认过渡按钮：进入建筑触发器时显示，点击后打开对应建筑 UI
local WBP_EnterButton = {
    bBound = false,
    BuildingName = '',
    OnOpenCallback = nil,
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

--- 全程 pcall 包裹，避免在无父槽位/无属性时抛异常
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
    local Ok, Slot = pcall(function()
        return Widget.Slot
    end)
    if Ok then
        return Slot
    end
    return nil
end

--- 强制可见 + 定位；只在控件已 AddToSlot（有父槽位）后由管理器调用
function WBP_EnterButton:AfterAdded()
    if self.SetVisibility then
        pcall(function()
            self:SetVisibility((ESlateVisibility and ESlateVisibility.Visible) or 0)
        end)
    end
    local Btn = GetW(self, 'Btn_Enter')
    if Btn and Btn.SetVisibility then
        pcall(function()
            Btn:SetVisibility((ESlateVisibility and ESlateVisibility.Visible) or 0)
        end)
    end
    local Slot = GetCanvasSlot(self)
    if Slot then
        pcall(function()
            if Slot.SetAnchors then
                Slot:SetAnchors({ Minimum = { X = 0.5, Y = 0.82 }, Maximum = { X = 0.5, Y = 0.82 } })
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
                Slot:SetZOrder(100)
            end
        end)
    end
    ugcprint('[EnterButton] AfterAdded OK')
end

--- 由 EnterButtonManager 调用：写入建筑名 + 点击后要执行的逻辑
function WBP_EnterButton:SetData(BuildingName, OnOpenCallback)
    self.BuildingName = tostring(BuildingName or '')
    self.OnOpenCallback = OnOpenCallback
    local Txt = GetW(self, 'Txt_BuildingName')
    if Txt and Txt.SetText then
        pcall(function()
            Txt:SetText(self.BuildingName)
        end)
        ugcprint('[EnterButton] SetData text = ' .. tostring(self.BuildingName))
    else
        ugcprint('[EnterButton] WARNING: Txt_BuildingName 未找到')
    end
end

--- Construct 保持最简：先打日志、再绑按钮，不做任何控件操作
function WBP_EnterButton:Construct()
    ugcprint('[EnterButton] Construct BEGIN')
    if self.bBound then
        return
    end
    self.bBound = true
    local Btn = GetW(self, 'Btn_Enter')
    if Btn and Btn.OnClicked then
        pcall(function()
            Btn.OnClicked:Add(self.OnEnterClicked, self)
        end)
    end
    ugcprint('[EnterButton] Construct OK')
end

function WBP_EnterButton:Destruct()
    local Btn = GetW(self, 'Btn_Enter')
    if Btn and Btn.OnClicked then
        pcall(function()
            Btn.OnClicked:Remove(self.OnEnterClicked, self)
        end)
    end
    self.bBound = false
    self.OnOpenCallback = nil
    ugcprint('[EnterButton] Destruct')
end

function WBP_EnterButton:OnEnterClicked()
    local cb = self.OnOpenCallback
    if cb then
        pcall(cb)
    end
    ugcprint('[EnterButton] OnEnterClicked')
end

return WBP_EnterButton