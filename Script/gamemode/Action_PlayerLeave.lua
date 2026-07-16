local Action_PlayerLeave = {
    -- 可配置参数定义，参数将显示在Action配置面板
    -- 例：
    -- MyIntParameter = 0
    PlayerKey = 0;
}

-- 触发器激活时，将执行Action的Execute
function Action_PlayerLeave:Execute(...)
    ugcprint(string.format("[Action_PlayerLeave] Start settlement %d", self.PlayerKey));
    UGCGameSystem.SendPlayerSettlement(self.PlayerKey);
    return true
end

--[[
-- 需要勾选Action的EnableTick，才会执行Update
-- 触发器激活后，将在每个tick执行Action的Update，直到self.bEnableActionTick为false
function Action_PlayerLeave:Update(DeltaSeconds)

end
]]

return Action_PlayerLeave