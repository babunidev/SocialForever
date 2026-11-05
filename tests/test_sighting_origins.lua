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
function GetZoneText() return "Dun Morogh" end
function GetSubZoneText() return "Kharanos" end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Localplayer","ForeverRealm" end end
function UnitExists() return false end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua"); dofile("Group.lua"); dofile("Detection.lua"); dofile("UI.lua")
local SF=SocialForever
local S=SF.State
local Detection=SF.Detection
local UI=SF.UI
SF.Util.InitDB()

local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

Detection.Remember("Nearbyone",2,nil,SF.Const.SEEN_TTL,nil,nil,nil,nil,"interaction","target")
assertEqual(#S.sightings.Nearbyone.origins,1,"first origin was not stored")
assertEqual(S.sightings.Nearbyone.origins[1],"target","target origin mismatch")

now=now+1
Detection.Remember("Nearbyone",2,nil,SF.Const.SEEN_TTL,nil,nil,nil,nil,"interaction","fighting")
assertEqual(#S.sightings.Nearbyone.origins,2,"second origin did not accumulate")
assertEqual(S.sightings.Nearbyone.origins[2],"fighting","fighting origin mismatch")

now=now+1
Detection.Remember("Nearbyone",2,nil,SF.Const.SEEN_TTL,nil,nil,nil,nil,"interaction","target")
assertEqual(#S.sightings.Nearbyone.origins,2,"duplicate origin was not deduplicated")
assertEqual(UI.OriginText(S.sightings.Nearbyone),"Mouseover","target sighting should display one mouseover reason")
assertEqual(UI.OriginText({origins={"mouseover","target","mouseover"}}),"Mouseover","duplicate hover and target origins should collapse")
assertEqual(UI.OriginText({origins={"fighting"}}),"Fighting","distinct fighting reason should survive")
assertEqual(UI.OriginText({origins={"target","helpful_aura"}}),"Buff / helpful aura","buff reason should take precedence")
assertEqual(SF.db.players.Nearbyone.origins,nil,"current-sighting provenance leaked into SavedVariables")
assertEqual(SF.Const.ORIGIN_LABELS.mouseover,"Hovered / mouseover","mouseover label mismatch")

assertEqual(Detection.UnitOrigin("target"),"target","target unit origin mismatch")
assertEqual(Detection.UnitOrigin("mouseover"),"mouseover","mouseover unit origin mismatch")
assertEqual(Detection.UnitOrigin("focus"),"focus","focus unit origin mismatch")
assertEqual(Detection.UnitOrigin("nameplate7"),"nameplate","nameplate unit origin mismatch")
assertEqual(Detection.UnitOrigin("party2"),"group","party unit origin mismatch")
assertEqual(Detection.UnitOrigin("raid14"),"group","raid unit origin mismatch")
assertEqual(Detection.UnitOrigin("party2target"),"tracked_target","tracked target unit origin mismatch")

print("PASS: current-sighting provenance accumulation and labels")
