---@class BP_MineSpawn_C:BP_UGCItemSpawner_C
--Edit Below--
local BP_MineSpawn = {}
 
function BP_MineSpawn:ReceiveBeginPlay()
    if BP_MineSpawn.SuperClass and BP_MineSpawn.SuperClass.ReceiveBeginPlay then
        pcall(BP_MineSpawn.SuperClass.ReceiveBeginPlay, self)
    end

    if not UGCGameSystem.IsServer() then
        return
    end

    ugcprint("[MineSpawn] ✅ 矿区生成器已激活 (3秒后生成矿石)")
    UGCTimerUtility.CreateLuaTimer(3.0, function()
        local Ok, MineZoneManager = pcall(function()
            return UGCGameSystem.UGCRequire("Script.GamePartCustom.MineZoneManager")
        end)
        if Ok and type(MineZoneManager) == "table" and MineZoneManager.SpawnAllZones then
            MineZoneManager.SpawnAllZones()
        else
            ugcprint("[MineSpawn] ❌ MineZoneManager 加载失败")
        end
    end, false)
end

--[[
function BP_MineSpawn:OnItemSpawn(Item)
    
end
--]]

--[[
function BP_MineSpawn:CustomSpawnItem(CustomParam)
    
end
--]]

return BP_MineSpawn