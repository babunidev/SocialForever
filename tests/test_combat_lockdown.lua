local combat = true
local touchedSecureRow = false
local stoppedAnimation = false

function wipe(t)
    for k in pairs(t) do t[k] = nil end
end

function InCombatLockdown()
    return combat
end

function GetTime()
    return 100
end

SocialForever = nil
dofile("Core.lua")
dofile("Memory.lua")
dofile("Group.lua")
dofile("UI.lua")

local SF = SocialForever
local S = SF.State
local UI = SF.UI

S.main = {
    rows = {
        {
            SetHeight = function()
                touchedSecureRow = true
                error("secure row geometry touched during combat")
            end,
        },
    },
    fadingPaint = false,
    SetScript = function(_, name, fn)
        if name == "OnUpdate" and fn == nil then
            stoppedAnimation = true
        end
    end,
}

S.listDirty = false
UI.RefreshList()
assert(S.listDirty == true, "combat RefreshList should defer and mark list dirty")
assert(touchedSecureRow == false, "combat RefreshList touched secure row geometry")

S.listDirty = false
UI.OnMainAnimUpdate()
assert(S.listDirty == true, "combat animation should mark list dirty")
assert(stoppedAnimation == true, "combat animation should stop its OnUpdate")
assert(touchedSecureRow == false, "combat animation touched secure row")

print("PASS: combat lockdown defers secure list-row mutations")
