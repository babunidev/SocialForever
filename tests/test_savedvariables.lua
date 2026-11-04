function wipe(t) for k in pairs(t) do t[k] = nil end end

SocialForever = nil
SocialForeverDB = nil
dofile("Core.lua")
dofile("Memory.lua")

local SF = SocialForever
local Util = SF.Util

local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m)
    if a ~= e then error((m or "values differ") .. "\nExpected: " .. tostring(e) .. "\nActual:   " .. tostring(a),2) end
end
local function init(db)
    SocialForeverDB = db
    SF.db = nil
    Util.InitDB()
    return SF.db
end

local db = init(nil)
assertTrue(type(db)=="table","empty DB not created")
assertTrue(type(db.players)=="table","players missing")
assertTrue(type(db.remote)=="table","remote missing")
assertTrue(type(db.customFlags)=="table","customFlags missing")
assertTrue(type(db.ignored)=="table","ignored missing")
assertEqual(db.listTab,"nearby","default list tab wrong")
assertEqual(db.sameMobAsk,false,"same-mob prompt should default off")

db = init({
    players={["Test-Person"]={nearbyTimes=4,color="green",flags={["Really friendly"]=true}}},
    remote={["Test-Person"]={["Other-Person"]={color="green",flags={["Old shared flag"]=true}}}},
    customFlags={"Helpful"}, ignored={}, listTab="zone", sameMobAsk=true, migratedIgnoreFlags=true,
})
assertTrue(db.players["Test-Person"] ~= nil,"existing player lost")
assertEqual(db.players["Test-Person"].nearbyTimes,4,"familiarity changed")
assertEqual(db.players["Test-Person"].color,"green","mark changed")
assertTrue(db.players["Test-Person"].flags["Really friendly"] == true,"personal flag lost")
assertEqual(db.listTab,"zone","list tab not preserved")
assertEqual(db.sameMobAsk,true,"same-mob prompt not preserved")
assertEqual(db.remote["Test-Person"]["Other-Person"].flags,nil,"legacy remote flags not removed")

db = init({players={},remote={},customFlags={},ignored={},autoInviteFriends=true,migratedIgnoreFlags=true})
assertEqual(db.autoInviteFriends,nil,"removed autoInviteFriends survived")

db = init({players={},remote={},customFlags={},ignored={},sameMobAutoInvite=true,migratedIgnoreFlags=true})
assertEqual(db.sameMobAutoInvite,nil,"removed sameMobAutoInvite survived")

db = init({
    players="broken",remote=123,customFlags=false,ignored="broken",
    partyId="wrong",partyCounted="wrong",listTab="bad",sameMobAsk="yes",
    autoInviteFriends=true,sameMobAutoInvite=true,migratedIgnoreFlags=true,
})
assertTrue(type(db.players)=="table","players not repaired")
assertTrue(type(db.remote)=="table","remote not repaired")
assertTrue(type(db.customFlags)=="table","customFlags not repaired")
assertTrue(type(db.ignored)=="table","ignored not repaired")
assertEqual(db.partyId,nil,"partyId not cleared")
assertEqual(db.partyCounted,nil,"partyCounted not cleared")
assertEqual(db.listTab,"nearby","listTab not repaired")
assertEqual(db.sameMobAsk,false,"sameMobAsk not repaired")
assertEqual(db.autoInviteFriends,nil,"obsolete friend field not cleared")
assertEqual(db.sameMobAutoInvite,nil,"obsolete same-mob field not cleared")

print("PASS: SavedVariables initialization and migration tests")