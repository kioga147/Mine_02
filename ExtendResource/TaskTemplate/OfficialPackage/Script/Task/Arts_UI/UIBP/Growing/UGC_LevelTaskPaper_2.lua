---@class UGC_LevelTaskPaper_2_C:UUserWidget
---@field CanvasPanel_BG UCanvasPanel
---@field Image_0 UImage
---@field Image_1 UImage
---@field Task_BG UUGC_ReuseList2_C
---@field Task_Item UUGC_ReuseList2_C
--Edit Below--
local UGC_LevelTaskPaper_2 = { bInitDoOnce = false } 

function UGC_LevelTaskPaper_2:Construct()
    print("[UGC_LevelTaskPaper_2:Construct]");
	self.Task_Item.OnUpdateItem:Add(self.InitTaskItem, self);
    self.Task_BG.OnUpdateItem:Add(self.InitBg, self);
end

function UGC_LevelTaskPaper_2:InitTaskItem(Item, Index)
    print(string.format("[UGC_LevelTaskPaper_2:InitTaskItem] Index: %d",Index));
    local TaskMinIndex = Index * 2 + 1;
    local TaskMaxIndex = (Index + 1) * 2;
    local IsEnd = false;
    if TaskMaxIndex >= self.LevelNum then
        IsEnd = true;
    end
    TaskMaxIndex = math.min(TaskMaxIndex, self.LevelNum);
    local TaskLinePage = {};
    for Idx = TaskMinIndex, TaskMaxIndex do
        table.insert(TaskLinePage, Idx);
    end
    Item:InitUI(TaskLinePage, IsEnd, self.TaskLineName);
end

function UGC_LevelTaskPaper_2:InitBg(Item, Index)
    print(string.format("[UGC_LevelTaskPaper_2:InitBg] Index: %d", Index));
end

function UGC_LevelTaskPaper_2:GotoAward(Index)
    print(string.format("[UGC_LevelTaskPaper_2:GotoAward] Index: %d", Index));
    self.Task_Item:JumpByIdxStyle((Index - 1) // 2, EReuseListJumpStyle.Begin);
end

-- function UGC_LevelTaskPaper_2:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_LevelTaskPaper_2:Destruct()
	self.Task_Item.OnUpdateItem:RemoveAll();
    self.Task_BG.OnUpdateItem:RemoveAll();
end

function UGC_LevelTaskPaper_2:InitUI(TaskLineName)
    print("[UGC_LevelTaskPaper_2:InitUI]");
    self.TaskLineName = TaskLineName;
    local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
    if TaskLineConfig and TaskLineConfig.TaskLineType == EUGCTaskLineType.LevelTaskLine then
        self.LevelNum = TaskLineConfig.LevelTaskLineConfig:Num();
        local TaskItemNum = math.ceil(self.LevelNum / 2);
        self.Task_Item:Reload(TaskItemNum);
        local TaskBgNum = math.ceil(self.LevelNum / 4);
        self.Task_BG:Reload(TaskBgNum);
    end
end

return UGC_LevelTaskPaper_2