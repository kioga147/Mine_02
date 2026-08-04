---@class TaskTemplateComponent_C:ActorComponent
---@field TaskMainUIPath FSoftClassPath
---@field TaskItemGetUIPath FSoftClassPath
---@field TaskItemTipUIPath FSoftClassPath
---@field CopperBoxIconPath01 FSoftObjectPath
---@field CopperBoxIconPath02 FSoftObjectPath
---@field CopperBoxIconPath03 FSoftObjectPath
---@field SilverBoxIconPath01 FSoftObjectPath
---@field SilverBoxIconPath02 FSoftObjectPath
---@field SilverBoxIconPath03 FSoftObjectPath
---@field GoldBoxIconPath01 FSoftObjectPath
---@field GoldBoxIconPath02 FSoftObjectPath
---@field GoldBoxIconPath03 FSoftObjectPath
---@field TaskBoxAwadListUIPath FSoftClassPath
---@field LevelTaskLineUIPath FSoftClassPath
---@field PercentTaskLineUIPath FSoftClassPath
---@field TaskTemplateConfig UDataTable
--Edit Below--

UGCGameSystem.UGCRequire("ExtendResource.TaskTemplate.OfficialPackage." .. "Script.Task.TaskManager");
UGCGameSystem.UGCRequire("ExtendResource.TaskTemplate.OfficialPackage." .. "Script.Common.Common");

local TaskTemplateComponent = {
    RequestMark = "Task"
}

function TaskTemplateComponent:ReceiveBeginPlay()
    TaskTemplateComponent.SuperClass.ReceiveBeginPlay(self);
    local PlayerController = self:GetOwner();
    TaskManager:RegisterComponentClass(GameplayStatics.GetObjectClass(self));


    local PromiseFuture = require("common.PromiseFuture")
    print_dev("TaskTemplateComponent:ReceiveBeginPlay Check GamePart Dependency Start")
    if PlayerController:HasAuthority() == false then
        self:PreLoad(PlayerController);
        PromiseFuture.New():Set(
            function (PromiseFuture)
                while not self:CheckGamePartDependency() do
                    PromiseFuture:Yield()
                end
                print_dev("TaskTemplateComponent:ReceiveBeginPlay GamePart Init Success")
                if not TaskManager.IsConfigLoaded then
                    self:LoadConfig(self.TaskTemplateConfig)
                end
                self:InitTaskOnClient();
            end
        ):AutoResume(self, 1, 20)
    end
end

--[[
function TaskTemplateComponent:ReceiveTick(DeltaTime)
    TaskTemplateComponent.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

function TaskTemplateComponent:ReceiveEndPlay()
    TaskTemplateComponent.SuperClass.ReceiveEndPlay(self)
    if self:GetOwner():HasAuthority() == true then
    else
        if UE.IsValid(self:GetVirtualItemManager()) then
            self:GetVirtualItemManager().AddItemResultDelegate:Remove(self.OnAddVirtualItem, self);
        end
        if UE.IsValid(self:GetTaskPlayerComponent()) then
            self:GetTaskPlayerComponent().OnTaskInfoChangeDelegate:Remove(self.OnTaskInfoChange, self);
            self:GetTaskPlayerComponent().OnTaskLineAwardInfoChangeDelegate:Remove(self.OnTaskLineAwardInfoChange, self);
            self:GetTaskPlayerComponent().OnTaskLineProgressChangeDelegate:Remove(self.OnTaskLineProgressChange, self);
        end
    end
end

function TaskTemplateComponent:GetReplicatedProperties()
    return;
end

function TaskTemplateComponent:GetAvailableServerRPCs()
    return
end

function TaskTemplateComponent:LoadConfig()
    if self.TaskTemplateConfig == nil then
        print_dev("TaskTemplateComponent:LoadConfig TaskTemplateConfig is Nil")
        return
    end
    TaskManager:LoadConfig(self.TaskTemplateConfig)
end

function TaskTemplateComponent:CheckGamePartDependency()
    if not UGCGamePartSystem.IsGamePartLoaded("VirtualItemManager") then
        print_dev("TaskTemplateComponent:CheckGamePartDependency VirtualItemManager is not Loaded")
        return false
    end

    if not UGCGamePartSystem.IsGamePartLoaded("TaskManager") then
        print_dev("TaskTemplateComponent:CheckGamePartDependency TaskManager is not Loaded")
        return false
    end

    if not UE.IsValid(UGCGamePartSystem.GetGamePartGlobalActor("TaskManager")) then
        print_dev("TaskTemplateComponent:CheckGamePartDependency TaskManagerGlobalActor is InValid")
        return false
    end

    local PC = self:GetOwner()
    if not UE.IsValid(PC) then
        print_dev("TaskTemplateComponent:CheckGamePartDependency PlayerController is InValid")
        return false
    end

    local TaskComp = UGCGamePartSystem.GetGamePartPlayerComponent("TaskManager", PC, "Task")
    if not UE.IsValid(TaskComp) then
        print_dev("TaskTemplateComponent:CheckGamePartDependency TaskManagerPlayerComponent is InValid")
        return false
    end

    if not TaskComp.TaskInited then
        print_dev("TaskTemplateComponent:CheckGamePartDependency TaskManagerPlayerComponent TaskInited is False")
        return false
    end

    return true
end

function TaskTemplateComponent:PreLoad(PlayerController)
    Common.LoadObjectWithSoftPathAsync(self.TaskMainUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.TaskMainUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.TaskMainUI:AddToViewport(10000);
            self.TaskMainUI:SetVisibility(ESlateVisibility.Collapsed);
            if self.LevelTaskLineUI then
                self.TaskMainUI:InitLevelTaskLineUI(self.LevelTaskLineUI);
            end
            if self.PercentTaskLineUI then
                self.TaskMainUI:InitPercentTaskLineUI(self.PercentTaskLineUI);
            end
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.TaskItemGetUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.TaskItemGetUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.TaskItemGetUI:AddToViewport(15000);
            self.TaskItemGetUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.TaskItemTipUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.TaskItemTipUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.TaskItemTipUI:AddToViewport(15000);
            self.TaskItemTipUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.TaskBoxAwadListUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.TaskBoxAwadListUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.TaskBoxAwadListUI:AddToViewport(12000);
            self.TaskBoxAwadListUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.LevelTaskLineUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.LevelTaskLineUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.LevelTaskLineUI:AddToViewport(10000);
            self.LevelTaskLineUI:SetVisibility(ESlateVisibility.Collapsed);
            if self.TaskMainUI then
                self.TaskMainUI:InitLevelTaskLineUI(self.LevelTaskLineUI);
            end
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.PercentTaskLineUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.PercentTaskLineUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.PercentTaskLineUI:AddToViewport(10000);
            self.PercentTaskLineUI:SetVisibility(ESlateVisibility.Collapsed);
            if self.TaskMainUI then
                self.TaskMainUI:InitPercentTaskLineUI(self.PercentTaskLineUI);
            end
        end
    end)
    self.CopperBoxIcon = {};
    self.SilverBoxIcon = {};
    self.GoldBoxIcon = {};
    Common.LoadObjectWithSoftPathAsync(self.CopperBoxIconPath01,
        function (Object)
            self.CopperBoxIcon[1] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload CopperBoxIcon: %s Success!", self.CopperBoxIconPath01.AssetPathName));
        end
    );
    Common.LoadObjectWithSoftPathAsync(self.CopperBoxIconPath02,
        function (Object)
            self.CopperBoxIcon[2] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload CopperBoxIcon: %s Success!", self.CopperBoxIconPath02.AssetPathName));
        end
    );
    Common.LoadObjectWithSoftPathAsync(self.CopperBoxIconPath03,
        function (Object)
            self.CopperBoxIcon[3] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload CopperBoxIcon: %s Success!", self.CopperBoxIconPath03.AssetPathName));
        end
    );

    Common.LoadObjectWithSoftPathAsync(self.SilverBoxIconPath01,
        function (Object)
            self.SilverBoxIcon[1] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload SilverBoxIcon: %s Success!", self.SilverBoxIconPath01.AssetPathName));
        end
    );
    Common.LoadObjectWithSoftPathAsync(self.SilverBoxIconPath02,
        function (Object)
            self.SilverBoxIcon[2] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload SilverBoxIcon: %s Success!", self.SilverBoxIconPath02.AssetPathName));
        end
    );
    Common.LoadObjectWithSoftPathAsync(self.SilverBoxIconPath03,
        function (Object)
            self.SilverBoxIcon[3] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload SilverBoxIcon: %s Success!", self.SilverBoxIconPath03.AssetPathName));
        end
    );

    Common.LoadObjectWithSoftPathAsync(self.GoldBoxIconPath01,
        function (Object)
            self.GoldBoxIcon[1] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload GoldBoxIcon: %s Success!", self.GoldBoxIconPath01.AssetPathName));
        end
    );
    Common.LoadObjectWithSoftPathAsync(self.GoldBoxIconPath02,
        function (Object)
            self.GoldBoxIcon[2] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload GoldBoxIcon: %s Success!", self.GoldBoxIconPath02.AssetPathName));
        end
    );
    Common.LoadObjectWithSoftPathAsync(self.GoldBoxIconPath03,
        function (Object)
            self.GoldBoxIcon[3] = Object;
            print(string.format("[TaskTemplateComponent:PreLoad] Preload GoldBoxIcon: %s Success!", self.GoldBoxIconPath03.AssetPathName));
        end
    );
end

function TaskTemplateComponent:InitTaskOnClient()
    ---GamePart加载完成且任务创建完成
    if self.TaskCreated and self.TaskGamePartLoaded then
        if self.TaskMainUI then
            self.TaskMainUI:InitUI();
        end
    end
end

function TaskTemplateComponent:OnTaskInfoChange(TaskIndex)
    log_tree("[TaskTemplateComponent:OnTaskInfoChange] TaskIndex", TaskIndex);
    if self.TaskMainUI then
        self.TaskMainUI:UpdateTaskInfo(TaskIndex);
        self.TaskMainUI:RefreshRedPoint();
    end
end

function TaskTemplateComponent:OnTaskLineAwardInfoChange(TaskLineName, Index)
    print(string.format("[TaskTemplateComponent:OnTaskLineAwardInfoChange] TaskLineName: %s Index: %d", TaskLineName, Index));
    if self.TaskMainUI then
        self.TaskMainUI:UpdateTaskLineAwardInfo(TaskLineName, Index);
        self.TaskMainUI:RefreshRedPoint();
    end
end

function TaskTemplateComponent:OnTaskLineProgressChange(TaskLineName)
    print(string.format("[TaskTemplateComponent:OnTaskLineProgressChange] TaskLineName: %s", TaskLineName));
    if self.TaskMainUI then
        self.TaskMainUI:UpdateTaskLineProgress(TaskLineName);
    end
end

--生效范围：客户端
function TaskTemplateComponent:OpenTaskMainUI()
    if self.TaskMainUI then
        local PlayerController = self:GetOwner();
        if PlayerController:HasAuthority() == false then
            if UE.IsValid(self:GetVirtualItemManager()) then
                self:GetVirtualItemManager().AddItemResultDelegate:Add(self.OnAddVirtualItem, self);
            end
            if UE.IsValid(self:GetTaskPlayerComponent()) then
                self:GetTaskPlayerComponent().OnTaskInfoChangeDelegate:Add(self.OnTaskInfoChange, self);
                self:GetTaskPlayerComponent().OnTaskLineAwardInfoChangeDelegate:Add(self.OnTaskLineAwardInfoChange, self);
                self:GetTaskPlayerComponent().OnTaskLineProgressChangeDelegate:Add(self.OnTaskLineProgressChange, self);
            end
        end
        self.TaskMainUI:InitUI();
        self.TaskMainUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function TaskTemplateComponent:CloseTaskMainUI()
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == false then
        if UE.IsValid(self:GetVirtualItemManager()) then
            self:GetVirtualItemManager().AddItemResultDelegate:Remove(self.OnAddVirtualItem, self);
        end
        if UE.IsValid(self:GetTaskPlayerComponent()) then
            self:GetTaskPlayerComponent().OnTaskInfoChangeDelegate:Remove(self.OnTaskInfoChange, self);
            self:GetTaskPlayerComponent().OnTaskLineAwardInfoChangeDelegate:Remove(self.OnTaskLineAwardInfoChange, self);
            self:GetTaskPlayerComponent().OnTaskLineProgressChangeDelegate:Remove(self.OnTaskLineProgressChange, self);
        end
    end
    self.TaskMainUI:SetVisibility(ESlateVisibility.Collapsed);
end


--获得道具回调
--生效范围：客户端
function TaskTemplateComponent:OnAddVirtualItem(Result)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == true then
        return;
    end
    print(string.format("[TaskTemplateComponent:OnAddVirtualItem]"));
    local bSucceeded = Result.bSucceeded;
    local ItemList = Result.ItemList;
    local PlayerKey = Result.PlayerKey;
    local RequestMark = Result.RequestMark;
    if bSucceeded then
        local SelfPlayerKey = PlayerController:GetInt64PlayerKey();
        if PlayerKey == SelfPlayerKey and RequestMark == self.RequestMark then
            local AwardList = {};
            for ItemID, ItemNum in pairs(ItemList) do
                table.insert(AwardList, {ItemID = ItemID, ItemNum = ItemNum});
            end
            self:ShowItemGet(AwardList);
        end
        ---刷新红点
        self:RefreshRedPoint();
    end
end

--展示获得到道具
function TaskTemplateComponent:ShowItemGet(ItemList)
    if self:GetOwner():HasAuthority() == true then
        return;
    end
    print("[TaskTemplateComponent:ShowItemGet]");
    if self.TaskItemGetUI then
        self.TaskItemGetUI:InitUI(ItemList);
        self.TaskItemGetUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function TaskTemplateComponent:SelectTaskLine(Index)
    if self.TaskMainUI then
        self.TaskMainUI:SelectTaskLine(Index);
    end
end

function TaskTemplateComponent:GetTaskListByTaskLineName(TaskLine)
    local TaskList = {};
    for Index, Task in pairs(self.AllTaskList) do
        if Task.TaskLine == TaskLine then
            table.insert(TaskList, Task);
        end
    end
    return TaskList;
end

function TaskTemplateComponent:GetItemNum(ItemID)
    if UE.IsValid(self:GetVirtualItemManager()) then
        local PlayerController = self:GetOwner();
        return self:GetVirtualItemManager():GetItemNum(ItemID, PlayerController);
    end
    return 0;
end

function TaskTemplateComponent:ShowItemTip(ItemID, Position)
    self.TaskItemTipUI:InitUI(ItemID, Position);
    self.TaskItemTipUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
end

function TaskTemplateComponent:GetTaskLineConfig(TaskLineName)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskLineConfig(TaskLineName)
    end
    print(string.format("[TaskTemplateComponent:GetTaskLineConfig] TaskMgr Is Nil"));
    return nil;
end

function TaskTemplateComponent:GetLevelTaskInfoList(TaskLineName)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetLevelTaskInfoList(TaskLineName);
    end
    print(string.format("[TaskTemplateComponent:GetLevelTaskInfoList] UGCTaskTemplateController Is Nil"));
    return {};
end

function TaskTemplateComponent:GetPercentTaskInfoList(TaskLineName)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetPercentTaskInfoList(TaskLineName);
    end
    print(string.format("[TaskTemplateComponent:GetPercentTaskInfoList] UGCTaskTemplateController Is Nil"));
    return {};
end

function TaskTemplateComponent:GetPercentTaskLineAwardStateList(TaskLineName)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetPercentTaskLineAwardStateList(TaskLineName);
    end
    print(string.format("[TaskTemplateComponent:GetPercentTaskLineAwardStateList] UGCTaskTemplateController Is Nil"));
    return {};
end

function TaskTemplateComponent:GetTaskLineProgress(TaskLineName)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetTaskLineProgress(TaskLineName);
    end
    print(string.format("[TaskTemplateComponent:GetTaskLineProgress] UGCTaskTemplateController Is Nil"));
    return 0;
end

function TaskTemplateComponent:GetTaskBeginTime(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskBeginTime(TaskID);
    end
    print(string.format("[TaskTemplateComponent:GetTaskBeginTime] TaskMgr Is Nil"));
    return 0;
end

function TaskTemplateComponent:GetTaskEndTime(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskEndTime(TaskID);
    end
    print(string.format("[TaskTemplateComponent:GetTaskEndTime] TaskMgr Is Nil"));
    return 0;
end

function TaskTemplateComponent:GetTaskLineBeginTime(TaskLineName)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskLineBeginTime(TaskLineName);
    end
    print(string.format("[TaskTemplateComponent:GetTaskLineBeginTime] TaskMgr Is Nil"));
    return 0;
end

function TaskTemplateComponent:GetTaskLineEndTime(TaskLineName)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskLineEndTime(TaskLineName);
    end
    print(string.format("[TaskTemplateComponent:GetTaskLineEndTime] TaskMgr Is Nil"));
    return 0;
end

function TaskTemplateComponent:GetTaskIsShowOutDate(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskIsShowOutDate(TaskID);
    end
    print(string.format("[TaskTemplateComponent:GetTaskIsShowOutDate] TaskMgr Is Nil"));
    return false;
end

function TaskTemplateComponent:GetPercentTaskPercent(TaskLineName, TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetPercentTaskPercent(TaskLineName, TaskID);
    end
    print(string.format("[TaskTemplateComponent:GetPercentTaskPercent] TaskMgr Is Nil"));
    return 0;
end

function TaskTemplateComponent:GetTaskDesc(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskDesc(TaskID);
    end
    return "";
end

function TaskTemplateComponent:GetTaskAwardList(TaskID)
    local TaskAwardList = {};
    if UE.IsValid(self:GetTaskManager()) then
        if self:GetTaskManager().TaskConfigMap:Find(TaskID) then
            local AawrdList = self:GetTaskManager().TaskConfigMap[TaskID].TaskAwardList;
            for Idx, Item in pairs(AawrdList) do
                table.insert(TaskAwardList, {ItemID = Item.ItemID, ItemNum = Item.ItemNum});
            end
        end
    end
    return TaskAwardList;
end

function TaskTemplateComponent:ClaimLevelTaskAward(TaskLineName, LevelIndex, TaskIndex)
    print(string.format("[TaskTemplateComponent:ClaimLevelTaskAward]"));
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        self:GetTaskPlayerComponent():ClaimLevelTaskAward(TaskLineName, LevelIndex, TaskIndex)
    end
end

function TaskTemplateComponent:ClaimPercentTaskAward(TaskLineName, TaskIndex)
    print(string.format("[TaskTemplateComponent:ClaimPercentTaskAward]"));
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        self:GetTaskPlayerComponent():ClaimPercentTaskAward(TaskLineName, TaskIndex)
    end
end

function TaskTemplateComponent:GetTaskLineAwardState(TaskLineName, Index)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetTaskLineAwardState(TaskLineName, Index);
    end
    return EUGCTaskLineAwardState.Lock;
end

function TaskTemplateComponent:ClaimTaskLineAward(TaskLineName, Index)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        self:GetTaskPlayerComponent():ClaimTaskLineAward(TaskLineName, Index);
    end
end

function TaskTemplateComponent:RefreshRedPoint()
    if self.TaskMainUI then
        self.TaskMainUI:RefreshRedPoint();
    end
end

function TaskTemplateComponent:GetCopperBoxIcon()
    return self.CopperBoxIcon;
end

function TaskTemplateComponent:GetSilverBoxIcon()
    return self.SilverBoxIcon;
end

function TaskTemplateComponent:GetGoldBoxIcon()
    return self.GoldBoxIcon;
end

function TaskTemplateComponent:GetTaskLineResetTime(TaskLineName)
    if UE.IsValid(self:GetTaskManager()) then
        local TaskLineConfig = self:GetTaskManager():GetTaskLineConfig(TaskLineName);
        if TaskLineConfig then
            return self:GetTaskManager():ComputePercentTaskLineResetTime(TaskLineConfig);
        end
    end
    return 0;
end

function TaskTemplateComponent:ShowBoxAwardList(AwardList)
    if self.TaskBoxAwadListUI then
        self.TaskBoxAwadListUI:InitUI(AwardList);
        self.TaskBoxAwadListUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function TaskTemplateComponent:GetPercentTaskProgress(TaskLineName, Index)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetPercentTaskProgress(TaskLineName, Index);
    end
    return 0;
end

function TaskTemplateComponent:GetPercentTaskState(TaskLineName, Index)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetPercentTaskState(TaskLineName, Index);
    end
    return EUGCTaskState.Lock;
end

function TaskTemplateComponent:GetLevelTaskProgress(TaskLineName, LevelIndex, TaskIndex)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetLevelTaskProgress(TaskLineName, LevelIndex, TaskIndex);
    end
    return 0;
end

function TaskTemplateComponent:GetLevelTaskState(TaskLineName, LevelIndex, TaskIndex)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        return self:GetTaskPlayerComponent():GetLevelTaskState(TaskLineName, LevelIndex, TaskIndex);
    end
    return EUGCTaskState.Lock;
end

function TaskTemplateComponent:GetTaskTarget(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskTarget(TaskID);
    end
    return 0;
end

function TaskTemplateComponent:SetTaskLineProgress(TaskLineName, TaskLineProgress)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        self:GetTaskPlayerComponent():SetTaskLineProgress(TaskLineName, TaskLineProgress);
    end
end

function TaskTemplateComponent:SetLevelItem(TaskLineName, Index, Item)
    if self.TaskMainUI then
        self.TaskMainUI:SetLevelItem(TaskLineName, Index, Item);
    end
end

function TaskTemplateComponent:ShowLevelInfo(TaskLineName, LevelIdx)
    if self.TaskMainUI then
        self.TaskMainUI:ShowLevelInfo(TaskLineName, LevelIdx);
    end
end

function TaskTemplateComponent:SelectLevelItem(TaskLineName, LevelIdx)
    if self.TaskMainUI then
        self.TaskMainUI:SelectLevelItem(TaskLineName, LevelIdx);
    end
end

function TaskTemplateComponent:SignWeeklyResetTaskLine(TaskLineName)
    if self.TaskMainUI then
        self.TaskMainUI:SignWeeklyResetTaskLine(TaskLineName);
    end
end

function TaskTemplateComponent:ResetPercentTaskLine(TaskLineName)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        self:GetTaskPlayerComponent():ResetPercentTaskLine(TaskLineName);
    end
end

function TaskTemplateComponent:ClaimAllAward(TaskLineName)
    if UE.IsValid(self:GetTaskPlayerComponent()) then
        self:GetTaskPlayerComponent():ClaimAllAward(TaskLineName);
    end
end

function TaskTemplateComponent:GetLevelTaskLineSelectIndex()
    if self.LevelTaskLineUI then
        return self.LevelTaskLineUI.SelectLevelIndex;
    end
    return -1;
end

function TaskTemplateComponent:GetTaskType(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskType(TaskID);
    end
    return 0;
end

function TaskTemplateComponent:GetTaskConfig(TaskID)
    if UE.IsValid(self:GetTaskManager()) then
        return self:GetTaskManager():GetTaskConfig(TaskID);
    end
    return nil;
end

function TaskTemplateComponent:UpdateTaskProgress(TaskIndex, PlayerController, TaskProgress)
    if UE.IsValid(self:GetTaskManager()) then
        self:GetTaskManager():UpdateTaskProgress(TaskIndex, PlayerController, TaskProgress);
    end
end

function TaskTemplateComponent:GetVirtualItemManager()
    if self.VirtualItemManager == nil and UGCGamePartSystem.IsGamePartLoaded("VirtualItemManager") then
        self.VirtualItemManager = UGCGamePartSystem.GetGamePartGlobalActor("VirtualItemManager");
    end
    return self.VirtualItemManager;
end

function TaskTemplateComponent:GetTaskManager()
    if self.TaskManagerGlobalActor == nil and UGCGamePartSystem.IsGamePartLoaded("TaskManager") then
        self.TaskManagerGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("TaskManager");
    end
    return self.TaskManagerGlobalActor;
end

function TaskTemplateComponent:GetTaskPlayerComponent()
    if self.TaskManagerPlayerComponent == nil and UGCGamePartSystem.IsGamePartLoaded("TaskManager") then
        self.TaskManagerPlayerComponent = UGCGamePartSystem.GetGamePartPlayerComponent("TaskManager", self:GetOwner(), "Task");
    end
    return self.TaskManagerPlayerComponent;
end

return TaskTemplateComponent
