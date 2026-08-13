---@class WBP_TitleAchievementPanel_C:UUserWidget
---@field Btn_Close UButton
---@field VBox_TitleList UVerticalBox
--Edit Below--
local WBP_TitleAchievementPanel = {}
local TITLE_LIST_ITEM_PATH = 'Asset/Blueprint/Prefabs/UI/WBP_TitleListItem.WBP_TitleListItem_C'
local function GetLocalPC()
    if UGCGameSystem and UGCGameSystem.GetLocalPlayerController then
        local Ok, PC = pcall(UGCGameSystem.GetLocalPlayerController)
        if Ok then
            return PC
        end
    end
    return nil
end
local function LoadTitleItemClass()
    local p = UGCGameSystem.GetUGCResourcesFullPath(TITLE_LIST_ITEM_PATH)
    if not p or p == '' then
        ugcprint('[称号] WBP_TitleListItem path not found')
        return nil
    end
    return UE.LoadClass(p)
end
function WBP_TitleAchievementPanel:Construct()
    if self.Btn_Close and self.Btn_Close.OnClicked then
        self.Btn_Close.OnClicked:Add(self.Close, self)
    end
end
function WBP_TitleAchievementPanel:Destruct()
    if self.Btn_Close and self.Btn_Close.OnClicked then
        self.Btn_Close.OnClicked:Remove(self.Close, self)
    end
end
function WBP_TitleAchievementPanel:RefreshList()
    if not self.VBox_TitleList then
        return
    end
    self.VBox_TitleList:ClearChildren()
    local PC = GetLocalPC()
    if not PC then
        return
    end
    local List = {}
    if PC.GetTitleListForUI then
        local Ok, L = pcall(PC.GetTitleListForUI, PC)
        if Ok and type(L) == "table" then
            List = L
        end
    end
    local ItemClass = LoadTitleItemClass()
    if not ItemClass then
        return
    end
    for _, Data in ipairs(List) do
        local Item = UserWidget.NewWidgetObjectBP(PC, ItemClass)
        if Item then
            if Data.Unlocked then
                Item.OnSwitchTitle = function(TitleID, _)
                    if PC.RequestSwitchTitle then
                        pcall(PC.RequestSwitchTitle, PC, TitleID)
                    end
                    self:Close()
                end
            end
            if Item.InitData then
                pcall(Item.InitData, Item, Data)
            end
            self.VBox_TitleList:AddChildToVerticalBox(Item)
        end
    end
end
function WBP_TitleAchievementPanel:InitUI()
    self:RefreshList()
    self:SetVisibility(ESlateVisibility.Visible)
end
function WBP_TitleAchievementPanel:Close()
    self:SetVisibility(ESlateVisibility.Collapsed)
end
return WBP_TitleAchievementPanel