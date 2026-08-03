---@class GiftPack_ApplyProp_Popup_UIBP_C:UUserWidget
---@field Btn_Increase UButton
---@field Btn_Increase10 UButton
---@field Btn_Increase100 UButton
---@field Btn_Reduce UButton
---@field BtnClose UButton
---@field Button_Buy UButton
---@field Common_UIPopupBG UCommon_UIPopupBG_C
---@field GiftPack_PopupsBG_UIBP UGiftPack_PopupsBG_UIBP_C
---@field HorizontalBox_Purchase_Limit UHorizontalBox
---@field HorizontalBox_Won UHorizontalBox
---@field Image_4 UImage
---@field Image_BgQuality UImage
---@field Image_EffectExpression UImage
---@field Image_Icon UImage
---@field Image_Quality UImage
---@field IsOwned UTextBlock
---@field Name1 UTextBlock
---@field NumberInput UHorizontalBox
---@field Text_ok UTextBlock
---@field TextBlock_Count UTextBlock
---@field TextBlock_Describe UTextBlock
---@field TextBlock_Purchase_Limit UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_Increase UWidgetSwitcher
---@field WidgetSwitcher_Reduce UWidgetSwitcher
--Edit Below--
local GiftPack_ApplyProp_Popup_UIBP = { bInitDoOnce = false } 

UGCGameSystem.UGCRequire("ExtendResource.GiftPack.OfficialPackage." .. "Script.GiftPack.GiftPackManager");

function GiftPack_ApplyProp_Popup_UIBP:Construct()
	self.BtnClose.OnClicked:Add(self.Close, self);
    self.Btn_Increase10.OnClicked:Add(self.Min, self);
    self.Btn_Reduce.OnClicked:Add(self.Reduce, self);
    self.Btn_Increase.OnClicked:Add(self.Increse, self);
    self.Btn_Increase100.OnClicked:Add(self.Max, self);
    self.Button_Buy.OnClicked:Add(self.UseGiftPack, self);
end

function GiftPack_ApplyProp_Popup_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function GiftPack_ApplyProp_Popup_UIBP:Min()
    self:ChangeNum(1);
end

function GiftPack_ApplyProp_Popup_UIBP:Reduce()
    if self.CurNum > 1 then
        self:ChangeNum(self.CurNum - 1);
    end
end

function GiftPack_ApplyProp_Popup_UIBP:Increse()
    if self.CurNum < self.MaxNum then
        self:ChangeNum(self.CurNum + 1);
    end
end

function GiftPack_ApplyProp_Popup_UIBP:Max()
    self:ChangeNum(self.MaxNum);
end

function GiftPack_ApplyProp_Popup_UIBP:ChangeNum(Num)
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

function GiftPack_ApplyProp_Popup_UIBP:UseGiftPack()
    print(string.format("GiftPack_ApplyProp_Popup_UIBP:UseGiftPack GiftPackID: %d CurNum: %d", self.GiftPackID, self.CurNum));
    local GiftPackData = GiftPackManager:GetGiftPackDataByID(self.GiftPackID);
    if GiftPackData.GiftPackType == EGiftPackType.Normal then
        -- 常规礼包
        GiftPackManager:AutoUseGiftPack(self.GiftPackID, self.CurNum);
    else
        -- 自选礼包
        if self.CurNum == 1 then
            GiftPackManager:OpenGiftPackSinglePopupUI(self.GiftPackID);
        elseif self.CurNum > 1 then
            GiftPackManager:OpenGiftPackComplexPopupUI(self.GiftPackID, self.CurNum);
        end
    end
end

-- function GiftPack_ApplyProp_Popup_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function GiftPack_ApplyProp_Popup_UIBP:Destruct()

-- end

function GiftPack_ApplyProp_Popup_UIBP:InitUI(GiftPackID)
    print("GiftPack_ApplyProp_Popup_UIBP:InitUI");
    self.GiftPackID = GiftPackID;
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
            local hasIllegalChar, unitLen, Name, isTruncate = FuncUtil:CheckName(ItemInfo.ItemName, true, 7, 1);
            self.Name1:SetText(Name);
        end

        if ItemInfo.ItemDesc then
            self.TextBlock_Describe:SetText(ItemInfo.ItemDesc); 
        end

        local GiftPackData = GiftPackManager:GetGiftPackDataByID(GiftPackID);
        local ItemNum = 999;
        if GiftPackData then
            local ItemID = GiftPackData.ItemID; 
            ItemNum = GiftPackManager:GetItemNum(ItemID);
        end
        self.CurNum = 0;
        self.MaxNum = ItemNum;
        self.IsOwned:SetText(tostring(ItemNum));
        self:ChangeNum(1);

        local Title = self.Title:GetText();
        local hasIllegalChar, unitLen, retStr, isTruncate = FuncUtil:CheckName(Title, true, 14, 1);
        self.Title:SetText(retStr);
    end
end

return GiftPack_ApplyProp_Popup_UIBP
