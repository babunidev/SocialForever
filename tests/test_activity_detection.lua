function wipe(t) for k in pairs(t) do t[k]=nil end end
function strsplit(sep,text,limit)
 if type(text)~="string" then return nil end
 local out,start={},1
 while not limit or #out < limit-1 do
  local i,j=string.find(text,sep,start,true)
  if not i then break end
  out[#out+1]=string.sub(text,start,i-1)
  start=j+1
 end
 out[#out+1]=string.sub(text,start)
 return table.unpack(out)
end

local now=1000
function GetTime() return now end
function GetServerTime() return 50000+now end
function GetZoneText() return "Elwynn Forest" end
function GetSubZoneText() return "Goldshire" end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit)
 if unit=="player" then return "Localplayer","ForeverRealm" end
end
function UnitExists() return false end
function GetPlayerInfoByGUID(guid)
 if guid=="Player-GUID-Crafter" then
  return "Mage","MAGE","Human","Human",2,"Crafter","ForeverRealm"
 end
end

TRADESKILL_LOG_THIRDPERSON="%s creates %s."
CREATED_ITEM="%s creates: %s."
CREATED_ITEM_MULTIPLE="%s creates: %sx%d."

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua")
local SF=SocialForever
local S=SF.State
local Detection=SF.Detection
SF.Util.InitDB()
Detection.Publish=function() end

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertFalse(v,m) if v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

assertEqual(Detection.CraftNameFromMessage("Smith creates [Copper Bar]."),"Smith","localized craft template did not parse name")
assertEqual(Detection.CraftNameFromMessage("Two Name creates [Copper Bar]."),"Two Name","two-word craft name did not parse")

assertTrue(Detection.NoteCraftEvent("Smith creates [Copper Bar].","Smith",nil,true),"system craft line was not accepted")
assertTrue(S.sightings.Smith~=nil,"system craft line did not create Nearby sighting")

assertTrue(Detection.NoteCraftEvent("Two Name creates [Copper Bar].","",nil,true),"two-word system craft line was not accepted")
assertTrue(S.sightings["Two-Name"]~=nil,"two-word craft name was not normalized")

assertFalse(Detection.NoteCraftEvent("You have learned how to create a new item: Copper Bar.","",nil,true),"unrelated system message was treated as nearby craft")
assertEqual(S.sightings.You,nil,"unrelated system message created bogus player")

assertTrue(Detection.NoteCraftEvent("opaque trade-skill payload","", "Player-GUID-Crafter",false),"trade-skill GUID fallback failed")
assertTrue(S.sightings.Crafter~=nil,"GUID-backed craft event did not create Nearby sighting")

assertFalse(Detection.NoteCraftEvent("You create [Copper Bar].","Localplayer",nil,false),"local player's craft became Nearby")
assertEqual(S.sightings.Localplayer,nil,"local player was stored as Nearby")

print("PASS: nearby craft event and system craft parsing tests")
