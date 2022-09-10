aura_env.inspectLib = LibStub:GetLibrary("LibGroupInSpecT-1.1",true)

aura_env.options = {
    readyTextGreen = true,
}

aura_env.needInspect = {}
aura_env.inspected = {}
aura_env.npcIDs = {}
aura_env.spellIDs = {}

aura_env.debugFlag = 1

aura_env.trackedSpells = { --[spellId]=cooldown
    [47528]  = {default=15}, --Mind Freeze
    [106839] = {default=15}, --Skull Bash
    [78675]  = {default=60}, --Solar Beam
    [183752] = {default=15}, --Disrupt
    [147362] = {default=24}, --Counter Shot
    [187707] = {default=15}, --Muzzle
    [2139]   = {default=24}, --Counter Spell
    [116705] = {default=15}, --Spear Hand Strike
    [96231]  = {default=15}, --Rebuke
    [1766]   = {default=15}, --Kick
    [57994]  = {default=12}, --Wind Shear
    [6552]   = {default=15}, --Pummel
    [119910] = {default=24}, --Spell Lock Command Demon
    [19647]  = {default=24}, --Spell Lock if used from pet bar
    [132409] = {default=24}, --Spell Lock Command Demon Ability
    [89466]  = {default=24}, --Felguard / Wrathguard Pet Axe Toss
    [89766]  = {default=24}, --Felguard / Wrathguard Pet Axe Toss if used from pet bar
    [89466]  = {default=24}, --Felguard / Wrathguard Pet Axe Toss Command Demon Ability
    [15487]  = {default=45,talents={[23137]=30}},--Silence 30 with talent   
}

aura_env.specialItrSpells = {
    --DK
    [250] = {spellID = 47528, priority = 0},
    [251] = {spellID = 47528, priority = 0},
    [252] = {spellID = 47528, priority = 0},
    
    --DH
    [577] = {spellID = 183752, priority = 0},
    [581] = {spellID = 183752, priority = 0},
    
    --DRUID
    [102] = {spellID = 78675, priority = 7},
    [103] = {spellID = 106839, priority = 0},
    [104] = {spellID = 106839, priority = 0},
    
    --HUNTER
    [253] = {spellID = 147362, priority = 0},
    [254] = {spellID = 147362, priority = 0},
    [255] = {spellID = 187707, priority = 0},
    
    --MAGE
    [62] = {spellID = 2139, priority = 0},
    [63] = {spellID = 2139, priority = 0},
    [64] = {spellID = 2139, priority = 0},
    
    --MONK
    [268] = {spellID = 116705, priority = 0},
    [269] = {spellID = 116705, priority = 0},
    
    --PALADIN
    [66] = {spellID = 96231, priority = 0},
    [70] = {spellID = 96231, priority = 0},
    
    --PRIEST
    [258] = {spellID = 15487, priority = 6},
    
    --ROGUE
    [259] = {spellID = 1766, priority = 0},
    [260] = {spellID = 1766, priority = 0},
    [261] = {spellID = 1766, priority = 0},
    
    --SHAMAN
    [262] = {spellID = 57994, priority = 1},
    [263] = {spellID = 57994, priority = 1},
    [264] = {spellID = 57994, priority = 5},
    
    --WARLOCK
    [265] = {spellID = 119910, priority = 0},
    [266] = {spellID = 119910, priority = 0},
    [267] = {spellID = 119910, priority = 0},
    
    --WARRIOR
    [71] = {spellID = 6552, priority = 0},
    [72] = {spellID = 6552, priority = 0},
    [73] = {spellID = 6552, priority = 0},
}

--https://wago.io/profile/asakawa
--usage:
--for unit in aura_env.GroupMembers() do
-- --do stuff
--end
function aura_env.GroupMembers()
    local unit = 'party'
    local numGroupMembers = GetNumSubgroupMembers()
    local i = 0
    return function()
        local ret
        if i == 0 and unit == 'party' then 
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + 1
        return ret
    end
end

--get talent adjusted duration
function aura_env.getDuration(spellId,sourceGUID)
    local info = aura_env.inspectLib:GetCachedInfo(sourceGUID)
    local data = aura_env.trackedSpells[spellId]
    if info then
        for talentIdx,_ in pairs(info.talents) do
            if data.talents and data.talents[talentIdx] then return data.talents[talentIdx] end
        end
    end    
    return data.default
end

--returns class colored for valid units
function aura_env.getColored(unit)
    if not unit then return nil end
    local function DecimalToHex(r,g,b)
        return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
    end
    local playername = UnitName(unit)
    local playerclass,PLAYERCLASS = UnitClass(unit)
    if not PLAYERCLASS then return unit end
    local classcolor = RAID_CLASS_COLORS[PLAYERCLASS]
    if not classcolor then return unit end
    local r,g,b = classcolor.r,classcolor.g,classcolor.b
    if UnitIsDeadOrGhost(unit) then r,g,b = 0.5,0.5,0.5 end        
    local classcolorhex = DecimalToHex(r,g,b)
    return classcolorhex..playername.."|r"
end

function aura_env.debugPrint(logStr)
    if aura_env.debugFlag == 1 and logStr ~=nil then
        print(logStr)
    end
end

function aura_env.getAuraByID(unit, spellID, filter)
    local index = 1
    local spell

    while true do
        _,_,_,_,_,_,_,_,_,spell = UnitAura(unit, index, filter)
        if spell == nil then
            return false
        end
        
        if spell == spellID then
            return true
        end
    
    end

end

for i,v in pairs(aura_env.specialItrSpells) do
    local role
    local intrSpellID
    
    role = GetSpecializationRoleByID(i)
    --aura_env.debugPrint("|cffff0000"..i.." "..role.."|r")
    
    if v.priority == 0 then
        if role == "TANK" then
            v.priority = 2
        else 
            intrSpellID = v.spellID
            if aura_env.trackedSpells[intrSpellID].default == 15 then
                v.priority = 3
            else if intrSpellID == 2139 then
                v.priority = 4
            end
                v.priority = 5
            end
        end
    end
    --aura_env.debugPrint(v.priority.." "..v.spellID)
end

for match in aura_env.config.npcID:gmatch("%d+") do
    aura_env.npcIDs[match] = true
end

for match in aura_env.config.spellID:gmatch("%d+") do
    aura_env.spellIDs[match] = true
end