function(allstates,event,...)
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
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
                    else
                        memberInfo.interruptSkill = nil
                    end
                    memberInfo.skillCD = aura_env.getDuration(memberInfo.interruptSkill, guid)
                    memberInfo.priority = aura_env.specialSpellPriority[specID].priority
                    
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
            end
        end
        return true
    end
end


