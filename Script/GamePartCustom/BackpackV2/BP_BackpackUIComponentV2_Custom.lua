---@class BP_BackpackUIComponentV2_Custom_C:BP_BackpackUIComponentV2_C
--Edit Below--
local BP_BackpackUIComponentV2_Custom = {} 

local WarehouseConfig = nil
do
    local Ok, Mod = pcall(function()
        return UGCGameSystem.UGCRequire("Script.Common.WarehouseConfig")
    end)
    if Ok and type(Mod) == "table" then
        WarehouseConfig = Mod
    else
        WarehouseConfig = {
            UpgradeGoldCost = 5000,
            SlotsPerUpgrade = 100,
            MaxSlots = 10050,
            GetUpgradeGoldCost = function()
                return 5000
            end,
            GetSlotsPerUpgrade = function()
                return 100
            end,
            GetMaxSlots = function()
                return 10050
            end,
            CanUpgrade = function(CurrentCapacity)
                return (math.floor(tonumber(CurrentCapacity) or 0) + 100) <= 10050
            end,
        }
    end
end

--- 点击仓库锁格：走服务端升级（支持金币/绿洲币），此处仅发请求用金币档（UI 无支付切换）
local function TryRequestWarehouseUpgrade(PlayerController)
    if PlayerController == nil then
        return
    end
    if PlayerController.RequestUpgradeWarehouse then
        -- 锁格点击默认金币支付；绿洲币请走仓库设施面板切换
        PlayerController:RequestUpgradeWarehouse(0)
        return
    end
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_UpgradeWarehouse", 0)
end

---点击上锁格子的响应函数
---生效范围：客户端
---@param DataType number @类型 [0:背包数据, 1:仓库数据]
function BP_BackpackUIComponentV2_Custom:ClickLockBackpackItem(DataType)
    local PlayerController = self:GetOwner()
    if not PlayerController then return end
    local Player = PlayerController:GetPawn()
    DataType = math.floor(tonumber(DataType) or 0)

    if DataType == 1 then
        local Cap = 0
        if UGCBackpackSystemV2 and UGCBackpackSystemV2.GetWarehouseCellCapacity then
            Cap = math.floor(tonumber(UGCBackpackSystemV2.GetWarehouseCellCapacity(Player)) or 0)
        end
        if not WarehouseConfig.CanUpgrade(Cap) then
            ugcprint("[仓库升级] 已达上限 Cap=", Cap)
            return
        end
        ugcprint("[仓库升级] 锁格请求升级 Cap=", Cap, "Cost=", WarehouseConfig.GetUpgradeGoldCost())
        TryRequestWarehouseUpgrade(PlayerController)
        return
    end

    -- 背包锁格与 Minershop 统一走服务端 Server_UpgradeBackpack
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "Server_UpgradeBackpack")
end

---开始运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveBeginPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveBeginPlay(self)
end

---结束运行时执行
function BP_BackpackUIComponentV2_Custom:ReceiveEndPlay()
    BP_BackpackUIComponentV2_Custom.SuperClass.ReceiveEndPlay(self)
end

---背包UI打开后执行
---@param Panel UUserWidget @背包主界面控件
function BP_BackpackUIComponentV2_Custom:OnOpenBattleMainPanel(Panel)
    BP_BackpackUIComponentV2_Custom.SuperClass.OnOpenBattleMainPanel(self, Panel)
end

return BP_BackpackUIComponentV2_Custom
