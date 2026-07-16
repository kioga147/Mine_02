---@class UGCPlayerController_C:BP_PlayerController_TopDown_C
---@field BuffClassTable ULuaArrayHelper<UClass>
---@field BuffClassTable1 ULuaArrayHelper<UClass>
--Edit Below--
local UGCPlayerController = {}

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
    end
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