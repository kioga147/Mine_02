---@class ShopV2_Goods_UIBP_C:UUserWidget
---@field ShopEmptyInfo UCanvasPanel
---@field ShopEmptyInfoText UTextBlock
---@field ShopItemDetailPanel UShopV2_Goods_Panel_UIBP_C
---@field ShopItemsList UUGC_ReuseList2_C
--Edit Below--
local ShopV2_Goods_UIBP = 
{ 
    bInitDoOnce = false;
    TabID = 0;
    CurrentProducts = {};
    LimitProducts = {};
    LastSelectedProductID = 0;
    SelectedProductID = 0;

    ProductIDsInTab = nil;
}; 

function ShopV2_Goods_UIBP:Construct()
	
    self.ShopItemsList.OnUpdateItem:Add(self.OnUpdateItem, self);

    local PriceButton = self.ShopItemDetailPanel.BuyButton.PriceButton;
    local FreeButton  = self.ShopItemDetailPanel.BuyButton.FreeButton;
    local SoldOutButton = self.ShopItemDetailPanel.BuyButton.SoldOutButton;
    PriceButton.OnClicked:Add(self.ShopItemDetailPanel.BuyButton.OnClick, self.ShopItemDetailPanel.BuyButton);
    FreeButton.OnClicked:Add(self.ShopItemDetailPanel.BuyButton.OnClick, self.ShopItemDetailPanel.BuyButton);
    SoldOutButton.OnClicked:Add(self.ShopItemDetailPanel.BuyButton.OnClick, self.ShopItemDetailPanel.BuyButton);
end

function ShopV2_Goods_UIBP:RefreshProductList(TabID, bCheckListingTime)
    
    print("[ShopV2_Goods_UIBP:RefreshProductList] Start refresh product list");

    local bRefreshCurrent = self.TabID == TabID;
    self.TabID = TabID;
    self.CurrentProducts = {};
    self.LimitProducts = {};

    self.ProductIDsInTab = ShopV2Manager:GetProductIDsInTab(TabID, bCheckListingTime);
    
    local Num = #self.ProductIDsInTab;
    if Num > 0 then
        self.SelectedProductID = self.ProductIDsInTab[1]; 
    end

    if bRefreshCurrent == true then
        for Idx, ProductID in ipairs(self.ProductIDsInTab) do
            if self.LastSelectedProductID == ProductID then
                self.SelectedProductID = ProductID;
                break;
            end
        end
    end

    self.LastSelectedProductID = self.SelectedProductID;

    if not bRefreshCurrent then
        self.ShopItemsList:ScrollToStart();
    end
    
    self.ShopItemsList:Reload(Num);

    if Num == 0 then
        self.ShopEmptyInfo:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    else
        self.ShopEmptyInfo:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function ShopV2_Goods_UIBP:RefreshCurrentList(bCheckListingTime)
    
    self:RefreshProductList(self.TabID, bCheckListingTime);
end

function ShopV2_Goods_UIBP:RefreshProductDetailPanel(ProductID)

    self.ShopItemDetailPanel:Refresh(ProductID);
end

function ShopV2_Goods_UIBP:RefreshCurrentProductDetailPanel()
    
    self.ShopItemDetailPanel:Refresh(self.SelectedProductID);
end

---@param Item ShopV2_CommonItem_UIBP_C
---@param Idx number
function ShopV2_Goods_UIBP:OnUpdateItem(Item, Idx)

    local ProductID = self.ProductIDsInTab[Idx+1];

    Item:Refresh(ProductID);

    if self.SelectedProductID == ProductID then
        Item:Select();
        self:RefreshProductDetailPanel(self.SelectedProductID);
    else
        Item:Deselect();
    end

    self.CurrentProducts[ProductID] = Item;

    if ShopV2Manager:GetProductConfigData(ProductID).LimitType ~= ELimitType.NotLimited then
        self.LimitProducts[ProductID] = Item;
    end
end

function ShopV2_Goods_UIBP:SelectProduct(ProductID)
    
    self.CurrentProducts[ProductID]:Select();
    if ProductID == self.SelectedProductID then
        return;
    end

    if self.CurrentProducts[self.SelectedProductID] then
        self.CurrentProducts[self.SelectedProductID]:Deselect();
    end

    self.SelectedProductID = ProductID;
    self.LastSelectedProductID = ProductID;

    self:RefreshProductDetailPanel(ProductID);
end

return ShopV2_Goods_UIBP;