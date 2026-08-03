---@class GiftPack_Complex_Popup_UIBP_C:UUserWidget
---@field BtnClose UButton
---@field Button_Buy UButton
---@field Common_UIPopupBG UCommon_UIPopupBG_C
---@field GiftPack_ComplexList UUGC_ReuseList2_C
---@field Text UTextBlock
---@field TextBlock_Choice02 UTextBlock
---@field TextBlock_Copywriting01 UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_Btn UWidgetSwitcher
--Edit Below--
local GiftPack_Complex_Popup_UIBP = { bInitDoOnce = false } 

function GiftPack_Complex_Popup_UIBP:Construct()
    self.BtnClose.OnClicked:Add(self.Close, self);
    self.Button_Buy.OnClicked:Add(self.GetItem, self);
    self.GiftPack_ComplexList.OnUpdateItem:Add(self.InitItem, self);
    self.Item = {};
    self.ItemList = {};
end

-- function GiftPack_Complex_Popup_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function GiftPack_Complex_Popup_UIBP:Destruct()

-- end

function GiftPack_Complex_Popup_UIBP:GetItem()
    if self.AllSelectNum == self.GiftPackNum then
        --- 消耗礼包，获得道具，最后显示UI
        local ItemList = self:GetItemList();
        GiftPackManager:ManualUseGiftPack(self.GiftPackID, self.GiftPackNum, ItemList);
    end
end

function GiftPack_Complex_Popup_UIBP:GetItemList()
    local ItemList = {};
    for ItemID, SelectNum in pairs(self.SelectNum) do
        if SelectNum > 0 then
            local ItemNum = self.Item[ItemID].ItemMinNum;
            print(string.format("GiftPack_Complex_Popup_UIBP:GetItemList ItemID: %d ItemNum: %d", ItemID, SelectNum * ItemNum));
            local ItemInfo = {ItemID = ItemID, ItemNum = SelectNum * ItemNum};
            ItemList[ItemID] = SelectNum * ItemNum;
        end
    end
    return ItemList;
end

function GiftPack_Complex_Popup_UIBP:InitItem(Item, Idx)
    print(string.format("GiftPack_Complex_Popup_UIBP:InitItem Index: %d", Idx));
    local ItemID = self.ItemList[Idx + 1].ItemID;
    local ItemMinNum = self.ItemList[Idx + 1].ItemMinNum;
    local ItemMaxNum = self.ItemList[Idx + 1].ItemMaxNum;
    self.Item[ItemID] = {Item = Item, ItemMinNum = ItemMinNum, ItemMaxNum = ItemMaxNum};
    local CanSelectNum = self:GetComplexSelectNum();
    Item:InitUI(ItemID, ItemMinNum, ItemMaxNum, self.GiftPackNum, CanSelectNum, self.SelectNum[ItemID]);
end

function GiftPack_Complex_Popup_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function GiftPack_Complex_Popup_UIBP:ChangeSelectState()
    if self.AllSelectNum == self.GiftPackNum then
        self.WidgetSwitcher_Btn:SetActiveWidgetIndex(0);    
    else
        self.WidgetSwitcher_Btn:SetActiveWidgetIndex(1);    
    end
end

function GiftPack_Complex_Popup_UIBP:IncreaseItem(ItemID)
    if self.SelectNum[ItemID] then
        if self.AllSelectNum < self.GiftPackNum then
            print("GiftPack_Complex_Popup_UIBP:IncreaseItem");
            self.SelectNum[ItemID] = self.SelectNum[ItemID] + 1;
            self.AllSelectNum = self.AllSelectNum + 1;
            self:ChangeNum();
            self:ChangeSelectState();

            if self.AllSelectNum >= self.GiftPackNum then
                for ItemID, Item in pairs(self.Item) do
                    Item.Item:ForbiddenIncrease();
                end 
            end
        end
    end
end

function GiftPack_Complex_Popup_UIBP:ReduceItem(ItemID)
    if self.SelectNum[ItemID] then
        if self.AllSelectNum > 0 and self.SelectNum[ItemID] > 0 then
            print("GiftPack_Complex_Popup_UIBP:ReduceItem")
            self.SelectNum[ItemID] = self.SelectNum[ItemID] - 1;
            self.AllSelectNum = self.AllSelectNum - 1;
            self:ChangeNum();
            self:ChangeSelectState();
            
            for ItemID, Item in pairs(self.Item) do
                Item.Item:AllowIncrease();
            end 
        end
    end
end

function GiftPack_Complex_Popup_UIBP:GetComplexSelectNum()
    local CanSelectNum = self.GiftPackNum - self.AllSelectNum;
    if CanSelectNum < 0 then
        CanSelectNum = 0; 
    end
    return CanSelectNum;
end

function GiftPack_Complex_Popup_UIBP:ChangeNum()
    self.TextBlock_Choice02:SetText(string.format("%d/%d", self.AllSelectNum, self.GiftPackNum));
end

function GiftPack_Complex_Popup_UIBP:InitUI(GiftPackID, GiftPackNum)
    self.GiftPackNum = GiftPackNum;
    self.GiftPackID = GiftPackID;
    self.SelectNum = {};
    self.AllSelectNum = 0;
    print(string.format("[GiftPack_Complex_Popup_UIBP:InitUI] GiftPackID: %d", GiftPackID));
    local ItemList = GiftPackManager:GetItemListByGiftPackID(GiftPackID);
    print(string.format("[GiftPack_Complex_Popup_UIBP:InitUI] ItemList: %d", #ItemList));
    if ItemList and #ItemList > 0 then
        self.ItemList = ItemList;
        for Index, Item in pairs(self.ItemList) do
            self.SelectNum[Item.ItemID] = 0;
        end
        self.GiftPack_ComplexList:Reload(#ItemList); 
    end
    self:ChangeNum();
    self:ChangeSelectState();
    self.TextBlock_Copywriting01:SetText(string.format("请从以下道具中选择%d个获得奖励", self.GiftPackNum));
end

return GiftPack_Complex_Popup_UIBP
