---@class WBP_RankingListBtn_C:UUserWidget
---@field ClearRankData UButton
---@field IsIncremental UEditableTextBox
---@field RankID UEditableTextBox
---@field Score UEditableTextBox
---@field UID UEditableTextBox
---@field UpdateRankScore UButton
--Edit Below--
local WBP_RankingListBtn = { bInitDoOnce = false } 

function WBP_RankingListBtn:Construct()
    self.UpdateRankScore.OnClicked:Add(self.UpdateRankListScore, self);
    self.ClearRankData.OnClicked:Add(self.ClearAllRankData, self);
end

function WBP_RankingListBtn:UpdateRankListScore()
    print("WBP_RankingListBtn:UpdateRankListScore");
    if self.RankID.Text == nil or self.RankID.Text == "" or self.Score.Text == nil or self.Score.Text == "" or self.UID.Text == nil or self.UID.Text == "" then
        return;
    end

    local RankID = tonumber(self.RankID.Text);
    local Score = tonumber(self.Score.Text);
    local UID = tonumber(self.UID.Text);
    local IsIncremental = tonumber(self.IsIncremental.Text);

    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    if RankingListGlobalActor then
        local PC = STExtraGameplayStatics.GetFirstPlayerController(self);
        if IsIncremental == 0 then
            RankingListGlobalActor:UpdateScore(PC, UID, RankID, Score, false);
        else
            RankingListGlobalActor:UpdateScore(PC, UID, RankID, Score, true);
        end
    end
    -- RankingListManager:UpdatePlayerRankingScore(PlayerController, UID, RankID, Score);
end

function WBP_RankingListBtn:ClearAllRankData()
    local RankingListGlobalActor = UGCGamePartSystem.GetGamePartGlobalActor("RankingListManager");
    if RankingListGlobalActor then
        RankingListGlobalActor:PIEClearAllRankListData();
    end
end

return WBP_RankingListBtn
