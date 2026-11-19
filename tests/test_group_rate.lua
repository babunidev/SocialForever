function wipe(t) for k in pairs(t) do t[k]=nil end end
function GetTime() return 1000 end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
local connected = {}
function UnitIsConnected(unit)
    if connected[unit] == nil then return true end
    return connected[unit]
end
function UnitClass() return "Warrior","WARRIOR" end
function UnitRace() return "Human","Human" end
function InCombatLockdown() return false end
function IsInRaid() return false end
local inGroup = true
function IsInGroup() return inGroup end
C_Timer = {
    After = function() end,
    NewTicker = function() return { Cancel = function() end } end,
}

local party = {
    party1 = { "Anna", "Belle" },
    party2 = { "Cara", "Dell" },
    party3 = { "Evan", "Frost" },
}

function UnitExists(unit)
    return unit == "player" or party[unit] ~= nil
end
function UnitName(unit)
    if unit == "player" then return "Local Player", "ForeverRealm" end
    local row = party[unit]
    if row then return row[1], row[2] end
end
function UnitIsUnit(a, b) return a == b end

SocialForever = nil
SocialForeverDB = {
    players = { Unknown = { groups = 8, flags = {} } },
    remote = {},
    customFlags = {},
    ignored = {},
    migratedIgnoreFlags = true,
    partyCounted = { Unknown = true },
}
dofile("Core.lua")
dofile("Memory.lua")
dofile("Group.lua")
dofile("Detection.lua")

local SF = SocialForever
local Util = SF.Util
local Group = SF.Group
local Detection = SF.Detection
local S = SF.State
Util.InitDB()

Detection.Publish = function() end
Detection.SyncRaidTicker = function() end
SF.UI.SpokenName = function(key) return (key:gsub("-", " ")) end
SF.UI.PaintChoice = function() end

local shown = 0
local rated = {}
local function resetPopup()
    shown = 0
    rated = {}
end
S.popup = {
    title = { SetText = function() end },
    rows = {},
    SetHeight = function() end,
    Show = function() shown = shown + 1 end,
    Raise = function() end,
    IsShown = function() return false end,
}
for i = 1, 4 do
    S.popup.rows[i] = {
        name = { SetText = function(_, text) rated[#rated + 1] = text end },
        sub = { SetText = function() end },
        Show = function() end,
        Hide = function() end,
    }
end

local function assertTrue(v, m) if not v then error(m, 2) end end
local function assertEqual(a, e, m)
    if a ~= e then error((m or "values differ") .. ": expected " .. tostring(e) .. ", got " .. tostring(a), 2) end
end
local function hasKey(list, key)
    for i = 1, #list do
        if list[i] == key then return true end
    end
    return false
end

assertEqual(SF.db.players.Unknown, nil, "stored Unknown memory was kept")
assertEqual(SF.db.partyCounted.Unknown, nil, "stored Unknown party count was kept")

S.armed = true
S.wasParty = false
S.lastMembers = {}
resetPopup()
Group.RefreshRoster()
assertEqual(shown, 0, "forming the party asked for a rating")
assertEqual(#S.lastMembers, 3, "starting party did not remember three members")
assertTrue(SF.db.players.Unknown == nil, "forming the party created Unknown")

party.party4 = { "Unknown", nil }
resetPopup()
Group.RefreshRoster()
assertEqual(shown, 0, "filling the group through Unknown opened the rating window")
assertEqual(#S.lastMembers, 3, "Unknown replaced the remembered party")
assertTrue(not hasKey(S.lastMembers, "Unknown"), "Unknown was stored as a party member")
assertEqual(SF.db.players.Unknown, nil, "Unknown gained a grouped count")

party.party4 = { "Last", "Joined" }
resetPopup()
Group.RefreshRoster()
assertEqual(shown, 0, "the real name arriving opened the rating window")
assertEqual(#S.lastMembers, 4, "the person who filled the group was not remembered")
assertTrue(hasKey(S.lastMembers, "Last-Joined"), "resolved joiner missing from the party")
local grouped = SF.db.players["Last-Joined"] and SF.db.players["Last-Joined"].groups
assertEqual(grouped, 1, "the person who filled the group was not counted once")

connected.party2 = false
resetPopup()
Group.RefreshRoster()
assertEqual(shown, 0, "a disconnect opened the rating window")
assertTrue(hasKey(S.lastMembers, "Cara-Dell"), "a disconnected member was forgotten while still in the party")

party.party2 = nil
resetPopup()
Group.RefreshRoster()
assertEqual(shown, 1, "a real person leaving did not open the rating window")
assertEqual(rated[1], "Cara Dell", "rating window named the wrong person")
assertTrue(not hasKey(rated, "Unknown"), "rating window included Unknown")

S.armed = false
inGroup = false
resetPopup()
Group.RefreshRoster()
assertEqual(shown, 0, "disarmed transition opened the rating window early")
assertTrue(S.wasParty, "disarmed transition forgot that the player was in a party")
Group.Arm()
assertEqual(shown, 1, "re-arming after leaving the party lost the rating window")
assertTrue(hasKey(rated, "Anna Belle"), "re-armed rating window lost a party member")
assertTrue(hasKey(rated, "Evan Frost"), "re-armed rating window lost another party member")
assertTrue(hasKey(rated, "Last Joined"), "re-armed rating window lost the last party member")

print("PASS: group ratings ignore false leaves and survive a disarmed world transition")
