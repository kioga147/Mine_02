---@class UGC_DailyTask_List_UIBP_C:UUserWidget
---@field Button_Daily_Get UNewButton
---@field Button_Daily_Go UNewButton
---@field Button_DailyExpired UNewButton
---@field Button_DailyNotUnlocked UNewButton
---@field Button_DailyReceived UNewButton
---@field Button_Unfinished UNewButton
---@field DailyTask_ListAward_01 UGC_DailyTask_Award_UIBP_C
---@field DailyTask_ListAward_02 UGC_DailyTask_Award_UIBP_C
---@field FX_SweepLight UImage
---@field TextBlock_DailyTaskDetails UTextBlock
---@field TextBlock_NotUnlocked UTextBlock
---@field TextBlock_TaskNum UTextBlock
---@field TextBlock_TaskTotal UTextBlock
---@field WidgetSwitcher_TaskBut UWidgetSwitcher
--Edit Below--
local UGC_DailyTask_List_UIBP = { bInitDoOnce = false } 

function UGC_DailyTask_List_UIBP:Construct()
    self.TaskAwardItemList = {
        [1] = self.DailyTask_ListAward_01,
        [2] = self.DailyTask_ListAward_02
    }
    self.Button_Daily_Get.OnClicked:Add(self.CliamTaskAward, self);
    self.Button_Daily_Go.OnClicked:Add(self.GotoTask, self);
end

---@param Index number @0: 前往完成任务 1：领取奖励 2：已领取 3：已过期 4：未解锁 5：未完成
function UGC_DailyTask_List_UIBP:SetTaskState(TaskState)
    ---先判断是否过期
    if TaskState == EUGCTaskState.Lock then
        self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(4);
    elseif TaskState == EUGCTaskState.Incomplete then
        if self.IsShowGotoBtn then
            self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(0);
        else
            self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(5);
        end
    elseif TaskState == EUGCTaskState.NotClaimed then
        self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(1);
    elseif TaskState == EUGCTaskState.HasClaimed then
        self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(2);
    elseif TaskState == EUGCTaskState.Expired then
        self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(3);
    end
end

function UGC_DailyTask_List_UIBP:GotoTask()
    ---TODO: 开发者自己扩展

end

-- function UGC_DailyTask_List_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_DailyTask_List_UIBP:Destruct()
    print("[UGC_DailyTask_List_UIBP:Destruct]");
    self.Button_Daily_Get.OnClicked:RemoveAll();
    self.Button_Daily_Go.OnClicked:RemoveAll();
end

function UGC_DailyTask_List_UIBP:CliamTaskAward()
    print(string.format("[UGC_DailyTask_List_UIBP:CliamTaskAward] TaskLineName: %s TaskIndex: %d", self.TaskLineName or "", self.Index or -1));
    ---阻塞，等DS能同步UObject后再完善
    TaskManager:ClaimPercentTaskAward(self.TaskLineName, self.Index);
end

function UGC_DailyTask_List_UIBP:InitUI(TaskID, Index, TaskLineName)
    print(string.format("[UGC_DailyTask_List_UIBP:InitUI] Index: %d TaskLineName: %s", Index or 0, TaskLineName or ""));
    --先清除一下监听，避免Item服用导致监听多个任务
    self.TaskID = TaskID;
    self.TaskLineName = TaskLineName;
    self.Index = Index;
    local TaskDesc = TaskManager:GetTaskDesc(TaskID);
    self.TextBlock_DailyTaskDetails:SetText(TaskDesc);
    self.Percent = TaskManager:GetPercentTaskPercent(TaskLineName, TaskID);
    self.EndTimeStamp = TaskManager:GetTaskEndTime(TaskID);
    local AwardList = TaskManager:GetTaskAwardList(TaskID);
    local AwardListNum = #AwardList;
    if AwardListNum == 0 then
        self.TaskAwardItemList[1]:SetVisibility(ESlateVisibility.Collapsed);
        self.TaskAwardItemList[2]:SetVisibility(ESlateVisibility.Collapsed);
    elseif AwardListNum == 1 then
        self.TaskAwardItemList[1]:SetVisibility(ESlateVisibility.Visible);
        self.TaskAwardItemList[2]:SetVisibility(ESlateVisibility.Collapsed);
        self.TaskAwardItemList[1]:InitUI(AwardList[1].ItemID, AwardList[1].ItemNum);
    elseif AwardListNum >= 2 then
        self.TaskAwardItemList[1]:SetVisibility(ESlateVisibility.Visible);
        self.TaskAwardItemList[2]:SetVisibility(ESlateVisibility.Visible);
        self.TaskAwardItemList[1]:InitUI(AwardList[1].ItemID, AwardList[1].ItemNum);
        self.TaskAwardItemList[2]:InitUI(AwardList[2].ItemID, AwardList[2].ItemNum);
    end

    local Progress = TaskManager:GetPercentTaskProgress(TaskLineName, Index);
    local Target = TaskManager:GetTaskTarget(TaskID);
    local State = TaskManager:GetPercentTaskState(TaskLineName, Index);
    self.TextBlock_TaskNum:SetText(tostring(Progress));
    self.TextBlock_TaskTotal:SetText(tostring(Target));

    local TaskConfig = TaskManager:GetTaskConfig(TaskID);
    if TaskConfig then
        self.IsShowGotoBtn = TaskConfig.IsShowGotoBtn;
    end
    self:SetTaskState(State);
end

-- function UGC_DailyTask_List_UIBP:UpdateTaskProgress(Progress)
--     print(string.format("[UGC_DailyTask_List_UIBP:UpdateTaskProgress] Progress: %d", Progress));
--     self.TextBlock_TaskNum:SetText(tostring(Progress));
-- end

-- function UGC_DailyTask_List_UIBP:UpdateTaskState(State)
--     print(string.format("[UGC_DailyTask_List_UIBP:UpdateTaskState] State: %d", State));
--     self:SetTaskState(State);
--     TaskManager:RefreshRedPoint();
-- end

function UGC_DailyTask_List_UIBP:UpdateTaskInfo(TaskID)
    print(string.format("[UGC_DailyTask_List_UIBP:UpdateTaskInfo] TaskID: %d", TaskID));
    if TaskID == self.TaskID then
        local Progress = TaskManager:GetPercentTaskProgress(self.TaskLineName, self.Index);
        local State = TaskManager:GetPercentTaskState(self.TaskLineName, self.Index);
        self.TextBlock_TaskNum:SetText(tostring(Progress));
        self:SetTaskState(State);
    else
        print(string.format("[UGC_DailyTask_List_UIBP:UpdateTaskInfo] UpdateTaskID: %d TaskID: %d", TaskID or 0, self.TaskID or 0));
    end
end

return UGC_DailyTask_List_UIBP