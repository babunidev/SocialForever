-- Event-driven discovery regression tests (mocked Forever APIs, not live client).
function wipe(t) for k in pairs(t) do t[k] = nil end end
function strsplit(sep, text, limit)
    if type(text) ~= "string" then return nil end
    local out, start = {}, 1
    while not limit or #out < limit - 1 do
        local i, j = string.find(text, sep, start, true)
        if not i then break end
        out[#out + 1] = string.sub(text, start, i - 1)
        start = j + 1
    end
    out[#out + 1] = string.sub(text, start)
    return table.unpack(out)
end
function GetTime() return 1000 end
function GetServerTime() return 51000 end
function GetZoneText() return "Elwynn Forest" end
function GetSubZoneText() return "Goldshire" end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function UnitName(unit)
    if unit == "player" then return "Localplayer", "ForeverRealm" end
    if unit == "mouseover" then return "Hovered", "Person" end
end
function UnitExists(unit) return unit == "mouseover" end
function UnitIsPlayer(unit) return unit == "mouseover" end
function UnitIsUnit(a, b) return a == b end
function UnitIsConnected() return true end
function UnitIsVisible(unit) return unit == "mouseover" end
function UnitDistanceSquared(unit)
    if unit == "mouseover" then return 100, true end
end
function UnitLevel() return 20 end
function UnitClass() return "Mage", "MAGE" end
function UnitRace() return "Human", "Human" end
function UnitFactionGroup() return "Alliance" end
function GetPlayerInfoByGUID(guid)
    if guid == "Player-123-Caster" then
        return "Priest", "PRIEST", "Human", "Human", 2, "Caster Person", "CAMWOWEU4Realm10RP"
    end
end
C_UnitAuras = {
    GetAuraCasterGUID = function(unit, id)
        if unit == "player" and id == 17 then return "Player-123-Caster" end
    end,
}
SocialForever = nil
SocialForeverDB = {players={}, remote={}, customFlags={}, ignored={}, migratedIgnoreFlags=true}
dofile("Core.lua")
dofile("Memory.lua")
dofile("Group.lua")
dofile("Detection.lua")
local SF, publishes = SocialForever, {}
SF.Util.InitDB()
-- The isolated detection test does not load Sharing.lua.
SF.Sharing.MaybeHello = function() end
SF.UI.RefreshList = function(opts) publishes[#publishes + 1] = opts end

SF.Detection.OnMouseoverChanged()
assert(SF.State.nearby["Hovered-Person"], "mouseover was not published synchronously")
assert(publishes[#publishes] and publishes[#publishes].skipMove, "mouseover should paint without a movement hold")

-- Preexisting buffs on login must not become new nearby encounters.
local oldAura = {isHelpful=true, auraInstanceID=88}
C_UnitAuras.GetAuraDataByIndex = function(unit, index, filter)
    if unit == "player" and index == 1 and filter == "HELPFUL" then return oldAura end
end
SF.Detection.PrimePlayerHelpfulAuras()
assert(SF.State.P.helpfulAuraSeen[88], "preexisting aura was not primed")
SF.Detection.OnPlayerAura("player", {addedAuras={oldAura}})
assert(SF.State.P.recentBuffKey == nil, "preexisting aura was treated as newly received")

local aura = {isHelpful=true, auraInstanceID=17}
SF.Detection.OnPlayerAura("player", {addedAuras={aura}})
assert(SF.State.nearby["Caster-Person"], "fresh aura caster GUID should work without a live unit token")
assert(SF.State.P.recentBuffKey == "Caster-Person", "newly identified buff caster should receive priority")
assert(publishes[#publishes] and publishes[#publishes].skipMove, "aura caster should paint without a movement hold")
assert(SF.State.sightings["Caster-Person"].origins[1] == "helpful_aura", "caster origin missing")

local countedAt = SF.State.sightings["Caster-Person"].at
local recencyAt = SF.State.P.recentBuffAt
SF.Detection.OnPlayerAura("player", {addedAuras={aura}})
assert(SF.State.sightings["Caster-Person"].at == countedAt, "the same aura was repeatedly counted")
assert(SF.State.P.recentBuffAt == recencyAt, "the same aura repeatedly pinned the caster")

-- A full aura snapshot must not refresh a buff simply because it persists.
C_UnitAuras.GetAuraDataByIndex = function(unit, index, filter)
    if unit == "player" and index == 1 and filter == "HELPFUL" then
        return aura
    end
end
SF.Detection.OnPlayerAura("player", {addedAuras={}})
assert(SF.State.sightings["Caster-Person"].at == countedAt, "persistent helpful aura refreshed a stale player")
assert(SF.State.sightings["Caster-Person"].ttl == SF.Const.BUFF_TTL, "buff-only sightings should expire quickly")
assert(SF.State.nearby["Caster-Person"], "empty aura delta must not remove confirmed caster")
print("PASS: immediate mouseover and fresh helpful-aura GUID discovery")
