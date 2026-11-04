SocialForever = nil

dofile("Core.lua")

local SF = SocialForever
local Util = SF.Util
local C = SF.Const

local function assertTrue(value, message)
    if not value then error(message, 2) end
end

local matrix = {
    Human = {"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","MAGE","WARLOCK"},
    Dwarf = {"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","SHAMAN"},
    NightElf = {"WARRIOR","HUNTER","ROGUE","PRIEST","DRUID"},
    Gnome = {"WARRIOR","ROGUE","MAGE","WARLOCK","PRIEST"},
    Orc = {"WARRIOR","HUNTER","ROGUE","SHAMAN","MAGE","WARLOCK"},
    Troll = {"WARRIOR","HUNTER","ROGUE","PRIEST","SHAMAN","MAGE","WARLOCK"},
    Tauren = {"WARRIOR","HUNTER","SHAMAN","DRUID"},
    Scourge = {"WARRIOR","ROGUE","PRIEST","MAGE","WARLOCK","PALADIN"},
    Skyborne = {"WARRIOR","HUNTER","ROGUE","DRUID","MAGE","SHAMAN"},
}

local tested = 0
for race, classes in pairs(matrix) do
    for _, class in ipairs(classes) do
        local icon = Util.IdentityIcon(race, class)
        assertTrue(type(icon) == "string" and icon ~= "", race .. " " .. class .. " returned no icon")
        tested = tested + 1
    end
end

assertTrue(Util.IdentityIcon("Dwarf","SHAMAN") ~= C.RACE_ICONS.Dwarf, "Dwarf Shaman fell back to race icon")
assertTrue(Util.IdentityIcon("Gnome","PRIEST") ~= C.RACE_ICONS.Gnome, "Gnome Priest fell back to race icon")
assertTrue(Util.IdentityIcon("Scourge","PALADIN") ~= C.RACE_ICONS.Scourge, "Undead Paladin fell back to race icon")
assertTrue(Util.IdentityIcon("Skyborne","MAGE"), "Skyborne Mage missing")
assertTrue(Util.IdentityIcon("Skyborne","SHAMAN"), "Skyborne Shaman missing")
assertTrue(Util.IdentityIcon("Undead","PALADIN") == Util.IdentityIcon("Scourge","PALADIN"), "Undead alias mismatch")
assertTrue(Util.IdentityIcon("Human","SHAMAN") == C.CLASS_ICONS.SHAMAN, "unknown combination did not prefer class fallback")
assertTrue(Util.IdentityIcon("Human","NOTACLASS") == C.RACE_ICONS.Human, "unknown class did not fall back to race")

assertTrue(tested == 52, "Forever matrix expected 52 combinations, got " .. tested)
print("PASS: race/class icon tests (" .. tested .. " combinations)")