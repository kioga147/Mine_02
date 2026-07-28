---@class Basic_MiningVehicle_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Basic_MiningVehicle = {}

local function GetPlayerPawnFromWeapon(Weapon)
    local Owner = Weapon:GetOwner()
    ugcprint("[矿车辅助] 武器持有者:", tostring(Owner))
    
    if Owner then
        if Owner.SetMineCarMode then
            ugcprint("[矿车辅助] ✅ 持有者直接是PlayerPawn")
            return Owner
        end
        
        if Owner.GetOwner then
            local Parent = Owner:GetOwner()
            ugcprint("[矿车辅助] 背包组件的持有者:", tostring(Parent))
            if Parent and Parent.SetMineCarMode then
                ugcprint("[矿车辅助] ✅ Parent是PlayerPawn")
                return Parent
            end
        end
        
        if Owner.GetController then
            local Controller = Owner:GetController()
            ugcprint("[矿车辅助] 获取Controller:", tostring(Controller))
            if Controller and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local Ok, PlayerPawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Controller)
                ugcprint("[矿车辅助] 通过Controller获取PlayerPawn:", Ok, tostring(PlayerPawn))
                if Ok and PlayerPawn and PlayerPawn.SetMineCarMode then
                    return PlayerPawn
                end
            end
        end
    end
    
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawns then
        local Pawns = UGCGameSystem.GetAllPlayerPawns()
        ugcprint("[矿车辅助] 获取所有PlayerPawn数量:", #Pawns)
        for _, Pawn in ipairs(Pawns) do
            if Pawn and Pawn.SetMineCarMode then
                ugcprint("[矿车辅助] ✅ 找到PlayerPawn:", tostring(Pawn))
                return Pawn
            end
        end
    end
    
    ugcprint("[矿车辅助] ❌ 无法找到PlayerPawn")
    return nil
end

function Basic_MiningVehicle:ReceiveBeginPlay()
    Basic_MiningVehicle.SuperClass.ReceiveBeginPlay(self)
    
    ugcprint("[矿车武器] ==================== 矿车武器开始 ====================")
    
    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    
    if PlayerPawn and PlayerPawn.SetMineCarMode then
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, "AxeLevel", 2)
        ugcprint("[矿车武器] ✅ 已设置玩家AxeLevel=2")
        if PlayerPawn.IsMineCarMode and PlayerPawn:IsMineCarMode() then
            ugcprint("[矿车武器] ⚠️ 矿车模式已激活，跳过重复激活")
        else
            PlayerPawn:SetMineCarMode(true)
            
            if UGCTimerManagerSystem and UGCTimerManagerSystem.SetTimer then
                UGCTimerManagerSystem.SetTimer(function()
                    self:AddMineCarSkill(PlayerPawn)
                end, 1.5, false)
            else
                ugcprint("[矿车武器] ⚠️ UGCTimerManagerSystem不可用，直接添加技能")
                self:AddMineCarSkill(PlayerPawn)
            end
            
            ugcprint("[矿车武器] ✅ 成功激活矿车模式")
        end
    else
        ugcprint("[矿车武器] ❌ 无法激活矿车模式")
    end
    
    ugcprint("[矿车武器] ==================== 矿车武器结束 ====================")
end

function Basic_MiningVehicle:AddMineCarSkill(PlayerPawn)
    ugcprint("[矿车武器] 开始添加BasicVehicle技能")
    
    local SkillPaths = {
        "/Mine_02/Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C",
        "/Game/Mine_02/Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C",
        UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C')
    }
    
    local SkillClass = nil
    for _, Path in ipairs(SkillPaths) do
        ugcprint("[矿车武器] 尝试路径:", Path)
        SkillClass = UGCObjectUtility.LoadClass(Path)
        if SkillClass then
            ugcprint("[矿车武器] ✅ 技能类加载成功:", tostring(SkillClass))
            break
        else
            ugcprint("[矿车武器] ❌ 路径加载失败:", Path)
        end
    end
    if SkillClass then
        ugcprint("[矿车武器] 技能类加载成功:", tostring(SkillClass))
        
        local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn, SkillClass)
        ugcprint("[矿车武器] 已有技能数量:", #ExistSkills)
        
        if #ExistSkills == 0 then
            local Skill = UGCPersistEffectSystem.AddSkillByClass(PlayerPawn, SkillClass, -1)
            if Skill then
                ugcprint("[矿车武器] ✅ 成功添加BasicVehicle技能")
                
                if Skill.OnApply_BP then
                    pcall(Skill.OnApply_BP, Skill)
                    ugcprint("[矿车武器] ✅ 已调用OnApply_BP")
                end
                
                if Skill.Activate then
                    pcall(Skill.Activate, Skill)
                    ugcprint("[矿车武器] ✅ 已调用Activate")
                end
            else
                ugcprint("[矿车武器] ❌ 添加技能失败")
            end
        else
            ugcprint("[矿车武器] ⚠️ 技能已存在")
            local Skill = ExistSkills[1]
            if Skill then
                ugcprint("[矿车武器] 技能状态 IsActive:", tostring(Skill.IsActive))
                if Skill.OnApply_BP then
                    pcall(Skill.OnApply_BP, Skill)
                    ugcprint("[矿车武器] ✅ 已调用OnApply_BP")
                end
            end
        end
    else
        ugcprint("[矿车武器] ❌ 无法加载技能类")
    end
    
    local AllSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn)
    ugcprint("[矿车武器] 玩家当前技能总数:", #AllSkills)
end

function Basic_MiningVehicle:ReapplyWeaponSkills(PlayerPawn)
    ugcprint("[矿车武器] 尝试重新应用武器技能")
    
    local SkillPaths = {
        "Asset/Blueprint/Prefabs/Skills/BasicVehicle.BasicVehicle_C"
    }
    
    for _, SkillPath in ipairs(SkillPaths) do
        local FullPath = UGCGameSystem.GetUGCResourcesFullPath(SkillPath)
        ugcprint("[矿车武器] 技能路径:", FullPath)
        
        local SkillClass = UGCObjectUtility.LoadClass(FullPath)
        
        if SkillClass then
            ugcprint("[矿车武器] 技能类加载成功:", tostring(SkillClass))
            
            local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn, SkillClass)
            ugcprint("[矿车武器] 已有技能数量:", #ExistSkills)
            
            if #ExistSkills > 0 then
                ugcprint("[矿车武器] 技能已存在")
            else
                local Skill = UGCPersistEffectSystem.AddSkillByClass(PlayerPawn, SkillClass, -1)
                if Skill then
                    ugcprint("[矿车武器] ✅ 成功添加技能")
                else
                    ugcprint("[矿车武器] ❌ 添加技能失败")
                end
            end
        else
            ugcprint("[矿车武器] ❌ 无法加载技能类")
        end
    end
    
    local AllSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn)
    ugcprint("[矿车武器] 玩家当前技能总数:", #AllSkills)
end

function Basic_MiningVehicle:ReceiveEndPlay()
    Basic_MiningVehicle.SuperClass.ReceiveEndPlay(self) 
    
    ugcprint("[矿车武器] ==================== 矿车武器销毁 ====================")
    
    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    
    if PlayerPawn and PlayerPawn.SetMineCarMode then
        PlayerPawn:SetMineCarMode(false)
        ugcprint("[矿车武器] ✅ 成功取消矿车模式")
    else
        ugcprint("[矿车武器] ❌ 无法取消矿车模式")
    end
    
    ugcprint("[矿车武器] ==================== 矿车武器销毁结束 ====================")
end

function Basic_MiningVehicle:GetReplicatedProperties()
    return
end

function Basic_MiningVehicle:GetAvailableServerRPCs()
    return
end

return Basic_MiningVehicle