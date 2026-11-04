function GetRealmName() return "Forever Realm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Local Player","ForeverRealm" end end

SocialForever=nil
dofile("Core.lua")
local Util=SocialForever.Util

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertFalse(v,m) if v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

assertEqual(Util.MakeKey("Alice",nil),"Alice","one-word name")
assertEqual(Util.MakeKey("Alice","ForeverRealm"),"Alice","local realm should not be appended")
assertEqual(Util.MakeKey("Alice","Other Realm"),"Alice-OtherRealm","other realm normalization")
assertEqual(Util.MakeKey("First Second","ForeverRealm"),"First-Second","Forever two-word name")
assertEqual(Util.SafeKey("First Second"),"First-Second","SafeKey space normalization")
assertTrue(Util.SameKey("First Second","First-Second"),"spaces/hyphens not normalized equivalently")
assertTrue(Util.SameKey("Anne-Marie","Anne Marie"),"hyphen/space comparison failed")
assertTrue(Util.IsMe("Local Player"),"self name with space not excluded")
assertTrue(Util.IsMe("Local-Player"),"self name with hyphen not excluded")
assertFalse(Util.IsMe("Another-Player"),"other player mistaken for self")
assertEqual(Util.SafeKey("A"),nil,"one-character invalid name accepted")
assertEqual(Util.SafeKey("Bad|Name"),nil,"unsafe name accepted")

print("PASS: player-name normalization tests")