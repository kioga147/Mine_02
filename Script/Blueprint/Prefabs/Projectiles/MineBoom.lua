---@class MineBoom_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field ParticleSystem UParticleSystemComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local MineBoom = {}

local MiningSystem = UGCGameSystem.UGCRequire('Script.GamePartCustom.MiningSystem')
local MINE_BOOM_SKILL_CLASS_PATH = "Asset/Blueprint/Prefabs/Skills/MineBoom.MineBoom_C"

function MineBoom:ReceiveBeginPlay()
    MineBoom.SuperClass.ReceiveBeginPlay(self)
    
    if MiningSystem then
        MiningSystem.SetBombActive(true)
    end

    -- 投射物生成后立即结束技能，允许连续释放
    if UGCGameSystem and UGCGameSystem.IsServer and UGCGameSystem.IsServer() then
        local Instigator = self:GetInstigator()
        if Instigator and UE.IsValid(Instigator) then
            local FullPath = UGCGameSystem.GetUGCResourcesFullPath(MINE_BOOM_SKILL_CLASS_PATH)
            local SkillClass = UGCObjectUtility.LoadClass(FullPath)
            if SkillClass and UGCPersistEffectSystem and UGCPersistEffectSystem.GetSkillsByClass then
                local Ok, Skills = pcall(UGCPersistEffectSystem.GetSkillsByClass, Instigator, SkillClass)
                if Ok and Skills and #Skills > 0 then
                    for _, SkillInst in ipairs(Skills) do
                        if UE.IsValid(SkillInst) then
                            pcall(SkillInst.DeActivateSkill, SkillInst, 0)
                            ugcprint("[MineBoom] 投射物-立即结束技能")
                        end
                    end
                end
            end
        end
    end
end
 
--[[
function MineBoom:ReceiveTick(DeltaTime)
    MineBoom.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function MineBoom:GetReplicatedProperties()
    return
end
--]]

--[[
function MineBoom:GetAvailableServerRPCs()
    return
end
--]]

return MineBoom
