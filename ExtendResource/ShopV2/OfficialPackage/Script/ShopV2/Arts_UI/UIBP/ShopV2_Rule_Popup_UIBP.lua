---@class ShopV2_Rule_Popup_UIBP_C:UUserWidget
---@field CloseButton UButton
---@field ContentText UUTRichTextBlock
---@field ShopV2_PopupsBG_UIBP UShopV2_PopupsBG_UIBP_C
--Edit Below--
local ShopV2_Rule_Popup_UIBP = 
{ 
    bInitDoOnce = false,
    Desc = "";
} 

function ShopV2_Rule_Popup_UIBP:Construct()
    
    self.CloseButton.OnClicked:Add(self.CloseClick, self);
end

function ShopV2_Rule_Popup_UIBP:CloseClick()
    
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function ShopV2_Rule_Popup_UIBP:Refresh()
    
    self.ContentText:SetText(self.Desc);
end

return ShopV2_Rule_Popup_UIBP