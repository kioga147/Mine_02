---@class UGCPlayerController_C:BP_PlayerController_TopDown_C
---@field BuffClassTable ULuaArrayHelper<UClass>
---@field BuffClassTable1 ULuaArrayHelper<UClass>
--Edit Below--
local UGCPlayerController = {}

local COPPER_PICKAXE_ITEM_ID = 8310026

function UGCPlayerController:OnStartFire(Press)
    self.Character = UGCGameSystem.GetLocalPlayerPawn()

    local CurrentWeapon = UGCWeaponManagerSystem.GetCurrentWeapon(self.Character)
    if CurrentWeapon  then
        -- 全自动枪械处理
        if Press then
            UGCGunSystem.StartFire(CurrentWeapon)
        else
            UGCGunSystem.StopFire(CurrentWeapon)
        end
    end
end
    

function UGCPlayerController:ReceiveBeginPlay()
    UGCPlayerController.SuperClass.ReceiveBeginPlay(self)
    if not UGCGameSystem.IsServer() then
        GMP.GlobalMessage.BindUObject(self, "InputAction.StartFire", self, self.OnStartFire)

        local WidgetPath = UGCGameSystem.GetUGCResourcesFullPath('Asset/Blueprint/BP_RightJoystick.BP_RightJoystick_C')
        local function OnCreatedRightJoyStickWidget(Widget)
            self.RightJoyStickWidget = Widget
            UGCWidgetManagerSystem.AddToSlot(Widget, 'UI.UISlot.MainUISlot_High')
        end
        if not self.RightJoyStickWidget then
            UGCWidgetManagerSystem.CreateWidgetAsync(WidgetPath, OnCreatedRightJoyStickWidget)
        end
    else
        local selfRef = self
        UGCTimerManagerSystem.SetTimer(function()
            selfRef:GiveInitialCopperPickaxe()
        end, 8.0, false)
    end
end

function UGCPlayerController:GiveInitialCopperPickaxe()
    if not UGCGameSystem.IsServer() then
        ugcprint("[初始装备] ❌ 不在服务器，跳过")
        return
    end
    
    ugcprint("[初始装备] ====== 开始发放铜镐 ======")
    
    local PlayerPawn = UGCGameSystem.GetPlayerPawnByPlayerController(self)
    ugcprint("[初始装备] PlayerPawn:", tostring(PlayerPawn))
    
    if not PlayerPawn then
        ugcprint("[初始装备] ❌ 获取PlayerPawn失败，稍后重试...")
        local selfRef = self
        UGCTimerManagerSystem.SetTimer(function()
            selfRef:GiveInitialCopperPickaxe()
        end, 3.0, false)
        return
    end
    
    local currentCount = UGCBackpackSystemV2.GetItemCountV2(PlayerPawn, COPPER_PICKAXE_ITEM_ID)
    ugcprint("[初始装备] 当前铜镐数量:", currentCount)
    
    if currentCount <= 0 then
        ugcprint("[初始装备] 调用 AddItemV2(PlayerPawn, 8310026, 1)...")
        local result = {UGCBackpackSystemV2.AddItemV2(PlayerPawn, COPPER_PICKAXE_ITEM_ID, 1)}
        ugcprint("[初始装备] AddItemV2返回值类型:", type(result), "长度:", #result)
        if #result > 0 then
            for i, v in ipairs(result) do
                ugcprint("[初始装备] 返回值", i, ":", type(v), tostring(v))
            end
        end
        
        local newCount = UGCBackpackSystemV2.GetItemCountV2(PlayerPawn, COPPER_PICKAXE_ITEM_ID)
        ugcprint("[初始装备] 添加后铜镐数量:", newCount)
        
        if newCount > 0 then
            ugcprint("[初始装备] ✅ 已发放铜镐到背包")
            
            local selfRef = self
            UGCTimerManagerSystem.SetTimer(function()
                selfRef:EquipCopperPickaxe(PlayerPawn)
            end, 2.0, false)
        else
            ugcprint("[初始装备] ❌ 添加铜镐失败，尝试再次添加...")
            
            local selfRef = self
            UGCTimerManagerSystem.SetTimer(function()
                selfRef:GiveInitialCopperPickaxe()
            end, 5.0, false)
        end
    else
        ugcprint("[初始装备] 铜镐已存在")
        self:EquipCopperPickaxe(PlayerPawn)
    end
    
    ugcprint("[初始装备] ====== 发放流程结束 ======")
end

function UGCPlayerController:EquipCopperPickaxe(PlayerPawn)
    if not UGCGameSystem.IsServer() then
        ugcprint("[初始装备] ❌ 不在服务器，跳过装备")
        return
    end
    
    ugcprint("[初始装备] ====== 开始装备铜镐 ======")
    
    local defineIDs = UGCBackpackSystemV2.GetItemDefineIDsByIDV2(PlayerPawn, COPPER_PICKAXE_ITEM_ID)
    ugcprint("[初始装备] GetItemDefineIDsByIDV2返回值:", type(defineIDs))
    
    if defineIDs then
        ugcprint("[初始装备] 获取到的物品实例数量:", #defineIDs)
        for i, def in ipairs(defineIDs) do
            ugcprint("[初始装备] 实例", i, "类型:", type(def), "值:", tostring(def))
            if type(def) == "table" then
                for k, v in pairs(def) do
                    ugcprint("[初始装备]   属性", k, ":", type(v), tostring(v))
                end
            end
        end
        
        if #defineIDs > 0 then
            local firstDefineID = defineIDs[1]
            ugcprint("[初始装备] 准备装备的物品实例:", tostring(firstDefineID))
            
            ugcprint("[初始装备] 调用 EquipItemToAnySlotV2...")
            local equipResult = {UGCBackpackSystemV2.EquipItemToAnySlotV2(PlayerPawn, firstDefineID)}
            ugcprint("[初始装备] EquipItemToAnySlotV2返回值类型:", type(equipResult), "长度:", #equipResult)
            if #equipResult > 0 then
                for i, v in ipairs(equipResult) do
                    ugcprint("[初始装备] 装备返回值", i, ":", type(v), tostring(v))
                end
            end
            
            ugcprint("[初始装备] ✅ 装备完成")
        else
            ugcprint("[初始装备] ❌ 没有找到铜镐实例")
        end
    else
        ugcprint("[初始装备] ❌ GetItemDefineIDsByIDV2返回nil")
    end
    
    ugcprint("[初始装备] ====== 装备流程结束 ======")
end


--[[
function UGCPlayerController:ReceiveTick(DeltaTime)
    UGCPlayerController.SuperClass.ReceiveTick(self, DeltaTime)
end
--]]

--[[
function UGCPlayerController:ReceiveEndPlay()
    UGCPlayerController.SuperClass.ReceiveEndPlay(self) 
end
--]]

--[[
function UGCPlayerController:GetReplicatedProperties()
    return
end
--]]

--[[
function UGCPlayerController:GetAvailableServerRPCs()
    return
end
--]]

return UGCPlayerController