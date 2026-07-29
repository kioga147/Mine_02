local VehicleRepairConfig = {
    UnlockCost = 5000,
    RepairCost = 1000,
    DamageChance = 10,
    GoldItemId = 8310002,
    VehicleOrder = { 1, 2, 3 },
    Vehicles = {
        [1] = {
            ItemId = 8310025,
            Name = "初级采矿车",
            RangeText = "3x3",
            MineLevel = 2,
        },
        [2] = {
            ItemId = 8310024,
            Name = "中级采矿车",
            RangeText = "5x5",
            MineLevel = 4,
        },
        [3] = {
            ItemId = 8310023,
            Name = "高级采矿车",
            RangeText = "7x7",
            MineLevel = 5,
        },
    },
}

function VehicleRepairConfig.GetVehicle(VehicleId)
    local Id = math.floor(tonumber(VehicleId) or 0)
    if VehicleRepairConfig.Vehicles[Id] then
        return VehicleRepairConfig.Vehicles[Id], Id
    end
    for Key, Vehicle in pairs(VehicleRepairConfig.Vehicles) do
        if math.floor(tonumber(Vehicle.ItemId) or 0) == Id then
            return Vehicle, Key
        end
    end
    return nil, 0
end

function VehicleRepairConfig.GetFirstVehicleId()
    return VehicleRepairConfig.VehicleOrder[1] or 1
end

function VehicleRepairConfig.NextVehicleId(CurrentId)
    local Cur = math.floor(tonumber(CurrentId) or 0)
    local Order = VehicleRepairConfig.VehicleOrder
    for Index, Id in ipairs(Order) do
        if Id == Cur then
            return Order[(Index % #Order) + 1]
        end
    end
    return VehicleRepairConfig.GetFirstVehicleId()
end

function VehicleRepairConfig.RollDamage()
    local Chance = math.max(0, math.min(100, math.floor(tonumber(VehicleRepairConfig.DamageChance) or 0)))
    return Chance > 0 and math.random(1, 100) <= Chance
end

return VehicleRepairConfig
