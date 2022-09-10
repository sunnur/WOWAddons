function(allstates,event,...)
    -- aura_env.debugPrint(event)
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        -- aura_env.debugPrint("GroupMembers:\n")
        for unit in aura_env.GroupMembers() do
            local specializationId = 0
            local memberInfo = {}
            local guid = UnitGUID(unit)
            
            memberInfo.unit = unit
            memberInfo.expirationTime = 0
            -- aura_env.debugPrint(unit)
            -- aura_env.debugPrint(UnitName(unit))
            
            if unit == "player" then
                local currentSpec = GetSpecialization()
                specializationId = GetSpecializationInfo(currentSpec);
                
                if specializationId then
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
            
            if specializationId ~= 0 then
                if aura_env.specialItrSpells[specializationId]then
                    memberInfo.specialization = specializationId
                    memberInfo.interruptSkill = aura_env.specialItrSpells[specializationId].spellID
                    memberInfo.skillCD = aura_env.getDuration(memberInfo.interruptSkill, sourceGUID)
                    memberInfo.priority = aura_env.specialItrSpells[specializationId].priority
                    memberInfo.expirationTime = 0
                    aura_env.inspected[sourceGUID] = memberInfo
                end
            end
        end
        
        aura_env.needInspect[sourceGUID] = nil
        
        for i,v in pairs(aura_env.inspected) do
            if IsGUIDInGroup(i) ~= true then
                aura_env.inspected[i] = nil
            else
                --aura_env.debugPrint("unit: "..v.unit.." 打断: "..v.interruptSkill)
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
        
    end
    
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local subevent = select(2,...)
        if subevent == "SPELL_CAST_SUCCESS" then
            local sourceGUID = select(4,...)
            local spellId = select(12,...)
            local npcID
            
            if spellId == 119910 or spellId == 19647 or spellId == 132409 or spellId == 89466 or spellId == 89766 then
                spellId = 119910
            end

            if aura_env.inspected[sourceGUID] ~= nil then
                if spellId == aura_env.inspected[sourceGUID].interruptSkill then
                    aura_env.inspected[sourceGUID].expirationTime = GetTime() + aura_env.inspected[sourceGUID].skillCD
                    
                    for key, value in pairs(allstates) do
                        value.show = false
                        value.changed = true
                    end
                end
            end
            
            npcID = select(6, strsplit("-", sourceGUID))
            if aura_env.npcIDs[npcID] then
                local state = allstates[sourceGUID]
                if state then
                    if spellId == 228269 or spellId == 227779 then
                        state.dangerousTime = GetTime() + 20
                    end
                end
                
                if spellId ~=  227628 then
                    for key, value in pairs(allstates) do
                        value.show = false
                        value.changed = true
                    end
                end
                
            end
            
        end
    end
    if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local sourceGUID = select(2,...)
        local spellId = select(3,...)
        local npcID
        
        npcID = select(6, strsplit("-", sourceGUID))
        if aura_env.npcIDs[npcID] then
            
            if spellId == 227628 then
                for key, value in pairs(allstates) do
                    value.show = false
                    value.changed = true
                end
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
                   
                    local memberInfo = {}
                    memberInfo.priority = 9
                    memberInfo.unit = 0
                    
                    local nextMemberInfo = {}
                    nextMemberInfo.priority = 9
                    nextMemberInfo.unit = 0
                    
                    local interruptList = {}

                    local spellName,_,_,castTime = GetSpellInfo(spellId)
                    castTime = castTime / 1000
                    
                    for i,v in pairs(aura_env.inspected) do
                        if v.expirationTime < (GetTime() + castTime * 2 - 0.5) then
                            table.insert(interruptList, v)
                        end
                    end
                    
                    table.sort(interruptList,function (a,b)
                            if a and b then
                            end
                            if a.expirationTime < b.expirationTime then
                                return true
                            elseif(a.priority < b.priority)then
                                return true
                            elseif a.priority == b.priority then
                                if a.unit == 0 or UnitGUID(a.unit) > UnitGUID(b.unit) then
                                    return true
                                end
                            end
                            return false
                    end)

                    memberInfo = interruptList[1]

                    if memberInfo and memberInfo.expirationTime > (GetTime() + castTime - 0.5) then
                        memberInfo = nil
                        nextMemberInfo = interruptList[1]
                    else
                        memberInfo = interruptList[1]
                        nextMemberInfo = interruptList[2]
                    end


                    -- for key,val in pairs(memberInfo) do
                    --     aura_env.debugPrint("key: "..key.." val: "..val)
                    -- end
                    
                    local needInterrupt = 1
                    local state = allstates[npcID]
                    
                    if spellId == 227628 then
                        local _,_,debuffStack = AuraUtil.FindAuraByName(spellName, unit.."target","HARMFUL")
                        if (debuffStack == nil) or (debuffStack < aura_env.config.debuffMaxStack) then
                            needInterrupt = 0
                        end
                    end
                    --228249
                    if (spellId == 227615) then
                        local spellTarget
                        for spellTarget in WA_IterateGroupMembers() do
                            if aura_env.getAuraByID(spellTarget, 228249, "HARMFUL") then
                                break
                            end
                            spellTarget = nil
                        end
                        
                        local unitTargetGUID = UnitGUID(spellTarget)
                        local roleSpec
                        if unitTargetGUID and aura_env.inspected[unitTargetGUID]then
                            roleSpec = aura_env.inspected[unitTargetGUID].specialization
                            
                            if GetSpecializationRole(roleSpec) == "TANK" then
                                needInterrupt = 0
                            end
                        end
                        
                        if state and (aura_env.config.purgatoryIntr == false) then
                            local flag = aura_env.getAuraByID(spellId, 228958, "HARMFUL")
                            if (GetTime() > state.dangerousTime) and (flag == nil) then
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
                    
                    if state then
                        state.show = true
                        state.changed = true
                        state.unit = "player"
                        state.isHide = false
                        state.playerName = nameString
                        state.nextString = nextString
                        state.shoutString = shoutString
                    else
                        allstates[npcID] = {
                            show = true,
                            changed = true,
                            unit = "player",
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
    
    if event == "CHAT_MSG_SAY" then
        local playerName = select(2,...)
        local text = select(1,...)
        
        local getChatMsg
        local npcID
        local spellId
        
        if aura_env.debugFlag ~= 1 then
            return true
        end

        playerName = select(1,strsplit("-", playerName))
        print("test mode "..playerName )

        if playerName == UnitName("player") then
            
            getChatMsg = string.gmatch(text,"%d+")
            npcID = getChatMsg()
            spellId = getChatMsg()

            if aura_env.spellIDs[tostring(spellId)] and aura_env.npcIDs[npcID] then
                
                local memberInfo = {}
                memberInfo.priority = 9
                memberInfo.unit = 0
                
                local nextMemberInfo = {}
                nextMemberInfo.priority = 9
                nextMemberInfo.unit = 0
                
                local interruptList = {}

                local spellName,_,_,castTime = GetSpellInfo(spellId)
                castTime = castTime / 1000
                
                for i,v in pairs(aura_env.inspected) do
                    if v.expirationTime < (GetTime() + castTime * 2 - 0.5) then
                        table.insert(interruptList, v)
                    end
                end
                
                table.sort(interruptList,function (a,b)
                        if a and b then
                        end
                        if a.expirationTime < b.expirationTime then
                            return true
                        elseif(a.priority < b.priority)then
                            return true
                        elseif a.priority == b.priority then
                            if a.unit == 0 or UnitGUID(a.unit) > UnitGUID(b.unit) then
                                return true
                            end
                        end
                        return false
                end)

                memberInfo = interruptList[1]

                if memberInfo and memberInfo.expirationTime > (GetTime() + castTime - 0.5) then
                    memberInfo = nil
                    nextMemberInfo = interruptList[1]
                else
                    memberInfo = interruptList[1]
                    nextMemberInfo = interruptList[2]
                end


                -- for key,val in pairs(memberInfo) do
                --     aura_env.debugPrint("key: "..key.." val: "..val)
                -- end
                
                local needInterrupt = 1
                local state = allstates[npcID]
                
                if spellId == 227628 then
                    local _,_,debuffStack = AuraUtil.FindAuraByName(spellName, unit.."target","HARMFUL")
                    if (debuffStack == nil) or (debuffStack < aura_env.config.debuffMaxStack) then
                        needInterrupt = 0
                    end
                end
                --228249
                if (spellId == 227615) then
                    local spellTarget
                    for spellTarget in WA_IterateGroupMembers() do
                        if aura_env.getAuraByID(spellTarget, 228249, "HARMFUL") then
                            break
                        end
                        spellTarget = nil
                    end
                    
                    local unitTargetGUID = UnitGUID(spellTarget)
                    local roleSpec
                    if unitTargetGUID and aura_env.inspected[unitTargetGUID]then
                        roleSpec = aura_env.inspected[unitTargetGUID].specialization
                        
                        if GetSpecializationRole(roleSpec) == "TANK" then
                            needInterrupt = 0
                        end
                    end
                    
                    if state and (aura_env.config.purgatoryIntr == false) then
                        local flag = aura_env.getAuraByID(spellId, 228958, "HARMFUL")
                        if (GetTime() > state.dangerousTime) and (flag == nil) then
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
                        memberInfo.expirationTime = GetTime() + aura_env.inspected[UnitGUID(memberInfo.unit)].skillCD
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
                        memberInfo.expirationTime = GetTime() + aura_env.inspected[UnitGUID(memberInfo.unit)].skillCD
                    else
                        shoutString = shoutString.." 下断各凭本事"
                        nextString = "|cffff0000下断各凭本事|r"
                    end
                end
                
                if state then
                    state.show = true
                    state.changed = true
                    state.unit = "player"
                    state.isHide = false
                    state.playerName = nameString
                    state.nextString = nextString
                    state.shoutString = shoutString
                else
                    allstates[npcID] = {
                        show = true,
                        changed = true,
                        unit = "player",
                        isHide = false,
                        playerName = nameString,
                        nextString = nextString,
                        dangerousTime = 0,
                        
                    }
                end
            end
        end
    end
    
    return true
end

