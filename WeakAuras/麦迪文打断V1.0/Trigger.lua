--GROUP_ROSTER_UPDATE,PLAYER_ENTERING_WORLD,PLAYER_SPECIALIZATION_CHANGED,INSPECT_READY,CLEU:SPELL_CAST_SUCCESS,UNIT_SPELLCAST_INTERRUPTED,UNIT_SPELLCAST_CHANNEL_STOP,UNIT_SPELLCAST_START,UNIT_SPELLCAST_CHANNEL_START,NAME_PLATE_UNIT_ADDED,NAME_PLATE_UNIT_REMOVED,ENCOUNTER_END
function(allstates,event,...)
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        for unit in aura_env.GroupMembers() do
            local guid = UnitGUID(unit)
            
            if unit == "player" then
                local memberInfo = {}
                local currentSpec = GetSpecialization()
                local specializationId = GetSpecializationInfo(currentSpec);
                
                if specializationId then
                    memberInfo.unit = unit
                    memberInfo.expirationTime = 0
                    memberInfo.specialization = specializationId
                    memberInfo.interruptSkill = aura_env.specialItrSpells[specializationId].spellID
                    memberInfo.skillCD = aura_env.getDuration(memberInfo.interruptSkill, guid)
                    memberInfo.priority = aura_env.specialItrSpells[specializationId].priority
                    
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
        local specializationId
        local memberInfo = {}
        
        if sourceGUID == nil then
            return true
        end
        
        if aura_env.needInspect[sourceGUID] then
            --aura_env.debugPrint("guid is in group")
            
            memberInfo.unit = aura_env.needInspect[sourceGUID]
            --aura_env.debugPrint("unit = "..memberInfo.unit)
            
            specializationId = GetInspectSpecialization(memberInfo.unit)
            --aura_env.debugPrint("specializationId = "..specializationId)
            
            if specializationId and specializationId ~= 0 then
                if aura_env.specialItrSpells[specializationId] then
                    memberInfo.specialization = specializationId
                    memberInfo.interruptSkill = aura_env.specialItrSpells[specializationId].spellID
                    memberInfo.skillCD = aura_env.getDuration(memberInfo.interruptSkill, sourceGUID)
                    memberInfo.priority = aura_env.specialItrSpells[specializationId].priority
                    memberInfo.expirationTime = 0
                    aura_env.inspected[sourceGUID] = memberInfo
                end
            end
        else
            return true
        end
        
        aura_env.needInspect[sourceGUID] = nil
        
        -- for i,v in pairs(aura_env.inspected) do
        --     if IsGUIDInGroup(i) ~= true then
        --         aura_env.inspected[i] = nil
        --     end
        -- end
        
        -- for i,v in pairs(aura_env.needInspect) do
        --     if IsGUIDInGroup(i) ~= true then
        --         aura_env.needInspect[i] = nil
        --     else
        --         NotifyInspect(v)
        --         break
        --     end
        -- end
        
    end
    
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