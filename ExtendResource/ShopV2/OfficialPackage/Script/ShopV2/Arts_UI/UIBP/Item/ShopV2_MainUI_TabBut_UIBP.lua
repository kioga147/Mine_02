---@class ShopV2_MainUI_TabBut_UIBP_C:UUserWidget
---@field RedPoint UImage
---@field SelectHighlight UImage
---@field TabButton UButton
---@field TabNameText UTextBlock
--Edit Below--
local ShopV2_MainUI_TabBut_UIBP = 
{ 
    bInitDoOnce = false;
    TabInfo = nil;
}; 

function ShopV2_MainUI_TabBut_UIBP:Construct()
	
    self.TabButton.OnClicked:Add(self.OnButtonClicked, self);
end

function ShopV2_MainUI_TabBut_UIBP:SetTabName(TabName)
    
    self.TabNameText:SetText(TabName);
end

function ShopV2_MainUI_TabBut_UIBP:SetupTabInfo(TabInfo)
    
    self.TabInfo = TabInfo;
    self.TabID = TabInfo.TabID;
    self.TabNameText:SetText(TabInfo.TabName);
end

function ShopV2_MainUI_TabBut_UIBP:Select()

    self.SelectHighlight:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function ShopV2_MainUI_TabBut_UIBP:Deselect()

    self.SelectHighlight:SetVisibility(ESlateVisibility.Collapsed);
end

function ShopV2_MainUI_TabBut_UIBP:OnButtonClicked()

    ShopV2Manager:SelectShopTab(self.TabID);
end

return ShopV2_MainUI_TabBut_UIBP;