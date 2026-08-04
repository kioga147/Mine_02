TaskManager = {}

UGCTaskAwardState = {
    Lock = 0,
    CanSign = 1,
    HasGot = 2,
}

UGCTaskState = {
    Lock = 0, --未解锁
    Incomplete = 1, --已解锁未完成
    CompletedNotClaimed = 2, --已完成未领取
    RewardClaimed = 3, --已领取
}

function TaskManager:RegisterComponentClass(CompClass, PlayerController)
    if CompClass ~= nil then
        self.TaskTemplateComponentClass = CompClass;
    end
end

--获取玩家的TaskTemplateComponent
--生效范围：客户端&&服务端
function TaskManager:GetTaskTemplateComponent(PlayerController)
    if PlayerController == nil and UGCGameSystem.GameState:HasAuthority() == false then
        if self.TaskTemplateComponent == nil then
            if self.TaskTemplateComponentClass ~= nil and UGCGameSystem.GameState ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(UGCGameSystem.GameState);
                self.TaskTemplateComponent = PlayerController:GetComponentByClass(self.TaskTemplateComponentClass);
            else
                print("[TaskManager:GetTaskTemplateComponent] Cannot get local component!");
            end
        end
        return self.TaskTemplateComponent;
    end

    if self.TaskTemplateComponentClass ~= nil then
        return PlayerController:GetComponentByClass(self.TaskTemplateComponentClass);
    else
        print("[TaskManager:GetTaskTemplateComponent] ComponentClass is nil!");
        return nil;
    end
end

function TaskManager:LoadConfig(ConfigDataTable)
    print_dev("TaskManager:LoadConfig")
    if self.IsConfigLoaded then
        return
    end

    self.TaskLineConfigData = {}
    local ConfigDatas = UGCGameSystem.GetDataTableData(ConfigDataTable)
    for _, ConfigData in pairs(ConfigDatas) do
        local TaskLineName = ConfigData.TaskLineName
        self.TaskLineConfigData[TaskLineName] = true
    end
    self.IsConfigLoaded = true
end

function TaskManager:GetTaskLineUIPathList()
    log_tree("TaskManager:GetTaskLineUIPathList:", self.TaskLineUIPathList);
    return self.TaskLineUIPathList;
end

function TaskManager:SelectTaskLine(Index)
    self:GetTaskTemplateComponent():SelectTaskLine(Index);
end

function TaskManager:OpenTaskMainUI()
    print("TaskManager:OpenTaskMainUI");
    self:GetTaskTemplateComponent():OpenTaskMainUI();
end

function TaskManager:CloseTaskMainUI()
    print("TaskManager:CloseTaskMainUI");
    self:GetTaskTemplateComponent():CloseTaskMainUI();
end

function TaskManager:GetObjectData()
    print("TaskManager:GetObjectData");
    if self.ObjectDatas ~= nil then
        return self.ObjectDatas;
    end

    self.ObjectDatas = Common.GetObjectDatas();

    return self.ObjectDatas;
end

---@param ItemID int32
---@return FUGCObjectData
function TaskManager:GetItemInfoByItemID(ItemID)
    print(string.format("TaskManager:GetItemInfoByItemID ItemID: %d", ItemID));
    if self.ObjectDatas == nil then
        self:GetObjectData(); 
    end

    return self.ObjectDatas[ItemID];
end

---@param Task UUGCTaskTypeBase
function TaskManager:GetTaskParamConfig(Task)
    local Current = 0;
    local Target = 0;
    if Task and Task.TaskNode then
        if Task.TaskNode.GetNodeType() == EUGCTaskNodeType.UGCCumulativeOnlineTimeTask then
            Target = Task.TaskNode.OnlineTime;
        elseif Task.TaskNode.GetNodeType() == EUGCTaskNodeType.UGCCumulativeGetItem then
            Target = Task.TaskNode.CumulativeItemNum;
        elseif Task.TaskNode.GetNodeType() == EUGCTaskNodeType.UGCCumulativeKillNumTask then
            Target = Task.TaskNode.KillNum;
        end
    end
end

function TaskManager:ShowItemTip(ItemID, Position)
    return self:GetTaskTemplateComponent():ShowItemTip(ItemID, Position);
end

function TaskManager:GetTaskLineConfig(TaskLineName)
    return self:GetTaskTemplateComponent():GetTaskLineConfig(TaskLineName);
end

function TaskManager:GetLevelTaskInfoList(TaskLineName)
    return self:GetTaskTemplateComponent():GetLevelTaskInfoList(TaskLineName);
end

function TaskManager:GetPercentTaskInfoList(TaskLineName)
    return self:GetTaskTemplateComponent():GetPercentTaskInfoList(TaskLineName);
end

function TaskManager:GetPercentTaskLineAwardStateList(TaskLineName)
    return self:GetTaskTemplateComponent():GetPercentTaskLineAwardStateList(TaskLineName);
end

function TaskManager:GetTaskLineProgress(TaskLineName)
    return self:GetTaskTemplateComponent():GetTaskLineProgress(TaskLineName);
end

function TaskManager:GetItemNum(ItemID)
    return self:GetTaskTemplateComponent():GetItemNum(ItemID);
end

function TaskManager:GetTaskBeginTime(TaskID)
    return self:GetTaskTemplateComponent():GetTaskBeginTime(TaskID);
end

function TaskManager:GetTaskEndTime(TaskID)
    return self:GetTaskTemplateComponent():GetTaskEndTime(TaskID);
end

function TaskManager:GetTaskLineBeginTime(TaskLineName)
    return self:GetTaskTemplateComponent():GetTaskLineBeginTime(TaskLineName);
end

function TaskManager:GetTaskLineEndTime(TaskLineName)
    return self:GetTaskTemplateComponent():GetTaskLineEndTime(TaskLineName);
end

function TaskManager:GetTaskIsShowOutDate(TaskID)
    return self:GetTaskTemplateComponent():GetTaskIsShowOutDate(TaskID);
end

function TaskManager:GetPercentTaskPercent(TaskLineName, TaskID)
    return self:GetTaskTemplateComponent():GetPercentTaskPercent(TaskLineName, TaskID);
end

function TaskManager:ClaimLevelTaskAward(TaskLineName, LevelIndex, TaskIndex)
    return self:GetTaskTemplateComponent():ClaimLevelTaskAward(TaskLineName, LevelIndex, TaskIndex);
end

function TaskManager:ClaimPercentTaskAward(TaskLineName, TaskIndex)
    return self:GetTaskTemplateComponent():ClaimPercentTaskAward(TaskLineName, TaskIndex);
end

function TaskManager:GetTaskDesc(TaskID)
    return self:GetTaskTemplateComponent():GetTaskDesc(TaskID);
end

function TaskManager:GetTaskAwardList(TaskID)
    return self:GetTaskTemplateComponent():GetTaskAwardList(TaskID);
end

function TaskManager:GetTaskLineAwardState(TaskLineName, Index)
    return self:GetTaskTemplateComponent():GetTaskLineAwardState(TaskLineName, Index);
end

function TaskManager:ClaimTaskLineAward(TaskLineName, Index)
    self:GetTaskTemplateComponent():ClaimTaskLineAward(TaskLineName, Index);
end

function TaskManager:RefreshRedPoint()
    self:GetTaskTemplateComponent():RefreshRedPoint();
end

function TaskManager:GetCopperBoxIcon()
    return self:GetTaskTemplateComponent():GetCopperBoxIcon();
end

function TaskManager:GetSilverBoxIcon()
    return self:GetTaskTemplateComponent():GetSilverBoxIcon();
end

function TaskManager:GetGoldBoxIcon()
    return self:GetTaskTemplateComponent():GetGoldBoxIcon();
end

function TaskManager:GetTaskLineResetTime(TaskLineName)
    return self:GetTaskTemplateComponent():GetTaskLineResetTime(TaskLineName);
end

function TaskManager:ShowBoxAwardList(AwardList)
    return self:GetTaskTemplateComponent():ShowBoxAwardList(AwardList);
end

function TaskManager:GetPercentTaskProgress(TaskLineName, Index)
    return self:GetTaskTemplateComponent():GetPercentTaskProgress(TaskLineName, Index);
end

function TaskManager:GetPercentTaskState(TaskLineName, Index)
    return self:GetTaskTemplateComponent():GetPercentTaskState(TaskLineName, Index);
end

function TaskManager:GetLevelTaskProgress(TaskLineName, LevelIndex, TaskIndex)
    return self:GetTaskTemplateComponent():GetLevelTaskProgress(TaskLineName, LevelIndex, TaskIndex);
end

function TaskManager:GetLevelTaskState(TaskLineName, LevelIndex, TaskIndex)
    return self:GetTaskTemplateComponent():GetLevelTaskState(TaskLineName, LevelIndex, TaskIndex);
end

function TaskManager:GetTaskTarget(TaskID)
    return self:GetTaskTemplateComponent():GetTaskTarget(TaskID);
end

function TaskManager:SetTaskLineProgress(TaskLineName, TaskLineProgress)
    self:GetTaskTemplateComponent():SetTaskLineProgress(TaskLineName, TaskLineProgress);
end

function TaskManager:SetLevelItem(TaskLineName, Index, Item)
    self:GetTaskTemplateComponent():SetLevelItem(TaskLineName, Index, Item);
end

function TaskManager:ShowLevelInfo(TaskLineName, LevelIdx)
    self:GetTaskTemplateComponent():ShowLevelInfo(TaskLineName, LevelIdx);
end

function TaskManager:SelectLevelItem(TaskLineName, LevelIdx)
    self:GetTaskTemplateComponent():SelectLevelItem(TaskLineName, LevelIdx);
end

function TaskManager:SignWeeklyResetTaskLine(TaskLineName)
    self:GetTaskTemplateComponent():SignWeeklyResetTaskLine(TaskLineName);
end

function TaskManager:ResetPercentTaskLine(TaskLineName)
    self:GetTaskTemplateComponent():ResetPercentTaskLine(TaskLineName);
end

function TaskManager:ClaimAllAward(TaskLineName)
    self:GetTaskTemplateComponent():ClaimAllAward(TaskLineName);
end

function TaskManager:GetLevelTaskLineSelectIndex()
    return self:GetTaskTemplateComponent():GetLevelTaskLineSelectIndex();
end

function TaskManager:GetTaskType(TaskID)
    return self:GetTaskTemplateComponent():GetTaskType(TaskID);
end

function TaskManager:GetTaskConfig(TaskID)
    return self:GetTaskTemplateComponent():GetTaskConfig(TaskID);
end

function TaskManager:UpdateTaskProgress(TaskIndex, PlayerController, TaskProgress)
    self:GetTaskTemplateComponent():UpdateTaskProgress(TaskIndex, PlayerController, TaskProgress);
end

return TaskManager