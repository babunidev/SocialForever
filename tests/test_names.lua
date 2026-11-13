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
assertEqual(Util.MakeKey("Neera","Faded"),"Neera-Faded","second name in the realm slot must be kept")
assertEqual(Util.MakeKey("Alexandra","Moonwhisper"),"Alexandra-Moonwhisper","unit API second name must be kept")
assertEqual(Util.MakeKey("Neera-Faded",nil),"Neera-Faded","chat sender two-word name must be kept")
assertEqual(Util.MakeKey("Neera-Faded-CAMWOWEU4Realm10RP",nil),"Neera-Faded","chat sender realm token stripped, second name kept")
assertEqual(Util.MakeKey("Neera","CAMWOWEU4Realm10RP"),"Neera","internal realm token is never a second name")
assertEqual(Util.MakeKey("First Second","ForeverRealm"),"First-Second","Forever two-word name")
assertEqual(Util.MakeKey("Otto Bywater","CAMWOWEU4Realm10RP"),"Otto-Bywater","GUID/aura internal realm token must not pollute key")
assertEqual(Util.MakeKey("Otto-Bywater-CAMWOWEU4Realm10RP",nil),"Otto-Bywater","polluted key must strip Forever realm token")
assertEqual(Util.NameOnlyKey("Otto-Bywater-CAMWOWEU4Realm10RP"),"Otto-Bywater","NameOnlyKey strips aura realm token")
assertEqual(Util.SafeKey("First Second"),"First-Second","SafeKey space normalization")
assertEqual(Util.SafeKey("Otto Bywater CAMWOWEU4Realm10RP"),"Otto-Bywater","SafeKey strips leaked realm from display-like string")
assertTrue(Util.SameKey("First Second","First-Second"),"spaces/hyphens not normalized equivalently")
assertTrue(Util.SameKey("Otto-Bywater","Otto-Bywater-CAMWOWEU4Realm10RP"),"polluted GUID key must match clean name key")
assertTrue(Util.SameKey("Anne-Marie","Anne Marie"),"hyphen/space comparison failed")
assertTrue(Util.IsMe("Local Player"),"self name with space not excluded")
assertTrue(Util.IsMe("Local-Player"),"self name with hyphen not excluded")
assertFalse(Util.IsMe("Another-Player"),"other player mistaken for self")
assertEqual(Util.MakeKey("Unknown",nil),nil,"client placeholder Unknown is not a player")
assertEqual(Util.MakeKey("Unknown","CAMWOWEU4Realm10RP"),nil,"placeholder with a realm token is not a player")
assertEqual(Util.MakeKey("Unknown Entity",nil),nil,"Unknown Entity placeholder is not a player")
assertEqual(Util.SafeKey("Unknown"),nil,"SafeKey must reject the Unknown placeholder")
assertEqual(Util.MakeKey("Unknown Fate",nil),"Unknown-Fate","a real two-word name may start with Unknown")
assertEqual(Util.SafeKey("A"),nil,"one-character invalid name accepted")
assertEqual(Util.SafeKey("Bad|Name"),nil,"unsafe name accepted")

-- Display helpers live in UI.lua; keep a Core-level guarantee that keys stay name-only.
assertFalse(tostring(Util.MakeKey("Otto Bywater","CAMWOWEU4Realm10RP") or ""):find("CAMWOW"),"MakeKey leaked CAMWOW realm into key")

print("PASS: player-name normalization tests")