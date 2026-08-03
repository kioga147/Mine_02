---@class ShopV2_ItemGet_UIBP_C:UUserWidget
---@field DX_Parachute UWidgetAnimation
---@field DX_GXHD UWidgetAnimation
---@field ConfirmButton UNewButton
---@field ItemList UUGC_ReuseList2_C
--Edit Below--

local ShopV2_ItemGet_UIBP = { bInitDoOnce = false } 

function ShopV2_ItemGet_UIBP:Construct()
    
    self.ItemList.OnUpdateItem:Add(self.OnUpdateItem, self);
    self.ConfirmButton.OnClicked:Add(self.OnConfirmClick, self);

    Common.LoadObjectAsync("/Game/WwiseEvent/UI_hall/Play_UI_hall_Shopping_Get.Play_UI_hall_Shopping_Get", 
        function (Object)
            if Object ~= nil and self ~= nil then
                self.Sound = Object;
            end
        end
    )
end

function ShopV2_ItemGet_UIBP:OnConfirmClick()
    
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function ShopV2_ItemGet_UIBP:Popup(ItemID, Num)

    self.Num = Num or 1;

    self.ItemData = ShopV2Manager:GetItemConfigData(ItemID);
    self.ItemList:Reload(1);

    if CheckObjectContainsField(self, "DX_GXHD") then
        self:PlayAnimation(self.DX_GXHD, 0, 1, EUMGSequencePlayMode.Forward, 1);
    end

    if self.Sound ~= nil then
        UGCSoundManagerSystem.PlaySound2D(self.Sound);
    end
end

function ShopV2_ItemGet_UIBP:OnUpdateItem(Item, Idx)
    
    Common.LoadObjectAsync(self.ItemData.ItemIcon, 
        function (IconTexture)
            if self ~= nil and UE.IsValid(self) then
                Item.ItemIcon:SetBrushFromTexture(IconTexture);
                Item.ItemNameText:SetText(self.ItemData.ItemName);
                Item.NumText:SetText(tostring(self.Num));
            end
        end
    )

    Common.LoadObjectAsync(ShopV2Manager:GetQualityTexturePath(self.ItemData.ItemID, false), 
        function (IconTexture)
            if self ~= nil and UE.IsValid(self) then
                Item.QualityBackground:SetBrushFromTexture(IconTexture);
            end
        end
    );

    Common.LoadObjectAsync(ShopV2Manager:GetQualityBarTexturePath(self.ItemData.ItemID), 
        function (IconTexture)
            if self ~= nil and UE.IsValid(self) then
                Item.QualityBar:SetBrushFromTexture(IconTexture);
            end
        end
    );
end

function ShopV2_ItemGet_UIBP:OnAnimationFinished(Animation)
    
    if CheckObjectContainsField(self, "DX_GXHD") then
        self:PlayAnimation(self.DX_Parachute, 0, 0, EUMGSequencePlayMode.Forward, 1);
    end
end

return ShopV2_ItemGet_UIBP