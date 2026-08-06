UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage." .. "Script.Common.Common");

---@type UKismetMathLibrary
KismetMathLibrary = KismetMathLibrary == nil and nil or KismetMathLibrary

local Delegate = UGCGameSystem.UGCRequire("common.Delegate");

ShopV2Manager = ShopV2Manager or
{
    ShopComponentClass = nil;
    bBlockRepeatPurchase = false;
    LocalComponent = nil;
    ProductIDGroupByTabID = nil;
    VirtualItemManager = nil;
    CommodityOperationManager = nil;
    OnItemNumChangeDelegate = Delegate.New();
    ItemQuality = nil;
    bBuyProductResultBinded = false
}

function ShopV2Manager:RegisterComponentClass(CompClass)
    if CompClass ~= nil then
        self.ComponentClass = CompClass;
    end
end

function ShopV2Manager:RegisterMainUI(MainUI)
    if self.MainUI == nil then
        self.MainUI = MainUI;
    end
end

function ShopV2Manager:UnregisterMainUI()
    self.MainUI = nil;
    local cm = self:GetCommodityOperationManager()
    if cm then
        cm.BuyProductResultDelegate:Remove(self.OnBuyProductResult, self);
    end
    self.bBuyProductResultBinded = false
end

function ShopV2Manager:GetCommodityOperationManager()
    if self.CommodityOperationManager == nil then
        if UGCGamePartSystem and UGCGamePartSystem.CommodityOperationManager then
            self.CommodityOperationManager = UGCGamePartSystem.CommodityOperationManager.GetGlobalActor();
        end
    end
    return self.CommodityOperationManager;
end

function ShopV2Manager:GetVirtualItemManager()
    if self.VirtualItemManager == nil then
        if UGCGamePartSystem and UGCGamePartSystem.VirtualItemManager then
            self.VirtualItemManager = UGCGamePartSystem.VirtualItemManager.GetGlobalActor();
        end
    end
    return self.VirtualItemManager;
end

function ShopV2Manager:GetProductConfigData(ProductID)
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:GetProductData(ProductID) end
    return nil
end

function ShopV2Manager:GetItemConfigData(ItemID)
    local vm = self:GetVirtualItemManager()
    if vm then return vm:GetItemData(ItemID) end
    return nil
end

function ShopV2Manager:GetAllProductConfigData()
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:GetAllProductData() end
    return {}
end

function ShopV2Manager:GetAllItemConfigDatas()
    local vm = self:GetVirtualItemManager()
    if vm then return vm:GetItemDatas() end
    return {}
end

function ShopV2Manager:GetLimitPurchasedTimes(ProductID, PlayerController)
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:GetLimitPurchasedTimes(ProductID, PlayerController) end
    return 0
end

function ShopV2Manager:GetPurchasedTimes(ProductID, PlayerController)
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:GetPurchasedTimes(ProductID, PlayerController) end
    return 0
end

function ShopV2Manager:GetAllLimitPurchasedProducts(PlayerController)
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:GetAllLimitPurchasedProducts(PlayerController) end
    return {}
end

function ShopV2Manager:GetAllPurchasedProducts(PlayerController)
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:GetAllPurchasedProducts(PlayerController) end
    return {}
end

function ShopV2Manager:GetQualityTexturePath(ItemID, bBigSize)
    if self.ItemQuality == nil then
        local Comp = self:GetShopV2Component()
        if Comp ~= nil and Comp.ReadItemQualityTable then
            Comp:ReadItemQualityTable();
        end
        if self.ItemQuality == nil then
            self.ItemQuality = {};
        end
    end
    local QualityRank = self.ItemQuality[ItemID];
    if QualityRank == nil or QualityRank < 0 or QualityRank > 6 then
        QualityRank = 0;
    end
    local Path = bBigSize == true and UGCItemSystem.GetBigQualityTexturePath(QualityRank) or UGCItemSystem.GetQualityTexturePath(QualityRank);
    return Path;
end

function ShopV2Manager:GetQualityBarTexturePath(ItemID)
    if self.ItemQuality == nil then
        local Comp = self:GetShopV2Component()
        if Comp ~= nil and Comp.ReadItemQualityTable then
            Comp:ReadItemQualityTable();
        end
        if self.ItemQuality == nil then
            self.ItemQuality = {};
        end
    end
    local QualityRank = self.ItemQuality[ItemID];
    if QualityRank == nil or QualityRank < 0 or QualityRank > 6 then
        QualityRank = 0;
    end
    local Path = UGCItemSystem.GetQualityBarTexturePath(QualityRank);
    return Path;
end

function ShopV2Manager:CanAfford(ProductID, Num, PlayerController)
    local cm = self:GetCommodityOperationManager()
    if cm then return cm:CanAfford(ProductID, Num, PlayerController) end
    return false
end

function ShopV2Manager:GetShopV2Component(PlayerController)
    if PlayerController == nil and UGCGameSystem.GameState ~= nil and UGCGameSystem.GameState:HasAuthority() == false then
        if self.LocalComponent == nil then
            if self.ComponentClass ~= nil and UGCGameSystem.GameState ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(UGCGameSystem.GameState);
                self.LocalComponent = PlayerController:GetComponentByClass(self.ComponentClass);
            else
                print("[ShopV2Manager:GetShopV2Component] Cannot get local component!");
            end
        end
        return self.LocalComponent;
    end
    if self.ComponentClass ~= nil then
        return PlayerController:GetComponentByClass(self.ComponentClass);
    else
        print("[ShopV2Manager:GetShopV2Component] ComponentClass is nil!");
        return nil;
    end
end

function ShopV2Manager:OpenMainUI(TabID)
    if self.MainUI == nil then
        print("[ShopV2Manager:OpenMainUI] MainUI is nil!");
        return;
    end
    local cm = self:GetCommodityOperationManager()
    local vm = self:GetVirtualItemManager()
    if cm and not self.bBuyProductResultBinded then
        cm.BuyProductResultDelegate:Add(self.OnBuyProductResult, self);
        self.bBuyProductResultBinded = true
    end
    if cm then
        cm.LimitProductUpdateDelegate:Add(self.RefreshProducts, self);
    end
    if vm then
        vm.AddItemResultDelegate:Add(self.OnAddVirtualItem, self);
        vm.OnItemNumUpdatedDelegate:Add(self.OnItemNumUpdate, self);
    end
    if TabID ~= nil then
        self.MainUI.SelectedTabID = TabID;
        self.MainUI.ShopGoods.TabID = TabID;
    end
    self.MainUI:SetIsEnabled(true);
    self.MainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    self.MainUI:RefreshTabs();
    self.MainUI:InitCurrencyBar()
    self.MainUI:CheckRefreshTime();
    self.OnItemNumChangeDelegate();
end

function ShopV2Manager:CloseMainUI()
    if self.MainUI == nil then
        print("[ShopV2Manager:CloseMainUI] MainUI is nil!");
        return;
    end
    local cm = self:GetCommodityOperationManager()
    local vm = self:GetVirtualItemManager()
    if cm then
        cm.LimitProductUpdateDelegate:Remove(self.RefreshProducts, self);
    end
    if vm then
        vm.AddItemResultDelegate:Remove(self.OnAddVirtualItem, self);
        vm.OnItemNumUpdatedDelegate:Remove(self.OnItemNumUpdate, self);
    end
    self.MainUI:SetVisibility(ESlateVisibility.Collapsed);
end

function ShopV2Manager:OpenPurchaseUI(ProductID)
    self.MainUI:ShowPurchasePanel(ProductID);
end

function ShopV2Manager:RefreshProducts()
    if self.MainUI == nil or self.MainUI:GetIsVisible() == false then return; end
    self.MainUI.ShopGoods:RefreshCurrentList(false);
end

function ShopV2Manager:RefreshProductDetail()
    if self.MainUI == nil or self.MainUI:GetIsVisible() == false then return; end
    self.MainUI.ShopGoods:RefreshCurrentProductDetailPanel();
end

function ShopV2Manager:ResetSelectedProductID()
    if self.MainUI == nil or self.MainUI:GetIsVisible() == false then return; end
    self.MainUI.ShopGoods.LastSelectedProductID = 0;
    self.MainUI.ShopGoods.SelectedProductID = 0;
end

function ShopV2Manager:ShowPurchaseTip(Message)
    if self.MainUI == nil then return; end
    self.MainUI:ShowPurchaseTip(Message);
end

function ShopV2Manager:ShowItemGetPopup(ItemID, Num)
    if self.MainUI == nil then return; end
    self.MainUI:ShowItemGet(ItemID, Num);
end

function ShopV2Manager:GetProductCurrencyIconPath(ProductID)
    local cm = self:GetCommodityOperationManager()
    if not cm then return nil end
    local ProductData = cm:GetProductData(ProductID);
    if ProductData == nil then return nil end
    if ProductData.CurrencyType == ECurrencyType.OasisCoin then
        if self.MainUI == nil then return nil end
        return KismetSystemLibrary.BreakSoftObjectPath(self.MainUI.OasisIconPath);
    end
    if ProductData.CurrencyType == ECurrencyType.OtherCoin then
        local VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager");
        if VirtualItemManager == nil then return nil end
        local ItemData = VirtualItemManager:GetItemData(ProductData.CostID);
        if ItemData == nil then return nil end
        return ItemData.ItemIcon;
    end
    return nil;
end

function ShopV2Manager:OnItemNumUpdate()
    self:RefreshProducts();
    self.OnItemNumChangeDelegate();
end

function ShopV2Manager:SelectShopTab(TabID)
    self.MainUI:SelectTab(TabID);
end

function ShopV2Manager:SelectProduct(ProductID)
    self.MainUI:SelectProduct(ProductID);
end

function ShopV2Manager:GetRemainingDays(EndTime)
    local RemainingSec = EndTime - UGCGameSystem.GetServerTimeSec();
    return RemainingSec > 0 and math.floor(RemainingSec/3600/24) or 0;
end

function ShopV2Manager:GetDiscountPrice(ProductID)
    return UGCCommoditySystem.GetSellingPriceAfterDiscount(ProductID);
end

function ShopV2Manager:IsProductValid(ProductID)
    local cm = self:GetCommodityOperationManager()
    if not cm then return false end
    local ProductData = cm:GetProductData(ProductID);
    if ProductData == nil then return false; end
    if ProductData.AvailableForSale == EAvailableForSale.NotForSale then return false; end
    if ProductData.StoreID == EStoreId.Lobby then return false; end
    local CurrentTime = UGCGameSystem.GetServerTimeSec();
    local ListingTime = ProductData.ListingTime;
    return CurrentTime >= ListingTime;
end

function ShopV2Manager:IsPermanentDiscount(EndTime)
    local Date = os.date("*t", EndTime);
    return Date.year >= 3000;
end

function ShopV2Manager:BuyProduct(ProductID, Num, CurrentPrice)
    -- 礼包联动锁定：已购买更高级礼包则拦截购买
    if self:IsGiftBlockedByHigherLevel(ProductID) then
        return
    end
    local cm = self:GetCommodityOperationManager()
    if cm then cm:BuyProduct(ProductID, CurrentPrice, Num) end
end

function ShopV2Manager:GetOwnedVirtualItemNum(ItemId)
    if not UGCGamePartSystem or not UGCGamePartSystem.VirtualItemManager then return 0 end
    local VIM = UGCGamePartSystem.VirtualItemManager.GetGlobalActor()
    if not VIM or not VIM.GetItemNum then return 0 end
    local Ok, Num = pcall(VIM.GetItemNum, VIM, ItemId)
    return (Ok and Num) and (tonumber(Num) or 0) or 0
end

function ShopV2Manager:IsGiftBlockedByHigherLevel(ProductID)
    local ProductData = self:GetProductConfigData(ProductID)
    if not ProductData then return false end
    local ItemID = tonumber(ProductData.ItemID) or 0
    if ItemID == 1002 then
        return self:GetOwnedVirtualItemNum(1003) > 0 or self:GetOwnedVirtualItemNum(1004) > 0
    elseif ItemID == 1003 then
        return self:GetOwnedVirtualItemNum(1004) > 0
    end
    return false
end

function ShopV2Manager:GetProductIDsInTab(TabID, bRefresh)
    if self.ProductIDGroupByTabID == nil or bRefresh == true then
        self:GroupProductIDByTabID();
    end
    if self.ProductIDGroupByTabID[tostring(TabID)] == nil then
        return {};
    end
    return self.ProductIDGroupByTabID[tostring(TabID)];
end

function ShopV2Manager:GroupProductIDByTabID()
    self.ProductIDGroupByTabID = {};
    local cm = self:GetCommodityOperationManager()
    if not cm then return end
    local ProductDatas = cm:GetAllProductData();
    for ProductID, ProductData in pairs(ProductDatas) do
        local TabID = tostring(ProductData.TabID);
        self.ProductIDGroupByTabID[TabID] = self.ProductIDGroupByTabID[TabID] or {};
        if self:IsProductValid(ProductData.ProductID) == true then
            table.insert(self.ProductIDGroupByTabID[TabID], ProductID);
        end
    end
    local function Compare(ProductIDA, ProductIDB)
        local cm2 = ShopV2Manager:GetCommodityOperationManager()
        if not cm2 then return ProductIDA < ProductIDB end
        local ProductDataA = cm2:GetProductData(ProductIDA);
        local ProductDataB = cm2:GetProductData(ProductIDB);
        if ProductDataA.SortPriority ~= ProductDataB.SortPriority then
            return ProductDataA.SortPriority < ProductDataB.SortPriority;
        end
        return ProductDataA.ProductID < ProductDataB.ProductID;
    end
    for _, Tab in pairs(self.ProductIDGroupByTabID) do
        table.sort(Tab, Compare);
    end
end

function ShopV2Manager:OnAddVirtualItem(Result)
    if Result.bSucceeded == false then return; end
    for ItemID, Num in pairs(Result.ItemList) do
        self:ShowItemGetPopup(ItemID, Num);
        break;
    end
    self:RefreshProducts();
    self:RefreshProductDetail();
end

function ShopV2Manager:OnBuyProductResult(Result)
    self.bBlockRepeatPurchase = false;
    self:RefreshProducts();
    self:RefreshProductDetail();
end
