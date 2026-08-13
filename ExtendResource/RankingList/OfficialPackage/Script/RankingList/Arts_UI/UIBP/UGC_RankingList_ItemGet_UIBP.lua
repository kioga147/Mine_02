---@class UGC_RankingList_ItemGet_UIBP_C:UUserWidget
---@field DX_Parachute UWidgetAnimation
---@field DX_GXHD UWidgetAnimation
---@field Button_Close UButton
---@field Button_Mask UButton
---@field CanvasPanel_Arrow UCanvasPanel
---@field CanvasPanel_List02 UCanvasPanel
---@field DesText UUTRichTextBlock
---@field Image_17 UImage
---@field Image_18 UImage
---@field Image_19 UImage
---@field NewButton_Confirm UNewButton
---@field NewButton_OK UNewButton
---@field NewButton_Use UNewButton
---@field PlaceTitle01 UHorizontalBox
---@field PlaceTitle02 UHorizontalBox
---@field PlaceTitle03 UHorizontalBox
---@field SizeBox_ItemGet_UseImmediately USizeBox
---@field TextBlock_Use UTextBlock
---@field UGC_ReuseList2_Item1 UUGC_ReuseList2_C
---@field UGC_ReuseList2_Item2 UUGC_ReuseList2_C
---@field UIParticleEmitter_0 UUIParticleEmitter
---@field WidgetSwitcher_ItemGet UWidgetSwitcher
--Edit Below--

local UGC_RankingList_ItemGet_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_ItemGet_UIBP:Construct()
	self:InitBindEvent();
end

function UGC_RankingList_ItemGet_UIBP:InitBindEvent()
    self.UGC_ReuseList2_Item1.OnAfterNewItem:Add(self.InitUpItem, self);
    self.UGC_ReuseList2_Item2.OnAfterNewItem:Add(self.InitDownItem, self);
    self.NewButton_Confirm.OnClicked:Add(self.ConfirmBtnClick, self);
end

function UGC_RankingList_ItemGet_UIBP:InitUpItem(Item, Index)
    local ItemID = self.ItemUpList[Index + 1].ItemID;
    local ItemNum = self.ItemUpList[Index + 1].ItemNum;
    Item:InitUI(ItemID, ItemNum);
end

function UGC_RankingList_ItemGet_UIBP:InitDownItem(Item, Index)
    local ItemID = self.ItemDownList[Index + 1].ItemID;
    local ItemNum = self.ItemDownList[Index + 1].ItemNum;
    Item:InitUI(ItemID, ItemNum);
end

function UGC_RankingList_ItemGet_UIBP:ConfirmBtnClick()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

-- function UGC_RankingList_ItemGet_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_ItemGet_UIBP:Destruct()

-- end

function UGC_RankingList_ItemGet_UIBP:InitUI(ItemList)
    print("UGC_RankingList_ItemGet_UIBP:InitUI");
    if ItemList then
        print(#ItemList);
        self.ItemUpList = ItemList;
        self.UGC_ReuseList2_Item2:SetVisibility(ESlateVisibility.Collapsed);
        self.DesText:SetVisibility(ESlateVisibility.Collapsed);

        self.UGC_ReuseList2_Item1:Reload(#ItemList);
        self.WidgetSwitcher_ItemGet:SetActiveWidgetIndex(1);

        if CheckObjectContainsField(self, "DX_GXHD") then
            self:PlayAnimation(self.DX_GXHD, 0, 1, EUMGSequencePlayMode.Forward, 1);
        end
    end
end

return UGC_RankingList_ItemGet_UIBP
