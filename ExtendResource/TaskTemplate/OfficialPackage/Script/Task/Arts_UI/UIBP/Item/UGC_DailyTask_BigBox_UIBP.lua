---@class UGC_DailyTask_BigBox_UIBP_C:UUserWidget
---@field CanvasPanel_SeasonBox_FX UCanvasPanel
---@field DailyTask_Ring_Box_01 UGC_DailyTask_Ring_Box_UIBP_C
---@field DailyTask_Ring_Box_02 UGC_DailyTask_Ring_Box_UIBP_C
---@field DailyTask_Ring_Box_03 UGC_DailyTask_Ring_Box_UIBP_C
---@field Image_FX1 UImage
---@field Image_FX2 UImage
---@field Image_schedule UImage
---@field Image_Taskbanner UImage
---@field NewButton_Receive UNewButton
---@field NewButton_ReceivedAlready UNewButton
---@field Switcher_DayTaskBig_But UWidgetSwitcher
---@field Text UTextBlock
---@field Text_DailyTask_Ring_Box_01 UTextBlock
---@field Text_DailyTask_Ring_Box_02 UTextBlock
---@field Text_DailyTask_Ring_Box_03 UTextBlock
---@field TextBlock_11 UTextBlock
---@field TextBlock_Challenge_DuringTime UTextBlock
---@field TextBlock_CompleteTips UTextBlock
---@field TextBlock_DailyChallenge_Number UTextBlock
---@field UGC_DailyTask_Ring_Box_Big UGC_DailyTask_Ring_Box_UIBP_C
---@field WidgetSwitcher_DayTask UWidgetSwitcher
--Edit Below--
local UGC_DailyTask_BigBox_UIBP = { bInitDoOnce = false } 

function UGC_DailyTask_BigBox_UIBP:Construct()
	self.NewButton_Receive.OnClicked:Add(self.OpenBigBox, self);
end

function UGC_DailyTask_BigBox_UIBP:OpenBigBox()
    self.UGC_DailyTask_Ring_Box_Big:OpenBox();
end

function UGC_DailyTask_BigBox_UIBP:SignAward()
    print("[UGC_DailyTask_BigBox_UIBP:SignAward]");
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    local PercentAwardNum = TaskLineConfig.PercentAwardList:Num();
    if PercentAwardNum >= 3 then
        --- 先播放宝箱打开动画
        --- 动画播放完毕后调用领奖逻辑并更新宝箱显示状态
        local AwardState01 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 1);
        local AwardState02 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 2);
        local AwardState03 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 3);
        if AwardState03 == EUGCTaskLineAwardState.NotClaimed then
            TaskManager:ClaimTaskLineAward(self.TaskLineName, 3);
        elseif AwardState02 == EUGCTaskLineAwardState.NotClaimed then
            TaskManager:ClaimTaskLineAward(self.TaskLineName, 2);
        elseif AwardState01 == EUGCTaskLineAwardState.NotClaimed then
            TaskManager:ClaimTaskLineAward(self.TaskLineName, 1);
        end
    end
end

function UGC_DailyTask_BigBox_UIBP:CheckAwardCanSign()
    local CanSign = false;
    if CanSign then
        self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(0);
    else
        self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(1);
    end
end

-- function UGC_DailyTask_BigBox_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_DailyTask_BigBox_UIBP:Destruct()
    if self.ResetTimer ~= nil then
        Timer.RemoveTimer(self.ResetTimer);
        self.ResetTimer = nil;
    end
	self.NewButton_Receive.OnClicked:RemoveAll();
end

function UGC_DailyTask_BigBox_UIBP:SetMode(IsDailyTask)
    self.IsDailyTask = IsDailyTask;
    if IsDailyTask then
        self.WidgetSwitcher_DayTask:SetActiveWidgetIndex(0);
    else
        self.WidgetSwitcher_DayTask:SetActiveWidgetIndex(1);
    end
end

function UGC_DailyTask_BigBox_UIBP:InitUI(TaskLineName)
    self.TaskLineName = TaskLineName;
    --- 设置周活跃任务的奖励
    if self.IsDailyTask then
        if self.ResetTimer ~= nil then
            Timer.RemoveTimer(self.ResetTimer);
            self.ResetTimer = nil;
        end
    else
        self:SetWeekResetAward();
    end
end

function UGC_DailyTask_BigBox_UIBP:SetWeekResetAward()
    self.CopperBoxIcon = TaskManager:GetCopperBoxIcon();
    self.SilverBoxIcon = TaskManager:GetSilverBoxIcon();
    self.GoldBoxIcon = TaskManager:GetGoldBoxIcon();

    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    local PercentAwardNum = TaskLineConfig.PercentAwardList:Num();
    if PercentAwardNum >= 3 then
        self.DailyTask_Ring_Box_01:InitUI(1, self.CopperBoxIcon, self.TaskLineName, false);
        self.DailyTask_Ring_Box_02:InitUI(2, self.SilverBoxIcon, self.TaskLineName, false);
        self.DailyTask_Ring_Box_03:InitUI(3, self.GoldBoxIcon, self.TaskLineName, false);
        self.Text_DailyTask_Ring_Box_01:SetText(tostring(TaskLineConfig.PercentAwardList[1].Percent));
        self.Text_DailyTask_Ring_Box_02:SetText(tostring(TaskLineConfig.PercentAwardList[2].Percent));
        self.Text_DailyTask_Ring_Box_03:SetText(tostring(TaskLineConfig.PercentAwardList[3].Percent));
        --- 中间显示的是最小可领取的宝箱
        self:SetButtonState();
        self:UpdateBigBoxAwardState();
    else
        sandbox.LogWarning("[UGC_DailyTask_BigBox_UIBP] PercentAwardNum < 3!");
    end
    ---设置重置时间
    if self.ResetTimer == nil then
        self.ResetTimer = Timer.InsertTimer(
            1,
            function ()
                self:SetResetTime();
            end,
            true,
            "ResetTimer",
            0
        );
    end
    self:UpdatePercent();
end

function UGC_DailyTask_BigBox_UIBP:SetResetTime()
    if self.NextResetTime == nil then
        self.NextResetTime = TaskManager:GetTaskLineResetTime(self.TaskLineName);
    end
    local ServerTime = UGCGameSystem.GetServerTimeSec();
    print(string.format("[UGC_DailyTask_BigBox_UIBP] SetResetTime ResetTime: %d CurTime: %d", self.NextResetTime or 0, ServerTime or 0));
    local RemainTime = self.NextResetTime - ServerTime;
    if RemainTime > 86400 then
        local Day = math.ceil((self.NextResetTime - ServerTime) / 86400);
        self.TextBlock_Challenge_DuringTime:SetText(string.format("%d天后重置", Day));
    elseif RemainTime > 0 then
        local Hour = math.floor(RemainTime / 3600);
        local Min = math.floor(RemainTime % 3600 / 60);
        local Sec = RemainTime % 60;
        self.TextBlock_Challenge_DuringTime:SetText(string.format("%02d:%02d:%02d后重置", Hour, Min, Sec));
    else
        ---任务线重置，刷新UI
        if self.TaskLineName then
            self.NextResetTime = TaskManager:GetTaskLineResetTime(self.TaskLineName);
            self:InitUI(self.TaskLineName);
        end
    end
end

function UGC_DailyTask_BigBox_UIBP:UpdateTaskLineAwardInfo(Index)
    if Index == 1 then
        self.DailyTask_Ring_Box_01:UpdateTaskLineAwardInfo();
    elseif Index == 2 then
        self.DailyTask_Ring_Box_02:UpdateTaskLineAwardInfo();
    elseif Index == 3 then
        self.DailyTask_Ring_Box_03:UpdateTaskLineAwardInfo();
    end
    ---更新一下大礼盒的显示
    self:UpdateBigBoxAwardState();
    ---更新领奖按钮的状态
    self:SetButtonState();
end

function UGC_DailyTask_BigBox_UIBP:UpdateTaskLineProgress()
    ---刷新进度
    self:UpdatePercent();
    ---刷新进度奖励状态
    self.DailyTask_Ring_Box_01:SetTaskLineAwardState();
    self.DailyTask_Ring_Box_02:SetTaskLineAwardState();
    self.DailyTask_Ring_Box_03:SetTaskLineAwardState();
    self:UpdateBigBoxAwardState();
    self:SetButtonState();
end

function UGC_DailyTask_BigBox_UIBP:UpdatePercent()
    print_dev("[UGC_DailyTask_BigBox_UIBP:UpdatePercent]");
    ---设置进度
    local Percent = TaskManager:GetTaskLineProgress(self.TaskLineName);
    self.TextBlock_DailyChallenge_Number:SetText(tostring(Percent));
    local TaskLineConfig = TaskManager:GetTaskLineConfig(self.TaskLineName);
    local PercentAwardNum = TaskLineConfig.PercentAwardList:Num();
    if PercentAwardNum >= 3 then
        local Percent01 = TaskLineConfig.PercentAwardList[1].Percent;
        local Percent02 = TaskLineConfig.PercentAwardList[2].Percent;
        local Percent03 = TaskLineConfig.PercentAwardList[3].Percent;
        local ShowPercent = 0;
        if Percent < Percent01 then
            ShowPercent = (Percent / Percent01) * 0.3;
        elseif Percent < Percent02 then
            ShowPercent = 0.3 + (Percent - Percent01) / (Percent02 - Percent01) * 0.3;
        elseif Percent < Percent03 then
            ShowPercent = 0.6 + (Percent - Percent02) / (Percent03 - Percent02) * 0.245;
        else
            ShowPercent = 0.845;
        end
        print(ShowPercent);
        local ImageMaterial = self.Image_schedule:GetDynamicMaterial();
        if ImageMaterial and Percent03 > 0 then
            ImageMaterial:SetScalarParameterValue("Mask_Percent", ShowPercent);
            print(string.format("[UGC_DailyTask_BigBox_UIBP:UpdatePercent] Percent: %d ShowPercent: %f", Percent, ShowPercent));
        else
            print_dev("[UGC_DailyTask_BigBox_UIBP:UpdatePercent] ImageMaterial is nil");
        end
    end
end

function UGC_DailyTask_BigBox_UIBP:UpdateBigBoxAwardState()
    print(string.format("[UGC_DailyTask_BigBox_UIBP:UpdateBigBoxAwardState]"));
    --- 中间显示的是最小可领取的宝箱
    local AwardState01 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 1);
    local AwardState02 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 2);
    local AwardState03 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 3);
    self.UGC_DailyTask_Ring_Box_Big:SetVisibility(ESlateVisibility.Visible);
    self.TextBlock_CompleteTips:SetVisibility(ESlateVisibility.Collapsed);
    if AwardState03 == EUGCTaskLineAwardState.NotClaimed then
        self.UGC_DailyTask_Ring_Box_Big:InitUI(3, self.GoldBoxIcon, self.TaskLineName, true);
    elseif AwardState02 == EUGCTaskLineAwardState.NotClaimed then
        self.UGC_DailyTask_Ring_Box_Big:InitUI(2, self.SilverBoxIcon, self.TaskLineName, true);
    elseif AwardState01 == EUGCTaskLineAwardState.NotClaimed then
        self.UGC_DailyTask_Ring_Box_Big:InitUI(1, self.CopperBoxIcon, self.TaskLineName, true);
    elseif AwardState01 == EUGCTaskLineAwardState.Lock then
        self.UGC_DailyTask_Ring_Box_Big:InitUI(1, self.CopperBoxIcon, self.TaskLineName, true);
    elseif AwardState02 == EUGCTaskLineAwardState.Lock then
        self.UGC_DailyTask_Ring_Box_Big:InitUI(2, self.SilverBoxIcon, self.TaskLineName, true);
    elseif AwardState03 == EUGCTaskLineAwardState.Lock then
        self.UGC_DailyTask_Ring_Box_Big:InitUI(3, self.GoldBoxIcon, self.TaskLineName, true);
    elseif AwardState01 == EUGCTaskLineAwardState.HasClaimed and
            AwardState02 == EUGCTaskLineAwardState.HasClaimed and
            AwardState03 == EUGCTaskLineAwardState.HasClaimed then
        self.UGC_DailyTask_Ring_Box_Big:SetVisibility(ESlateVisibility.Collapsed);
        self.TextBlock_CompleteTips:SetVisibility(ESlateVisibility.Visible);
    end
end

function UGC_DailyTask_BigBox_UIBP:SetButtonState()
    local AwardState01 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 1);
    local AwardState02 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 2);
    local AwardState03 = TaskManager:GetTaskLineAwardState(self.TaskLineName, 3);
    if AwardState01 == EUGCTaskLineAwardState.HasClaimed then
        if AwardState02 == EUGCTaskLineAwardState.HasClaimed then
            if AwardState03 == EUGCTaskLineAwardState.HasClaimed then
                ---已领取
                self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(1);
                self.Text:SetText("已领取");
            else
                if AwardState03 == EUGCTaskLineAwardState.Lock then
                    ---未解锁
                    self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(1);
                    self.Text:SetText("待完成");
                elseif AwardState03 == EUGCTaskLineAwardState.NotClaimed then
                    ---领奖
                    self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(0);
                end
            end
        else
            if AwardState02 == EUGCTaskLineAwardState.Lock then
                ---未解锁
                self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(1);
                self.Text:SetText("待完成");
            elseif AwardState02 == EUGCTaskLineAwardState.NotClaimed then
                ---领奖
                self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(0);
            end
        end
    else
        if AwardState01 == EUGCTaskLineAwardState.Lock then
            ---未解锁
            self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(1);
            self.Text:SetText("待完成");
        elseif AwardState01 == EUGCTaskLineAwardState.NotClaimed then
            ---领奖
            self.Switcher_DayTaskBig_But:SetActiveWidgetIndex(0);
        end
    end
end

return UGC_DailyTask_BigBox_UIBP