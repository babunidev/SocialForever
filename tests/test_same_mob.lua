function wipe(t) for k in pairs(t) do t[k]=nil end end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Localplayer","ForeverRealm" end end
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

-- Same-mob prompts were removed from Settings and remain forced off.
assertEqual(Group.SameMobAskOn(),false,"same-mob ask must stay forced off")
local ok=Detection.EvaluateSameMobGrouping(42)
assertTrue(ok==true,"same-mob evaluation should short-circuit while disabled")
assertEqual(unattendedCalls,0,"same-mob path called unattended invite API")
assertEqual(promptCalls,0,"disabled same-mob option opened prompt")
assertEqual(#S.sameMobQueue,0,"same-mob queue populated while disabled")

SF.db.sameMobAsk=true
Group.SetSameMobAsk(true)
assertEqual(Group.SameMobAskOn(),false,"SetSameMobAsk must not re-enable prompts")
assertEqual(SF.db.sameMobAsk,false,"SetSameMobAsk must force saved option off")

print("PASS: same-mob grouping stays disabled and prompt-free")
