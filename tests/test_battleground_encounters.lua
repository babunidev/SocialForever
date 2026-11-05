-- Mock regression: each battleground match counts once per nearby player.
function wipe(t) for k in pairs(t) do t[k] = nil end end
function strsplit(sep, text, limit)
    if type(text) ~= "string" then return nil end
    local out, start = {}, 1
    while not limit or #out < limit - 1 do
        local i, j = string.find(text, sep, start, true)
        if not i then break end
        out[#out + 1] = string.sub(text, start, i - 1)
        start = j + 1
    end
    out[#out + 1] = string.sub(text, start)
    return table.unpack(out)
end

local now = 1000
local bg = "Warsong Gulch"
local zone, sub = "Warsong Gulch", "Horde Graveyard"
function GetTime() return now end
function GetServerTime() return 51000 + now end
function GetZoneText() return zone end
function GetSubZoneText() return sub end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit == "player" then return "Localplayer", "ForeverRealm" end end
function GetInstanceInfo()
    if bg then return bg, "pvp", 0, "", 20, 0, false, 489 end
    return "Eastern Kingdoms", "none", 0, "", 0, 0, false, 0
end

SocialForever = nil
SocialForeverDB = {players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua")
dofile("Memory.lua")
local SF = SocialForever
SF.Util.InitDB()
local M = SF.Memory
local function eq(actual, expected, description)
    if actual ~= expected then
        error(description .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end

eq(M.NoteNearbyPlace("Ally", true), "Warsong Gulch", "match location")
eq(M.Familiarity("Ally"), 1, "first encounter")
eq(M.Familiarity("Enemy"), 0, "unseen player")
M.NoteNearbyPlace("Enemy", true)
eq(M.Familiarity("Enemy"), 1, "enemy's first encounter")
sub = "Alliance Graveyard"
now = now + 30
eq(M.CurrentArea(), "Warsong Gulch", "subzone must not become meeting area")
M.NoteNearbyPlace("Ally", true)
M.NoteNearbyPlace("Enemy", true)
eq(M.Familiarity("Ally"), 1, "death / graveyard switch recount")
eq(M.Familiarity("Enemy"), 1, "repeated enemy recount")

-- /reload reconstructs addon modules but retains SavedVariables.
SocialForever = nil
dofile("Core.lua")
dofile("Memory.lua")
SF = SocialForever
SF.Util.InitDB()
M = SF.Memory
now = now + 30
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 1, "reload recounted existing match")

-- A brief loading gap cannot end the active match.
bg = nil
now = now + 1
M.SyncBattlegroundSession()
bg = "Warsong Gulch"
now = now + 1
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 1, "temporary instance status loss recounted match")

-- Leaving long enough closes the match, even with no Nearby sightings.
bg = nil
zone, sub = "Elwynn Forest", "Goldshire"
now = now + 1
M.SyncBattlegroundSession()
now = now + 4
M.SyncBattlegroundSession()
bg = "Warsong Gulch"
zone, sub = "Warsong Gulch", "Horde Graveyard"
now = now + 15
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 2, "second match on same battleground did not count")
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 2, "second match counted twice")

-- Outside battlegrounds the existing different-place rule is unchanged.
bg = nil
zone, sub = "Elwynn Forest", "Northshire Valley"
now = now + 10
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 3, "normal-world different-place encounter")
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 3, "normal-world same-place re-entry recount")
sub = "Goldshire"
M.NoteNearbyPlace("Ally", true)
eq(M.Familiarity("Ally"), 4, "normal-world different-subzone encounter")
print("PASS: one Nearby familiarity count per battleground match")
