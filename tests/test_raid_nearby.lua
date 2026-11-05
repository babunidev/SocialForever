function wipe(t) for k in pairs(t) do t[k]=nil end end
local now=1000
local inRaid=true
local units={}
function GetTime() return now end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function IsInRaid() return inRaid end
function IsInGroup() return inRaid end
function UnitExists(unit) if unit=="player" then return true end return units[unit]~=nil end
function UnitIsConnected(unit) if unit=="player" then return true end local d=units[unit]; return d and d.connected~=false or false end
function UnitIsPlayer(unit) return unit=="player" or units[unit]~=nil end
function UnitName(unit) if unit=="player" then return "Localplayer","ForeverRealm" end local d=units[unit]; if d then return d.name,"ForeverRealm" end end
function UnitClass(unit) if unit=="player" then return "Paladin","PALADIN" end if units[unit] then return "Warrior","WARRIOR" end end
function UnitRace(unit) if unit=="player" then return "Human","Human" end if units[unit] then return "Human","Human" end end
function UnitFactionGroup(unit) if unit=="player" or units[unit] then return "Alliance" end end
function UnitDistanceSquared(unit) local d=units[unit]; if not d or d.distance==nil then return nil,false end return d.distance*d.distance,true end
function CheckInteractDistance() return false end
function UnitIsVisible(unit) local d=units[unit]; return d and d.visible==true or false end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua")
local SF=SocialForever
local S=SF.State
local Detection=SF.Detection
SF.Util.InitDB()
Detection.Publish=function() end

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end
local function reset()
 S.sightings={}; S.inviteState={}; S.P.groupByKey={}; S.P.groupByNorm={}; S.P.nameplateByUnit={}; units={}; now=1000; inRaid=true
end

reset()
units.raid1={name="Near Person",distance=20}; S.P.groupByKey["Near-Person"]="raid1"; S.P.groupByNorm.nearperson="raid1"
S.sightings["Near-Person"]={at=900,trackable=true,ttl=180}
Detection.ValidatePresence()
assertTrue(S.sightings["Near-Person"]~=nil,"20-yard raid member removed")
assertEqual(S.sightings["Near-Person"].at,1000,"20-yard member not refreshed")
assertEqual(S.sightings["Near-Person"].unconfirmedSince,nil,"20-yard member stale")

reset()
units.raid2={name="Far Person",distance=70}; S.P.groupByKey["Far-Person"]="raid2"; S.P.groupByNorm.farperson="raid2"
S.sightings["Far-Person"]={at=900,trackable=true,ttl=180}
Detection.ValidatePresence()
assertEqual(S.sightings["Far-Person"],nil,"70-yard raid member remained")

reset()
S.P.groupByKey["Missing-Person"]="raid3"; S.P.groupByNorm.missingperson="raid3"
S.sightings["Missing-Person"]={at=900,trackable=true,ttl=180}
Detection.ValidatePresence()
assertTrue(S.sightings["Missing-Person"]~=nil,"missing token removed immediately")
assertEqual(S.sightings["Missing-Person"].unconfirmedSince,1000,"missing token not stale")
now=now+S.P.staleTrackable; Detection.ValidatePresence()
assertEqual(S.sightings["Missing-Person"],nil,"stale raid member immortal")

reset()
units.raid4={name="Unknown Range",distance=nil,visible=false}; S.P.groupByKey["Unknown-Range"]="raid4"; S.P.groupByNorm.unknownrange="raid4"
S.sightings["Unknown-Range"]={at=900,trackable=true,ttl=180}
Detection.ValidatePresence()
assertEqual(S.sightings["Unknown-Range"].unconfirmedSince,1000,"membership counted as proximity")
now=now+S.P.staleTrackable; Detection.ValidatePresence()
assertEqual(S.sightings["Unknown-Range"],nil,"unconfirmed raid member did not expire")

reset()
units.raid5={name="Never Seen",distance=20}; S.P.groupByKey["Never-Seen"]="raid5"; S.P.groupByNorm.neverseen="raid5"
Detection.ValidatePresence()
assertEqual(S.sightings["Never-Seen"],nil,"raid membership manufactured Nearby")

reset(); inRaid=false
units.party1={name="Party Person",distance=20}; S.P.groupByKey["Party-Person"]="party1"; S.P.groupByNorm.partyperson="party1"
Detection.ValidatePresence()
assertEqual(S.sightings["Party-Person"],nil,"party membership manufactured Nearby")

print("PASS: raid/Nearby presence tests")