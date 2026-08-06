---@class ShopV2Component_C:ActorComponent
---@field ShowTestButton bool
---@field MainUIClassPath FSoftClassPath
---@field TestButtonPath FSoftClassPath
---@field ItemQualityTablePath FSoftObjectPath
--Edit Below--

UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage." .. "Script.ShopV2.ShopV2Manager");
UGCGameSystem.UGCRequire("ExtendResource.ShopV2.OfficialPackage." .. "Script.Common.Common");

local Delegate = UGCGameSystem.UGCRequire("common.Delegate");
local STExtraGMDelegatesMgr = KismetLibrary.New("/Script/ShadowTrackerExtra.STExtraGMDelegatesMgr");

local ShopV2Component = {}

function ShopV2Component:ReceiveBeginPlay()
    
    ShopV2Manager:RegisterComponentClass(GameplayStatics.GetObjectClass(self));

    if KismetSystemLibrary.BreakSoftObjectPath(self.ItemQualityTablePath) ~= "" then
        Common.LoadObjectWithSoftPathAsync(self.ItemQualityTablePath, 
            function (Asset)
                if self ~= nil then
                    self:ReadItemQualityTable();
                end
            end
        );
    end

    if self:GetOwner():HasAuthority() == false then
        self:InitShopUI();
    end
end

function ShopV2Component:ReceiveEndPlay()
    
end

function ShopV2Component:InitShopUI()

    Common.LoadObjectWithSoftPathAsync(self.MainUIClassPath, 
        function (MainUIClass)
            if self == nil or MainUIClass == nil then
                print("[ShopV2Component:InitShopUI] MainUIClass load failed");
                return;
            end

            local MainUI = UserWidget.NewWidgetObjectBP(self:GetOwner(), MainUIClass);
            MainUI:AddToViewport(10050);
            MainUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    );

    if self.ShowTestButton == true then
        Common.LoadObjectWithSoftPathAsync(self.TestButtonPath, 
            function (ButtonClass)
                if self == nil or ButtonClass == nil then
                    print("[ShopV2Component:InitShopUI] TestButtonClass load failed");
                    return;
                end
                
                local Button = UserWidget.NewWidgetObjectBP(self:GetOwner(), ButtonClass);
                Button:AddToViewport(10000);
            end
        );
    end
end

function ShopV2Component:ReadItemQualityTable()
    
    print("[ShopV2Component:ReadItemQualityTable] Start read item quality rank");
    ShopV2Manager.ItemQuality = {};

    if self.ItemQualityTablePath == nil then
        print("[ShopV2Component:ReadItemQualityTable] ItemQualityTablePath is nil");
        return;
    end

    local Path = Common.GetDataTablePath(self.ItemQualityTablePath);
    if Path == "" then
        print("[ShopV2Component:ReadItemQualityTable] ItemQualityTablePath is empty");
        return;
    end

    local Table = UGCGameSystem.GetTableData(Common.GetDataTablePath(self.ItemQualityTablePath));
    for _, Data in pairs(Table) do
        ShopV2Manager.ItemQuality[Data.ItemID] = Data.QualityRank;
    end
end

return ShopV2Component
