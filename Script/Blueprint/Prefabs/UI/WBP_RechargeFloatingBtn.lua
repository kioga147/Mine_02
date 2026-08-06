---@class WBP_RechargeFloatingBtn_C:UUserWidget
---@field Btn_Rank UButton
---@field Btn_Recharge UButton
---@field Btn_Task UButton
--Edit Below--
local WBP_RechargeFloatingBtn = {}
local TASK_MANAGER_REQUIRE_PATH = 'ExtendResource.TaskTemplate.OfficialPackage.Script.Task.TaskManager'
local TASK_MAIN_UI_PATH = 'ExtendResource/TaskTemplate/OfficialPackage/Asset/Task/Arts_UI/UIBP/UGC_TaskMain_UIBP.UGC_TaskMain_UIBP_C'
local TASK_LEVEL_LINE_UI_PATH = 'ExtendResource/TaskTemplate/OfficialPackage/Asset/Task/Arts_UI/UIBP/UGC_LevelTask_UIBP.UGC_LevelTask_UIBP_C'
local TASK_PERCENT_LINE_UI_PATH = 'ExtendResource/TaskTemplate/OfficialPackage/Asset/Task/Arts_UI/UIBP/UGC_DailyTask_UIBP.UGC_DailyTask_UIBP_C'

local RANKING_LIST_MANAGER_REQUIRE_PATH = 'ExtendResource.RankingList.OfficialPackage.Script.RankingList.RankingListManager'
local RANK_MAIN_UI_PATH = 'ExtendResource/RankingList/OfficialPackage/Asset/RankingList/Arts_UI/UIBP/UGC_RankingList_Main_UIBP.UGC_RankingList_Main_UIBP_C'
local function LoadRankingListManager()
    local Ok = pcall(UGCGameSystem.UGCRequire, RANKING_LIST_MANAGER_REQUIRE_PATH)
    if Ok and RankingListManager then
        return RankingListManager
    end
    ugcprint('[RankBtn] RankingListManager require failed')
    return nil
end
local function LoadTaskManager()
    local Ok = pcall(UGCGameSystem.UGCRequire, TASK_MANAGER_REQUIRE_PATH)
    if Ok and TaskManager then
        return TaskManager
    end
    ugcprint('[TaskBtn] TaskManager require failed')
    return nil
end
function WBP_RechargeFloatingBtn:Construct()
    ugcprint('[ShopBtn] Construct')
    if self.Btn_Recharge and self.Btn_Recharge.OnClicked then
        self.Btn_Recharge.OnClicked:Add(self.OnBtnRechargeClicked, self)
        ugcprint('[ShopBtn] Button bound OK')
    else
        ugcprint('[ShopBtn] Button bind FAILED')
    end
    if self.Txt_Label and self.Txt_Label.SetText then
        self.Txt_Label:SetText("商城")
    end
    if self.Btn_Task and self.Btn_Task.OnClicked then
        self.Btn_Task.OnClicked:Add(self.OnBtnTaskClicked, self)
        ugcprint('[TaskBtn] Button bound OK')
    else
        ugcprint('[TaskBtn] Btn_Task not found in blueprint')
    end
    if self.Txt_TaskLabel and self.Txt_TaskLabel.SetText then
        self.Txt_TaskLabel:SetText("任务")
    end

    if self.Btn_Rank and self.Btn_Rank.OnClicked then
        self.Btn_Rank.OnClicked:Add(self.OnBtnRankClicked, self)
        ugcprint('[RankBtn] Button bound OK')
    else
        ugcprint('[RankBtn] Btn_Rank not found in blueprint')
    end
    if self.Txt_RankLabel and self.Txt_RankLabel.SetText then
        self.Txt_RankLabel:SetText("排行")
    end
end
function WBP_RechargeFloatingBtn:CreateMainUI()
    UGCGameSystem.UGCRequire('ExtendResource.ShopV2.OfficialPackage.Script.ShopV2.ShopV2Manager')
    if ShopV2Manager.MainUI ~= nil then
        ugcprint('[ShopBtn] MainUI already exists')
        return
    end
    local p = UGCGameSystem.GetUGCResourcesFullPath(
        'ExtendResource/ShopV2/OfficialPackage/Asset/ShopV2/Arts_UI/UIBP/ShopV2_MainUI_UIBP.ShopV2_MainUI_UIBP_C')
    if not p or p == '' then
        ugcprint('[ShopBtn] MainUI path not found')
        return
    end
    local cls = UE.LoadClass(p)
    if not cls then
        ugcprint('[ShopBtn] LoadClass failed')
        return
    end
    local m = UserWidget.NewWidgetObjectBP(UGCGameSystem.GetLocalPlayerController(), cls)
    if not UGCObjectUtility.IsObjectValid(m) then
        ugcprint('[ShopBtn] NewWidgetObjectBP failed')
        return
    end
    m:AddToViewport(10050)
    m:SetIsEnabled(true)
    m:SetVisibility(1)
    ugcprint('[ShopBtn] MainUI created and registered')
end
function WBP_RechargeFloatingBtn:OnBtnRechargeClicked()
    ugcprint('[ShopBtn] click')
    self:CreateMainUI()
    UGCGameSystem.UGCRequire('ExtendResource.ShopV2.OfficialPackage.Script.ShopV2.ShopV2Manager')
    if ShopV2Manager.MainUI == nil then
        ugcprint('[ShopBtn] MainUI still nil after CreateMainUI')
        return
    end
    -- Toggle: use official API for proper delegate binding
    if ShopV2Manager.MainUI:IsVisible() then
        ShopV2Manager:CloseMainUI()
        ugcprint('[ShopBtn] closed')
    else
        ShopV2Manager:OpenMainUI(1)
        ugcprint('[ShopBtn] opened')
    end
end
function WBP_RechargeFloatingBtn:CreateTaskMainUI()
    local TM = LoadTaskManager()
    if not TM then
        return
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then
        ugcprint('[TaskBtn] LocalPC nil')
        return
    end
    -- 组件已创建则优先复用组件的 TaskMainUI，避免重复创建
    local Comp = nil
    if TM.GetTaskTemplateComponent then
        local OkC, C = pcall(TM.GetTaskTemplateComponent, TM, PC)
        if OkC then
            Comp = C
        end
    end
    if Comp and UGCObjectUtility.IsObjectValid(Comp) and Comp.TaskMainUI and UGCObjectUtility.IsObjectValid(Comp.TaskMainUI) then
        self.TaskMainUI = Comp.TaskMainUI
        ugcprint('[TaskBtn] use component TaskMainUI')
        return
    end
    if self.TaskMainUI and UGCObjectUtility.IsObjectValid(self.TaskMainUI) then
        return
    end
    local p = UGCGameSystem.GetUGCResourcesFullPath(TASK_MAIN_UI_PATH)
    if not p or p == '' then
        ugcprint('[TaskBtn] TaskMainUI path not found')
        return
    end
    local cls = UE.LoadClass(p)
    if not cls then
        ugcprint('[TaskBtn] TaskMainUI LoadClass failed')
        return
    end
    local UI = UserWidget.NewWidgetObjectBP(PC, cls)
    if not UGCObjectUtility.IsObjectValid(UI) then
        ugcprint('[TaskBtn] TaskMainUI create failed')
        return
    end
    self.TaskMainUI = UI
    UI:AddToViewport(10000)
    UI:SetVisibility(ESlateVisibility.Collapsed)
    -- 手动补齐成长/活跃任务线 UI（与 TaskTemplateComponent:PreLoad 保持一致）
    local function LoadTaskLineUI(Path, InitFn)
        local LinePath = UGCGameSystem.GetUGCResourcesFullPath(Path)
        if not LinePath or LinePath == '' then
            return
        end
        local LineCls = UE.LoadClass(LinePath)
        if not LineCls then
            return
        end
        local LineUI = UserWidget.NewWidgetObjectBP(PC, LineCls)
        if UGCObjectUtility.IsObjectValid(LineUI) and UI[InitFn] then
            LineUI:AddToViewport(10000)
            LineUI:SetVisibility(ESlateVisibility.Collapsed)
            UI[InitFn](UI, LineUI)
        end
    end
    LoadTaskLineUI(TASK_LEVEL_LINE_UI_PATH, 'InitLevelTaskLineUI')
    LoadTaskLineUI(TASK_PERCENT_LINE_UI_PATH, 'InitPercentTaskLineUI')
    if Comp and Comp.TaskMainUI == nil then
        Comp.TaskMainUI = UI
    end
    ugcprint('[TaskBtn] TaskMainUI created manually')
end
function WBP_RechargeFloatingBtn:OnBtnTaskClicked()
    ugcprint('[TaskBtn] click')
    local TM = LoadTaskManager()
    if not TM then
        return
    end
    self:CreateTaskMainUI()
    local UI = self.TaskMainUI
    if not UI or not UGCObjectUtility.IsObjectValid(UI) then
        ugcprint('[TaskBtn] TaskMainUI still nil')
        return
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    local Comp = nil
    if TM.GetTaskTemplateComponent and PC then
        local OkC, C = pcall(TM.GetTaskTemplateComponent, TM, PC)
        if OkC then
            Comp = C
        end
    end
    if UI:IsVisible() then
        if Comp and Comp.CloseTaskMainUI then
            pcall(Comp.CloseTaskMainUI, Comp)
        else
            UI:SetVisibility(ESlateVisibility.Collapsed)
        end
        ugcprint('[TaskBtn] closed')
        return
    end
    if Comp and Comp.OpenTaskMainUI and Comp.TaskMainUI and UGCObjectUtility.IsObjectValid(Comp.TaskMainUI) then
        pcall(Comp.OpenTaskMainUI, Comp)
    else
        if UI.InitUI then
            pcall(UI.InitUI, UI)
        end
        UI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
    ugcprint('[TaskBtn] opened')
end
function WBP_RechargeFloatingBtn:CreateRankMainUI()
    local RM = LoadRankingListManager()
    if not RM then
        return
    end
    if self.RankMainUI and UGCObjectUtility.IsObjectValid(self.RankMainUI) then
        return
    end
    local PC = UGCGameSystem.GetLocalPlayerController()
    if not PC then
        ugcprint('[RankBtn] LocalPC nil')
        return
    end
    local Comp = nil
    if RM.GetRankingListComponent then
        local OkC, C = pcall(RM.GetRankingListComponent, RM, PC)
        if OkC then
            Comp = C
        end
    end
    if Comp and UGCObjectUtility.IsObjectValid(Comp) and Comp.RankingListMainUI and UGCObjectUtility.IsObjectValid(Comp.RankingListMainUI) then
        self.RankMainUI = Comp.RankingListMainUI
        ugcprint('[RankBtn] use component RankingListMainUI')
        return
    end
    local p = UGCGameSystem.GetUGCResourcesFullPath(RANK_MAIN_UI_PATH)
    if not p or p == '' then
        ugcprint('[RankBtn] RankMainUI path not found')
        return
    end
    local cls = UE.LoadClass(p)
    if not cls then
        ugcprint('[RankBtn] RankMainUI LoadClass failed')
        return
    end
    local UI = UserWidget.NewWidgetObjectBP(PC, cls)
    if not UGCObjectUtility.IsObjectValid(UI) then
        ugcprint('[RankBtn] RankMainUI create failed')
        return
    end
    self.RankMainUI = UI
    UI:AddToViewport(10000)
    UI:SetVisibility(ESlateVisibility.Collapsed)
    if Comp and Comp.RankingListMainUI == nil then
        Comp.RankingListMainUI = UI
    end
    ugcprint('[RankBtn] RankMainUI created manually')
end
function WBP_RechargeFloatingBtn:OnBtnRankClicked()
    ugcprint('[RankBtn] click')
    local RM = LoadRankingListManager()
    if not RM then
        return
    end
    self:CreateRankMainUI()
    local UI = self.RankMainUI
    if not UI or not UGCObjectUtility.IsObjectValid(UI) then
        ugcprint('[RankBtn] RankMainUI still nil')
        return
    end
    if UI:IsVisible() then
        if UI.Close then
            pcall(UI.Close, UI)
        else
            UI:SetVisibility(ESlateVisibility.Collapsed)
        end
        ugcprint('[RankBtn] closed')
        return
    end
    if UI.InitUI then
        pcall(UI.InitUI, UI)
    end
    UI:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    ugcprint('[RankBtn] opened')
end

function WBP_RechargeFloatingBtn:Destruct()
    if self.Btn_Recharge and self.Btn_Recharge.OnClicked then
        self.Btn_Recharge.OnClicked:Remove(self.OnBtnRechargeClicked, self)
    end
    if self.Btn_Task and self.Btn_Task.OnClicked then
        self.Btn_Task.OnClicked:Remove(self.OnBtnTaskClicked, self)
    end
    if self.Btn_Rank and self.Btn_Rank.OnClicked then
        self.Btn_Rank.OnClicked:Remove(self.OnBtnRankClicked, self)
    end
end
return WBP_RechargeFloatingBtn