---@class UGC_Task_Tips_UIBP_C:UUserWidget
---@field BasePanel UCanvasPanel
---@field CloseButton UNewButton
---@field DescText UTextBlock
---@field Icon UImage
---@field NameText UTextBlock
---@field NumText UTextBlock
---@field TipPanel UCanvasPanel
--Edit Below--
local UGC_Task_Tips_UIBP = { bInitDoOnce = false } 

function UGC_Task_Tips_UIBP:Construct()
    self.CloseButton.OnClicked:Add(self.CloseClick, self);
end

function UGC_Task_Tips_UIBP:CloseClick()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

-- function UGC_Task_Tips_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_Task_Tips_UIBP:Destruct()
    self.CloseButton.OnClicked:RemoveAll();
end

function UGC_Task_Tips_UIBP:InitUI(ItemID, Position)
    print(string.format("[UGC_Task_Tips_UIBP:InitUI] ItemID: %d", ItemID));
    local ItemData = Common.GetObjectDatas()[ItemID];
    if ItemData == nil then
        return;
    end
    self.NameText:SetText(ItemData.ItemName);
    self.DescText:SetText(ItemData.ItemDesc);
    if ItemData.ItemIcon then
        Common.LoadObjectAsync(ItemData.ItemIcon,
        function (Object)
            if self ~= nil and Object ~= nil then
                self.Icon:SetBrushFromTexture(Object);
            end
        end)
    end
    local ItemNum = TaskManager:GetItemNum(ItemID) or 0;
    print(string.format("[UGC_Task_Tips_UIBP:InitUI] ItemNum: %d", ItemNum));
    self.NumText:SetText(string.format("已拥有%d个", ItemNum));
    self:SetPosition(Position);
end

function UGC_Task_Tips_UIBP:SetPosition(Position)
    print("[UGC_Task_Tips_UIBP:SetPosition]");
    print(Position.X);
    print(Position.Y);
    local ViewportSize = WidgetLayoutLibrary.GetViewportSize(self);
    local ViewportScale = WidgetLayoutLibrary.GetViewportScale(self);
    local MaxX = ViewportSize.X;
    local MaxY = ViewportSize.Y;
    print(string.format("ViewportSize X: %d, Y: %d", tonumber(ViewportSize.X), tonumber(ViewportSize.Y)));
    print(string.format("ViewportScale %s", tostring(ViewportScale)));

    local TipSize = self.BasePanel.Slots[1]:GetSize();
    print(string.format("TipSize X: %d, Y: %d", tonumber(TipSize.X), tonumber(TipSize.Y)));
    local DesireX = (Position.X + TipSize.X) * ViewportScale;
    local DesireY = (Position.Y + TipSize.Y) * ViewportScale;

    if DesireX > MaxX then
        Position.X = Position.X - (DesireX - MaxX);
    end
    
    if DesireX < 0 then
        Position.X = 0;
    end

    if DesireY > MaxY then
        Position.Y = Position.Y - (DesireY - MaxY);
    end

    if DesireY < 0 then
        Position.Y = 0;
    end
    print("[UGC_Task_Tips_UIBP:SetPosition] EndPosition");
    print(Position.X);
    print(Position.Y);
    self.BasePanel.Slots[1]:SetPosition(Position);
end

return UGC_Task_Tips_UIBP