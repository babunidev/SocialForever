function wipe(t) for k in pairs(t) do t[k]=nil end end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Localplayer" end end
function InCombatLockdown() return false end

local unattendedCalls=0
function InviteUnit()
 unattendedCalls=unattendedCalls+1
 error("unattended InviteUnit call")
end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},sameMobAsk=true,migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua")
local SF=SocialForever
local S=SF.State
local Group=SF.Group
local Detection=SF.Detection
local UI=SF.UI
SF.Util.InitDB()

local promptCalls=0
UI.ShowSameMobPrompt=function() promptCalls=promptCalls+1 end
Group.PartyHasRoom=function() return true end
Detection.CollectSameMobCandidates=function()
 return {{key="Candidate-Person",mob="Forest Wolf"}}
end

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

local ok=Detection.EvaluateSameMobGrouping(42)
assertTrue(ok==true,"same-mob candidate not handled")
assertEqual(unattendedCalls,0,"same-mob path called unattended invite API")
assertEqual(promptCalls,1,"same-mob candidate did not open prompt")
assertEqual(#S.sameMobQueue,1,"same-mob queue not populated")
assertEqual(S.sameMobQueue[1].key,"Candidate-Person","wrong same-mob candidate queued")

SF.db.sameMobAsk=false
promptCalls=0
wipe(S.sameMobQueue)
ok=Detection.EvaluateSameMobGrouping(43)
assertTrue(ok==true,"disabled same-mob prompt did not short-circuit")
assertEqual(promptCalls,0,"disabled same-mob option opened prompt")
assertEqual(unattendedCalls,0,"disabled same-mob option called invite API")

print("PASS: same-mob grouping remains prompt-only and user-controlled")