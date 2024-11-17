--GROUP_ROSTER_UPDATE,PLAYER_ENTERING_WORLD,PLAYER_SPECIALIZATION_CHANGED,INSPECT_READY,CLEU:SPELL_CAST_SUCCESS,UNIT_SPELLCAST_INTERRUPTED,UNIT_SPELLCAST_CHANNEL_STOP,UNIT_SPELLCAST_START,UNIT_SPELLCAST_CHANNEL_START,NAME_PLATE_UNIT_ADDED,NAME_PLATE_UNIT_REMOVED,ENCOUNTER_END
--ENCOUNTER_START, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, CLEU:SPELL_CAST_START:SPELL_CAST_SUCCESS:SPELL_INTERRUPT, RAID_TARGET_UPDATE, OPTIONS, UNIT_SPELLCAST_START:nameplate, INSTANCE_ENCOUNTER_ENGAGE_UNIT
function(allstates,event,...)
    if event == "OPTIONS"
    and WeakAuras.IsOptionsOpen()
    and aura_env.config.testMode then
        for _, plate in pairs(C_NamePlate.GetNamePlates()) do
            local unit = plate.namePlateUnitToken
            local guid = UnitGUID(plate.namePlateUnitToken)
            if unit
            and guid then
                local npcID = select(6, strsplit("-", guid))
                allstates[guid] = {
                    show = true,
                    changed = true,
                    unit = unit,
                    playerName = aura_env.config.overrideSettings and aura_env.config.showName and WA_ClassColorName("player"),
                    counter = 1,
                    progressType = aura_env.config.showCastDuration and "timed",
                    duration = 10,
                    expirationTime = 10 + GetTime(),
                }
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        for unit in aura_env.GroupMembers() do
            local guid = UnitGUID(unit)
            
            aura_env.debugPrint("[GROUP_ROSTER_UPDATE]")
            if unit == "player" then
                local memberInfo = {}
                local specID = GetSpecializationInfo(GetSpecialization())
                
                aura_env.debugPrint("[GROUP_ROSTER_UPDATE]specID: "..specID)
                if specID then
                    memberInfo.unit = unit
                    memberInfo.expirationTime = 0
                    if aura_env.specialSpellPriority[specID] then
                        memberInfo.interruptSkill = aura_env.specialSpellPriority[specID].spellID
                        memberInfo.skillCD = aura_env.getDuration(memberInfo.interruptSkill, guid)
                        memberInfo.priority = aura_env.specialSpellPriority[specID].priority
                    else
                        memberInfo.interruptSkill = nil
                    end
                    
                    if guid then
                        aura_env.inspected[guid] = memberInfo
                    end
                end
            else
                if guid and aura_env.inspected[guid] == nil then
                    aura_env.needInspect[guid] = unit
                end
            end
        end
        
        if IsGUIDInGroup(UnitGUID("player")) == false then
            for i,v in pairs(aura_env.needInspect) do
                aura_env.needInspect[i] = nil
            end
            for i,v in pairs(aura_env.inspected) do
                aura_env.inspected[i] = nil
            end
        end
        
        for i,v in pairs(aura_env.needInspect) do
            if IsGUIDInGroup(i) ~= true then
                aura_env.needInspect[i] = nil
            else
                NotifyInspect(v)
                break
            end
        end
        
        for i,v in pairs(aura_env.inspected) do
            if IsGUIDInGroup(i) ~= true then
                aura_env.inspected[i] = nil
            else
                aura_env.debugPrint(i.."is inspected\r\n")
            end
        end
    end
    
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = select(1,...)
        if unit then
            local guid = UnitGUID(unit)
            if guid and IsGUIDInGroup(guid) == true then
                aura_env.inspected[guid] = nil
                aura_env.needInspect[guid] = unit
            end
        end
    end
    
    if event == "INSPECT_READY" then
        local sourceGUID = select(1,...)
        local specID
        local memberInfo = {}
        
        if sourceGUID == nil then
            return false
        end
        
        if aura_env.needInspect[sourceGUID] then
            aura_env.debugPrint("[INSPECT_READY]unit in group")
            
            memberInfo.unit = aura_env.needInspect[sourceGUID]
            aura_env.debugPrint("[INSPECT_READY]unit = "..memberInfo.unit)
            
            specID = GetInspectSpecialization(memberInfo.unit)
            aura_env.debugPrint("specID = "..specID)
            
            if specID and specID ~= 0 then
                if aura_env.specialSpellPriority[specID] then
                    memberInfo.expirationTime = 0
                    memberInfo.interruptSkill = aura_env.specialSpellPriority[specID].spellID
                    memberInfo.skillCD = aura_env.getDuration(memberInfo.interruptSkill, sourceGUID)
                    memberInfo.priority = aura_env.specialSpellPriority[specID].priority
                    aura_env.inspected[sourceGUID] = memberInfo
                end
            end
        else
            return false
        end
        
        aura_env.needInspect[sourceGUID] = nil
    end
    
    if event == "RAID_TARGET_UPDATE" then
        for _, plate in pairs(C_NamePlate.GetNamePlates()) do
            local unit = plate.namePlateUnitToken
            local guid = UnitGUID(plate.namePlateUnitToken)
            local icon = GetRaidTargetIndex(unit)

            if unit and guid and icon then
                aura_env.debugPrint("[RAID_TARGET_UPDATE]unit: "..unit.." icon: "..icon)
                if UnitCanAttack("player", unit) then
                    aura_env.needIptTar[icon].unit = unit
                    aura_env.needIptTar[icon].guid = guid
                else
                    aura_env.needIptTar[icon].unit = nil
                end
                
                --[[
                if not aura_env.counter[guid] then
                    aura_env.counter[guid] = 1
                end
                local counter = aura_env.counter[guid]
                allstates[guid] = {
                    show = true,
                    changed = true,
                    counter = counter,
                    unit = unit,
                    icon = icon or 0,
                    myAssignment = aura_env.checkAssignment(counter, icon)
                }
                local isMyAssignment = aura_env.checkAssignment(counter, icon)
                if isMyAssignment then
                    PlaySoundFile(aura_env.sound[aura_env.config.specifiedSound], "MASTER")
                    local _, _, _, startMS, endMS, _, _, _, spellId = UnitCastingInfo(unit)
                    if spellId then
                        allstates[guid].progressType = "timed"
                        allstates[guid].duration = ((endMS-startMS)/1000)
                        allstates[guid].expirationTime = (endMS/1000)
                        allstates[guid].isCasting = true
                    end
                end
                if aura_env.showName then
                    allstates[guid].playerName = aura_env.assignments[icon] and aura_env.assignments[icon][counter]
                end
                --]]
            end

            if aura_env.needIptTar[icon].unit ~= nil then
                aura_env.debugPrint("[RAID_TARGET_UPDATE]need interrupt num: "..aura_env.table_length(aura_env.needIptTar))
            else
                aura_env.debugPrint("[RAID_TARGET_UPDATE]need interrupt nil")
            end
            
        end
        return true
    end
    --TODO
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local subevent = select(2,...)
        if subevent == "SPELL_CAST_SUCCESS" then
            local sourceGUID = select(4,...)
            local spellId = select(12,...)
            local npcID
            
            if spellId == 119910 or spellId == 19647 or spellId == 132409 or spellId == 89766 or spellId == 119914 then
                spellId = 119910
            end
            
            if aura_env.inspected[sourceGUID] and (spellId == aura_env.inspected[sourceGUID].interruptSkill) then
                aura_env.inspected[sourceGUID].expirationTime = GetTime() + aura_env.inspected[sourceGUID].skillCD
            end
            
            npcID = select(6, strsplit("-", sourceGUID))
            if aura_env.npcIDs[npcID] then
                local state = allstates[sourceGUID]
                if state then
                    if spellId == 228269 or spellId == 227779 then
                        state.dangerousTime = GetTime() + 20
                    elseif spellId ~= 227628 then
                        -- state.isHide = true
                        -- state.changed = true
                    end
                end
            end
        end
    end

    if event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit = select(1,...)
        local sourceGUID
        local npcID

        if unit then
            sourceGUID = UnitGUID(unit)
        end

        if sourceGUID then
            npcID = select(6, strsplit("-", sourceGUID))
            if npcID and aura_env.npcIDs[npcID] then
                local state = allstates[sourceGUID]
                -- state.isHide = true
                -- state.changed = true
            end
        end
    end

    if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unit = select(1,...)
        local spellId = select(3,...)
        local npcID
        local sourceGUID
        
        if unit then
            sourceGUID = UnitGUID(unit)
        end
        
        if sourceGUID then
            npcID = select(6, strsplit("-", sourceGUID))
        end

        if npcID and aura_env.npcIDs[npcID] then
            if spellId == 227628 then
                local state = allstates[sourceGUID]
                state.isHide = true
                state.changed = true
            end
        end
    end
    
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit = select(1,...)
        local spellId = select(3,...)
        
        local sourceGUID
        local npcID
        
        if unit then
            sourceGUID = UnitGUID(unit)
            
            if sourceGUID then
                npcID = select(6, strsplit("-", sourceGUID))
                
                if aura_env.spellIDs[tostring(spellId)] and aura_env.npcIDs[npcID] then
                    
                    local state = allstates[sourceGUID]
                    local nameString,nextString,shoutString = aura_env.labelUpdate(spellId, unit, true, state)

                    if state then
                        state.show = true
                        state.changed = true
                        state.unit = unit
                        state.isHide = false
                        state.playerName = nameString
                        state.nextString = nextString
                        state.shoutString = shoutString
                    else
                        allstates[sourceGUID] = {
                            show = true,
                            changed = true,
                            unit = unit,
                            isHide = false,
                            playerName = nameString,
                            nextString = nextString,
                            dangerousTime = 0,
                        }
                    end
                end
            end
        end
    end
    
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unit = select(1,...)
        local guid
        local npcID
        
        if unit then
            guid = UnitGUID(unit)
            npcID = select(6, strsplit("-", guid))
            
            if aura_env.npcIDs[npcID] then
                local state = allstates[guid]
                if state then
                    state.show = true
                    state.changed = true
                    state.unit = unit
                    state.isHide = false
                end
            end
        end
    end
    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = select(1,...)
        local guid
        
        if unit then
            guid = UnitGUID(unit)
        end
        
        if guid then
            local state = allstates[guid]
            if state then
                state.show = true
                state.changed = true
                state.isHide = true
            end
        end
    end
    
    if event == "ENCOUNTER_END" then
        for key, value in pairs(allstates) do
            value.show = false
            value.changed = true
        end
    end
    
    return true
end