function(event, ...)
    local party = aura_env.config['no_party']
    local party_area = aura_env.config['party_area']
    local club = aura_env.config['no_club']
    local club_area = aura_env.config['club_area']
    if event == "CHAT_MSG_WHISPER_INFORM" then
        local text, playerName = ...
        aura_env.m_send[playerName] = true
    elseif event == "PARTY_INVITE_REQUEST" and party then
        if party_area and aura_env.area[GetZoneText()] == nil then
            return
        end
        local name = ...
        if aura_env.m_send[name] or aura_env.checkTarget(name) then
            --pass
        else
            --print("已拒绝 "..name.." 的组队邀请。")
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
        end
    elseif club and event == "CLUB_INVITATION_ADDED_FOR_SELF" then
        --[[ if club_area and aura_env.area[GetZoneText()] == nil then
            return
        end
        local info = ...
        local name = info.inviter.name
        local id = info.club.clubId
        if not aura_env.m_send[name] or aura_env.checkTarget(name) then
            print("已拒绝 "..name.." 的社区邀请。")
            
end]]
    end
end

