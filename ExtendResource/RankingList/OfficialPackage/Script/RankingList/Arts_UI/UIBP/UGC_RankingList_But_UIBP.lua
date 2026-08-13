---@class UGC_RankingList_But_UIBP_C:UUserWidget
---@field Button_Cancel UButton
---@field Button_Hotzone UButton
---@field Button_Report UButton
---@field Button_Select UButton
---@field CanvasPanel_List UCanvasPanel
---@field CanvasPanel_OtherPlays UCanvasPanel
---@field CanvasPanel_SelectBg UCanvasPanel
---@field Common_Avatar_BP Common_Avatar_BP_C
---@field Image_Coer_Medal UImage
---@field Image_Huang UImage
---@field Image_Icon_GenderBoy UImage
---@field Image_Icon_GenderGirl UImage
---@field Image_Line UImage
---@field Image_Myself UImage
---@field Image_Pass_RankItemSelectBg UImage
---@field TextBlock_Num UTextBlock
---@field TextBlock_PlayerName UTextBlock
---@field TextBlock_RankIndex UTextBlock
---@field TextBlockNoRank UTextBlock
---@field UGC_ReuseList2_Item UGC_ReuseList2_C
---@field WidgetSwitcher_PlayersStyle UWidgetSwitcher
---@field WidgetSwitcher_SateBG UWidgetSwitcher
---@field WidgetSwitcher_ScoreRank UWidgetSwitcher
---@field WidgetSwitcher_ScoreRank_Sex UWidgetSwitcher
--Edit Below--
local UGC_RankingList_But_UIBP = { bInitDoOnce = false } 

local DefaultProfileData =
{
    nickName = "",          --名称
    picUrl = "",            --头像
    level = 0,              --等级
    sex = 0,                --性别
    cur_avatar_box_id = 0,  --头像框
}

function UGC_RankingList_But_UIBP:Construct()
	self.UGC_ReuseList2_Item.OnUpdateItem:Add(self.InitItem, self);
    self.Button_Hotzone.OnClicked:Add(self.OpenReportBtn, self);
    self.Button_Report.OnClicked:Add(self.OpenReportUI, self);
    self.Button_Cancel.OnClicked:Add(self.HideReportBtn, self);
    self.Button_Cancel:SetVisibility(ESlateVisibility.Collapsed);
    self.PlayerName = "";
end

function UGC_RankingList_But_UIBP:OpenReportBtn()
    print_dev("UGC_RankingList_But_UIBP:OpenReportBtn");
    if self.UID ~= RankingListManager:GetSelfUID() then
        --- 打开当前玩家的举报按钮，关闭其他玩家的举报按钮
        RankingListManager:OpenReportBtn(self.Rank);
    end
end

function UGC_RankingList_But_UIBP:OpenReportUI()
    print_dev("UGC_RankingList_But_UIBP:OpenReportUI");
    self:HideReportBtn();
    local RankListData = RankingListManager:GetRankConfigData(self.RankID);
    if RankListData then
        local UID = tostring(self.UID);
        print_dev(string.format("PlayerName: %s, UID: %d, RankID: %d, ShowUID: %s", self.PlayerName, self.UID, self.RankID, self.ShowUID))
        local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
        RankingListManager:OpenReportUI(PlayerController, UID, self.PlayerName, self.RankID, self.ShowUID);
    end
end

function UGC_RankingList_But_UIBP:ShowReportBtn()
    print_dev("UGC_RankingList_But_UIBP:ShowReportBtn");
    self.Button_Cancel:SetVisibility(ESlateVisibility.Visible);
    self.Button_Report:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function UGC_RankingList_But_UIBP:HideReportBtn()
    print_dev("UGC_RankingList_But_UIBP:HideReportBtn");
    self.Button_Report:SetVisibility(ESlateVisibility.Collapsed);
    self.Button_Cancel:SetVisibility(ESlateVisibility.Collapsed);
end

function UGC_RankingList_But_UIBP:InitItem(Item, Index)
    local ItemInfo = self.ItemList[Index + 1];
    self.Item[Index + 1] = Item;
    Item:InitUI(ItemInfo, self.IsSelf, self.RankID, self.Rank, self.ImageVal);
end

-- function UGC_RankingList_But_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_But_UIBP:Destruct()

-- end

function UGC_RankingList_But_UIBP:InitUI(RankID, RankListInfo, IsSelf, ImageVal)
    print_dev(string.format("RankID: %d, Rank: %d, UID: %d, Score: %s", RankID, RankListInfo.Rank, RankListInfo.UID, tostring(RankListInfo.Score)));
    ---前三名显示图片，其他显示数字
    self.Rank = RankListInfo.Rank;
    self.UID = RankListInfo.UID;
    self.IsSelf = IsSelf;
    self.RankID = RankID;
    self.ImageVal = ImageVal;
    self.ShowUID = true;
    self.Item = {};
    self.PlayerName = "";
    if IsSelf then
        self.WidgetSwitcher_SateBG:SetActiveWidgetIndex(0);
        local IsEnterRankList = RankingListManager:CheckEnterRankList(RankID, self.Rank);
        if IsEnterRankList then
            if self.Rank <= 3 then
                self.WidgetSwitcher_ScoreRank:SetActiveWidgetIndex(0);
                local IconPath = RankingListManager:GetRankPic(self.Rank);
                UIUtil.SetImageBrushAsync(self.Image_Coer_Medal, IconPath, 53, 63);
                self.Image_Coer_Medal:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
            else
                self.WidgetSwitcher_ScoreRank:SetActiveWidgetIndex(1);
                self.TextBlock_RankIndex:SetText(tostring(self.Rank));
            end
        else
            self.WidgetSwitcher_ScoreRank:SetActiveWidgetIndex(2);
        end
    else
        if RankListInfo.UID == RankingListManager:GetSelfUID() then
            self.WidgetSwitcher_SateBG:SetActiveWidgetIndex(2);
        else
            self.WidgetSwitcher_SateBG:SetActiveWidgetIndex(1);
        end

        if self.Rank <= 3 then
            self.WidgetSwitcher_ScoreRank:SetActiveWidgetIndex(0);
            local IconPath = RankingListManager:GetRankPic(self.Rank);
            UIUtil.SetImageBrushAsync(self.Image_Coer_Medal, IconPath, 53, 63);
            self.Image_Coer_Medal:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
        else
            self.WidgetSwitcher_ScoreRank:SetActiveWidgetIndex(1);
            self.TextBlock_RankIndex:SetText(tostring(self.Rank));
        end
    end
    ---玩家信息
    local ProfileData = RankingListManager:GetProfileDataByUID(RankID, RankListInfo.UID);
    self:SetProfileInfo(ProfileData);
    ---分数
    local Score = RankListInfo.Score;
    local RankListConfigData = RankingListManager:GetRankConfigData(RankID);
    if RankListConfigData then
        if RankListConfigData.ScoreFormatType == ERankListScoreFormatType.Time then
            local Min = Score // 60;
            local Sec = math.floor(Score % 60);
            self.TextBlock_Num:SetText(string.format("%02d分%02d秒", Min, Sec));
        elseif RankListConfigData.ScoreFormatType == ERankListScoreFormatType.Percent then
            self.TextBlock_Num:SetText(string.format("%.f%%", Score));
        else
            if Score >= 1e10 or Score <= -1e10 then
                -- 计算指数
                local exponent = math.floor(math.log(math.abs(Score), 10))
                -- 计算尾数
                local mantissa = Score / (10 ^ exponent)
                self.TextBlock_Num:SetText(string.format("%.05fx10^%d", mantissa, exponent))
            else
                self.TextBlock_Num:SetText(tostring(Score));
            end
        end
    end
    ---奖励
    self.ItemList = RankingListManager:GetRankingAwardsConfigData(RankID, self.Rank);
    if self.ItemList and #self.ItemList > 0 then
        self.UGC_ReuseList2_Item:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
        self.UGC_ReuseList2_Item:Reload(#self.ItemList);
    else
        self.UGC_ReuseList2_Item:SetVisibility(ESlateVisibility.Collapsed);
    end

    self:HideReportBtn();
end

function UGC_RankingList_But_UIBP:RefreshRedPoint()
    if self.Item and next(self.Item) ~= nil then
        for Index, Item in pairs(self.Item) do
            Item:RefreshRedPoint();
        end
    end
end

function UGC_RankingList_But_UIBP:SetProfileInfo(ProfileData)
    if ProfileData == nil or next(ProfileData) == nil then
        print_dev("UGC_RankingList_But_UIBP:SetProfileInfo ProfileData is Empty");
        self.PlayerName = "";
        self.TextBlock_PlayerName:SetText(self.PlayerName);
        self.WidgetSwitcher_PlayersStyle:SetActiveWidgetIndex(0);
        self.Common_Avatar_BP:UseAsyncLoad(true);
        self.Common_Avatar_BP:InitView(2, self.UID, DefaultProfileData.PicUrl, DefaultProfileData.sex, DefaultProfileData.cur_avatar_box_id, DefaultProfileData.level, false, false);
        return;
    end

    --- 大厅的隐私设置及排行榜里的隐私设置
    self.UID = ProfileData.UID;

    self.WidgetSwitcher_ScoreRank_Sex:SetVisibility(ESlateVisibility.Collapsed);
    --- 也需要判断是否是当前玩家
    local IsSelfUID = self.UID == RankingListManager:GetSelfUID();
    if ProfileData.IsAnonymous then
        print_dev("[UGC_RankingList_But_UIBP] IsAnonymous is true");
        self.PlayerName = ProfileData.PlayerName;
        self.TextBlock_PlayerName:SetText(ProfileData.ShowName);
        self.WidgetSwitcher_PlayersStyle:SetActiveWidgetIndex(0);
        self.Common_Avatar_BP:UseAsyncLoad(true);
        self.Common_Avatar_BP:InitView(2, ProfileData.UID, ProfileData.PicUrl, DefaultProfileData.sex, DefaultProfileData.cur_avatar_box_id, DefaultProfileData.level, false, false);
        self.ShowUID = false;
    else
        print_dev("[UGC_RankingList_But_UIBP] IsAnonymous is false");
        if IsSelfUID then
            print_dev("[UGC_RankingList_But_UIBP] IsSelfUID is true");
            self.PlayerName = ProfileData.PlayerName;
            self.TextBlock_PlayerName:SetText(ProfileData.ShowName);
            self.WidgetSwitcher_PlayersStyle:SetActiveWidgetIndex(0);
            self.Common_Avatar_BP:UseAsyncLoad(true);
            self.Common_Avatar_BP:InitView(2, ProfileData.UID, ProfileData.PicUrl, DefaultProfileData.sex, DefaultProfileData.cur_avatar_box_id, DefaultProfileData.level, false, false);
        else
            print_dev("[UGC_RankingList_But_UIBP] IsSelfUID is false");
            if ProfileData.IsHided then
                print_dev("[UGC_RankingList_But_UIBP] IsHided is true")
                self.PlayerName = ProfileData.PlayerName;
                self.TextBlock_PlayerName:SetText(ProfileData.ShowName);
                self.WidgetSwitcher_PlayersStyle:SetActiveWidgetIndex(0);
                self.Common_Avatar_BP:UseAsyncLoad(true);
                self.Common_Avatar_BP:InitView(2, ProfileData.UID, ProfileData.PicUrl, DefaultProfileData.sex, DefaultProfileData.cur_avatar_box_id, DefaultProfileData.level, false, false);
                self.ShowUID = false;
            else
                print_dev("[UGC_RankingList_But_UIBP] IsHided is false");
                local IsHide = RankingListManager:GetPrivacySettingByUID(self.UID) == 1;
                if IsHide then
                    print_dev("[UGC_RankingList_But_UIBP] Privacy is true");
                    self.PlayerName = "隐藏玩家";
                    self.TextBlock_PlayerName:SetText(self.PlayerName);
                    self.WidgetSwitcher_PlayersStyle:SetActiveWidgetIndex(1);
                    self.Common_Avatar_BP:UseAsyncLoad(true);
                    self.Common_Avatar_BP:InitView(2, DefaultProfileData.uid, "", DefaultProfileData.sex, DefaultProfileData.cur_avatar_box_id, DefaultProfileData.level, false, false);
                    self.ShowUID = false;
                else
                    print_dev("[UGC_RankingList_But_UIBP] Privacy is false");
                    self.PlayerName = ProfileData.PlayerName;
                    self.TextBlock_PlayerName:SetText(ProfileData.ShowName);
                    self.WidgetSwitcher_PlayersStyle:SetActiveWidgetIndex(0);
                    self.Common_Avatar_BP:UseAsyncLoad(true);
                    self.Common_Avatar_BP:InitView(2, ProfileData.UID, ProfileData.PicUrl, DefaultProfileData.sex, DefaultProfileData.cur_avatar_box_id, DefaultProfileData.level, false, false);
                end
            end
        end
    end
end

function UGC_RankingList_But_UIBP:RefreshProfileData()
    local ProfileData = RankingListManager:GetProfileDataByUID(self.RankID, self.UID);
    self:SetProfileInfo(ProfileData);
end

return UGC_RankingList_But_UIBP
