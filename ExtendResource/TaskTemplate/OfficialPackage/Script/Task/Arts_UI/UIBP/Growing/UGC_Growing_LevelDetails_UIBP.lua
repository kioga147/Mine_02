---@class UGC_Growing_LevelDetails_UIBP_C:UUserWidget
---@field Task_TabMenu UGC_ReuseList2_C
---@field TextBlock_Level UTextBlock
---@field TextBlock_LevelName UTextBlock
--Edit Below--
local UGC_Growing_LevelDetails_UIBP = { bInitDoOnce = false }

function UGC_Growing_LevelDetails_UIBP:Construct()
    self.Task_TabMenu.OnUpdateItem:Add(self.InitItem, self);
end

-- function UGC_Growing_LevelDetails_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_Growing_LevelDetails_UIBP:Destruct()
    self.Task_TabMenu.OnUpdateItem:RemoveAll();
end

function UGC_Growing_LevelDetails_UIBP:InitItem(Item, Index)
    if self.IsShowTask then
        if Index == 0 then
            if Item and Item.Image_Fengexian03 then
                Item.Image_Fengexian03:SetVisibility(ESlateVisibility.Collapsed);
            end
        else
            if Item and Item.Image_Fengexian03 then
                Item.Image_Fengexian03:SetVisibility(ESlateVisibility.Visible);
            end
        end
        Item:InitUI(self.TaskList[Index + 1].TaskID, self.LevelIndex, self.TaskList[Index + 1].Index, self.TaskLineName);
        self.TaskItem[Item] = self.TaskList[Index + 1].Index;
    else
        Item:HideTask();
    end
end

function UGC_Growing_LevelDetails_UIBP:InitUI(TaskLineName, LevelIndex)
    print(string.format("[UGC_Growing_LevelDetails_UIBP:InitUI] TaskLineName: %s LevelIndex: %d", TaskLineName, LevelIndex));
    self.TaskLineName = TaskLineName;
    self.LevelIndex = LevelIndex;
    local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
    if TaskLineConfig then
        self.TextBlock_LevelName:SetText(TaskLineConfig.LevelTaskPropertyName);
        if TaskLineConfig.LevelTaskLineConfig and TaskLineConfig.LevelTaskLineConfig[LevelIndex] then
            local Level = TaskLineConfig.LevelTaskLineConfig[LevelIndex].Level;
            self.TextBlock_Level:SetText(tostring(Level));
            local CurrentLevel = TaskManager:GetTaskLineProgress(TaskLineName);
            if CurrentLevel >= Level then
                self.IsShowTask = true;
                self:RefreshTask();
            else
                self.IsShowTask = false;
                self.Task_TabMenu:Reload(1);
            end
        end
    end
end

function UGC_Growing_LevelDetails_UIBP:RefreshTask()
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    if TaskLineConfig then
        self.TaskList = {};
        self.TaskItem = {};
        local LevelTaskInfoList = TaskManager:GetLevelTaskInfoList(self.TaskLineName);
        if LevelTaskInfoList and LevelTaskInfoList[self.LevelIndex] and LevelTaskInfoList[self.LevelIndex].TaskInfoList then
            local CurTimeStamp = UGCGameSystem.GetServerTimeSec();
            for Index, TaskInfo in pairs(LevelTaskInfoList[self.LevelIndex].TaskInfoList) do
                local TaskID = TaskInfo.TaskID;
                local BeginTimeStamp = TaskManager:GetTaskBeginTime(TaskID);
                local EndTimeStamp = TaskManager:GetTaskEndTime(TaskID);
                if CurTimeStamp >= BeginTimeStamp and CurTimeStamp <= EndTimeStamp then
                    table.insert(self.TaskList, {TaskID = TaskID, Index = Index});
                elseif CurTimeStamp > EndTimeStamp then
                    local IsShowOutDate = TaskManager:GetTaskIsShowOutDate(TaskID);
                    print(string.format("[UGC_Growing_LevelDetails_UIBP:RefreshTask] IsShowOutDate: %s", tostring(IsShowOutDate)));
                    if IsShowOutDate then
                        table.insert(self.TaskList, {TaskID = TaskID, Index = Index});
                    end
                end
            end
        end
        self.Task_TabMenu:Reload(#self.TaskList);
    end
end

function UGC_Growing_LevelDetails_UIBP:UpdateTaskInfo(TaskID, TaskIndex)
    print(string.format("[UGC_Growing_LevelDetails_UIBP:UpdateTaskInfo] TaskID: %d TaskIndex: %d", TaskID, TaskIndex));
    local TaskState = TaskManager:GetLevelTaskState(self.TaskLineName, self.LevelIndex, TaskIndex);
    if TaskState == EUGCTaskState.Expired then
        ---刷新Item
        self:RefreshTask();
    else
        local IsExist = false;
        local TaskItem = nil;
        for Item, Idx in pairs(self.TaskItem) do
            if Idx == TaskIndex then
                IsExist = true;
                TaskItem = Item;
            end
        end
        if IsExist and TaskItem then
            TaskItem:UpdateTaskInfo(TaskID);
        else
            ---刷新Item
            self:RefreshTask();
        end
    end
end

return UGC_Growing_LevelDetails_UIBP