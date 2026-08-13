-- ShopV2 悬浮商店：虚拟物品 ItemID -> 实际发放内容
-- 对应 UGCShop 表 ProductID 9000001~9000007，UGCObject 表 ItemID 1002~1008
-- 工具/背包等级复用 ShopConfig；随机矿物复用 OreRecycleConfig
local ShopV2ProductConfig = {
    [1002] = {
        ProductID = 9000001,
        Name = "初级矿工成长礼包",
        Desc = "铁钻头x1 + 背包升至Lv3 + 玉矿石x1",
        Items = { { 8310019, 1 } },
        BackpackLevel = 3,
        JadeCount = 1,
    },
    [1003] = {
        ProductID = 9000002,
        Name = "进阶矿工成长礼包",
        Desc = "钻石钻头x1 + 背包升至Lv6 + 随机矿物x100",
        Items = { { 8310001, 1 } },
        BackpackLevel = 6,
        RandomOreCount = 100,
    },
    [1004] = {
        ProductID = 9000003,
        Name = "满级矿工成长礼包",
        Desc = "高级采矿车x1 + 背包升至Lv10 + 玉矿石x25",
        Items = { { 8310023, 1 } },
        BackpackLevel = 10,
        JadeCount = 25,
    },
    [1005] = {
        ProductID = 9000004,
        Name = "矿场无限精炼燃料",
        Desc = "精炼不再消耗煤矿",
        Flag = "bInfiniteFuel",
    },
    [1006] = {
        ProductID = 9000005,
        Name = "矿区传送终身VIP",
        Desc = "免费使用矿区传送",
        Flag = "bTeleportVIP",
    },
    [1007] = {
        ProductID = 9000006,
        Name = "矿石盲盒补给礼包",
        Desc = "随机矿物x100",
        RandomOreCount = 100,
    },
    [1008] = {
        ProductID = 9000007,
        Name = "自动拾取功能",
        Desc = "开启自动拾取（标记已生效，拾取行为待接入）",
        Flag = "bAutoPickup",
    },
}

function ShopV2ProductConfig.GetGift(ItemID)
    return ShopV2ProductConfig[tonumber(ItemID) or 0]
end

return ShopV2ProductConfig
