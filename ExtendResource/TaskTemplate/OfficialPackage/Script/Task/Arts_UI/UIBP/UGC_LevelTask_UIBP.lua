---@class UGC_LevelTask_UIBP_C:UUserWidget
---@field Button_CloseUI UNewButton
---@field Button_LeftSlide UNewButton
---@field CanvasPanel_CloseUI UCanvasPanel
---@field CanvasPanel_IPX UCanvasPanel
---@field CanvasTaskGrowMaps UCanvasPanel
---@field LevelTaskPaper UGC_LevelTaskPaper_2_C
---@field LevelTaskScroll UScrollBox
---@field sign_Panel UCanvasPanel
---@field Text_GrowingActivityDescription UTextBlock
---@field TextBlock_GrowingTitle UTextBlock
---@field UGC_Growing_LevelDetails_UIBP UGC_Growing_LevelDetails_UIBP_C
--Edit Below--
local UGC_LevelTask_UIBP = { bInitDoOnce = false } 

function UGC_LevelTask_UIBP:Construct()
    self.Button_LeftSlide.OnClicked:Add(self.GotoAward, self);
    self.LevelItem = {};
end

function UGC_LevelTask_UIBP:InitItem(Item, Index)
    Item:InitUI(self.LevelTaskLine[Index + 1]);
    if Index == 0 then
        Item:Select();
    else
        Item:UnSelect();
    end
end

---跳转到最小可领取奖励的等级
function UGC_LevelTask_UIBP:GotoAward()
    ---先找到索引
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    if TaskLineConfig and TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
        local LevelNum = TaskLineConfig.LevelTaskLineConfig:Num();
        for LevelIdx = 1, LevelNum do
            local TaskIDList = TaskLineConfig.LevelTaskLineConfig[LevelIdx].TaskIDList;
            for Idx, TaskID in pairs(TaskIDList) do
                local State = TaskManager:GetLevelTaskState(self.TaskLineName, LevelIdx, Idx);
                if State == EUGCTaskState.NotClaimed then
                    self.LevelTaskPaper:GotoAward(LevelIdx);
                    self:SelectLevelItem(LevelIdx);
                    self:ShowLevelInfo(LevelIdx);
                    break;
                end
            end
        end
    end
    ---JumpByIdxStyle(Idx, EReuseListJumpStyle.Begin);
end

-- function UGC_LevelTask_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_LevelTask_UIBP:Destruct()
    self.Button_LeftSlide.OnClicked:RemoveAll();
end

function UGC_LevelTask_UIBP:InitUI(TaskLineName)
    print(string.format("[UGC_LevelTask_UIBP:InitUI] TaskLineName: %s", TaskLineName));
    self.TaskLineName = TaskLineName;
    self.SelectLevelIndex = -1;
    self.Button_LeftSlide:SetVisibility(ESlateVisibility.Collapsed);
    self.LevelTaskPaper:InitUI(TaskLineName);
    self:UpdateGotoBtn();
end

function UGC_LevelTask_UIBP:UpdateTaskInfo(TaskID, LevelIndex, LevelTaskIndex)
    print(string.format("[UGC_LevelTask_UIBP:UpdateTaskInfo] TaskID: %d LevelIndex: %d LevelTaskIndex: %d SelectLevelIndex: %d", TaskID, LevelIndex, LevelTaskIndex, self.SelectLevelIndex));
    if self.SelectLevelIndex == LevelIndex then
        self.UGC_Growing_LevelDetails_UIBP:UpdateTaskInfo(TaskID, LevelTaskIndex);
    end
    for Item, Index in pairs(self.LevelItem) do
        if Index == LevelIndex then
            Item:UpdateLevelAwardState();
            self:UpdateGotoBtn();
        end
    end
end

function UGC_LevelTask_UIBP:SetLevelItem(Index, Item)
    print(string.format("[UGC_LevelTask_UIBP:SetLevelItem] Index: %d", Index));
    self.LevelItem[Item] = Index;
    if self.Button_LeftSlide:GetVisibility() == ESlateVisibility.Collapsed then
        local AwardState = TaskManager:GetTaskLineAwardState(self.TaskLineName, Index);
        if AwardState == EUGCTaskLineAwardState.NotClaimed then
            self.Button_LeftSlide:SetVisibility(ESlateVisibility.Visible);
        end
    end
end

function UGC_LevelTask_UIBP:SelectLevelItem(Index)
    if self.SelectLevelIndex == Index then
        return;
    end
    print(string.format("[UGC_LevelTask_UIBP:SelectLevelItem] Index: %d", Index));
    log_tree("[UGC_LevelTask_UIBP:SelectLevelItem] LevelItem", self.LevelItem);
    self.SelectLevelIndex = Index;
    for Item, Idx in pairs(self.LevelItem) do
        if Index == Idx then
            Item:Select();
        else
            Item:UnSelect();
        end
    end
end

function UGC_LevelTask_UIBP:ShowLevelInfo(LevelIndex)
    self.UGC_Growing_LevelDetails_UIBP:InitUI(self.TaskLineName, LevelIndex);
end

function UGC_LevelTask_UIBP:UpdateTaskLineProgress()
    ---刷新等级状态
    for Item, Idx in pairs(self.LevelItem) do
        Item:UpdateLevelAwardState();
    end
    ---刷新详情信息
    self.UGC_Growing_LevelDetails_UIBP:InitUI(self.TaskLineName, self.SelectLevelIndex);
    self:UpdateGotoBtn();
end

function UGC_LevelTask_UIBP:UpdateGotoBtn()
    ---判断是否有等级奖励可领取
    local IsShow = false;
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    if TaskLineConfig and TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
        local LevelNum = TaskLineConfig.LevelTaskLineConfig:Num();
        for LevelIdx = 1, LevelNum do
            local TaskIDList = TaskLineConfig.LevelTaskLineConfig[LevelIdx].TaskIDList;
            for Idx, TaskID in pairs(TaskIDList) do
                local State = TaskManager:GetLevelTaskState(self.TaskLineName, LevelIdx, Idx);
                if State == EUGCTaskState.NotClaimed then
                    IsShow = true;
                    break;
                end
            end
        end
    end
    if IsShow then
        self.Button_LeftSlide:SetVisibility(ESlateVisibility.Visible);
    else
        self.Button_LeftSlide:SetVisibility(ESlateVisibility.Collapsed);
    end
end

return UGC_LevelTask_UIBP