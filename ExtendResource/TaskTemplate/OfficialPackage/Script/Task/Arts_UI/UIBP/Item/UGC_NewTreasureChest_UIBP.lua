---@class UGC_NewTreasureChest_UIBP_C:UUserWidget
---@field Button_Receive UNewButton
---@field FX_L01 UImage
---@field FX_L02 UImage
---@field FX_L03 UImage
---@field IconGot UImage
---@field New_TaskIcon UImage
---@field New_TaskIReceived UCanvasPanel
---@field NumberText UCanvasPanel
---@field NumText UTextBlock
---@field PendingCollection UCanvasPanel
---@field TextBlock_Total UTextBlock
---@field TreasureChest_ActivityBar UProgressBar
--Edit Below--
local UGC_NewTreasureChest_UIBP = { bInitDoOnce = false } 

function UGC_NewTreasureChest_UIBP:Construct()
	self.Button_Receive.OnClicked:Add(self.ClaimPercentAward, self);
end

function UGC_NewTreasureChest_UIBP:ClaimPercentAward()
    --- 可领取则点击领取，不可领取则弹出道具Tip
    local AwardState = TaskManager:GetTaskLineAwardState(self.TaskLineName, self.Index);
    if AwardState == EUGCTaskLineAwardState.NotClaimed then
        TaskManager:ClaimTaskLineAward(self.TaskLineName, self.Index);
    else
        print("[UGC_NewTreasureChest_UIBP:ClaimPercentAward] 显示道具Tip");
        ---显示道具Tip
        local AbsPosition = SlateBlueprintLibrary.GetAbsolutePosition(self:GetCachedGeometry());
        local Position = SlateBlueprintLibrary.AbsoluteToLocal(WidgetLayoutLibrary.GetViewportWidgetGeometry(self), AbsPosition);
        log_tree("[UGC_NewTreasureChest_UIBP:ClaimPercentAward] Position", Position);
        TaskManager:ShowItemTip(self.ItemID, Position);
    end
end

-- function UGC_NewTreasureChest_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_NewTreasureChest_UIBP:Destruct()
	self.Button_Receive.OnClicked:RemoveAll();
end

function UGC_NewTreasureChest_UIBP:RefreshPercentState()
    local AwardState = TaskManager:GetTaskLineAwardState(self.TaskLineName, self.Index);
    print(string.format("[UGC_NewTreasureChest_UIBP:RefreshPercentState] Index: %s AwardState: %d", self.Index, AwardState));
    if AwardState == EUGCTaskLineAwardState.Lock then
        self.TreasureChest_ActivityBar:SetVisibility(ESlateVisibility.Collapsed);
        self.PendingCollection:SetVisibility(ESlateVisibility.Collapsed);
        self.New_TaskIReceived:SetVisibility(ESlateVisibility.Collapsed);
    elseif AwardState == EUGCTaskLineAwardState.NotClaimed then
        self.TreasureChest_ActivityBar:SetVisibility(ESlateVisibility.Visible);
        self.PendingCollection:SetVisibility(ESlateVisibility.Visible);
        self.New_TaskIReceived:SetVisibility(ESlateVisibility.Collapsed);
    elseif AwardState == EUGCTaskLineAwardState.HasClaimed then
        self.TreasureChest_ActivityBar:SetVisibility(ESlateVisibility.Visible);
        self.PendingCollection:SetVisibility(ESlateVisibility.Collapsed);
        self.New_TaskIReceived:SetVisibility(ESlateVisibility.Visible);
    end
end

function UGC_NewTreasureChest_UIBP:SetAwardInfo(ItemID, ItemNum)
    self.ItemID = ItemID;
    local ItemInfo = TaskManager:GetItemInfoByItemID(ItemID);
    if ItemInfo and ItemInfo.ItemIcon then
        Common.LoadObjectAsync(ItemInfo.ItemIcon, 
            function (IconTexture)
                if self ~= nil and UE.IsValid(self) then
                    self.New_TaskIcon:SetBrushFromTexture(IconTexture);
                end
            end)
    end
    self.TextBlock_Total:SetText(tostring(ItemNum));
end

function UGC_NewTreasureChest_UIBP:InitUI(Index, TaskLineName)
    self.Index = Index;
    self.TaskLineName = TaskLineName;
    local CurPercentNum = TaskManager:GetTaskLineProgress(TaskLineName);
    local TaskLineConfig = TaskManager:GetTaskLineConfig(TaskLineName);
    if TaskLineConfig then
        local PercentAwardList = TaskLineConfig.PercentAwardList;
        local PercentAward = PercentAwardList[Index];
        if PercentAward then
            if PercentAward.ItemList:Num() > 0 then
                local ItemID = PercentAward.ItemList[1].ItemID;
                local ItemNum = PercentAward.ItemList[1].ItemNum;
                self:SetAwardInfo(ItemID, ItemNum);
            end

            if PercentAward.Percent then
                self.TargetPercent = PercentAward.Percent;
                self.NumText:SetText(tostring(self.TargetPercent));
            end
        end
    end
    self:RefreshPercentState();
end

function UGC_NewTreasureChest_UIBP:UpdateTaskLineAwardInfo()
    self:RefreshPercentState();
end

return UGC_NewTreasureChest_UIBP