---@class ShopV2_Goods_Panel_UIBP_C:UUserWidget
---@field BuyButton UShopV2_CommonButton_UIBP_C
---@field CurrencyIcon UImage
---@field DescriptionText UTextBlock
---@field Image_Market_Goods_QualityLine UImage
---@field ItemImage UImage
---@field NameText UTextBlock
---@field PriceText UTextBlock
---@field PurchaseLimitInfo UHorizontalBox
---@field PurchaseLimitNumText UTextBlock
--Edit Below--

local ShopV2_Goods_Panel_UIBP = { bInitDoOnce = false; }; 

function ShopV2_Goods_Panel_UIBP:Construct()
	
end

function ShopV2_Goods_Panel_UIBP:Reset()

    self.PurchaseLimitInfo:SetVisibility(ESlateVisibility.Collapsed);
end

function ShopV2_Goods_Panel_UIBP:Refresh(ProductID)

    self.CurrentProductID = ProductID;

    local ProductData = ShopV2Manager:GetProductConfigData(ProductID);
    if ProductData == nil then
        print("ShopV2_Goods_Panel_UIBP:Refresh ProductData is nil for " .. tostring(ProductID));
        return;
    end
    print("[ShopDiag] GoodsPanel Refresh ProductID=" .. tostring(ProductID) .. " Name=" .. tostring(ProductData.ProductName) .. " Price=" .. tostring(ProductData.SellingPrice))
    local ObjectData = ShopV2Manager:GetItemConfigData(ProductData.ItemID);
    if ObjectData == nil then
        print("ShopV2_Goods_Panel_UIBP:Refresh ObjectData is nil for ItemID " .. tostring(ProductData.ItemID));
        return;
    end

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

    local RemainingTime = -1;
    if ProductData.LimitType ~= ELimitType.NotLimited then
        local PurchaseTime = ShopV2Manager:GetLimitPurchasedTimes(ProductID);
        RemainingTime = ProductData.PurchaseLimit - PurchaseTime;

        if RemainingTime < 0 then
            RemainingTime = 0;
        end
    end

    -- 礼包联动锁定：已购买更高级礼包则低级礼包剩余次数置 0
    if ShopV2Manager:IsGiftBlockedByHigherLevel(ProductID) then
        RemainingTime = 0;
    end

    if RemainingTime >= 0 then
        self.PurchaseLimitInfo:SetVisibility(ESlateVisibility.HitTestInvisible);
        self.PurchaseLimitNumText:SetText(tostring(RemainingTime));
    end

    self.BuyButton:Refresh(ProductID);
end

return ShopV2_Goods_Panel_UIBP;
