--- 付费商品配置
--- 商品ID范围: 9000000-9999999 (UGCShop表)
--- 物品ID范围: 1001-10000 (UGCObject表, 虚拟物品)
local PaymentConfig = {}

-- ========== 商品定义 ==========
PaymentConfig.Products = {
    [9000001] = {
        ProductId = 9000001,
        Name = "初级矿工成长礼包",
        Desc = "包含铁钻头、背包升级券、玉矿石",
        Price = 15,
        CurrencyType = 1, -- 1=绿洲币
        Items = {
            { CommodityId = 1001, Count = 1, Desc = "铁钻头 x1" },
            { CommodityId = 1002, Count = 1, Desc = "背包升级三级券 x1" },
            { CommodityId = 1003, Count = 5, Desc = "玉矿石 x5" },
        },
    },
}

-- ========== 虚拟物品定义 (UGCObject表) ==========
-- 这些是玩家购买后获得的虚拟物品, 需要在编辑器UGCObject表中配置
PaymentConfig.Commodities = {
    [1001] = {
        CommodityId = 1001,
        Name = "铁钻头",
        Desc = "使用后获得铁钻头(8310019)",
        Effect = "give_item",
        EffectParams = { ItemId = 8310019, Count = 1 },
    },
    [1002] = {
        CommodityId = 1002,
        Name = "背包升级三级券",
        Desc = "使用后背包等级升至3级",
        Effect = "upgrade_backpack",
        EffectParams = { TargetLevel = 3 },
    },
    [1003] = {
        CommodityId = 1003,
        Name = "玉矿石",
        Desc = "使用后获得玉矿石(8310010)",
        Effect = "give_item",
        EffectParams = { ItemId = 8310010, Count = 1 },
    },
}

-- ========== 查询函数 ==========

function PaymentConfig.GetProduct(ProductId)
    return PaymentConfig.Products[tonumber(ProductId) or 0]
end

function PaymentConfig.GetProductList()
    local list = {}
    for _, product in pairs(PaymentConfig.Products) do
        table.insert(list, product)
    end
    return list
end

function PaymentConfig.GetCommodity(CommodityId)
    return PaymentConfig.Commodities[tonumber(CommodityId) or 0]
end

function PaymentConfig.GetCommodityName(CommodityId)
    local commodity = PaymentConfig.GetCommodity(CommodityId)
    if commodity then
        return commodity.Name
    end
    return nil
end

function PaymentConfig.GetCommodityEffect(CommodityId)
    local commodity = PaymentConfig.GetCommodity(CommodityId)
    if commodity then
        return commodity.Effect, commodity.EffectParams
    end
    return nil, nil
end

function PaymentConfig.GetTicketPrice(ProductId)
    local product = PaymentConfig.GetProduct(ProductId)
    if product then
        return product.Price
    end
    return 0
end

return PaymentConfig
