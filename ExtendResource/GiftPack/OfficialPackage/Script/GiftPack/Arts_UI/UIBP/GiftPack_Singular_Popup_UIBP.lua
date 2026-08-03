---@class GiftPack_Singular_Popup_UIBP_C:UUserWidget
---@field BtnClose UButton
---@field Button_Buy UButton
---@field Common_UIPopupBG UCommon_UIPopupBG_C
---@field GiftPack_SingularList UUGC_ReuseList2_C
---@field Text UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_Btn UWidgetSwitcher
--Edit Below--
local GiftPack_Singular_Popup_UIBP = { bInitDoOnce = false } 

function GiftPack_Singular_Popup_UIBP:Construct()
    self.BtnClose.OnClicked:Add(self.Close, self);
    self.Button_Buy.OnClicked:Add(self.GetItem, self);
    self.GiftPack_SingularList.OnUpdateItem:Add(self.InitItem, self);
    self.ItemList = {};
    self.Item = {};
    self.SelectedIndex = nil;
end

function GiftPack_Singular_Popup_UIBP:InitItem(Item, Idx)
    local ItemID = self.ItemList[Idx + 1].ItemID;
    print(string.format("GiftPack_Singular_Popup_UIBP:InitItem Index: %d ItemID: %d", Idx, ItemID or -1));
    local ItemMinNum = self.ItemList[Idx + 1].ItemMinNum;
    local ItemMaxNum = self.ItemList[Idx + 1].ItemMaxNum;
    self.Item[Idx + 1] = {ItemID = ItemID, Item = Item, ItemMinNum = ItemMinNum, ItemMaxNum = ItemMaxNum};
    Item:InitUI(Idx + 1, ItemID, ItemMinNum, ItemMaxNum);
    if self.SelectedIndex and self.SelectedIndex == Idx + 1 then
        Item:Select();
    else
        Item:UnSelect();
    end
end

function GiftPack_Singular_Popup_UIBP:SelectItemByIndex(Index)
    print(string.format("GiftPack_Singular_Popup_UIBP:SelectItemByID Index: %d", Index));
    if self.Item[self.SelectedIndex] and self.Item[self.SelectedIndex].Item then
        self.Item[self.SelectedIndex].Item:UnSelect();
    end
    self.SelectedIndex = Index;
    self:ChangeSelectState();
end

function GiftPack_Singular_Popup_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function GiftPack_Singular_Popup_UIBP:GetItem()
    if self.SelectedIndex ~= nil then
        --- 消耗礼包，获得道具，最后显示UI
        local ItemNum = self.Item[self.SelectedIndex].ItemMinNum;
        local ItemID = self.Item[self.SelectedIndex].ItemID or 0;
        local ItemList = {};
        ItemList[ItemID] = ItemNum;
        print(string.format("GiftPack_Singular_Popup_UIBP:GetItem ItemID: %d ItemNum: %d", ItemID, ItemNum));
        GiftPackManager:ManualUseGiftPack(self.GiftPackID, 1, ItemList);
    end
end

function GiftPack_Singular_Popup_UIBP:SelectItem(ItemID, ItemNum)

end

function GiftPack_Singular_Popup_UIBP:ChangeSelectState()
    if self.SelectedIndex ~= nil then
        self.WidgetSwitcher_Btn:SetActiveWidgetIndex(0);    
    else
        self.WidgetSwitcher_Btn:SetActiveWidgetIndex(1);    
    end
end

-- function GiftPack_Singular_Popup_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function GiftPack_Singular_Popup_UIBP:Destruct()

-- end

function GiftPack_Singular_Popup_UIBP:InitUI(GiftPackID)
    print(string.format("[GiftPack_Singular_Popup_UIBP:InitUI] GiftPackID: %d", GiftPackID));
    local ItemList = GiftPackManager:GetItemListByGiftPackID(GiftPackID);
    print(string.format("[GiftPack_Singular_Popup_UIBP:InitUI] ItemList: %d", #ItemList));
    self.SelectedIndex = nil;
    self.ItemList = {};
    self.GiftPackID = GiftPackID;
    if ItemList and #ItemList > 0 then
        self.ItemList = ItemList;
        self.GiftPack_SingularList:Reload(#self.ItemList);
    end
    self:ChangeSelectState();
end

return GiftPack_Singular_Popup_UIBP