---@class WBP_TitleSwitchPanel_C:UUserWidget
---@field Btn_Close UButton
---@field VBox_TitleList UVerticalBox
--Edit Below--
local WBP_TitleSwitchPanel = {}
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

function WBP_TitleSwitchPanel:Construct()
    if self.Btn_Close and self.Btn_Close.OnClicked then
        self.Btn_Close.OnClicked:Add(self.Close, self)
    end
end

function WBP_TitleSwitchPanel:Destruct()
    if self.Btn_Close and self.Btn_Close.OnClicked then
        self.Btn_Close.OnClicked:Remove(self.Close, self)
    end
    local PC = GetLocalPC()
    if PC and PC._OnTitleSwitched == self._OnTitleSwitchedHandler then
        PC._OnTitleSwitched = nil
    end
    self._OnTitleSwitchedHandler = nil
end

function WBP_TitleSwitchPanel:RefreshList()
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
        if Data.Unlocked then
            local Item = UserWidget.NewWidgetObjectBP(PC, ItemClass)
            if Item then
                Item.OnSwitchTitle = function(TitleID, _)
                    if PC.RequestSwitchTitle then
                        pcall(PC.RequestSwitchTitle, PC, TitleID)
                    end
                end
                if Item.InitData then
                    pcall(Item.InitData, Item, Data)
                end
                self.VBox_TitleList:AddChildToVerticalBox(Item)
            end
        end
    end
end

function WBP_TitleSwitchPanel:InitUI()
    local PC = GetLocalPC()
    if PC then
        PC._OnTitleSwitched = function(CurrentID)
            if UE.IsValid(self) then
                self._ClientCurrentTitleID = CurrentID
                self:RefreshList()
            end
        end
        self._OnTitleSwitchedHandler = PC._OnTitleSwitched
    end
    self:RefreshList()
    self:SetVisibility(ESlateVisibility.Visible)
end

function WBP_TitleSwitchPanel:Close()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

return WBP_TitleSwitchPanel