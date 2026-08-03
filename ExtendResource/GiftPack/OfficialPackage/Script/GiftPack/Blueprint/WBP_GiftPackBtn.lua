---@class WBP_GiftPackBtn_C:UserWidgetUI
---@field ApplyGiftPackBtn UButton
---@field GiftPackInput USpinBox
--Edit Below--
local WBP_GiftPackBtn = { bInitDoOnce = false } 

function WBP_GiftPackBtn:Construct()
    self.ApplyGiftPackBtn.OnClicked:Add(self.ApplyGiftPack, self);
end

function WBP_GiftPackBtn:ApplyGiftPack()
    print("WBP_GiftPackBtn:ApplyGiftPack");
    local GiftPackID = math.modf(self.GiftPackInput:GetValue());
    GiftPackManager:OpenGiftPack(GiftPackID);
end

-- function WBP_GiftPackBtn:Tick(MyGeometry, InDeltaTime)

-- end

-- function WBP_GiftPackBtn:Destruct()

-- end

return WBP_GiftPackBtn