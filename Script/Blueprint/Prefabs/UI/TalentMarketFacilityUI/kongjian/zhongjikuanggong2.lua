---@class dijikuanggong3_C:UUserWidget
---@field Button_110 UButton
---@field CurrencyIcon UImage
---@field DescriptionText UTextBlock
---@field Image_159 UImage
---@field Image_Market_Goods_QualityLine UImage
---@field ItemImage UImage
---@field NameText UTextBlock
---@field PriceText UTextBlock
--Edit Below--

local zhongjikuanggong2 = { bInitDoOnce = false; }; 

function zhongjikuanggong2:Construct()
	
end

function zhongjikuanggong2:Reset()

    self.PurchaseLimitInfo:SetVisibility(ESlateVisibility.Collapsed);
end

function zhongjikuanggong2:Refresh(ProductID)

    self.CurrentProductID = ProductID;

    local ProductData = ShopV2Manager:GetProductConfigData(ProductID);
    local ObjectData = ShopV2Manager:GetItemConfigData(ProductData.ItemID);

    self:Reset();

    local Price = ShopV2Manager:GetDiscountPrice(ProductID);
    self.PriceText:SetText(Price);

    self.NameText:SetText(ProductData.ProductName);
    self.DescriptionText:SetText(ObjectData.ItemDesc);
    
    Common.LoadObjectAsync(ObjectData.ItemIcon, 
        function (IconTexture)
            if self ~= nil and UE.IsValid(self) then
                self.ItemImage:SetBrushFromTexture(IconTexture);
            end
        end
    );

    local Path = ShopV2Manager:GetProductCurrencyIconPath(ProductID);
    if Path ~= nil then
        Common.LoadObjectAsync(Path, 
            function (IconTexture)
                if self ~= nil and UE.IsValid(self) then
                    self.CurrencyIcon:SetBrushFromTexture(IconTexture);
                end
            end
        );
    end

    if ProductData.LimitType ~= ELimitType.NotLimited then
        local PurchaseTime = ShopV2Manager:GetLimitPurchasedTimes(ProductID);
        local RemainingTime = ProductData.PurchaseLimit - PurchaseTime;

        if RemainingTime < 0 then
            RemainingTime = 0;
        end

        self.PurchaseLimitInfo:SetVisibility(ESlateVisibility.HitTestInvisible);
        self.PurchaseLimitNumText:SetText(tostring(RemainingTime));
    end

    self.BuyButton:Refresh(ProductID);
end

return zhongjikuanggong2;