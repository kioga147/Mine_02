local PaymentConfig = nil
do
    local ok, mod = pcall(function()
        return UGCGameSystem.UGCRequire('Script.Common.PaymentConfig')
    end)
    if ok and type(mod) == 'table' then PaymentConfig = mod else PaymentConfig = {} end
end

local PaymentSystem = {}
local _boundDelegates = false

-- ========== 初始化 ==========

function PaymentSystem.Initialize()
    if _boundDelegates then return end
    _boundDelegates = true

    if UGCCommoditySystem and UGCCommoditySystem.BuyUGCCommodityResultDelegate then
        UGCCommoditySystem.BuyUGCCommodityResultDelegate:Add(PaymentSystem.OnBuyResult, PaymentSystem)
        ugcprint("[PaymentSystem] 购买结果委托已绑定")
    end

    if UGCCommoditySystem and UGCCommoditySystem.UseUGCCommodityResultDelegate then
        UGCCommoditySystem.UseUGCCommodityResultDelegate:Add(PaymentSystem.OnUseResult, PaymentSystem)
        ugcprint("[PaymentSystem] 使用结果委托已绑定")
    end

    -- 显示绿洲币充值入口UI (仅客户端)
    if not UGCGameSystem.IsServer() and UGCCommoditySystem and UGCCommoditySystem.ShowRechargeEntryUI then
        pcall(function()
            UGCCommoditySystem.ShowRechargeEntryUI()
        end)
    end
end

function PaymentSystem.Cleanup()
    if not _boundDelegates then return end
    _boundDelegates = false

    if UGCCommoditySystem and UGCCommoditySystem.BuyUGCCommodityResultDelegate then
        UGCCommoditySystem.BuyUGCCommodityResultDelegate:Remove(PaymentSystem.OnBuyResult, PaymentSystem)
    end
    if UGCCommoditySystem and UGCCommoditySystem.UseUGCCommodityResultDelegate then
        UGCCommoditySystem.UseUGCCommodityResultDelegate:Remove(PaymentSystem.OnUseResult, PaymentSystem)
    end
    ugcprint("[PaymentSystem] 委托已解绑")
end

-- ========== 购买功能 ==========

--- 购买商品 (客户端)
--- @param ProductId number 商品ID (9000001等)
--- @param Count number 购买数量 (通常为1)
function PaymentSystem.BuyProduct(ProductId, Count)
    if not UGCCommoditySystem or not UGCCommoditySystem.BuyUGCCommodity2 then
        ugcprint("[PaymentSystem] ❌ 商业化系统不可用")
        return false
    end

    ProductId = math.floor(tonumber(ProductId) or 0)
    Count = math.floor(tonumber(Count) or 1)

    if ProductId <= 0 then
        ugcprint("[PaymentSystem] ❌ 无效商品ID")
        return false
    end

    local product = PaymentConfig.GetProduct(ProductId)
    if product then
        ugcprint(string.format("[PaymentSystem] 🛒 购买商品: %s (ID=%d, 数量=%d)",
            product.Name, ProductId, Count))
    else
        ugcprint(string.format("[PaymentSystem] 🛒 购买商品: ID=%d, 数量=%d", ProductId, Count))
    end

    -- 优先从 PaymentConfig 取商品展示信息，没有则用空字符串，
    -- 再无则由系统回退 UGCShop 表配置
    local IconPath = nil
    local DescText = nil
    if product then
        IconPath = product.Icon
        DescText = product.Desc
    end

    local ok, err = pcall(function()
        UGCCommoditySystem.BuyUGCCommodity2(ProductId, IconPath, DescText, Count)
    end)

    if not ok then
        ugcprint(string.format("[PaymentSystem] ❌ 购买调用失败: %s", tostring(err)))
        return false
    end

    return true
end

-- ========== 使用功能 ==========

--- 使用虚拟物品 (客户端)
--- @param CommodityId number 虚拟物品ID (1001等)
--- @param Count number 使用数量
function PaymentSystem.UseCommodity(CommodityId, Count)
    if not UGCCommoditySystem or not UGCCommoditySystem.UseUGCCommodity2 then
        ugcprint("[PaymentSystem] ❌ 商业化系统不可用")
        return false
    end

    CommodityId = math.floor(tonumber(CommodityId) or 0)
    Count = math.floor(tonumber(Count) or 1)

    if CommodityId <= 0 then
        ugcprint("[PaymentSystem] ❌ 无效物品ID")
        return false
    end

    local commodity = PaymentConfig.GetCommodity(CommodityId)
    local commodityName = commodity and commodity.Name or tostring(CommodityId)

    ugcprint(string.format("[PaymentSystem] 📦 使用物品: %s (ID=%d, 数量=%d)",
        commodityName, CommodityId, Count))

    local ok, err = pcall(function()
        UGCCommoditySystem.UseUGCCommodity2(nil, CommodityId, nil, nil, Count, true)
    end)

    if not ok then
        ugcprint(string.format("[PaymentSystem] ❌ 使用调用失败: %s", tostring(err)))
        return false
    end

    return true
end

-- ========== 充值入口 ==========

--- 显示绿洲币充值入口 (客户端)
function PaymentSystem.ShowRechargeUI()
    if not UGCCommoditySystem or not UGCCommoditySystem.ShowRechargeEntryUI then
        ugcprint("[PaymentSystem] ❌ 充值入口不可用")
        return
    end

    local ok, result = pcall(function()
        return UGCCommoditySystem.ShowRechargeEntryUI()
    end)

    if ok and result then
        ugcprint("[PaymentSystem] ✅ 充值入口已显示")
    else
        ugcprint("[PaymentSystem] ⚠️ 充值入口显示可能被关闭或未开通权限")
    end
end

-- ========== 查询功能 ==========

--- 获取玩家绿洲币余额
--- @return number 绿洲币数量
function PaymentSystem.GetTicketCount()
    if not UGCCommoditySystem or not UGCCommoditySystem.GetTicket then
        return 0
    end
    local ok, count = pcall(UGCCommoditySystem.GetTicket)
    if ok then
        return math.floor(tonumber(count) or 0)
    end
    return 0
end

--- 获取玩家虚拟物品列表
--- @return table 物品列表 [{CommodityID=, Count=}, ...]
function PaymentSystem.GetCommodityList()
    if not UGCCommoditySystem or not UGCCommoditySystem.GetUGCCommodityList then
        return {}
    end
    local ok, list = pcall(UGCCommoditySystem.GetUGCCommodityList)
    if ok and type(list) == 'table' then
        return list
    end
    return {}
end

--- 获取玩家限购商品信息
--- @return table 限购数据 {ProductID: {BuyProductLimitCount=}, ...}
function PaymentSystem.GetProductList()
    if not UGCCommoditySystem or not UGCCommoditySystem.GetUGCProductList then
        return {}
    end
    local ok, list = pcall(UGCCommoditySystem.GetUGCProductList)
    if ok and type(list) == 'table' then
        return list
    end
    return {}
end

--- 查询玩家是否拥有指定虚拟物品
--- @param CommodityId number 虚拟物品ID
--- @return number 拥有数量 (0表示没有)
function PaymentSystem.GetCommodityCount(CommodityId)
    CommodityId = math.floor(tonumber(CommodityId) or 0)
    if CommodityId <= 0 then return 0 end

    local list = PaymentSystem.GetCommodityList()
    for _, item in ipairs(list) do
        if item.CommodityID == CommodityId then
            return math.floor(tonumber(item.Count) or 0)
        end
    end
    return 0
end

-- ========== 购买结果回调 ==========

function PaymentSystem.OnBuyResult(bSuccess, PlayerKey, CommodityId, Count, UID, ProductId)
    local product = PaymentConfig.GetProduct(ProductId)
    local productName = product and product.Name or tostring(ProductId)

    if bSuccess then
        ugcprint(string.format(
            "[PaymentSystem] ✅ 购买成功: %s (商品ID=%s, 获得物品ID=%s, 数量=%s)",
            productName, tostring(ProductId), tostring(CommodityId), tostring(Count)
        ))

        -- 如果商品配置了多个物品（礼包），在这里额外发放剩余物品
        if product and type(product.Items) == 'table' then
            local pc = UGCGameSystem.GetPlayerControllerByPlayerKey(PlayerKey)
            if pc then
                for _, item in ipairs(product.Items) do
                    local cid = math.floor(tonumber(item.CommodityId) or 0)
                    local ccount = math.floor(tonumber(item.Count) or 1)
                    -- 跳过已经由系统自动发放的主物品（通过 CommodityId 判断）
                    if cid ~= CommodityId then
                        ugcprint(string.format("[PaymentSystem] 📦 礼包附加发放: 物品ID=%d, 数量=%d", cid, ccount))
                        PaymentSystem._GrantCommodityToPlayer(pc, cid, ccount)
                    end
                end
            end
        end

        PaymentSystem.NotifyBuySuccess(ProductId, CommodityId, Count)
    else
        ugcprint(string.format(
            "[PaymentSystem] ❌ 购买失败: %s (商品ID=%s)",
            productName, tostring(ProductId)
        ))

        PaymentSystem.NotifyBuyFailed(ProductId)
    end
end

--- 发放虚拟物品到玩家背包（内部函数）
function PaymentSystem._GrantCommodityToPlayer(pc, CommodityId, Count)
    if not pc or CommodityId <= 0 then return end

    local commodity = PaymentConfig.GetCommodity(CommodityId)
    if not commodity then
        ugcprint(string.format("[PaymentSystem] ⚠️ 物品ID=%d 未在 PaymentConfig 配置，跳过自动发放", CommodityId))
        return
    end

    local effect, params = PaymentConfig.GetCommodityEffect(CommodityId)
    if not effect or not params then
        ugcprint(string.format("[PaymentSystem] ⚠️ 物品ID=%d 无配置效果，跳过", CommodityId))
        return
    end

    -- 直接在服务端执行效果，避免二次调用Buy接口
    if effect == "give_item" then
        local itemId = math.floor(tonumber(params.ItemId) or 0)
        local count = math.floor(tonumber(params.Count) or 1) * (Count or 1)
        if UGCBackpackSystemV2 and UGCBackpackSystemV2.AddItemV2 then
            local ok, err = pcall(function()
                UGCBackpackSystemV2.AddItemV2(pc, itemId, count)
            end)
            if ok then
                ugcprint(string.format("[PaymentSystem] ✅ 礼包发放物品: ID=%d, 数量=%d", itemId, count))
            else
                ugcprint(string.format("[PaymentSystem] ❌ 礼包发放物品失败: %s", tostring(err)))
            end
        end
    elseif effect == "upgrade_backpack" then
        local targetLevel = math.floor(tonumber(params.TargetLevel) or 3)
        if UGCGameSystem.IsServer() then
            if pc.BackpackLevel and pc.BackpackLevel < targetLevel then
                pc.BackpackLevel = targetLevel
                if pc.OnBackpackLevelChanged then
                    pcall(pc.OnBackpackLevelChanged, pc)
                end
                ugcprint(string.format("[PaymentSystem] ✅ 礼包升级背包至 %d 级", targetLevel))
            end
        end
    end
end

-- ========== 使用结果回调 ==========

function PaymentSystem.OnUseResult(bSuccess, PlayerKey, CommodityId, Count, UID)
    local commodity = PaymentConfig.GetCommodity(CommodityId)
    local commodityName = commodity and commodity.Name or tostring(CommodityId)

    if bSuccess then
        ugcprint(string.format(
            "[PaymentSystem] ✅ 使用成功: %s (物品ID=%s, 数量=%s)",
            commodityName, tostring(CommodityId), tostring(Count)
        ))

        PaymentSystem.ApplyCommodityEffect(CommodityId, Count)
    else
        ugcprint(string.format(
            "[PaymentSystem] ❌ 使用失败: %s (物品ID=%s)",
            commodityName, tostring(CommodityId)
        ))
    end
end

-- ========== 物品效果执行 ==========

function PaymentSystem.ApplyCommodityEffect(CommodityId, Count)
    local effect, params = PaymentConfig.GetCommodityEffect(CommodityId)
    if not effect or not params then
        ugcprint("[PaymentSystem] ⚠️ 无配置效果，跳过")
        return
    end

    if effect == "give_item" then
        PaymentSystem.Effect_GiveItem(params)
    elseif effect == "upgrade_backpack" then
        PaymentSystem.Effect_UpgradeBackpack(params)
    else
        ugcprint(string.format("[PaymentSystem] ⚠️ 未知效果类型: %s", tostring(effect)))
    end
end

--- 效果: 给玩家物品
function PaymentSystem.Effect_GiveItem(params)
    local itemId = math.floor(tonumber(params.ItemId) or 0)
    local count = math.floor(tonumber(params.Count) or 1)

    if itemId <= 0 then
        ugcprint("[PaymentSystem] ❌ 无效物品ID")
        return
    end

    local pc = UGCGameSystem.GetLocalPlayerController()
    if not pc then
        ugcprint("[PaymentSystem] ❌ 无法获取玩家控制器")
        return
    end

    if UGCGameSystem.IsServer() then
        if UGCBackpackSystemV2 and UGCBackpackSystemV2.AddItemV2 then
            local ok, err = pcall(function()
                UGCBackpackSystemV2.AddItemV2(pc, itemId, count)
            end)
            if ok then
                ugcprint(string.format("[PaymentSystem] ✅ 已添加物品: ID=%d, 数量=%d", itemId, count))
            else
                ugcprint(string.format("[PaymentSystem] ❌ 添加物品失败: %s", tostring(err)))
            end
        end
    else
        -- 客户端：发起服务端RPC执行发放
        if pc.Server_PaymentGiveItem then
            pcall(function()
                pc:Server_PaymentGiveItem(itemId, count)
            end)
        else
            UnrealNetwork.CallUnrealRPC(pc, pc, "Server_PaymentGiveItem", itemId, count)
        end
    end
end

--- 效果: 升级背包
function PaymentSystem.Effect_UpgradeBackpack(params)
    local targetLevel = math.floor(tonumber(params.TargetLevel) or 3)

    local pc = UGCGameSystem.GetLocalPlayerController()
    if not pc then
        ugcprint("[PaymentSystem] ❌ 无法获取玩家控制器")
        return
    end

    if UGCGameSystem.IsServer() then
        if pc.BackpackLevel and pc.BackpackLevel < targetLevel then
            pc.BackpackLevel = targetLevel
            if pc.OnBackpackLevelChanged then
                pcall(pc.OnBackpackLevelChanged, pc)
            end
            ugcprint(string.format("[PaymentSystem] ✅ 背包升级至 %d 级", targetLevel))
        else
            ugcprint(string.format("[PaymentSystem] ⚠️ 当前背包等级 >= %d，无需升级", targetLevel))
        end
    else
        if pc.Server_PaymentUpgradeBackpack then
            pcall(function()
                pc:Server_PaymentUpgradeBackpack(targetLevel)
            end)
        else
            UnrealNetwork.CallUnrealRPC(pc, pc, "Server_PaymentUpgradeBackpack", targetLevel)
        end
    end
end

-- ========== 通知回调 (给UI层使用) ==========

local _listeners = {
    BuySuccess = {},
    BuyFailed = {},
    UseSuccess = {},
    UseFailed = {},
}

function PaymentSystem.AddEventListener(eventType, callback)
    if _listeners[eventType] and type(callback) == 'function' then
        table.insert(_listeners[eventType], callback)
        return true
    end
    return false
end

function PaymentSystem.RemoveEventListener(eventType, callback)
    if _listeners[eventType] then
        for i, cb in ipairs(_listeners[eventType]) do
            if cb == callback then
                table.remove(_listeners[eventType], i)
                return true
            end
        end
    end
    return false
end

function PaymentSystem._FireEvent(eventType, ...)
    if _listeners[eventType] then
        for _, cb in ipairs(_listeners[eventType]) do
            local ok, err = pcall(cb, ...)
            if not ok then
                ugcprint(string.format("[PaymentSystem] ❌ 事件回调错误: %s", tostring(err)))
            end
        end
    end
end

function PaymentSystem.NotifyBuySuccess(ProductId, CommodityId, Count)
    PaymentSystem._FireEvent("BuySuccess", ProductId, CommodityId, Count)
end

function PaymentSystem.NotifyBuyFailed(ProductId)
    PaymentSystem._FireEvent("BuyFailed", ProductId)
end

return PaymentSystem
