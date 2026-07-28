---@class Advanced_MiningTruck_C:BP_UGC_MeleeWeap_Pan_C
--Edit Below--
local Advanced_MiningTruck = {}

local function GetPlayerPawnFromWeapon(Weapon)
    local Owner = Weapon:GetOwner()
    
    if Owner then
        if Owner.SetMineCarMode then
            return Owner
        end
        
        if Owner.GetOwner then
            local Parent = Owner:GetOwner()
            if Parent and Parent.SetMineCarMode then
                return Parent
            end
        end
        
        if Owner.GetController then
            local Controller = Owner:GetController()
            if Controller and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local Ok, PlayerPawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Controller)
                if Ok and PlayerPawn and PlayerPawn.SetMineCarMode then
                    return PlayerPawn
                end
            end
        end
    end
    
    if UGCGameSystem and UGCGameSystem.GetAllPlayerPawns then
        local Pawns = UGCGameSystem.GetAllPlayerPawns()
        for _, Pawn in ipairs(Pawns) do
            if Pawn and Pawn.SetMineCarMode then
                return Pawn
            end
        end
    end
    
    return nil
end

function Advanced_MiningTruck:ReceiveBeginPlay()
    Advanced_MiningTruck.SuperClass.ReceiveBeginPlay(self)
    
    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    
    if PlayerPawn and PlayerPawn.SetMineCarMode then
        UGCAttributeSystem.SetGameAttributeValue(PlayerPawn, "AxeLevel", 5)
        
        if PlayerPawn.IsMineCarMode and PlayerPawn:IsMineCarMode() then
            return
        end
        
        PlayerPawn:SetMineCarMode(true)
        
        if UGCTimerManagerSystem and UGCTimerManagerSystem.SetTimer then
            UGCTimerManagerSystem.SetTimer(function()
                self:AddMineCarSkill(PlayerPawn)
            end, 1.5, false)
        else
            self:AddMineCarSkill(PlayerPawn)
        end
    end
end

function Advanced_MiningTruck:AddMineCarSkill(PlayerPawn)
    local SkillPaths = {
        "/Mine_02/Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C",
        "/Game/Mine_02/Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C",
        UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/Prefabs/Skills/MaxVehicle.MaxVehicle_C')
    }
    
    local SkillClass = nil
    for _, Path in ipairs(SkillPaths) do
        SkillClass = UGCObjectUtility.LoadClass(Path)
        if SkillClass then
            break
        end
    end
    
    if SkillClass then
        local ExistSkills = UGCPersistEffectSystem.GetSkillsByClass(PlayerPawn, SkillClass)
        
        if #ExistSkills == 0 then
            local Skill = UGCPersistEffectSystem.AddSkillByClass(PlayerPawn, SkillClass, -1)
            if Skill then
                if Skill.OnApply_BP then
                    pcall(Skill.OnApply_BP, Skill)
                end
                if Skill.Activate then
                    pcall(Skill.Activate, Skill)
                end
            end
        else
            local Skill = ExistSkills[1]
            if Skill and Skill.OnApply_BP then
                pcall(Skill.OnApply_BP, Skill)
            end
        end
    end
end

function Advanced_MiningTruck:ReceiveEndPlay()
    Advanced_MiningTruck.SuperClass.ReceiveEndPlay(self) 
    
    local PlayerPawn = GetPlayerPawnFromWeapon(self)
    
    if PlayerPawn and PlayerPawn.SetMineCarMode then
        PlayerPawn:SetMineCarMode(false)
    end
end

function Advanced_MiningTruck:GetReplicatedProperties()
    return
end

function Advanced_MiningTruck:GetAvailableServerRPCs()
    return
end

return Advanced_MiningTruck
