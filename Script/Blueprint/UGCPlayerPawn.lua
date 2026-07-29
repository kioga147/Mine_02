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

local MINE_CAR_SKILL_PATHS = {
    "Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C",
    "Asset/Blueprint/Prefabs/Skills/MidVehicle.MidVehicle_C",
    "Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C",
}

local function IsServerRuntime()
    if UGCGameSystem and UGCGameSystem.IsServer then
        return UGCGameSystem.IsServer()
    end
    if UE_IsServer then
        return UE_IsServer()
    end
    return false
end

local BP_BackpackComponentV2_Custom = nil
local function GetBackpackComponent()
    if not BP_BackpackComponentV2_Custom then
        if UGCGameSystem and UGCGameSystem.UGCRequire then
            local Ok, Mod = pcall(UGCGameSystem.UGCRequire, "Script.GamePartCustom.BackpackV2.BP_BackpackComponentV2_Custom")
            if Ok and Mod then
                BP_BackpackComponentV2_Custom = Mod
            end
        end
    end
    return BP_BackpackComponentV2_Custom
end

local function LoadMineCarSkillClass(SkillPath)
    if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
        local Ok, FullPath = pcall(UGCGameSystem.GetUGCResourcesFullPath, SkillPath)
        if Ok and FullPath then
            local LoadOk, SkillClass = pcall(UGCObjectUtility.LoadClass, FullPath)
            if LoadOk and SkillClass then
                return SkillClass
            end
        end
    end
    return SkillPath
end

local function ClearMineCarSkills(Actor)
    if not IsServerRuntime() or Actor == nil or UGCPersistEffectSystem == nil then
        return
    end

    for _, SkillPath in ipairs(MINE_CAR_SKILL_PATHS) do
        local SkillClass = LoadMineCarSkillClass(SkillPath)
        local Ok, Skills = pcall(UGCPersistEffectSystem.GetSkillsByClass, Actor, SkillClass)
        if Ok and type(Skills) == "table" then
            for _, Skill in ipairs(Skills) do
                if Skill then
                    local Removed = false
                    if UGCPersistEffectSystem.RemoveSkillInstance then
                        local RemoveOk = pcall(UGCPersistEffectSystem.RemoveSkillInstance, Actor, Skill)
                        Removed = RemoveOk
                    end
                    if not Removed and Skill.Cancel then
                        pcall(Skill.Cancel, Skill, EPersistEffectUnApplyReason.Normal)
                    end
                end
            end
        end
    end
end

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
    
    if IsServerRuntime() then
        UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
        UGCAttributeSystem.SetGameAttributeValue(self, "AxeLevel", 0)
    end
    
    self.bIsMineCarMode = false
end

function UGCPlayerPawn:SetMineCarMode(bEnable)
    ugcprint("[矿车模式] 设置矿车模式:", bEnable)
    
    local IsServer = IsServerRuntime()
    
    ugcprint("[矿车模式] 当前是否服务器:", IsServer)
    
    if UGCPersistEffectSystem then
        local BaseComp = UGCPersistEffectSystem.GetPersistBaseComponentByContent(self)
        ugcprint("[矿车模式] PersistBaseComponent:", tostring(BaseComp))
    end
    
    if IsServer then
        ugcprint("[矿车模式] 已在服务器端，直接执行")
        self:DoSetMineCarMode(bEnable)
    else
        ugcprint("[矿车模式] 在客户端，发送RPC到服务器")
        self.bIsMineCarMode = bEnable == true
        if self.Server_SetMineCarMode then
            self:Server_SetMineCarMode(bEnable)
        else
            ugcprint("[矿车模式] ❌ Server_SetMineCarMode RPC不存在")
        end
    end
end

function UGCPlayerPawn:Server_SetMineCarMode(bEnable)
    if not IsServerRuntime() then
        return
    end
    ugcprint("[矿车模式] Server_SetMineCarMode:", bEnable)
    self:DoSetMineCarMode(bEnable)
end

function UGCPlayerPawn:DoSetMineCarMode(bEnable)
    if not IsServerRuntime() then
        self.bIsMineCarMode = bEnable == true
        return
    end

    if bEnable then
        if self.bIsMineCarMode then
            ugcprint("[矿车模式] ⚠️ 矿车模式已激活")
            return
        end
        
        ClearMineCarSkills(self)
        self.bIsMineCarMode = true
        UGCAttributeSystem.SetGameAttributeValue(self, 
            UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, MINE_CAR_SPEED_SCALE)
        
        local BuffPath = "/Game/Mine_02/Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C"
        
        if UGCPersistEffectSystem then
            ugcprint("[矿车模式] 准备添加变身Buff")
            
            local BuffClass = nil
            if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
                local FullPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C')
                ugcprint("[矿车模式] Buff完整路径:", FullPath)
                
                BuffClass = UGCObjectUtility.LoadClass(FullPath)
                ugcprint("[矿车模式] LoadClass结果:", tostring(BuffClass))
            end
            
            if not BuffClass then
                ugcprint("[矿车模式] ⚠️ LoadClass失败，尝试直接使用路径")
                BuffClass = BuffPath
            end
            
            local Ok, Result = pcall(UGCPersistEffectSystem.AddBuffByClass, self, BuffClass)
            if Ok then
                ugcprint("[矿车模式] ✅ AddBuffByClass调用成功")
                
                local GetBuffsOk, Buffs = pcall(UGCPersistEffectSystem.GetBuffsByClass, self, BuffClass)
                if GetBuffsOk and Buffs and type(Buffs) == "table" and #Buffs > 0 then
                    ugcprint("[矿车模式] ✅ 确认Buff已添加，数量:", #Buffs)
                else
                    ugcprint("[矿车模式] ⚠️ GetBuffsByClass结果:", tostring(Buffs))
                end
            else
                ugcprint("[矿车模式] ❌ AddBuffByClass调用失败:", tostring(Result))
            end
        else
            ugcprint("[矿车模式] ❌ UGCPersistEffectSystem不可用")
        end
        
        ugcprint("[矿车模式] ✅ 已切换到矿车模式")
    else
        self.bIsMineCarMode = false
        
        local BuffPath = "/Game/Mine_02/Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C"
        
        if UGCPersistEffectSystem then
            local BuffClass = nil
            if UGCObjectUtility and UGCObjectUtility.LoadClass and UGCGameSystem and UGCGameSystem.GetUGCResourcesFullPath then
                local FullPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Buffs/Transform_Mningcar.Transform_Mningcar_C')
                BuffClass = UGCObjectUtility.LoadClass(FullPath)
            end
            
            if not BuffClass then
                BuffClass = BuffPath
            end
            
            local Ok, Result = pcall(UGCPersistEffectSystem.RemoveBuffByClass, self, BuffClass)
            if Ok then
                ugcprint("[矿车模式] ✅ 已移除变身Buff")
            else
                ugcprint("[矿车模式] ❌ 移除变身Buff失败:", tostring(Result))
            end
        end
        
        ClearMineCarSkills(self)

        local BackpackComp = GetBackpackComponent()
        if BackpackComp and BackpackComp.GetBackpackWeightInfo then
            local backpackWeightInfo = BackpackComp.GetBackpackWeightInfo(self)
            if backpackWeightInfo and backpackWeightInfo.CurrentWeight >= HEAVY_WEIGHT_THRESHOLD then
                UGCAttributeSystem.SetGameAttributeValue(self, 
                    UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, HEAVY_SPEED_SCALE)
            else
                UGCAttributeSystem.SetGameAttributeValue(self, 
                    UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
            end
        end
        
        ugcprint("[矿车模式] ❌ 已退出矿车模式")
    end
end

function UGCPlayerPawn:IsMineCarMode()
    return self.bIsMineCarMode == true
end

function UGCPlayerPawn:UpdateSpeedByWeight()
    if self.bIsMineCarMode or not IsServerRuntime() then
        return
    end
    
    local BackpackComp = GetBackpackComponent()
    if BackpackComp and BackpackComp.GetBackpackWeightInfo then
        local backpackWeightInfo = BackpackComp.GetBackpackWeightInfo(self)
        if backpackWeightInfo then
            if backpackWeightInfo.CurrentWeight >= HEAVY_WEIGHT_THRESHOLD then
                UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, HEAVY_SPEED_SCALE)
                ugcprint("[速度更新] 背包超重，速度降低至:", HEAVY_SPEED_SCALE)
            else
                UGCAttributeSystem.SetGameAttributeValue(self, UGCNativeGameAttributeType.Character_UGCGeneralMoveSpeedScale, NORMAL_SPEED_SCALE)
                ugcprint("[速度更新] 背包负重正常，速度恢复至:", NORMAL_SPEED_SCALE)
            end
        end
    end
end

function UGCPlayerPawn:ReceiveTick(DeltaTime)
    UGCPlayerPawn.SuperClass.ReceiveTick(self, DeltaTime)
    
    if self.bIsMineCarMode or not IsServerRuntime() then
        return
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
    return {"__SubObjectRepList", "Lazy", "bIsMineCarMode"}
end

function UGCPlayerPawn:GetAvailableServerRPCs()
    return "Server_SetMineCarMode"
end

return UGCPlayerPawn
