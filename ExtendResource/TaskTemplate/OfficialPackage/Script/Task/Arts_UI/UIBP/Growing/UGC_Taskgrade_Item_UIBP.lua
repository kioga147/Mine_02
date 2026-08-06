---@class UGC_Taskgrade_Item_UIBP_C:UUserWidget
---@field Button_Daily_Get UNewButton
---@field Button_Daily_Go UNewButton
---@field Button_DailyExpired UNewButton
---@field Button_DailyNotUnlocked UNewButton
---@field Button_DailyReceived UNewButton
---@field Button_Unfinished UNewButton
---@field Image_Fengexian03 UImage
---@field itemBox UHorizontalBox
---@field Text_LevelDetails UTextBlock
---@field Text_tips2 UTextBlock
---@field TextBlock_NotUnlocked UTextBlock
---@field Textschedule UTextBlock
---@field UGC_DailyTask_Award_01 UGC_DailyTask_Award_UIBP_C
---@field UGC_DailyTask_Award_02 UGC_DailyTask_Award_UIBP_C
---@field WidgetSwitcher_PromptNotReached UWidgetSwitcher
---@field WidgetSwitcher_TaskBut UWidgetSwitcher
--Edit Below--
local UGC_Taskgrade_Item_UIBP = { bInitDoOnce = false } 

function UGC_Taskgrade_Item_UIBP:Construct()
	self.Button_Daily_Get.OnClicked:Add(self.SignAward, self);
    self.Button_Daily_Go.OnClicked:Add(self.GotoTask, self);
end

function UGC_Taskgrade_Item_UIBP:SignAward()
    print(string.format("[UGC_Taskgrade_Item_UIBP:SignAward] TaskLineName: %s LevelIndex: %d TaskIndex: %d", self.TaskLineName, self.LevelIndex, self.TaskIndex));
    TaskManager:ClaimLevelTaskAward(self.TaskLineName, self.LevelIndex, self.TaskIndex);
end

function UGC_Taskgrade_Item_UIBP:GotoTask()
    ---TODO: 开发者自己扩展

end

-- function UGC_Taskgrade_Item_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_Taskgrade_Item_UIBP:Destruct()
	self.Button_Daily_Get.OnClicked:RemoveAll();
    self.Button_Daily_Go.OnClicked:RemoveAll();
end

function UGC_Taskgrade_Item_UIBP:InitUI(TaskID, LevelIndex, TaskIndex, TaskLineName)
    print("[UGC_Taskgrade_Item_UIBP:InitUI]");
    self.TaskID = TaskID;
    self.LevelIndex = LevelIndex;
    self.TaskIndex = TaskIndex;
    self.TaskLineName = TaskLineName;
    local TaskDesc = TaskManager:GetTaskDesc(TaskID);
    print(TaskDesc);
    self.Text_LevelDetails:SetText(tostring(TaskDesc));
    local Progress = TaskManager:GetLevelTaskProgress(TaskLineName, LevelIndex, TaskIndex);
    local Target = TaskManager:GetTaskTarget(TaskID);
    self.Textschedule:SetText(string.format("(%d/%d)", Progress, Target));

    local AwardList = TaskManager:GetTaskAwardList(TaskID);
    local AwardListNum = #AwardList;
    if AwardListNum == 0 then
        self.UGC_DailyTask_Award_01:SetVisibility(ESlateVisibility.Collapsed);
        self.UGC_DailyTask_Award_02:SetVisibility(ESlateVisibility.Collapsed);
    elseif AwardListNum == 1 then
        self.UGC_DailyTask_Award_01:SetVisibility(ESlateVisibility.Visible);
        self.UGC_DailyTask_Award_02:SetVisibility(ESlateVisibility.Collapsed);
        self.UGC_DailyTask_Award_01:InitUI(AwardList[1].ItemID, AwardList[1].ItemNum);
    elseif AwardListNum >= 2 then
        self.UGC_DailyTask_Award_01:SetVisibility(ESlateVisibility.Visible);
        self.UGC_DailyTask_Award_02:SetVisibility(ESlateVisibility.Visible);
        self.UGC_DailyTask_Award_01:InitUI(AwardList[1].ItemID, AwardList[1].ItemNum);
        self.UGC_DailyTask_Award_02:InitUI(AwardList[2].ItemID, AwardList[2].ItemNum);
    end

    local TaskConfig = TaskManager:GetTaskConfig(TaskID);
    if TaskConfig then
        self.IsShowGotoBtn = TaskConfig.IsShowGotoBtn;
    end
    local State = TaskManager:GetLevelTaskState(TaskLineName, LevelIndex, TaskIndex);
    self:SetTaskState(State);

    self.WidgetSwitcher_PromptNotReached:SetActiveWidgetIndex(0);
end

function UGC_Taskgrade_Item_UIBP:HideTask()
    self.WidgetSwitcher_PromptNotReached:SetActiveWidgetIndex(1);
end

function UGC_Taskgrade_Item_UIBP:SetTaskState(TaskState)
    print(string.format("[UGC_Taskgrade_Item_UIBP:SetTaskState] LevelIndex: %d TaskIndex: %d TaskState: %d", self.LevelIndex or 0, self.TaskIndex or 0, TaskState or 0));
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

function UGC_Taskgrade_Item_UIBP:UpdateTaskInfo(TaskID)
    print(string.format("[UGC_Taskgrade_Item_UIBP:UpdateTaskInfo] UpdateTaskID: %d TaskID: %d", TaskID or 0, self.TaskID or 0));
    if TaskID == self.TaskID then
        local Progress = TaskManager:GetLevelTaskProgress(self.TaskLineName, self.LevelIndex, self.TaskIndex);
        local Target = TaskManager:GetTaskTarget(TaskID);
        self.Textschedule:SetText(string.format("(%d/%d)", Progress, Target));
        local State = TaskManager:GetLevelTaskState(self.TaskLineName, self.LevelIndex, self.TaskIndex);
        self:SetTaskState(State);
    else
        print(string.format("[UGC_Taskgrade_Item_UIBP:UpdateTaskInfo] UpdateTaskID: %d TaskID: %d", TaskID or 0, self.TaskID or 0));
    end
end

return UGC_Taskgrade_Item_UIBP