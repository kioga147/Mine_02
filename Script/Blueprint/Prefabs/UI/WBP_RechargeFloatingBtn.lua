---@class WBP_RechargeFloatingBtn_C:UAEUserWidget
---@field Btn_Recharge UButton
---@field Txt_Label UTextBlock
--Edit Below--
local WBP_RechargeFloatingBtn = {}

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

function WBP_RechargeFloatingBtn:Destruct()
    if self.Btn_Recharge and self.Btn_Recharge.OnClicked then
        self.Btn_Recharge.OnClicked:Remove(self.OnBtnRechargeClicked, self)
    end
end

return WBP_RechargeFloatingBtn
