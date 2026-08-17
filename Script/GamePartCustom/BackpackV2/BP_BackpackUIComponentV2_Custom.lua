---@class BP_BackpackUIComponentV2_Custom_C:BP_BackpackUIComponentV2_C
--Edit Below--
local BP_BackpackUIComponentV2_Custom = {}

local TITLE_SWITCH_PANEL_PATH = 'Asset/Blueprint/Prefabs/UI/WBP_TitleSwitchPanel.WBP_TitleSwitchPanel_C'
local TITLE_SWITCH_PANEL_ENABLED = true
-- 官方背包预设锚点：侧边栏（参考 docs/wiki/进阶内容/UI系统/20097_和平控件锚点.md）
local TITLE_SWITCH_SLOT_NAME = 'UI.UISlot.BackpackUISlot.Full.OptionSlot'

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

local function GetLocalPlayerControllerSafe()
    if UGCGameSystem and UGCGameSystem.GetLocalPlayerController then
        local Ok, PC = pcall(UGCGameSystem.GetLocalPlayerController)
        if Ok then
            return PC
        end
    end
    return nil
end

function BP_BackpackUIComponentV2_Custom:ShowTitleSwitchPanel(Panel)
    if self.TitleSwitchPanel and UE.IsValid(self.TitleSwitchPanel) then
        if self.TitleSwitchPanel.InitUI then
            pcall(self.TitleSwitchPanel.InitUI, self.TitleSwitchPanel)
        end
        self.TitleSwitchPanel:SetVisibility(ESlateVisibility.Visible)
        ugcprint("[称号] TitleSwitchPanel 复用已有面板")
        return
    end

    local WidgetPath = UGCGameSystem.GetUGCResourcesFullPath(TITLE_SWITCH_PANEL_PATH)
    if not WidgetPath or WidgetPath == '' then
        ugcprint("[称号] TitleSwitchPanel path not found")
        return
    end

    -- 官方方案：CreateWidgetAsync + AddToSlot 挂到背包侧边栏锚点
    UGCWidgetManagerSystem.CreateWidgetAsync(WidgetPath, function(WidgetInstance)
        if not WidgetInstance then
            ugcprint("[称号] TitleSwitchPanel CreateWidgetAsync 失败")
            return
        end
        if not UGCObjectUtility.IsObjectValid(self) then
            ugcprint("[称号] TitleSwitchPanel 创建回调时组件已销毁")
            return
        end

        local AnchorData = CreateStruct("AnchorData")
        local OffsetsData = CreateStruct("Margin")
        OffsetsData.Left = 0
        OffsetsData.Top = 0
        OffsetsData.Right = 0
        OffsetsData.Bottom = 0
        local Anchors = CreateStruct("Anchors")
        Anchors.Minimum = Vector2D.New(0, 0)
        Anchors.Maximum = Vector2D.New(1, 1)
        AnchorData.Offsets = OffsetsData
        AnchorData.Anchors = Anchors
        AnchorData.Alignment = Vector2D.New(0, 0)

        UGCWidgetManagerSystem.AddToSlot(WidgetInstance, TITLE_SWITCH_SLOT_NAME, 0, AnchorData)

        self.TitleSwitchPanel = WidgetInstance
        WidgetInstance:SetVisibility(ESlateVisibility.Visible)

        if WidgetInstance.InitUI then
            pcall(WidgetInstance.InitUI, WidgetInstance)
        end

        ugcprint("[称号] TitleSwitchPanel 已挂载到背包 OptionSlot")
    end)
end

function BP_BackpackUIComponentV2_Custom:RefreshTitleSwitchPanel()
    if self.TitleSwitchPanel and UE.IsValid(self.TitleSwitchPanel) and self.TitleSwitchPanel.RefreshList then
        pcall(self.TitleSwitchPanel.RefreshList, self.TitleSwitchPanel)
    end
end

function BP_BackpackUIComponentV2_Custom:HideTitleSwitchPanel()
    if self.TitleSwitchPanel then
        if UE.IsValid(self.TitleSwitchPanel) then
            pcall(UGCWidgetManagerSystem.RemoveFromSlot, self.TitleSwitchPanel)
            pcall(UGCWidgetManagerSystem.DestroyWidget, self.TitleSwitchPanel)
            ugcprint("[称号] TitleSwitchPanel 已从 OptionSlot 移除并销毁")
        end
        self.TitleSwitchPanel = nil
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
    if Player == nil then
        ugcprint("[背包UI] 未找到本机玩家，锁格点击忽略 DataType=", DataType)
        return
    end

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
    if TITLE_SWITCH_PANEL_ENABLED then
        self:ShowTitleSwitchPanel(Panel)
    end
end

function BP_BackpackUIComponentV2_Custom:OnCloseBattleMainPanel(Panel)
    BP_BackpackUIComponentV2_Custom.SuperClass.OnCloseBattleMainPanel(self, Panel)
    self:HideTitleSwitchPanel()
end

return BP_BackpackUIComponentV2_Custom