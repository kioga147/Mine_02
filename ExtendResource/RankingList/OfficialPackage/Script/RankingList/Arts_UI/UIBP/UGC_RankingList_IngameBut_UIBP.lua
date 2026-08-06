---@class UGC_RankingList_IngameBut_UIBP_C:UUserWidget
---@field Button_RankBut UButton
---@field Image_Bg_Default UImage
--Edit Below--
local UGC_RankingList_IngameBut_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_IngameBut_UIBP:Construct()
	self.Button_RankBut.OnClicked:Add(self.RankClick, self);
end

-- function UGC_RankingList_IngameBut_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_IngameBut_UIBP:Destruct()

-- end

function UGC_RankingList_IngameBut_UIBP:RankClick()
    print("UGC_RankingList_IngameBut_UIBP:RankClick");
    RankingListManager:OpenRankingList();
end

function UGC_RankingList_IngameBut_UIBP:RefreshRedPoint()
    print("UGC_RankingList_IngameBut_UIBP:RefreshRedPoint");
    local CanSign, _ = RankingListManager:GetAllRankListRedPoint();
    if CanSign then
        self.Image_Bg_Default:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    else
        self.Image_Bg_Default:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function UGC_RankingList_IngameBut_UIBP:InitUI()
    print("UGC_RankingList_IngameBut_UIBP:InitUI");
    self:RefreshRedPoint();
end

return UGC_RankingList_IngameBut_UIBP
