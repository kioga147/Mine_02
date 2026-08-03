local Delegate = UGCGameSystem.UGCRequire("common.Delegate");

GiftPackManager = {
    GiftPackActor = nil,
    OnOpenGiftPackageDelegate = Delegate.New(),
}

GiftPackageType = {
    NOT_Package = 1,    --不是礼包
    Normal = 2,         --常规礼包
    Optional = 3,       --自选礼包
}

function GiftPackManager:GetClass(SoftClassPath)
    print("GiftPackManager:GetClass")
    if SoftClassPath == nil then
        print("GiftPackManager: SoftClassPath is not valid");
        return nil;
    end
    local Path = KismetSystemLibrary.BreakSoftClassPath(SoftClassPath);
    if Path == nil then
        print("GiftPackManager: Path is nil");
        return nil;
    end
    return UE.LoadClass(Path);
end

function GiftPackManager:RegisterComponentClass(ComponentClassPath)
    print("GiftPackManager:RegisterComponentClass")
    if self.GiftPackComponentClass == nil then
        self.GiftPackComponentClass = self:GetClass(ComponentClassPath);
    end
end

--获取玩家的GiftPackComponent
---生效范围：客户端&&服务端
---@param PlayerController BP_UGCPlayerController_C
---@return BP_GiftPackComponent_C
function GiftPackManager:GetGiftPackComponent(PlayerController)
    if PlayerController == nil and UGCGameSystem.GameState:HasAuthority() == false then
        if self.GiftPackComponent == nil then
            if self.GiftPackComponentClass ~= nil and UGCGameSystem.GameState ~= nil then
                local PlayerController = STExtraGameplayStatics.GetFirstPlayerController(UGCGameSystem.GameState);
                self.GiftPackComponent = PlayerController:GetComponentByClass(self.GiftPackComponentClass);
            else
                print("[GiftPackManager:GetGiftPackComponent] Cannot get local component!");
            end
        end
        return self.GiftPackComponent;
    end

    if self.GiftPackComponentClass ~= nil then
        return PlayerController:GetComponentByClass(self.GiftPackComponentClass);
    else
        print("[GiftPackManager:GetGiftPackComponent] ComponentClass is nil!");
        return nil;
    end
end

function GiftPackManager:GetGiftPackData()
    print("GiftPackManager:GetGiftPackData");
    if self.GiftPackDatas ~= nil then
        return self.GiftPackDatas; 
    end
    self.GiftPackDatas = {};
    local GiftPackTable = UGCGameSystem.GetTableData("Data/Table/UGCGiftPack");
    if GiftPackTable then
        for Key, Value in pairs(GiftPackTable) do
            local Data = {};
            Data.GiftPackID = Value.ID;
            ---print(string.format("GiftPackManager:GetGiftPackData GiftPackID: %d", Data.GiftPackID));
            Data.ItemID = Value.ItemID;
            Data.GiftPackType = Value.GiftPackType;
            Data.OpenWay = Value.OpenWay;
            Data.DropID = Value.DropID;
            Data.DropGroupID = Value.DropGroupID;
            self.GiftPackDatas[Data.GiftPackID] = Data;
        end
    end
    log_tree("GiftPackDatas:", self.GiftPackDatas);
    return self.GiftPackDatas;
end

function GiftPackManager:GetObjectData()
    print("GiftPackManager:GetObjectData");
    if self.ObjectDatas ~= nil then
        return self.ObjectDatas;
    end
    self.ObjectDatas = {};
    local VirtualItemManager = self:GetVirtualItemManager();
    if VirtualItemManager then
        self.ObjectDatas = VirtualItemManager:GetItemDatas();
    end
    return self.ObjectDatas;
end

function GiftPackManager:GetGiftPackDataByID(GiftPackID)
    print(string.format("GiftPackManager:GetGiftPackDataByID GiftPackID: %d", GiftPackID));
    if self.GiftPackDatas == nil then
        self:GetGiftPackData(); 
    end

    return self.GiftPackDatas[GiftPackID];
end

function GiftPackManager:GetItemInfoByItemID(ItemID)
    print(string.format("GiftPackManager:GetItemInfoByItemID ItemID: %d", ItemID));
    if self.ObjectDatas == nil then
        self:GetObjectData(); 
    end

    return self.ObjectDatas[ItemID];
end

function GiftPackManager:GetDropData()
    if self.DropDatas ~= nil then
        return self.DropDatas;
    end
    self.DropDatas = {};
    local DropTable = UGCGameSystem.GetTableData("Data/Table/UGCDrop");
    if DropTable then
        for ID, Value in pairs(DropTable) do
            ID = tonumber(ID);
            self.DropDatas[ID] = {};
            if Value.DropItemInfo then
                for Index, Info in pairs(Value.DropItemInfo) do
                    ---print(string.format("GiftPackManager:GetDropData Item: %d", Info.ItemID))
                    table.insert(self.DropDatas[ID], {ItemID = Info.ItemID, ItemMinNum = Info.ItemNumMin, ItemMaxNum = Info.ItemNumMax});
                end
            end
        end
    end
    return self.DropDatas;
end

function GiftPackManager:GetDropDataByID(DropID)
    if self.DropDatas == nil then
        self:GetDropData();
    end

    return self.DropDatas[DropID];
end

function GiftPackManager:GetDropGroupData()
    if self.DropGroupDatas ~= nil then
        return self.DropGroupDatas;
    end
    self.DropGroupDatas = {};
    local DropGroupTable = UGCGameSystem.GetTableData("Data/Table/UGCDropGroup");

    print("LotteryManager:GetDropGroupData");
    if DropGroupTable then
        for ID, Value in pairs(DropGroupTable) do
            ID = tonumber(ID);
            self.DropGroupDatas[ID] = {}
            if Value.DropGroupItemInfo then
                for Index, Info in pairs(Value.DropGroupItemInfo) do
                    local DropID = Info.DropID;
                    print(DropID);
                    local ItemList = self:GetDropDataByID(DropID);
                    table.move(ItemList, 1, #ItemList, #self.DropGroupDatas[ID] + 1, self.DropGroupDatas[ID]);
                end
            end
        end
    end
    return self.DropGroupDatas;
end

function GiftPackManager:GetDropGroupDataByID(DropGroupID)
    if self.DropGroupDatas == nil then
        self:GetDropGroupData();
    end

    return self.DropGroupDatas[DropGroupID];
end

function GiftPackManager:GetItemListByGiftPackID(GiftPackID)
    local GiftPackData = self:GetGiftPackDataByID(GiftPackID);
    local DropID = GiftPackData.DropID;
    local DropGroupID = GiftPackData.DropGroupID;
    print(string.format("GiftPackManager:GetItemListByGiftPackID DropID: %d, DropGroupID: %d", DropID, DropGroupID));

    local DropTable = GiftPackManager:GetDropData();
    if DropTable and DropTable[DropID] then
        return self:GetDropDataByID(DropID);
    end

    local DropGroupTable = GiftPackManager:GetDropGroupData();
    if DropGroupTable and DropGroupTable[DropGroupID] then
        return self:GetDropGroupDataByID(DropGroupID);
    end

    return {};
end

function GiftPackManager:OpenGiftPackApplyUI(GiftPackID)
    self:GetGiftPackComponent():OpenGiftPackApplyUI(GiftPackID);
end

function GiftPackManager:OpenGiftPackSinglePopupUI(GiftPackID)
    self:GetGiftPackComponent():OpenGiftPackSinglePopupUI(GiftPackID);
end

function GiftPackManager:OpenGiftPackComplexPopupUI(GiftPackID, GiftPackNum)
    self:GetGiftPackComponent():OpenGiftPackComplexPopupUI(GiftPackID, GiftPackNum);
end

function GiftPackManager:SelectItemByIndex(Index)
    self:GetGiftPackComponent():SelectItemByIndex(Index);
end

function GiftPackManager:IncreaseItem(ItemID)
    self:GetGiftPackComponent():IncreaseItem(ItemID);
end

function GiftPackManager:ReduceItem(ItemID)
    self:GetGiftPackComponent():ReduceItem(ItemID);
end

function GiftPackManager:GetComplexSelectNum()
    return self:GetGiftPackComponent():GetComplexSelectNum();
end

function GiftPackManager:OpenGiftPack(GiftPackID)
    ---先判断类型
    local GiftPackData = self:GetGiftPackDataByID(GiftPackID);
    if GiftPackData then
        local GiftPackNum = self:GetItemNum(GiftPackData.ItemID);
        print(string.format("GiftPackManager:OpenGiftPack GiftPackID: %d GiftPackNum: %d", GiftPackID, GiftPackNum));
        if GiftPackNum <= 0 then
            print("暂无礼包可用！");
            return false;
        end
        if GiftPackData.GiftPackType == EGiftPackType.Normal then
            if GiftPackData.OpenWay == EGiftPackOpenType.AutoOpen then
                self:AutoUseGiftPack(GiftPackID, 1);
            elseif GiftPackData.OpenWay == EGiftPackOpenType.ManuallyOpen then
                self:OpenGiftPackApplyUI(GiftPackID);
            end
        elseif GiftPackData.GiftPackType == EGiftPackType.Optional then
            ---自选礼包只支持手动打开
            self:OpenGiftPackApplyUI(GiftPackID);
        end
        return true;
    else
        print("礼包不存在！");
        return false;
    end
end

function GiftPackManager:GetGiftPackDropList(GiftPackID)
    local GiftPackData = self:GetGiftPackDataByID(GiftPackID);
    local DropID = GiftPackData.DropID;
    local DropGroupID = GiftPackData.DropGroupID;

    local DropTable = GiftPackManager:GetDropData();
    if DropTable and DropTable[DropID] then
        local DropRes = UGCDropSystem.DropItems(DropID);
        local ItemList = {};
        for ItemID, ItemNum in pairs(DropRes) do
            if ItemList[ItemID] == nil then
                ItemList[ItemID] = ItemNum;
            else
                ItemList[ItemID] = ItemList[ItemID] + ItemNum;
            end
        end
        return ItemList;
    end

    local DropGroupTable = GiftPackManager:GetDropGroupData();
    if DropGroupTable and DropGroupTable[DropGroupID] then
        local DropRes = UGCDropSystem.DropItemsByGroup(DropGroupID);
        local ItemList = {};
        for ItemID, ItemNum in pairs(DropRes) do
            if ItemList[ItemID] == nil then
                ItemList[ItemID] = ItemNum;
            else
                ItemList[ItemID] = ItemList[ItemID] + ItemNum;
            end
        end
        return ItemList;
    end

    return {};
end

function GiftPackManager:GetAllGiftPackDropList(GiftPackID, UseNum)
    local ItemList = {};
    for i=1, UseNum do
        local DropRes = GiftPackManager:GetGiftPackDropList(GiftPackID);
        for ItemID, ItemNum in pairs(DropRes) do
            if ItemList[ItemID] == nil then
                ItemList[ItemID] = ItemNum;
            else
                ItemList[ItemID] = ItemList[ItemID] + ItemNum;
            end
        end
    end

    return ItemList;
end

function GiftPackManager:OpenItemGet(ItemList)
    self:GetGiftPackComponent():OpenItemGet(ItemList);
end

function GiftPackManager:ShowItemTip(ItemID, Position)
    self:GetGiftPackComponent():ShowItemTip(ItemID, Position);
end

function GiftPackManager:CloseApplyGiftPackUI()
    self:GetGiftPackComponent():CloseApplyGiftPackUI();
end

function GiftPackManager:ManualUseGiftPack(GiftPackID, UseNum, ItemList)
    self:GetGiftPackComponent():UseGiftPack(GiftPackID, UseNum, ItemList);
end

function GiftPackManager:AutoUseGiftPack(GiftPackID, UseNum)
    self:GetGiftPackComponent():UseGiftPack(GiftPackID, UseNum, {});
end

function GiftPackManager:GetItemNum(ItemID)
    return self:GetGiftPackComponent():GetItemNum(ItemID);
end

function GiftPackManager:GetVirtualItemManager()
    if self.VirtualItemManager == nil then
        self.VirtualItemManager = UGCBlueprintFunctionLibrary.GetGamePartGlobalActor(UGCGameSystem.GameState, "VirtualItemManager");
    end
    return self.VirtualItemManager;
end

----------------------------------------- API接口 -----------------------------------------
---判断是否为礼包
---生效范围：客户端&&服务端
---@param ItemID number
---@return GiftPackageType
function GiftPackManager:GetGiftPackageType(ItemID)
    if self.GiftPackDatas == nil then
        self:GetGiftPackData();
    end
    for GiftPackID, Info in pairs(self.GiftPackDatas) do
        if Info.ItemID == ItemID then
            if Info.GiftPackType == EGiftPackType.Normal then
                return GiftPackageType.Normal;
            elseif Info.GiftPackType == EGiftPackType.Optional then
                return GiftPackageType.Optional                
            end
        end
    end
    return GiftPackageType.NOT_Package;
end

---获取礼包可掉落物品列表
---生效范围：客户端&&服务端
---@param GiftPackID number
---@return table @{[Index] = {ItemID = ItemID, ItemMinNum = ItemNumMin, ItemMaxNum = ItemNumMax}}
function GiftPackManager:GetPackageDropItems(GiftPackID)
    return self:GetItemListByGiftPackID(GiftPackID);
end

---为玩家发放礼包
---生效范围：服务端
---@param GiftPackID number
---@param Num number
---@param PlayerController BP_UGCPlayerController_C
---@return boolean
function GiftPackManager:AddGiftPackage(GiftPackID, Num, PlayerController)
    local VirtualItemManager = self:GetVirtualItemManager();
    if VirtualItemManager then
        local GiftPackData = self:GetGiftPackDataByID(GiftPackID);
        if GiftPackData and GiftPackData.ItemID then
            return VirtualItemManager:AddVirtualItem(PlayerController, GiftPackData.ItemID, Num);
        end
    end
    return false;
end

---打开常规礼包
---生效范围：客户端&&服务端
---@param GiftPackID number
---@param UseNum number
---@param PlayerController BP_UGCPlayerController_C
function GiftPackManager:OpenNormalGiftPackage(GiftPackID, UseNum, PlayerController)
    self:GetGiftPackComponent(PlayerController):OpenNormalGiftPackage(GiftPackID, UseNum, PlayerController);
end

---打开自选礼包
---生效范围：客户端&&服务端
---@param GiftPackID number
---@param UseNum number
---@param ItemList any
---@param PlayerController BP_UGCPlayerController_C
function GiftPackManager:OpenOptionalGiftPackage(GiftPackID, UseNum, ItemList, PlayerController)
    self:GetGiftPackComponent(PlayerController):OpenOptionalGiftPackage(GiftPackID, UseNum, ItemList, PlayerController);
end