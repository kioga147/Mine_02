---@class MineBoom_C:PESkillProjectileBase
---@field Capsule UCapsuleComponent
---@field ParticleSystem UParticleSystemComponent
---@field StaticMesh UStaticMeshComponent
--Edit Below--
local MineBoom = {}

local MiningSystem = UGCGameSystem.UGCRequire('Script.GamePartCustom.MiningSystem')

function MineBoom:ReceiveBeginPlay()
    MineBoom.SuperClass.ReceiveBeginPlay(self)
    if MiningSystem then
        MiningSystem.SetBombActive(true)
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