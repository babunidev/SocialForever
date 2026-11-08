function wipe(t) for k in pairs(t) do t[k]=nil end end
local now=100000
function GetServerTime() return now end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit)
 if unit=="player" then return "Localplayer","ForeverRealm" end
 if unit=="target" then return "Blue","Person" end
end
function UnitIsPlayer(unit) return unit=="target" end
function InCombatLockdown() return false end
C_Timer={After=function(_,cb) cb() end}
LOCALIZED_CLASS_NAMES_MALE=nil
local chatMessages={}
DEFAULT_CHAT_FRAME={AddMessage=function(_,text) chatMessages[#chatMessages+1]=text end}

local function loadAddon()
 SocialForever=nil
 dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("UI.lua")
 SocialForever.Util.InitDB()
 return SocialForever
end
local function assertTrue(v,m) if not v then error(m,2) end end
local function assertFalse(v,m) if v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

SocialForeverDB={
 players={
  ["White-Person"]={nearbyTimes=1,race="Human",class="WARRIOR"},
  ["Blue-Person"]={nearbyTimes=5,race="Dwarf",class="SHAMAN"},
  ["Purple-Person"]={nearbyTimes=10,race="Human",class="PALADIN"},
  ["Grouped-Person"]={nearbyTimes=5,race="NightElf",class="HUNTER"},
  ["ClassOnly-Person"]={nearbyTimes=5,class="PRIEST"},
  ["RaceOnly-Person"]={nearbyTimes=5,race="Scourge"},
  ["Unknown-Person"]={nearbyTimes=5},
 },remote={},customFlags={},ignored={},migratedIgnoreFlags=true,
}
local SF=loadAddon()
local Memory=SF.Memory
local S=SF.State
Memory.InvalidateMaxFamiliarity()

assertFalse(Memory.RecognitionEligible("White-Person"),"white player eligible")
assertTrue(Memory.RecognitionEligible("Blue-Person"),"blue player rejected")
assertTrue(Memory.RecognitionEligible("Purple-Person"),"purple player rejected")
S.P.groupByKey["Grouped-Person"]="party1"; S.P.groupByNorm["groupedperson"]="party1"
S.P.groupRosterByKey["Grouped-Person"]="party1"; S.P.groupRosterByNorm["groupedperson"]="party1"
assertFalse(Memory.RecognitionEligible("Grouped-Person"),"grouped player eligible")
S.P.groupByKey["Grouped-Person"]=nil; S.P.groupByNorm["groupedperson"]=nil
S.P.groupRosterByKey["Grouped-Person"]=nil; S.P.groupRosterByNorm["groupedperson"]=nil

assertEqual(Memory.RecognitionPhrase("Blue-Person"),"I've seen this Dwarf Shaman before.","race/class phrase")
assertEqual(Memory.RecognitionPhrase("ClassOnly-Person"),"I've seen this Priest before.","class phrase")
assertEqual(Memory.RecognitionPhrase("RaceOnly-Person"),"I've seen this Undead before.","race phrase")
assertEqual(Memory.RecognitionPhrase("Unknown-Person"),"I've seen this player before.","generic phrase")

chatMessages={}
S.nearby["Blue-Person"]={key="Blue-Person"}
assertTrue(Memory.FireRecognition("Blue-Person"),"recognition did not fire")
assertEqual(SocialForeverDB.players["Blue-Person"].lastRecognitionAt,now,"timestamp not stored")
assertEqual(#chatMessages,1,"message count")
now=now+1199
assertTrue(Memory.RecognitionOnCooldown("Blue-Person"),"cooldown ended early")
assertFalse(Memory.RecognitionEligible("Blue-Person"),"eligible during cooldown")
now=now+1
assertFalse(Memory.RecognitionOnCooldown("Blue-Person"),"cooldown did not expire")
assertTrue(Memory.RecognitionEligible("Blue-Person"),"not eligible after cooldown")

now=200000
S.nearby["Purple-Person"]={key="Purple-Person"}
assertTrue(Memory.FireRecognition("Purple-Person"),"purple recognition failed")
local stored=SocialForeverDB.players["Purple-Person"].lastRecognitionAt
SF=loadAddon(); Memory=SF.Memory; S=SF.State; Memory.InvalidateMaxFamiliarity()
now=200500
assertEqual(SocialForeverDB.players["Purple-Person"].lastRecognitionAt,stored,"timestamp lost on reload")
assertTrue(Memory.RecognitionOnCooldown("Purple-Person"),"cooldown lost on reload")
assertFalse(Memory.RecognitionEligible("Purple-Person"),"reloaded player eligible during cooldown")

-- Delayed/stale recognition must not print after the player left Nearby.
chatMessages={}
SocialForeverDB.players["ClassOnly-Person"].lastRecognitionAt=nil
S.nearby["ClassOnly-Person"]=nil
assertFalse(Memory.FireRecognition("ClassOnly-Person"),"stale recognition fired without Nearby entry")
assertEqual(#chatMessages,0,"stale recognition printed a message")

-- Combat recognition is queued until rows can repaint.
local combat=true
_G.InCombatLockdown=function() return combat end
S.nearby["RaceOnly-Person"]={key="RaceOnly-Person"}
SocialForeverDB.players["RaceOnly-Person"].lastRecognitionAt=nil
assertFalse(Memory.FireRecognition("RaceOnly-Person"),"combat recognition fired immediately")
assertTrue(S.P.recognitionCombatPending["RaceOnly-Person"],"combat recognition was not queued")
assertEqual(#chatMessages,0,"combat recognition printed before list could repaint")
combat=false
Memory.FlushRecognitionAfterCombat()
assertEqual(#chatMessages,1,"queued combat recognition did not fire after combat")

-- Target recognition must promote the target into Nearby before printing.
chatMessages={}
SocialForeverDB.players["Blue-Person"].lastRecognitionAt=nil
S.nearby["Blue-Person"]=nil
S.sightings["Blue-Person"]=nil
SF.Util.UnitIdentity=function(unit)
 if unit=="target" then return "Blue-Person","SHAMAN","Dwarf","Alliance" end
 if unit=="player" then return "Localplayer" end
end
SF.Detection.ConsiderUnit=function(unit,loose,origin)
 assertEqual(unit,"target","target recognition considered wrong unit")
 assertEqual(origin,"target","target recognition provenance missing")
 S.sightings["Blue-Person"]={key="Blue-Person",class="SHAMAN",race="Dwarf",origins={"target"}}
 S.nearby["Blue-Person"]={key="Blue-Person",class="SHAMAN",race="Dwarf",origins={"target"}}
end
SF.Detection.Publish=function() end
S.armed=true
Memory.NoteTargetRecognition()
assertTrue(S.nearby["Blue-Person"]~=nil,"target recognition did not promote player to Nearby")
assertEqual(#chatMessages,1,"target recognition did not print after Nearby promotion")

print("PASS: familiar-player recognition tests")