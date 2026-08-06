---@class UGC_DailyTask_UIBP_C:UUserWidget
---@field ActivityText UTextBlock
---@field Button_dailyTask UNewButton
---@field Button_WeeklyTask UNewButton
---@field CanvasPanel_TreasureChest_Bar UCanvasPanel
---@field DailyTaskList UGC_ReuseList2_C
---@field Image_Daily_RedPoint UImage
---@field Image_WeeklyTask_RedPoint UImage
---@field NewButton_GetQuick UNewButton
---@field NewButton_grey UNewButton
---@field ScaleBox_IPX UScaleBox
---@field ShopEmptyInfo UCanvasPanel
---@field ShopEmptyInfoText UTextBlock
---@field Task_Item UGC_ReuseList2_C
---@field Text_GrowingActivityDescription UTextBlock
---@field TextBlock_18 UTextBlock
---@field TextBlock_GrowingTitle UTextBlock
---@field UGC_DailyTask_BigBox_UIBP UGC_DailyTask_BigBox_UIBP_C
---@field WidgetSwitcher_dailyTask UWidgetSwitcher
---@field WidgetSwitcher_GetQuick UWidgetSwitcher
---@field WidgetSwitcher_ReuseList UWidgetSwitcher
---@field WidgetSwitcher_TaskMode UWidgetSwitcher
---@field WidgetSwitcher_WeeklyTask UWidgetSwitcher
--Edit Below--
local UGC_DailyTask_UIBP = { bInitDoOnce = false } 

local TaskStatePriority = {
    [EUGCTaskState.NotClaimed] = 1,
    [EUGCTaskState.Incomplete] = 2,
    [EUGCTaskState.HasClaimed] = 3,
    [EUGCTaskState.Expired] = 4,
}

function UGC_DailyTask_UIBP:Construct()
	self.WidgetSwitcher_TaskMode:SetActiveWidgetIndex(1);
    self.DailyTaskList.OnUpdateItem:Add(self.InitPercentTaskItem, self);
    self.Task_Item.OnUpdateItem:Add(self.InitPercentAwardItem, self);
    self.NewButton_GetQuick.OnClicked:Add(self.ClaimAllAward, self);
end

function UGC_DailyTask_UIBP:InitPercentTaskItem(Item, Index)
    self.TaskItem[Index + 1] = Item;
    local TaskID = self.TaskList[Index + 1].TaskID;
    local Idx = self.TaskList[Index + 1].Index;
    Item:InitUI(TaskID, Idx, self.TaskLineName);
end

function UGC_DailyTask_UIBP:InitPercentAwardItem(Item, Index)
    self.TaskLineAwardItem[Index + 1] = Item;
    Item:InitUI(Index + 1, self.TaskLineName);
end

function UGC_DailyTask_UIBP:ClaimAllAward()
    ---领取可领取的任务/任务线奖励
    TaskManager:ClaimAllAward(self.TaskLineName);
end

-- function UGC_DailyTask_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_DailyTask_UIBP:Destruct()
    self.DailyTaskList.OnUpdateItem:RemoveAll();
    self.Task_Item.OnUpdateItem:RemoveAll();
    self.NewButton_GetQuick.OnClicked:RemoveAll();
end

--- 检查是否有奖励可领取
function UGC_DailyTask_UIBP:CheckAwardCanClaim()
    local TaskInfoList = TaskManager:GetPercentTaskInfoList(self.TaskLineName);
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    local CanClaim = false;
    if TaskInfoList and TaskLineConfig then
        if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
            for Index, LevelInfo in pairs(TaskInfoList) do
                ---判断任务奖励是否可领取
                for Idx, TaskInfo in pairs(LevelInfo.TaskInfoList) do
                    if TaskInfo.TaskState == EUGCTaskState.NotClaimed then
                        CanClaim = true;
                        break;
                    end
                end
                ---判断任务线奖励是否可领取
                if LevelInfo.AwardState == EUGCTaskLineAwardState.NotClaimed then
                    CanClaim = true;
                    break;
                end
            end
        elseif TaskLineConfig.TaskLineType == EUGCTaskLineType.PercentTaskLine then
            ---判断任务奖励是否可领取
            for Idx, TaskInfo in pairs(TaskInfoList) do
                if TaskInfo.TaskState == EUGCTaskState.NotClaimed then
                    CanClaim = true;
                    break;
                end
            end
            ---判断任务线奖励是否可领取
            local AwardStateList = TaskManager:GetPercentTaskLineAwardStateList(self.TaskLineName);
            log_tree("[UGC_Task_TabBut_UIBP:RefreshRedPoint] AwardStateList", AwardStateList);
            if AwardStateList then
                for Idx, AwardInfo in pairs(AwardStateList) do
                    if AwardInfo.AwardState == EUGCTaskLineAwardState.NotClaimed then
                        CanClaim = true;
                        break;
                    end
                end
            end
        end
    end

    if CanClaim then
        self.WidgetSwitcher_GetQuick:SetActiveWidgetIndex(0);
    else
        self.WidgetSwitcher_GetQuick:SetActiveWidgetIndex(1);
    end
end

function UGC_DailyTask_UIBP:InitUI(TaskLineName)
    self.TaskLineName = TaskLineName;
    self.TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName):Copy();
    if self.TaskLineConfig then
        log_tree("[UGC_DailyTask_UIBP:InitUI] TaskLineConfig", self.TaskLineConfig);
        self.PercentItemID = self.TaskLineConfig.ItemID;
        ---重置类型
        if self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.NotReset or self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.DailyReset then
            ---当前活跃度
            self.CurPercentNum = TaskManager:GetTaskLineProgress(TaskLineName);
            self.ActivityText:SetText(tostring(self.CurPercentNum));
            self.CanvasPanel_TreasureChest_Bar:SetVisibility(ESlateVisibility.Visible);
            self.UGC_DailyTask_BigBox_UIBP:SetMode(true);
            self.TextBlock_18:SetText("日常任务");

            local PercentAwardNum = self.TaskLineConfig.PercentAwardList:Num();
            print(string.format("[UGC_DailyTask_UIBP:InitUI] PercentAwardNum: %d", PercentAwardNum));
            self.TaskLineAwardItem = {};
            self.Task_Item:Reload(PercentAwardNum);
        elseif self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.WeeklyReset then
            self.CanvasPanel_TreasureChest_Bar:SetVisibility(ESlateVisibility.Collapsed);
            self.UGC_DailyTask_BigBox_UIBP:SetMode(false);
            self.UGC_DailyTask_BigBox_UIBP:InitUI(TaskLineName);
            self.TextBlock_18:SetText("周任务");
        end
        self:RefreshTask();
    end
end

function UGC_DailyTask_UIBP:RefreshTask()
    self.TaskList = {};
    local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
    local TaskInfoList = TaskManager:GetPercentTaskInfoList(self.TaskLineName);
    if TaskInfoList then
        for Index, TaskInfo in pairs(TaskInfoList) do
            local TaskID = TaskInfo.TaskID;
            local Priority = self:GetTaskPriority(TaskID);
            local BeginTimeStamp = TaskManager:GetTaskBeginTime(TaskID);
            local EndTimeStamp = TaskManager:GetTaskEndTime(TaskID);
            print(string.format("[UGC_DailyTask_UIBP:RefreshTask] TaskID: %d CurTimeStamp: %d BeginTimeStamp: %d EndTimeStamp: %d", TaskID, CurTimeStamp, BeginTimeStamp, EndTimeStamp));
            if CurTimeStamp >= BeginTimeStamp and CurTimeStamp <= EndTimeStamp then
                table.insert(self.TaskList, {TaskID = TaskID, Index = Index, Priority = Priority, TaskState = TaskInfo.TaskState});
            elseif CurTimeStamp > EndTimeStamp then
                local IsShowOutDate = TaskManager:GetTaskIsShowOutDate(TaskID);
                print(string.format("[UGC_DailyTask_UIBP:RefreshTask] IsShowOutDate: %s", tostring(IsShowOutDate)));
                if IsShowOutDate then
                    table.insert(self.TaskList, {TaskID = TaskID, Index = Index, Priority = Priority, TaskState = TaskInfo.TaskState});
                end
            end
        end
    end
    -- 可领取 > 未完成 > 已领取 > 已过期
    ---按优先级对任务进行排序
    table.sort(self.TaskList, function(A, B)
        if A.TaskState == B.TaskState then
            return A.Priority > B.Priority;
        else
            return TaskStatePriority[A.TaskState] < TaskStatePriority[B.TaskState];
        end
    end)
    self.TaskItem = {};
    self.DailyTaskList:Reload(#self.TaskList);
    log_tree("[UGC_DailyTask_UIBP:RefreshTask] TaskList", self.TaskList);
    self:CheckAwardCanClaim();
end

function UGC_DailyTask_UIBP:GetTaskPriority(TaskID)
    if self.TaskPriority == nil then
        self.TaskPriority = {};
        for Index, PercentTaskConfig in pairs(self.TaskLineConfig.PercentTaskLineConfig) do
            ---这里得判断一下任务是否存在，否则任务顺序会全部错乱
            local TaskID = PercentTaskConfig.PercentTaskID;
            local Priority = PercentTaskConfig.Priority;
            self.TaskPriority[TaskID] = Priority;
        end
    end

    if self.TaskPriority[TaskID] then
        return self.TaskPriority[TaskID];
    else
        return 0;
    end
end

function UGC_DailyTask_UIBP:UpdateTaskInfo(TaskID, PercentTaskIndex)
    print(string.format("[UGC_DailyTask_UIBP:UpdateTaskInfo] TaskID: %d PercentTaskIndex: %d", TaskID, PercentTaskIndex));
    self:RefreshTask();
    -- ---活跃任务会根据优先级排序，所以这里的索引不是实际Item的索引
    -- local TaskState = TaskManager:GetPercentTaskState(self.TaskLineName, PercentTaskIndex);
    -- if TaskState == EUGCTaskState.Expired then
    --     ---刷新Item
    -- else
    --     local IsExist = false;
    --     local Index = 0;
    --     for Idx, Data in pairs(self.TaskList) do
    --         if Data.Index == PercentTaskIndex then
    --             IsExist = true;
    --             Index = Idx;
    --         end
    --     end
    --     if IsExist then
    --         if self.TaskItem[Index] then
    --             self.TaskItem[Index]:UpdateTaskInfo(TaskID);
    --         end
    --         self:CheckAwardCanClaim();
    --     else
    --         ---刷新Item
    --         self:RefreshTask();
    --     end
    -- end
end

function UGC_DailyTask_UIBP:UpdateTaskLineAwardInfo(Index)
    print(string.format("[UGC_DailyTask_UIBP:UpdateTaskLineAwardInfo] Index: %s", Index));
    if self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.NotReset or self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.DailyReset then
        if self.TaskLineAwardItem and self.TaskLineAwardItem[Index] then
            self.TaskLineAwardItem[Index]:UpdateTaskLineAwardInfo();
        end
    elseif self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.WeeklyReset then
        self.UGC_DailyTask_BigBox_UIBP:UpdateTaskLineAwardInfo(Index);
    end
    self:CheckAwardCanClaim();
end

function UGC_DailyTask_UIBP:UpdateTaskLineProgress()
    ---重置类型
    if self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.NotReset or self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.DailyReset then
        ---当前活跃度
        self.CurPercentNum = TaskManager:GetTaskLineProgress(self.TaskLineName);
        self.ActivityText:SetText(tostring(self.CurPercentNum));
    elseif self.TaskLineConfig.ResetType == EUGCPercentTaskResetType.WeeklyReset then
        self.UGC_DailyTask_BigBox_UIBP:UpdateTaskLineProgress();
    end
end

function UGC_DailyTask_UIBP:SignWeeklyResetTaskLine()
    self.UGC_DailyTask_BigBox_UIBP:SignAward();
end

return UGC_DailyTask_UIBP
