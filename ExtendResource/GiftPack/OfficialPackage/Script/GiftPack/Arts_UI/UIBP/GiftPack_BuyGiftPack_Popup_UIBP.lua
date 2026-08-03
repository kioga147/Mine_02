---@class GiftPack_BuyGiftPack_Popup_UIBP_C:UUserWidget
---@field Btn_Increase UButton
---@field Btn_Increase10 UButton
---@field Btn_Increase100 UButton
---@field Btn_Reduce UButton
---@field BtnClose UButton
---@field Button_Buy UButton
---@field Common_UIPopupBG UCommon_UIPopupBG_C
---@field GiftPack_PopupsBG_UIBP UGiftPack_PopupsBG_UIBP_C
---@field Image_BgQuality UImage
---@field Image_EffectExpression UImage
---@field Image_Icon UImage
---@field Image_Quality UImage
---@field IsOwned UTextBlock
---@field Money_Type_Img1 UImage
---@field Name1 UTextBlock
---@field NumberInput UHorizontalBox
---@field Price2 UTextBlock
---@field Text UTextBlock
---@field TextBlock_Count UTextBlock
---@field TextBlock_Describe UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_Increase UWidgetSwitcher
---@field WidgetSwitcher_Reduce UWidgetSwitcher
--Edit Below--
local GiftPack_BuyGiftPack_Popup_UIBP = { bInitDoOnce = false } 

function GiftPack_BuyGiftPack_Popup_UIBP:Construct()
    self.BtnClose.OnClicked:Add(self.Close, self);
    self.Btn_Reduce.OnClicked:Add(self.Reduce, self);
    self.Btn_Increase.OnClicked:Add(self.Increse, self);
    self.Btn_Increase10.OnClicked:Add(self.IncreseTen, self);
    self.Btn_Increase100.OnClicked:Add(self.IncreseHundred, self);

    self.CurNum = 0;
    self.MaxNum = 999;
end

function GiftPack_BuyGiftPack_Popup_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function GiftPack_BuyGiftPack_Popup_UIBP:Reduce()
    if self.CurNum > 1 then
        self:ChangeNum(self.CurNum - 1);
    end
end

function GiftPack_BuyGiftPack_Popup_UIBP:Increse()
    if self.CurNum < self.MaxNum then
        self:ChangeNum(self.CurNum + 1);
    end
end

function GiftPack_BuyGiftPack_Popup_UIBP:IncreseTen()
    local Num = self.CurNum + 10;
    if self.CurNum + 10 > self.MaxNum then
        Num = self.MaxNum;
    end

    self:ChangeNum(Num);
end

function GiftPack_BuyGiftPack_Popup_UIBP:IncreseHundred()
    local Num = self.CurNum + 100;
    if self.CurNum + 100 > self.MaxNum then
        Num = self.MaxNum;
    end
    
    self:ChangeNum(Num);
end

function GiftPack_BuyGiftPack_Popup_UIBP:ChangeNum(Num)
    self.CurNum = Num;
    self.TextBlock_Count:SetText(string.format("%d/%d", self.CurNum, self.MaxNum));

    if self.CurNum <= 1 then
        self.WidgetSwitcher_Reduce:SetActiveWidgetIndex(1);
    else
        self.WidgetSwitcher_Reduce:SetActiveWidgetIndex(0);
    end

    if self.CurNum >= self.MaxNum then
        self.WidgetSwitcher_Increase:SetActiveWidgetIndex(1);
    else
        self.WidgetSwitcher_Increase:SetActiveWidgetIndex(0);
    end
end

-- function GiftPack_BuyGiftPack_Popup_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function GiftPack_BuyGiftPack_Popup_UIBP:Destruct()

-- end

function GiftPack_BuyGiftPack_Popup_UIBP:InitUI(GiftPackID)
    local ItemID = GiftPackManager:GetGiftPackDataByID(GiftPackID).ItemID;
    if ItemID then
        local ItemInfo = GiftPackManager:GetItemInfoByItemID(ItemID);
        if ItemInfo.ItemIcon then
            Common.LoadObjectAsync(ItemInfo.ItemIcon, 
            function (Object)
                if self ~= nil and Object ~= nil then
                    self.Image_Icon:SetBrushFromTexture(Object);
                end
            end)
        end

        if ItemInfo.ItemName then
            -- 字数限制为7个
            self.Name1:SetText(ItemInfo.ItemName);
        end

        if ItemInfo.ItemDesc then
            self.TextBlock_Describe:SetText(ItemInfo.ItemDesc); 
        end

        local ItemNum = 0
        self.IsOwned:SetText(string.format("已拥有:%d", tostring(ItemNum)));
    end
end

return GiftPack_BuyGiftPack_Popup_UIBP