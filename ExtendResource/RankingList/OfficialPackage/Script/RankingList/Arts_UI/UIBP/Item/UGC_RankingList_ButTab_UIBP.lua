---@class UGC_RankingList_ButTab_UIBP_C:UUserWidget
---@field Button_Tab UButton
---@field Image_Bg_Default UImage
---@field TextBlock_Tab UTextBlock
---@field TextBlock_TabSelect UTextBlock
---@field WidgetSwitcher_Tab UWidgetSwitcher
--Edit Below--
local UGC_RankingList_ButTab_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_ButTab_UIBP:Construct()
	self.Button_Tab.OnClicked:Add(self.TabClick, self);
end

function UGC_RankingList_ButTab_UIBP:TabClick()
    print("UGC_RankingList_ButTab_UIBP:TabClick")
    ---取消其他tab的选中态
    ---切换选中态
    RankingListManager:SelectRank(self.RankID);
    ---显示排行榜数据
end

function UGC_RankingList_ButTab_UIBP:Select()
    print("UGC_RankingList_ButTab_UIBP:Select");
    self.WidgetSwitcher_Tab:SetActiveWidgetIndex(0);
end

function UGC_RankingList_ButTab_UIBP:UnSelect()
    print("UGC_RankingList_ButTab_UIBP:UnSelect");
    self.WidgetSwitcher_Tab:SetActiveWidgetIndex(1);
end

-- function UGC_RankingList_ButTab_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_ButTab_UIBP:Destruct()

-- end

function UGC_RankingList_ButTab_UIBP:InitUI(RankID)
    self.RankID = RankID;
    print(string.format("UGC_RankingList_ButTab_UIBP:InitUI RankID: %d", RankID));
    local RankInfo = RankingListManager:GetRankConfigData(RankID);
    local hasIllegalChar, unitLen, TabName, isTruncate = FuncUtil:CheckName(RankInfo.TabName, true, 5, 1);
    self.TextBlock_Tab:SetText(TabName);
    self.TextBlock_TabSelect:SetText(TabName);
end

function UGC_RankingList_ButTab_UIBP:ShowRedPoint()
    print(string.format("UGC_RankingList_ButTab_UIBP:ShowRedPoint RankID: %d", self.RankID));
    self.Image_Bg_Default:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function UGC_RankingList_ButTab_UIBP:HideRedPoint()
    print(string.format("UGC_RankingList_ButTab_UIBP:HideRedPoint RankID: %d", self.RankID));
    self.Image_Bg_Default:SetVisibility(ESlateVisibility.Collapsed);
end

return UGC_RankingList_ButTab_UIBP
