function LightCtrl()
    local nameString = aura_env.getColored("player")
    if aura_env.state.playerName ==  nameString.." 打断" then
        return true
    end
    return false
end

function WarningSound()
    local nameString = aura_env.getColored("player")
    if aura_env.state.playerName ==  nameString.." 打断" and aura_env.config.soundWarning == true then
        local target = "playertarget"
        if UnitGUID(target) and UnitGUID(target) == UnitGUID(aura_env.state.unit) then
            return true
        end
    end
    return false
end

function SendMsg()
    return aura_env.config.shout and aura_env.state.shoutString and IsGUIDInGroup(UnitGUID("player"))
end

if SendMsg() then     
    local message = aura_env.state.shoutString
    if message then
        SendChatMessage(message,"PARTY")
    else
        print(message)
    end
end






