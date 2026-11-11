local combat = true
local interactCalls = 0
local invitedName = nil
local paintedName = nil
local inviteShown = nil
local rowShown = nil
local rowResized = false
local targetCalls = 0
local stoppedAnimation = false

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

function TargetUnit()
    targetCalls = targetCalls + 1
    error("TargetUnit must not be called in combat")
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
        return "Localplayer", "ForeverRealm"
    end
end

function UnitFactionGroup(unit)
    if unit == "player" then
        return "Alliance"
    end
end

C_PartyInfo = {
    InviteUnit = function(name)
        invitedName = name
    end,
}

C_Timer = { After = function() end }

GameFontHighlight = {
    GetFont = function()
        return "Fonts\\FRIZQT__.TTF", 16, ""
    end,
}

GameTooltip = {
    IsShown = function() return false end,
    GetOwner = function() return nil end,
    Hide = function() end,
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
Util.InvalidateMeCache()

local chat = {}
DEFAULT_CHAT_FRAME = {
    AddMessage = function(_, text)
        chat[#chat + 1] = text
    end,
}

assert(Util.Interact("target", 2) == nil, "combat interaction fallback should be nil")
assert(interactCalls == 0, "CheckInteractDistance was invoked during combat")
assert(UI.RefreshCombatList == nil, "combat overlay painter should be gone")
assert(UI.TryTarget("Combatmouse") == false, "name click should not target during combat")
assert(targetCalls == 0, "TargetUnit was invoked during combat")
assert(chat[1] == "Targeting players isn't allowed in combat.", "combat name click did not explain itself in chat")
combat = false
assert(UI.TryTarget("Combatmouse") == false, "name click must not call the protected targeting API out of combat")
assert(targetCalls == 0, "TargetUnit was invoked out of combat")
combat = true

local function noop() end
local function fontString(capture)
    return {
        SetText = function(_, text)
            if capture then
                paintedName = text
            end
        end,
        SetTextColor = noop,
        SetFont = noop,
        SetWidth = noop,
        SetPoint = noop,
        SetFontObject = noop,
        Hide = noop,
        Show = noop,
        ClearAllPoints = noop,
        SetSize = noop,
        SetTexture = noop,
        SetVertexColor = noop,
    }
end

local invite = {
    label = { SetText = noop, SetTextColor = noop },
    SetBackdropColor = noop,
    SetBackdropBorderColor = noop,
    SetAlpha = noop,
    ClearAllPoints = noop,
    SetPoint = noop,
    IsShown = function() return inviteShown == true end,
    IsMouseOver = function() return false end,
    Show = function() inviteShown = true end,
    Hide = function() inviteShown = false end,
}

local row = {
    invite = invite,
    mark = fontString(false),
    name = fontString(true),
    levelText = fontString(false),
    identity = fontString(false),
    highlight = { Show = noop, Hide = noop },
    SetHeight = function() rowResized = true end,
    SetWidth = noop,
    SetAlpha = noop,
    ClearAllPoints = noop,
    SetPoint = noop,
    PaintTarget = noop,
    Show = function() rowShown = true end,
    Hide = function() rowShown = false end,
    IsShown = function() return rowShown == true end,
    IsMouseOver = function() return false end,
}

local function makeTab()
    return {
        label = { SetText = noop, SetTextColor = noop },
        SetBackdropColor = noop,
        SetBackdropBorderColor = noop,
    }
end

local onUpdate
S.main = {
    rows = { row },
    list = {
        GetHeight = function() return SF.Const.ROW_HEIGHT end,
        GetWidth = function() return 250 end,
    },
    empty = { SetText = noop, Show = noop, Hide = noop },
    bar = {
        lock = false,
        Show = noop,
        Hide = noop,
        SetMinMaxValues = noop,
        SetValue = noop,
        IsShown = function() return false end,
        IsMouseOver = function() return false end,
    },
    tabNearby = makeTab(),
    tabZone = makeTab(),
    scrollOffset = 0,
    fadingPaint = false,
    IsShown = function() return true end,
    GetScript = function(_, name)
        if name == "OnUpdate" then
            return onUpdate
        end
    end,
    SetScript = function(_, name, fn)
        if name == "OnUpdate" then
            onUpdate = fn
            if fn == nil then
                stoppedAnimation = true
            end
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
S.inZone = {}
S.displayOrdered = {}
S.listDirty = false

UI.RefreshList()
assert(rowShown == true, "combat refresh did not keep the same row visible")
assert(rowResized == true, "combat refresh did not update the same row")
assert(paintedName == "Combatmouse", "combat mouseover was not painted on the same list")
assert(inviteShown == true, "combat invite button was hidden for an invitable player")
assert(S.main.combatCover == nil, "combat refresh built a second list cover")
assert(S.listDirty ~= true, "combat refresh should paint in place instead of deferring a second list")

assert(UI.DirectInvite("Combatmouse") == true, "direct combat invite path failed")
assert(invitedName == "Combatmouse", "combat invite used the wrong player name")
assert(S.inviteState.Combatmouse == "invited", "combat invite state was not recorded")
assert(paintedName == "Combatmouse", "combat invite refresh left the same list")

wipe(S.fadeInAt)
wipe(S.fadeOutAt)
S.moveWave = nil
UI.OnMainAnimUpdate()
assert(stoppedAnimation == true, "idle combat animation should stop its OnUpdate")
assert(rowShown == true, "idle combat animation hid the list row")

inviteShown = nil
S.nearby = {
    ["Orc-Raider"] = {
        key = "Orc-Raider", bucket = 3, at = 100, ttl = SF.Const.SEEN_TTL,
        faction = "Horde", origins = { "mouseover" },
    },
}
invitedName = nil
UI.RefreshList()
assert(inviteShown == false, "other-faction player must not get an invite button")
assert(UI.DirectInvite("Orc-Raider") == false, "other-faction direct invite must be refused")
assert(invitedName == nil, "other-faction invite reached InviteUnit")
assert(paintedName == "Orc Raider", "other-faction name was not painted on the same list")

local order = {}
function UnregisterStateDriver(_, state)
    order[#order + 1] = "unregister:" .. tostring(state)
end
function RegisterStateDriver(_, state, driver)
    order[#order + 1] = "register:" .. tostring(state) .. ":" .. tostring(driver)
end
combat = false
local shown = 0
local fake = {
    visibilityDriver = "[combat] hide; show",
    Show = function()
        shown = shown + 1
        order[#order + 1] = "show"
    end,
    Hide = function()
        order[#order + 1] = "hide"
    end,
}
UI.SetTargetDriver(fake, true)
assert(shown == 1, "target click stayed hidden when already out of combat")
assert(order[#order] == "register:visibility:[combat] hide; show", "target click driver was not armed after showing")
UI.SetTargetDriver(fake, true)
assert(shown == 2, "arming the same target click again skipped Show")
combat = true
UI.SetTargetDriver(fake, true)
assert(shown == 2, "combat was allowed to change target click visibility")

print("PASS: one list paints during combat, direct invite works, name click does not target, no other-faction invite")
