---@class RankingListComponent_C:ActorComponent
---@field RankingListMainUIPath FSoftClassPath
---@field RankingListUnnamedUIPath FSoftClassPath
---@field GoldIconPath FSoftObjectPath
---@field SilverIconPath FSoftObjectPath
---@field CopperIconPath FSoftObjectPath
---@field RankingListItemGetUIPath FSoftClassPath
---@field RankingListExplanationUIPath FSoftClassPath
---@field RankingListBtnUIPath FSoftClassPath
--Edit Below--
local RankingListComponent = {
    PlayerAccountInfo = {},
    RequestMark = "RankingList";
}

UGCGameSystem.UGCRequire("ExtendResource.RankingList.OfficialPackage." .. "Script.RankingList.RankingListManager");
UGCGameSystem.UGCRequire("ExtendResource.RankingList.OfficialPackage." .. "Script.Common.Common");

function RankingListComponent:ReceiveBeginPlay()
    print("[RankingListComponent] ReceiveBeginPlay")
    RankingListComponent.SuperClass.ReceiveBeginPlay(self)
    RankingListManager:RegisterComponentClass(GameplayStatics.GetObjectClass(self));

    local PlayerController = self:GetOwner();
    if UGCGamePartSystem.IsGamePartLoaded("RankingListManager") then
        if UE.IsValid(self:GetRankingListGlobalActor()) then
            self:GetRankingListGlobalActor().ClaimRankListAwardDelegate:Add(self.AddRankListAwardsDelegate, self);
            if PlayerController:HasAuthority() == false then
                self:GetRankingListGlobalActor().ProfileDataChangeDelegate:Add(self.UpdateProfileData, self);
                self:GetRankingListGlobalActor().ShowRankDataChangeDelegate:Add(self.UpdateShowRankData, self);
                self:GetRankingListGlobalActor().ShowPlayerRankDataChangeDelegate:Add(self.UpdateShowPlayerRankData, self);
            end
        end
    end
    if PlayerController:HasAuthority() and UGCGamePartSystem.IsGamePartLoaded("VirtualItemManager") then
        if UE.IsValid(self:GetVirtualItemManager()) then
            self:GetVirtualItemManager().AddItemResultDelegate:Add(self.OnAddVirtualItem, self);
        end
    end
    if PlayerController:HasAuthority() == true then
        GMP.GlobalMessage.BindUObject(PlayerController, "UGC.GamePart.GamePartLoadedForPlayer", self, self.InitGamePart);

        if PlayerController:GetInt64PlayerKey() == 0 then
            local STExtraGMDelegatesMgr = UGCGameSystem.GetSTExtraGMDelegatesMgr();
            if STExtraGMDelegatesMgr ~= nil then
                STExtraGMDelegatesMgr.GetInstance().OnPlayerPostLoginDelegate:AddInstance(self.LoadData, self);
            end
        else
            self:LoadData();
        end
    else
        GMP.GlobalMessage.BindUObject(PlayerController, "UGC.GamePart.GamePartLoaded", self, self.InitGamePart); 
        self:PreLoadUI();
    end

    local ShowRankListBtn = false;
    if self.RankingListTimer == nil then
        self.RankingListTimer = Timer.InsertTimer(
            1,
            function ()
                local ServerTime = UGCGameSystem.GetServerTimeSec();
                if PlayerController:HasAuthority() == false then
                    if ShowRankListBtn == false and (self.LastCheckRankListTime == nil or ServerTime - self.LastCheckRankListTime >= 60) then
                        local RankList = RankingListManager:GetLegalRankListTableData();
                        if RankList and next(RankList) ~= nil then
                            if self.RankingListBtn then
                                self.RankingListBtn:InitUI();
                                self.RankingListBtn:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
                                ShowRankListBtn = true;
                            end
                        end
                        self.LastCheckRankListTime = ServerTime;
                    end
                end
            end,
            true,
            "RankingListTimer",
            0
        );
    end
end

--[[
function RankingListComponent:ReceiveTick(DeltaTime)
    RankingListComponent.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

function RankingListComponent:ReceiveEndPlay()
    print("[RankingListComponent] ReceiveEndPlay");
    RankingListComponent.SuperClass.ReceiveEndPlay(self);

    local PC = self:GetOwner();
    if PC:HasAuthority() == true and UE.IsValid(self:GetVirtualItemManager()) then
        self:GetVirtualItemManager().AddItemResultDelegate:Remove(self.OnAddVirtualItem, self);
    end
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        if PC:HasAuthority() == false then
            self:GetRankingListGlobalActor().ProfileDataChangeDelegate:Remove(self.UpdateProfileData, self);
            self:GetRankingListGlobalActor().ShowRankDataChangeDelegate:Remove(self.UpdateShowRankData, self);
            self:GetRankingListGlobalActor().ShowPlayerRankDataChangeDelegate:Remove(self.UpdateShowPlayerRankData, self);
        end
        self:GetRankingListGlobalActor().ClaimRankListAwardDelegate:Remove(self.AddRankListAwardsDelegate, self);
    end

    if self.RankingListTimer ~= nil then
        Timer.RemoveTimer(self.RankingListTimer);
        self.RankingListTimer = nil;
    end
end

function RankingListComponent:GetReplicatedProperties()
    return  {"PlayerAccountInfo", "Lazy"};
end

function RankingListComponent:GetAvailableServerRPCs()
    return  "Server_RequestAllRankListData",
            "Server_RequestRankListData";
end

--初始化GamePart
---生效范围:客户端&&服务端
---@param GamePartName string
function RankingListComponent:InitGamePart(GamePartName)
    print(string.format("[RankingListComponent] InitGamePart GamePartName: %s", GamePartName or ""));
    local PlayerController = self:GetOwner();
    if GamePartName == "VirtualItemManager" then
        if UE.IsValid(self:GetVirtualItemManager()) then
            if PlayerController:HasAuthority() == true then
                self:GetVirtualItemManager().AddItemResultDelegate:Add(self.OnAddVirtualItem, self);
            end
        end
        print(string.format("[RankingListComponent] VirtualItemManager is Nil: %s", self.VirtualItemManager == nil));
    elseif GamePartName == "RankingListManager" then
        if self.RankingListPlayerComponent == nil then
            self.RankingListPlayerComponent = UGCBlueprintFunctionLibrary.GetGamePartPlayerComponent(PlayerController, "RankingListManager", PlayerController, "RankingList");
        end
        if UE.IsValid(self:GetRankingListGlobalActor()) then
            self:GetRankingListGlobalActor().ClaimRankListAwardDelegate:Add(self.AddRankListAwardsDelegate, self);
            if PlayerController:HasAuthority() == false then
                self:GetRankingListGlobalActor().ProfileDataChangeDelegate:Add(self.UpdateProfileData, self);
                self:GetRankingListGlobalActor().ShowRankDataChangeDelegate:Add(self.UpdateShowRankData, self);
                self:GetRankingListGlobalActor().ShowPlayerRankDataChangeDelegate:Add(self.UpdateShowPlayerRankData, self);
            end
        end
        print(string.format("[RankingListComponent] RankingListPlayerComponent is Nil: %s", self.RankingListPlayerComponent == nil));
    end
end

--玩家登录后初始化数据
--生效范围：服务端
function RankingListComponent:LoadData()
    local PlayerController = self:GetOwner();
    local PlayerKey = PlayerController:GetInt64PlayerKey();
    local PlayerAccountInfo = UGCPlayerStateSystem.GetPlayerAccountInfo(PlayerKey):Copy();
    self.PlayerAccountInfo.UID = PlayerAccountInfo.UID;
    self.PlayerAccountInfo.PlayerName = PlayerAccountInfo.PlayerName;
    self.PlayerAccountInfo.Gender = PlayerAccountInfo.Gender;
    self.PlayerAccountInfo.IconURL = PlayerAccountInfo.IconURL;
    _G.DOREPONCE(self, "PlayerAccountInfo");
end

function RankingListComponent:OnRep_PlayerAccountInfo()
    log_tree("[RankingListComponent] OnRep_PlayerAccountInfo PlayerAccountInfo: ", self.PlayerAccountInfo);
end

------------------------------------------------------------请求数据相关------------------------------------------------------------
--请求所有排行榜数据
--生效范围：服务端
---@param PlayerController BP_UGCPlayerController_C
function RankingListComponent:Server_RequestAllRankListData(PlayerController)
    if PlayerController:HasAuthority() == false then
        return;
    end
    self:RequestAllRankListData();
end

--请求所有排行榜数据
--生效范围：服务端
function RankingListComponent:RequestAllRankListData()
    print("[RankingListComponent] RequestAllRankListData")
    --- 清空UID
    local RankListTableData = RankingListManager:GetLegalRankListTableData();
    for Index, Data in pairs(RankListTableData) do
        if Data.PeriodType == ERankListPeriodType.NotReset then
            if Data.PeopleNum <= 100 then
                self:RequestRankingListData(Data.ID, 1, Data.PeopleNum, 0);
            else
                self:RequestRankingListData(Data.ID, 1, 100, 0);
                self:RequestRankingListData(Data.ID, 101, Data.PeopleNum - 100, 0);
            end
        else
            if Data.PeopleNum <= 100 then
                self:RequestRankingListData(Data.ID, 1, Data.PeopleNum, 0);
                self:RequestRankingListData(Data.ID, 1, Data.PeopleNum, 1);
            else
                self:RequestRankingListData(Data.ID, 1, 100, 0);
                self:RequestRankingListData(Data.ID, 101, Data.PeopleNum - 100, 0);
                self:RequestRankingListData(Data.ID, 1, 100, 1);
                self:RequestRankingListData(Data.ID, 101, Data.PeopleNum - 100, 1);
            end
        end
    end
end

--请求单个排行榜数据
--生效范围：服务端
---@param RankID number
---@param StartIdx number
---@param Count number
---@param RankingCycles number
function RankingListComponent:RequestRankingListData(RankID, StartIdx, Count, RankingCycles)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == false then
        return;
    end
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        local UID = self:GetSelfUID();
        self:GetRankingListGlobalActor():RequestRankingListData(UID, RankID, StartIdx, Count, RankingCycles);
    end
end

--请求排行榜数据
--生效范围：服务端
---@param PlayerController BP_UGCPlayerController_C
---@param RankID number
---@param StartIdx number
---@param Count number
---@param RankingCycles number
function RankingListComponent:Server_RequestRankListData(RankID, StartIdx, Count, RankingCycles)
    if self:GetOwner():HasAuthority() == false then
        return;
    end
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        local UID = self:GetSelfUID();
        self:GetRankingListGlobalActor():RequestRankingListData(UID, RankID, StartIdx, Count, RankingCycles);
    end
end

--上传隐私设置
--生效范围：客户端
---@param State number
function RankingListComponent:SetPrivacyState(State)
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        local UID = self:GetSelfUID();
        self:GetRankingListGlobalActor():SetRankListPrivacy(UID, State);
    end
end

------------------------------------------------------------获取数据相关------------------------------------------------------------
--获取排行榜排名数据
--生效范围：客户端&&服务端
---@param RankID number
---@param RankingCycles number
---@return any
function RankingListComponent:GetRankListData(RankID, RankingCycles)
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        return self:GetRankingListGlobalActor():GetRankListData(RankID, RankingCycles);
    end
    return {};
end

--获取当前玩家的排名数据
--生效范围：客户端&&服务端
---@param RankID number
---@param RankingCycles number
---@return any
function RankingListComponent:GetMyRankData(RankID, RankingCycles)
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        local SelfUID = self:GetSelfUID();
        return self:GetRankingListGlobalActor():GetPlayerRankData(SelfUID, RankID, RankingCycles);
    end
    return {Rank = -1, Score = 0};
end

--获取全部排行榜排名数据
--生效范围：客户端&&服务端
---@return any
function RankingListComponent:GetAllRankListData()
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        return self:GetRankingListGlobalActor():GetShowRankData();
    end
    return {};
end

--通过玩家UID获取账号信息
--生效范围：客户端
---@param RankID number
---@param UID number
---@return any
function RankingListComponent:GetProfileDataByUID(RankID, UID)
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        return self:GetRankingListGlobalActor():GetProfileData(RankID, UID);
    end
    return {};
end

--获取当前玩家的隐私配置
--生效范围：客户端&&服务端
function RankingListComponent:GetSelfPrivacySetting()
    local SelfUID = self:GetSelfUID();
    return self:GetPrivacySettingByUID(SelfUID);
end

--通过玩家UID获取隐私配置
--生效范围：客户端&&服务端
---@param UID number
---@return number
function RankingListComponent:GetPrivacySettingByUID(UID)
    print(string.format("[RankingListComponent] GetPrivacySettingByUID UID: %d", UID or -1));
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        return self:GetRankingListGlobalActor():GetRankListPrivacyByUID(UID);
    end
    return 0;
end

--获取当前玩家的UID
--生效范围：客户端&&服务端
---@return number
function RankingListComponent:GetSelfUID()
    if self.PlayerAccountInfo and self.PlayerAccountInfo.UID then
        print(string.format("[RankingListComponent] SelfUID: %d", self.PlayerAccountInfo.UID));
        return self.PlayerAccountInfo.UID;
    end
    return 0;
end

--获取已拥有的道具数量
--生效范围：客户端&&服务端
---@param ItemID number
---@return number
function RankingListComponent:GetItemNum(ItemID)
    if UE.IsValid(self:GetVirtualItemManager()) then
        local PlayerController = self:GetOwner();
        return self:GetVirtualItemManager():GetItemNum(ItemID, PlayerController); 
    end
    return 0;
end
------------------------------------------------------------排行榜奖励相关------------------------------------------------------------
--领取排行榜奖励
--生效范围：客户端
---@param RankID number
---@param Rank number
function RankingListComponent:ReceiveRankListAward(RankID)
    local PlayerController = self:GetOwner();
    self:AddRankListAwards(PlayerController, RankID);
end

--判断是否可以领取奖励
--生效范围：客户端&&服务端
---@param RankID number
---@return UGCRankingListAwardState
function RankingListComponent:CanClaimRankListAward(RankID)
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        local PC = self:GetOwner();
        return self:GetRankingListGlobalActor():CanClaimRankListAward(PC, RankID);
    end
    return 0;
end

--添加道具 
--生效范围：服务端
---@param AwardList any
---@return boolean
function RankingListComponent:AddItems(AwardList)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == false then
        return false;
    end

    if UE.IsValid(self:GetVirtualItemManager()) then
        return self:GetVirtualItemManager():AddVirtualItems(PlayerController, AwardList, self.RequestMark);
    end
    return false;
end

---添加道具回调
--生效范围：服务端
---@param Result any
function RankingListComponent:OnAddVirtualItem(Result)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == false then
        return;
    end
    local bSucceeded = Result.bSucceeded;
    local ItemList = Result.ItemList;
    local PlayerKey = Result.PlayerKey;
    local RequestMark = Result.RequestMark;
    local SelfPlayerKey = PlayerController:GetInt64PlayerKey();
    print(string.format("[RankingListComponent] OnAddVirtualItem PlayerKey: %d SelfPlayerKey: %d", PlayerKey, SelfPlayerKey));
    if bSucceeded and PlayerKey == SelfPlayerKey and RequestMark == self.RequestMark then
        local AwardList = {};
        for ItemID, ItemNum in pairs(ItemList) do
            table.insert(AwardList, {ItemID = ItemID, ItemNum = ItemNum});
        end
        UnrealNetwork.CallUnrealRPC(PlayerController, self, "Client_ItemGet", AwardList);
    end
end


------------------------------------------------------------UI相关------------------------------------------------------------
--预加载UI
--生效范围：客户端
function RankingListComponent:PreLoadUI()
    local PlayerController = self:GetOwner();
    Common.LoadObjectWithSoftPathAsync(self.RankingListMainUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.RankingListMainUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.RankingListMainUI:AddToViewport(10000);
            self.RankingListMainUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.RankingListUnnamedUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.RankingListUnnamedUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.RankingListUnnamedUI:AddToViewport(15000);
            self.RankingListUnnamedUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.RankingListExplanationUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.RankingListExplanationUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.RankingListExplanationUI:AddToViewport(15000);
            self.RankingListExplanationUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.RankingListItemGetUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.RankingListItemGetUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.RankingListItemGetUI:AddToViewport(15000);
            self.RankingListItemGetUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.RankingListBtnUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.RankingListBtn = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.RankingListBtn:AddToViewport(1000);
            self.RankingListBtn:InitUI();
            local RankList = RankingListManager:GetLegalRankListTableData();
            if RankList and next(RankList) ~= nil then
                self.RankingListBtn:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
            else
                self.RankingListBtn:SetVisibility(ESlateVisibility.Collapsed);
            end
        end
    end)
end

--打开排行榜主界面
--生效范围：客户端
function RankingListComponent:OpenRankingList()
    if self.RankingListMainUI then
        self.RankingListMainUI:InitUI();
        self.RankingListMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);        
    end
end

--打开隐私设置界面
--生效范围：客户端
function RankingListComponent:OpenUnnamedUI()
    if self.RankingListUnnamedUI then
        self.RankingListUnnamedUI:InitUI();
        self.RankingListUnnamedUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);        
    end
end

--打开说明界面
--生效范围：客户端
function RankingListComponent:OpenExplanationUI(RankID)
    if self.RankingListExplanationUI then
        self.RankingListExplanationUI:InitUI(RankID);
        self.RankingListExplanationUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

--选择排行榜
--生效范围：客户端
---@param RankID number
function RankingListComponent:SelectRank(RankID)
    if self.RankingListMainUI ~= nil then
        self.RankingListMainUI:SelectRank(RankID);
    end
end

--显示道具提示
--生效范围：客户端
---@param ItemID number
---@param Position any
function RankingListComponent:ShowItemTip(ItemID, Position)
    if self.RankingListMainUI ~= nil then
        self.RankingListMainUI:ShowItemTip(ItemID, Position);
    end
end

--显示获得道具界面并刷新红点
--生效范围：客户端
---@param ItemList any
function RankingListComponent:Client_ItemGet(ItemList)
    if self:GetOwner():HasAuthority() == true then
        return;
    end
    if self.RankingListItemGetUI then
        self.RankingListItemGetUI:InitUI(ItemList);
        self.RankingListItemGetUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);        
    end
end

--关闭排行榜界面及入口
--生效范围：客户端
function RankingListComponent:CloseRankList()
    if self.RankingListBtn then
         self.RankingListBtn:SetVisibility(ESlateVisibility.Collapsed);
    end
    if self.RankingListMainUI then
        self.RankingListMainUI:SetVisibility(ESlateVisibility.Collapsed);
    end
end

--显示举报按钮
--生效范围：客户端
---@param Index number
function RankingListComponent:OpenReportBtn(Index)
    if self.RankingListMainUI then
        self.RankingListMainUI:OpenReportBtn(Index);
    end
end

--刷新整个排行榜的红点
--生效范围：客户端
function RankingListComponent:RefreshAllRedPoint(RankID)
    if self.RankingListBtn then
        self.RankingListBtn:RefreshRedPoint();
    end
    if self.RankingListMainUI and self.RankingListMainUI:GetVisibility() == ESlateVisibility.SelfHitTestInvisible then
        self.RankingListMainUI:RefreshRedPoint(RankID);
    end
end

--获取前三名的排名图标
--生效范围：客户端
---@param Rank number
---@return string
function RankingListComponent:GetRankPic(Rank)
    print(string.format("[RankingListComponent] GetRankPic Rank: %d", Rank));
    if Rank == 1 then
        return self.GoldIconPath.AssetPathName;
    elseif Rank == 2 then
        return self.SilverIconPath.AssetPathName;
    elseif Rank == 3 then
        return self.CopperIconPath.AssetPathName;
    end

    return nil;
end

------------------------------------------------------------其他接口------------------------------------------------------------
--判断是否处于PIE环境下
--生效范围：客户端&&服务端
---@return boolean
function RankingListComponent:IsPIE()
    local PlayerController = self:GetOwner();
    return UGCBlueprintFunctionLibrary.IsUGCPIE(PlayerController);
end

--发放排名奖励物资
--生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@param RankID number
function RankingListComponent:AddRankListAwards(PlayerController, RankID)
    if UE.IsValid(self:GetRankingListGlobalActor()) then
        self:GetRankingListGlobalActor():ClaimRankListAward(PlayerController, RankID);
    end
end

--发放排名奖励物资回调
--生效范围：客户端&&服务端
---@param Success boolean
function RankingListComponent:AddRankListAwardsDelegate(RankID, Success)
    print(string.format("[RankingListComponent] AddRankListAwardsDelegate RankID: %d Success: %s", RankID or 0, tostring(Success or false)));
    if self:GetOwner():HasAuthority() == false then
        if Success then
            local PC = UGCGameSystem.GetLocalPlayerController();
            local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
            if UE.IsValid(RankingListGlobalActor) and UE.IsValid(PC) then
                local State = RankingListGlobalActor:CanClaimRankListAward(PC, RankID);
                if self.RedPointState then
                    self.RedPointState[RankID] = State == UGCRankingListAwardState.CanSign;
                else
                    self.RedPointState = {
                        [RankID] = State == UGCRankingListAwardState.CanSign;
                    }
                end
            end
            self.ShowRedPoint = false;
            for RankID, State in pairs(self.RedPointState) do
                if State then
                    self.ShowRedPoint = true;
                    break;
                end
            end
            self:RefreshAllRedPoint(RankID);
        end
    end
    RankingListManager.OnAddAwardsDelegate(Success);
end

--拉取上榜的排行数据
--生效范围：客户端&&服务端
function RankingListComponent:RequestTopRankingListData()
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == true then
        self:Server_RequestAllRankListData(PlayerController);
    else
        UnrealNetwork.CallUnrealRPC(PlayerController, self, "Server_RequestAllRankListData", PlayerController);
    end
end

--拉取上榜的排行数据
--生效范围：客户端&&服务端
---@param RankID number
---@param StartIdx number
---@param Count number
---@param RankingCycles number
function RankingListComponent:RequestRankingListDataByRankID(RankID, StartIdx, Count, RankingCycles)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == true then
        self:Server_RequestRankListData(PlayerController, RankID, StartIdx, Count, RankingCycles);
    else
        UnrealNetwork.CallUnrealRPC(PlayerController, self, "Server_RequestRankListData", RankID, StartIdx, Count, RankingCycles);
    end
end

function RankingListComponent:GetVirtualItemManager()
    if self.VirtualItemManager == nil and UGCGamePartSystem.IsGamePartLoaded("VirtualItemManager") then
        self.VirtualItemManager = UGCGamePartSystem.GetGamePartGlobalActor("VirtualItemManager");
    end
    return self.VirtualItemManager;
end

function RankingListComponent:GetRankingListPlayerComponent()
    if self.RankingListPlayerComponent == nil and UGCGamePartSystem.IsGamePartLoaded("RankingListManager") then
        self.RankingListPlayerComponent = UGCGamePartSystem.GetGamePartPlayerComponent("RankingListManager", self:GetOwner(), "RankingList");
    end
    return self.RankingListPlayerComponent;
end

function RankingListComponent:GetRankingListGlobalActor()
    if self.RankingListGlobalActor == nil and UGCGamePartSystem.IsGamePartLoaded("RankingListManager") then
        self.RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    end
    return self.RankingListGlobalActor;
end

function RankingListComponent:UpdateShowRankData(RankID, RankingCycles)
    print(string.format("[RankingListComponent] UpdateShowRankData RankID: %d RankingCycles: %d", RankID or -1, RankingCycles or -1));
    if self.RankingListMainUI and self.RankingListMainUI:GetVisibility() ~= ESlateVisibility.Collapsed then
        self.RankingListMainUI:RefreshRankData(RankID, RankingCycles);
    end
end

function RankingListComponent:GetRedPointState()
    self.ShowRedPoint = false;
    if self.RedPointState == nil then
        self.RedPointState = {};
    end
    local RankList = RankingListManager:GetRankingListTableData();
    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    local PC = self:GetOwner()
    if UE.IsValid(RankingListGlobalActor) and UE.IsValid(PC) then
        for Idx, RankConfigData in pairs(RankList) do
            local RankID = RankConfigData.ID;
            local State = RankingListGlobalActor:CanClaimRankListAward(PC, RankID);
            self.RedPointState[RankID] = State == UGCRankingListAwardState.CanSign;
            if self.ShowRedPoint == false and self.RedPointState[RankID] then
                self.ShowRedPoint = true;
            end
        end
    end
    print_dev("RankingListComponent:GetRedPointState ShowRedPoint:"..tostring(self.ShowRedPoint))
    log_tree_dev("RankingListComponent:GetRedPointState RedPointState", self.RedPointState)
    return self.ShowRedPoint, self.RedPointState;
end

function RankingListComponent:UpdateShowPlayerRankData(RankID, RankingCycles)
    print(string.format("[RankingListComponent] UpdateShowPlayerRankData RankID: %d RankingCycles: %d", RankID or -1, RankingCycles or -1));
    if self.RankingListMainUI and self.RankingListMainUI:GetVisibility() ~= ESlateVisibility.Collapsed then
        self.RankingListMainUI:RefreshPlayerRankData(RankID, RankingCycles);
    end
    local RankConfigData = RankingListManager:GetRankConfigData(RankID);
    if RankConfigData then
        if (RankConfigData.PeriodType == ERankListPeriodType.NotReset and RankingCycles == 0) or
            (RankConfigData.PeriodType ~= ERankListPeriodType.NotReset and RankingCycles == 1) then
            local PC = UGCGameSystem.GetLocalPlayerController();
            local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
            if UE.IsValid(RankingListGlobalActor) and UE.IsValid(PC) then
                local State = RankingListGlobalActor:CanClaimRankListAward(PC, RankID);
                if self.RedPointState then
                    self.RedPointState[RankID] = State == UGCRankingListAwardState.CanSign;
                else
                    self.RedPointState = {
                        [RankID] = State == UGCRankingListAwardState.CanSign;
                    }
                end
            end
            self.ShowRedPoint = false;
            for RankID, State in pairs(self.RedPointState) do
                if State then
                    self.ShowRedPoint = true;
                    break;
                end
            end
            self:RefreshAllRedPoint(RankID);
        end
    end
end

function RankingListComponent:UpdateProfileData(RankID)
    print(string.format("[RankingListComponent] UpdateProfileData RankID: %d", RankID or -1));
    if self.RankingListMainUI and self.RankingListMainUI:GetVisibility() ~= ESlateVisibility.Collapsed then
        self.RankingListMainUI:RefreshProfileData(RankID);
    end
end

return RankingListComponent
