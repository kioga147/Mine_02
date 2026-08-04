---@class ShopV2_BuyMessageTips_UIBP_C:UUserWidget
---@field DX_In UWidgetAnimation
---@field TipsText UTextBlock
--Edit Below--
local ShopV2_BuyMessageTips_UIBP = { bInitDoOnce = false } 

function ShopV2_BuyMessageTips_UIBP:Construct()
	
end

function ShopV2_BuyMessageTips_UIBP:ShowMessageTip(Text)
    
    self.TipsText:SetText(Text);    

    -- 播放动画
    if CheckObjectContainsField(self, "DX_In") then
        self:PlayAnimation(self.DX_In, 0, 1, EUMGSequencePlayMode.Forward, 1);
    end
end

return ShopV2_BuyMessageTips_UIBP