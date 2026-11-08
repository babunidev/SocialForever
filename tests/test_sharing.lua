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
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit) if unit=="player" then return "Localplayer" end end
function GetServerTime() return 123456 end
function GetTime() return 1000 end

SocialForever=nil
SocialForeverDB={players={},remote={},customFlags={},ignored={},migratedIgnoreFlags=true}
dofile("Core.lua"); dofile("Memory.lua")
SocialForever.UI.RefreshList=function() end
dofile("Sharing.lua")

local SF=SocialForever
local Sharing=SF.Sharing
SF.Util.InitDB()

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

local note={
 color="green",
 flags={["Really friendly"]=true},
 kos=true,
 nearbyTimes=999,
 declines=7,
}
local msg=Sharing.Encode("Subject-Person",note,"Localplayer")
assertTrue(type(msg)=="string","mark did not serialize")
assertTrue(msg:find("\tG\t",1,true)~=nil,"green mark missing from wire message")
assertTrue(msg:find("Really friendly",1,true)==nil,"private flag serialized")
assertTrue(msg:find("kos",1,true)==nil and msg:find("KOS",1,true)==nil,"KOS serialized")
assertTrue(msg:find("999",1,true)==nil,"encounter count serialized")
assertTrue(msg:find("declines",1,true)==nil and msg:find("\t7\t",1,true)==nil,"decline data serialized")

Sharing.StoreRemote("Sender-Person","D\tSubject-Person\tR\t0\tPrivateFlag\tOrigin-Person")
local remote=SF.db.remote["Subject-Person"] and SF.db.remote["Subject-Person"]["Origin-Person"]
assertTrue(type(remote)=="table","valid remote mark not stored")
assertEqual(remote.color,"red","remote red mark not decoded")
assertEqual(remote.flags,nil,"legacy incoming flag text was stored")

local malformed={
 "",
 "D\t",
 "D\tSubject-Person",
 "D\t\tG\t0\tFlag\tOrigin-Person",
 "D\tSubject-Person\t?\tgarbage\tFlag\tOrigin-Person",
}
for _,bad in ipairs(malformed) do
 local ok,err=pcall(Sharing.StoreRemote,"Sender-Person",bad)
 assertTrue(ok,"malformed sharing message raised error: "..tostring(err))
end

local ok,err=pcall(Sharing.OnAddon,"WrongPrefix","D\tX\tG\t0\t\tY","WHISPER","Sender")
assertTrue(ok,"wrong-prefix addon message raised error: "..tostring(err))
ok,err=pcall(Sharing.OnAddon,SF.Const.PREFIX,nil,"WHISPER","Sender")
assertTrue(ok,"non-string addon payload raised error: "..tostring(err))

print("PASS: sharing serialization/privacy and malformed-message tests")