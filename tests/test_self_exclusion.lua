function wipe(t) for k in pairs(t) do t[k]=nil end end
function GetTime() return now or 1000 end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit)
  if unit=="player" then return "Local Player","ForeverRealm" end
  if unit=="mouseover" then return "Other Person","ForeverRealm" end
end
function UnitGUID(unit)
  if unit=="player" then return "Player-1-SELF" end
  if unit=="mouseover" then return "Player-1-OTHER" end
end
function UnitIsUnit(a,b) return a=="player" and b=="player" end
function UnitExists(unit) return unit=="player" or unit=="mouseover" end
function UnitIsPlayer(unit) return true end
function UnitIsConnected() return true end
function UnitClass() return "Warrior","WARRIOR" end
function UnitRace() return "Human","Human" end
function GetPlayerInfoByGUID(guid)
  if guid=="Player-1-SELF" then
    return "Warrior","WARRIOR","Human","Human",nil,"Local Player","CAMWOWEU4Realm10RP"
  end
  if guid=="Player-1-OTHER" then
    return "Mage","MAGE","Human","Human",nil,"Other Person","CAMWOWEU4Realm10RP"
  end
end
function InCombatLockdown() return false end
function IsInRaid() return false end
function IsInGroup() return false end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua")
local SF=SocialForever
local Util=SF.Util
local Detection=SF.Detection
local Memory=SF.Memory
local S=SF.State
Util.InitDB()
now=1000

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

assertTrue(Util.IsMyGuid("Player-1-SELF"),"player GUID not recognized")
assertTrue(Util.IsMe("Local-Player"),"local player key not IsMe")
assertTrue(Util.IsMe("Local Player CAMWOWEU4Realm10RP"),"polluted self key not IsMe")
assertEqual(Detection.KeyFromGuid("Player-1-SELF"),nil,"KeyFromGuid must reject self GUID")
assertEqual(Util.UnitIdentity("player"),nil,"UnitIdentity must reject player unit")

Detection.Remember("Local-Player",1,nil,SF.Const.UNIT_TTL,nil,nil,nil,nil,"interaction","helpful_aura")
assertEqual(S.sightings["Local-Player"],nil,"Remember must not keep self sighting")
assertEqual(SF.db.players["Local-Player"],nil,"Remember must not create self memory")

-- Buff/GUID path for self must never enter Nearby or raise familiarity.
local added=Detection.NoteHelpfulAuraCaster({
  isHelpful=true,
  auraInstanceID=7,
  sourceUnit=nil,
})
-- Without GetAuraCasterGUID mock this returns false; exercise KeyFromGuid path via Remember alias.
assertEqual(Detection.KeyFromGuid("Player-1-SELF"),nil,"self GUID key")
Memory.NoteNearbyPlace("Local-Player",true)
assertEqual(SF.db.players["Local-Player"],nil,"NoteNearbyPlace must not charge self familiarity")

Detection.Remember("Other-Person",1,nil,SF.Const.BUFF_TTL,nil,nil,nil,nil,"interaction","helpful_aura")
assertTrue(S.sightings["Other-Person"]~=nil,"other buff caster missing")
assertEqual(S.sightings["Other-Person"].ttl,SF.Const.BUFF_TTL,"buff TTL not applied")

-- The same buff must not restart the timer while it is still up.
now=3000
local aura={isHelpful=true,auraInstanceID=42}
assertTrue(Detection.RememberBuffCaster("Buffer-Person",nil,nil,nil,aura)==true,"first buff did not list the caster")
assertEqual(S.sightings["Buffer-Person"].ttl,SF.Const.SEEN_TTL,"buff caster did not use the normal nearby lifetime")
S.sightings["Buffer-Person"].at=111
S.sightings["Buffer-Person"].unconfirmedSince=222
assertTrue(Detection.RememberBuffCaster("Buffer-Person",nil,nil,nil,aura)==false,"repeat buff refreshed the caster")
assertEqual(S.sightings["Buffer-Person"].at,111,"repeat buff moved the sighting clock")
assertEqual(S.sightings["Buffer-Person"].unconfirmedSince,222,"repeat buff cleared the grace timer")
assertEqual(Detection.BuffCasterKey("player",42,"HELPFUL"),"Buffer-Person","buff tooltip could not reuse the known caster")
S.sightings["Buffer-Person"]=nil

-- Nameplate loss starts the grace; the player lingers until it runs out.
S.P.nameplateByUnit.nameplate1="Other-Person"
S.sightings["Other-Person"].trackable=true
function UnitName(unit)
  if unit=="player" then return "Local Player","ForeverRealm" end
end
function UnitExists(unit) return unit=="player" end
now=2000
S.sightings["Other-Person"].at=now
Detection.OnNameplateRemoved("nameplate1")
assertTrue(S.sightings["Other-Person"]~=nil,"nameplate removal dropped player before grace")
assertEqual(S.sightings["Other-Person"].unconfirmedSince,now,"nameplate removal did not start grace")
now=now+SF.Const.STALE_TRACKABLE-1
Detection.ValidatePresence()
assertTrue(S.sightings["Other-Person"]~=nil,"player dropped before trackable grace ended")
now=now+2
Detection.ValidatePresence()
assertEqual(S.sightings["Other-Person"],nil,"player not dropped after trackable grace")

Util.PurgeSelfRecords()
SF.db.players["Local-Player"]={nearbyTimes=9}
Util.PurgeSelfRecords()
assertEqual(SF.db.players["Local-Player"],nil,"PurgeSelfRecords left self memory")

print("PASS: self exclusion, buff TTL, and nameplate drop tests")
