---@class UGC_Common_Get_FX_UIBP_C:UUserWidget
---@field DX_Flip UWidgetAnimation
---@field Button_ItemGet_Item UButton
---@field CanvasPanel_Name UCanvasPanel
---@field Image_Fragments UImage
---@field Image_ItemGet_Item_GoodsLogo UImage
---@field Image_ItemGet_Item_GoodsQualityBg UImage
---@field Image_ItemGet_Item_GoodsQualityLight UImage
---@field ItemSlot UCanvasPanel
---@field TextBlock_ItemGet_Item_GoodsAmount UTextBlock
---@field TextBlock_ItemGet_Item_GoodsDays UTextBlock
---@field TextBlock_ItemGet_Item_GoodsName UTextBlock
--Edit Below--
local UGC_RankingList_Get_FX_UIBP = { bInitDoOnce = false } 

function UGC_RankingList_Get_FX_UIBP:Construct()
	
end


-- function UGC_RankingList_Get_FX_UIBP:Tick(MyGeometry, InDeltaTime)

-- end

-- function UGC_RankingList_Get_FX_UIBP:Destruct()

-- end

function UGC_RankingList_Get_FX_UIBP:InitUI(ItemID, ItemNum)
    local ObjectDatas = Common.GetObjectDatas();
    local ItemInfo = ObjectDatas[ItemID];
    if ItemInfo then
        if ItemInfo.ItemIcon then
            Common.LoadObjectAsync(ItemInfo.ItemIcon, 
            function (Object)
                if self ~= nil and Object ~= nil then
                    self.Image_ItemGet_Item_GoodsLogo:SetBrushFromTexture(Object);
                end
            end)
        end

        if ItemInfo.ItemName then
            self.TextBlock_ItemGet_Item_GoodsName:SetText(ItemInfo.ItemName);
        end
    end
    self.TextBlock_ItemGet_Item_GoodsAmount:SetText(tostring(ItemNum));
end

return UGC_RankingList_Get_FX_UIBP
