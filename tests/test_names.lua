function GetNormalizedRealmName() return "ForeverRealm" end
function GetRealmName() error("realm name must not be used as character identity") end
function UnitName(unit)
    if unit == "player" then return "Local", "Player" end
    if unit == "party1" then return "Alice", "Brightvale" end
end
function UnitClass(unit) return "Mage", "MAGE" end
function UnitRace(unit) return "Human", "Human" end
function UnitFactionGroup(unit) return "Alliance" end
function GetTime() return 100 end
function GetPlayerInfoByGUID(guid)
    if guid == "Player-Full" then return "Mage", "MAGE", "Human", "Human", 2, "Alice Brightvale", "ForeverRealm", 60 end
    if guid == "Player-Partial" then return "Mage", "MAGE", "Human", "Human", 2, "Alice", "ForeverRealm", 60 end
end

SocialForever=nil
dofile("Core.lua")
dofile("Detection.lua")
dofile("UI.lua")
dofile("Sharing.lua")
local SF=SocialForever
local Util=SF.Util
local Detection=SF.Detection
local UI=SF.UI
local Sharing=SF.Sharing
local S=SF.State

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertFalse(v,m) if v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

assertEqual(Util.MakeKey("Alice", "Brightvale"), "Alice-Brightvale", "first name + surname")
assertEqual(Util.MakeKey("Alice Brightvale"), "Alice-Brightvale", "combined full name")
assertEqual(Util.MakeKey("Alice-Brightvale"), "Alice-Brightvale", "normalized full name")
assertEqual(Util.MakeKey("Alice", "ForeverRealm"), "Alice-ForeverRealm", "surname must not be compared with internal realm token")
assertEqual(Util.MyKey(), "Local-Player", "player identity must include surname")
assertEqual(Util.UnitIdentity("party1"), "Alice-Brightvale", "unit identity must include surname")
assertEqual(Util.SafeKey("First Second"), "First-Second", "SafeKey space normalization")
assertTrue(Util.SameKey("First Second", "First-Second"), "spaces/hyphens not normalized equivalently")
assertTrue(Util.SameKey("Anne-Marie", "Anne Marie"), "hyphen/space comparison failed")
assertTrue(Util.IsMe("Local Player"), "self name with space not excluded")
assertTrue(Util.IsMe("Local-Player"), "self name with hyphen not excluded")
assertFalse(Util.IsMe("Another-Player"), "other player mistaken for self")
assertEqual(Util.SafeKey("A"), nil, "one-character invalid name accepted")
assertEqual(Util.SafeKey("Bad|Name"), nil, "unsafe name accepted")

assertEqual(UI.SpokenName("Alice-Brightvale"), "Alice Brightvale", "list display must show both names")
assertEqual(UI.SlashName("Alice-Brightvale"), "Alice Brightvale", "invite name must show both names")

assertEqual(Util.SenderKey("Alice-Brightvale"), "Alice-Brightvale", "plain two-part sender")
assertEqual(Util.SenderKey("Alice Brightvale"), "Alice-Brightvale", "spaced two-part sender")
assertEqual(Util.SenderKey("Alice-Brightvale-ForeverRealm"), "Alice-Brightvale", "transport suffix must not become a surname")
assertEqual(Util.SenderKey("Alice Brightvale-ForeverRealm"), "Alice-Brightvale", "spaced name with transport suffix")
assertEqual(Util.SenderKey("Alice-ForeverRealm"), "Alice-ForeverRealm", "legitimate surname matching suffix token must be preserved")
assertEqual(Detection.KeyFromSender("Alice Brightvale"), "Alice-Brightvale", "chat sender full name")
assertEqual(Detection.KeyFromGuid("Player-Full"), "Alice-Brightvale", "GUID full name must ignore realm-shaped return")
assertEqual(Detection.KeyFromGuid("Player-Partial"), nil, "GUID lookup must not turn realm-shaped value into surname")

S.peers = {}
Sharing.Enqueue = function() end
Sharing.PushRelevant = function() end
Sharing.OnAddon(SF.Const.PREFIX, "H1", "WHISPER", "Alice-Brightvale-ForeverRealm")
assertTrue(S.peers["Alice-Brightvale"] ~= nil, "addon sender transport suffix leaked into peer identity")

print("PASS: Forever two-part player-name normalization tests")
