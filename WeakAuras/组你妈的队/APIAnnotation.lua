--APIAnnotation-1
numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers()
--Returns the total and online number of guild members.

--[[
Returns

    numTotalMembers
        Integer - total number of people in the guild, or 0 if player is not in a guild.
    numOnlineMaxLevelMembers
        Integer - total number of people in the guild that are at the level cap, or 0 if player is not in a guild. (Does not include remote chat members)
    numOnlineMembers
        Integer - number of online people in the guild, or 0 if the player is not in a guild.
--]]


--APIAnnotation-2
name, rank, rankIndex, level, class, zone, note, 
  officernote, online, status, classFileName, 
  achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(index);
--Returns information about the player in the guild roster.

--[[
Arguments

    index 
        Integer - It's a number corresponding to one player in the Guild

Returns

    name 
        String - The name of one member of the guild
    rank 
        String - The member's rank in the guild ( Guild Master, Member ...)
    rankIndex 
        Number - The number corresponding to the guild's rank. The Rank Index starts at 0, add 1 to correspond with the index used in GuildControlGetRankName(index)
    level 
        Number - The level of the player.
    class 
        String - The class (Mage, Warrior, etc) of the player.
    zone 
        String - The position of the player ( or the last if he is off line )
    note 
        String - Returns the character's public note if one exists, returns "" if there is no note or the current player does not have access to the public notes
    officernote 
        String - Returns the character's officer note if one exists, returns "" if there is no note or the current player does not have access to the officer notes
    online 
        Boolean - Whether the player is online
    status 
        Integer (0,1,2) - The availability of the player; Available, Away, Busy
    classFileName 
        String - Upper-case English classname - localisation independant.
    achievementPoints 
        Integer - The guild achievement points of the member
    achievementRank 
        Integer - The guild achievement rank of the member
    isMobile 
        Boolean - If member is logged on using the mobile armory application
    isSoREligible 
        Boolean - is member eligible for Scroll of Resurrection
    standingID 
        Integer StandingId (0-8) - Numeric representation of standing (Neutral, friendly etc) with the guild
--]]


--APIAnnotation-3
realmName = GetRealmName()
--Returns the name of the realm (aka server) the player is currently on. 

--[[
Returns

    realmName 
        String - The name of the realm.    
--]]

--获取当前服务器名称，可通过下面的例子取出名字中的服务器部分，仅限本服角色
if string.find(playerName, GetRealmName()) then
    playerName = strsplit("-", playerName)
end

--APIAnnotation-4
totalBNet, numBNetOnline = BNGetNumFriends()
--returns totalBNet, numBNetOnline. 

--[[
Returns:

    totalBNet - Total number of RealID friends (number)
    numBNetOnline - Number of currently online RealID friends (number)
--]]


--APIAnnotation-5
isFriend, isDND, isFavorite, gameAccountInfo, accountName, battleTag, 
note, rafLinkType, bnetAccountID, appearOffline, customMessage, lastOnlineTime, customMessageTime, isAFK, isBattleTagFriend = C_BattleNet.GetFriendAccountInfo(friendIndex)
--Returns information about a RealID friend by index.

--[[
    Arguments:

    friendIndex - Index (between 1 and BNGetNumFriends()) (number)

Returns:

    isFriend            (boolean)   
    isDND               (boolean)   是否处于忙碌中
    isFavorite          (boolean)   是否是亲密好友
    gameAccountInfo     (table)     账号信息，具体值与当前运行的客户端有关
    accountName         (string)    战网名
    battleTag           (string)    战网名 + 序号
    note                (string)    备注
    rafLinkType         (number)    ??
    bnetAccountID       (number)    索引号
    appearOffline       (boolean)   是否显示离线
    customMessage       (string)    个人说明
    lastOnlineTime      (number)    最近一次上线时间
    customMessageTime   (number)    个人说明更新时间
    isAFK               (boolean)   是否离开
    isBattleTagFriend   (boolean)   是否是实名好友，A boolean indicating whether the friend is a RealID friend (false) or a BattleTag friend (true). 

    WOW客户端下：
    gameAccountInfo = {
        isGameAFK,          (boolean)   是否离开
        clientProgram,      (string)    客户端类型，魔兽世界为"WOW"，BNET_CLIENT_WOW
        realmName,          (string)    服务器名字
        characterName,      (string)    角色名字
        isGameBusy,         (string)    是否忙碌
        factionName,        (string)    阵营，联盟部落
        playerGuid,         (string)    玩家标识ID
        realmDisplayName,   (string)    服务器显示名称
        wowProjectID,       (number)    魔兽版本，正式服为1，燃烧的远征为5
        gameAccountID,      (number)
        realmID,            (number)
        hasFocus,           (boolean)   ??
        canSummon,          (boolean)   ??
        isWowMobile,        (boolean)   ??
        areaName,           (string)    角色所处区域
        className,          (string)    角色职业
        richPresence,       (string)    玩家状态描述，“正在酒馆战棋中搏杀！”
        characterLevel,     (string)    角色等级
        raceName,           (string)    角色种族
        isOnline            (boolean)   是否在线
    }
--]]