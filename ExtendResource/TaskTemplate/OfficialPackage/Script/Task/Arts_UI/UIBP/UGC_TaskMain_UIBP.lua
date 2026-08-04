---@class UGC_TaskMain_UIBP_C:UUserWidget
---@field button_close UNewButton
---@field CanvasPanel_Content UCanvasPanel
---@field CanvasPanel_SideIPX UCanvasPanel
---@field CTaskGrowbut UCanvasPanel
---@field Image_NewTaskBG UImage
---@field ScaleBox_IPX UScaleBox
---@field ScaleBox_NewTaskBG UScaleBox
---@field Task_TabMenu UGC_ReuseList2_C
--Edit Below--
local UGC_TaskMain_UIBP = { bInitDoOnce = false } 

function UGC_TaskMain_UIBP:Construct()
    print("[UGC_TaskMain_UIBP:Construct]");
    self:InitBindEvent();
    self.TabList = {};
    self.SelectTaskLineIndex = -1;
    Common.LoadObjectAsync('/Game/WwiseEvent/UI_Button/Play_UI_Bnt_MainMenu.Play_UI_Bnt_MainMenu',
            function (Object)
                if self ~= nil and UE.IsValid(self) then
                    print("[UGC_TaskMain_UIBP:Construct] Load WwiseEvent");
                    self.OpenWwiseEvent = Object
                end
            end
        );
end

-- function UGC_TaskMain_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_TaskMain_UIBP:Destruct()
    if self.TaskMainUITimer ~= nil then
        Timer.RemoveTimer(self.TaskMainUITimer);
        self.TaskMainUITimer = nil;
    end
    self.Task_TabMenu.OnUpdateItem:RemoveAll();
    self.button_close.OnClicked:RemoveAll();
end

function UGC_TaskMain_UIBP:InitBindEvent()
    self.Task_TabMenu.OnUpdateItem:Add(self.InitTabItem, self);
    self.button_close.OnClicked:Add(self.Close, self);
end

function UGC_TaskMain_UIBP:Close()
    TaskManager:CloseTaskMainUI()
end

function UGC_TaskMain_UIBP:InitTabItem(Item, Index)
    print(string.format("[UGC_TaskMain_UIBP:InitTabItem] Index: %d", Index));
    -- log_tree("[UGC_TaskMain_UIBP:InitTabItem] TaskLineUIList", self.TaskLineUIMap);
    self.TabList[Index + 1] = Item;

    if self.LegalTaskLineConfig[Index + 1] then
        local TaskLineName = self.LegalTaskLineConfig[Index + 1].TaskLineConfig.TaskLineName;
        print(string.format("[UGC_TaskMain_UIBP:InitTabItem] TaskLineName: %s", TaskLineName));
        Item:InitUI(Index + 1, TaskLineName);
        if Index == 0 then
            self.TabList[Index + 1]:Select();
            self.SelectTaskLineIndex = 1;
            local TaskLineType = self.LegalTaskLineConfig[Index + 1].TaskLineConfig.TaskLineType;
            if TaskLineType == EUGCTaskLineType.LevelTaskLine then
                self.LevelTaskLineUI:InitUI(TaskLineName);
                self.LevelTaskLineUI:SetVisibility(ESlateVisibility.Visible);
                self.PercentTaskLineUI:SetVisibility(ESlateVisibility.Collapsed);
            elseif TaskLineType == EUGCTaskLineType.PercentTaskLine then
                self.PercentTaskLineUI:InitUI(TaskLineName);
                self.LevelTaskLineUI:SetVisibility(ESlateVisibility.Collapsed);
                self.PercentTaskLineUI:SetVisibility(ESlateVisibility.Visible);
            end
        else
            self.TabList[Index + 1]:UnSelect();
        end
    end
end

function UGC_TaskMain_UIBP:ShowLevelTask()

end

function UGC_TaskMain_UIBP:ShowDailyTask()

end

---@param TaskLineConfigList ULuaMapHelper
function UGC_TaskMain_UIBP:InitUI()
    self:InitTaskLineData();
    if self.TaskMainUITimer == nil then
        self.TaskMainUITimer = Timer.InsertTimer(
            1,
            function ()
                local CurTime = UGCGameSystem.GetServerTimeSec();
                print(string.format("[UGC_TaskMain_UIBP:InitUI] CurTime: %d NextRefreshTime: %d", CurTime, self.NextRefreshTime or 0));
                if self.NextRefreshTime and CurTime >= self.NextRefreshTime then
                    self:SetLegalTaskLineConfig();
                    self.Task_TabMenu:Reload(#self.LegalTaskLineConfig);
                    self:SetNextRefreshTime();
                end
            end,
            true,
            "TaskMainUITimer",
            0
        );
    end
    self.Task_TabMenu:Reload(#self.LegalTaskLineConfig);
    if self.OpenWwiseEvent then
        print("[UGC_TaskMain_UIBP:InitUI] PlaySound2D");
        UGCSoundManagerSystem.PlaySound2D(self.OpenWwiseEvent);
    end
end

function UGC_TaskMain_UIBP:InitTaskLineData()
    if self.TaskLineConfig == nil then
        local GamePartConfig = UGCGamePartSystem.GetGamePartConfig("TaskManager");
        if GamePartConfig and GamePartConfig.TaskLineConfigList then
            self.TaskLineConfig = {};
            for Idx, TaskLineConfig in pairs(GamePartConfig.TaskLineConfigList) do
                -- print(string.format("[UGC_TaskMain_UIBP:InitTaskLineData] Idx: %d", Idx));
                print_dev(TaskLineConfig.TaskLineName)
                if TaskManager.TaskLineConfigData[TaskLineConfig.TaskLineName] then
                    table.insert(self.TaskLineConfig, TaskLineConfig:Copy());
                end
            end
            log_tree("[UGC_TaskMain_UIBP:InitTaskLineData] TaskLineConfig", self.TaskLineConfig);

            if self.TaskLineTimeMap == nil then
                self.TaskLineTimeMap = {};
                for Idx, TaskLineConfig in pairs(self.TaskLineConfig) do
                    local TasklLineName = TaskLineConfig.TaskLineName;
                    local BeginTime = TaskManager:GetTaskLineBeginTime(TasklLineName);
                    local EndTime = TaskManager:GetTaskLineEndTime(TasklLineName);
                    self.TaskLineTimeMap[TasklLineName] = {BeginTime = BeginTime, EndTime = EndTime};
                end
                log_tree("[UGC_TaskMain_UIBP:InitTaskLineData] TaskLineTimeMap", self.TaskLineTimeMap);
            end
            self:SetLegalTaskLineConfig();
            self:SetNextRefreshTime();
            self.CanvasPanel_Content:SetVisibility(ESlateVisibility.Visible);
        end
    end
end

function UGC_TaskMain_UIBP:SetLegalTaskLineConfig()
    self.LegalTaskLineConfig = {};
    local CurTime = UGCGameSystem.GetServerTimeSec();
    for Idx, TaskLineConfig in pairs(self.TaskLineConfig) do
        local TaskLineName = TaskLineConfig.TaskLineName;
        if self.TaskLineTimeMap and self.TaskLineTimeMap[TaskLineName] then
            local BeginTime = self.TaskLineTimeMap[TaskLineName].BeginTime;
            local EndTime = self.TaskLineTimeMap[TaskLineName].EndTime;
            print(string.format("[UGC_TaskMain_UIBP:SetLegalTaskLineConfig] CurTime: %d BeginTime: %d EndTime: %d", CurTime, BeginTime, EndTime));
            if CurTime >= BeginTime and CurTime < EndTime then
                table.insert(self.LegalTaskLineConfig, {TaskLineConfig = TaskLineConfig, RealIndex = Idx});
            end
        end
    end
    log_tree("[UGC_TaskMain_UIBP:SetLegalTaskLineConfig] LegalTaskLineConfig", self.LegalTaskLineConfig);
end

function UGC_TaskMain_UIBP:SetNextRefreshTime()
    local CurTime = UGCGameSystem.GetServerTimeSec();
    local TimeList = {};
    self.NextRefreshTime = nil;
    for Idx, TaskLineConfig in pairs(self.TaskLineConfig) do
        local TaskLineName = TaskLineConfig.TaskLineName;
        if self.TaskLineTimeMap and self.TaskLineTimeMap[TaskLineName] then
            local BeginTime = self.TaskLineTimeMap[TaskLineName].BeginTime;
            local EndTime = self.TaskLineTimeMap[TaskLineName].EndTime;
            if BeginTime > CurTime then
                table.insert(TimeList, BeginTime);
            end
            if EndTime > CurTime then
                table.insert(TimeList, EndTime);
            end
        end
    end
    log_tree("[UGC_TaskMain_UIBP:SetNextRefreshTime] TimeList", TimeList);
    for Idx, Time in pairs(TimeList) do
        if self.NextRefreshTime == nil then
            self.NextRefreshTime = Time;
        elseif self.NextRefreshTime > Time then
            self.NextRefreshTime = Time;
        end
    end
    print(string.format("[UGC_TaskMain_UIBP:SetNextRefreshTime] CurTime: %d NextRefreshTime: %d", CurTime, self.NextRefreshTime or 0));
end

function UGC_TaskMain_UIBP:SelectTaskLine(Index)
    print(string.format("[UGC_TaskMain_UIBP:SelectTaskLine] Index: %d", Index));
    for Idx, Tab in pairs(self.TabList) do
        if self.LegalTaskLineConfig[Idx] then
            if Index == Idx then
                Tab:Select();
                self.SelectTaskLineIndex = Idx;
            else
                Tab:UnSelect();
            end
        end
    end
    if self.LegalTaskLineConfig[Index] then
        local TaskLineName = self.LegalTaskLineConfig[Index].TaskLineConfig.TaskLineName;
        print(string.format("[UGC_TaskMain_UIBP:SelectTaskLine] TaskLineName: %s", TaskLineName));
        local TaskLineType = self.LegalTaskLineConfig[Index].TaskLineConfig.TaskLineType;
        if TaskLineType == EUGCTaskLineType.LevelTaskLine then
            self.LevelTaskLineUI:InitUI(TaskLineName);
            self.LevelTaskLineUI:SetVisibility(ESlateVisibility.Visible);
            self.PercentTaskLineUI:SetVisibility(ESlateVisibility.Collapsed);
        elseif TaskLineType == EUGCTaskLineType.PercentTaskLine then
            self.PercentTaskLineUI:InitUI(TaskLineName);
            self.PercentTaskLineUI:SetVisibility(ESlateVisibility.Visible);
            self.LevelTaskLineUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end
end

function UGC_TaskMain_UIBP:RefershRedPoint()
    for Idx, Tab in pairs(self.TabList) do
        Tab:RefershRedPoint();
    end
end

function UGC_TaskMain_UIBP:InitLevelTaskLineUI(LevelTaskLineUI)
    print("[UGC_TaskMain_UIBP:InitLevelTaskLineUI]");
    if UE.IsValid(LevelTaskLineUI) then
        self.LevelTaskLineUI = LevelTaskLineUI;
        UIUtil.AttachTo(self.CanvasPanel_Content, LevelTaskLineUI, 0, { Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } }, { Left = 0, Right = -1.5, Bottom = 0, Top = 0 });
        GlobalBattleUIFunctionLibrary.ApplyAllUGCButtonsSetting(LevelTaskLineUI);
    end
end

function UGC_TaskMain_UIBP:InitPercentTaskLineUI(PercentTaskLineUI)
    print("[UGC_TaskMain_UIBP:InitPercentTaskLineUI]");
    if UE.IsValid(PercentTaskLineUI) then
        self.PercentTaskLineUI = PercentTaskLineUI;
        UIUtil.AttachTo(self.CanvasPanel_Content, PercentTaskLineUI, 0, { Minimum = { X = 0, Y = 0 }, Maximum = { X = 1, Y = 1 } }, { Left = 0, Right = -1.5, Bottom = 0, Top = 0 });
        GlobalBattleUIFunctionLibrary.ApplyAllUGCButtonsSetting(PercentTaskLineUI);
    end
end

function UGC_TaskMain_UIBP:UpdateTaskInfo(TaskIndex)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local TaskLineName = TaskIndex.TaskLineName;
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        print(string.format("[UGC_TaskMain_UIBP:UpdateTaskInfo] TaskLineName: %s SelectTaskLineName: %s", TaskLineName, SelectTaskLineName));
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                local TaskID = TaskIndex.TaskID;
                print(string.format("[UGC_TaskMain_UIBP:UpdateTaskInfo] TaskID: %d TaskLineType: %d", TaskID, TaskLineConfig.TaskLineType));
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
                    local LevelIndex = TaskIndex.LevelTaskLevelIndex;
                    local LevelTaskIndex = TaskIndex.LevelTaskIndex;
                    self.LevelTaskLineUI:UpdateTaskInfo(TaskID, LevelIndex, LevelTaskIndex);
                elseif TaskLineConfig.TaskLineType == EUGCTaskLineType.PercentTaskLine then
                    local PercentTaskIndex = TaskIndex.PercentTaskIndex;
                    self.PercentTaskLineUI:UpdateTaskInfo(TaskID, PercentTaskIndex);
                end
            end
        end
    end
end

function UGC_TaskMain_UIBP:UpdateTaskLineAwardInfo(TaskLineName, Index)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
                    -- self.LevelTaskLineUI:UpdateTaskLineAwardInfo(Index);
                elseif TaskLineConfig.TaskLineType == EUGCTaskLineType.PercentTaskLine then
                    self.PercentTaskLineUI:UpdateTaskLineAwardInfo(Index);
                end
            end
        end
    end
end

function UGC_TaskMain_UIBP:UpdateTaskLineProgress(TaskLineName)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
                    self.LevelTaskLineUI:UpdateTaskLineProgress();
                elseif TaskLineConfig.TaskLineType == EUGCTaskLineType.PercentTaskLine then
                    self.PercentTaskLineUI:UpdateTaskLineProgress();
                end
            end
        end
    end
end

function UGC_TaskMain_UIBP:SetLevelItem(TaskLineName, Index, Item)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
                    self.LevelTaskLineUI:SetLevelItem(Index, Item);
                end
            end
        end
    end
end

function UGC_TaskMain_UIBP:ShowLevelInfo(TaskLineName, LevelIdx)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
                    self.LevelTaskLineUI:ShowLevelInfo(LevelIdx);
                end
            end
        end
    end
end

function UGC_TaskMain_UIBP:SelectLevelItem(TaskLineName, LevelIdx)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
                    self.LevelTaskLineUI:SelectLevelItem(LevelIdx);
                end
            end
        end
    end
end

function UGC_TaskMain_UIBP:RefreshRedPoint()
    for Idx, Tab in pairs(self.TabList) do
        Tab:RefreshRedPoint();
    end
end

function UGC_TaskMain_UIBP:SignWeeklyResetTaskLine(TaskLineName)
    if self.TaskLineConfig and self.TaskLineConfig[self.SelectTaskLineIndex] then
        local SelectTaskLineName = self.TaskLineConfig[self.SelectTaskLineIndex].TaskLineName;
        if TaskLineName == SelectTaskLineName then
            local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
            if TaskLineConfig and TaskLineConfig.TaskLineType then
                if TaskLineConfig.TaskLineType == EUGCTaskLineType.PercentTaskLine then
                    self.PercentTaskLineUI:SignWeeklyResetTaskLine();
                end
            end
        end
    end
end

return UGC_TaskMain_UIBP