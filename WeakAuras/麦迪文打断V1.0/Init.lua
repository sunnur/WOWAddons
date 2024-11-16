aura_env.inspectLib = LibStub:GetLibrary("LibGroupInSpecT-1.1",true)

aura_env.options = {
    readyTextGreen = true,
}

aura_env.needInspect = {}
aura_env.inspected = {}
aura_env.npcIDs = {}
aura_env.spellIDs = {}

aura_env.debugFlag = 0

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
    [89766]  = {default=24}, --Felguard / Wrathguard Pet Axe Toss if used from pet bar
    [119914]  = {default=24}, --Felguard / Wrathguard Pet Axe Toss Command Demon Ability
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
    [102] = {spellID = 78675, priority = 8},
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
    [258] = {spellID = 15487, priority = 7},
    
    --ROGUE
    [259] = {spellID = 1766, priority = 0},
    [260] = {spellID = 1766, priority = 0},
    [261] = {spellID = 1766, priority = 0},
    
    --SHAMAN
    [262] = {spellID = 57994, priority = 1},
    [263] = {spellID = 57994, priority = 1},
    [264] = {spellID = 57994, priority = 6},
    
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
    
    if (unit == nil) or (spellID == nil) then
        return false,0,nil
    end
    
    while true do
        local _,_,count,_,_,_,_,_,_,spell = UnitAura(unit, index, filter)
        if spell == nil then
            return false,0,nil
        end
        
        if spell == spellID then
            return true,count,spell
        end
        index = index + 1
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
            elseif intrSpellID == 2139 then
                v.priority = 4
            else
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

function aura_env.labelUpdate(spellId, unit, playSound, state)
    
    local sourceGUID = UnitGUID(unit)
    local memberInfo = {}
    memberInfo.priority = 9
    memberInfo.unit = 0
    
    local nextMemberInfo = {}
    nextMemberInfo.priority = 9
    nextMemberInfo.unit = 0
    
    local interruptList = {}
    local endTime
    local castTime = 3

    endTime = GetTime() + castTime
    for i,v in pairs(aura_env.inspected) do
        local flag = aura_env.getAuraByID(v.unit, 227592, "HARMFUL")
        if (v.expirationTime < (endTime + castTime - 0.3)) and (UnitIsDead(v.unit) == false) and flag == false then
            table.insert(interruptList, v)
        end
    end
    
    table.sort(interruptList,function (a,b)
            if a.expirationTime ~= b.expirationTime then
                if a.expirationTime < b.expirationTime then
                    return true
                else
                    return false
                end
            else
                if(a.priority < b.priority)then
                    return true
                elseif a.priority == b.priority then
                    if UnitGUID(a.unit) < UnitGUID(b.unit) then
                        return true
                    end
                end
            end

            return false
    end)
    
    memberInfo = interruptList[1]
    
    if memberInfo and memberInfo.expirationTime > (endTime - 0.3) then
        nextMemberInfo = interruptList[1]
        memberInfo = nil
    else
        memberInfo = interruptList[1]
        nextMemberInfo = interruptList[2]
    end
    
    local needInterrupt = 1
    
    if spellId == 227628 then
        local flag,debuffStack = aura_env.getAuraByID(unit.."target", 227644 ,"HARMFUL")
        if (flag == false) or (debuffStack < aura_env.config.debuffMaxStack) then
            needInterrupt = 0
        end
    end
    --228249
    if (spellId == 227615) then
        local spellTarget
        for tar in WA_IterateGroupMembers() do
            local flag = aura_env.getAuraByID(tar, 228249, "HARMFUL")
            if flag then
                spellTarget = tar
                break
            end
            spellTarget = nil
        end
        
        local unitTargetGUID
        local roleSpec
        
        if spellTarget then
            unitTargetGUID = UnitGUID(spellTarget)
        end
        
        if unitTargetGUID and aura_env.inspected[unitTargetGUID]then
            roleSpec = aura_env.inspected[unitTargetGUID].specialization
            
            if GetSpecializationRole(roleSpec) == "TANK" then
                needInterrupt = 0
            end
        end
        
        if state and (aura_env.config.purgatoryIntr == false) then
            local flag = aura_env.getAuraByID(spellTarget, 228958, "HARMFUL")
            if (GetTime() > state.dangerousTime) and flag == false then
                needInterrupt = 0
            end
        end
    end
    
    local nameString
    local nextString
    local shoutString = ""
    
    if needInterrupt == 1 then
        if memberInfo and memberInfo.unit ~= 0 then
            nameString = aura_env.getColored(memberInfo.unit)
            shoutString = UnitName(memberInfo.unit).." 打断"
            if nameString then
                nameString = nameString.." 打断"
            end

            if playSound and (memberInfo.unit == "player") and (aura_env.config.soundWarning == true) and (UnitGUID("playertarget") == sourceGUID) then
                PlaySoundFile("Interface\\AddOns\\WeakAuras\\Media\\Sounds\\ErrorBeep.ogg", "MASTER")
            end
        else
            nameString = "|cffff0000无法打断|r"
            shoutString = "无法打断"
        end
        
        if nextMemberInfo and nextMemberInfo.unit ~= 0 then
            nextString = aura_env.getColored(nextMemberInfo.unit)
            shoutString = shoutString.." "..UnitName(nextMemberInfo.unit).." 准备打断"
            if nextString then
                nextString = nextString.." 准备打断"
            end
        else
            nextString = "|cffff0000下断各凭本事|r"
            shoutString = shoutString.." 下断各凭本事"
        end
    else
        nameString = "|cff00ff00不需要打断|r"
        shoutString = "不需要打断"
        if memberInfo and memberInfo.unit ~= 0 then
            nextString = aura_env.getColored(memberInfo.unit)
            shoutString = shoutString.." "..UnitName(memberInfo.unit).." 准备打断"
            if nextString then
                nextString = nextString.." 准备打断"
            end
        else
            shoutString = shoutString.." 下断各凭本事"
            nextString = "|cffff0000下断各凭本事|r"
        end
    end
    return nameString,nextString,shoutString
end