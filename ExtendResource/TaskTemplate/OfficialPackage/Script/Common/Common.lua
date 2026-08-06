Common = Common or {}

CommonImpl = CommonImpl or {};

---@param SoftObjectPath FSoftObjectPath
function Common.GetDataTablePath(SoftObjectPath)
    
    local Path = KismetSystemLibrary.BreakSoftObjectPath(SoftObjectPath);
    Path = string.match(Path, "^.*Asset/(.+)$") or "";
    Path = string.match(Path, "^([^%.]+)") or "";

    return Path;
end

---@param SoftClassPath FSoftClassPath
function Common.GetClassWithSoftPath(SoftClassPath)
    
    if SoftClassPath == nil then
        print("SignInEventManager: SoftClassPath is not valid");
        return nil;
    end

    local Path = KismetSystemLibrary.BreakSoftClassPath(SoftClassPath);
    if Path == nil then
        print("SignInEventManager: Path is nil");
        return nil;
    end

    return UE.LoadClass(Path);
end

function Common.GetProductDatas()
   
    return CommonImpl:GetProductDatas();
end

function Common.GetObjectDatas()
    
    return CommonImpl:GetObjectDatas();
end

--- 异步加载 Object
---@param SourcePath string
---@param CallBack function
function Common.LoadObjectAsync(SourcePath, CallBack)
    
    local SoftObjectPath = KismetSystemLibrary.MakeSoftObjectPath(SourcePath);
    Common.LoadObjectWithSoftPathAsync(SoftObjectPath, CallBack);
end

--- 异步加载 Object
---@param SoftObjectPath FSoftObjectPath
---@param CallBack function
function Common.LoadObjectWithSoftPathAsync(SoftObjectPath, CallBack)

    if UGCGameSystem.GameState == nil or UE.IsValid(UGCGameSystem.GameState) == false then
        return
    end

    if CallBack == nil then
        return
    end

    if type(CallBack) ~= "function" then
        return
    end

    if UGCGameSystem.GameState.AsyncDelegate == nil then
        UGCGameSystem.GameState.AsyncDelegate = {}
        UGCGameSystem.GameState.AsyncDelegateIndex = 0
    end

    UGCGameSystem.GameState.AsyncDelegateIndex = UGCGameSystem.GameState.AsyncDelegateIndex + 1
    local AsyncDelegateIndex = UGCGameSystem.GameState.AsyncDelegateIndex 
    UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex] = ObjectExtend.CreateDelegate(UGCGameSystem.GameState, 
        function (Asset)

            if UGCGameSystem.GameState == nil or UE.IsValid(UGCGameSystem.GameState) == false then
                return
            end

            if Asset == nil then
                print("UGCAsyncLoadTools:LoadObject Error:" ..  KismetSystemLibrary.BreakSoftObjectPath(SoftObjectPath));

                if UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex] then
                    ObjectExtend.DestroyDelegate(UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex])
                    UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex] = nil
                end

                return
            end

            CallBack(Asset)
        
            if UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex] then
                ObjectExtend.DestroyDelegate(UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex])
                UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex] = nil
            end
        end
    )

    STExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(SoftObjectPath, UGCGameSystem.GameState.AsyncDelegate[AsyncDelegateIndex], true)
end

---@return osdate
function Common.GetCurrentDate()
    
    return os.date("*t", Common.GetCurrentTime());
end

function Common.GetCurrentTime(bPrintLog)

    if bPrintLog == nil then
        bPrintLog = true;
    end
    
    local CurrentTime = UGCGameSystem.GetServerTimeSec();
    if CurrentTime == false then
        CurrentTime = 0;
    end

    if bPrintLog == true then
        print(string.format("[Common.GetCurrentTime] Current Timestamp=%d", CurrentTime));
    end

    return CurrentTime;
end

---@param StartDate FDateTime
---@param EndDate FDateTime
function Common.CheckStartEndDate(StartDate, EndDate)
    
    print(string.format("[Common.CheckStartEndDate] Start check start end date"));

    local CurrentTime = Common.GetCurrentTime();
    local StartTime = Common.GetTimestampFromDateTime(StartDate);
    print(string.format("[Common.CheckStartEndDate] StartTime=%d", StartTime));
    local EndTime = Common.GetTimestampFromDateTime(EndDate);
    print(string.format("[Common.CheckStartEndDate] EndTime=%d", EndTime));

    return CurrentTime >= StartTime and CurrentTime < EndTime;
end

---@param StartTime int
---@param EndTime int
function Common.CheckStartEndTime(StartTime, EndTime)
    
    print(string.format("[Common.CheckStartEndDate] Start check start end time"));

    local CurrentTime = Common.GetCurrentTime();
    print(string.format("[Common.CheckStartEndDate] StartTime=%d", StartTime));
    print(string.format("[Common.CheckStartEndDate] EndTime=%d", EndTime));

    return CurrentTime >= StartTime and CurrentTime < EndTime;
end

---@param Date FDateTime
---@return number
function Common.GetTimestampFromDateTime(Date)
    
    local Year, Month, Day, Hour, Minute, Second = KismetMathLibrary.BreakDateTime(Date);
    Year = Year < 1970 and 1970 or Year;
    Hour = Hour + 8;
    
    -- Lua 时间戳有最大值，大约大于了 3000.1.1 就会返回 nil
    local Time = os.time({year=Year, month=Month, day=Day, hour=Hour, min=Minute, sec=Second});
    Time = Time == nil and 32503694400 or Time;

    return Time;
end

function CommonImpl:GetProductDatas()
    
    if self.ProductDatas == nil then
        self:ReadProductTable();
    end

    return self.ProductDatas;
end

function CommonImpl:GetObjectDatas()
    
    if self.ObjectDatas == nil then
        self:ReadObjectTable();
    end

    return self.ObjectDatas;
end

local function Compare(ProductIDA, ProductIDB)
    
    local ProductDataA = ShopManager:GetProductData(ProductIDA);
    local ProductDataB = ShopManager:GetProductData(ProductIDB);

    if ProductDataA.SortPriority ~= ProductDataB.SortPriority then
        return ProductDataA.SortPriority < ProductDataB.SortPriority;
    end
    
    -- 优先级一样按照 ID 排序
    return ProductDataA.ProductId < ProductDataB.ProductId;
end

function CommonImpl:ReadProductTable()

    local Table = UGCGameSystem.GetTableData("Data/Table/UGCShop");

    self.ProductDatas = {};

    self.ProductIDGroupByTabID = {};

    for i, Data in pairs(Table) do

        ---@type FUGCProductData
        local ProductData = {};
        ProductData.ProductId               = Data["ProductId"];
        ProductData.ProductName             = Data["ProductName"];
        ProductData.ItemID                  = Data["ItemID"];
        ProductData.ItemNum                 = Data["ItemNum"];
        ProductData.CostID                  = Data["CostID"];
        ProductData.AvailableForSale        = Data["AvailableForSale"]
        ProductData.LimitType               = Data["LimitType"];
        ProductData.SellingPrice            = Data["SellingPrice"];
        ProductData.PurchaseLimit           = Data["PurchaseLimit"];
        ProductData.ListingTimeString       = Data["ListingTimeString"];
        ProductData.DelistingTimeString     = Data["DelistingTimeString"];
        ProductData.SortPriority            = Data["SortPriority"];
        ProductData.StoreID                 = Data["StoreId"];
        ProductData.CurrencyType            = Data["CurrencyType"];
        ProductData.TabID                   = Data["TabID"];
        ProductData.DiscountStartTime       = Data["DiscountStartTime"]:Copy();
        ProductData.DiscountEndTime         = Data["DiscountEndTime"]:Copy();
        ProductData.Discount                = Data["Discount"];
        ProductData.CurrencyType            = Data["CurrencyType"];
        ProductData.ProductType             = Data["ProductType"];

        self.ProductDatas[ProductData.ProductId] = ProductData;

        --- 按照 TabID 分组
        local TabID = tostring(Data["TabID"]);
        self.ProductIDGroupByTabID[TabID] = self.ProductIDGroupByTabID[TabID] or {};
        --- 只添加有效的商品到分组
        if self:IsProductValid(ProductData.ProductId) == true then
            table.insert(self.ProductIDGroupByTabID[TabID], ProductData.ProductId);
        end
    end
    
    --- 商品排序，优先级越小的越靠前
    for _, Tab in pairs(self.ProductIDGroupByTabID) do
        table.sort(Tab, Compare);
    end
end

function CommonImpl:ReadObjectTable()
    
    local Table = UGCGameSystem.GetTableData("Data/Table/UGCObject");

    self.ObjectDatas = {};

    for i, Data in pairs(Table) do
        
        ---@type FUGCObjectData
        local ObjectData = {};

        ObjectData.ItemID   = Data["ItemID"];
        ObjectData.ItemName = Data["ItemName"];
        ObjectData.ItemDesc = Data["ItemDesc"];
        ObjectData.ItemIcon = KismetSystemLibrary.BreakSoftObjectPath(Data["ItemSmallIcon"]);

        self.ObjectDatas[ObjectData.ItemID] = ObjectData;
    end
end

--- 加载资源
--- 获得道具界面
--- 二次确认界面
--- 通用提示界面
--- 道具Tips