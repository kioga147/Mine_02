---@class GiftPack_Complex_Item_UIBP_C:UUserWidget
---@field Btn_Increase UButton
---@field Btn_Reduce UButton
---@field Button_Confirm UButton
---@field Image_Icon UImage
---@field Image_Quality UImage
---@field Image_Select UImage
---@field NumberInput UHorizontalBox
---@field TextBlock_Count UTextBlock
---@field TextBlock_Name UTextBlock
---@field TextBlock_Quantity UTextBlock
---@field WidgetSwitcher_Increase UWidgetSwitcher
---@field WidgetSwitcher_Reduce UWidgetSwitcher
--Edit Below--
local GiftPack_Complex_Item_UIBP = { bInitDoOnce = false } 

function GiftPack_Complex_Item_UIBP:Construct()
	self.Btn_Increase.OnClicked:Add(self.IncreaseItem, self);
	self.Btn_Reduce.OnClicked:Add(self.ReduceItem, self);
    self.Button_Confirm.OnPressed:Add(self.OnPress, self);
    self.Button_Confirm.OnReleased:Add(self.OnRelease, self);
end

-- function GiftPack_Complex_Item_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function GiftPack_Complex_Item_UIBP:Destruct()

-- end

function GiftPack_Complex_Item_UIBP:IncreaseItem()
    -- 要先获取当前还能选择多少道具
    self.CanSelectNum = GiftPackManager:GetComplexSelectNum();
    print(string.format("GiftPack_Complex_Item_UIBP:IncreaseItem CanSelectNum: %d", self.CanSelectNum));
    if self.CanSelectNum > 0 then
        self:ChangeNum(self.CurNum + 1);
        GiftPackManager:IncreaseItem(self.ItemID);
    end
end

function GiftPack_Complex_Item_UIBP:ReduceItem()
    if self.CurNum > 0 then
        self:ChangeNum(self.CurNum - 1);
        GiftPackManager:ReduceItem(self.ItemID);
    end
end

function GiftPack_Complex_Item_UIBP:OnPress()
    print("GiftPack_Complex_Item_UIBP:OnPress");
    self.PressTimerHandle = Timer.InsertTimer(
        0, 
        function ()
            print("GiftPack_Complex_Item_UIBP: LongPress");
            local AbsPosition = SlateBlueprintLibrary.GetAbsolutePosition(self:GetCachedGeometry());
            local Position = SlateBlueprintLibrary.AbsoluteToLocal(WidgetLayoutLibrary.GetViewportWidgetGeometry(self), AbsPosition);
            GiftPackManager:ShowItemTip(self.ItemID, Position);
        end,
        false,
        "ShowTipPressTimer",
        0.5
    );
end

function GiftPack_Complex_Item_UIBP:OnRelease()
    if self.PressTimerHandle ~= nil then
        Timer.RemoveTimer(self.PressTimerHandle);
        self.PressTimerHandle = nil; 
    end
end

-- function GiftPack_Complex_Item_UIBP:Select()
--     -- 通知父界面刷新
--     self.Image_Select:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
-- end

-- function GiftPack_Complex_Item_UIBP:UnSelect()
--     self.Image_Select:SetVisibility(ESlateVisibility.Collapsed);
-- end

function GiftPack_Complex_Item_UIBP:GetSelect()
end

function GiftPack_Complex_Item_UIBP:ForbiddenIncrease()
    print("GiftPack_Complex_Item_UIBP:ForbiddenIncrease");
    self.WidgetSwitcher_Increase:SetActiveWidgetIndex(1);
end

function GiftPack_Complex_Item_UIBP:AllowIncrease()
    print("GiftPack_Complex_Item_UIBP:AllowIncrease");
    self.WidgetSwitcher_Increase:SetActiveWidgetIndex(0);
end

function GiftPack_Complex_Item_UIBP:ChangeNum(Num)
    self.CurNum = Num;
    self.TextBlock_Count:SetText(string.format("%d/%d", self.CurNum, self.MaxNum));

    if self.CurNum <= 0 then
        self.WidgetSwitcher_Reduce:SetActiveWidgetIndex(1);
    else
        self.WidgetSwitcher_Reduce:SetActiveWidgetIndex(0);
    end

    if self.CurNum >= self.CanSelectNum then
        self.WidgetSwitcher_Increase:SetActiveWidgetIndex(1);
    else
        self.WidgetSwitcher_Increase:SetActiveWidgetIndex(0);
    end
end

function GiftPack_Complex_Item_UIBP:GetCurNum()
    print(string.format("CurNum: %d", self.CurNum));
    return self.CurNum;
end

function GiftPack_Complex_Item_UIBP:InitUI(ItemID, ItemMinNum, ItemMaxNum, GiftPackNum, CanSelectNum, SelectedNum)
    print(string.format("GiftPack_Complex_Item_UIBP:InitUI ItemID: %d CanSelectedNum: %d SelectedNum: %d", ItemID, CanSelectNum, SelectedNum))
    self.CurNum = SelectedNum;
    self.MaxNum = GiftPackNum;
    self.CanSelectNum = CanSelectNum;
    self.ItemID = ItemID;
    local ItemInfo = GiftPackManager:GetItemInfoByItemID(ItemID);
    if ItemInfo then
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
            self.TextBlock_Name:SetText(ItemInfo.ItemName);
        end

        if ItemMaxNum == ItemMinNum then
            self.TextBlock_Quantity:SetText(string.format("%d", ItemMinNum));
        else
            self.TextBlock_Quantity:SetText(string.format("%d~%d", ItemMinNum, ItemMaxNum));
        end
    end

    self:ChangeNum(self.CurNum);
end

return GiftPack_Complex_Item_UIBP