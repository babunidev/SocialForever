function wipe(t) for k in pairs(t) do t[k]=nil end end
SocialForever=nil
SocialForeverDB=nil
dofile("Core.lua"); dofile("Memory.lua")
local SF=SocialForever
local Memory=SF.Memory
local S=SF.State
local function assertTrue(v,m) if not v then error(m,2) end end
local function assertEqual(a,e,m) if a~=e then error((m or "values differ")..": expected "..tostring(e)..", got "..tostring(a),2) end end

SocialForeverDB={
 players={
  ["Alice-Person"]={nearbyTimes=7,color="green",lastRecognitionAt=123456,flags={["Really friendly"]=true}},
  ["Bob-Person"]={nearbyTimes=4,color="yellow",lastRecognitionAt=654321,flags={}},
 },
 remote={
  ["Alice-Person"]={["Other-Person"]={color="red"}},
  ["Bob-Person"]={["Other-Person"]={color="green"}},
 },
 ignored={["Alice-Person"]=true,["Bob-Person"]=true},
 customFlags={"Helpful"},listTab="zone",sameMobAsk=true,nameSize=20,backgroundAlpha=0.55,migratedIgnoreFlags=true,
}
SF.Util.InitDB()

S.inviteState["Alice-Person"]="pending"; S.inviteState["Bob-Person"]="pending"
S.sameMobInviteAt["Alice-Person"]=111; S.sameMobInviteAt["Bob-Person"]=222
S.helloAt["Alice-Person"]=111; S.helloAt["Bob-Person"]=222
S.helloReplyAt["Alice-Person"]=111; S.helloReplyAt["Bob-Person"]=222
S.pushedAt["Alice-Person"]=111; S.pushedAt["Bob-Person"]=222
S.peers["Alice-Person"]=true; S.peers["Bob-Person"]=true
S.P.recognitionToken["Alice-Person"]=3; S.P.recognitionPending["Alice-Person"]=true

assertTrue(Memory.ResetPlayer("Alice-Person"),"ResetPlayer false")
assertEqual(SF.db.players["Alice-Person"],nil,"Alice local memory remains")
assertEqual(SF.db.remote["Alice-Person"],nil,"Alice remote memory remains")
assertEqual(SF.db.ignored["Alice-Person"],nil,"Alice ignored remains")
assertEqual(S.P.recognitionPending["Alice-Person"],nil,"Alice pending recognition remains")
assertEqual(S.inviteState["Alice-Person"],nil,"Alice invite state remains")
assertEqual(S.sameMobInviteAt["Alice-Person"],nil,"Alice same-mob state remains")
assertEqual(S.helloAt["Alice-Person"],nil,"Alice hello remains")
assertEqual(S.helloReplyAt["Alice-Person"],nil,"Alice hello reply remains")
assertEqual(S.pushedAt["Alice-Person"],nil,"Alice push remains")
assertEqual(S.peers["Alice-Person"],nil,"Alice peer remains")

assertTrue(SF.db.players["Bob-Person"]~=nil,"Bob removed")
assertEqual(SF.db.players["Bob-Person"].nearbyTimes,4,"Bob familiarity changed")
assertEqual(SF.db.players["Bob-Person"].lastRecognitionAt,654321,"Bob recognition changed")
assertTrue(SF.db.remote["Bob-Person"]~=nil,"Bob remote removed")
assertEqual(SF.db.ignored["Bob-Person"],true,"Bob ignored changed")

assertEqual(SF.db.listTab,"zone","list pref changed")
assertEqual(SF.db.sameMobAsk,nil,"sameMobAsk should stay discarded")
assertEqual(SF.db.nameSize,20,"name size changed")
assertEqual(SF.db.backgroundAlpha,0.55,"background changed")
assertEqual(SF.db.customFlags[1],"Helpful","custom flags changed")

S.P.recognitionToken["Bob-Person"]=8; S.P.recognitionPending["Bob-Person"]=true
assertTrue(Memory.ResetAllPlayers(),"ResetAllPlayers false")
assertEqual(next(SF.db.players),nil,"players not empty")
assertEqual(next(SF.db.remote),nil,"remote not empty")
assertEqual(next(SF.db.ignored),nil,"ignored not empty")
assertEqual(next(S.P.recognitionToken),nil,"recognition tokens not empty")
assertEqual(next(S.P.recognitionPending),nil,"recognition pending not empty")
assertEqual(next(S.inviteState),nil,"invite state not empty")
assertEqual(next(S.sameMobInviteAt),nil,"same-mob state not empty")
assertEqual(next(S.helloAt),nil,"hello not empty")
assertEqual(next(S.helloReplyAt),nil,"hello reply not empty")
assertEqual(next(S.pushedAt),nil,"pushed not empty")
assertEqual(next(S.peers),nil,"peers not empty")
assertEqual(SF.db.listTab,"zone","list pref lost")
assertEqual(SF.db.sameMobAsk,nil,"sameMobAsk should stay discarded")
assertEqual(SF.db.nameSize,20,"name size lost")
assertEqual(SF.db.backgroundAlpha,0.55,"background lost")
assertEqual(SF.db.customFlags[1],"Helpful","custom flags lost")

print("PASS: memory reset tests")