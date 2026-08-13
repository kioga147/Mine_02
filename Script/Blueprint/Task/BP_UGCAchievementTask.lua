---@class BP_UGCAchievementTask_C:UGCEvaluationTask
---@field TaskTarget int32
--Edit Below--
local BP_UGCAchievementTask = {}

function BP_UGCAchievementTask:GetTaskTargetProcess()
    return math.floor(tonumber(self.TaskTarget) or 0)
end

return BP_UGCAchievementTask
