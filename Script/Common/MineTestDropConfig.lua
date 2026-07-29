local MineTestDropConfig = {
    bEnableGoldOnMineDestroy = true,
    GoldItemId = 8310002,
    GoldCount = 10000,
}

function MineTestDropConfig.GiveTestGold(EventInstigator)
    if not MineTestDropConfig.bEnableGoldOnMineDestroy then
        return false
    end
    if EventInstigator == nil or UGCBackpackSystemV2 == nil or UGCBackpackSystemV2.AddItemV2 == nil then
        return false
    end
    local Ok = pcall(function()
        UGCBackpackSystemV2.AddItemV2(
            EventInstigator,
            MineTestDropConfig.GoldItemId,
            MineTestDropConfig.GoldCount
        )
    end)
    if Ok then
        ugcprint("[MineTestDrop] 挖矿测试发放金币 x" .. tostring(MineTestDropConfig.GoldCount))
    end
    return Ok and true or false
end

return MineTestDropConfig
