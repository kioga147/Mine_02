-- 成就称号配置
-- UnlockItemID: UGCObject 中的称号解锁凭证（虚拟物品，不映射背包）
-- EquipItemID: UGCObject 中的当前佩戴标记（虚拟物品，不映射背包）
local TitleConfig = {
    TaskLineName = "成就",
    Titles = {
        [1011] = { UnlockItemID = 1011, EquipItemID = 1031, TaskIndex = 1, TaskTarget = 1000000, Name = "百万富翁", Desc = "拥有 100w 现金", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_Millionaire.Title_Millionaire" },
        [1012] = { UnlockItemID = 1012, EquipItemID = 1032, TaskIndex = 2, TaskTarget = 10000000, Name = "千万富翁", Desc = "拥有 1000w 现金", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_TenMillionaire.Title_TenMillionaire" },
        [1013] = { UnlockItemID = 1013, EquipItemID = 1033, TaskIndex = 3, TaskTarget = 100000000, Name = "一个小目标", Desc = "拥有 1 亿现金", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_Billionaire.Title_Billionaire" },
        [1014] = { UnlockItemID = 1014, EquipItemID = 1034, TaskIndex = 4, TaskTarget = 1, Name = "新手上路", Desc = "获得第一辆任意等级采矿车", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_FirstVehicle.Title_FirstVehicle" },
        [1015] = { UnlockItemID = 1015, EquipItemID = 1035, TaskIndex = 5, TaskTarget = 1, Name = "初出茅庐", Desc = "完成新手教程", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_Tutorial.Title_Tutorial" },
        [1016] = { UnlockItemID = 1016, EquipItemID = 1036, TaskIndex = 6, TaskTarget = 2000, Name = "玉石鉴赏家", Desc = "鉴定出一块价值 2000 以上的玉石", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_JadeMaster.Title_JadeMaster" },
        [1017] = { UnlockItemID = 1017, EquipItemID = 1037, TaskIndex = 7, TaskTarget = 6666, Name = "挖矿大亨", Desc = "挖掘 6666 块矿石", IconPath = "Asset/Blueprint/Prefabs/UI/Textures/Title_MiningTycoon.Title_MiningTycoon" },
    },
    Order = { 1011, 1012, 1013, 1014, 1015, 1016, 1017 },
}

function TitleConfig.Get(TitleID)
    return TitleConfig.Titles[tonumber(TitleID) or 0]
end

function TitleConfig.GetAllTitles()
    return TitleConfig.Order
end

function TitleConfig.GetByUnlockItemID(ItemID)
    ItemID = tonumber(ItemID) or 0
    local Entry = TitleConfig.Titles[ItemID]
    if Entry and Entry.UnlockItemID == ItemID then
        return Entry, ItemID
    end
    return nil, nil
end

function TitleConfig.GetByEquipItemID(ItemID)
    ItemID = tonumber(ItemID) or 0
    for TitleID, Entry in pairs(TitleConfig.Titles) do
        if Entry.EquipItemID == ItemID then
            return Entry, TitleID
        end
    end
    return nil, nil
end

function TitleConfig.IsUnlockItemID(ItemID)
    local Entry = TitleConfig.GetByUnlockItemID(ItemID)
    return Entry ~= nil
end

function TitleConfig.IsEquipItemID(ItemID)
    local Entry = TitleConfig.GetByEquipItemID(ItemID)
    return Entry ~= nil
end

function TitleConfig.GetDefaultTitleID()
    return TitleConfig.Order[1]
end

function TitleConfig.GetTaskLineName()
    return TitleConfig.TaskLineName
end

function TitleConfig.GetTaskIndex(TitleID)
    local Entry = TitleConfig.Get(TitleID)
    return Entry and Entry.TaskIndex or 0
end

function TitleConfig.GetTaskTarget(TitleID)
    local Entry = TitleConfig.Get(TitleID)
    return Entry and Entry.TaskTarget or 0
end

return TitleConfig