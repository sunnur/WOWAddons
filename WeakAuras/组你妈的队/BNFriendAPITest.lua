--InitActive Start
--InitActive Code
aura_env.mFriendName = {}
aura_env.mFriendRank = {}
aura_env.mFriendClass = {}
aura_env.mFriendNum = 0
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
        local _,count = BNGetNumFriends()
        print(count)
        aura_env.mFriendNum = count
        if count > 0 then
            for index = 1,count do
                playerName = C_BattleNet.GetFriendAccountInfo(index);
                print(playerName)
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
    local count = aura_env.mFriendNum

    for index = 1,count do
        Str = Str..aura_env.mClassColor[aura_env.mFriendClass[index]].."["..index.."]   "..
        aura_env.mFriendName[index].."  "..aura_env.mFriendClass[index].."  "..aura_env.mFriendRank[index].."|r\n"
    end

    return Str
end
--InterfaceActive End