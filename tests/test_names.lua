function GetRealmName() return "Forever Realm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Local Player","ForeverRealm" end end
function UnitGUID(unit) if unit == "player" then return "Player-Self-123" end end
function GetPlayerInfoByGUID(guid)
    if guid == "Player-Self-123" then
        return "Priest", "PRIEST", "Dwarf", "Dwarf", 3, "Jasmine Amberbrew", "CAMWOWEU4Realm10RP"
    end
end

SocialForever=nil
dofile("Core.lua")
local Util=SocialForever.Util

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertFalse(v,m) if v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

assertEqual(Util.MakeKey("Alice",nil),"Alice","one-word name")
assertEqual(Util.MakeKey("Alice","Amberbrew"),"Alice-Amberbrew","UnitName second value must be surname")
assertEqual(Util.MakeKey("Alice","Other Realm"),"Alice","server names must not be appended as surnames")
assertEqual(Util.MakeKey("Lyswin Lightanvil","CAMWOWEU4Realm10RP"),"Lyswin-Lightanvil","internal Forever realm token was exposed in player name")
assertEqual(Util.MakeKey("First Second","ForeverRealm"),"First-Second","Forever two-word name")
assertEqual(Util.SafeKey("First Second"),"First-Second","SafeKey space normalization")
assertTrue(Util.IsCompleteCharacterKey("First Second"),"complete two-part name rejected")
assertFalse(Util.IsCompleteCharacterKey("First"),"partial name was accepted")
assertFalse(Util.IsCompleteCharacterKey("First-Second-Server"),"three-part name was accepted")
assertTrue(Util.SameKey("First Second","First-Second"),"spaces/hyphens not normalized equivalently")
assertTrue(Util.SameKey("Anne-Marie","Anne Marie"),"hyphen/space comparison failed")
assertTrue(Util.IsMe("Local Player"),"self name with space not excluded")
assertTrue(Util.IsMe("Local-Player"),"self name with hyphen not excluded")
assertFalse(Util.IsMe("Another-Player"),"other player mistaken for self")
assertTrue(Util.IsMyGuid("Player-Self-123"),"self GUID was not recognized")
assertTrue(Util.IsMe("Jasmine Amberbrew"),"self two-word GUID name was not recognized")
assertTrue(Util.IsMe("Jasmine-Amberbrew"),"self normalized two-word GUID name was not recognized")
assertTrue(Util.IsMe("Jasmine-Amberbrew","Player-Self-123"),"self identity by GUID was not excluded")
assertFalse(Util.IsMe("Other Amberbrew"),"similarly named stranger mistaken for self")

assertEqual(Util.SafeKey("A"),nil,"one-character invalid name accepted")
assertEqual(Util.SafeKey("Bad|Name"),nil,"unsafe name accepted")

print("PASS: player-name normalization tests")