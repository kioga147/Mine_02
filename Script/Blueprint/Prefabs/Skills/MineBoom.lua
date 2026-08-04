---@class MineBoom_C:PESkillTemplate_Base_C
--Edit Below--
local MineBoom = {}

local MELEE_WEAPON_SLOT = 4
local MELEE_SLOT_NAME = "EquipmentSlot.Core.MeleeSlot"

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
end

function MineBoom:OnDisableSkill_BP()
    MineBoom.SuperClass.OnDisableSkill_BP(self)
end

function MineBoom:OnActivateSkill_BP()
    MineBoom.SuperClass.OnActivateSkill_BP(self)
    ugcprint("[MineBoom] 技能激活")
    
    -- 激活时把当前武器挂到背后（变成空手状态）
    local PlayerPawn = GetPlayerPawn(self)
    if PlayerPawn then
        AttachWeaponToBack(PlayerPawn)
    end
end

function MineBoom:OnDeActivateSkill_BP()
    MineBoom.SuperClass.OnDeActivateSkill_BP(self)
    ugcprint("[MineBoom] 技能结束")
    
    -- 结束时切换回近战武器（镐子）
    local PlayerPawn = GetPlayerPawn(self)
    if PlayerPawn then
        -- 延迟一帧切换，确保技能完全结束
        if UGCGameSystem and UGCGameSystem.SetTimer then
            UGCGameSystem.SetTimer(function()
                SwitchToMeleeWeapon(PlayerPawn)
            end, 0.1, false)
        else
            SwitchToMeleeWeapon(PlayerPawn)
        end
    end
end

function MineBoom:CanActivateSkill_BP()
    return MineBoom.SuperClass.CanActivateSkill_BP(self)
end

return MineBoom