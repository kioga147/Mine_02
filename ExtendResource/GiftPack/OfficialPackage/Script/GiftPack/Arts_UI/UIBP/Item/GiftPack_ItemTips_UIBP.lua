---@class GiftPack_ItemTips_UIBP_C:UUserWidget
---@field BasePanel UCanvasPanel
---@field CloseButton UButton
---@field DescText UTextBlock
---@field Icon UImage
---@field NameText UTextBlock
---@field NumText UTextBlock
---@field TipPanel UCanvasPanel
--Edit Below--


local GiftPack_ItemTips_UIBP = {
    bInitDoOnce = false
}


function GiftPack_ItemTips_UIBP:Construct()
	self:LuaInit();
end

function GiftPack_ItemTips_UIBP:Refresh(ItemID, Position)
    print(string.format("GiftPack_ItemTips_UIBP:Refresh"));
    local ItemData = Common.GetObjectDatas()[ItemID];
    if ItemData == nil then
        return;
    end

    self.NameText:SetText(ItemData.ItemName);
    self.DescText:SetText(ItemData.ItemDesc);

    Common.LoadObjectAsync(ItemData.ItemIcon, 
        function (Object)
            if self ~= nil and Object ~= nil then
                self.Icon:SetBrushFromTexture(Object);
            end
        end
    )
    local ItemNum = GiftPackManager:GetItemNum(ItemID);
    self.NumText:SetText(string.format("已拥有%d个", ItemNum));

    self:SetPosition(Position);
end

function GiftPack_ItemTips_UIBP:LuaInit()
    if self.bInitDoOnce then
        return;
    end

    self.bInitDoOnce = true;
    self.CloseButton.OnClicked:Add(self.Close, self)
end

function GiftPack_ItemTips_UIBP:Close()
    
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function GiftPack_ItemTips_UIBP:SetPosition(Position)
    self:RemoveFromViewport();
    self:AddToViewport(30000);
    local ViewportSize = WidgetLayoutLibrary.GetViewportSize(self);
    local ViewportScale = WidgetLayoutLibrary.GetViewportScale(self);
    local MaxX = ViewportSize.X;
    local MaxY = ViewportSize.Y;

    local TipSize = self.BasePanel.Slots[2]:GetSize();
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

    self.BasePanel.Slots[2]:SetPosition(Position);
end

return GiftPack_ItemTips_UIBP