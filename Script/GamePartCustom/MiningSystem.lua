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
        MiningSystem.BombExpireTime = os.clock() + 0.5
        ugcprint("[MiningSystem] 炸弹已激活，等级="..MiningSystem.BombLevel.."，持续0.5秒")
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
    
    -- 首先检查是否在矿车模式中
    local ownerPawn = nil
    local function TryGetPawn(Actor)
        if Actor and Actor.IsMineCarMode then
            return Actor
        end
        return nil
    end
    
    if DamageCauser.IsMineCarMode then
        ownerPawn = DamageCauser
    elseif DamageCauser.GetOwner then
        local ok, owner = pcall(function() return DamageCauser:GetOwner() end)
        if ok and owner then
            ownerPawn = TryGetPawn(owner)
            if not ownerPawn and owner.GetOwner then
                local ok2, owner2 = pcall(function() return owner:GetOwner() end)
                if ok2 and owner2 then
                    ownerPawn = TryGetPawn(owner2)
                end
            end
        end
    end
    
    local bInMineCarMode = ownerPawn and ownerPawn.IsMineCarMode and ownerPawn:IsMineCarMode() or false
    
    -- 如果在矿车模式中，优先使用玩家的AxeLevel属性
    if bInMineCarMode and ownerPawn then
        local mineCarAxeLevel = UGCAttributeSystem.GetGameAttributeValue(ownerPawn, "AxeLevel")
        if (not mineCarAxeLevel or mineCarAxeLevel <= 0) and ownerPawn._mineCarAxeLevel then
            mineCarAxeLevel = ownerPawn._mineCarAxeLevel
        end
        if mineCarAxeLevel and mineCarAxeLevel > 0 then
            ugcprint(string.format("[MiningSystem] 矿车模式伤害判定: AxeLevel=%s", tostring(mineCarAxeLevel)))
            return mineCarAxeLevel
        end
    end
    
    -- 获取当前武器
    local currentWeapon = nil
    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetCurrentWeapon then
        local ok, weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, DamageCauser)
        if ok then
            currentWeapon = weapon
        end
    end
    
    if not currentWeapon and ownerPawn then
        if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetCurrentWeapon then
            local ok, weapon = pcall(UGCWeaponManagerSystem.GetCurrentWeapon, ownerPawn)
            if ok then
                currentWeapon = weapon
            end
        end
    end
    
    if currentWeapon then
        -- 检查武器的AxeLevel属性
        local axeLevel = UGCAttributeSystem.GetGameAttributeValue(currentWeapon, "AxeLevel")
        if axeLevel and axeLevel > 0 then
            ugcprint(string.format("[MiningSystem] 武器AxeLevel: %s", tostring(axeLevel)))
            return axeLevel
        end
        
        if currentWeapon.GetClass then
            local className = tostring(currentWeapon:GetClass()):lower()
            local isMineCarWeapon = string.find(className, "miningvehicle") ~= nil or string.find(className, "miningtruck") ~= nil
            if isMineCarWeapon and not bInMineCarMode then
                ugcprint("[MiningSystem] 矿车武器已装备但玩家不在矿车模式，跳过等级判定")
            else
                local level = MiningSystem.GetAxeLevelByClassName(currentWeapon:GetClass())
                if level > 0 then
                    ugcprint(string.format("[MiningSystem] 武器类名匹配: %s -> level=%d", currentWeapon:GetClass(), level))
                    return level
                end
            end
        end
        
        if currentWeapon.GetName then
            local nameStr = tostring(currentWeapon:GetName()):lower()
            local isMineCarWeapon = string.find(nameStr, "miningvehicle") ~= nil or string.find(nameStr, "miningtruck") ~= nil
            if isMineCarWeapon and not bInMineCarMode then
                ugcprint("[MiningSystem] 矿车武器(按名称)已装备但玩家不在矿车模式，跳过等级判定")
            else
                local level = MiningSystem.GetAxeLevelByClassName(currentWeapon:GetName())
                if level > 0 then
                    ugcprint(string.format("[MiningSystem] 武器名匹配: %s -> level=%d", currentWeapon:GetName(), level))
                    return level
                end
            end
        end
        
        if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetWeaponItemID then
            local ok, itemID = pcall(UGCWeaponManagerSystem.GetWeaponItemID, currentWeapon)
            if ok and itemID then
                local level = MiningSystem.GetAxeLevelByItemID(itemID)
                if level > 0 then
                    ugcprint(string.format("[MiningSystem] 武器ItemID匹配: %s -> level=%d", tostring(itemID), level))
                    return level
                end
            end
        end
        
        if currentWeapon.GetItemID then
            local itemID = currentWeapon:GetItemID()
            if itemID then
                local level = MiningSystem.GetAxeLevelByItemID(itemID)
                if level > 0 then
                    ugcprint(string.format("[MiningSystem] 武器GetItemID匹配: %s -> level=%d", tostring(itemID), level))
                    return level
                end
            end
        end
    end
    
    -- 最后检查伤害发起者的AxeLevel
    local axeLevel = UGCAttributeSystem.GetGameAttributeValue(DamageCauser, "AxeLevel")
    if axeLevel and axeLevel > 0 then
        ugcprint(string.format("[MiningSystem] 伤害发起者AxeLevel: %s", tostring(axeLevel)))
        return axeLevel
    end
    
    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.GetWeaponItemID then
        local ok, itemID = pcall(UGCWeaponManagerSystem.GetWeaponItemID, DamageCauser)
        if ok and itemID then
            local level = MiningSystem.GetAxeLevelByItemID(itemID)
            if level > 0 then
                ugcprint(string.format("[MiningSystem] 伤害发起者ItemID匹配: %s -> level=%d", tostring(itemID), level))
                return level
            end
        end
    end
    
    if DamageCauser.GetItemID then
        local itemID = DamageCauser:GetItemID()
        if itemID then
            local level = MiningSystem.GetAxeLevelByItemID(itemID)
            if level > 0 then
                ugcprint(string.format("[MiningSystem] 伤害发起者GetItemID匹配: %s -> level=%d", tostring(itemID), level))
                return level
            end
        end
    end
    
    ugcprint("[MiningSystem] 未找到AxeLevel，返回0")
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
