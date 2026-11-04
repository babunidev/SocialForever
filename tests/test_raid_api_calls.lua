function wipe(t) for k in pairs(t) do t[k]=nil end end

local calls={UnitExists=0,UnitName=0,UnitDistanceSquared=0,UnitIsPlayer=0,UnitIsConnected=0}
local existsByUnit={}
local function resetCalls()
 for k in pairs(calls) do calls[k]=0 end
 existsByUnit={}
end

function GetTime() return 1000 end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function IsInRaid() return true end
function IsInGroup() return true end
function UnitExists(unit)
 calls.UnitExists=calls.UnitExists+1
 existsByUnit[unit]=(existsByUnit[unit] or 0)+1
 local n=unit:match("^raid(%d+)$")
 return n~=nil and tonumber(n)<=40
end
function UnitIsConnected(unit) calls.UnitIsConnected=calls.UnitIsConnected+1; return unit:match("^raid%d+$")~=nil end
function UnitIsPlayer(unit) calls.UnitIsPlayer=calls.UnitIsPlayer+1; return unit:match("^raid%d+$")~=nil end
function UnitIsUnit() return false end
function UnitName(unit)
 calls.UnitName=calls.UnitName+1
 local n=unit:match("^raid(%d+)$")
 if n then return "Raidperson"..n,"ForeverRealm" end
 if unit=="player" then return "Localplayer","ForeverRealm" end
end
function UnitClass(unit) if unit:match("^raid%d+$") then return "Warrior","WARRIOR" end end
function UnitRace(unit) if unit:match("^raid%d+$") then return "Human","Human" end end
function UnitFactionGroup(unit) if unit=="player" or unit:match("^raid%d+$") then return "Alliance" end end
function UnitLevel(unit) if unit:match("^raid%d+$") then return 60 end end
function UnitDistanceSquared(unit)
 calls.UnitDistanceSquared=calls.UnitDistanceSquared+1
 if unit:match("^raid%d+$") then return 625,true end
 return nil,false
end
function CheckInteractDistance() return false end
function UnitIsVisible() return false end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua")
local SF=SocialForever
local S=SF.State
local Detection=SF.Detection
SF.Util.InitDB()

local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end
local function countPattern(p)
 local n=0
 for unit,count in pairs(existsByUnit) do if unit:match(p) then n=n+count end end
 return n
end
local function printCounts(label)
 print(label..": UnitExists="..calls.UnitExists..
       " UnitName="..calls.UnitName..
       " UnitIsPlayer="..calls.UnitIsPlayer..
       " UnitIsConnected="..calls.UnitIsConnected..
       " UnitDistanceSquared="..calls.UnitDistanceSquared)
end

for i=1,40 do
 local key="Raidperson"..i
 local unit="raid"..i
 S.P.groupByKey[key]=unit
 S.P.groupByNorm[key:lower()]=unit
end

resetCalls()
local live=Detection.BuildLiveUnitMap()
assertEqual(countPattern("^raid%d+$"),40,"BuildLiveUnitMap cached raid-unit checks")
assertEqual(countPattern("^raid%d+target$"),0,"BuildLiveUnitMap repeated raid-target sweep")
assertEqual(calls.UnitDistanceSquared,0,"BuildLiveUnitMap performed distance checks")
for i=1,40 do assertEqual(live["Raidperson"..i],"raid"..i,"missing cached raid member") end
printCounts("BuildLiveUnitMap")

Detection.Publish=function() end
resetCalls()
Detection.ScanRaid()
assertEqual(countPattern("^raid%d+$"),40,"ScanRaid raid checks")
assertEqual(countPattern("^raid%d+target$"),40,"ScanRaid target checks")
assertEqual(calls.UnitDistanceSquared,40,"ScanRaid distance checks")
printCounts("ScanRaid")

resetCalls()
Detection.ValidatePresence()
assertEqual(countPattern("^raid%d+$"),40,"ValidatePresence cached raid checks")
assertEqual(countPattern("^raid%d+target$"),0,"ValidatePresence repeated raid-target sweep")
assertEqual(calls.UnitDistanceSquared,40,"ValidatePresence distance checks")
printCounts("ValidatePresence")

print("PASS: raid API-call instrumentation tests")