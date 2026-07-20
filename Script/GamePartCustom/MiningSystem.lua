local MiningSystem = {}

MiningSystem.AXE_LEVEL_MAP = {
    [83100026] = 1,
    [83100027] = 1,
    [83100030] = 2,
    [83100019] = 2,
    [83100025] = 2,
    [83100028] = 3,
    [83100029] = 3,
    [83100022] = 4,
    [83100001] = 4,
    [83100024] = 4,
    [83100020] = 5,
    [83100021] = 5,
    [83100023] = 5,
}

function MiningSystem.GetAxeLevelByItemID(ItemID)
    return MiningSystem.AXE_LEVEL_MAP[ItemID] or 0
end

function MiningSystem.GetAxeLevelFromDamageCauser(DamageCauser)
    if not DamageCauser then
        return 0
    end
    
    if DamageCauser.GetItemID then
        local itemID = DamageCauser:GetItemID()
        ugcprint("[矿石挖掘] DamageCauser:GetItemID():", itemID)
        local level = MiningSystem.GetAxeLevelByItemID(itemID)
        if level > 0 then
            return level
        end
    end
    
    if DamageCauser.UGCItemHandle then
        local itemHandle = DamageCauser.UGCItemHandle
        if itemHandle then
            if itemHandle.ItemID then
                ugcprint("[矿石挖掘] UGCItemHandle.ItemID:", itemHandle.ItemID)
                local level = MiningSystem.GetAxeLevelByItemID(itemHandle.ItemID)
                if level > 0 then
                    return level
                end
            end
            if itemHandle.GetItemID then
                local itemID = itemHandle:GetItemID()
                ugcprint("[矿石挖掘] UGCItemHandle:GetItemID():", itemID)
                local level = MiningSystem.GetAxeLevelByItemID(itemID)
                if level > 0 then
                    return level
                end
            end
        end
    end
    
    if DamageCauser.GetOwner then
        local owner = DamageCauser:GetOwner()
        ugcprint("[矿石挖掘] DamageCauser:GetOwner():", tostring(owner))
        if owner then
            if owner.GetItemID then
                local itemID = owner:GetItemID()
                ugcprint("[矿石挖掘] Owner:GetItemID():", itemID)
                local level = MiningSystem.GetAxeLevelByItemID(itemID)
                if level > 0 then
                    return level
                end
            end
            if owner.UGCItemHandle then
                local itemHandle = owner.UGCItemHandle
                if itemHandle and itemHandle.ItemID then
                    ugcprint("[矿石挖掘] Owner.UGCItemHandle.ItemID:", itemHandle.ItemID)
                    local level = MiningSystem.GetAxeLevelByItemID(itemHandle.ItemID)
                    if level > 0 then
                        return level
                    end
                end
            end
        end
    end
    
    ugcprint("[矿石挖掘] 无法从DamageCauser获取物品ID")
    return 0
end

function MiningSystem.CanMine(MineLevel, AxeLevel)
    if not MineLevel or MineLevel <= 0 then
        return true
    end
    if not AxeLevel or AxeLevel <= 0 then
        return false
    end
    return AxeLevel >= MineLevel
end

return MiningSystem