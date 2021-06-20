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
presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, 
client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, broadcastTime, canSoR = BNGetFriendInfo(friendIndex)
--Returns information about a RealID friend by index.

--[[
    Arguments:

    friendIndex - Index (between 1 and BNGetNumFriends()) (number)

Returns:

    presenceID - auto incrementing ID, reset at each login. Persists across reload of UI, but not change of character (number)
    presenceName - Full name of the friend, as a new form of chatlink. Visually looks like a string, but only when rendered. The real name of the friend for RealID friends. The BattleTag without the ID number for BattleTag friends. (string, Kstring)
    battleTag - BattleTag of the friend, or nil if the friend does not have a BattleTag. (string)
    isBattleTagPresence - A boolean indicating whether the friend is a RealID friend (false) or a BattleTag friend (true). (boolean)
    toonName - Name of the active character tied to the BNet account (string)
    toonID - (number)
    client - The name of the game the friend is currently playing, if any; Returns nil if not online. Returns initialism for World of Warcraft ('WoW') (string)
    isOnline - Online status (boolean)
    lastOnline - (number)
    isAFK - (boolean)
    isDND - (boolean)
    messageText - RealID broadcast message displayed below the user on your friends list (string)
    noteText - The player's personal note for the friend; nil for no note (string)
    isRIDFriend - (boolean)
    broadcastTime - The number of seconds since the friend send the current broadcast (number)
    canSoR - Whether or not this friend can receive a Scroll of Resurrection (boolean)

--]]