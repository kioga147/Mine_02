---@class MineBoom_C:PESkillTemplate_Base_C
--Edit Below--
local MineBoom = {}

local EMPTY_WEAPON_SLOT = 0       -- SWPS_None 空手
local MELEE_WEAPON_SLOT = 4       -- SWPS_MeleeWeapon 近战武器（镐子）
local MINE_BOOM_ITEM_ID = 8310033 -- 矿石炸弹 ItemID
local MINE_BOOM_SKILL_CLASS_PATH = "Asset/Blueprint/Prefabs/Skills/MineBoom.MineBoom_C"

-- 从技能对象获取 PlayerPawn
local function GetPlayerPawnFromSkill(Skill)
    if not Skill then return nil end

    local Ok, OwnerActor = pcall(Skill.GetOwnerActor, Skill)
    if Ok and OwnerActor and UE.IsValid(OwnerActor) then
        return OwnerActor
    end

    ugcprint("[MineBoom] GetOwnerActor 失败")
    return nil
end

-- 获取背包里矿石炸弹的数量
local function GetMineBoomCount(PlayerPawn)
    if not PlayerPawn then return 0 end
    if not UGCBackpackSystemV2 or not UGCBackpackSystemV2.GetItemCountV2 then return 0 end

    local Ok, Count = pcall(UGCBackpackSystemV2.GetItemCountV2, PlayerPawn, MINE_BOOM_ITEM_ID)
    if Ok and Count then
        return math.floor(tonumber(Count) or 0)
    end
    return 0
end

-- 切换到空手
local function SwitchToEmptyHand(PlayerPawn)
    if not PlayerPawn then return end

    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.CurrentWeaponAttachToBack then
        pcall(UGCWeaponManagerSystem.CurrentWeaponAttachToBack, PlayerPawn)
    end

    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.SwitchWeaponBySlot then
        pcall(UGCWeaponManagerSystem.SwitchWeaponBySlot, PlayerPawn, EMPTY_WEAPON_SLOT, true)
        ugcprint("[MineBoom] 切换到空手成功")
    end
end

-- 切换回近战武器
local function GetPlayerPawn(Skill)
    if not Skill then
        return nil
    end
    
    -- 尝试从 GetOwner 获取
    if Skill.GetOwner then
        local Owner = Skill:GetOwner()
        if Owner then
            -- 直接是 PlayerPawn
            if Owner.GetController then
                return Owner
            end
            -- 可能是 Controller
            if Owner.GetPawn then
                local Pawn = Owner:GetPawn()
                if Pawn then
                    return Pawn
                end
            end
        end
    end
    
    -- 从全局获取
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawns then
        local Pawns = UGCGameSystem.GetAllPlayerPawns()
        if Pawns and #Pawns > 0 then
            return Pawns[1]
        end
    end
    
    return nil
end

local function AttachWeaponToBack(PlayerPawn)
    if not PlayerPawn then
        return
    end
    
    if UGCWeaponManagerSystem and UGCWeaponManagerSystem.CurrentWeaponAttachToBack then
        local Ok = pcall(UGCWeaponManagerSystem.CurrentWeaponAttachToBack, PlayerPawn)
        if Ok then
            ugcprint("[MineBoom] 武器已挂到背后")
        end
    end
end

local function SwitchToMeleeWeapon(PlayerPawn)
    if not PlayerPawn then
        ugcprint("[MineBoom] SwitchToMeleeWeapon: PlayerPawn 为空")
        return
    end
    
    if not UGCWeaponManagerSystem or not UGCWeaponManagerSystem.SwitchWeaponBySlot then
        ugcprint("[MineBoom] SwitchWeaponBySlot 不可用")
        return
    end
    
    local Ok = pcall(UGCWeaponManagerSystem.SwitchWeaponBySlot, PlayerPawn, MELEE_WEAPON_SLOT, true)
    ugcprint("[MineBoom] 切换到近战武器槽: " .. tostring(Ok))
end

function MineBoom:OnEnableSkill_BP()
    MineBoom.SuperClass.OnEnableSkill_BP(self)
    ugcprint("[MineBoom] OnEnableSkill_BP 触发")

    -- 技能启用时立即切空手（最早的回调，确保武器不干扰后续逻辑）
    local PlayerPawn = GetPlayerPawnFromSkill(self)
    if PlayerPawn then
        SwitchToEmptyHand(PlayerPawn)
    end
end

function MineBoom:OnDisableSkill_BP()
    MineBoom.SuperClass.OnDisableSkill_BP(self)
    ugcprint("[MineBoom] OnDisableSkill_BP 触发")
end

function MineBoom:OnActivateSkill_BP()
    MineBoom.SuperClass.OnActivateSkill_BP(self)
    ugcprint("[MineBoom] OnActivateSkill_BP 触发")

    -- 服务器端：消耗1个矿石炸弹物品
    if UGCGameSystem and UGCGameSystem.IsServer and UGCGameSystem.IsServer() then
        local PlayerPawn = GetPlayerPawnFromSkill(self)
        if PlayerPawn and UGCBackpackSystemV2 and UGCBackpackSystemV2.RemoveItemV2 then
            local Ok = pcall(UGCBackpackSystemV2.RemoveItemV2, PlayerPawn, MINE_BOOM_ITEM_ID, 1)
            ugcprint("[MineBoom] 移除矿石炸弹: " .. tostring(Ok))
        end
    end

    ugcprint("[MineBoom] 技能激活")

    -- 激活时把当前武器挂到背后（变成空手状态）
    local PlayerPawn = GetPlayerPawn(self)
    if PlayerPawn then
        AttachWeaponToBack(PlayerPawn)
    end
end

function MineBoom:OnDeActivateSkill_BP()
    MineBoom.SuperClass.OnDeActivateSkill_BP(self)
    ugcprint("[MineBoom] OnDeActivateSkill_BP 触发")

    -- 立即恢复冷却，允许连续释放
    if UGCGameSystem and UGCGameSystem.IsServer and UGCGameSystem.IsServer() then
        pcall(self.ChargeCDEnergy, self, 1.0)
        ugcprint("[MineBoom] 重置冷却完成")
    end

    local PlayerPawn = GetPlayerPawnFromSkill(self)
    if not PlayerPawn then
        ugcprint("[MineBoom] OnDeActivateSkill_BP: PlayerPawn 为空")
        return
    end

    -- 检查背包里矿石炸弹的数量
    local Count = GetMineBoomCount(PlayerPawn)
    ugcprint(string.format("[MineBoom] 剩余矿石炸弹数量: %d", Count))

    -- 只有数量为0时才切换回镐子并移除技能实例
    if Count <= 0 then
        ugcprint("[MineBoom] 矿石炸弹已用完，切换回近战武器")
        RemoveMineBoomSkillInstance(PlayerPawn)
        SwitchToMeleeWeapon(PlayerPawn)
    else
        ugcprint("[MineBoom] 还有矿石炸弹，保持空手状态")
    end

    ugcprint("[MineBoom] 技能结束")

    -- 结束时切换回近战武器（镐子）
    local PlayerPawn2 = GetPlayerPawn(self)
    if PlayerPawn2 then
        -- 延迟一帧切换，确保技能完全结束
        if UGCGameSystem and UGCGameSystem.SetTimer then
            UGCGameSystem.SetTimer(function()
                SwitchToMeleeWeapon(PlayerPawn2)
            end, 0.1, false)
        else
            SwitchToMeleeWeapon(PlayerPawn2)
        end
    end
end

function MineBoom:CanActivateSkill_BP()
    return MineBoom.SuperClass.CanActivateSkill_BP(self)
end

return MineBoom