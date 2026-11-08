local combat = true
local touchedSecureRow = false
local stoppedAnimation = false
local interactCalls = 0
local invitedName = nil
local paintedName = nil
local overlayShown = false

function wipe(t)
    for k in pairs(t) do t[k] = nil end
end

function InCombatLockdown()
    return combat
end

function CheckInteractDistance()
    interactCalls = interactCalls + 1
    error("CheckInteractDistance must not be called in combat")
end

function GetTime()
    return 100
end

function GetServerTime()
    return 1000
end

function GetRealmName()
    return "ForeverRealm"
end

function GetNormalizedRealmName()
    return "ForeverRealm"
end

function GetZoneText()
    return "Dun Morogh"
end

function GetSubZoneText()
    return "Kharanos"
end

function UnitName(unit)
    if unit == "player" then
        return "Localplayer"
    end
end

C_PartyInfo = {
    InviteUnit = function(name)
        invitedName = name
    end,
}

SocialForeverDB = {
    players = {},
    remote = {},
    customFlags = {},
    ignored = {},
    migratedIgnoreFlags = true,
    listTab = "nearby",
}

SocialForever = nil
dofile("Core.lua")
dofile("Memory.lua")
dofile("Group.lua")
dofile("UI.lua")

local SF = SocialForever
local S = SF.State
local UI = SF.UI
local Util = SF.Util
SF.Util.InitDB()

assert(Util.Interact("target", 2) == nil, "combat interaction fallback should be nil")
assert(interactCalls == 0, "CheckInteractDistance was invoked during combat")

local function noop() end
local inviteLabel = { SetText = noop, SetTextColor = noop }
local invite = {
    label = inviteLabel,
    SetBackdropColor = noop,
    SetBackdropBorderColor = noop,
    Show = noop,
    Hide = noop,
}
local combatRow = {
    invite = invite,
    mark = { SetText = noop, SetTextColor = noop },
    name = {
        SetText = function(_, text) paintedName = text end,
        SetTextColor = noop,
    },
    SetHeight = noop,
    ClearAllPoints = noop,
    SetPoint = noop,
    Show = function() overlayShown = true end,
    Hide = noop,
}
local empty = { SetText = noop, Show = noop, Hide = noop }
local cover = {
    empty = empty,
    Show = function() overlayShown = true end,
    Hide = noop,
}

S.main = {
    -- This represents the protected target row underneath the combat overlay.
    rows = {
        {
            SetHeight = function()
                touchedSecureRow = true
                error("protected row geometry touched during combat")
            end,
        },
    },
    combatCover = cover,
    combatRows = { combatRow },
    list = { GetHeight = function() return SF.Const.ROW_HEIGHT end },
    fadingPaint = false,
    SetScript = function(_, name, fn)
        if name == "OnUpdate" and fn == nil then
            stoppedAnimation = true
        end
    end,
}
S.nearby = {
    Combatmouse = {
        key = "Combatmouse",
        bucket = 3,
        at = 100,
        ttl = SF.Const.SEEN_TTL,
        origins = { "mouseover" },
    },
}
S.displayOrdered = {}
S.listDirty = false

UI.RefreshList()
assert(overlayShown == true, "combat overlay did not paint")
assert(paintedName == "Combatmouse", "combat mouseover was not painted immediately")
assert(touchedSecureRow == false, "combat refresh touched protected target-row geometry")
assert(S.listDirty == true, "combat refresh should still request a full post-combat repaint")

assert(UI.DirectInvite("Combatmouse") == true, "direct combat invite path failed")
assert(invitedName == "Combatmouse", "combat invite used the wrong player name")
assert(S.inviteState.Combatmouse == "invited", "combat invite state was not recorded")
assert(touchedSecureRow == false, "combat invite refresh touched protected target-row geometry")

S.listDirty = false
UI.OnMainAnimUpdate()
assert(S.listDirty == true, "combat animation should mark list dirty")
assert(stoppedAnimation == true, "combat animation should stop its OnUpdate")
assert(touchedSecureRow == false, "combat animation touched protected row")

print("PASS: combat overlay paints newcomers, direct invite works, protected rows stay untouched")
