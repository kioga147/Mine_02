---@class UGC_Task_TabBut_UIBP_C:UUserWidget
---@field Button_Select UNewButton
---@field CanvasPanel_TeamReward UCanvasPanel
---@field Image_RedPoint UImage
---@field TextBlock_But UTextBlock
---@field TextBlock_ButSelect UTextBlock
---@field WidgetSwitcher_TaskBut UWidgetSwitcher
--Edit Below--
local UGC_Task_TabBut_UIBP = { bInitDoOnce = false } 

function UGC_Task_TabBut_UIBP:Construct()
    self:InitBindEvent();
end

function UGC_Task_TabBut_UIBP:InitBindEvent()
    self.Button_Select.OnClicked:Add(self.SelectTaskLine, self);
end

function UGC_Task_TabBut_UIBP:SelectTaskLine()
    print(string.format("[UGC_Task_TabBut_UIBP:SelectTaskLine] Index: %d", self.Index));
    TaskManager:SelectTaskLine(self.Index);
end

function UGC_Task_TabBut_UIBP:Select()
    print(string.format("[UGC_Task_TabBut_UIBP:Select] Index: %d", self.Index));
    self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(1);
end

function UGC_Task_TabBut_UIBP:UnSelect()
    print(string.format("[UGC_Task_TabBut_UIBP:UnSelect] Index: %d", self.Index));
    self.WidgetSwitcher_TaskBut:SetActiveWidgetIndex(0);
end

function UGC_Task_TabBut_UIBP:InitUI(Index, TaskLineName)
    self.Index = Index;
    self.TaskLineName = TaskLineName;
    self.TextBlock_But:SetText(self.TaskLineName);
    self.TextBlock_ButSelect:SetText(self.TaskLineName);
    self:RefreshRedPoint();
end

-- function UGC_Task_TabBut_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_Task_TabBut_UIBP:Destruct()
    self.Button_Select.OnClicked:RemoveAll();
end

function UGC_Task_TabBut_UIBP:RefreshRedPoint()
    print(string.format("[UGC_Task_TabBut_UIBP:RefreshRedPoint] TaskLineName: %s", self.TaskLineName));
    log_tree("[UGC_Task_TabBut_UIBP:RefreshRedPoint] TaskInfoList", TaskInfoList);
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    local ShowRedPoint = false;
    if TaskLineConfig then
        if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
            local TaskInfoList = TaskManager:GetLevelTaskInfoList(self.TaskLineName);
            if TaskInfoList then
                for Index, LevelInfo in pairs(TaskInfoList) do
                    ---判断任务奖励是否可领取
                    for Idx, TaskInfo in pairs(LevelInfo.TaskInfoList) do
                        if TaskInfo.TaskState == EUGCTaskState.NotClaimed then
                            ShowRedPoint = true;
                            break;
                        end
                    end
                    ---判断任务线奖励是否可领取
                    if LevelInfo.AwardState == EUGCTaskLineAwardState.NotClaimed then
                        ShowRedPoint = true;
                        break;
                    end
                end
            end
        elseif TaskLineConfig.TaskLineType == EUGCTaskLineType.PercentTaskLine then
            local TaskInfoList = TaskManager:GetPercentTaskInfoList(self.TaskLineName);
            if TaskInfoList then
                ---判断任务奖励是否可领取
                for Idx, TaskInfo in pairs(TaskInfoList) do
                    if TaskInfo.TaskState == EUGCTaskState.NotClaimed then
                        ShowRedPoint = true;
                        break;
                    end
                end
            end
            ---判断任务线奖励是否可领取
            local AwardStateList = TaskManager:GetPercentTaskLineAwardStateList(self.TaskLineName);
            log_tree("[UGC_Task_TabBut_UIBP:RefreshRedPoint] AwardStateList", AwardStateList);
            if AwardStateList then
                for Idx, AwardInfo in pairs(AwardStateList) do
                    if AwardInfo.AwardState == EUGCTaskLineAwardState.NotClaimed then
                        ShowRedPoint = true;
                        break;
                    end
                end
            end
        end
    end

    if ShowRedPoint then
        self.Image_RedPoint:SetVisibility(ESlateVisibility.Visible);
    else
        self.Image_RedPoint:SetVisibility(ESlateVisibility.Collapsed);
    end
end

return UGC_Task_TabBut_UIBP