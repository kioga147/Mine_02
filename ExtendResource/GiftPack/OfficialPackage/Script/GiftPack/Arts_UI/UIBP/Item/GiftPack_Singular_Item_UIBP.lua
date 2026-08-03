---@class GiftPack_Singular_Item_UIBP_C:UUserWidget
---@field Button_Confirm UButton
---@field Image_Icon UImage
---@field Image_Quality UImage
---@field Image_Select UImage
---@field TextBlock_Name UTextBlock
---@field TextBlock_Quantity UTextBlock
--Edit Below--
local GiftPack_Singular_Item_UIBP = { bInitDoOnce = false } 

function GiftPack_Singular_Item_UIBP:Construct()
	self.Button_Confirm.OnClicked:Add(self.SelectItem, self);
    self.Button_Confirm.OnPressed:Add(self.OnPress, self);
    self.Button_Confirm.OnReleased:Add(self.OnRelease, self);
end

-- function GiftPack_Singular_Item_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function GiftPack_Singular_Item_UIBP:Destruct()

-- end

function GiftPack_Singular_Item_UIBP:SelectItem()
    print("GiftPack_Singular_Item_UIBP:SelectItem");
    GiftPackManager:SelectItemByIndex(self.Index);
    self:Select();
end

function GiftPack_Singular_Item_UIBP:Select()
    -- 通知父界面刷新
    self.Image_Select:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function GiftPack_Singular_Item_UIBP:UnSelect()
    self.Image_Select:SetVisibility(ESlateVisibility.Collapsed);
end

function GiftPack_Singular_Item_UIBP:GetSelect()
end

function GiftPack_Singular_Item_UIBP:OnPress()
    print("GiftPack_Singular_Item_UIBP:OnPress");
    self.PressTimerHandle = Timer.InsertTimer(
        0, 
        function ()
            print("GiftPack_Singular_Item_UIBP: LongPress");
            local AbsPosition = SlateBlueprintLibrary.GetAbsolutePosition(self:GetCachedGeometry());
            local Position = SlateBlueprintLibrary.AbsoluteToLocal(WidgetLayoutLibrary.GetViewportWidgetGeometry(self), AbsPosition);
            GiftPackManager:ShowItemTip(self.ItemID , Position);
        end,
        false,
        "ShowTipPressTimer",
        0.5
    );
end

function GiftPack_Singular_Item_UIBP:OnRelease()
    if self.PressTimerHandle ~= nil then
        Timer.RemoveTimer(self.PressTimerHandle);
        self.PressTimerHandle = nil; 
    end
end

function GiftPack_Singular_Item_UIBP:InitUI(Index, ItemID, ItemMinNum, ItemMaxNum)
    print("GiftPack_Singular_Item_UIBP:InitUI");
    self.ItemID = ItemID;
    self.Index = Index;
    local ItemInfo = GiftPackManager:GetItemInfoByItemID(ItemID);
    if ItemInfo then
        if ItemInfo.ItemIcon then
            Common.LoadObjectAsync(ItemInfo.ItemIcon, 
            function (Object)
                if self ~= nil and Object ~= nil then
                    self.Image_Icon:SetBrushFromTexture(Object);
                end
            end)
        end

        if ItemInfo.ItemName then
            -- 字数限制为7个
            self.TextBlock_Name:SetText(ItemInfo.ItemName);
        end

        if ItemMaxNum == ItemMinNum then
            self.TextBlock_Quantity:SetText(string.format("%d", ItemMinNum));
        else
            self.TextBlock_Quantity:SetText(string.format("%d~%d", ItemMinNum, ItemMaxNum));
        end
    end
end

return GiftPack_Singular_Item_UIBP