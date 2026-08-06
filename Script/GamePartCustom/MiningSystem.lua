local MiningSystem = {}

MiningSystem.AXE_LEVEL_MAP = {
    [8310026] = 1,
    [8310027] = 1,
    [8310030] = 2,
    [8310019] = 2,
    [8310025] = 2,
    [8310028] = 3,
    [8310029] = 3,
    [8310022] = 4,
    [8310001] = 4,
    [8310024] = 4,
    [8310020] = 5,
    [8310021] = 5,
    [8310023] = 5,
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
    ["mineboom"] = 5,
}

MiningSystem.BombLevel = 5
MiningSystem.BombExpireTime = 0

function MiningSystem.SetBombActive(bActive)
    if bActive then
        MiningSystem.BombExpireTime = os.clock() + 3
        ugcprint("[MiningSystem] 炸弹已激活，等级="..MiningSystem.BombLevel.."，持续3秒")
    else
        MiningSystem.BombExpireTime = 0
        ugcprint("[MiningSystem] 炸弹已清除")
    end
end

function MiningSystem.IsBombActive()
    if MiningSystem.BombExpireTime > 0 and os.clock() < MiningSystem.BombExpireTime then
        return true
    end
    return false
end

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
    
    if MiningSystem.IsBombActive() then
        return MiningSystem.BombLevel
    end
    
    local currentWeapon = nil
    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetCurrentWeapon then
        local ok, weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, DamageCauser)
        if ok then
            currentWeapon = weapon
        end
    end
    
    if not currentWeapon and DamageCauser.GetOwner then
        local owner = DamageCauser:GetOwner()
        if owner and UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetCurrentWeapon then
            local ok, weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, owner)
            if ok then
                currentWeapon = weapon
            end
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
        
        if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetWeaponItemID then
            local ok, itemID = pcall(UGCWeaponManagerSystem.GetWeaponItemID, currentWeapon)
            if ok and itemID then
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
    
    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetWeaponItemID then
        local ok, itemID = pcall(UGCWeaponManagerSystem.GetWeaponItemID, DamageCauser)
        if ok and itemID then
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
