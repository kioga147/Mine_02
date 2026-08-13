---@class UGC_RankingList_Set_Popup_UIBP_C:UUserWidget
---@field BtnClose UButton
---@field Button_Help UButton
---@field Button_SwitcherBut UButton
---@field Button_Yes UButton
---@field Common_PopupsBg_Small_UIBP UCommon_PopupsBg_Small_UIBP_C
---@field Common_UIPopupBG UCommon_UIPopupBG_C
---@field HorizontalBox_Won UHorizontalBox
---@field TextBlock_Details UTextBlock
---@field Title UTextBlock
---@field WidgetSwitcher_But UWidgetSwitcher
---@field WidgetSwitcher_Confirm UWidgetSwitcher
--Edit Below--
local UGC_RankingList_Set_Popup_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_Set_Popup_UIBP:Construct()
    self.Button_SwitcherBut.OnClicked:Add(self.Select, self);
    self.BtnClose.OnClicked:Add(self.Close, self);
    self.Button_Yes.OnClicked:Add(self.Confirm, self);
end

function UGC_RankingList_Set_Popup_UIBP:Select()
    print("UGC_RankingList_Set_Popup_UIBP:Select");
    local Index = self.WidgetSwitcher_But:GetActiveWidgetIndex();
    print(string.format("%s", self.IsNoname));
    if Index == 0 then
        self.WidgetSwitcher_But:SetActiveWidgetIndex(1);
        self.IsNoname = 0; 
    elseif Index == 1 then
        self.WidgetSwitcher_But:SetActiveWidgetIndex(0);
        self.IsNoname = 1; 
    end

    if self.IsNoname ~= RankingListManager:GetSelfPrivacySetting() then
        self.WidgetSwitcher_Confirm:SetActiveWidgetIndex(1);
    else
        self.WidgetSwitcher_Confirm:SetActiveWidgetIndex(0);
    end
end

function UGC_RankingList_Set_Popup_UIBP:Close()
    self:SetVisibility(ESlateVisibility.Collapsed);
end

function UGC_RankingList_Set_Popup_UIBP:Confirm()
    --- 把配置发到DS，关闭界面
    self:Close();
    RankingListManager:SetPrivacyState(self.IsNoname);
end

-- function UGC_RankingList_Set_Popup_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_Set_Popup_UIBP:Destruct()

-- end

function UGC_RankingList_Set_Popup_UIBP:InitUI()
    --- 从PlayerData中读取当前玩家的隐私设置
    local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(self);
    local UID = PlayerController:GetInt64UID();
    self.IsNoname = RankingListManager:GetSelfPrivacySetting();
    if self.IsNoname == 1 then
        self.WidgetSwitcher_But:SetActiveWidgetIndex(0);
    elseif self.IsNoname == 0 then
        self.WidgetSwitcher_But:SetActiveWidgetIndex(1);
    end
    self.WidgetSwitcher_Confirm:SetActiveWidgetIndex(0);
    self.TextBlock_Details:SetText("开启匿名上榜后, 在本玩法所有排行榜的排名不变, 但头像、ID会被神秘玩家代替(仅在 设置-隐私设置-允许他人查看绿洲启元玩法排行榜信息 为【开启】时生效)");
end

return UGC_RankingList_Set_Popup_UIBP
