---@class UGC_Growing_SignPoint_UIBP_C:UUserWidget
---@field Button_Select UButton
---@field Canvas_Panel_TIPS UCanvasPanel
---@field CanvasPanel_6 UCanvasPanel
---@field CanvasPanel_Gift UCanvasPanel
---@field Image_2 UImage
---@field Image_4 UImage
---@field Image_6 UImage
---@field Image_ItemIcon UImage
---@field Image_Received UImage
---@field NewButton_Gift UNewButton
---@field sign_4 UImage
---@field sign_ring_lock UImage
---@field sign_ring_select UCanvasPanel
---@field Text_GetGrade_1 UTextBlock
---@field Text_Grade_0 UTextBlock
---@field Text_LockGrade_3 UTextBlock
---@field Text_ReceivedGrade_2 UTextBlock
---@field WidgetSwitcher_BG UWidgetSwitcher
--Edit Below--
local UGC_Growing_SignPoint_UIBP = { bInitDoOnce = false } 

function UGC_Growing_SignPoint_UIBP:Construct()
	self.Button_Select.OnClicked:Add(self.SelectTask, self);
end

function UGC_Growing_SignPoint_UIBP:SelectTask()
    print(string.format("[UGC_Growing_SignPoint_UIBP:SelectTask] Index: %d", self.LevelIdx));
    TaskManager:SelectLevelItem(self.TaskLineName, self.LevelIdx);
    TaskManager:ShowLevelInfo(self.TaskLineName, self.LevelIdx);
end

function UGC_Growing_SignPoint_UIBP:Select()
    print(string.format("[UGC_Growing_SignPoint_UIBP:Select] Index: %d", self.LevelIdx));
    self.sign_ring_select:SetVisibility(ESlateVisibility.Visible);
    self:UpdateLevelAwardState();
end

function UGC_Growing_SignPoint_UIBP:UnSelect()
    print(string.format("[UGC_Growing_SignPoint_UIBP:UnSelect] Index: %d", self.LevelIdx));
    self.sign_ring_select:SetVisibility(ESlateVisibility.Collapsed);
    self:UpdateLevelAwardState();
end

---检查是否有奖励可领取
function UGC_Growing_SignPoint_UIBP:CheckCanSign()
end

-- function UGC_Growing_SignPoint_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_Growing_SignPoint_UIBP:Destruct()
	self.Button_Select.OnClicked:RemoveAll();
end

function UGC_Growing_SignPoint_UIBP:InitUI(LevelIdx, TaskLineName)
    self.LevelIdx = LevelIdx;
    self.TaskLineName = TaskLineName;
    local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
    if TaskLineConfig and
        TaskLineConfig.LevelTaskLineConfig and
        TaskLineConfig.LevelTaskLineConfig[LevelIdx] then

        local Level = tostring(TaskLineConfig.LevelTaskLineConfig[LevelIdx].Level);
        self.Text_Grade_0:SetText(Level);
        self.Text_GetGrade_1:SetText(Level);
        self.Text_ReceivedGrade_2:SetText(Level);
        self.Text_LockGrade_3:SetText(Level);

        ---显示当前任务列表里任务线进度任务的奖励，没有就不显示
        self.IsShowAwardTip = false;
        for Idx, TaskID in pairs(TaskLineConfig.LevelTaskLineConfig[LevelIdx].TaskIDList) do
            local TaskType = TaskManager:GetTaskType(TaskID);
            if TaskType == 5 then
                local TaskAwardList = TaskManager:GetTaskAwardList(TaskID);
                if TaskAwardList and #TaskAwardList > 0 then
                    local ItemID = TaskAwardList[1].ItemID;
                    local ItemInfo = TaskManager:GetItemInfoByItemID(ItemID);
                    if ItemInfo and ItemInfo.ItemIcon then
                        self.IsShowAwardTip = true;
                        Common.LoadObjectAsync(ItemInfo.ItemIcon,
                            function (IconTexture)
                                if self ~= nil and UE.IsValid(self) then
                                    self.Image_ItemIcon:SetBrushFromTexture(IconTexture);
                                end
                            end)
                    end
                end
                break;
            end
        end
    end

    TaskManager:SetLevelItem(TaskLineName, LevelIdx, self);
    local SelectIndex = TaskManager:GetLevelTaskLineSelectIndex();
    if SelectIndex == nil or SelectIndex == -1 then
        if LevelIdx == 1 then
            TaskManager:SelectLevelItem(TaskLineName, LevelIdx);
            TaskManager:ShowLevelInfo(TaskLineName, LevelIdx);
            self:Select();
        else
            self:UnSelect();
        end
    else
        if LevelIdx ~= SelectIndex then
            self:UnSelect();
        end
    end
end

function UGC_Growing_SignPoint_UIBP:UpdateLevelAwardState()
    print(string.format("[UGC_Growing_SignPoint_UIBP:UpdateLevelAwardState] TaskLineName: %s LevelIdx: %d", self.TaskLineName, self.LevelIdx));
    local TaskLineProgress = TaskManager:GetTaskLineProgress(self.TaskLineName);
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    if TaskLineConfig and
        TaskLineConfig.LevelTaskLineConfig and
        TaskLineConfig.LevelTaskLineConfig[self.LevelIdx] then
        local Level = TaskLineConfig.LevelTaskLineConfig[self.LevelIdx].Level;
        if TaskLineProgress >= Level then
            ---已解锁
            local HasClaimed = true;
            local IsShowGift = false;
            for Idx, TaskID in pairs(TaskLineConfig.LevelTaskLineConfig[self.LevelIdx].TaskIDList) do
                local State = TaskManager:GetLevelTaskState(self.TaskLineName, self.LevelIdx, Idx);
                if State ~= EUGCTaskState.HasClaimed then
                    HasClaimed = false;
                end
                if State == EUGCTaskState.NotClaimed then
                    IsShowGift = true;
                end
            end
            if HasClaimed then
                self.WidgetSwitcher_BG:SetActiveWidgetIndex(2);
            else
                local SelectIndex = TaskManager:GetLevelTaskLineSelectIndex();
                if SelectIndex == self.LevelIdx then
                    self.WidgetSwitcher_BG:SetActiveWidgetIndex(1);
                else
                    self.WidgetSwitcher_BG:SetActiveWidgetIndex(0);
                end
            end
            if IsShowGift then
                self.CanvasPanel_Gift:SetVisibility(ESlateVisibility.Visible);
            else
                self.CanvasPanel_Gift:SetVisibility(ESlateVisibility.Collapsed);
            end
            self.Canvas_Panel_TIPS:SetVisibility(ESlateVisibility.Collapsed);
        else
            ---未解锁
            self.WidgetSwitcher_BG:SetActiveWidgetIndex(3);
            self.CanvasPanel_Gift:SetVisibility(ESlateVisibility.Collapsed);
            ---判断是否有任务线进度任务
            if self.IsShowAwardTip then
                self.Canvas_Panel_TIPS:SetVisibility(ESlateVisibility.Visible);
            else
                self.Canvas_Panel_TIPS:SetVisibility(ESlateVisibility.Collapsed);
            end
        end
    end
end

return UGC_Growing_SignPoint_UIBP