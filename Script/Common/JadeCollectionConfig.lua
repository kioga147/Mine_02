local JadeCollectionConfig = {
    SlotCount = 5,
    BaseValue = 600,
    JadeItemId = 8310011,
    LegacyJadeItemId = 8310018,
    StateEmpty = 0,
    StateRaw = 1,
    StateAppraised = 2,
    TotalCells = 25,
}

function JadeCollectionConfig.GetSlotCount()
    return JadeCollectionConfig.SlotCount
end

function JadeCollectionConfig.GetBaseValue()
    return JadeCollectionConfig.BaseValue
end

function JadeCollectionConfig.GetTotalCells()
    return JadeCollectionConfig.TotalCells
end

function JadeCollectionConfig.GetStateName(State, OpenedCount, TotalCells)
    State = math.floor(tonumber(State) or 0)
    OpenedCount = math.floor(tonumber(OpenedCount) or 0)
    TotalCells = math.floor(tonumber(TotalCells) or JadeCollectionConfig.TotalCells)

    if State == JadeCollectionConfig.StateRaw then
        return "未鉴定玉石"
    end
    if State == JadeCollectionConfig.StateAppraised then
        if TotalCells > 0 and OpenedCount >= TotalCells then
            return "完全鉴定玉石"
        end
        return "未完全鉴定玉石"
    end
    return "空展台"
end

return JadeCollectionConfig
