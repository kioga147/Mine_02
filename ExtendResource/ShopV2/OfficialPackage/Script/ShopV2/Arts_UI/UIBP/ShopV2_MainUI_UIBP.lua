---@class ShopV2_MainUI_UIBP_C:UUserWidget
---@field CloseButton UButton
---@field CurrencyBar UHorizontalBox
---@field HelpButton UButton
---@field ShopCurrency_1 UShopV2_Currency_UIBP_C
---@field ShopGoods UShopV2_Goods_UIBP_C
---@field ShopTabMenu UUGC_ReuseList2_C
---@field TitleIcon UImage
---@field TitleText UTextBlock
---@field Tabs TArray<FShopV2_TabInfo__pf3882563479>
---@field bShowOasisCoin bool
---@field SelectedTabID int32
---@field PurchasePanelPath FSoftClassPath
---@field ItemGetUIPath FSoftClassPath
---@field PurchaseTipUIPath FSoftClassPath
---@field RuleDescPanelPath FSoftClassPath
---@field OasisIconPath FSoftObjectPath
--Edit Below--
local ShopV2_MainUI_UIBP = 
{ 
    bInitDoOnce = false;
    bCurrencyBarInited = false;
    
    TabInfos = {};
    TabButtons = {};

    NextCheckRefreshTime = 0;
}

function ShopV2_MainUI_UIBP:Construct()

    self:InitCurrencyBar();
    self:BindEvent();

    self:PreLoadUI();

    ShopV2Manager:RegisterMainUI(self);
end

function ShopV2_MainUI_UIBP:Destruct()
    
    ShopV2Manager:UnregisterMainUI();
end

function ShopV2_MainUI_UIBP:BindEvent()
    
    self.ShopTabMenu.OnUpdateItem:Add(self.RefreshTabMenuButton, self);
    self.CloseButton.OnClicked:Add(self.OnCloseButtonClick, self);
    self.HelpButton.OnClicked:Add(self.OnHelpButtonClick, self);
end

function ShopV2_MainUI_UIBP:PreLoadUI()
    
    Common.LoadObjectWithSoftPathAsync(self.PurchasePanelPath, 
        function (Object)
            if self ~= nil and Object ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
                self.PurchasePanel = UserWidget.NewWidgetObjectBP(PlayerController, Object);
                self.PurchasePanel:AddToViewport(15000);
                self.PurchasePanel:SetVisibility(ESlateVisibility.Collapsed);
            end
        end
    );

    Common.LoadObjectWithSoftPathAsync(self.ItemGetUIPath, 
        function (Object)
            if self ~= nil and Object ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
                self.ItemGetUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
                self.ItemGetUI:AddToViewport(20000);
                self.ItemGetUI:SetVisibility(ESlateVisibility.Collapsed);
            end
        end
    );

    Common.LoadObjectWithSoftPathAsync(self.PurchaseTipUIPath, 
        function (Object)
            if self ~= nil and Object ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
                self.PurchaseTipUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
                self.PurchaseTipUI:AddToViewport(20000);
                self.PurchaseTipUI:SetVisibility(ESlateVisibility.Collapsed);
            end
        end
    );

    Common.LoadObjectWithSoftPathAsync(self.RuleDescPanelPath, 
        function (Object)
            if self ~= nil and Object ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
                self.RuleDescUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
                self.RuleDescUI:AddToViewport(18000);
                self.RuleDescUI:SetVisibility(ESlateVisibility.Collapsed);
            end
        end  
    );
end

function ShopV2_MainUI_UIBP:RefreshTabs()
    
    local bHasSelectedTabID = false;
    self.TabInfos = {};

    for i, Tab in ipairs(self.Tabs) do
        local TabInfo = {};
        TabInfo.TabID       = Tab.TabID;
        TabInfo.TabName     = Tab.TabName;
        TabInfo.TabShopName = Tab.TabShopName;
        TabInfo.TabShopDesc = Tab.TabShopDesc;
        table.insert(self.TabInfos, TabInfo);

        if TabInfo.TabID == self.SelectedTabID then
            bHasSelectedTabID = true;
        end
    end

    if bHasSelectedTabID == false then
        self.SelectedTabID = self.TabInfos[1].TabID;
    end

    self.ShopTabMenu:Reload(#self.TabInfos);
end

function ShopV2_MainUI_UIBP:InitCurrencyBar()
    print("ShopV2_MainUI_UIBP:InitCurrencyBar")

    if self.bShowOasisCoin == true then
        UGCCommoditySystem.ShowRechargeEntryUI():Then(
            function (Result)
                local UI = Result:Get();

                if UI ~= nil then
                    UI:RemoveFromParent();
                    UI:SetVisibility(ESlateVisibility.Visible);
                    self.CurrencyBar:AddChild(UI);
                    self.bCurrencyBarInited = true;
                else
                    print("ShopV2_MainUI_UIBP:InitCurrencyBar RechargeUI is nil")
                end
            end
        );
    end    
end

function ShopV2_MainUI_UIBP:ShowPurchasePanel(ProductID)
    
    self.PurchasePanel:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    self.PurchasePanel:Refresh(ProductID);
end

function ShopV2_MainUI_UIBP:ShowPurchaseTip(Message)

    self.PurchaseTipUI:SetVisibility(ESlateVisibility.HitTestInvisible);
    self.PurchaseTipUI:ShowMessageTip(Message);
end

function ShopV2_MainUI_UIBP:ShowItemGet(ItemID, Num)

    self.ItemGetUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    self.ItemGetUI:Popup(ItemID, Num);
end

function ShopV2_MainUI_UIBP:SetupShopTabInfo(TabInfo)
   
    self.HelpButton:SetVisibility(TabInfo.TabShopDesc ~= "" and ESlateVisibility.Visible or ESlateVisibility.Collapsed);
    self.RuleDescUI.Desc = TabInfo.TabShopDesc;
    self.TitleText:SetText(TabInfo.TabShopName);
end

function ShopV2_MainUI_UIBP:RefreshTabMenuButton(TabButton, Idx)
    
    TabButton:SetupTabInfo(self.TabInfos[Idx+1]);

    if TabButton.TabID == self.SelectedTabID then
        TabButton:Select();
        self:SetupShopTabInfo(self.TabInfos[Idx+1]);
        self.ShopGoods:RefreshProductList(self.SelectedTabID, false);
    else
        TabButton:Deselect(self.TabInfos[Idx+1].Tab);
    end

    self.TabButtons[TabButton.TabID] = TabButton;
end

function ShopV2_MainUI_UIBP:SelectTab(TabID)
    
    if TabID == self.SelectedTabID then
        return;
    end

    self.TabButtons[TabID]:Select();
    self.TabButtons[self.SelectedTabID]:Deselect();
    self.SelectedTabID = TabID;

    self:SetupShopTabInfo(self.TabButtons[TabID].TabInfo);

    self.ShopGoods:RefreshProductList(TabID, false);
end

function ShopV2_MainUI_UIBP:SelectProduct(ProductID)

    self.ShopGoods:SelectProduct(ProductID);
end

function ShopV2_MainUI_UIBP:OnCloseButtonClick()

    ShopV2Manager:CloseMainUI();
    
    if self.CheckRefreshTimer ~= nil then
        Timer.RemoveTimer(self.CheckRefreshTimer);
        self.CheckRefreshTimer = nil; 
    end
end

function ShopV2_MainUI_UIBP:OnHelpButtonClick()
    
    self.RuleDescUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    self.RuleDescUI:Refresh();
end

function ShopV2_MainUI_UIBP:CheckRefreshTime()
    
    print("[ShopV2_MainUI_UIBP:CheckRefreshTime] Start check time");

    --每小时刷新上下架状态
    local CurrentTime = Common.GetCurrentTime();
    if CurrentTime >= self.NextCheckRefreshTime then
        self.ShopGoods:RefreshCurrentList(true);

        local CurrentDate = Common.GetCurrentDate();
        local NextCheckRefreshTime = os.time({year=CurrentDate.year, month=CurrentDate.month, day=CurrentDate.day, hour=CurrentDate.hour});
        self.NextCheckRefreshTime = NextCheckRefreshTime + 60 * 60 + 1;
    end

    self.CheckRefreshTimer = Timer.InsertTimer(1,
        function ()
            if self ~= nil then
                self:CheckRefreshTime();
            end
        end
    );
end

function ShopV2_MainUI_UIBP:RefreshCountDown(Time)

    if self.CountDown:GetVisibility() == ESlateVisibility.Collapsed then
        return;
    end

    local Day = math.floor(Time/86400);
    Time = Time % 86400;

    local Hour = math.floor(Time/3600);
    Time = Time % 3600;

    local Min = math.floor(Time/60);
    local Sec = Time % 60;

    local Text = "";
    if Day > 0 then
        Text = string.format("%d天%d小时", Day, Hour);
    elseif Hour > 0 then
        Text = string.format("%d小时%d分钟", Hour, Min);
    else
        Text = string.format("%d分钟%d秒", Min, Sec);
    end

    self.CountDownText:SetText(Text);
end

return ShopV2_MainUI_UIBP;