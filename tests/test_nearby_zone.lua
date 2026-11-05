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
local zone="Elwynn Forest"
local subzone="Northshire Valley"
function GetTime() return now end
function GetServerTime() return 50000+now end
function GetZoneText() return zone end
function GetSubZoneText() return subzone end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Localplayer","ForeverRealm" end end
function UnitExists() return false end
function UnitGUID(unit) if unit == "player" then return "Player-Self-123" end end
function GetPlayerInfoByGUID(guid)
    if guid == "Player-Self-123" then
        return "Priest", "PRIEST", "Dwarf", "Dwarf", 3, "Jasmine Amberbrew", "CAMWOWEU4Realm10RP"
    end
end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua")
local SF=SocialForever
local S=SF.State
local Memory=SF.Memory
local Detection=SF.Detection
SF.Util.InitDB()
Detection.Publish=function() end

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

Detection.NoteChat("Jasmine Amberbrew", "Player-Self-123")
assertEqual(S.sightings["Jasmine-Amberbrew"], nil, "self chat GUID was added to Nearby")
Detection.NoteChat("Jasmine Amberbrew", nil)
assertEqual(S.sightings["Jasmine-Amberbrew"], nil, "self chat with missing GUID was added to Nearby")
assertEqual(Memory.Familiarity("Jasmine-Amberbrew"), 0, "self gained familiarity")

Detection.NoteZone("Zone Person","1. General - Elwynn Forest","General",nil)
assertTrue(S.zoneSeen["Zone-Person"]~=nil,"General-channel player not stored as Zone candidate")
assertEqual(Memory.Familiarity("Zone Person"),0,"Zone-only player increased familiarity")
assertEqual(S.sightings["Zone-Person"],nil,"Zone-only player became Nearby")

Detection.NoteChat("Near Person",nil)
assertTrue(S.sightings["Near-Person"]~=nil,"say/emote-style nearby input did not create sighting")
assertEqual(Memory.Familiarity("Near Person"),1,"first Nearby encounter not counted")

now=now+1
Detection.NoteChat("Near Person",nil)
assertEqual(Memory.Familiarity("Near Person"),1,"repeated same sighting increased familiarity")

S.sightings["Near-Person"]=nil
now=now+1
Detection.NoteChat("Near Person",nil)
assertEqual(Memory.Familiarity("Near Person"),1,"same-place re-entry increased familiarity")

S.sightings["Near-Person"]=nil
subzone="Goldshire"
now=now+1
Detection.NoteChat("Near Person",nil)
assertEqual(Memory.Familiarity("Near Person"),2,"different-place encounter did not increase familiarity")

print("PASS: Nearby/Zone separation and place-based familiarity tests")