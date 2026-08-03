---@class BP_GiftPackComponent_C:ActorComponent
---@field GiftPackApplyUIPath FSoftClassPath
---@field GiftPackSingleUIPath FSoftClassPath
---@field GiftPackComplexUIPath FSoftClassPath
---@field ItemGetUIPath FSoftClassPath
---@field ItemTipUIPath FSoftClassPath
---@field GiftPackComponentClassPath FSoftClassPath
--Edit Below--
local GiftPackComponent = {
    RequestMark = "GiftPack"
}
 
UGCGameSystem.UGCRequire("ExtendResource.GiftPack.OfficialPackage." .. "Script.GiftPack.GiftPackManager");
UGCGameSystem.UGCRequire("ExtendResource.GiftPack.OfficialPackage." .. "Script.Common.Common");

--[[
function GiftPackComponent:ReceiveBeginPlay()
    GiftPackComponent.SuperClass.ReceiveBeginPlay(self)
end
--]]

--[[
function GiftPackComponent:ReceiveTick(DeltaTime)
    GiftPackComponent.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function GiftPackComponent:ReceiveEndPlay()
    GiftPackComponent.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function GiftPackComponent:GetReplicatedProperties()
    return
end
--]]

--[[
function GiftPackComponent:GetAvailableServerRPCs()
    return
end
--]]

function GiftPackComponent:ReceiveBeginPlay()
    print("GiftPackComponent:ReceiveBeginPlay");
    GiftPackComponent.SuperClass.ReceiveBeginPlay(self)

    GiftPackManager:RegisterComponentClass(self.GiftPackComponentClassPath);
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == true then
        GMP.GlobalMessage.BindUObject(PlayerController, "UGC.GamePart.GamePartLoadedForPlayer", self, self.InitGamePart);
    else
        if UE.IsValid(self:GetVirtualItemManager()) then
            self:GetVirtualItemManager().AddItemResultDelegate:Add(self.OnAddVirtualItem, self);
        else
            GMP.GlobalMessage.BindUObject(PlayerController, "UGC.GamePart.GamePartLoaded", self, self.InitGamePart); 
        end
        self:PreLoad();
    end
end

--[[
function GiftPackComponent:ReceiveTick(DeltaTime)
    GiftPackComponent.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

function GiftPackComponent:ReceiveEndPlay()
    GiftPackComponent.SuperClass.ReceiveEndPlay(self) 

    if self:GetOwner():HasAuthority() == false then
        if UE.IsValid(self:GetVirtualItemManager()) then
            self:GetVirtualItemManager().AddItemResultDelegate:Remove(self.OnAddVirtualItem, self);
        end
    end
end

--[[
function GiftPackComponent:GetReplicatedProperties()
    return
end
--]]

function GiftPackComponent:GetAvailableServerRPCs()
    return "Server_UseGiftPack";
end

function GiftPackComponent:PreLoad()
    local PlayerController = self:GetOwner();
    Common.LoadObjectWithSoftPathAsync(self.GiftPackApplyUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.GiftPackApplyUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.GiftPackApplyUI:AddToViewport(25000);
            self.GiftPackApplyUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.GiftPackComplexUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.GiftPackComplexUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.GiftPackComplexUI:AddToViewport(25000);
            self.GiftPackComplexUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.GiftPackSingleUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.GiftPackSingleUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.GiftPackSingleUI:AddToViewport(25000);
            self.GiftPackSingleUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.ItemGetUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.ItemGetUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.ItemGetUI:AddToViewport(30000);
            self.ItemGetUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    Common.LoadObjectWithSoftPathAsync(self.ItemTipUIPath, function(Object)
        if self ~= nil and Object ~= nil then
            self.ItemTipUI = UserWidget.NewWidgetObjectBP(PlayerController, Object);
            self.ItemTipUI:AddToViewport(30000);
            self.ItemTipUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end)
    local Path = UGCGameSystem.GetUGCResourcesFullPath('Asset/Data/Table/UGCGiftPack.UGCGiftPack');
    Common.LoadObjectAsync(Path,
        function (Object)
            print("[LotteryComponent] Preload UGCGiftPack Table Success!");
        end
    );
end

function GiftPackComponent:InitGamePart(GamePartName)
    print("[GiftPackComponent:InitGamePart] Start Init GamePart");
    local PlayerController = self:GetOwner();
    if GamePartName == "VirtualItemManager" then
        self.VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager");
        print(string.format("self.VirtualItemManager %s", self.VirtualItemManager == nil));
    
        if PlayerController:HasAuthority() == false and UE.IsValid(self.VirtualItemManager) then
            self.VirtualItemManager.AddItemResultDelegate:Add(self.OnAddVirtualItem, self);
        end
    end
end

function GiftPackComponent:OpenGiftPackApplyUI(GiftPackID)
    if self.GiftPackApplyUI then
        self.GiftPackApplyUI:InitUI(GiftPackID);
        self.GiftPackApplyUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function GiftPackComponent:OpenGiftPackSinglePopupUI(GiftPackID)
    if self.GiftPackSingleUI then
        self.GiftPackSingleUI:InitUI(GiftPackID);
        self.GiftPackSingleUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function GiftPackComponent:OpenGiftPackComplexPopupUI(GiftPackID, GiftPackNum)
    if self.GiftPackComplexUI then
        self.GiftPackComplexUI:InitUI(GiftPackID, GiftPackNum);
        self.GiftPackComplexUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function GiftPackComponent:OpenItemGet(ItemList)
    if self.ItemGetUI then
        self.ItemGetUI:InitUI(ItemList);
        self.ItemGetUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function GiftPackComponent:ShowItemTip(ItemID, Position)
    if self.ItemTipUI then
        self.ItemTipUI:Refresh(ItemID, Position);
        self.ItemTipUI:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    end
end

function GiftPackComponent:SelectItemByIndex(Index)
    print(string.format("GiftPackComponent:SelectItemByID Index: %d", Index));
    if self.GiftPackSingleUI then
        self.GiftPackSingleUI:SelectItemByIndex(Index);
    end
end

function GiftPackComponent:IncreaseItem(ItemID)
    print(string.format("GiftPackComponent:IncreaseItem"));
    if self.GiftPackComplexUI then
        self.GiftPackComplexUI:IncreaseItem(ItemID);
    end
end

function GiftPackComponent:ReduceItem(ItemID)
    print(string.format("GiftPackComponent:ReduceItem"));
    if self.GiftPackComplexUI then
        self.GiftPackComplexUI:ReduceItem(ItemID);
    end
end

function GiftPackComponent:GetComplexSelectNum()
    print(string.format("GiftPackComponent:GetComplexSelectNum"));
    if self.GiftPackComplexUI then
        return self.GiftPackComplexUI:GetComplexSelectNum();
    end
    return 0;
end

function GiftPackComponent:CloseApplyGiftPackUI()
    if self.GiftPackApplyUI then
        self.GiftPackApplyUI:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function GiftPackComponent:UseGiftPack(GiftPackID, UseNum, ItemList)
    print(string.format("GiftPackComponent:UseGiftPack GiftPackID: %d UseNum: %d", GiftPackID, UseNum));
    local PlayerController = self:GetOwner();
    -- 判断是否拥有对应的礼包
    local GiftPackData = GiftPackManager:GetGiftPackDataByID(GiftPackID);
    if GiftPackData then
        local GiftPackNum = self:GetItemNum(GiftPackData.ItemID);
        if GiftPackNum < UseNum then
            print("礼包数量不足！");
            return;
        end
    else
        print("礼包不存在！");
        return;
    end

    -- 防连点
    if self.IsUsing == true then
        print("上一次使用礼包的流程还未结束！");
        return false; 
    end
    self.IsUsing = true;
    UnrealNetwork.CallUnrealRPC(PlayerController, self, "Server_UseGiftPack", PlayerController, GiftPackID, UseNum, ItemList);
end

function GiftPackComponent:Server_UseGiftPack(PlayerController, GiftPackID, UseNum, ItemList)
    print(string.format("GiftPackComponent:Server_UseGiftPack GiftPackID: %d UseNum: %d", GiftPackID, UseNum));
    if PlayerController:HasAuthority() == false then
        return; 
    end

    local GiftPackData = GiftPackManager:GetGiftPackDataByID(GiftPackID);
    if GiftPackData then
        local GiftPackNum = self:GetItemNum(GiftPackData.ItemID);
        if GiftPackNum < UseNum then
            return;
        end
        local ItemID = GiftPackData.ItemID;
        if GiftPackData.GiftPackType == EGiftPackType.Normal then
            self:AutoUseGiftPack(PlayerController, GiftPackID, ItemID, UseNum);
        elseif GiftPackData.GiftPackType == EGiftPackType.Optional then
            self:ConsumeGiftPack(PlayerController, ItemID, UseNum, ItemList);
        end
    end
    print("GiftPackComponent:Server_UseGiftPack Done");
end

function GiftPackComponent:ReadPlayerData(PlayerKey)
    if self:GetOwner():HasAuthority() == false then
        return;
    end
    print(string.format("GiftPackComponent:Begin read PlayerKey:%d PlayerData", PlayerKey));

    local UID = STExtraGameplayStatics.FindPlayerControllerWithPlayerKey(self, PlayerKey):GetInt64UID();
    local PlayerData = UGCPlayerStateSystem.GetPlayerArchiveData(UID);

    if PlayerData == nil then
        print(string.format("GiftPackComponent:UID:%d PlayerData is empty, creating new one.", UID))

        PlayerData = {
            Shop = 
            {
                PurchasedList = {},
                LimitProductList = {}
            }
        }
        UGCPlayerStateSystem.SavePlayerArchiveData(UID, PlayerData);
    end

    if PlayerData["Shop"] == nil then
        print(string.format("GiftPackComponent:UID:%d ShopData is empty, creating new one.", UID))
        
        PlayerData["Shop"] = {
            PurchasedList = {},
            LimitProductList = {}
        }
        UGCPlayerStateSystem.SavePlayerArchiveData(UID, PlayerData);
    end

    print(string.format("GiftPackComponent:Read UID:%d PlayerData Success", UID));
    return PlayerData;
end

function GiftPackComponent:WritePlayerData(PlayerKey, PlayerData)
    if self:GetOwner():HasAuthority() == false then
        return;
    end

    print(string.format("GiftPackComponent:Begin write PlayerKey:%d PlayerData", PlayerKey));

    local UID = STExtraGameplayStatics.FindPlayerControllerWithPlayerKey(self, PlayerKey):GetInt64UID();
    local bSuccess = UGCPlayerStateSystem.SavePlayerArchiveData(UID, PlayerData);

    if bSuccess == true then
        print(string.format("GiftPackComponent:Write UID:%d PlayerData Success", UID));
    else
        print(string.format("GiftPackComponent:Write UID:%d PlayerData Failed", UID));
    end
end

function GiftPackComponent:ConsumeGiftPack(PlayerController, ItemID, UseNum, ItemList)
    print(string.format("GiftPackComponent:UseGiftPack ItemID: %d UseNum: %d", ItemID, UseNum));
    if PlayerController:HasAuthority() == false then
        return;
    end

    local AwardList = {};
    for AwardID, ItemNum in pairs(ItemList) do
        print(string.format("ItemID: %d ItemNum: %d", AwardID, ItemNum));
        table.insert(AwardList, {ItemID = AwardID, ItemNum = ItemNum});
    end

    self:RemoveVirtualItem(ItemID, UseNum, function()
        local Success = self:AddVirtualItems(ItemList);
        if Success then
            self:OpenGiftPackageDelegate(AwardList);
            UnrealNetwork.CallUnrealRPC(PlayerController, self, "OpenGiftPackageDelegate", AwardList);
        end
    end)
end

function GiftPackComponent:AutoUseGiftPack(PlayerController, GiftPackID, ItemID, UseNum)
    if self:GetOwner():HasAuthority() == false then
        return;
    end

    local ItemList = GiftPackManager:GetAllGiftPackDropList(GiftPackID, UseNum);
    print(string.format("GiftPackComponent:AutoUseGiftPack ItemList: %d", #ItemList));
    self:ConsumeGiftPack(PlayerController, ItemID, UseNum, ItemList);
end

function GiftPackComponent:OnAddVirtualItem(Result)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == true then
        return;
    end
    -- 礼包使用完毕，可以进行下一次使用
    self.IsUsing = false;
    print(string.format("GiftPackComponent:OnAddVirtualItem"));
    local bSucceeded = Result.bSucceeded;
    local PlayerKey = Result.PlayerKey;
    local RequestMark = Result.RequestMark;
    local ItemList = Result.ItemList;
    local SelfPlayerKey = PlayerController:GetInt64PlayerKey();
    if bSucceeded and PlayerKey == SelfPlayerKey and RequestMark == self.RequestMark then
        local AwardList = {};
        for ItemID, ItemNum in pairs(ItemList) do
            table.insert(AwardList, {ItemID = ItemID, ItemNum = ItemNum});
        end
        self:OpenItemGet(AwardList);
        if self.GiftPackApplyUI then
            self.GiftPackApplyUI:SetVisibility(ESlateVisibility.Collapsed);
        end
        if self.GiftPackSingleUI then
            self.GiftPackSingleUI:SetVisibility(ESlateVisibility.Collapsed);
        end
        if self.GiftPackComplexUI then
            self.GiftPackComplexUI:SetVisibility(ESlateVisibility.Collapsed);
        end
    end
end

--获取已拥有的道具数量
--生效范围：客户端&&服务端
---@param ItemID number
---@return number
function GiftPackComponent:GetItemNum(ItemID)
    if UE.IsValid(self:GetVirtualItemManager()) then
        local PlayerController = self:GetOwner();
        return self:GetVirtualItemManager():GetItemNum(ItemID, PlayerController); 
    end
    return 0;
end

--添加道具 
--生效范围：客户端&&服务端
---@param AwardList any
---@return boolean
function GiftPackComponent:AddVirtualItems(AwardList)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == false then
        return false;
    end
    if UE.IsValid(self:GetVirtualItemManager()) then
        return self:GetVirtualItemManager():AddVirtualItems(PlayerController, AwardList, self.RequestMark);
    end
    return false;
end

--消耗道具
--生效范围：客户端&&服务端
---@param ItemID number
---@param Num number
---@param Callback function
function GiftPackComponent:RemoveVirtualItem(ItemID, Num, Callback)
    local PlayerController = self:GetOwner();
    if PlayerController:HasAuthority() == false then
        return;
    end
    if UE.IsValid(self:GetVirtualItemManager()) then
        self:GetVirtualItemManager():RemoveVirtualItem(PlayerController, ItemID, Num, Callback);
    end
end

function GiftPackComponent:GetVirtualItemManager()
    if self.VirtualItemManager == nil and UGCGamePartSystem.IsGamePartLoaded("VirtualItemManager") then
        self.VirtualItemManager = UGCGamePartSystem.GetGamePartGlobalActor("VirtualItemManager");
    end
    return self.VirtualItemManager;
end

----------------------------------------- API接口 -----------------------------------------
--打开礼包回调
--生效范围：客户端&&服务端
---@param ItemList any
function GiftPackComponent:OpenGiftPackageDelegate(ItemList)
    log_tree("[GiftPackComponent] OpenGiftPackageDelegate:", ItemList);
    GiftPackManager.OnOpenGiftPackageDelegate(ItemList);
end

--打开常规礼包
--生效范围：客户端&&服务端
---@param GiftPackID number
---@param UseNum number
---@param PlayerController BP_UGCPlayerController_C
function GiftPackComponent:OpenNormalGiftPackage(GiftPackID, UseNum, PlayerController)
    if PlayerController:HasAuthority() == true then
        self:Server_UseGiftPack(PlayerController, GiftPackID, UseNum, {});
    else
        UnrealNetwork.CallUnrealRPC(PlayerController, self, "Server_UseGiftPack", PlayerController, GiftPackID, UseNum, {});
    end
end

---打开自选礼包
--生效范围：客户端&&服务端
---@param GiftPackID number
---@param UseNum number
---@param ItemList any
---@param PlayerController BP_UGCPlayerController_C
function GiftPackComponent:OpenOptionalGiftPackage(GiftPackID, UseNum, ItemList, PlayerController)
    if PlayerController:HasAuthority() == true then
        self:Server_UseGiftPack(PlayerController, GiftPackID, UseNum, ItemList);
    else
        UnrealNetwork.CallUnrealRPC(PlayerController, self, "Server_UseGiftPack", PlayerController, GiftPackID, UseNum, ItemList);
    end
end

return GiftPackComponent
