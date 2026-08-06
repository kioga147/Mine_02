---@class UGC_Growing_SignPointPage_1_C:UUserWidget
---@field CanvasPanel_Point UCanvasPanel
---@field Image_Fengexian01 UImage
---@field Image_Fengexian02 UImage
---@field Signitem01 UUGC_Growing_SignPoint_UIBP_C
---@field Signitem02 UUGC_Growing_SignPoint_UIBP_C
--Edit Below--
local UGC_Growing_SignPointPage_1 = { bInitDoOnce = false } 

function UGC_Growing_SignPointPage_1:Construct()
	self.LevelTaskItem = {
        [1] = self.Signitem01,
        [2] = self.Signitem02,
    }
    self.LevelLine = {
        [1] = self.Image_Fengexian01,
        [2] = self.Image_Fengexian02,
    }
end

-- function UGC_Growing_SignPointPage_1:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_Growing_SignPointPage_1:Destruct()

-- end

function UGC_Growing_SignPointPage_1:InitUI(LevelIdxList, IsEnd, TaskLineName)
    local TaskItemNum = #LevelIdxList;
    if TaskItemNum == 1 then
        self.LevelTaskItem[2]:SetVisibility(ESlateVisibility.Collapsed);
        self.LevelTaskItem[1]:InitUI(LevelIdxList[1], TaskLineName);
        self.LevelLine[1]:SetVisibility(ESlateVisibility.Collapsed);
        self.LevelLine[2]:SetVisibility(ESlateVisibility.Collapsed);
    elseif TaskItemNum == 2 then
        self.LevelTaskItem[2]:SetVisibility(ESlateVisibility.Visible);
        self.LevelTaskItem[1]:InitUI(LevelIdxList[1], TaskLineName);
        self.LevelTaskItem[2]:InitUI(LevelIdxList[2], TaskLineName);
        if IsEnd then
            self.LevelLine[1]:SetVisibility(ESlateVisibility.Visible);
            self.LevelLine[2]:SetVisibility(ESlateVisibility.Collapsed);
        else
            self.LevelLine[1]:SetVisibility(ESlateVisibility.Visible);
            self.LevelLine[2]:SetVisibility(ESlateVisibility.Visible);
        end
    end
end

return UGC_Growing_SignPointPage_1