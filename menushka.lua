local function DrawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(Material("pp/blurscreen"))
    
    for i = 1, 3 do
        Material("pp/blurscreen"):SetFloat("$blur", (i / 3) * (amount or 6))
        Material("pp/blurscreen"):Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end
end

local isScoreboardVisible = false
local scoreboardFrame = nil

local function GetPlayerPropCount(ply)
    if IsValid(ply) and ply:IsPlayer() then
        return ply:GetCount("props") or 0
    end
    return 0
end

local function UpdatePlayerList(playerList)
    playerList:Clear()

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local playerPanel = vgui.Create("DPanel", playerList)
            playerPanel:SetSize(playerList:GetWide() - 300, 50)
            playerPanel:Dock(TOP)
            playerPanel:DockMargin(150, 0, 150, 10)
            playerPanel.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
                draw.SimpleText(ply:Nick(), "DermaDefaultBold", 20, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local muteButton = vgui.Create("DButton", playerPanel)
            muteButton:SetSize(80, 30)
            muteButton:SetPos(playerPanel:GetWide() - 300, 10)
            muteButton:SetText(ply:IsMuted() and "Unmute" or "Mute")
            muteButton.DoClick = function()
                if IsValid(ply) then
                    ply:SetMuted(not ply:IsMuted())
                    muteButton:SetText(ply:IsMuted() and "Unmute" or "Mute")
                end
            end

            local pingLabel = vgui.Create("DLabel", playerPanel)
            pingLabel:SetSize(100, 30)
            pingLabel:SetPos(playerPanel:GetWide() - 200, 10)
            pingLabel:SetText("Ping: " .. ply:Ping() .. (not ply:Alive() and " (мертв)" or ""))
            pingLabel:SetTextColor(Color(255, 255, 255))
            pingLabel:SetFont("DermaDefault")

            local propCountLabel = vgui.Create("DLabel", playerPanel)
            propCountLabel:SetSize(100, 30)
            propCountLabel:SetPos(playerPanel:GetWide() - 100, 10)
            propCountLabel:SetText("Props: " .. GetPlayerPropCount(ply))
            propCountLabel:SetTextColor(Color(255, 255, 255))
            propCountLabel:SetFont("DermaDefault")
        end
    end
end

local function ShowCustomScoreboard()
    if IsValid(scoreboardFrame) then
        scoreboardFrame:SetVisible(true)
        UpdatePlayerList(scoreboardFrame.PlayerList)
    else
        scoreboardFrame = vgui.Create("DFrame")
        scoreboardFrame:SetSize(ScrW(), ScrH())
        scoreboardFrame:SetPos(0, 0)
        scoreboardFrame:SetTitle("")
        scoreboardFrame:ShowCloseButton(false)
        scoreboardFrame:SetDraggable(false)
        scoreboardFrame:SetBackgroundBlur(false)
        scoreboardFrame:SetDrawOnTop(true)
        scoreboardFrame.Paint = function(self, w, h)
            DrawBlur(self, 6)
            draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 25, 200))
            draw.SimpleText("Список игроков", "DermaLarge", w / 2, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        local playerList = vgui.Create("DScrollPanel", scoreboardFrame)
        playerList:SetSize(scoreboardFrame:GetWide() - 50, scoreboardFrame:GetTall() - 100)
        playerList:SetPos(25, 75)

        scoreboardFrame.PlayerList = playerList

        UpdatePlayerList(playerList)
    end

    isScoreboardVisible = true
    gui.EnableScreenClicker(true)
end

local function HideCustomScoreboard()
    if IsValid(scoreboardFrame) then
        scoreboardFrame:SetVisible(false)
    end

    isScoreboardVisible = false
    gui.EnableScreenClicker(false)
end

hook.Add("ScoreboardShow", "CustomScoreboardShow", function()
    ShowCustomScoreboard()
    return true
end)

hook.Add("ScoreboardHide", "CustomScoreboardHide", function()
    HideCustomScoreboard()
    return true
end)

hook.Add("PlayerInitialSpawn", "UpdateScoreboardOnJoin", function(ply)
    if IsValid(scoreboardFrame) then
        UpdatePlayerList(scoreboardFrame.PlayerList)
    end
end)
