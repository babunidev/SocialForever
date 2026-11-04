function wipe(t) for k in pairs(t) do t[k] = nil end end
function UnitFactionGroup(unit) if unit=="player" then return "Alliance" end end

SocialForever=nil
SocialForeverDB=nil
dofile("Core.lua")
dofile("Memory.lua")

local SF=SocialForever
local Memory=SF.Memory
local C=SF.Const

local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end
local function assertRGB(r,g,b,e,m) if r~=e[1] or g~=e[2] or b~=e[3] then error(m or "RGB mismatch",2) end end

SocialForeverDB={
 players={
  ["Purple-Person"]={nearbyTimes=10,race="Human"},
  ["Blue-Person"]={nearbyTimes=5,race="Dwarf"},
  ["White-Person"]={nearbyTimes=1,race="Human"},
  ["Boundary30-Person"]={nearbyTimes=3,race="Human"},
  ["Boundary80-Person"]={nearbyTimes=8,race="Human"},
  ["Enemy-Person"]={nearbyTimes=10,race="Orc"},
  ["GreenMark-Person"]={nearbyTimes=1,color="green",race="Human"},
  ["RedMark-Person"]={nearbyTimes=10,color="red",race="Human"},
 },remote={},customFlags={},ignored={},migratedIgnoreFlags=true,
}
SF.Util.InitDB()
Memory.InvalidateMaxFamiliarity()

assertEqual(Memory.MaxFamiliarity(),10,"max familiarity")
assertEqual(Memory.FamiliarityBand("White-Person"),"white","white band")
assertEqual(Memory.FamiliarityBand("Blue-Person"),"blue","blue band")
assertEqual(Memory.FamiliarityBand("Purple-Person"),"purple","purple band")
assertEqual(Memory.FamiliarityBand("Boundary30-Person"),"white","30% boundary")
assertEqual(Memory.FamiliarityBand("Boundary80-Person"),"blue","80% boundary")

local r,g,b=Memory.SeenRGB("White-Person",10); assertRGB(r,g,b,C.SEEN_RGB.white,"white RGB")
r,g,b=Memory.SeenRGB("Blue-Person",10); assertRGB(r,g,b,C.SEEN_RGB.blue,"blue RGB")
r,g,b=Memory.SeenRGB("Purple-Person",10); assertRGB(r,g,b,C.SEEN_RGB.purple,"purple RGB")
assertEqual(Memory.GeneralColor("GreenMark-Person"),"green","green mark")
assertEqual(Memory.GeneralColor("RedMark-Person"),"red","red mark")
r,g,b=Memory.NameRGB("Enemy-Person",SF.db.players["Enemy-Person"],10); assertRGB(r,g,b,C.ENEMY_FACTION_RGB,"enemy override")
r,g,b=Memory.NameRGB("Purple-Person",SF.db.players["Purple-Person"],10); assertRGB(r,g,b,C.SEEN_RGB.purple,"same faction familiarity")

print("PASS: familiarity band, mark, and faction-color tests")