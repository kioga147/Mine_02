---@class UGC_DailyTask_Award_UIBP_C:UUserWidget
---@field Image_Icon UImage
---@field Image_QualityBg UImage
---@field NewButton_Click UNewButton
---@field TextBlock_ItemNum UTextBlock
--Edit Below--
local UGC_DailyTask_Award_UIBP = { bInitDoOnce = false } 

function UGC_DailyTask_Award_UIBP:Construct()
	self.NewButton_Click.OnClicked:Add(self.Click, self);
end

function UGC_DailyTask_Award_UIBP:Click()
    print("[UGC_DailyTask_Award_UIBP:Click] 显示道具Tip");
    if self.ItemID then
        ---显示道具Tip
        local AbsPosition = SlateBlueprintLibrary.GetAbsolutePosition(self:GetCachedGeometry());
        local Position = SlateBlueprintLibrary.AbsoluteToLocal(WidgetLayoutLibrary.GetViewportWidgetGeometry(self), AbsPosition);
        TaskManager:ShowItemTip(self.ItemID, Position);
    end
end

-- function UGC_DailyTask_Award_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_DailyTask_Award_UIBP:Destruct()
	self.NewButton_Click.OnClicked:RemoveAll();
end

function UGC_DailyTask_Award_UIBP:InitUI(ItemID, ItemNum)
    print(string.format("[UGC_DailyTask_Award_UIBP:InitUI] ItemID: %d ItemNum: %d", ItemID or 0, ItemNum or 0));
    self.ItemID = ItemID;
    local ItemInfo = TaskManager:GetItemInfoByItemID(ItemID);
    if ItemInfo and ItemInfo.ItemIcon then
        Common.LoadObjectAsync(ItemInfo.ItemIcon, 
            function (IconTexture)
                if self ~= nil and UE.IsValid(self) then
                    self.Image_Icon:SetBrushFromTexture(IconTexture);
                end
            end)
    end
    self.TextBlock_ItemNum:SetText(tostring(ItemNum));
end

return UGC_DailyTask_Award_UIBP