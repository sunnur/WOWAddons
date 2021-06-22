aura_env.m_send = {}
aura_env.area = {}
aura_env.area['暴风城'] = 1
aura_env.area['奥格瑞玛'] = 1
aura_env.area['奥利波斯'] = 1

aura_env.checkTarget = function(name)
    local num = GetNumGuildMembers() -- APIAnnotation-1
    if num > 0 then
        for i =1, num do
            local gName = GetGuildRosterInfo(i) -- Returns information about the player in the guild roster. 
            if string.find(gName, GetRealmName()) then
                gName = strsplit("-", gName)
            end
            if name == gName then
                return true
            end
        end
    end

    local num = BNGetNumFriends()
    if num > 0 then
        for i =1, num do
            local info =  C_BattleNet.GetFriendAccountInfo(i).gameAccountInfo
            if info.clientProgram == BNET_CLIENT_WOW then
                local gName = info.characterName
                if name == gName then
                    return true
                end
            end
        end
    end

    name = strsplit("-", name)
    local info = C_FriendList.GetFriendInfo(name)
    if info then
        return true
    end

    local clubs = C_Club.GetSubscribedClubs()
    for i=1, #clubs do
        if clubs[i].clubType ==  0 or clubs[i].clubType == 1 then
            local id = clubs[i].clubId
            local members = C_Club.GetClubMembers(id)
            for k,v in pairs(members) do
                local info = C_Club.GetMemberInfo(id, v)
                local gName = strsplit("-", info.name)
                if gName == name then
                    return true
                end
            end
        end
    end

    return false
end


