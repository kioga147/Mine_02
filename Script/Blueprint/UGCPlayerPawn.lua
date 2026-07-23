---@class UGCPlayerPawn_C:BP_PlayerPawn_TopDown_C
--Edit Below--
local UGCPlayerPawn = {}

local HEAVY_WEIGHT_THRESHOLD = 100
local NORMAL_SPEED_SCALE = 2.0
local HEAVY_SPEED_SCALE = 1.0

local AXE_LEVEL_BY_CLASS = {
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

local MINE_CAR_SPEED_SCALE = 4.0

local function GetAxeLevelByClassName(ClassName)
    if not ClassName then
        return 0
    end
    local name = tostring(ClassName):lower()
    for classPattern, level in pairs(AXE_LEVEL_BY_CLASS) do
        if string.find(name, classPattern) then
            return level
        end
    end
    return 0
end

local lastAxeLevel = 0
local lastWeaponName = ""

function UGCPlayerPawn:ReceiveBeginPlay()
    UGCPlayerPawn.SuperClass.ReceiveBeginPlay(self)
    
    UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 0)
    
    self.bIsMineCarMode = false
end

function UGCPlayerPawn:SetMineCarMode(bEnable)
    self.bIsMineCarMode = bEnable
    ugcprint("[矿车模式] 设置矿车模式:", bEnable)
    
    if bEnable then
        UGCAttributeSystem.SetGameAttributeValue(self, 
            UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, MINE_CAR_SPEED_SCALE)
        ugcprint("[矿车模式] ✅ 已切换到矿车模式，移速:", MINE_CAR_SPEED_SCALE)
    else
        local backpackWeightInfo = BP_BackpackComponentV2_Custom.GetBackpackWeightInfo(self)
        if backpackWeightInfo and backpackWeightInfo.CurrentWeight >= HEAVY_WEIGHT_THRESHOLD then
            UGCAttributeSystem.SetGameAttributeValue(self, 
                UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, HEAVY_SPEED_SCALE)
        else
            UGCAttributeSystem.SetGameAttributeValue(self, 
                UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
        end
        ugcprint("[矿车模式] ❌ 已退出矿车模式")
    end
end

function UGCPlayerPawn:IsMineCarMode()
    return self.bIsMineCarMode == true
end

function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)
    
    if not self.bIsMineCarMode then
        local backpackWeightInfo = BP_BackpackComponentV2_Custom.GetBackpackWeightInfo(self)
        if backpackWeightInfo then
            if backpackWeightInfo.CurrentWeight >= HEAVY_WEIGHT_THRESHOLD then
                UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, HEAVY_SPEED_SCALE)
            else
                UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
            end
        end
    end
    
    local axeLevel = 0
    local currentWeaponName = ""

    if UGCWeaponManagerSystem.GetCurrentWeapon then
        local weapon = UGCWeaponManagerSystem.GetCurrentWeapon(self)
        
        if weapon then
            if weapon.GetName then
                currentWeaponName = tostring(weapon:GetName())
            end
            
            local attrAxeLevel = UGCAttributeSystem.GetGameAttributeValue(weapon, "AxeLevel") or 0
            local classAxeLevel = 0
            
            if weapon.GetClass then
                classAxeLevel = GetAxeLevelByClassName(weapon:GetClass())
            end
            
            axeLevel = attrAxeLevel > 0 and attrAxeLevel or classAxeLevel
            
            if axeLevel ~= lastAxeLevel or currentWeaponName ~= lastWeaponName then
                ugcprint("[镐子装备] 装备:", currentWeaponName, "| 等级:", axeLevel)
                lastAxeLevel = axeLevel
                lastWeaponName = currentWeaponName
            end
        else
            if lastWeaponName ~= "" then
                ugcprint("[镐子装备] 未持有武器")
                lastWeaponName = ""
                lastAxeLevel = 0
            end
        end
    end
    
    UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", axeLevel)
end

function UGCPlayerPawn:ReceiveEndPlay()
    UGCPlayerPawn.SuperClass.ReceiveEndPlay(self) 
end

function UGCPlayerPawn:GetReplicatedProperties()
    return {"__SubObjectRepList", "Lazy"}
end

return UGCPlayerPawn