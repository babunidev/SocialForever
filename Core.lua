-- Social Forever
-- Nearby players for questing groups, and a memory of who you liked grouping with.
-- Built for World of Warcraft: Forever 1.60.1 (Interface 16001).

SocialForever = SocialForever or {}
local SF = SocialForever

SF.Const = SF.Const or {}
SF.State = SF.State or {}
SF.Util = SF.Util or {}
SF.Memory = SF.Memory or {}
SF.Group = SF.Group or {}
SF.Detection = SF.Detection or {}
SF.Sharing = SF.Sharing or {}
SF.UI = SF.UI or {}
SF.Events = SF.Events or {}

local C = SF.Const
local S = SF.State
local Util = SF.Util

C.ADDON = "SocialForever"
C.PREFIX = "SocialForever"
C.VISIBLE_ROWS = 5
C.ROW_HEIGHT = 24
-- How many player rows the list can hold (Nearby or Zone tab). Zone still
-- harvests up to 200 from General, then keeps the best 100 after sorting.
C.MAX_ROWS = 100
C.ZONE_LIST_PLUS = 100
C.FRAME_WIDTH = 280
C.FRAME_HEIGHT = 220
C.MAX_YARDS = 50
-- Nearby sightings expire unless presence is reconfirmed. A buff is one meeting
-- and then uses SEEN_TTL; BUFF_TTL is kept so older notes still have a meaning.
C.SEEN_TTL = 90
C.SORT_EVERY = 3
C.ZONE_TTL = 600
-- After a zone change, keep other-zone names at least this long before purging.
C.ZONE_PURGE_DELAY = 30
-- After a subzone/area change outdoors, keep prior-area names at least this long.
C.AREA_PURGE_DELAY = 15
C.CHAT_TTL = 60
C.UNIT_TTL = 90
C.BUFF_TTL = 40
-- Seconds without a live unit token before a sighting is dropped.
C.STALE_TRACKABLE = 15
C.STALE_INTERACTION = 20
C.EMPTY_NEARBY = "No one nearby"
C.EMPTY_ZONE = "No one else listed in this zone yet."
C.EMPTY_TEXT = C.EMPTY_NEARBY
C.MAX_ORIGINS = 12
C.ORIGIN_LABELS = {
    target = "Your target",
    mouseover = "Hovered / mouseover",
    focus = "Focus",
    soft_target = "Soft target",
    nameplate = "Visible nameplate",
    group = "Group member nearby",
    tracked_target = "Tracked unit",
    interaction = "Interaction target",
    chat = "Local chat / emote",
    crafting = "Crafting",
    fighting = "Fighting",
    helpful_aura = "Buff",
    resurrection = "Resurrection",
    trade = "Trade",
    duel = "Duel",
    opening = "Opening / loot activity",
    nearby_activity = "Nearby activity",
}
C.MAX_SHARE = 8
C.HELLO_GAP = 300
C.SAME_MOB_COOLDOWN = 300
C.SAME_MOB_NEARBY_GRACE = 60
-- Familiar recognition thought: per-player cooldown (server time seconds).
C.RECOGNITION_COOLDOWN = 1200

C.PRESET_FLAGS = {
    "Really friendly",
    "Generous",
    "Weird",
    "Bad behavior",
}

C.COLOR_SCORE = { green = 1, yellow = 0, red = -1 }
C.COLOR_RGB = {
    green = { 0.35, 1, 0.45 },
    yellow = { 1, 0.86, 0.25 },
    red = { 1, 0.35, 0.30 },
}
-- Other-faction names: muted war / dusty red, not the bright mark-red.
C.ENEMY_FACTION_RGB = { 0.68, 0.38, 0.32 }
C.COLOR_LABEL = {
    green = "Green - group again",
    yellow = "Yellow - neutral",
    red = "Red - unpleasant",
}
C.WIRE_COLOR = { G = "green", Y = "yellow", R = "red" }
C.COLOR_WIRE = { green = "G", yellow = "Y", red = "R" }

C.ANCHORS = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true,
    LEFT = true, CENTER = true, RIGHT = true,
    BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}

C.PANEL_BACKDROP = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

C.FLAT_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
}

C.FADE_IN_TIME = 0.4
C.FADE_OUT_TIME = 3
C.MOVE_HALF = 0.8

S.nearby = {}
S.inZone = {}
S.peers = {}
S.lastMembers = {}
S.wasParty = false
S.armed = false
S.queue = {}
S.sendReady = false
S.helloAt = {}
S.helloReplyAt = {}
S.pushedAt = {}
S.lastPopupSig = ""
S.lastPopupAt = 0
S.tipToken = 0
S.sightings = {}
S.zoneSeen = {}
S.zoneRoster = {}
S.inviteState = {}
S.groupedBefore = {}
S.sortHold = { at = 0, near = {}, zone = {} }
S.listedKeys = {}
S.fadeInAt = {}
S.fadeOutAt = {}
S.fadeOutEntry = {}
S.moveWave = nil
S.moveKeys = {}
S.moveHeld = nil
S.lastShown = nil
S.trackedZone = nil
S.zonePurgeAt = nil
S.trackedArea = nil
S.areaPurgeAt = nil
S.friendNames = {}
S.combatLogSeen = 0
S.main = nil
S.popup = nil
S.menu = nil
S.settingsMenu = nil
S.listFrozen = false
S.listDirty = false
S.pinnedNearKey = nil
S.displayOrdered = nil
S.displayNearCount = 0
S.displayZoneCount = 0
S.listTab = "nearby"
S.sameMobInviteAt = {}
S.sameMobQueue = {}
S.sameMobPopup = nil
-- Plumbing state bundled to stay under the chunk local limit.
S.P = {
    publishSig = nil,
    maxFamiliarity = nil,
    groupByKey = {},
    groupByNorm = {},
    raidTicker = nil,
    combatGen = 0,
    harvestedGen = nil,
    meterPending = false,
    rosterPending = false,
    zoneRosterFull = false,
    shareRotate = 1,
    nameplateByUnit = {},
    staleTrackable = C.STALE_TRACKABLE,
    staleInteraction = C.STALE_INTERACTION,
    sameMobStamp = nil,
    sameMobPromptPending = false,
    meterAttempt = 0,
    -- Recognition: pending timer tokens keyed by player.
    recognitionToken = {},
    recognitionPending = {},
    recognitionCombatPending = {},
}

C.LOOK_UNITS = {
    "mouseover",
    "target",
    "focus",
    "softfriend",
    "softenemy",
    "softinteract",
    "targettarget",
    "mouseovertarget",
    "focustarget",
    "softfriendtarget",
    "softenemytarget",
    "softinteracttarget",
    "pettarget",
    "party1target",
    "party2target",
    "party3target",
    "party4target",
    "npc",
}

C.SKIP_WORDS = {
    you = true,
    your = true,
    someone = true,
    unknown = true,
    creates = true,
    create = true,
    created = true,
    performs = true,
    perform = true,
    has = true,
    hits = true,
    hit = true,
    crits = true,
    casts = true,
    cast = true,
    gains = true,
    misses = true,
    resists = true,
    dies = true,
}

C.MOB_UNITS = {
    "target",
    "mouseover",
    "focus",
    "softenemy",
    "softinteract",
    "npc",
    "targettarget",
    "mouseovertarget",
    "party1target",
    "party2target",
    "party3target",
    "party4target",
}

C.SEEN_RGB = {
    white = { 0.95, 0.95, 0.95 },
    blue = { 0.45, 0.7, 1 },
    purple = { 0.76, 0.45, 1 },
}

C.CITY_ZONES = {
    ironforge = true,
    ["stormwind city"] = true,
    stormwind = true,
    darnassus = true,
    orgrimmar = true,
    ["thunder bluff"] = true,
    undercity = true,
    ["the exodar"] = true,
    ["silvermoon city"] = true,
    ["shattrath city"] = true,
    dalaran = true,
}

-- Skyborne pick Alliance or Horde at creation, so they are not listed here.
C.FACTION_BY_RACE = {
    Human = "Alliance",
    Dwarf = "Alliance",
    NightElf = "Alliance",
    Gnome = "Alliance",
    Orc = "Horde",
    Troll = "Horde",
    Tauren = "Horde",
    Scourge = "Horde",
}

C.CRAFT_VERBS = {
    creates = true,
    create = true,
    created = true,
    performs = true,
    perform = true,
    performed = true,
}

-- One portrait per race+class when known; otherwise the race face.
-- Skyborne use flight / air-themed icons (no stock race portrait yet).
C.RACE_ICONS = {
    Human = "Interface\\Icons\\Achievement_Character_Human_Male",
    Dwarf = "Interface\\Icons\\Achievement_Character_Dwarf_Male",
    NightElf = "Interface\\Icons\\Achievement_Character_Nightelf_Male",
    Gnome = "Interface\\Icons\\Achievement_Character_Gnome_Male",
    Orc = "Interface\\Icons\\Achievement_Character_Orc_Male",
    Troll = "Interface\\Icons\\Achievement_Character_Troll_Male",
    Tauren = "Interface\\Icons\\Achievement_Character_Tauren_Male",
    Scourge = "Interface\\Icons\\Achievement_Character_Undead_Male",
    Undead = "Interface\\Icons\\Achievement_Character_Undead_Male",
    Skyborne = "Interface\\Icons\\Ability_Druid_FlightForm",
    Skyborn = "Interface\\Icons\\Ability_Druid_FlightForm",
}

-- Race+class overrides when a clearer combo icon exists.
C.RACE_CLASS_ICONS = {
    Human = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Human_Male",
        PALADIN = "Interface\\Icons\\Spell_Holy_AvengineWrath",
        HUNTER = "Interface\\Icons\\Ability_Hunter_SniperShot",
        ROGUE = "Interface\\Icons\\Ability_Stealth",
        PRIEST = "Interface\\Icons\\Spell_Holy_DivineSpirit",
        MAGE = "Interface\\Icons\\Spell_Holy_MagicalSentry",
        WARLOCK = "Interface\\Icons\\Spell_Shadow_SummonImp",
    },
    Dwarf = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Dwarf_Male",
        PALADIN = "Interface\\Icons\\Spell_Holy_SealOfMight",
        HUNTER = "Interface\\Icons\\Ability_Hunter_RunningShot",
        ROGUE = "Interface\\Icons\\Ability_Rogue_Disguise",
        PRIEST = "Interface\\Icons\\Spell_Holy_WordFortitude",
        SHAMAN = "Interface\\Icons\\Spell_Nature_Lightning",
    },
    NightElf = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Nightelf_Male",
        HUNTER = "Interface\\Icons\\Ability_Hunter_Pet_Owl",
        ROGUE = "Interface\\Icons\\Ability_Druid_SupriseAttack",
        PRIEST = "Interface\\Icons\\Spell_Nature_Moonglow",
        DRUID = "Interface\\Icons\\Ability_Racial_ShadowMeld",
    },
    Gnome = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Gnome_Male",
        ROGUE = "Interface\\Icons\\Ability_Rogue_FleetFooted",
        MAGE = "Interface\\Icons\\Spell_Arcane_MindMastery",
        WARLOCK = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
        PRIEST = "Interface\\Icons\\Spell_Holy_PowerWordShield",
    },
    Orc = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Orc_Male",
        HUNTER = "Interface\\Icons\\Ability_Hunter_Pet_Wolf",
        ROGUE = "Interface\\Icons\\Ability_Rogue_BladeFlurry",
        SHAMAN = "Interface\\Icons\\Spell_Nature_BloodLust",
        MAGE = "Interface\\Icons\\Spell_Fire_Fireball02",
        WARLOCK = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
    },
    Troll = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Troll_Male",
        HUNTER = "Interface\\Icons\\Ability_Hunter_Pet_Raptor",
        ROGUE = "Interface\\Icons\\Ability_Rogue_DualWeild",
        PRIEST = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
        SHAMAN = "Interface\\Icons\\Spell_Nature_Lightning",
        MAGE = "Interface\\Icons\\Spell_Fire_Fireball",
        WARLOCK = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",
    },
    Tauren = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Tauren_Male",
        HUNTER = "Interface\\Icons\\Ability_Hunter_Pet_TallStrider",
        SHAMAN = "Interface\\Icons\\Spell_Nature_EarthBindTotem",
        DRUID = "Interface\\Icons\\Ability_Racial_BearForm",
    },
    Scourge = {
        WARRIOR = "Interface\\Icons\\Achievement_Character_Undead_Male",
        ROGUE = "Interface\\Icons\\Ability_Stealth",
        PRIEST = "Interface\\Icons\\Spell_Shadow_Shadowform",
        MAGE = "Interface\\Icons\\Spell_Frost_FrostBolt02",
        WARLOCK = "Interface\\Icons\\Spell_Shadow_DeathCoil",
        PALADIN = "Interface\\Icons\\Spell_Holy_SealOfMight",
    },
    Skyborne = {
        WARRIOR = "Interface\\Icons\\Ability_Warrior_Charge",
        HUNTER = "Interface\\Icons\\Ability_Hunter_Pet_DragonHawk",
        ROGUE = "Interface\\Icons\\Ability_Rogue_Sprint",
        MAGE = "Interface\\Icons\\Spell_Arcane_TeleportDarnassus",
        SHAMAN = "Interface\\Icons\\Spell_Nature_Cyclone",
        DRUID = "Interface\\Icons\\Ability_Druid_FlightForm",
    },
}

C.CLASS_ICONS = {
    WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
    PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    HUNTER = "Interface\\Icons\\ClassIcon_Hunter",
    ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
    PRIEST = "Interface\\Icons\\ClassIcon_Priest",
    SHAMAN = "Interface\\Icons\\ClassIcon_Shaman",
    MAGE = "Interface\\Icons\\ClassIcon_Mage",
    WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
    DRUID = "Interface\\Icons\\ClassIcon_Druid",
}

C.RACE_CLASS_ICONS.Undead = C.RACE_CLASS_ICONS.Scourge
C.RACE_CLASS_ICONS.Skyborn = C.RACE_CLASS_ICONS.Skyborne

--------------------------------------------------
-- Values the client may seal in combat
--------------------------------------------------

function Util.Secret(value)
    if type(issecretvalue) == "function" then
        local ok, secret = pcall(issecretvalue, value)
        if not ok or secret then
            return true
        end
    end
    if type(canaccessvalue) == "function" then
        local ok, allowed = pcall(canaccessvalue, value)
        if not ok or not allowed then
            return true
        end
    end
    return false
end

function Util.PlainString(value)
    if type(value) ~= "string" or Util.Secret(value) then
        return nil
    end
    if value == "" then
        return nil
    end
    return value
end

function Util.PlainBool(value)
    if type(value) ~= "boolean" or Util.Secret(value) then
        return nil
    end
    return value
end

function Util.PlainNumber(value)
    if type(value) ~= "number" or Util.Secret(value) then
        return nil
    end
    local ok = pcall(function()
        return value + 0
    end)
    if not ok then
        return nil
    end
    return value
end

function Util.Now()
    if type(GetServerTime) == "function" then
        return GetServerTime()
    end
    return time()
end

function Util.Trim(text)
    if type(text) ~= "string" then
        return ""
    end
    if strtrim then
        return strtrim(text)
    end
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Util.NormRealm(realm)
    realm = Util.PlainString(realm)
    if not realm then
        return nil
    end
    realm = realm:gsub("%s+", "")
    if realm == "" then
        return nil
    end
    return realm
end

-- Forever GUID/aura paths often return internal realm tokens (for example
-- CAMWOWEU4Realm10RP) that do not match GetNormalizedRealmName. Those must
-- never become part of a player key or appear in the UI.
function Util.LooksLikeRealmToken(segment)
    segment = Util.NormRealm(segment)
    if not segment then
        return false
    end
    local mine = Util.MyRealm()
    if mine and segment:lower() == mine:lower() then
        return true
    end
    if segment:find("[Rr]ealm") then
        return true
    end
    -- Long alphanumeric blobs with digits are Forever/connected-realm style IDs,
    -- not a second Forever character-name word.
    if #segment >= 10 and segment:match("^[%w]+$") and segment:find("%d") then
        return true
    end
    return false
end

-- Forever character names are one or two words. Strip any trailing realm token
-- from a hyphenated key so buff/GUID sightings merge with ordinary unit sightings.
function Util.NameOnlyKey(key)
    if type(key) ~= "string" then
        return nil
    end
    key = key:gsub("%s+", "-")
    local parts = {}
    for part in key:gmatch("[^%-]+") do
        parts[#parts + 1] = part
    end
    while #parts > 1 and Util.LooksLikeRealmToken(parts[#parts]) do
        parts[#parts] = nil
    end
    -- If a polluted key still has more than two name words, keep the Forever
    -- character name only (first two segments).
    if #parts > 2 then
        parts = { parts[1], parts[2] }
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, "-")
end

-- The client uses these until it knows who just joined. They are not characters.
function Util.IsPlaceholderName(name)
    if type(name) ~= "string" then
        return false
    end
    local lower = name:lower():gsub("%-", " "):gsub("%s+", " ")
    lower = lower:gsub("^%s+", ""):gsub("%s+$", "")
    if lower == "unknown" or lower == "unknown entity" then
        return true
    end
    if type(UNKNOWNOBJECT) == "string" then
        local token = UNKNOWNOBJECT:lower():gsub("%-", " "):gsub("%s+", " ")
        token = token:gsub("^%s+", ""):gsub("%s+$", "")
        if lower == token then
            return true
        end
    end
    return false
end

function Util.MakeKey(name, realm)
    name = Util.PlainString(name)
    if not name or Util.IsPlaceholderName(name) then
        return nil
    end
    -- Every Forever character has two names. They arrive as "First Second",
    -- "First-Second", or as name="First" plus the second name in the realm slot.
    name = Util.Trim(name):gsub("%s+", "-")
    name = Util.NameOnlyKey(name) or name
    if not name:find("-", 1, true) then
        local second = Util.NormRealm(realm)
        -- Our own realm and internal tokens (CAMWOWEU4Realm10RP) are not a second name.
        if second and not Util.LooksLikeRealmToken(second) then
            name = name .. "-" .. second
        end
    end
    if #name < 2 or #name > 24 then
        return nil
    end
    if name:find("[%c|%%%[%]]") or Util.IsPlaceholderName(name) then
        return nil
    end
    return name
end

function Util.SafeKey(key)
    if type(key) ~= "string" then
        return nil
    end
    key = key:gsub("%s+", "-")
    key = Util.NameOnlyKey(key) or key
    if #key < 2 or #key > 50 then
        return nil
    end
    if key:find("[%c|%%%[%]]") or Util.IsPlaceholderName(key) then
        return nil
    end
    return key
end

function Util.SameKey(a, b)
    if type(a) ~= "string" or type(b) ~= "string" then
        return false
    end
    a = Util.NameOnlyKey(a) or a
    b = Util.NameOnlyKey(b) or b
    return a:gsub("[%s%-]+", ""):lower() == b:gsub("[%s%-]+", ""):lower()
end

-- Cheap identity cache. Hot paths (Publish/Scan/IsMe) must not call UnitName
-- for every remembered player on every tick.
S.P.myKey = nil
S.P.myKeyFull = nil
S.P.myGuid = nil
S.P.myRealm = nil

function Util.InvalidateMeCache()
    S.P.myKey = nil
    S.P.myKeyFull = nil
    S.P.myGuid = nil
    S.P.myRealm = nil
    S.P.myFaction = nil
end

function Util.MyRealm()
    if S.P.myRealm then
        return S.P.myRealm
    end
    local realm
    if type(GetNormalizedRealmName) == "function" then
        realm = Util.NormRealm(GetNormalizedRealmName())
    end
    if not realm and type(GetRealmName) == "function" then
        realm = Util.NormRealm(GetRealmName())
    end
    S.P.myRealm = realm
    return realm
end

function Util.MyKey()
    if S.P.myKey then
        return S.P.myKey
    end
    local ok, name, realm = pcall(UnitName, "player")
    if not ok then
        return nil
    end
    local key = Util.MakeKey(name, realm)
    if key then
        S.P.myKey = key
        -- If our own second name sits in the realm slot and equals the realm
        -- name, MakeKey cannot join it; keep the joined form for IsMe too.
        local second = Util.NormRealm(realm)
        if not key:find("-", 1, true) and second then
            S.P.myKeyFull = key .. "-" .. second
        end
    end
    return key
end

function Util.MyGuid()
    if S.P.myGuid then
        return S.P.myGuid
    end
    if type(UnitGUID) ~= "function" then
        return nil
    end
    local ok, guid = pcall(UnitGUID, "player")
    if not ok then
        return nil
    end
    guid = Util.PlainString(guid)
    if guid then
        S.P.myGuid = guid
    end
    return guid
end

function Util.IsMyGuid(guid)
    guid = Util.PlainString(guid)
    local mine = Util.MyGuid()
    return guid ~= nil and mine ~= nil and guid == mine
end

function Util.IsMe(key)
    if type(key) ~= "string" or key == "" then
        return false
    end
    local mine = Util.MyKey()
    if not mine then
        return false
    end
    return Util.SameKey(key, mine) or (S.P.myKeyFull ~= nil and Util.SameKey(key, S.P.myKeyFull))
end

-- One-shot cleanup at login only. Never call from Publish/Scan/ValidatePresence:
-- walking SavedVariables with IsMe on every tick burned CPU.
function Util.PurgeSelfRecords()
    local mine = Util.MyKey()
    if not mine then
        return
    end
    local function scrub(map)
        if type(map) ~= "table" then
            return
        end
        local drop = {}
        for key in pairs(map) do
            if Util.SameKey(key, mine) then
                drop[#drop + 1] = key
            end
        end
        for i = 1, #drop do
            map[drop[i]] = nil
        end
    end
    if SF.db then
        scrub(SF.db.players)
        scrub(SF.db.remote)
        scrub(SF.db.ignored)
    end
    scrub(S.sightings)
    scrub(S.nearby)
    scrub(S.inZone)
    scrub(S.zoneSeen)
    scrub(S.zoneRoster)
    scrub(S.inviteState)
end

function Util.ValidColor(color)
    if color == "green" or color == "yellow" or color == "red" then
        return color
    end
    return nil
end

function Util.ValidStars(stars)
    stars = tonumber(stars)
    if not stars then
        return nil
    end
    stars = math.floor(stars)
    if stars < 1 or stars > 5 then
        return nil
    end
    return stars
end

function Util.NameSize()
    local size = SF.db and tonumber(SF.db.nameSize)
    if size == 18 or size == 20 then
        return size
    end
    return 16
end

function Util.RowHeight()
    return Util.NameSize() + 8
end

function Util.NameFont()
    local font, _, flags = GameFontHighlight:GetFont()
    if type(font) ~= "string" or font == "" then
        font = "Fonts\\FRIZQT__.TTF"
    end
    return font, Util.NameSize(), flags or ""
end

-- SetFont keeps only the Latin face. Chinese names then draw as empty boxes.
function Util.ApplyNameFont(fontString)
    if not fontString or not fontString.SetFontObject then
        return
    end
    fontString:SetFontObject(GameFontHighlight)
    local size = Util.NameSize()
    if fontString.SetTextScale then
        local _, base = GameFontHighlight:GetFont()
        base = tonumber(base)
        if not base or base <= 0 then
            base = 16
        end
        pcall(fontString.SetTextScale, fontString, size / base)
    elseif fontString.SetFontHeight then
        pcall(fontString.SetFontHeight, fontString, size)
    end
end

function Util.InitDB()
    if type(SocialForeverDB) ~= "table" then
        SocialForeverDB = {}
    end
    SF.db = SocialForeverDB
    local db = SF.db
    if type(db.players) ~= "table" then
        db.players = {}
    end
    -- One-shot at load. A party slot named "Unknown" used to be stored as a
    -- person and then rated when the real name arrived. Never walk this from
    -- Scan, Publish, or roster ticks.
    local function dropPlaceholders(map)
        if type(map) ~= "table" then
            return
        end
        local drop = {}
        for key in pairs(map) do
            if type(key) == "string" and Util.IsPlaceholderName(key) then
                drop[#drop + 1] = key
            end
        end
        for i = 1, #drop do
            map[drop[i]] = nil
        end
    end
    dropPlaceholders(db.players)
    dropPlaceholders(db.partyCounted)
    dropPlaceholders(db.remote)
    if type(db.remote) ~= "table" then
        db.remote = {}
    end
    if type(db.customFlags) ~= "table" then
        db.customFlags = {}
    end
    if db.partyId ~= nil and type(db.partyId) ~= "number" then
        db.partyId = nil
    end
    if type(db.partyCounted) ~= "table" then
        db.partyCounted = nil
    end
    if type(db.ignored) ~= "table" then
        db.ignored = {}
    end
    if db.listTab ~= "nearby" and db.listTab ~= "zone" then
        db.listTab = "nearby"
    end
    S.listTab = db.listTab
    -- Removed options are discarded harmlessly from older SavedVariables.
    db.sameMobAsk = nil
    db.autoInviteFriends = nil
    db.sameMobAutoInvite = nil
    if not db.migratedIgnoreFlags then
        local hasIgnoredName = false
        for _, existing in ipairs(db.customFlags) do
            if type(existing) == "string" and existing:lower() == "ignored" then
                hasIgnoredName = true
                break
            end
        end
        for key in pairs(db.ignored) do
            if type(key) == "string" then
                local rec = SF.Memory.EnsurePlayer(key)
                rec.color = "red"
                rec.flags["Ignored"] = true
                if not hasIgnoredName then
                    db.customFlags[#db.customFlags + 1] = "Ignored"
                    hasIgnoredName = true
                end
            end
        end
        db.migratedIgnoreFlags = true
    end
    -- Drop any flags that older builds stored from peers; flags are personal only.
    for _, bucket in pairs(db.remote) do
        if type(bucket) == "table" then
            for _, note in pairs(bucket) do
                if type(note) == "table" and note.flags ~= nil then
                    note.flags = nil
                end
            end
        end
    end
    SF.Memory.InvalidateMaxFamiliarity()
end

function Util.DistanceYards(unit)
    if type(UnitDistanceSquared) ~= "function" then
        return nil
    end
    local ok, distSq, checked = pcall(UnitDistanceSquared, unit)
    if not ok or Util.PlainBool(checked) ~= true then
        return nil
    end
    local sq = Util.PlainNumber(distSq)
    if not sq or sq < 0 then
        return nil
    end
    return math.sqrt(sq)
end

function Util.Interact(unit, index)
    if type(CheckInteractDistance) ~= "function" then
        return nil
    end
    -- CheckInteractDistance is combat-restricted on the live Forever client
    -- for this addon path. pcall does not prevent ADDON_ACTION_BLOCKED, so do
    -- not invoke the protected function at all while combat lockdown is active.
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        return nil
    end
    local ok, value = pcall(CheckInteractDistance, unit, index)
    if not ok then
        return nil
    end
    return Util.PlainBool(value)
end

function Util.UnitIdentity(unit)
    unit = Util.PlainString(unit) or unit
    if type(unit) ~= "string" then
        return nil
    end
    local selfOk, isSelf = pcall(UnitIsUnit, unit, "player")
    if selfOk and Util.PlainBool(isSelf) == true then
        return nil
    end
    local ok, name, realm = pcall(UnitName, unit)
    if not ok then
        return nil
    end
    local key = Util.MakeKey(name, realm)
    if not key or Util.IsMe(key) then
        return nil
    end
    local classFile
    local classOk, _, file = pcall(UnitClass, unit)
    if classOk then
        classFile = Util.PlainString(file)
    end
    local raceFile
    local raceOk, _, raceToken = pcall(UnitRace, unit)
    if raceOk then
        raceFile = Util.PlainString(raceToken)
    end
    local faction
    if type(UnitFactionGroup) == "function" then
        local factionOk, factionToken = pcall(UnitFactionGroup, unit)
        if factionOk then
            faction = Util.PlainString(factionToken)
            if faction ~= "Alliance" and faction ~= "Horde" then
                faction = nil
            end
        end
    end
    return key, classFile, raceFile, faction
end

function Util.NormRaceFile(raceFile)
    raceFile = Util.PlainString(raceFile)
    if not raceFile then
        return nil
    end
    if raceFile == "Undead" then
        return "Scourge"
    end
    if raceFile == "Skyborn" then
        return "Skyborne"
    end
    return raceFile
end

function Util.NormClassFile(classFile)
    classFile = Util.PlainString(classFile)
    if not classFile then
        return nil
    end
    return classFile:upper()
end

function Util.IdentityIcon(raceFile, classFile)
    raceFile = Util.NormRaceFile(raceFile)
    classFile = Util.NormClassFile(classFile)
    if raceFile and classFile then
        local byRace = C.RACE_CLASS_ICONS[raceFile]
        if byRace and byRace[classFile] then
            return byRace[classFile]
        end
    end
    if classFile and C.CLASS_ICONS[classFile] then
        return C.CLASS_ICONS[classFile]
    end
    if raceFile and C.RACE_ICONS[raceFile] then
        return C.RACE_ICONS[raceFile]
    end
    return nil
end

function Util.NormFaction(faction)
    faction = Util.PlainString(faction)
    if faction == "Alliance" or faction == "Horde" then
        return faction
    end
    return nil
end

function Util.MyFaction()
    if S.P.myFaction then
        return S.P.myFaction
    end
    if type(UnitFactionGroup) ~= "function" then
        return nil
    end
    local ok, faction = pcall(UnitFactionGroup, "player")
    if not ok then
        return nil
    end
    S.P.myFaction = Util.NormFaction(faction)
    return S.P.myFaction
end

function Util.FactionOf(key, entry)
    local faction = entry and Util.NormFaction(entry.faction) or nil
    if not faction and entry then
        local raceFile = Util.NormRaceFile(entry.race)
        faction = raceFile and C.FACTION_BY_RACE[raceFile] or nil
    end
    if not faction and key then
        local seen = S.sightings[key] or S.zoneSeen[key] or (S.inZone and S.inZone[key])
        if type(seen) == "table" then
            faction = Util.NormFaction(seen.faction)
            if not faction then
                local raceFile = Util.NormRaceFile(seen.race)
                faction = raceFile and C.FACTION_BY_RACE[raceFile] or nil
            end
        end
    end
    if not faction and key then
        local rec = SF.db and SF.db.players and SF.db.players[key]
        if type(rec) == "table" then
            faction = Util.NormFaction(rec.faction)
            if not faction then
                local raceFile = Util.NormRaceFile(rec.race)
                faction = raceFile and C.FACTION_BY_RACE[raceFile] or nil
            end
        end
    end
    return faction
end

function Util.IsOtherFaction(key, entry)
    local mine = Util.MyFaction()
    local theirs = Util.FactionOf(key, entry)
    return mine ~= nil and theirs ~= nil and mine ~= theirs
end
