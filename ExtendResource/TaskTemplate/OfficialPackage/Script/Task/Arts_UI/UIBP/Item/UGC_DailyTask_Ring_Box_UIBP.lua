---@class UGC_DailyTask_Ring_Box_UIBP_C:UUserWidget
---@field DX_kaixiang UWidgetAnimation
---@field Button_Receive UNewButton
---@field New_TaskIcon UImage
---@field New_TaskIReceived UCanvasPanel
---@field PendingCollection UCanvasPanel
---@field UIParticleEmitter_22 UUIParticleEmitter
--Edit Below--
local UGC_DailyTask_Ring_Box_UIBP = { bInitDoOnce = false } 

function UGC_DailyTask_Ring_Box_UIBP:Construct()
	self.Button_Receive.OnClicked:Add(self.ShowBoxAwardList, self);
    self.DX_kaixiang.OnAnimationFinished:Add(self.ShowItemGet, self);
end

function UGC_DailyTask_Ring_Box_UIBP:ShowBoxAwardList()
    if not self.IsBigBox then
        local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
        if TaskLineConfig and
            TaskLineConfig.PercentAwardList and
            TaskLineConfig.PercentAwardList[self.Index] and
            TaskLineConfig.PercentAwardList[self.Index].ItemList then
            TaskManager:ShowBoxAwardList(TaskLineConfig.PercentAwardList[self.Index].ItemList);
        end
    end
end

function UGC_DailyTask_Ring_Box_UIBP:OpenBox()
    -- 播放宝箱打开动画，动画播放完毕后再领奖
    print("[UGC_DailyTask_Ring_Box_UIBP:OpenBox]");
    if self.IsBigBox then
        self.New_TaskIcon:SetBrushFromTexture(self.BoxIcon[3]);
        if CheckObjectContainsField(self, "DX_kaixiang") then
            self:PlayAnimation(self.DX_kaixiang, 0, 1, EUMGSequencePlayMode.Forward, 1);
        end
    end
end

function UGC_DailyTask_Ring_Box_UIBP:ShowItemGet()
    print("[UGC_DailyTask_Ring_Box_UIBP:ShowItemGet]");
    TaskManager:SignWeeklyResetTaskLine(self.TaskLineName);
end

-- function UGC_DailyTask_Ring_Box_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_DailyTask_Ring_Box_UIBP:Destruct()
	self.Button_Receive.OnClicked:RemoveAll();
    self.DX_kaixiang.OnAnimationFinished:RemoveAll();
end

function UGC_DailyTask_Ring_Box_UIBP:InitUI(Index, BoxIcon, TaskLineName, IsBigBox)
    self.BoxIcon = BoxIcon;
    self.TaskLineName = TaskLineName;
    self.Index = Index;
    self:SetTaskLineAwardState();
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    if TaskLineConfig and
        TaskLineConfig.PercentAwardList and
        TaskLineConfig.PercentAwardList[self.Index] and
        TaskLineConfig.PercentAwardList[self.Index].ItemList then
        if TaskLineConfig.PercentAwardList[self.Index].ItemList:Num() > 0 then
            self.ItemID = TaskLineConfig.PercentAwardList[self.Index].ItemList[1].ItemID;
        end
    end
    self.IsBigBox = IsBigBox;
end

function UGC_DailyTask_Ring_Box_UIBP:SetTaskLineAwardState()
    local AwardState = TaskManager:GetTaskLineAwardState(self.TaskLineName, self.Index);
    if AwardState == EUGCTaskLineAwardState.Lock then
        self.New_TaskIcon:SetBrushFromTexture(self.BoxIcon[1]);
        self.PendingCollection:SetVisibility(ESlateVisibility.Collapsed);
        self.New_TaskIReceived:SetVisibility(ESlateVisibility.Collapsed);
    elseif AwardState == EUGCTaskLineAwardState.NotClaimed then
        self.New_TaskIcon:SetBrushFromTexture(self.BoxIcon[1]);
        self.PendingCollection:SetVisibility(ESlateVisibility.Visible);
        self.New_TaskIReceived:SetVisibility(ESlateVisibility.Collapsed);
    elseif AwardState == EUGCTaskLineAwardState.HasClaimed then
        self.New_TaskIcon:SetBrushFromTexture(self.BoxIcon[2]);
        self.New_TaskIReceived:SetVisibility(ESlateVisibility.Collapsed);
        self.PendingCollection:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function UGC_DailyTask_Ring_Box_UIBP:UpdateTaskLineAwardInfo()
    self:SetTaskLineAwardState();
end

return UGC_DailyTask_Ring_Box_UIBP