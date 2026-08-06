---@class UGC_RankingList_Main_UIBP_C:UUserWidget
---@field Button_Cancel UButton
---@field Button_Close UButton
---@field Button_CurrentData UButton
---@field Button_Help UButton
---@field Button_PreviousIssue_Data UButton
---@field Button_Set UButton
---@field CanvasPanel_SelfMarket UCanvasPanel
---@field HorizontalBox_0 UHorizontalBox
---@field Image_12 UImage
---@field Image_Bg_Default UImage
---@field ScaleBox_IPX UScaleBox
---@field TextBlock_9 UTextBlock
---@field TextBlock_16 UTextBlock
---@field TextBlock_17 UTextBlock
---@field TextBlock_RankTime UTextBlock
---@field UGC_RankingList_But_UIBP UUGC_RankingList_But_UIBP_C
---@field UGC_ReuseList2_Rank UUGC_ReuseList2_C
---@field UGC_ReuseList2_tab UUGC_ReuseList2_C
---@field WidgetSwitcher_Data UWidgetSwitcher
---@field WidgetSwitcher_Rank UWidgetSwitcher
---@field ItemTipUIClassPath FSoftClassPath
--Edit Below--
local UGC_RankingList_Main_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_Main_UIBP:Construct()
    print("UGC_RankingList_Main_UIBP:Construct");
    self:InitBindEvent();
    self:PreLoadUI();
    self.RankTab = {};
    self.RankItem = {};

    ---开启计时器，结算或结束时需要对界面进行刷新
    self.RankTimer = Timer.InsertTimer(
        1, 
        function ()
            if self.SelectedRankID then
                local ServerTime = UGCGameSystem.GetServerTimeSec();
                print(string.format("UGC_RankingList_Main_UIBP RankID: %d CurTime: %d", self.SelectedRankID, ServerTime));
                ---结束时刷新排行榜个数
                if self.EndTime then
                    print(string.format("UGC_RankingList_Main_UIBP 结束时间: %d", self.EndTime));
                    if ServerTime >= self.EndTime then
                        local RankList = RankingListManager:GetLegalRankListTableData();
                        if RankList and next(RankList) == nil then
                            RankingListManager:CloseRankList();
                            if self.RankTimer ~= nil then
                                Timer.RemoveTimer(self.RankTimer);
                                self.RankTimer = nil;
                            end
                        else
                            self:InitUI();
                        end
                    end
                end

                if self:GetVisibility() == ESlateVisibility.SelfHitTestInvisible then
                    ---有新排行榜开启，刷新UI
                    if self.BeginTime then
                        print(string.format("UGC_RankingList_Main_UIBP 开始时间: %d", self.BeginTime));
                        if ServerTime >= self.BeginTime then
                            self:InitUI();
                        end
                    end
    
                    ---结算时刷新排行榜数据
                    if self.SettleTime then
                        print(string.format("UGC_RankingList_Main_UIBP 结算刷新时间: %d", self.SettleTime));
                        if ServerTime >= self.SettleTime then
                            self:SelectRank(self.SelectedRankID, true);
                            self:GetSettleTime();
                        end
                    end
                end
            end
        end,
        true,
        "RankTimer"
    );
end

function UGC_RankingList_Main_UIBP:PreLoadUI()
    Common.LoadObjectWithSoftPathAsync(self.ItemTipUIClassPath, 
        function (Object)
            if self ~= nil and Object ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
                self.ItemTip = UserWidget.NewWidgetObjectBP(PlayerController, Object);
                self.ItemTip:AddToViewport(25000);
                self.ItemTip:SetVisibility(ESlateVisibility.Collapsed);
            end
        end
    );
end

function UGC_RankingList_Main_UIBP:InitBindEvent()
	self.UGC_ReuseList2_Rank.OnUpdateItem:Add(self.InitRankItem, self);
	self.UGC_ReuseList2_tab.OnUpdateItem:Add(self.InitTabItem, self);
    self.Button_Close.OnClicked:Add(self.Close, self);
    self.Button_Set.OnClicked:Add(self.SetUnname, self);
    self.Button_CurrentData.OnClicked:Add(self.OpenCurrentData, self);
    self.Button_PreviousIssue_Data.OnClicked:Add(self.OpenHistoryData, self);
    self.Button_Help.OnClicked:Add(self.OpenExplanationUI, self);
end

function UGC_RankingList_Main_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function UGC_RankingList_Main_UIBP:SetUnname()
    RankingListManager:OpenUnnamedUI();
end

function UGC_RankingList_Main_UIBP:InitRankItem(Item, Index)
    print(string.format("UGC_RankingList_Main_UIBP:InitRankItem Index: %d", Index));
    local RankInfo = self.ShowData[Index + 1];
    if RankInfo then
        log_tree("UGC_RankingList_Main_UIBP:InitRankItem: ", RankInfo);
        self.RankItem[Item] = Index + 1;
        RankInfo.Rank = Index + 1;
        Item:InitUI(self.SelectedRankID, RankInfo, false, self.RankingCycles);
    end
end

function UGC_RankingList_Main_UIBP:InitTabItem(Item, Index)
    print(string.format("UGC_RankingList_Main_UIBP:InitTabItem Index: %d", Index));
    local RankID = self.RankingListTableData[Index + 1].ID;
    Item:InitUI(RankID);
    self.RankTab[Item] = RankID;
    local State = RankingListManager:CanClaimRankListAward(RankID);
    print_dev("UGC_RankingList_Main_UIBP:InitTabItem State:"..tostring(State))
    if State == UGCRankingListAwardState.CanSign then
        Item:ShowRedPoint();
    else
        Item:HideRedPoint();
    end

    if Index == 0 then
        self:SelectRank(RankID);
    else
        Item:UnSelect();
    end
end

-- function UGC_RankingList_Main_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_RankingList_Main_UIBP:Destruct()
    --- 计时器销毁
    if self.RankTimer ~= nil then
        Timer.RemoveTimer(self.RankTimer);
        self.RankTimer = nil;
    end
end

function UGC_RankingList_Main_UIBP:OpenCurrentData()
    print("UGC_RankingList_Main_UIBP:OpenCurrentData");
    if self.SelectedRankID then
        local RankData = RankingListManager:GetRankListData(self.SelectedRankID, 0);
        self:ShowCurrentData(RankData);
        self:ShowSelfData(self.SelectedRankID, 0);
    end
end

function UGC_RankingList_Main_UIBP:OpenHistoryData()
    print("UGC_RankingList_Main_UIBP:OpenHistoryData");
    if self.SelectedRankID then
        local RankData = RankingListManager:GetRankListData(self.SelectedRankID, 1);
        self:ShowHistoryData(RankData);
        self:ShowSelfData(self.SelectedRankID, 1);
    end
end

function UGC_RankingList_Main_UIBP:ShowCurrentData(CurrentData)
    print("UGC_RankingList_Main_UIBP:ShowCurrentData");
    ---显示当期数据
    self.WidgetSwitcher_Data:SetActiveWidgetIndex(1);
    self.RankingCycles = 0;
    self:RefreshRankList(CurrentData, true);
end

function UGC_RankingList_Main_UIBP:ShowHistoryData(HistoryData)
    print("UGC_RankingList_Main_UIBP:ShowHistoryData");
    ---显示上期数据
    self.WidgetSwitcher_Data:SetActiveWidgetIndex(0);
    self.RankingCycles = 1;
    self:RefreshRankList(HistoryData, false);
end

function UGC_RankingList_Main_UIBP:RefreshRankList(RankListData, IsCurrent)
    print("UGC_RankingList_Main_UIBP:RefreshRankList");
    if IsCurrent then
        local RankListInfo = RankingListManager:GetRankConfigData(self.SelectedRankID);
        if RankListInfo then
            if RankListInfo.PeriodType == ERankListPeriodType.NotReset then
                self:SetRankListTime(0);
                self:ShowRankListData(RankListData);
            else
                ---周期榜结束时间后显示已结束
                local CurTime = UGCGameSystem.GetServerTimeSec();
                local EndTime = RankListInfo.EndDate:ToUnixTimestamp();
                print(string.format("CurTime: %d EndTime: %d", CurTime, EndTime));
                if CurTime >= EndTime then
                    self.TextBlock_9:SetText("榜单已结束");
                    self.WidgetSwitcher_Rank:SetActiveWidgetIndex(0);
                    self.HorizontalBox_0:SetVisibility(ESlateVisibility.Collapsed);
                else
                    self:SetRankListTime(0);
                    self:ShowRankListData(RankListData);
                end
            end
        end
    else
        self:SetRankListTime(1);
        self:ShowRankListData(RankListData);
    end
end

function UGC_RankingList_Main_UIBP:ShowRankListData(RankListData)
    if next(RankListData) == nil then
        local IsRequesting = RankingListManager:GetIsRequesting(self.SelectedRankID, self.RankingCycles)
        if IsRequesting then
            --数据加载中
            self.WidgetSwitcher_Rank:SetActiveWidgetIndex(2);
        else
            --- 无玩家上榜
            self.TextBlock_9:SetText("暂无玩家上榜");
            self.WidgetSwitcher_Rank:SetActiveWidgetIndex(0);
        end
    else
        self.WidgetSwitcher_Rank:SetActiveWidgetIndex(1);
        self.ShowData = RankListData;
        self.RankItem = {};
        self.UGC_ReuseList2_Rank:Reload(#RankListData);
    end
    self.HorizontalBox_0:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function UGC_RankingList_Main_UIBP:InitUI()
    print("UGC_RankingList_Main_UIBP:InitUI")
    ---排行榜配置数据
    self.RankingListTableData = RankingListManager:GetLegalRankListTableData();
    self.SelectedRankID = nil;
    ---获取最近一个排行榜的结束时间
    self:GetEndTime();
    self:GetBeginTime();
    self:GetSettleTime();
    self.UGC_ReuseList2_tab:ScrollToStart();
    self.RankTab = {};
    self.UGC_ReuseList2_tab:Reload(#self.RankingListTableData);
end

function UGC_RankingList_Main_UIBP:SelectRank(RankID, ForceRefresh)
    print(string.format("UGC_RankingList_Main_UIBP:SelectRank RankID: %d", RankID));
    if self.SelectedRankID then
        print(string.format("UGC_RankingList_Main_UIBP:SelectRank SelectID: %d", self.SelectedRankID));
    end
    if ForceRefresh == nil then
        ForceRefresh = false;
    end

    if ForceRefresh == false and RankID == self.SelectedRankID then
        return;
    end

    local TabItem = nil;
    for Item, ID in pairs(self.RankTab) do
        if ID == RankID then
            TabItem = Item;
        end
        Item:UnSelect();
    end

    if TabItem then
        self.SelectedRankID = RankID;
        TabItem:Select();
        local RankListData = RankingListManager:GetRankConfigData(RankID);
        if RankListData then
            ---显示上榜玩家信息
            self.RankingCycles = 0;
            self:OpenCurrentData();
            self:RefreshRedPoint(self.SelectedRankID);

            if RankingListManager:CheckRankListHasAward(RankID) then
                self.TextBlock_17:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
            else
                self.TextBlock_17:SetVisibility(ESlateVisibility.Collapsed);
            end

            --- 判断是否为周期榜
            if RankListData.SortPropertyName then
                self.TextBlock_16:SetText(RankListData.SortPropertyName);
            end

            local HideHistoryData = false;
            if RankListData.PeriodType == ERankListPeriodType.NotReset then
                HideHistoryData = true;
            else
                local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
                local CurDate = os.date("*t", CurTimeStamp);
                local BeginTimeStamp = RankListData.BeginDate:ToUnixTimestamp();
                local BeginDate = os.date("*t", BeginTimeStamp);
                if RankListData.PeriodType == ERankListPeriodType.DailyReset then
                    --- 下一天的零点
                    local RefreshTimeStamp = os.time({year=BeginDate.year, month=BeginDate.month, day=BeginDate.day + 1, hour=0, min=0, sec=0});
                    if CurTimeStamp < RefreshTimeStamp then
                        HideHistoryData = true;
                    end
                    print(string.format("DailyReset CurTimeStamp: %d, RefreshTimeStamp: %d", CurTimeStamp, RefreshTimeStamp));
                elseif RankListData.PeriodType == ERankListPeriodType.WeeklyReset then
                    --- 下周一的零点
                    local WeekDay = tonumber(os.date("%w", BeginTimeStamp));
                    local Offset = (WeekDay - 1) % 7;
                    local RefreshTimeStamp = os.time({year=BeginDate.year, month=BeginDate.month, day=BeginDate.day - Offset + 7, hour=0, min=0, sec=0});
                    if CurTimeStamp < RefreshTimeStamp then
                        HideHistoryData = true;
                    end
                    print(string.format("WeeklyReset CurTimeStamp: %d, RefreshTimeStamp: %d", CurTimeStamp, RefreshTimeStamp));
                elseif RankListData.PeriodType == ERankListPeriodType.MonthlyReset then
                    --- 下月一号的零点
                    local RefreshTimeStamp = os.time({year=BeginDate.year, month=BeginDate.month+1, day=1, hour=0, min=0, sec=0});
                    if CurTimeStamp < RefreshTimeStamp then
                        HideHistoryData = true;
                    end
                    print(string.format("MonthlyReset CurTimeStamp: %d, RefreshTimeStamp: %d", CurTimeStamp, RefreshTimeStamp));
                end
            end

            if HideHistoryData == true then
                self.WidgetSwitcher_Data:SetVisibility(ESlateVisibility.Collapsed);
            else
                self.WidgetSwitcher_Data:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
            end
        end
    end
end

function UGC_RankingList_Main_UIBP:SetRankListTime(ImageVal)
    if self.SelectedRankID then
        local RankInfo = RankingListManager:GetRankConfigData(self.SelectedRankID);
        if RankInfo then
            local BeginYear, BeginMonth, BeginDay, EndYear, EndMonth, EndDay;
            local BeginHour = 0;
            local BeginMin = 0;
            local BeginSec = 0;
            local EndHour = 23;
            local EndMin = 59;
            local EndSec = 59;
            if RankInfo.PeriodType == ERankListPeriodType.DailyReset then
                local CurTime = UGCGameSystem.GetServerTimeSec();
                local CurDate = os.date("*t", CurTime);
                local BeginDate;
                local BeginTime;
                if ImageVal == 0 then
                    BeginTime = os.time({year=CurDate.year, month=CurDate.month, day=CurDate.day, hour=0, min=0, sec=0});
                    BeginDate = os.date("*t", BeginTime);
                elseif ImageVal == 1 then
                    BeginTime = os.time({year=CurDate.year, month=CurDate.month, day=CurDate.day - 1, hour=0, min=0, sec=0});
                    BeginDate = os.date("*t", BeginTime);
                end
                if BeginTime < RankInfo.BeginDate:ToUnixTimestamp() then
                    local BeginTimeStamp = RankInfo.BeginDate:ToUnixTimestamp();
                    local LocalBeginDate = os.date("*t", BeginTimeStamp);
                    BeginYear = LocalBeginDate.year;
                    BeginMonth = LocalBeginDate.month;
                    BeginDay = LocalBeginDate.day;
                    BeginHour = LocalBeginDate.hour;
                    BeginMin = LocalBeginDate.min;
                    BeginSec = LocalBeginDate.sec;
                else
                    if BeginDate then
                        BeginYear = BeginDate.year;
                        BeginMonth = BeginDate.month;
                        BeginDay = BeginDate.day;
                    end
                end
                EndYear = BeginYear;
                EndMonth = BeginMonth;
                EndDay = BeginDay;
            elseif RankInfo.PeriodType == ERankListPeriodType.WeeklyReset then
                local CurTime = UGCGameSystem.GetServerTimeSec();
                local CurDate = os.date("*t", CurTime);
                local WeekDay = tonumber(os.date("%w", CurTime));
                local Offset = (WeekDay - 1) % 7;
                local BeginDate;
                local BeginTime;
                if ImageVal == 0 then
                    BeginTime = os.time({year=CurDate.year, month=CurDate.month, day=CurDate.day - Offset, hour=0, min=0, sec=0});
                    BeginDate = os.date("*t", BeginTime);
                elseif ImageVal == 1 then
                    BeginTime = os.time({year=CurDate.year, month=CurDate.month, day=CurDate.day - Offset - 7, hour=0, min=0, sec=0});
                    BeginDate = os.date("*t", BeginTime);
                end
                local EndTime = BeginTime + 518400;
                local EndDate = os.date("*t", EndTime);
                if BeginTime < RankInfo.BeginDate:ToUnixTimestamp() then
                    --- 转成北京时间
                    local BeginTimeStamp = RankInfo.BeginDate:ToUnixTimestamp();
                    local LocalBeginDate = os.date("*t", BeginTimeStamp);
                    BeginYear = LocalBeginDate.year;
                    BeginMonth = LocalBeginDate.month;
                    BeginDay = LocalBeginDate.day;
                    BeginHour = LocalBeginDate.hour;
                    BeginMin = LocalBeginDate.min;
                    BeginSec = LocalBeginDate.sec;
                else
                    if BeginDate then
                        BeginYear = BeginDate.year;
                        BeginMonth = BeginDate.month;
                        BeginDay = BeginDate.day;
                    end
                end
                if EndDate then
                    EndYear = EndDate.year;
                    EndMonth = EndDate.month;
                    EndDay = EndDate.day;
                end
            elseif RankInfo.PeriodType == ERankListPeriodType.MonthlyReset then
                local CurTime = UGCGameSystem.GetServerTimeSec();
                local CurDate = os.date("*t", CurTime);
                local BeginDate;
                local BeginTime;
                if ImageVal == 0 then
                    BeginTime = os.time({year=CurDate.year, month=CurDate.month, day=1, hour=0, min=0, sec=0});
                    BeginDate = os.date("*t", BeginTime);
                elseif ImageVal == 1 then
                    BeginTime = os.time({year=CurDate.year, month=CurDate.month - 1, day=1, hour=0, min=0, sec=0});
                    BeginDate = os.date("*t", BeginTime);
                end
                if BeginTime < RankInfo.BeginDate:ToUnixTimestamp() then
                    local BeginTimeStamp = RankInfo.BeginDate:ToUnixTimestamp();
                    local LocalBeginDate = os.date("*t", BeginTimeStamp);
                    BeginYear = LocalBeginDate.year;
                    BeginMonth = LocalBeginDate.month;
                    BeginDay = LocalBeginDate.day;
                    BeginHour = LocalBeginDate.hour;
                    BeginMin = LocalBeginDate.min;
                    BeginSec = LocalBeginDate.sec;
                else
                    if BeginDate then
                        BeginYear = BeginDate.year;
                        BeginMonth = BeginDate.month;
                        BeginDay = 1;
                    end
                end
                EndYear = BeginYear;
                EndMonth = BeginMonth;
                local MonthDay = os.date("%d", os.time({year=BeginYear, month=BeginMonth + 1, day=0}));
                EndDay = MonthDay;
            elseif RankInfo.PeriodType == ERankListPeriodType.NotReset then
                local BeginTimeStamp = RankInfo.BeginDate:ToUnixTimestamp();
                local SettleTimeStamp = RankInfo.SettleDate:ToUnixTimestamp();
                local LocalBeginDate = os.date("*t", BeginTimeStamp);
                local LocalSettleDate = os.date("*t", SettleTimeStamp);
                BeginYear = LocalBeginDate.year;
                BeginMonth = LocalBeginDate.month;
                BeginDay = LocalBeginDate.day;
                BeginHour = LocalBeginDate.hour;
                BeginMin = LocalBeginDate.min;
                BeginSec = LocalBeginDate.sec;
                EndYear = LocalSettleDate.year;
                EndMonth = LocalSettleDate.month;
                EndDay = LocalSettleDate.day;
                EndHour = LocalSettleDate.hour;
                EndMin = LocalSettleDate.min;
                EndSec = LocalSettleDate.sec;
            end
    
            self.TextBlock_RankTime:SetText(string.format("%04d.%02d.%02d %02d:%02d:%02d-%04d.%02d.%02d %02d:%02d:%02d", BeginYear, BeginMonth, BeginDay, BeginHour, BeginMin, BeginSec, EndYear, EndMonth, EndDay, EndHour, EndMin, EndSec));
            print(string.format("BeginYear: %d BeginMonth: %d BeginDay %d BeginHour: %d BeginMin: %d BeginSec: %d", BeginYear, BeginMonth, BeginDay, BeginHour, BeginMin, BeginSec));
            print(string.format("EndYear: %d EndMonth: %d EndDay %d EndHour: %d EndMin: %d EndSec: %d", EndYear, EndMonth, EndDay, EndHour, EndMin, EndSec));
        end
    end
end

---获取最近一个排行榜的结算时间
function UGC_RankingList_Main_UIBP:GetSettleTime()
    print("UGC_RankingList_Main_UIBP:GetSettleTime");
    self.SettleTime = nil;
    if self.RankingListTableData then
        local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
        local CurrentTime = os.date("*t", CurTimeStamp);
        for Key, Value in pairs(self.RankingListTableData) do
            local SettleTime = 0;
            if Value.PeriodType == ERankListPeriodType.DailyReset then
                ---下一天的0点结算
                SettleTime = os.time({year=CurrentTime.year, month=CurrentTime.month, day=CurrentTime.day + 1, hour=0, min=0, sec=0});
            elseif Value.PeriodType == ERankListPeriodType.WeeklyReset then
                ---下周一的0点结算
                local WeekDay = tonumber(os.date("%w", CurTimeStamp));
                local Offset = (WeekDay - 1) % 7;
                SettleTime = os.time({year=CurrentTime.year, month=CurrentTime.month, day=CurrentTime.day - Offset + 7, hour=0, min=0, sec=0});
            elseif Value.PeriodType == ERankListPeriodType.MonthlyReset then
                ---下个月第一天的0点结算
                SettleTime = os.time({year=CurrentTime.year, month=CurrentTime.month + 1, day=1, hour=0, min=0, sec=0});
            elseif Value.PeriodType == ERankListPeriodType.NotReset then
                ---表格里的结算时间
                SettleTime = Value.SettleDate:ToUnixTimestamp();
            end

            if SettleTime > CurTimeStamp then
                if self.SettleTime == nil then
                    self.SettleTime = SettleTime;
                else
                    if self.SettleTime > SettleTime then
                        self.SettleTime = SettleTime; 
                    end
                end
            end
        end
    end

    if self.SettleTime then
        print(string.format("UGC_RankingList_Main_UIBP:GetSettleTime SettleTime: %d", self.SettleTime));
    else
        print("UGC_RankingList_Main_UIBP:GetSettleTime SettleTime is Nil");
    end
end

function UGC_RankingList_Main_UIBP:ShowItemTip(ItemID, Position)
    self.ItemTip:InitUI(ItemID, Position);
    self.ItemTip:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function UGC_RankingList_Main_UIBP:RefreshRedPoint(RankID)
    local State = RankingListManager:CanClaimRankListAward(RankID);
    print_dev(string.format("UGC_RankingList_Main_UIBP:RefreshRedPoint RankID: %d State: %s", RankID or -1, tostring(State)))
    local RankListData = RankingListManager:GetRankConfigData(RankID);
    if RankListData then
        if State == UGCRankingListAwardState.CanSign then
            if RankListData.PeriodType == ERankListPeriodType.NotReset then
                self.Image_Bg_Default:SetVisibility(ESlateVisibility.Collapsed);
            elseif self.RankingCycles == 0 then
                self.Image_Bg_Default:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
            end
        else
            self.Image_Bg_Default:SetVisibility(ESlateVisibility.Collapsed);
        end
        self.UGC_RankingList_But_UIBP:RefreshRedPoint();
    end
    for Item, ID in pairs(self.RankTab) do
        if RankID == ID then
            if State == UGCRankingListAwardState.CanSign then
                Item:ShowRedPoint();
            else
                Item:HideRedPoint();
            end
            break
        end
    end
end

function UGC_RankingList_Main_UIBP:ShowSelfData(RankID, ImageVal)
    ---玩家自己的上榜信息
    local MyRankData = RankingListManager:GetMyRankData(RankID, ImageVal);
    local SelfRankInfo = {
        Rank = MyRankData.Rank,
        UID = RankingListManager:GetSelfUID(),
        Score = MyRankData.Score,
    }
    self.UGC_RankingList_But_UIBP:InitUI(RankID, SelfRankInfo, true, ImageVal);
end

---获取最近一个排行榜的结束时间
function UGC_RankingList_Main_UIBP:GetEndTime()
    print("UGC_RankingList_Main_UIBP:GetEndTime");
    self.EndTime = nil;
    if self.RankingListTableData then
        local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
        for Key, Value in pairs(self.RankingListTableData) do 
            if Value.EndTime > CurTimeStamp then
                if self.EndTime == nil then
                    self.EndTime = Value.EndTime;
                else
                    if self.EndTime > Value.EndTime then
                        self.EndTime = Value.EndTime;
                    end
                end
            end
        end
    end

    if self.EndTime then
        print(string.format("UGC_RankingList_Main_UIBP:GetEndTime EndTime: %d", self.EndTime));
    else
        print("UGC_RankingList_Main_UIBP:GetEndTime EndTime is Nil");
    end
end

---获取最近一个排行榜的开始时间
function UGC_RankingList_Main_UIBP:GetBeginTime()
    print("UGC_RankingList_Main_UIBP:GetBeginTime");
    --- 这里要读全部的排行榜数据
    self.BeginTime = nil;
    local RankingListTablData = RankingListManager:GetRankingListTableData();
    if RankingListTablData then
        local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
        for Key, Value in pairs(RankingListTablData) do 
            local BeginTimeStamp = Value.BeginDate:ToUnixTimestamp();
            if BeginTimeStamp > CurTimeStamp then
                if self.BeginTime == nil then
                    self.BeginTime = BeginTimeStamp;
                else
                    if self.BeginTime > BeginTimeStamp then
                        self.BeginTime = BeginTimeStamp;
                    end
                end
            end
        end
    end

    if self.BeginTime then
        print(string.format("UGC_RankingList_Main_UIBP:GetBeginTime BeginTime: %d", self.BeginTime));
    else
        print("UGC_RankingList_Main_UIBP:GetBeginTime BeginTime is Nil");
    end
end

function UGC_RankingList_Main_UIBP:OpenExplanationUI()
    if self.SelectedRankID ~= nil then
        RankingListManager:OpenExplanationUI(self.SelectedRankID);
    end
end

function UGC_RankingList_Main_UIBP:OpenReportBtn(Index)
    for Item, Idx in pairs(self.RankItem) do
        if Idx == Index then
            Item:ShowReportBtn();
        else
            Item:HideReportBtn();
        end
    end
end

function UGC_RankingList_Main_UIBP:RefreshRankData(RankID, RankingCycles)
    if self.SelectedRankID == RankID and self.RankingCycles == RankingCycles then
        local RankData = RankingListManager:GetRankListData(RankID, RankingCycles);
        if self.RankingCycles == 0 then
            self:ShowCurrentData(RankData);
        else
            self:ShowHistoryData(RankData);
        end
    end
end

function UGC_RankingList_Main_UIBP:RefreshPlayerRankData(RankID, RankingCycles)
    if self.SelectedRankID == RankID and self.RankingCycles == RankingCycles then
        self:ShowSelfData(RankID, RankingCycles);
    end
end

function UGC_RankingList_Main_UIBP:RefreshProfileData(RankID)
    if self.SelectedRankID == RankID then
        local Items = {}
        self.UGC_ReuseList2_Rank:GetAllItems(Items)
        for Idx, Item in pairs(Items) do
            Item:RefreshProfileData()
        end
        self.UGC_RankingList_But_UIBP:RefreshProfileData()
    end
end

return UGC_RankingList_Main_UIBP
