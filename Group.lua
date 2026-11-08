-- Social Forever
-- Nearby players for questing groups, and a memory of who you liked grouping with.
-- Built for World of Warcraft: Forever 1.60.1 (Interface 16001).

SocialForever = SocialForever or {}
local SF = SocialForever

local C = SF.Const
local S = SF.State
local Util = SF.Util
local Memory = SF.Memory
local Group = SF.Group
local Detection = SF.Detection
local Sharing = SF.Sharing
local UI = SF.UI

-- A party unit is a confirmed member only when the client says it is in the
-- party. Pending/declined invitations are not roster membership.
function Group.IsPartyRosterUnit(unit)
    if type(UnitInParty) ~= "function" then
        return false
    end
    local ok, member = pcall(UnitInParty, unit)
    return ok and Util.PlainBool(member) == true
end

-- This is the actual party roster, not just its connected members. Forever
-- keeps party unit tokens for disconnected players, so UnitIsConnected must
-- not decide whether somebody belongs in the group-review snapshot.
function Group.PartyRosterKeys()
    local list = {}
    for i = 1, 4 do
        local unit = "party" .. i
        local ok, exists = pcall(UnitExists, unit)
        if ok and Util.PlainBool(exists) == true and Group.IsPartyRosterUnit(unit) then
            local key = Util.UnitIdentity(unit)
            if key and not Util.IsMe(key) then
                list[#list + 1] = key
            end
        end
    end
    return list
end

function Group.RebuildGroupMembers()
    wipe(S.P.groupByKey)
    wipe(S.P.groupByNorm)
    wipe(S.P.groupRosterByKey)
    wipe(S.P.groupRosterByNorm)

    local function addUnit(unit, partyUnit)
        local ok, exists = pcall(UnitExists, unit)
        if not ok or Util.PlainBool(exists) ~= true then
            return
        end
        if partyUnit and not Group.IsPartyRosterUnit(unit) then
            return
        end
        local key = Util.UnitIdentity(unit)
        if not key or Util.IsMe(key) then
            return
        end

        local norm = key:gsub("[%s%-]+", ""):lower()
        -- Roster membership includes offline players. This map is used for
        -- invite blocking and group identity, not Nearby presence.
        S.P.groupRosterByKey[key] = unit
        S.P.groupRosterByNorm[norm] = unit

        -- The online map remains deliberately narrower for Nearby detection.
        if Detection.UnitConnectedPlain(unit) ~= false then
            S.P.groupByKey[key] = unit
            S.P.groupByNorm[norm] = unit
        end
    end

    local raidOk, inRaid = pcall(IsInRaid)
    if raidOk and Util.PlainBool(inRaid) == true then
        for i = 1, 40 do
            addUnit("raid" .. i, false)
        end
        return
    end
    local groupOk, inGroup = pcall(IsInGroup)
    if groupOk and Util.PlainBool(inGroup) == true then
        for i = 1, 4 do
            addUnit("party" .. i, true)
        end
    end
end

local function HasGroupKey(key, byKey, byNorm)
    if not key then return false end
    if byKey[key] then return true end
    local norm = key:gsub("[%s%-]+", ""):lower()
    return byNorm[norm] ~= nil
end

-- Membership includes disconnected players who remain on the actual roster.
Group.InMyGroup = function(key)
    return HasGroupKey(key, S.P.groupRosterByKey, S.P.groupRosterByNorm)
end

-- Online presence is separate: detection must not keep disconnected players
-- in Nearby merely because their group slot remains.
function Group.InMyGroupOnline(key)
    return HasGroupKey(key, S.P.groupByKey, S.P.groupByNorm)
end

function Group.RefreshFriends()
    wipe(S.friendNames)
    if not (C_FriendList and C_FriendList.GetNumFriends and C_FriendList.GetFriendInfoByIndex) then
        return
    end
    local ok, count = pcall(C_FriendList.GetNumFriends)
    count = ok and Util.PlainNumber(count) or nil
    if not count or count < 1 then
        return
    end
    if count > 200 then
        count = 200
    end
    for i = 1, count do
        local infoOk, info = pcall(C_FriendList.GetFriendInfoByIndex, i)
        if infoOk then
            local name = type(info) == "table" and Util.PlainString(info.name) or Util.PlainString(info)
            if name then
                S.friendNames[name] = true
                local short = name:match("^([^%-]+)")
                if short and short ~= name then
                    S.friendNames[short] = true
                end
            end
        end
    end
end

function Group.NoteGroupButtons(members)
    local nowIn = {}
    for _, key in ipairs(members) do
        nowIn[key] = true
        S.inviteState[key] = nil
    end
    for key in pairs(S.groupedBefore) do
        if not nowIn[key] and S.inviteState[key] ~= "declined" then
            S.inviteState[key] = nil
        end
    end
    wipe(S.groupedBefore)
    for key in pairs(nowIn) do
        S.groupedBefore[key] = true
    end
end

function Group.GroupState()
    local okG, grouped = pcall(IsInGroup)
    local okR, raid = pcall(IsInRaid)
    if not okG or not okR then
        return nil
    end
    grouped = Util.PlainBool(grouped)
    raid = Util.PlainBool(raid)
    if grouped == nil or raid == nil then
        return nil
    end
    if raid then
        return "raid"
    end
    if grouped then
        return "party"
    end
    return "solo"
end

function Group.EndPartySession()
    SF.db.partyId = nil
    SF.db.partyCounted = nil
end

function Group.NoteMembers(members)
    if not SF.db.partyId then
        SF.db.nextPartyId = (tonumber(SF.db.nextPartyId) or 0) + 1
        SF.db.partyId = SF.db.nextPartyId
        SF.db.partyCounted = {}
    end
    if type(SF.db.partyCounted) ~= "table" then
        SF.db.partyCounted = {}
    end
    for _, key in ipairs(members) do
        if not SF.db.partyCounted[key] then
            SF.db.partyCounted[key] = true
            local rec = Memory.EnsurePlayer(key)
            rec.groups = (tonumber(rec.groups) or 0) + 1
        end
    end
    S.lastMembers = members
end

function Group.CopyMembers(members)
    local copy = {}
    for i = 1, math.min(4, #members) do
        copy[i] = members[i]
    end
    return copy
end

function Group.PlayTick()
    local kit = SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    if kit then
        pcall(PlaySound, kit)
    end
end

function Group.ShowRatePopup(members)
    if not S.armed or not S.popup then
        return
    end
    local list = {}
    local seen = {}
    for _, key in ipairs(members) do
        key = Util.SafeKey(key)
        if key and not Util.IsMe(key) and not seen[key] then
            seen[key] = true
            list[#list + 1] = key
            if #list == 4 then
                break
            end
        end
    end
    if #list == 0 then
        return
    end
    local sig = table.concat(list, "|")
    local now = GetTime()
    if sig == S.lastPopupSig and now - S.lastPopupAt < 3 then
        return
    end
    S.lastPopupSig = sig
    S.lastPopupAt = now

    S.popup.title:SetText(#list == 1 and "How was this player?" or "How was this group?")
    for i = 1, 4 do
        local row = S.popup.rows[i]
        local key = list[i]
        if key then
            row.key = key
            row.choice = nil
            row.name:SetText(UI.SpokenName(key))
            row.sub:SetText(Memory.HistoryLine(key))
            if UI.PaintChoice then
                UI.PaintChoice(row)
            end
            row:Show()
        else
            row.key = nil
            row:Hide()
        end
    end
    S.popup:SetHeight(46 + #list * 44 + 34)
    S.popup:Show()
    S.popup:Raise()
    C_Timer.After(0, function()
        if S.popup:IsShown() and S.popup.Anchor then
            S.popup:Anchor()
        end
    end)
    Group.PlayTick()
end

function Group.RefreshRoster()
    if not SF.db then
        return
    end
    Group.RebuildGroupMembers()
    Detection.SyncRaidTicker()
    local state = Group.GroupState()
    if state == nil then
        return
    end
    if state == "party" then
        Group.NoteGroupButtons(Group.PartyRosterKeys())
    elseif state == "solo" then
        Group.NoteGroupButtons({})
    end
    if state == "party" then
        local members = Group.PartyRosterKeys()
        if S.wasParty then
            local still = {}
            for _, key in ipairs(members) do
                still[key] = true
            end
            local left = {}
            for _, key in ipairs(S.lastMembers) do
                if not still[key] then
                    left[#left + 1] = key
                end
            end
            if #left > 0 then
                Group.ShowRatePopup(left)
            end
        end
        if #members > 0 then
            Group.NoteMembers(members)
        end
        S.wasParty = true
        Detection.Publish()
        return
    end
    if not S.armed then
        return
    end
    if S.wasParty and state == "solo" then
        local members = Group.CopyMembers(S.lastMembers)
        S.wasParty = false
        S.lastMembers = {}
        Group.EndPartySession()
        Group.ShowRatePopup(members)
    else
        S.wasParty = false
        S.lastMembers = {}
        Group.EndPartySession()
    end
    Detection.Publish()
end

function Group.Arm()
    S.armed = true
    if not S.wasParty then
        local state = Group.GroupState()
        if state == "solo" or state == "raid" or state == nil then
            Group.EndPartySession()
        end
    end
end

function Group.PartyHasRoom()
    local state = Group.GroupState()
    if state == "raid" then
        local ok, n = pcall(GetNumGroupMembers)
        n = ok and Util.PlainNumber(n) or nil
        return n ~= nil and n < 40
    end
    if state == "party" then
        local ok, n = pcall(GetNumGroupMembers)
        n = ok and Util.PlainNumber(n) or nil
        return n ~= nil and n < 5
    end
    return true
end

function Group.SameMobAskOn()
    return SF.db and SF.db.sameMobAsk == true
end

function Group.SetSameMobAsk(on)
    if not SF.db then return end
    SF.db.sameMobAsk = on and true or false
end
