function wipe(t) for k in pairs(t) do t[k] = nil end end

local units = {}
local inParty = true
local now = 1000

function GetTime() return now end
function GetServerTime() return now end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function IsInGroup() return inParty end
function IsInRaid() return false end
function UnitExists(unit)
    if unit == "player" then return true end
    return units[unit] ~= nil
end
function UnitInParty(unit)
    local data = units[unit]
    return data ~= nil and data.inParty == true
end
function UnitIsConnected(unit)
    if unit == "player" then return true end
    local data = units[unit]
    return data ~= nil and data.connected == true
end
function UnitName(unit)
    if unit == "player" then return "Localplayer" end
    local data = units[unit]
    if data then return data.name end
end
function UnitClass(unit)
    if unit == "player" then return "Paladin", "PALADIN" end
    if units[unit] then return "Warrior", "WARRIOR" end
end
function UnitRace(unit)
    if unit == "player" then return "Human", "Human" end
    if units[unit] then return "Human", "Human" end
end
function UnitFactionGroup(unit)
    if unit == "player" or units[unit] then return "Alliance" end
end

SocialForever = nil
SocialForeverDB = {players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua")
dofile("Memory.lua")
dofile("Group.lua")
dofile("Detection.lua")

local SF = SocialForever
local S = SF.State
local Group = SF.Group
local Detection = SF.Detection
SF.Util.InitDB()
Detection.SyncRaidTicker = function() end
Detection.Publish = function() end

local popupCalls = {}
Group.ShowRatePopup = function(members)
    local copy = {}
    for i=1,#members do copy[i]=members[i] end
    popupCalls[#popupCalls+1] = copy
end

local function assertTrue(value, message)
    if not value then error(message, 2) end
end
local function assertFalse(value, message)
    if value then error(message, 2) end
end
local function assertEqual(actual, expected, message)
    if actual ~= expected then
        error((message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end
local function contains(list, wanted)
    for i=1,#list do if list[i] == wanted then return true end end
    return false
end

units = {
    party1 = {name="Leader", connected=true, inParty=true},
    party2 = {name="Friend", connected=true, inParty=true},
}
S.armed = true
S.wasParty = false
S.lastMembers = {}
S.inviteState = {}
S.groupedBefore = {}
Group.RefreshRoster()

assertEqual(#S.lastMembers, 2, "initial party snapshot did not contain both confirmed members")
assertTrue(contains(S.lastMembers, "Friend"), "confirmed member missing from initial snapshot")
assertEqual(SF.db.players.Friend.groups, 1, "confirmed member group count was not recorded")
assertEqual(#popupCalls, 0, "initial group formation opened a review")

-- Disconnecting changes online presence, not actual party membership.
units.party2.connected = false
Group.RefreshRoster()
assertEqual(#popupCalls, 0, "disconnect incorrectly opened a group review")
assertTrue(contains(S.lastMembers, "Friend"), "offline member disappeared from party-review snapshot")
assertTrue(Group.InMyGroup("Friend"), "offline member no longer counted as a group member")
assertFalse(Group.InMyGroupOnline("Friend"), "offline member still counted as online")
assertEqual(SF.db.players.Friend.groups, 1, "disconnect counted as a second group")

-- Reconnecting the same roster member is not a new group or a departure.
units.party2.connected = true
Group.RefreshRoster()
assertEqual(#popupCalls, 0, "reconnect incorrectly opened a group review")
assertTrue(Group.InMyGroupOnline("Friend"), "reconnected member was not restored to online group map")
assertEqual(SF.db.players.Friend.groups, 1, "reconnect counted as a new group")

-- A temporary/pending invite token is not accepted as a real party member.
units.party3 = {name="Decliner", connected=true, inParty=false}
Group.RefreshRoster()
assertEqual(#popupCalls, 0, "unconfirmed invite candidate triggered a group review")
assertFalse(contains(S.lastMembers, "Decliner"), "unconfirmed invite candidate entered party snapshot")
assertEqual(SF.db.players.Decliner, nil, "unconfirmed invite candidate received group history")

-- A confirmed member who is disconnected remains in the snapshot until removed.
units.party2.connected = false
Group.RefreshRoster()
assertEqual(#popupCalls, 0, "offline member was rated before actual roster removal")
units.party2 = nil
Group.RefreshRoster()
assertEqual(#popupCalls, 1, "confirmed roster removal did not open a group review")
assertEqual(#popupCalls[1], 1, "departure review contained an unexpected number of players")
assertEqual(popupCalls[1][1], "Friend", "departure review did not identify the removed member")
assertFalse(Group.InMyGroup("Friend"), "removed member remained in group membership map")
assertEqual(SF.db.players.Friend.groups, 1, "leaving the group changed group count")

-- Further roster updates must not repeat the same departure prompt.
Group.RefreshRoster()
assertEqual(#popupCalls, 1, "same departure opened a duplicate group review")

print("PASS: party roster, connection-state, and group-review tests")
