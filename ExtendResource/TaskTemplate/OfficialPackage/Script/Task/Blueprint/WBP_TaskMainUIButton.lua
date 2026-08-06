---@class WBP_TaskMainUIButton_C:UUserWidget
---@field LevelIndex UEditableTextBox
---@field OpenMainUI UButton
---@field ResetPercentTaskLineBtn UButton
---@field TaskIndex UEditableTextBox
---@field TaskLineName UEditableTextBox
---@field TaskLineProgress UEditableTextBox
---@field TaskProgress UEditableTextBox
---@field UpdateTaskLineProgressBtn UButton
---@field UpdateTaskProgressBtn UButton
--Edit Below--
local WBP_TaskMainUIButton = { bInitDoOnce = false } 

function WBP_TaskMainUIButton:Construct()
    self.OpenMainUI.OnClicked:Add(self.OpenTaskMainUI, self);
    self.UpdateTaskLineProgressBtn.OnClicked:Add(self.UpdateTaskLineProgress, self);
    self.ResetPercentTaskLineBtn.OnClicked:Add(self.ResetPercentTaskLine, self);
    self.UpdateTaskProgressBtn.OnClicked:Add(self.UpdateTaskProgress, self);
end

function WBP_TaskMainUIButton:OpenTaskMainUI()
    print("WBP_TaskMainUIButton:OpenTaskMainUI");
    TaskManager:OpenTaskMainUI();
end

function WBP_TaskMainUIButton:UpdateTaskLineProgress()
    local TaskLineName = self.TaskLineName.Text;
    local TaskLineProgress = tonumber(self.TaskLineProgress.Text);
    print(string.format("[WBP_TaskMainUIButton:UpdateTaskLineProgress] TaskLineName: %s TaskLineProgress: %d", TaskLineName, TaskLineProgress));
    TaskManager:SetTaskLineProgress(TaskLineName, TaskLineProgress);
end

function WBP_TaskMainUIButton:ResetPercentTaskLine()
    local TaskLineName = self.TaskLineName.Text;
    print(string.format("[WBP_TaskMainUIButton:ResetPercentTaskLine] TaskLineName: %s", TaskLineName));
    TaskManager:ResetPercentTaskLine(TaskLineName);
end

function WBP_TaskMainUIButton:UpdateTaskProgress()
    local TaskProgress = tonumber(self.TaskProgress.Text);
    local TaskIndex = {
        TaskLineName = self.TaskLineName.Text,
        PercentTaskIndex = tonumber(self.Taskindex.Text),
        LevelTaskLevelIndex = tonumber(self.LevelIndex.Text),
        LevelTaskIndex = tonumber(self.Taskindex.Text),
    };
    local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
    log_tree("[WBP_TaskMainUIButton:UpdateTaskProgress] TaskIndex", TaskIndex);
    print(string.format("[WBP_TaskMainUIButton:UpdateTaskProgress] TaskProgress: %s", TaskProgress));
    TaskManager:UpdateTaskProgress(TaskIndex, PlayerController, TaskProgress);
end

-- function WBP_TaskMainUIButton:Tick(MyGeometry, InDeltaTime)

-- end

function WBP_TaskMainUIButton:Destruct()
    self.OpenMainUI.OnClicked:RemoveAll();
    self.UpdateTaskLineProgressBtn.OnClicked:RemoveAll();
    self.ResetPercentTaskLineBtn.OnClicked:RemoveAll();
    self.UpdateTaskProgressBtn.OnClicked:RemoveAll();
end

return WBP_TaskMainUIButton