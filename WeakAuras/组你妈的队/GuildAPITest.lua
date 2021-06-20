--InitActive Start
--InitActive Code
aura_env.mMemberName = {}
aura_env.mMemberRank = {}
aura_env.mMemberClass = {}
aura_env.mMemberNum = 0
aura_env.mClassColor = {["死亡骑士"]    = "|c00C41F3B",
                        ["恶魔猎手"]    = "|c00A330C9",
                        ["德鲁伊"]      = "|c00FF7D0A",
                        ["猎人"]        = "|c00ABD473",
                        ["法师"]        = "|c0069CCF0",
                        ["武僧"]        = "|c0000FF96",
                        ["圣骑士"]      = "|c00F58CBA",
                        ["牧师"]        = "|c00FFFFFF",
                        ["潜行者"]      = "|c00FFF569",
                        ["萨满祭司"]    = "|c000070DE",
                        ["术士"]        = "|c009482C9",
                        ["战士"]        = "|c00C79C6E"}
--InitActive End


--TriggerActive Start
--TriggerActive EventType
GUILD_TRADESKILL_UPDATE
--TriggerActive Code
function(event,...)
    local playerName,playerRank,playerClass
    if event == "GUILD_TRADESKILL_UPDATE" then
        local _,_,count = GetNumGuildMembers()
        aura_env.mMemberNum = count
        if count > 0 then
            for index = 1,count do
                playerName,playerRank,_,_,playerClass = GetGuildRosterInfo(index)
                if string.find(playerName, GetRealmName()) then
                    playerName = strsplit("-", playerName)
                end
                aura_env.mMemberName[index] = playerName
                aura_env.mMemberRank[index] = playerRank
                aura_env.mMemberClass[index] = playerClass
            end
            return true
        else
            return nil
        end
    end
end
--TriggerActive End

--InterfaceActive Start
--InterfaceActive Code
function()
    local Str = ""
    local count = aura_env.mMemberNum

    for index = 1,count do
        Str = Str..aura_env.mClassColor[aura_env.mMemberClass[index]].."["..index.."]   "..
        aura_env.mMemberName[index].."  "..aura_env.mMemberClass[index].."  "..aura_env.mMemberRank[index].."|r\n"
    end

    return Str
end
--InterfaceActive End