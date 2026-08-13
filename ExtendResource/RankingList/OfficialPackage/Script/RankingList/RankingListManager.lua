local Delegate = UGCGameSystem.UGCRequire("common.Delegate");

RankingListManager = {
    RankingListActor = nil,
    OnAddAwardsDelegate = Delegate.New(),
}

UGCRankingListAwardState = {
    Lock = 0,
    CanSign = 1,
    HasGot = 2,
    NotAvailable = 3,
}

function RankingListManager:RegisterComponentClass(CompClass)
    if CompClass ~= nil then
        self.RankingListComponentClass = CompClass;
    end
end

--获取玩家的RankingListComponent
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@return RankingListComponent_C
function RankingListManager:GetRankingListComponent(PlayerController)
    if PlayerController == nil and UGCGameSystem.GameState ~= nil and UGCGameSystem.GameState:HasAuthority() == false then
        if self.RankingListComponent == nil then
            if self.RankingListComponentClass ~= nil and UGCGameSystem.GameState ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(UGCGameSystem.GameState);
                self.RankingListComponent = PlayerController:GetComponentByClass(self.RankingListComponentClass);
            else
                print("[RankingListManager:GetRankingListComponent] Cannot get local component!");
            end
        end
           
        return self.RankingListComponent;
    end

    if self.RankingListComponentClass ~= nil then
        return PlayerController:GetComponentByClass(self.RankingListComponentClass);
    else
        print("[RankingListManager:GetRankingListComponent] ComponentClass is nil!");
        return nil;
    end
end

function RankingListManager:GetRankingListTableData()
    print("RankingListManager:GetRankingListTableData");
    if self.RankingListData ~= nil then
        return self.RankingListData; 
    end
    self.RankingListData = {};
    local RankingListTable = UGCGameSystem.GetTableData("Data/Table/UGCRankingList");
    if RankingListTable then
        for Key, Value in pairs(RankingListTable) do
            if Value.EnableType == ERankListEnableType.Enable then
                local BeginDate = Value.BeginDate:Copy();
                local EndDate = Value.EndDate:Copy();
                local BeginTime = BeginDate:ToUnixTimestamp();
                local EndTime = EndDate:ToUnixTimestamp();
                ---周期榜的持续时间要比结束时间多一个周期
                if Value.PeriodType == ERankListPeriodType.DailyReset then
                    EndTime = EndTime + 86400;
                elseif Value.PeriodType == ERankListPeriodType.WeeklyReset then
                    EndTime = EndTime + 604800;
                elseif Value.PeriodType == ERankListPeriodType.MonthlyReset then
                    ---需要获取结束时间下一个月的天数
                    local Year, Month = KismetMathLibrary.BreakDateTime(EndDate);
                    local MonthDay = os.date("%d", os.time({year=Year, month=Month + 2, day=0}));
                    EndTime = EndTime + MonthDay * 86400;
                end
                local Data = {};
                Data.ID = Value.ID;
                Data.PeopleNum = Value.PeopleNum;
                Data.PeriodType = Value.PeriodType;
                Data.BeginDate = BeginDate;
                Data.SettleDate = Value.SettleDate:Copy();
                Data.EndDate = EndDate;
                Data.SortPropertyName = Value.SortPropertyName;
                Data.SortType = Value.SortType;
                Data.RankAward = Value.RankAward:Copy();
                Data.TabName = Value.TabName;
                Data.EndTime = EndTime;
                Data.ShowInGame = Value.ShowInGame;
                Data.Desc = Value.Desc;
                Data.ScoreFormatType = Value.ScoreFormatType;
    
                table.insert(self.RankingListData, Data);
            end
        end
    end
    log_tree("RankingListData: ", self.RankingListData)
    return self.RankingListData;
end

function RankingListManager:GetObjectData()
    print("GiftPackManager:GetObjectData");
    if self.ObjectDatas ~= nil then
        return self.ObjectDatas;
    end

    self.ObjectDatas = {};
    local VirtualItemManager = self:GetVirtualItemManager();
    if VirtualItemManager then
        self.ObjectDatas = VirtualItemManager:GetItemDatas();
    end

    return self.ObjectDatas;
end

--打开排行榜界面
---生效范围：客户端
function RankingListManager:OpenRankingList()
    local Comp = self:GetRankingListComponent()
    if not Comp then return end
    Comp:OpenRankingList();
end

--打开匿名设置界面
---生效范围：客户端
function RankingListManager:OpenUnnamedUI()
    local Comp = self:GetRankingListComponent()
    if not Comp then return end
    Comp:OpenUnnamedUI();
end

--打开说明界面
---生效范围：客户端
function RankingListManager:OpenExplanationUI(RankID)
    local Comp = self:GetRankingListComponent()
    if not Comp then return end
    Comp:OpenExplanationUI(RankID);
end

--切换排行榜
---生效范围：客户端
---@param RankID number
function RankingListManager:SelectRank(RankID)
    self:GetRankingListComponent():SelectRank(RankID);
end

--获取后台的排行榜数据
---生效范围：客户端
---@return any
function RankingListManager:GetAllRankListData()
    return self:GetRankingListComponent():GetAllRankListData();
end

---显示道具Tip
--生效范围：客户端
---@param ItemID number
---@param Position any
function RankingListManager:ShowItemTip(ItemID, Position)
    self:GetRankingListComponent():ShowItemTip(ItemID, Position);
end

function RankingListManager:GetSelfPrivacySetting()
    return self:GetRankingListComponent():GetSelfPrivacySetting();
end

function RankingListManager:GetPrivacySettingByUID(UID)
    return self:GetRankingListComponent():GetPrivacySettingByUID(UID);
end

function RankingListManager:GetRankPic(Rank)
    local Comp = self:GetRankingListComponent()
    if not Comp then return nil end
    return Comp:GetRankPic(Rank);
end

function RankingListManager:CanClaimRankListAward(RankID)
    return self:GetRankingListComponent():CanClaimRankListAward(RankID);
end

function RankingListManager:ReceiveRankListAward(RankID)
    return self:GetRankingListComponent():ReceiveRankListAward(RankID);
end

function RankingListManager:GetAwardList(RankID, Rank)
    local AwardList = {}; 
    local RankListData = self:GetRankConfigData(RankID)
    if RankListData then
        for Index, Data in pairs(RankListData.RankAward) do
            if Rank >= Data.BeginRanking and Rank <= Data.EndRanking then
                for Idx, Award in pairs(Data.AwardList) do
                    if AwardList[Award.ItemID] == nil then
                        AwardList[Award.ItemID] = Award.ItemNum;
                    else
                        AwardList[Award.ItemID] = AwardList[Award.ItemID] + Award.ItemNum;
                    end
                end
                return AwardList;
            end
        end
    end

    return AwardList;
end

function RankingListManager:GetAllRankListRedPoint()
    local Comp = self:GetRankingListComponent()
    if not Comp then return false, {} end
    return Comp:GetRedPointState();
end

function RankingListManager:CheckEnterRankList(RankID, Rank)
    local RankListData = self:GetRankConfigData(RankID);
    if RankListData then
        if Rank > 0 and Rank <= RankListData.PeopleNum then
            return true; 
        end
    end

    return false;
end

function RankingListManager:GetSelfUID()
    return self:GetRankingListComponent():GetSelfUID();
end

function RankingListManager:GetRankListData(RankID, ImageVal)
    local Comp = self:GetRankingListComponent()
    if not Comp then return nil end
    return Comp:GetRankListData(RankID, ImageVal);
end

function RankingListManager:GetMyRankData(RankID, ImageVal)
    return self:GetRankingListComponent():GetMyRankData(RankID, ImageVal);
end

function RankingListManager:GetItemNum(ItemID)
    local Comp = self:GetRankingListComponent()
    if not Comp then return 0 end
    return Comp:GetItemNum(ItemID);
end

function RankingListManager:GetLegalRankListTableData()
    local LegalRankListTableData = {};
    if self.RankingListData == nil then
        self:GetRankingListTableData();
    end
    local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
    if CurTimeStamp then
        for Index, Data in pairs(self.RankingListData) do
            local BeginTimeStamp = Data.BeginDate:ToUnixTimestamp();
            if CurTimeStamp >= BeginTimeStamp and CurTimeStamp < Data.EndTime and Data.ShowInGame == ERankListDisplayType.Show then
                table.insert(LegalRankListTableData, Data);
            end
        end
    end

    log_tree("RankingListManager:GetLegalRankListTableData", LegalRankListTableData);
    return LegalRankListTableData;
end

function RankingListManager:CloseRankList()
    local Comp = self:GetRankingListComponent()
    if not Comp then return end
    Comp:CloseRankList();
end

function RankingListManager:OpenReportBtn(Index)
    self:GetRankingListComponent():OpenReportBtn(Index);
end

function RankingListManager:CheckRankListHasAward(RankID)
    local RankListData = self:GetRankConfigData(RankID);
    if RankListData then
        for Index, Data in pairs(RankListData.RankAward) do
            for Idx, Award in pairs(Data.AwardList) do
                if Award.ItemNum > 0 then
                    return true;
                end
            end
        end
    end

    return false;
end

function RankingListManager:SetPrivacyState(State)
    self:GetRankingListComponent():SetPrivacyState(State);
end

function RankingListManager:GetProfileDataByUID(RankID, UID)
    return self:GetRankingListComponent():GetProfileDataByUID(RankID, UID);
end

function RankingListManager:RegisterActor(RankingListActor)
    self.RankingListActor = RankingListActor;
end

function RankingListManager:GetVirtualItemManager()
    if self.VirtualItemManager == nil then
        self.VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager");
    end
    return self.VirtualItemManager;
end

function RankingListManager:GetRankingPlayerComponent(PlayerController)
    if self.RankingListPlayerComponent == nil then
        self.RankingListPlayerComponent = UGCBlueprintFunctionLibrary.GetGamePartPlayerComponent(PlayerController, "RankingListManager", PlayerController, "RankingList");
    end
    return self.RankingListPlayerComponent;
end

----------------------------------------- API接口 -----------------------------------------
---获取排行榜配置信息
---生效范围：客户端&&服务端
---@param RankID number
---@return any
function RankingListManager:GetRankConfigData(RankID)
    if self.RankingListData == nil then
        self:GetRankingListTableData(); 
    end
    for Index, Data in pairs(self.RankingListData) do
        if Data.ID == RankID then
            return Data; 
        end
    end
    return nil;
end

---获取排行榜配置信息
---生效范围：客户端&&服务端
---@param ItemID number
---@return any
function RankingListManager:GetItemConfigData(ItemID)
    print(string.format("RankingListManager:GetItemConfigData ItemID: %d", ItemID));
    if self.ObjectDatas == nil then
        self:GetObjectData();
    end

    return self.ObjectDatas[ItemID];
end

---获取排名奖励配置信息
---生效范围：客户端&&服务端
---@return any
function RankingListManager:GetAllAwardsConfigData()
    local AllRankListData = self:GetLegalRankListTableData();
    local AllAwardsConfigData = {};
    for Index, RankListData in pairs(AllRankListData) do
        AllAwardsConfigData[RankListData.ID] = {};
        for Index, Info in pairs(RankListData.RankAward) do
            for Rank = Info.BeginRanking, Info.EndRanking do
                local ItemList = {};
                for Idx, ItemInfo in pairs(Info.AwardList) do
                    table.insert(ItemList, {ItemID = ItemInfo.ItemID, ItemNum = ItemInfo.ItemNum})
                end
                AllAwardsConfigData[RankListData.ID][Rank] = ItemList;
            end
        end
    end
    return AllAwardsConfigData;
end

---获取指定排名的奖励信息
---生效范围：客户端&&服务端
---@param RankID number
---@param Rank number
---@return any
function RankingListManager:GetRankingAwardsConfigData(RankID, Rank)
    local RankData = self:GetRankConfigData(RankID);
    local ItemList = {};
    if RankData and RankData.RankAward then
        for Index, Info in pairs(RankData.RankAward) do
            if Rank >= Info.BeginRanking and Rank <= Info.EndRanking then
                for Idx, ItemInfo in pairs(Info.AwardList) do
                    table.insert(ItemList, {ItemID = ItemInfo.ItemID, ItemNum = ItemInfo.ItemNum})
                end
            end
        end
    end
    return ItemList;
end

---获取玩家排名信息
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@param RankID number
---@param RankingCycles number
---@return number, number
function RankingListManager:GetPlayerRankingData(PlayerController, RankID, RankingCycles)
    if PlayerController then
        local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
        if UE.IsValid(RankingListGlobalActor) then
            local UID = PlayerController:GetCurPlayerState().UID;
            local PlayerRankData = RankingListGlobalActor:GetPlayerRankData(UID, RankID, RankingCycles);
            if PlayerRankData then
                return PlayerRankData.Rank, PlayerRankData.Score;
            end
        end
    end
    return -1, 0;
end

---发放排名奖励物资
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@param RankID number
function RankingListManager:AddAwards(PlayerController, RankID)
    self:GetRankingListComponent(PlayerController):AddRankListAwards(PlayerController, RankID);
end

---拉取上榜的排行数据
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
function RankingListManager:RequestTopRankingListData(PlayerController)
    local Comp = self:GetRankingListComponent(PlayerController)
    if not Comp then return end
    Comp:RequestTopRankingListData();
end

---分页拉取排行数据
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@param RankID number
---@param StartIdx number
---@param Count number
---@param RankingCycles number
function RankingListManager:RequestRankingListData(PlayerController, RankID, StartIdx, Count, RankingCycles)
    local Comp = self:GetRankingListComponent(PlayerController)
    if not Comp then return end
    Comp:RequestRankingListDataByRankID(RankID, StartIdx, Count, RankingCycles);
end

---更新排行榜分数
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@param UID number
---@param RankID number
---@param Score number
function RankingListManager:UpdatePlayerRankingScore(PlayerController, UID, RankID, Score)
    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    if UE.IsValid(RankingListGlobalActor) then
        RankingListGlobalActor:UpdateScore(PlayerController, UID, RankID, Score, false);
    end
end

---增量更新排行榜分数
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@param UID number
---@param RankID number
---@param Score number
function RankingListManager:AddPlayerRankingScore(PlayerController, UID, RankID, Score)
    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    if UE.IsValid(RankingListGlobalActor) then
        RankingListGlobalActor:UpdateScore(PlayerController, UID, RankID, Score, true);
    end
end

--打开举报UI
---生效范围：客户端
---@param PlayerController BP_UGCPlayerController_C
---@param UID number
---@param PlayerName string
---@param RankID number
---@param ShowUID boolean
function RankingListManager:OpenReportUI(PlayerController, UID, PlayerName, RankID, ShowUID)
    local RankingListPlayerComponent = self:GetRankingPlayerComponent(PlayerController);
    if RankingListPlayerComponent then
        RankingListPlayerComponent:OpenReportUI(UID, PlayerName, RankID, ShowUID);
    end
end

function RankingListManager:GetIsRequesting(RankID, RankingCycles)
    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    if UE.IsValid(RankingListGlobalActor) then
        return RankingListGlobalActor:GetIsRequesting(RankID, RankingCycles);
    end
    return false
end