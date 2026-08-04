---@class ShopV2_OpenShopButton_UIBP_C:UUserWidget
---@field ItemNumButton UButton
---@field OpenButton UButton
---@field TextBox UEditableTextBox
--Edit Below--

UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage." .. "Script.ShopV2.ShopV2Manager")

---@type ESlateVisibility
ESlateVisibility = ESlateVisibility == nil and nil or ESlateVisibility

local ShopV2_OpenShopButton_UIBP = { bInitDoOnce = false; }; 

function ShopV2_OpenShopButton_UIBP:Construct()

    self.OpenButton.OnClicked:Add(self.OnOpenButtonClicked, self);
    self.ItemNumButton.OnClicked:Add(self.OnItemNumButtonClicked, self);
end

function ShopV2_OpenShopButton_UIBP:OnOpenButtonClicked()
    
    ShopV2Manager:OpenMainUI();
end

function ShopV2_OpenShopButton_UIBP:OnItemNumButtonClicked()
    
    if self.TextBox.Text == nil or self.TextBox.Text == "" then
        return;
    end

    local ItemID = tonumber(self.TextBox.Text);

    if ItemID ~= nil then
        local Num = ShopV2Manager:GetVirtualItemManager():GetItemNum(ItemID);
        self.TextBox:SetText(string.format("%d %d", ItemID, Num));
    end
end

return ShopV2_OpenShopButton_UIBP;