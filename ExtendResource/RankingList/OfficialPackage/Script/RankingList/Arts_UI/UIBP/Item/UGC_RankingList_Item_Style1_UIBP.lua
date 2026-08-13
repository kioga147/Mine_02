---@class UGC_RankingList_Item_Style1_UIBP_C:UUserWidget
---@field Button_Item UButton
---@field Canvas_Root UCanvasPanel
---@field Down UImage
---@field FX_Light UCanvasPanel
---@field Image_Bg_Default UImage
---@field Image_Bg_Quality UImage
---@field Image_Icon UImage
---@field Image_Icon_Quality UImage
---@field Left UImage
---@field Right UImage
---@field Up UImage
--Edit Below--
local UGC_RankingList_Item_Style1_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_Item_Style1_UIBP:Construct()
	self.Button_Item.OnClicked:Add(self.ItemClick, self);
end

function UGC_RankingList_Item_Style1_UIBP:ItemClick()
    print("UGC_RankingList_Item_Style1_UIBP:ItemClick");
    local State = RankingListManager:CanClaimRankListAward(self.RankID);
    if self.IsSelf then
        if State == UGCRankingListAwardState.CanSign then
            print("UGC_RankingList_Item_Style1_UIBP:ItemClick 领取奖励");
            ---领取奖励
            RankingListManager:ReceiveRankListAward(self.RankID);
        elseif State == UGCRankingListAwardState.NotAvailable then
            UGCWidgetManagerSystem.ShowTipsUI("榜单结算中，请稍后再来领取奖励~")
        end
    else
        print("UGC_RankingList_Item_Style1_UIBP:ItemClick 显示道具Tip");
        ---显示道具Tip
        local AbsPosition = SlateBlueprintLibrary.GetAbsolutePosition(self:GetCachedGeometry());
        local Position = SlateBlueprintLibrary.AbsoluteToLocal(WidgetLayoutLibrary.GetViewportWidgetGeometry(self), AbsPosition);
        RankingListManager:ShowItemTip(self.ItemID, Position);
    end
end

-- function UGC_RankingList_Item_Style1_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_Item_Style1_UIBP:Destruct()

-- end

function UGC_RankingList_Item_Style1_UIBP:InitUI(AwardInfo, IsSelf, RankID, Rank, ImageVal)
    self.ItemID = AwardInfo.ItemID;
    self.RankID = RankID;
    self.Rank = Rank;
    self.IsSelf = IsSelf;
    self.ImageVal = ImageVal;
    local ItemInfo = RankingListManager:GetItemConfigData(self.ItemID);
    if ItemInfo and ItemInfo.ItemIcon then
        Common.LoadObjectAsync(ItemInfo.ItemIcon, 
        function (Object)
            if self ~= nil and Object ~= nil then
                self.Image_Icon:SetBrushFromTexture(Object);
            end
        end)
    end
    self.TextBlock_Num:SetText(tostring(AwardInfo.ItemNum));
    if IsSelf then
        self:RefreshRedPoint();
    else
        self.WidgetSwitcher_Sate:SetActiveWidgetIndex(1);
        self.Image_Bg_Default:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function UGC_RankingList_Item_Style1_UIBP:RefreshRedPoint()
    ---是上一期且奖励未领取时才显示
    local RankListData = RankingListManager:GetRankConfigData(self.RankID);
    if RankListData then
        local State = UGCRankingListAwardState.Lock;
        if RankListData.PeriodType == ERankListPeriodType.NotReset then
            if self.ImageVal == 0 then
                State = RankingListManager:CanClaimRankListAward(self.RankID);
            else
                State = UGCRankingListAwardState.Lock;
            end
        else
            if self.ImageVal == 1 then
                State = RankingListManager:CanClaimRankListAward(self.RankID);
            else
                State = UGCRankingListAwardState.Lock;
            end
        end
        print(string.format("UGC_RankingList_Item_Style1_UIBP:RefreshRedPoint State: %s", tostring(State)))
        if State == UGCRankingListAwardState.CanSign then
            self.WidgetSwitcher_Sate:SetActiveWidgetIndex(1);
            self.Image_Bg_Default:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
        elseif State == UGCRankingListAwardState.Lock then
            self.WidgetSwitcher_Sate:SetActiveWidgetIndex(1);
            self.Image_Bg_Default:SetVisibility(ESlateVisibility.Collapsed);
        elseif State == UGCRankingListAwardState.HasGot then
            self.WidgetSwitcher_Sate:SetActiveWidgetIndex(0);
        end
    end
end

return UGC_RankingList_Item_Style1_UIBP
