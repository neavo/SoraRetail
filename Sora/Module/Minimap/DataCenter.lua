-- Engines
local _, ns = ...
local oUF = ns.oUF or oUF
local S, C, L, DB = unpack(select(2, ...))

-- Variables
local anchors = {}
local width, height, space = nil, nil, nil

-- Common
local function OnLeave(self, event, ...)
    GameTooltip:Hide()
end

-- Clock
local function UpdateClock(self, ...)
    anchors.clock:SetText(GameTime_GetLocalTime(true))
end

local function CreateClock(self, ...)
    local clock = S.CreateButton(Minimap, 12)
    clock:SetSize(48, 16)
    clock:SetPoint("TOP", Minimap, 0, -4)
    clock:SetFrameLevel(Minimap:GetFrameLevel() + 255)

    local function OnEnter(self, ...)
        local doubleLineColor = {0.75, 0.90, 1.00, 1.00, 1.00, 1.00}

        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        GameTooltip:AddLine(date "%A, %B %d", 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true), unpack(doubleLineColor))
        GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true), unpack(doubleLineColor))

        GameTooltip:Show()
    end

    local function OnLeave(self, ...)
        GameTooltip:Hide()
    end

    local function OnClick(self, btn, ...)
        GameTimeFrame:Click()
    end

    clock:HookScript("OnLeave", OnLeave)
    clock:HookScript("OnEnter", OnEnter)
    clock:HookScript("OnClick", OnClick)

    anchors.clock = clock
end

-- FPS、Ping、Addon
local addons = {}

local function UpdateFPS(self, ...)
    local value = GetFramerate()

    local fps = anchors.First.fps
    fps:SetValue(value)
    fps.text:SetText(("%dFPS"):format(value))
end

local function CreateFPS(self, ...)
    local anchor = anchors.First

    local fps = CreateFrame("StatusBar", nil, anchor)
    fps:SetSize((width - 4 * 2) / 3, height)
    fps:SetPoint("BOTTOMLEFT")
    fps:SetMinMaxValues(0, 144)
    fps:SetStatusBarTexture(DB.Statusbar)
    fps:SetStatusBarColor(0.00, 0.40, 1.00)

    fps.text = S.MakeText(fps, 10)
    fps.text:SetText("N/A")
    fps.text:SetPoint("CENTER", 0, 5)

    fps.shadow = S.MakeShadow(fps, 2)
    fps.shadow:SetFrameLevel(fps:GetFrameLevel())

    fps.bg = fps:CreateTexture(nil, "BACKGROUND")
    fps.bg:SetTexture(DB.Statusbar)
    fps.bg:SetAllPoints()
    fps.bg:SetVertexColor(0.12, 0.12, 0.12)

    local function OnEnter(self, ...)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        local value = GetFramerate()
        GameTooltip:AddLine("帧数：", 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("帧数：", ("%.2fFPS"):format(value), 1.00, 1.00, 1.00, 1.00, 1.00, 1.00)

        GameTooltip:Show()
    end

    fps:SetScript("OnLeave", OnLeave)
    fps:SetScript("OnEnter", OnEnter)

    anchor.fps = fps
end

local function UpdatePing(self, ...)
    local ping = anchors.First.ping
    local _, _, latencyHome, latencyWorld = GetNetStats()
    local value = (latencyHome > latencyWorld) and latencyHome or latencyWorld

    ping:SetValue(value)
    ping.text:SetText(value .. "ms")

    local minValue, maxValue = ping:GetMinMaxValues()

    if value > maxValue * 0.50 then
        ping:SetStatusBarColor(1.00, 0.00, 0.00)
    elseif value > maxValue * 0.25 then
        ping:SetStatusBarColor(1.00, 1.00, 0.00)
    else
        ping:SetStatusBarColor(0.00, 0.40, 1.00)
    end
end

local function UpdateAddon(self, ...)
    UpdateAddOnMemoryUsage()

    for i = 1, GetNumAddOns() do
        local addon = {}

        addon.isLoaded = IsAddOnLoaded(i)
        addon.addonName = select(2, GetAddOnInfo(i))
        addon.addonMemory = GetAddOnMemoryUsage(i)

        addons[i] = addon
    end

    local function OnSort(l, r)
        local result = false

        if l and r then
            result = l.addonMemory > r.addonMemory
        elseif l and not r then
            result = true
        elseif not l and r or (not l and not r) then
            result = false
        end

        return false
    end
    table.sort(addons, OnSort)

    local currMemory = 0
    for key, value in pairs(addons) do
        currMemory = currMemory + value.addonMemory
    end

    local addon = anchors.First.addon
    addon:SetValue(currMemory)
    addon.text:SetText(S.FormatMemory(currMemory))

    if currMemory > 96 * 1024 then
        addon:SetStatusBarColor(1.00, 0.00, 0.00)
    elseif currMemory > 64 * 1024 then
        addon:SetStatusBarColor(1.00, 1.00, 0.00)
    else
        addon:SetStatusBarColor(0.00, 0.40, 1.00)
    end
end

local function CreatePing(self, ...)
    local anchor = anchors.First

    local ping = CreateFrame("StatusBar", nil, anchor)
    ping:SetPoint("BOTTOM")
    ping:SetMinMaxValues(0, 200)
    ping:SetStatusBarTexture(DB.Statusbar)
    ping:SetStatusBarColor(0.00, 0.40, 1.00)
    ping:SetSize((width - 4 * 2) / 3, height)

    ping.text = S.MakeText(ping, 10)
    ping.text:SetText("0ms")
    ping.text:SetPoint("CENTER", 0, 5)

    ping.shadow = S.MakeShadow(ping, 2)
    ping.shadow:SetFrameLevel(anchor:GetFrameLevel())

    ping.bg = ping:CreateTexture(nil, "BACKGROUND")
    ping.bg:SetTexture(DB.Statusbar)
    ping.bg:SetAllPoints()
    ping.bg:SetVertexColor(0.12, 0.12, 0.12)

    local function OnEnter(self, ...)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        local _, _, latencyHome, latencyWorld = GetNetStats()
        GameTooltip:AddLine("延迟：", 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("本地延迟：", latencyHome .. "ms", 1.00, 1.00, 1.00, 1.00, 1.00, 1.00)
        GameTooltip:AddDoubleLine("世界延迟：", latencyWorld .. "ms", 1.00, 1.00, 1.00, 1.00, 1.00, 1.00)

        GameTooltip:Show()
    end

    ping:SetScript("OnLeave", OnLeave)
    ping:SetScript("OnEnter", OnEnter)

    anchor.ping = ping
end

local function CreateAddon(self, ...)
    local anchor = anchors.First

    local addon = CreateFrame("StatusBar", nil, anchor)
    addon:SetPoint("BOTTOMRIGHT")
    addon:SetMinMaxValues(0, 128 * 1024)
    addon:SetStatusBarTexture(DB.Statusbar)
    addon:SetStatusBarColor(0.00, 0.40, 1.00)
    addon:SetSize((width - 4 * 2) / 3, height)

    addon.text = S.MakeText(addon, 10)
    addon.text:SetText("N/A")
    addon.text:SetPoint("CENTER", 0, 5)

    addon.shadow = S.MakeShadow(addon, 2)
    addon.shadow:SetFrameLevel(anchor:GetFrameLevel())

    addon.bg = addon:CreateTexture(nil, "BACKGROUND")
    addon.bg:SetTexture(DB.Statusbar)
    addon.bg:SetAllPoints()
    addon.bg:SetVertexColor(0.12, 0.12, 0.12)

    local function OnEnter(self, ...)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        local currMemory = 0
        for key, value in pairs(addons) do
            currMemory = currMemory + value.addonMemory
        end

        GameTooltip:AddDoubleLine("总共内存使用：", S.FormatMemory(currMemory), 0.40, 0.78, 1.00, 0.84, 0.75, 0.65)
        GameTooltip:AddLine(" ")

        for key, value in pairs(addons) do
            if value.isLoaded then
                currMemory = currMemory + value.addonMemory

                GameTooltip:AddDoubleLine(
                    value.addonName,
                    S.FormatMemory(value.addonMemory),
                    1.00,
                    1.00,
                    1.00,
                    0.00,
                    1.00,
                    0.00
                )
            end
        end

        GameTooltip:Show()
    end

    local function OnMouseDown(self, btn, ...)
        local before = gcinfo()

        collectgarbage()
        print("|cff70C0F5[Sora's]|r |cffffff00您回收了内存：|r" .. S.FormatMemory(before - gcinfo()))

        C_Timer.NewTicker(1.00, UpdateAddon, 1)
    end

    addon:SetScript("OnLeave", OnLeave)
    addon:SetScript("OnEnter", OnEnter)
    addon:SetScript("OnMouseDown", OnMouseDown)

    anchor.addon = addon
end

local function CreateFirstLine(self, ...)
    anchors.First = CreateFrame("Frame", nil, self)
    anchors.First:SetSize(width, height * 2 + space)

    CreatePing(self, ...)
    CreateClock(self, ...)
    CreateAddon(self, ...)
end

-- Gold、Item
local solts = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17}

local function UpdateGold(self, ...)
    local money = floor(GetMoney() / 100 / 100)

    local gold = anchors.Second.gold
    gold:SetValue(money)
    gold.text:SetText(("%s|cffffd700G|r"):format(S.FormatInteger(money)))
end

local function UpdateItem(self, ...)
    local item = anchors.Second.item
    local maxDurability, currDurability = 0, 0

    for key, value in pairs(solts) do
        if GetInventoryItemLink("player", value) ~= nil then
            local curr, max = GetInventoryItemDurability(value)

            if curr and max then
                maxDurability = maxDurability + max
                currDurability = currDurability + curr
            end
        end
    end

    local value = maxDurability > 0 and currDurability / maxDurability * 100 or 100

    if value < 10 then
        item:SetStatusBarColor(1.00, 0.00, 0.00)
    elseif value < 30 then
        item:SetStatusBarColor(1.00, 1.00, 0.00)
    else
        item:SetStatusBarColor(0.00, 0.40, 1.00)
    end

    item:SetValue(value)
    item.text:SetText(("%d%%"):format(value))
end

local function CreateGold(self, ...)
    local anchor = anchors.Second

    local gold = CreateFrame("StatusBar", nil, anchor)
    gold:SetSize((width - 4) / 2, height)
    gold:SetPoint("BOTTOMLEFT")
    gold:SetMinMaxValues(0, 999999)
    gold:SetStatusBarTexture(DB.Statusbar)
    gold:SetStatusBarColor(0.00, 0.40, 1.00)

    gold.text = S.MakeText(gold, 10)
    gold.text:SetText("N/A")
    gold.text:SetPoint("CENTER", 0, 5)

    gold.shadow = S.MakeShadow(gold, 2)
    gold.shadow:SetFrameLevel(gold:GetFrameLevel())

    gold.bg = gold:CreateTexture(nil, "BACKGROUND")
    gold.bg:SetTexture(DB.Statusbar)
    gold.bg:SetAllPoints()
    gold.bg:SetVertexColor(0.12, 0.12, 0.12)

    local function OnGoldBarEnter(self, ...)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        local money = GetMoney()
        local gold = floor(money / 100 / 100)
        local sliver = floor((money - gold * 100 * 100) / 100)
        local copper = floor((money - gold * 100 * 100 - sliver * 100))

        GameTooltip:AddLine("货币：", 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(
            "金币：",
            ("%d|cffffd700G|r %d|cffc7c7cfS|r %d|cffb87333C|r"):format(gold, sliver, copper),
            1.00,
            1.00,
            1.00,
            1.00,
            1.00,
            1.00
        )
        GameTooltip:Show()
    end

    gold:SetScript("OnLeave", OnLeave)
    gold:SetScript("OnEnter", OnGoldBarEnter)

    anchor.gold = gold
end

local function CreateItem(self, ...)
    local anchor = anchors.Second

    local item = CreateFrame("StatusBar", nil, anchor)
    item:SetSize((width - 4) / 2, height)
    item:SetPoint("BOTTOMRIGHT")
    item:SetMinMaxValues(0, 100)
    item:SetStatusBarTexture(DB.Statusbar)
    item:SetStatusBarColor(0.00, 0.40, 1.00)

    item.text = S.MakeText(item, 10)
    item.text:SetText("N/A")
    item.text:SetPoint("CENTER", 0, 5)

    item.shadow = S.MakeShadow(item, 2)
    item.shadow:SetFrameLevel(item:GetFrameLevel())

    item.bg = item:CreateTexture(nil, "BACKGROUND")
    item.bg:SetTexture(DB.Statusbar)
    item.bg:SetAllPoints()
    item.bg:SetVertexColor(0.12, 0.12, 0.12)

    local function OnItemBarEnter(self, ...)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        local maxDurability, currDurability = 0, 0

        for key, value in pairs(solts) do
            if GetInventoryItemLink("player", value) ~= nil then
                local curr, max = GetInventoryItemDurability(value)

                if curr and max then
                    maxDurability = maxDurability + max
                    currDurability = currDurability + curr
                end
            end
        end

        local value = currDurability / maxDurability * 100

        GameTooltip:AddLine("装备：", 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("耐久：", string.format("%.2f%%", value), 1.00, 1.00, 1.00, 1.00, 1.00, 1.00)
        GameTooltip:Show()
    end

    item:SetScript("OnLeave", OnLeave)
    item:SetScript("OnEnter", OnItemBarEnter)

    anchor.item = item
end

local function CreateSecondLine(self, ...)
    anchors.Second = CreateFrame("Frame", nil, self)
    anchors.Second:SetSize(width, height * 2 + space)

    CreateFPS(self, ...)
    CreateGold(self, ...)
    CreateItem(self, ...)
end

-- Experience
local function CreateExperienceLine(self, ...)
    local anchor = CreateFrame("Frame", nil, self)
    anchor:SetSize(width, height * 2 + space)

    local experience = CreateFrame("StatusBar", nil, anchor)
    experience:EnableMouse(true)
    experience:SetPoint("BOTTOM")
    experience:SetSize(width, height)
    experience:SetStatusBarTexture(DB.Statusbar)

    local function OnExperienceUpdateTooltip(self, event, ...)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        GameTooltip:AddLine(self.onEnterInfoLine:GetText(), 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("经验：", self.onEnterValueLine:GetText(), 1.00, 1.00, 1.00)
        GameTooltip:AddDoubleLine("休息：", self.onEnterRestedLine:GetText(), 1.00, 1.00, 1.00)

        GameTooltip:Show()
    end

    experience.shadow = S.MakeShadow(experience, 2)
    experience.shadow:SetFrameLevel(experience:GetFrameLevel())

    experience.rested = CreateFrame("StatusBar", nil, experience)
    experience.rested:SetAllPoints(experience)
    experience.rested:SetStatusBarTexture(DB.Statusbar)

    experience.text = S.MakeText(experience, 10)
    experience.text:SetText("N/A")
    experience.text:SetPoint("CENTER", 0, 5)
    self:Tag(experience.text, "[experience:per]%")

    experience.bg = experience.rested:CreateTexture(nil, "BACKGROUND")
    experience.bg:SetTexture(DB.Statusbar)
    experience.bg:SetAllPoints()
    experience.bg:SetVertexColor(0.12, 0.12, 0.12)

    experience.onEnterInfoLine = S.MakeText(experience, 10)
    experience.onEnterInfoLine:ClearAllPoints()
    self:Tag(experience.onEnterInfoLine, "[class] - Lv.[level]")

    experience.onEnterValueLine = S.MakeText(experience, 10)
    experience.onEnterValueLine:ClearAllPoints()
    self:Tag(experience.onEnterValueLine, "[experience:cur]/[experience:max] - [experience:per]%")

    experience.onEnterRestedLine = S.MakeText(experience, 10)
    experience.onEnterRestedLine:ClearAllPoints()
    self:Tag(experience.onEnterRestedLine, "[experience:currested] - [experience:perrested]%")

    self.Experience = experience
    self.Experience.Rested = experience.rested
    self.Experience.OverrideUpdateTooltip = OnExperienceUpdateTooltip

    anchors.Experience = anchor
end

-- Reputation
local function CreateReputationLine(self, ...)
    local anchor = CreateFrame("Frame", nil, self)
    anchor:SetSize(width, height * 2 + space)

    local reputation = CreateFrame("StatusBar", nil, anchor)
    reputation:EnableMouse(true)
    reputation:SetPoint("BOTTOM")
    reputation:SetSize(width, height)
    reputation:SetStatusBarTexture(DB.Statusbar)

    local function OnReputationUpdateTooltip(self, event, ...)
        local name, standingID, min, max, cur, factionID = GetWatchedFactionInfo()
        local _, desc = GetFactionInfoByID(factionID)

        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:ClearLines()

        GameTooltip:AddLine(self.onEnterInfoLine:GetText(), 0.40, 0.78, 1.00)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(desc, 1.00, 1.00, 1.00, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("声望：", self.onEnterValueLine:GetText(), 1.00, 1.00, 1.00)

        GameTooltip:Show()
    end

    reputation.shadow = S.MakeShadow(reputation, 2)
    reputation.shadow:SetFrameLevel(reputation:GetFrameLevel())

    reputation.colorStanding = true
    reputation.UpdateTooltip = OnReputationUpdateTooltip

    reputation.text = S.MakeText(reputation, 10)
    reputation.text:SetText("N/A")
    reputation.text:SetPoint("CENTER", 0, 5)
    self:Tag(reputation.text, "[reputation:per]%")

    reputation.bg = reputation:CreateTexture(nil, "BACKGROUND")
    reputation.bg:SetTexture(DB.Statusbar)
    reputation.bg:SetAllPoints()
    reputation.bg:SetVertexColor(0.12, 0.12, 0.12)

    reputation.onEnterInfoLine = S.MakeText(reputation, 10)
    reputation.onEnterInfoLine:ClearAllPoints()
    self:Tag(reputation.onEnterInfoLine, "[reputation:faction] - [reputation:standing]")

    reputation.onEnterValueLine = S.MakeText(reputation, 10)
    reputation.onEnterValueLine:ClearAllPoints()
    self:Tag(reputation.onEnterValueLine, "[reputation:cur]/[reputation:max] - [reputation:per]%")

    self.Reputation = reputation
    self.Reputation.colorStanding = true
    self.Reputation.UpdateTooltip = OnReputationUpdateTooltip

    anchors.Reputation = anchor
end

-- Artifact Power、Azerite Item
local function CreateArtifactPowerLine(self, ...)
    local anchor = CreateFrame("Frame", nil, self)
    anchor:SetSize(width, height * 2 + space)

    local artifactPower = CreateFrame("StatusBar", nil, anchor)
    artifactPower:EnableMouse(true)
    artifactPower:SetPoint("BOTTOM")
    artifactPower:SetSize(width, height)
    artifactPower:SetStatusBarTexture(DB.Statusbar)

    artifactPower.text = S.MakeText(artifactPower, 10)
    artifactPower.text:SetText("N/A")
    artifactPower.text:SetPoint("CENTER", 0, 5)

    artifactPower.shadow = S.MakeShadow(artifactPower, 2)
    artifactPower.shadow:SetFrameLevel(artifactPower:GetFrameLevel())

    artifactPower.bg = artifactPower:CreateTexture(nil, "BACKGROUND")
    artifactPower.bg:SetTexture(DB.Statusbar)
    artifactPower.bg:SetAllPoints()
    artifactPower.bg:SetVertexColor(0.12, 0.12, 0.12)

    local function PostUpdate(self, event, isShown)
        if isShown then
            self.text:SetText(("%d%%"):format(self.current / self.max * 100))
        end
    end

    self.ArtifactPower = artifactPower
    self.ArtifactPower.PostUpdate = PostUpdate

    anchors.ArtifactPower = anchor
end

-- Begin
local function UpdateAnchors(self, ...)
    local lines = {}

    table.insert(lines, anchors.First)
    table.insert(lines, anchors.Second)

    if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
        table.insert(lines, anchors.Experience)
    end

    if select(1, GetWatchedFactionInfo()) then
        table.insert(lines, anchors.Reputation)
    end

    if HasArtifactEquipped() or (C_AzeriteItem and C_AzeriteItem.FindActiveAzeriteItem()) then
        table.insert(lines, anchors.ArtifactPower)
    end

    for k, v in pairs(lines) do
        if k == 1 then
            v:SetPoint("TOP")
        else
            v:SetPoint("TOP", lines[k - 1], "BOTTOM", 0, 0)
        end
    end
end

local function RegisterStyle(self, ...)
    self:SetSize(width, height)
    self:SetPoint("TOP", Minimap, "BOTTOM", 0, 0)

    CreateFirstLine(self, ...)
    CreateSecondLine(self, ...)
    CreateExperienceLine(self, ...)
    CreateReputationLine(self, ...)
    CreateArtifactPowerLine(self, ...)
end

-- Event

local function OnPlayerLogin(self, event, ...)
    width, height, space = Minimap:GetWidth(), 6, 6

    oUF:RegisterStyle("oUF_Sora_InfoBar", RegisterStyle)
    oUF:SetActiveStyle("oUF_Sora_InfoBar")
    oUF:Spawn("player", "oUF_Sora_InfoBar")

    local function OnTicker(ticker)
        UpdateAnchors()

        if not anchors.First then
            return 0
        end

        UpdateFPS(self)
        UpdateGold(self)
        UpdateItem(self)
        UpdatePing(self)
        UpdateClock(self)
        UpdateAddon(self)
    end

    C_Timer.NewTicker(3.00, OnTicker)
end

-- Handler
local EventHandler = S.CreateEventHandler()
EventHandler.Event.PLAYER_LOGIN = OnPlayerLogin
EventHandler.Register()