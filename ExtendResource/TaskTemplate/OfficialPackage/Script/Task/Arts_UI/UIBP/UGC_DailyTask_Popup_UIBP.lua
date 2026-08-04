---@class UGC_DailyTask_Popup_UIBP_C:UUserWidget
---@field CloseButton UNewButton
---@field Common_PopupsBg_Medium_UIBP Common_PopupsBg_Medium_UIBP_C
---@field DailyTaskList UGC_ReuseList2_C
---@field Title_Name UTextBlock
--Edit Below--
local UGC_DailyTask_Popup_UIBP = { bInitDoOnce = false } 

function UGC_DailyTask_Popup_UIBP:Construct()
    self.DailyTaskList.OnUpdateItem:Add(self.InitItem, self);
    self.CloseButton.OnClicked:Add(self.Close, self);
end

function UGC_DailyTask_Popup_UIBP:InitItem(Item, Index)
    local Award = self.AwardList[Index + 1];
    Item:InitUI(Award.ItemID, Award.ItemNum);
end

function UGC_DailyTask_Popup_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

-- function UGC_DailyTask_Popup_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

function UGC_DailyTask_Popup_UIBP:Destruct()
    self.DailyTaskList.OnUpdateItem:RemoveAll();
    self.CloseButton.OnClicked:RemoveAll();
end

function UGC_DailyTask_Popup_UIBP:InitUI(AwardList)
    self.AwardList = AwardList;
    local AwardNum = AwardList:Num();
    self.DailyTaskList:Reload(AwardNum);
end

return UGC_DailyTask_Popup_UIBP