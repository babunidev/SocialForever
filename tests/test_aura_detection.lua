SocialForever = nil
function GetTime() return 100 end
dofile("Core.lua")
dofile("Detection.lua")
local SF = SocialForever
local Detection = SF.Detection
local UI = SF.UI
local calls, sortInvalidations, publishes = {}, 0, 0
local fresh, old = { marker = "new" }, { marker = "old" }
Detection.NoteHelpfulAuraCaster = function(aura)
    calls[#calls + 1] = aura
    return aura == fresh
end
Detection.Publish = function(immediate)
    assert(immediate == true, "new aura evidence should publish immediately")
    publishes = publishes + 1
end
UI.InvalidateListSort = function() sortInvalidations = sortInvalidations + 1 end
local function assertEqual(actual, expected, message)
    if actual ~= expected then
        error((message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
    end
end
Detection.OnPlayerAura("player", nil)
Detection.OnPlayerAura("player", {})
Detection.OnPlayerAura("player", { isFullUpdate = true, addedAuras = { fresh } })
Detection.OnPlayerAura("player", { updatedAuraInstanceIDs = { 11 } })
Detection.OnPlayerAura("player", { removedAuraInstanceIDs = { 11 } })
Detection.OnPlayerAura("player", { addedAuras = {} })
Detection.OnPlayerAura("party1", { addedAuras = { fresh } })
assertEqual(#calls, 0, "non-added aura updates must not create buff sightings")
assertEqual(publishes, 0, "non-added aura updates must not publish")
assertEqual(sortInvalidations, 0, "non-added aura updates must not invalidate sorting")
Detection.OnPlayerAura("player", { addedAuras = { fresh, old } })
assertEqual(#calls, 2, "only newly added aura records should be inspected")
assertEqual(calls[1], fresh, "first added aura was not processed")
assertEqual(calls[2], old, "second added aura was not processed")
assertEqual(publishes, 1, "one fresh caster should cause one immediate publish")
assertEqual(sortInvalidations, 1, "one fresh caster should invalidate sorting once")
assertEqual(Detection.ScanPlayerHelpfulCasters, nil, "legacy active-aura full scan must be removed")
print("PASS: newly added helpful aura detection tests")
