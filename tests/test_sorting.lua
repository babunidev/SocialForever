function wipe(t) for k in pairs(t) do t[k]=nil end end

local now=100
local targetName=nil
function GetTime() return now end
function GetZoneText() return "Elwynn Forest" end
function GetSubZoneText() return "Northshire Valley" end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit)
 if unit=="player" then return "Localplayer","ForeverRealm" end
 if unit=="target" and targetName then return targetName,"ForeverRealm" end
end
function InCombatLockdown() return false end
C_Timer={After=function(_,cb) cb() end}

GameFontHighlight={GetFont=function() return "Fonts\\FRIZQT__.TTF",16,"" end}
GameTooltip={
 IsShown=function() return false end,
 GetOwner=function() return nil end,
 Hide=function() end,
}

SocialForever=nil
SocialForeverDB={
 players={
  Alpha={nearbyTimes=1,flags={}},
  Beta={nearbyTimes=1,flags={}},
 },
 remote={},customFlags={},ignored={},listTab="nearby",migratedIgnoreFlags=true,
}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("UI.lua")
local SF=SocialForever
local S=SF.State
local UI=SF.UI
local Memory=SF.Memory
SF.Util.InitDB()

local noop=function() end
local function makeTab()
 return {
  label={SetText=noop,SetTextColor=noop},
  SetBackdropColor=noop,
  SetBackdropBorderColor=noop,
 }
end
local scripts={}
S.main={
 fadingPaint=false,
 rows={},
 list={GetWidth=function() return 250 end,GetHeight=function() return 120 end},
 empty={SetText=noop,Show=noop,Hide=noop},
 bar={
  lock=false,Show=noop,Hide=noop,SetMinMaxValues=noop,SetValue=noop,
  IsShown=function() return false end,IsMouseOver=function() return false end,
 },
 tabNearby=makeTab(),tabZone=makeTab(),scrollOffset=0,
 IsShown=function() return true end,
 GetScript=function(_,name) return scripts[name] end,
 SetScript=function(_,name,fn) scripts[name]=fn end,
}

local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end
local function order()
 local out={}
 for i,e in ipairs(S.displayOrdered or {}) do out[i]=e.key end
 return table.concat(out,",")
end
local function setNearby(alphaYards,betaYards)
 S.nearby={
  Alpha={key="Alpha",yards=alphaYards,at=now,ttl=180,area="Northshire Valley",zone="Elwynn Forest"},
  Beta={key="Beta",yards=betaYards,at=now,ttl=180,area="Northshire Valley",zone="Elwynn Forest"},
 }
 S.inZone={}
end

setNearby(10,20)
UI.RefreshList({force=true,skipMove=true})
assertEqual(order(),"Alpha,Beta","initial distance order")

S.nearby.Alpha.yards=30
S.nearby.Beta.yards=5
now=104
UI.RefreshList({force=true,skipMove=true})
assertEqual(order(),"Beta,Alpha","changed distance did not reorder same membership")

targetName="Alpha"
UI.RefreshList({force=true,skipMove=true})
assertEqual(order(),"Alpha,Beta","current target did not pin to top")

targetName=nil
SF.db.players.Alpha.nearbyTimes=10
SF.db.players.Beta.nearbyTimes=1
Memory.InvalidateMaxFamiliarity()
now=108
UI.RefreshList({force=true,skipMove=true})
assertEqual(order(),"Alpha,Beta","changed familiarity did not reorder same membership")

local original=UI.RefreshList
local periodicCalls=0
UI.RefreshList=function() periodicCalls=periodicCalls+1 end
S.sortHold.at=now
now=now+SF.Const.SORT_EVERY
UI.RefreshSortOrder()
assertEqual(periodicCalls,1,"periodic sort refresh did not trigger without membership changes")
UI.RefreshList=original

print("PASS: sorting and periodic reorder tests")