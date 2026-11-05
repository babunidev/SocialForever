-- Single ordinary list regression: mock Forever APIs, not live-client verification.
function wipe(t) for k in pairs(t) do t[k] = nil end end

local combat = true
local invitedName
local interacted = 0
local now = 100
function InCombatLockdown() return combat end
function GetTime() return now end
function GetServerTime() return 51000 end
function GetRealmName() return "ForeverRealm" end
function GetNormalizedRealmName() return "ForeverRealm" end
function GetZoneText() return "Dun Morogh" end
function GetSubZoneText() return "Kharanos" end
function UnitName(unit)
    if unit == "player" then return "Local", "Player" end
    if unit == "target" then return nil end
end
function CheckInteractDistance()
    interacted = interacted + 1
    error("protected distance query attempted in combat")
end
C_PartyInfo = { InviteUnit = function(name) invitedName = name end }
C_Timer = { After = function(_, cb) cb() end }
GameFontHighlight = { GetFont = function() return "Fonts\\FRIZQT__.TTF", 16, "" end }
GameTooltip = { IsShown = function() return false end, Hide = function() end }

SocialForever = nil
SocialForeverDB = {
    players = {}, remote = {}, customFlags = {}, ignored = {},
    migratedIgnoreFlags = true, listTab = "nearby",
}
dofile("Core.lua")
dofile("Memory.lua")
dofile("Group.lua")
dofile("UI.lua")

local SF, S, UI = SocialForever, SocialForever.State, SocialForever.UI
SF.Util.InitDB()

local function el()
    return {
        shown = false, text = nil,
        SetText = function(self, value) self.text = value end,
        SetTextColor = function() end,
        SetFont = function() end,
        SetWidth = function() end,
        SetHeight = function() end,
        SetPoint = function() end,
        ClearAllPoints = function() end,
        SetAlpha = function() end,
        SetBackdropColor = function() end,
        SetBackdropBorderColor = function() end,
        SetMinMaxValues = function() end,
        SetValue = function() end,
        Show = function(self) self.shown = true end,
        Hide = function(self) self.shown = false end,
        IsShown = function(self) return self.shown end,
        IsMouseOver = function() return false end,
    }
end

local function tab()
    local t = el()
    t.label = el()
    return t
end

local rows = {}
for i = 1, 3 do
    local row = el()
    row.mark, row.name, row.highlight = el(), el(), el()
    row.invite = el()
    row.invite.label = el()
    row.PaintTarget = function() end
    -- No secure attributes or secure frame geometry in this row.
    rows[i] = row
end
local scripts = {}
S.main = {
    rows = rows, scrollOffset = 0, fadingPaint = false,
    list = { GetWidth = function() return 260 end, GetHeight = function() return 75 end },
    empty = el(),
    bar = el(),
    tabNearby = tab(), tabZone = tab(),
    IsShown = function() return true end,
    GetScript = function(_, name) return scripts[name] end,
    SetScript = function(_, name, script) scripts[name] = script end,
}
S.nearby = {
    ["Combat-Mouse"] = {
        key = "Combat-Mouse", bucket = 3, at = now, ttl = 180,
        area = "Kharanos", zone = "Dun Morogh", origins = {"mouseover"},
    },
}
S.inZone = {}
S.displayOrdered = {}
S.listDirty = false

assert(SF.Util.Interact("target", 2) == nil)
assert(interacted == 0, "combat attempted protected distance query")

UI.RefreshList({force = true, skipMove = true})
assert(rows[1].key == "Combat-Mouse", "regular row did not show a combat sighting")
assert(rows[1].name.text == "Combat Mouse", "regular name row did not paint")
assert(rows[1].shown == true, "ordinary combat row was hidden")
assert(rows[1].invite.shown == true, "ordinary Invite button unavailable during combat")
assert(S.main.combatCover == nil and S.main.combatRows == nil,
    "legacy duplicate combat list still exists")

-- Newly discovered characters replace entries in the exact same row table.
S.nearby["Combat-Mouse"] = nil
S.nearby["Next-Person"] = {
    key = "Next-Person", bucket = 1, at = now + 1, ttl = 180,
    area = "Kharanos", zone = "Dun Morogh", origins = {"mouseover"},
}
now = now + 1
UI.RefreshList({force = true, skipMove = true})
assert(rows[1].key == "Next-Person", "combat failed to update the same row")
assert(rows[1].name.text == "Next Person", "combat left a stale label")
assert(UI.DirectInvite("Next-Person") == true, "ordinary combat invite failed")
assert(invitedName == "Next Person", "combat invite did not use both names")
assert(S.inviteState["Next-Person"] == "invited", "invite state was not updated")

combat = false
UI.RefreshList({force = true, skipMove = true})
assert(rows[1].key == "Next-Person", "leaving combat replaced the list")
assert(rows[1].name.text == "Next Person", "leaving combat changed the row text")

print("PASS: same ordinary rows repaint in/out of combat, invite remains clickable")
