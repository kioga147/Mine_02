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

MiningSystem.AXE_LEVEL_BY_CLASS = {
    ["copper_pickaxe"] = 1,
    ["copper_drill"] = 1,
    ["basic_miningvehicle"] = 2,
    ["iron_pickaxe"] = 2,
    ["iron_drill"] = 2,
    ["alloy_pickaxe"] = 3,
    ["alloy_drill"] = 3,
    ["diamond_pickaxe"] = 4,
    ["diamond_drill"] = 4,
    ["intermediate_miningtruck"] = 4,
    ["exdiamond_pickaxe"] = 5,
    ["exdiamond_drill"] = 5,
    ["advanced_miningtruck"] = 5,
}

function MiningSystem.GetAxeLevelByItemID(ItemID)
    return MiningSystem.AXE_LEVEL_MAP[ItemID] or 0
end

function MiningSystem.GetAxeLevelByClassName(ClassName)
    if not ClassName then
        return 0
    end
    local name = tostring(ClassName):lower()
    for classPattern, level in pairs(MiningSystem.AXE_LEVEL_BY_CLASS) do
        if string.find(name, classPattern) then
            return level
        end
    end
    return 0
end

function MiningSystem.GetAxeLevelFromDamageCauser(DamageCauser)
    if not DamageCauser then
        return 0
    end
    
    local currentWeapon = nil
    if UGCWeaponManagerSystem.GetCurrentWeapon then
        currentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(DamageCauser)
    end
    
    if not currentWeapon and DamageCauser.GetOwner then
        local owner = DamageCauser:GetOwner()
        if owner and UGCWeaponManagerSystem.GetCurrentWeapon then
            currentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(owner)
        end
    end
    
    if currentWeapon then
        local axeLevel = UGCAttributeSystem.GetGameAttributeValue(currentWeapon, "AxeLevel")
        if axeLevel and axeLevel > 0 then
            return axeLevel
        end
        
        if currentWeapon.GetClass then
            local level = MiningSystem.GetAxeLevelByClassName(currentWeapon:GetClass())
            if level > 0 then
                return level
            end
        end
        
        if currentWeapon.GetName then
            local level = MiningSystem.GetAxeLevelByClassName(currentWeapon:GetName())
            if level > 0 then
                return level
            end
        end
        
        if UGCWeaponManagerSystem.GetWeaponItemID then
            local itemID = UGCWeaponManagerSystem.GetWeaponItemID(currentWeapon)
            if itemID then
                local level = MiningSystem.GetAxeLevelByItemID(itemID)
                if level > 0 then
                    return level
                end
            end
        end
        
        if currentWeapon.GetItemID then
            local itemID = currentWeapon:GetItemID()
            if itemID then
                local level = MiningSystem.GetAxeLevelByItemID(itemID)
                if level > 0 then
                    return level
                end
            end
        end
    end
    
    local axeLevel = UGCAttributeSystem.GetGameAttributeValue(DamageCauser, "AxeLevel")
    if axeLevel and axeLevel > 0 then
        return axeLevel
    end
    
    if UGCWeaponManagerSystem.GetWeaponItemID then
        local itemID = UGCWeaponManagerSystem.GetWeaponItemID(DamageCauser)
        if itemID then
            local level = MiningSystem.GetAxeLevelByItemID(itemID)
            if level > 0 then
                return level
            end
        end
    end
    
    if DamageCauser.GetItemID then
        local itemID = DamageCauser:GetItemID()
        if itemID then
            local level = MiningSystem.GetAxeLevelByItemID(itemID)
            if level > 0 then
                return level
            end
        end
    end
    
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