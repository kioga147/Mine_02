--- 进入确认过渡按钮管理器：全局唯一 WBP_EnterButton 实例
--- 前提：10 个建筑触发器互不重叠，同一时刻至多一个建筑触发，因此无需仲裁
---
--- ⚠️ 2026-08-19 卡死根因与修复：
--- 多场 PIE 会话日志确认：进入建筑触发器 -> ShowEnterButton -> EnterButtonManager.Show
--- -> UGCWidgetManagerSystem.CreateWidgetAsync(WBP_EnterButton) 时，PIE 客户端游戏线程在
--- "battlemodulerequire ... WBP_EnterButton load success" 之后、Lua Construct 执行之前卡死，
--- 之后不再有任何游戏线程日志，随后进程被系统强制结束（8/19 15:13 / 15:26 / 16:03 / 16:12 会话一致复现）。
--- 同一客户端里直接创建 WBP_JadeFacilityPrompt 则完全正常（8/17、8/18 多场验证“模式选择层已显示”并可交互）。
---
--- 处理：ENABLE_ENTER_BUTTON_UI 默认 false，进触发器后直接打开建筑 UI
--- （等价于旧版已验证可用的 OnTriggerBeginOverlap -> ShowPrompt），彻底绕开
--- WBP_EnterButton.uasset 的原生创建，避免卡死。
--- 待 WBP_EnterButton.uasset 在编辑器内重建并通过 PIE 验证后，再将该开关置为 true 恢复“进入按钮”。
local ENABLE_ENTER_BUTTON_UI = false

local EnterButtonManager = {}

local ENTER_BTN_PATH = 'Asset/Blueprint/Prefabs/UI/WBP_EnterButton.WBP_EnterButton_C'
local Instance = nil
local bPending = false
local PendingName = nil
local PendingCallback = nil

local function GetLocalPC()
    return UGCGameSystem.GetLocalPlayerController()
end

local function SafeRemove(Widget)
    if Widget and Widget.RemoveFromParent then
        pcall(function()
            Widget:RemoveFromParent()
        end)
    end
end

--- 显示过渡按钮；开关关闭时直接打开建筑 UI
--- @param BuildingName string 按钮上显示的建筑名
--- @param OnOpenCallback function 点击后执行（打开对应建筑 UI）
function EnterButtonManager.Show(BuildingName, OnOpenCallback)
    if not ENABLE_ENTER_BUTTON_UI then
        ugcprint('[EnterButton] bypass: 直开建筑UI ' .. tostring(BuildingName))
        -- 绕开 WBP_EnterButton.uasset 创建（防 PIE 客户端卡死），直接打开建筑 UI
        if OnOpenCallback then
            pcall(OnOpenCallback)
        end
        return
    end

    ugcprint('[EnterButton] Show called: ' .. tostring(BuildingName))
    if Instance then
        if Instance.SetData then
            Instance:SetData(BuildingName, OnOpenCallback)
        else
            ugcprint('[EnterButton] WARNING: Instance.SetData 不存在')
        end
        return
    end

    PendingName = BuildingName
    PendingCallback = OnOpenCallback
    if bPending then
        ugcprint('[EnterButton] pending, 等待异步创建')
        return
    end
    bPending = true

    local Path = UGCGameSystem.GetUGCResourcesFullPath(ENTER_BTN_PATH)
    if not Path or Path == '' then
        bPending = false
        PendingName = nil
        PendingCallback = nil
        ugcprint('[EnterButton] ERROR: WBP_EnterButton 路径无效')
        return
    end

    ugcprint('[EnterButton] CreateWidgetAsync 开始: ' .. tostring(Path))
    UGCWidgetManagerSystem.CreateWidgetAsync(Path, function(Widget)
        bPending = false
        if not Widget then
            PendingName = nil
            PendingCallback = nil
            ugcprint('[EnterButton] ERROR: CreateWidgetAsync 返回空')
            return
        end
        local Name = PendingName
        local Cb = PendingCallback
        PendingName = nil
        PendingCallback = nil
        if not Name then
            SafeRemove(Widget)
            ugcprint('[EnterButton] 已取消（无目标建筑）')
            return
        end
        Instance = Widget
        if Widget.SetData then
            local function OnEntered()
                EnterButtonManager.Hide()
                if Cb then
                    pcall(Cb)
                end
            end
            Widget:SetData(Name, OnEntered)
        else
            ugcprint('[EnterButton] WARNING: Widget.SetData 不存在')
        end
        UGCWidgetManagerSystem.AddToSlot(Widget, 'UI.UISlot.MainUISlot_High')
        ugcprint('[EnterButton] AddToSlot done')
        pcall(function()
            if Widget.AfterAdded then
                Widget:AfterAdded()
            end
        end)
    end)
end

--- 隐藏并销毁过渡按钮
function EnterButtonManager.Hide()
    local W = Instance
    local bHad = (W ~= nil) or (PendingName ~= nil)
    PendingName = nil
    PendingCallback = nil
    Instance = nil
    if bHad then
        ugcprint('[EnterButton] Hide called')
    end
    SafeRemove(W)
end

return EnterButtonManager
