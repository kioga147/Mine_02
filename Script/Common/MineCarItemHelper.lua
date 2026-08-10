local MineCarItemHelper = {}

local MELEE_SLOT_NAME = "EquipmentSlot.Core.MeleeSlot"
local MELEE_WEAPON_SLOT = 4

local function GetPlayerPawnFromItem(Item)
    if not Item then
        return nil
    end
    if UGCItemSystemV2 and UGCItemSystemV2.GetOwnBackpackComponent then
        local Ok, Backpack = pcall(UGCItemSystemV2.GetOwnBackpackComponent, Item)
        if Ok and Backpack and Backpack.GetOwner then
            local OkPc, PC = pcall(Backpack.GetOwner, Backpack)
            if OkPc and PC and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
                local OkPawn, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, PC)
                if OkPawn and Pawn then
                    return Pawn
                end
            end
        end
    end

    local Owner = nil
    local GetOwnerOk = pcall(function()
        Owner = Item:GetOwner()
    end)
    if GetOwnerOk and Owner then
        if Owner.SetMineCarMode then
            return Owner
        end
        local Parent = nil
        local GetParentOk = pcall(function()
            Parent = Owner:GetOwner()
        end)
        if GetParentOk and Parent and Parent.SetMineCarMode then
            return Parent
        end
        local Controller = nil
        local GetCtrlOk = pcall(function()
            Controller = Owner:GetController()
        end)
        if GetCtrlOk and Controller and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
            local Ok, Pawn = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, Controller)
            if Ok and Pawn then
                return Pawn
            end
        end
    end
    return nil
end

local function GetPlayerController(Player)
    if Player and Player.GetController then
        local Ok, PC = pcall(Player.GetController, Player)
        if Ok then
            return PC
        end
    end
    return nil
end

local function SwitchToMelee(Player)
    local function DoSwitch()
        if Player and UE.IsValid(Player)
            and UGCWeaponManagerSystem and UGCWeaponManagerSystem.SwitchWeaponBySlot then
            pcall(UGCWeaponManagerSystem.SwitchWeaponBySlot, Player, MELEE_WEAPON_SLOT, true)
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.3, DoSwitch, false)
    else
        DoSwitch()
    end
end

local function ExitMineCarMode(Player)
    if Player and Player.IsMineCarMode and Player:IsMineCarMode() then
        ugcprint("[MineCarItemHelper] 退出矿车模式恢复人形")
        if Player.SetMineCarMode then
            Player:SetMineCarMode(false)
        elseif Player.DoSetMineCarMode then
            Player:DoSetMineCarMode(false)
        end
    end
end

local function ScheduleExitMineCarMode(Player)
    local function Done()
        ExitMineCarMode(Player)
        if Player then
            Player._mineCarSwitchingToMelee = nil
        end
    end
    if UGCTimerUtility and UGCTimerUtility.CreateLuaTimer then
        UGCTimerUtility.CreateLuaTimer(0.35, function()
            Done()
        end, false)
    else
        Done()
    end
end

function MineCarItemHelper.SwitchToMeleeItemByHandle(ItemHandle, ItemID)
    local Player = GetPlayerPawnFromItem(ItemHandle)
    if not Player or not (Player.IsMineCarMode and Player:IsMineCarMode()) then
        return
    end
    if Player._mineCarSwitchingToMelee then
        return
    end
    Player._mineCarSwitchingToMelee = true
    local PC = GetPlayerController(Player)
    if not PC then
        Player._mineCarSwitchingToMelee = nil
        return
    end
    local Ok, IDs = pcall(UGCBackpackSystemV2.GetItemDefineIDsByIDV2, PC, ItemID)
    if not (Ok and IDs and #IDs > 0) then
        Player._mineCarSwitchingToMelee = nil
        return
    end
    ugcprint("[MineCarItemHelper] 切换到近战物品:", ItemID)
    pcall(UGCBackpackSystemV2.EquipItemV2, PC, MELEE_SLOT_NAME, IDs[1])
    SwitchToMelee(Player)
    ScheduleExitMineCarMode(Player)
end

function MineCarItemHelper.SwitchToMeleeItemByPC(PC, ItemID)
    if not PC then
        return
    end
    local Player = nil
    if PC.GetPawn then
        local Ok, P = pcall(PC.GetPawn, PC)
        if Ok then
            Player = P
        end
    end
    if Player == nil and UGCGameSystem and UGCGameSystem.GetPlayerPawnByPlayerController then
        local Ok, P = pcall(UGCGameSystem.GetPlayerPawnByPlayerController, PC)
        if Ok then
            Player = P
        end
    end
    if not Player or not (Player.IsMineCarMode and Player:IsMineCarMode()) then
        return
    end
    if Player._mineCarSwitchingToMelee then
        return
    end
    Player._mineCarSwitchingToMelee = true
    local Ok, IDs = pcall(UGCBackpackSystemV2.GetItemDefineIDsByIDV2, PC, ItemID)
    if not (Ok and IDs and #IDs > 0) then
        Player._mineCarSwitchingToMelee = nil
        return
    end
    ugcprint("[MineCarItemHelper] 通过背包组件切换到近战物品:", ItemID)
    pcall(UGCBackpackSystemV2.EquipItemV2, PC, MELEE_SLOT_NAME, IDs[1])
    SwitchToMelee(Player)
    ScheduleExitMineCarMode(Player)
end

return MineCarItemHelper
