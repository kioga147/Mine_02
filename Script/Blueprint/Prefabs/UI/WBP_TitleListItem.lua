---@class WBP_TitleListItem_C:UUserWidget
---@field Btn_Title UButton
---@field Icon_Image UImage
--Edit Below--
local WBP_TitleListItem = {}

function WBP_TitleListItem:Construct()
    if self.Btn_Title and self.Btn_Title.OnClicked then
        self.Btn_Title.OnClicked:Add(self.OnClicked, self)
    end
end
function WBP_TitleListItem:Destruct()
    if self.Btn_Title and self.Btn_Title.OnClicked then
        self.Btn_Title.OnClicked:Remove(self.OnClicked, self)
    end
end
function WBP_TitleListItem:InitData(Data)
    self.Data = Data or {}
    if self.Icon_Image then
        if self.Data.IconPath then
            local FullPath = UGCGameSystem.GetUGCResourcesFullPath(self.Data.IconPath)
            if FullPath and FullPath ~= '' then
                local OkTex, Texture = pcall(UGCObjectUtility.LoadObject, FullPath)
                if OkTex and Texture then
                    self.Icon_Image:SetBrushFromTexture(Texture, true)
                end
            end
            self.Icon_Image:SetVisibility(ESlateVisibility.Visible)
        else
            self.Icon_Image:SetVisibility(ESlateVisibility.Collapsed)
        end
        local Tint = { R = 1, G = 1, B = 1, A = 1 }
        if self.Data.Equipped then
            Tint = { R = 1, G = 0.85, B = 0.3, A = 1 }
        elseif not self.Data.Unlocked then
            Tint = { R = 0.45, G = 0.45, B = 0.45, A = 0.4 }
        end
        if self.Icon_Image.SetColorAndOpacity then
            pcall(self.Icon_Image.SetColorAndOpacity, self.Icon_Image, Tint)
        end
    end
end
function WBP_TitleListItem:OnClicked()
    if self.OnSwitchTitle then
        self.OnSwitchTitle(self.Data.TitleID, self.Data)
    end
end
return WBP_TitleListItem