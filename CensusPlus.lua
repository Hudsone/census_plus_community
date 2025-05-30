--[[ CensusPlus for World of Warcraft(tm).
	
	Copyright 2005 - 2020 Cooper Sellers and WarcraftRealms.com

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
		
  Debugging/profiling note:
  Global  CPp.EnableProfiling must be set to True
  the appropriate profiling point must be set in code with
  --CP_profiling_timerstart =	debugprofilestop()
  don't use debugprofilestart() this does a reset of the timer...
  if multiple code (addons) have profiling turned on.. then debugprofilestart()
  will impact timing of the all the code profiles.
]]
--local regionKey = GetCVar("portal") == "public-test" and "PTR" or GetCVar("portal")
--Note: file layout structured for use with NotePad++ as editor using Lua(WoW) language definition

--[[	-- CensusPlus
-- A WoW UI customization by Cooper Sellers
--
]]

--[[  -- Blizzard 5.4.1 taint hider
--]]
-- UIParent:HookScript("OnEvent", function(s, e, a1, a2) if e:find("ACTION_FORBIDDEN") and ((a1 or "")..(a2 or "")):find("IsDisabledByParentalControls") then StaticPopup_Hide(e) end; end)

--[[	-- EURO vs US localization problem workaround for common server names
--
]]

local addon_name, addon_tableID = ... -- Addon_name contains the Addon name which must be the same as the container folder name... addon_tableID is a common private table for all .lua files in the directory.
--print("Main")
--print(true)
--print(false)
--print("What?")

--print (addon_name)
--print (addon_tableID)
local CPp =
    addon_tableID                             --short cut name for private shared table.

CPp.InterfaceVersion = 'Captain Placeholder'; -- random value.. must not match CensusPlus_VERSION string.
CPp.CensusPlusLocale = 'N/A';                 --  Must read either US or EU
local g_CensusPlusTZOffset = -999;
CPp.LocaleSet = false;                        -- not used?
CPp.TZWarningSent = false;                    -- not used?

--[[ 	-- Constants
--
]]

local projectVersion = '8.1.12'
local versionNumbers = strsplittable('.', projectVersion)
local CensusPlus_Version_Major = versionNumbers[1]
local CensusPlus_Version_Minor = versionNumbers[2]
local CensusPlus_Version_Maint = versionNumbers[3]

local CensusPlus_SubVersion = ' >=WoW.11.1.5';
--local CensusPlus_VERSION = "WoD"
local CensusPlus_VERSION = CensusPlus_Version_Major ..
    '.' .. CensusPlus_Version_Minor .. '.' .. CensusPlus_Version_Maint;
local versionSuffix = '' -- For alpha / beta / release.
local CensusPlus_VERSION_FULL = CensusPlus_VERSION .. versionSuffix .. '.' ..
    CensusPlus_SubVersion;
local CensusPlus_PTR = GetCVar('portal') == 'public-test' and 'PTR'; -- enable true for PTR testing  enable false for live use
local CensusPlus_MAXBARHEIGHT = 128;                                 -- Length of blue bars
local CensusPlus_NUMGUILDBUTTONS = 10;                               -- How many guild buttons are on the UI?
-- local LATEST_XPAC_LIMIT = 110		--WoWL limit
local LATEST_XPAC_LIMIT = 120                                        --BfA limit
local expansions = 15                                                -- arbitrary number for max expansion packs for WoW
-- pulls from Blizzard global data.. maximum possible character level

MAX_CHARACTER_LEVEL = GetMaxLevelForPlayerExpansion()
--print("Max Character Level")
--print(MAX_CHARACTER_LEVEL)
--local MAX_CHARACTER_LEVEL = 120;					-- Maximum level a PC can attain  testing only comment out for live

local MIN_CHARACTER_LEVEL = 20;    -- Minimum observed level returned by /who command (undocumented and barely acknowledged.)
local MAX_WHO_RESULTS = 49;        -- Maximum number of who results the server will return
CensusPlus_GUILDBUTTONSIZEY = 16;  -- pixil height of guild name lines
local CensusPlus_UPDATEDELAY = 5;  -- Delay time between /who messages
local CensusPlus_UPDATEDELAY2 = 10 -- Delay time from who request to database updated
local CP_MAX_TIMES = 50;

--local g_ServerPrefix = "";						--  US VERSION!!
--local g_ServerPrefix = "EU-";					--  EU VERSION!!

-- debug flags for remote QA testing of version upgrades.
local CP_libwho = 'libwho'
local CP_api = 'api'
local CP_letterselect = 0            -- default letter selector pattern... valid options 1 and 2.. testing only
local CensusPlus_WHOPROCESSOR =
    CP_libwho                        -- default processing of who request to full wholib  CP_api --
-- local CensusPlus_WHOPROCESSOR = CP_api   -- default processing of who request to full wholib  CP_api --
local CensusPLus_DEBUGWRITES = false -- don't add debug into to censusplus.lua output.
local CP_g_queue_count = 0           -- process speed checking avg time to process 1 queue
local wholib

if IntellisenseTrick_ExposeGlobal then
  wholib = LibWho
  CPp.Normalization = Normalization
  CPp.DatabaseOperation = DatabaseOperation
end

local NLZN = CPp.Normalization

--[[	-- Global scope variables
--
]]

CensusPlus_Database = {};    -- Database of all CensusPlus results
-- removed CensusPlus_BGInfo   = {};							--  Battleground info
CensusPlus_PerCharInfo = {}; --  Per character settings
CensusPlus_CRealms = {};     -- Connected realms for upload to web site.
CensusPlus_Unhandled = {};
CensusPlus_JobQueue = {};    -- The queue of pending jobs
local g_TrackUnhandled = false;
CPp.Options_Holder = {}      -- table is populated with existing option settings when Options panel is opened.. cancel resets live options to these settings.
CPp.Options_Holder['AccountWide'] = {}
CPp.Options_Holder['CCOverrides'] = {}

--[[	-- File scope variables
--
]]
local g_WoW_regions = {[1] = 'US', [2] = 'KR', [3] = 'EU', [4] = 'TW', [5] = 'CN'}
local g_addon_loaded = false
local g_player_loaded = false

local g_stealth = false;                        -- Stealth mode switch
local g_Verbose = false;                        -- Verbose mode switch
local g_Options_confirm_txt = true;             -- enable chatty confirm of options until user no longer desires
CPp.AutoCensus = false;                         -- AutoCensus mode switch
local g_Options_Scope = 'AW'                    -- options are AW or CO
CPp.AutoStartTimer = 20                         -- default Slider value in Options
CPp.AutoStartTrigger = 21                       -- time limiter in minutes if Slider less then this value auto start enabled
local g_FinishSoundNumber = 1                   -- default finish sound..
local g_PlayFinishSound = false                 -- mode switch
local g_CensusPlusInitialized = false;          -- Is CensusPlus initialized?
local g_CurrentJob = {};                        -- Current job being executed
CPp.IsCensusPlusInProgress = false;             -- Is a CensusPlus in progress?
local g_CensusPlusPaused = false;               -- Is CensusPlus in progress paused?
CPp.CensusPlusManuallyPaused = false;           -- Is CensusPlus in progress manually paused?
local CensusPlayerOnly = false                  -- true if player requests via /census me

CensusPlus_JobQueue.g_NumNewCharacters = 0;     -- How many new characters found this CensusPlus
CensusPlus_JobQueue.g_NumUpdatedCharacters = 0; -- How many characters were updated during this CensusPlus

local g_TotalCharacterXPPerLevel = {};          -- Total XP required to attain the given level

CensusPlus_Guilds = {};                         -- All known guild

local g_Consecutive = 0;                        -- Current consecutive same realm/faction run count
local g_TotalCount = 0;                         -- Total number of characters which meet search criteria
local g_RaceCount = {};                         -- Totals for each race given search criteria
local g_ClassCount = {};                        -- Totals for each class given search criteria
local g_LevelCount = {};                        -- Totals for each level given search criteria
local g_AccumulatorCount = 0;
--[[
--5.4 new tables
CPp.VRealms ={realm1,realm2,realm3..realmN}  -- list of member realms found in Virtual realm set with each Census run.. realm1 is current realm all else is up in the air

g_TempCount = {									-- table of tables  realm, name, class
			[realmX] = {
				[faction] = {
					[class] = {
						[character_name] = class
							},
						},
					},
			},

--]]
--local --global for PTR testing
---@type string[]
CPp.VRealms                             = {}; -- Table for membership of realms in Virtual Realm
--local --global for PTR testing
CensusPlus_JobQueue.g_TempCount         = {};
CPp.ConnectedRealmsButton               = 0;   -- Signals which member realm in connected realms is selected for guild info display

CPp.GuildSelected                       = nil; -- Search criteria: Currently selected guild, 0 indicates none
CPp.RaceSelected                        = 0;   -- Search criteria: Currently selected race, 0 indicates none
CPp.ClassSelected                       = 0;   -- Search criteria: Currently selected class, 0 indicates none
CPp.LevelSelected                       = 0;
local current_realm                     = 0;

local g_LastOnUpdateTime                = 0; -- Last time OnUpdate was called

local g_factionGroup                    =
'Neutral'                                        -- Faction of character running census. used to select/verify correct faction of race

local g_WhoAttempts                     = 0;     -- Counter for detecting stuck who results
local g_MiniOnStart                     = 1;     -- Flag to have the mini-censusP displayed on startup

local g_CompleteCensusStarted           = false; -- Flag for counter
local g_TakeHour                        = 0;     -- Our timing hour
local g_ResetHour                       = true;  -- Rest hour
local g_VariablesLoaded                 = false; -- flag to tell us if vars are loaded
CPp.FirstLoad                           = false  -- Flag to handle (hide) various database rebuild messages on initial database creation
local g_FirstRun                        = true;
local whoquery_answered                 = false;
local whoquery_active                   = false
CPp.LastCensusRun                       = time() -- (CPp.AutoStartTrigger * 60)	--  timer used if auto census is turned on
CPp.LastManualWho                       = time()

local g_Pre_FriendsFrameOnHideOverride  = nil; --  override for friend's frame to stop the close window sound
local g_Pre_FriendsFrameOnShowOverride  = nil; --  override for friend's frame to stop the close window sound
local g_Pre_WhoList_UpdateOverride      = nil; --  override for friend's frame to stop the close window sound
local g_Pre_WhoHandler                  = nil; --  override for submiting a who
local CP_Pre_OnEvent                    = nil;
local g_Pre_FriendsFrame_Update         = nil;
local CP_updatingGuild                  = nil;
local g_CurrentlyInBG                   = false;
local g_CurrentlyInBG_Msg               = false;
local g_InternalSearchName              = nil;
local g_InternalSearchLevel             = nil;
local g_InternalSearchCount             = 0;
CPp.EnableProfiling                     = false;
local CP_profiling_timerstart           = 0
local CP_profiling_timediff             = 0
local g_CensusPlus_StartTime            = 0;
local g_CensusWhoOverrideMsg            = nil;
local g_WaitingForOverrideUpdate        = false;
local g_ProblematicMessageShown         = false;
local g_WhoLibLoaded                    = false;
local g_PratLoaded                      = false;
local g_WhoLibSubvert                   = nil;
local g_WhoLibSendWhoSubvert            = nil;
local g_whoLibResultSubvert             = nil;
local g_WhoLibChatSubvert               = nil;
local g_WhoLibAskWhoSubvert             = nil;

--  Battleground info
CENSUSPLUS_CURRENT_BATTLEFIELD_QUEUES   = {};

local g_AccumulatedPruneData            = {};

local g_SupportedRaceCount              = 14;
local g_SupportedClassCount             = 13;
local g_RaceClassList                   = {}; -- Used to pick the right icon
g_RaceClassList[NLZN.CLASS.DRUID]       = 10;
g_RaceClassList[NLZN.CLASS.HUNTER]      = 11;
g_RaceClassList[NLZN.CLASS.MAGE]        = 12;
g_RaceClassList[NLZN.CLASS.PRIEST]      = 13;
g_RaceClassList[NLZN.CLASS.ROGUE]       = 14;
g_RaceClassList[NLZN.CLASS.WARLOCK]     = 15;
g_RaceClassList[NLZN.CLASS.WARRIOR]     = 16;
g_RaceClassList[NLZN.CLASS.SHAMAN]      = 17;
g_RaceClassList[NLZN.CLASS.PALADIN]     = 18;
g_RaceClassList[NLZN.CLASS.DEATHKNIGHT] = 30;
g_RaceClassList[NLZN.CLASS.MONK]        = 19;
g_RaceClassList[NLZN.CLASS.DEMONHUNTER] = 35;

g_RaceClassList[NLZN.RACE.DWARF]        = 20;
g_RaceClassList[NLZN.RACE.GNOME]        = 21;
g_RaceClassList[NLZN.RACE.HUMAN]        = 22;
g_RaceClassList[NLZN.RACE.NIGHTELF]     = 23;
g_RaceClassList[NLZN.RACE.ORC]          = 24;
g_RaceClassList[NLZN.RACE.TAUREN]       = 25;
g_RaceClassList[NLZN.RACE.TROLL]        = 26;
g_RaceClassList[NLZN.RACE.UNDEAD]       = 27;
g_RaceClassList[NLZN.RACE.DRAENEI]      = 28;
g_RaceClassList[NLZN.RACE.BLOODELF]     = 29;
g_RaceClassList[NLZN.RACE.WORGEN]       = 32;
g_RaceClassList[NLZN.RACE.GOBLIN]       = 31;
g_RaceClassList[NLZN.RACE.PANDAREN]     = 33; -- Male icon of Ji Firepaw (Houjin faction) Horde
g_RaceClassList[NLZN.RACE.PANDAREN]     = 34; -- Female icon of Aysa Cloudsinger (Tushui faction) Alliance
g_RaceClassList[NLZN.RACE.HIGHMOUNTAIN] = 36; --BfA
g_RaceClassList[NLZN.RACE.NIGHTBORNE]   = 37; --BfA
g_RaceClassList[NLZN.RACE.MAGHAR]       = 42; --BfA
g_RaceClassList[NLZN.RACE.ZANDALARI]    = 38; --BfA
g_RaceClassList[NLZN.RACE.LIGHTFORGED]  = 39; --BfA
g_RaceClassList[NLZN.RACE.VOIDELF]      = 40; --BfA
g_RaceClassList[NLZN.RACE.DARKIRON]     = 41; --BfA
g_RaceClassList[NLZN.RACE.KULTIRAN]     = 43; --BfA
g_RaceClassList[NLZN.RACE.VULPERA]      = 44; --BfA8.3
g_RaceClassList[NLZN.RACE.MECHAGNOME]   = 45; --BfA8.3
g_RaceClassList[NLZN.RACE.EARTHEN]      = 46; --11.0

CensusPlus_JobQueue.g_TimeDatabase      = {}; -- Time database
local function CensusPlus_Zero_g_TimeDatabase()
  CensusPlus_JobQueue.g_TimeDatabase                         = nil;
  CensusPlus_JobQueue.g_TimeDatabase                         = {};
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DRUID]       = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.HUNTER]      = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.MAGE]        = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.PRIEST]      = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.ROGUE]       = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.WARLOCK]     = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.WARRIOR]     = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.SHAMAN]      = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.PALADIN]     = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DEATHKNIGHT] = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.MONK]        = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DEMONHUNTER] = 0;
  CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.EVOKER]      = 0;
end
CensusPlus_Zero_g_TimeDatabase();


--  These two DO NOT need to be localized
local CENSUSPlus_HORDE                  = 'Horde';
local CENSUSPlus_ALLIANCE               = 'Alliance';
local CENSUSPlus_NEUTRAL                = 'Neutral';

local g_FactionCheck                    = {};
g_FactionCheck[CENSUSPLUS_ORC]          = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_TAUREN]       = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_TROLL]        = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_UNDEAD]       = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_BLOODELF]     = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_GOBLIN]       = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_HPANDAREN]    = CENSUSPlus_HORDE;
g_FactionCheck[CENSUSPLUS_HIGHMOUNTAIN] = CENSUSPlus_HORDE; --BFA
g_FactionCheck[CENSUSPLUS_NIGHTBORNE]   = CENSUSPlus_HORDE; --BFA
g_FactionCheck[CENSUSPLUS_MAGHAR]       = CENSUSPlus_HORDE; --BFA
g_FactionCheck[CENSUSPLUS_ZANDALARI]    = CENSUSPlus_HORDE; --BFA
g_FactionCheck[CENSUSPLUS_VULPERA]      = CENSUSPlus_HORDE; --BFA8.3

--[[ Pandaren are the first race to be able to select after character creation their faction membership
    Using the assumption that the mysql database schema is based on Server/Name, Name/Faction and Name/Race
    We could rely just Server and Name as keys into the database, but since the census taking data is formatted as
    Server/Faction/Race/Class/Name - level - guild instead of  Server/Name - faction - race - class - level - guild
    I expect there is a need to keep Race-FactionA separate from Race-FactionH
    This leads to APANDAREN and HPANDAREN
 ]] --

g_FactionCheck[CENSUSPLUS_DWARF]       = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_GNOME]       = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_HUMAN]       = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_NIGHTELF]    = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_DRAENEI]     = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_WORGEN]      = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_APANDAREN]   = CENSUSPlus_ALLIANCE;
g_FactionCheck[CENSUSPLUS_LIGHTFORGED] = CENSUSPlus_ALLIANCE; --BfA
g_FactionCheck[CENSUSPLUS_VOIDELF]     = CENSUSPlus_ALLIANCE; --BfA
g_FactionCheck[CENSUSPLUS_DARKIRON]    = CENSUSPlus_ALLIANCE; --BfA
g_FactionCheck[CENSUSPLUS_KULTIRAN]    = CENSUSPlus_ALLIANCE; --BfA
g_FactionCheck[CENSUSPLUS_MECHAGNOME]  = CENSUSPlus_ALLIANCE; --BfA8.3


--[[
do
	-- HACK
		seeing as Blizzard improperly coded GuildControlPopupFrame_OnEvent to mess up when GUILD_ROSTER_EVENT is dispatched,
		and there is no real harm in removing the handler entirely, that's what's happening. If and when Blizzard decides to fix it, this should be removed.
		Thanks to ckknight of wowace for this

--	GuildControlPopupFrame:SetScript("OnEvent", nil)
end
]]

--[[	-- Print a string to the chat frame
--	msg - message to print
--
]]

local function CensusPlus_Msg(msg)
  if (msg == nil) then
    msg = ' NIL ';
  end
  if (not (g_stealth)) then
    ChatFrame1:AddMessage(CENSUSPLUS_TEXT .. ' ' .. msg, 1.0, 1.0, 0.5);
  end
end

local function CensusPlus_WhoMsg(msg)
  if (msg == nil) then
    msg = ' NIL ';
  end
  ChatFrame1:AddMessage(CENSUSPLUS_TEXT .. ' ' .. WHO .. ': ' .. msg, 0.8, 0.8,
                        0.1);
end

local function CensusPlus_Msg2(msg)
  if (msg == nil) then
    msg = ' NIL ';
  end
  if (not (g_stealth)) then
    ChatFrame2:AddMessage(CENSUSPLUS_TEXT .. ': ' .. msg, 0.5, 1.0, 1.0);
  end
end

--[[ PTR debug messages
--]]
local channel = 0
local channelName = ' '
local channelReady = false
local instanceID = 0
local language = nil; -- nil = common for faction
local HortonBug = false
local HortonFingers = false
local HortonChannel = 'Hortondebug'

local function HortonChatMsg(hotair)
  DEFAULT_CHAT_FRAME:AddMessage(hotair, 0.7, 0.5, 0.7)
end

local function HortonChannelMsg(hotair)
  SendChatMessage(hotair, 'CHANNEL', language, channel)
  --   chattype = CHANNEL  -- language = COMMON  -- channel = channel
end

-- local says = HortonChannelMsg
local says =
    HortonChatMsg -- work around for incomplete work on Starter client sigh
local chat = HortonChatMsg

local function HortonChannelSetup()
  channel, channelName, instanceID = GetChannelName(HortonChannel)
  ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channel)
  channelReady = true
  says('Horton finds his very own channel')
  says('Horton turned on the chatlog')
end

--[[	-- Set up confirmation boxes
--
]]

StaticPopupDialogs['CP_PURGE_CONFIRM'] = {
  text = CENSUSPLUS_PURGE_LOCAL_CONFIRM,
  button1 = YES,
  button2 = NO,
  OnAccept = function()
    CensusPlus_DoPurge();
  end,
  --  sound = "levelup2",
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1
};

--[[	-- Set up Continue after override box  .. no longer valid
--
]]

StaticPopupDialogs['CP_CONTINUE_CENSUS'] = {
  text = CENSUSPlus_OVERRIDE_COMPLET_PAUSED,
  button1 = CENSUSPlus_CONTINUE,
  OnAccept = function()
    CPp.CensusPlusManuallyPaused = false;
    CensusPlusTakeButton:SetText(CENSUSPLUS_PAUSE);
  end,
  --  sound = "levelup2",
  timeout = 0,
  whileDead = 1,
  hideOnEscape = 1,
  showAlert = 1
};

--[[	-- Chat msg hook
--
]]

--[[	-- Insert a job at the end of the job queue
--
]]

local function InsertJobIntoQueue(job)
  --CensusPlus_DumpJob( job );
  table.insert(CensusPlus_JobQueue, job);
end

--[[	-- Initialize the tables of constants for XP calculations
--
]]

local function InitConstantTables()
  -- Total XP required to attain the given level
  for i = 1, MAX_CHARACTER_LEVEL, 1 do
    local val = (i * 5) / MAX_CHARACTER_LEVEL;
    g_TotalCharacterXPPerLevel[i] = math.exp(val);
  end
end

--[[	-- Return a table of races for the input faction
--
]]

function CensusPlus_GetFactionRaces(faction)
  local ret = {};
  if (faction == CENSUSPlus_HORDE) then
    ret = {
      NLZN.RACE.ORC,
      NLZN.RACE.TAUREN,
      NLZN.RACE.TROLL,
      NLZN.RACE.UNDEAD,
      NLZN.RACE.BLOODELF,
      NLZN.RACE.GOBLIN,
      NLZN.RACE.PANDAREN,
      NLZN.RACE.HIGHMOUNTAIN,
      NLZN.RACE.NIGHTBORNE,
      NLZN.RACE.MAGHAR,
      NLZN.RACE.ZANDALARI,
      NLZN.RACE.VULPERA,
      NLZN.RACE.DRACTHYR,
      NLZN.RACE.EARTHEN,
    };
  elseif (faction == CENSUSPlus_ALLIANCE) then
    ret = {
      NLZN.RACE.DWARF,
      NLZN.RACE.GNOME,
      NLZN.RACE.HUMAN,
      NLZN.RACE.NIGHTELF,
      NLZN.RACE.DRAENEI,
      NLZN.RACE.WORGEN,
      NLZN.RACE.PANDAREN,
      NLZN.RACE.LIGHTFORGED,
      NLZN.RACE.VOIDELF,
      NLZN.RACE.DARKIRON,
      NLZN.RACE.KULTIRAN,
      NLZN.RACE.MECHAGNOME,
      NLZN.RACE.DRACTHYR,
      NLZN.RACE.EARTHEN,
    };
  end
  return ret;
end

--[[	-- Return a table of classes for the input faction
--
-- the following function hasn't really been needed since Burning Crusade xPac v2.03..
-- but might (not likely) be needed in the future.
]]

function CensusPlus_GetFactionClasses(faction)
  -- this is last in first out list... add new classes to front of list.
  local ret = {};
  if (faction == CENSUSPlus_HORDE) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.DEMONHUNTER,
      NLZN.CLASS.DEATHKNIGHT,
      NLZN.CLASS.EVOKER,
    };
  elseif (faction == CENSUSPlus_ALLIANCE) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.DEMONHUNTER,
      NLZN.CLASS.DEATHKNIGHT,
      NLZN.CLASS.EVOKER,
    };
  end
  return ret;
end

--[[	-- Return a table of classes for the input race
--
]]


local function GetRaceClasses(race)
  local ret = {};
  if (race == NLZN.RACE.ORC) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
    --		ret = {NLZN.CLASS.WARRIOR, CENSUSPLUS_HUNTER, CENSUSPLUS_ROGUE, CENSUSPLUS_MAGE, CENSUSPLUS_SHAMAN, CENSUSPLUS_WARLOCK, CENSUSPLUS_DEATHKNIGHT, CENSUSPLUS_MONK};
  elseif (race == NLZN.RACE.TAUREN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.TROLL) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.UNDEAD) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.DWARF) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.GNOME) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.HUMAN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.NIGHTELF) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEMONHUNTER,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.BLOODELF) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEMONHUNTER,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.DRAENEI) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.WORGEN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.GOBLIN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.PANDAREN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.HIGHMOUNTAIN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.NIGHTBORNE) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.MAGHAR) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.ZANDALARI) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.LIGHTFORGED) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.VOIDELF) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.DARKIRON) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.KULTIRAN) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.DRUID,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.VULPERA) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif (race == NLZN.RACE.MECHAGNOME) then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.MONK,
      NLZN.CLASS.DEATHKNIGHT,
    };
  elseif race == NLZN.RACE.DRACTHYR then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.EVOKER,
    }
  elseif race == NLZN.RACE.EARTHEN then
    ret = {
      NLZN.CLASS.WARRIOR,
      NLZN.CLASS.HUNTER,
      NLZN.CLASS.MAGE,
      NLZN.CLASS.ROGUE,
      NLZN.CLASS.PRIEST,
      NLZN.CLASS.WARLOCK,
      NLZN.CLASS.PALADIN,
      NLZN.CLASS.SHAMAN,
      NLZN.CLASS.MONK,
    }
  end
  return ret;
end



--[[	-- Return common letters found in zone names
--
-- only used for census splitting by zone.. not used
]]

local function GetZoneLetters()
  return {'t', 'd', 'g', 'f', 'h', 'b', 'x', 'gulch', 'valley', 'basin'};
end

--[[	-- Return common letters found in names, may override this for other languages
--   Worst case scenario is to do it for every letter in the alphabet
--
]]

-- return {"a", "e", "r", "i", "n", "o", "l", "s", "t", "h", "d", "u", "m", "k", "c" };

--[[ see http://www.warcraftrealms.com/forum/viewtopic.php?t=4819&start=40
     Advantage: as seen from data sample
      removing the last 3 selectors "mkc" returned about same counts as current set..
      adding the "mkc" making the selector count the same increased found unique names by %0.17
     disavantage: as seen from data sample
      current selector will generates a duplicate name hit of 3.27 duplicates /unique name
      alternate selector will generate a duplicate name hit of 4.04 duplicates /unique name
      shortened alternate will generate duplicate name hit of 3.47 duplicates /unique name
   ]]

-----------------------------------------------------------------------------------
local function GetNameLetters()
  return {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'o', 'p', 'r', 's', 't', 'u', 'y'};
end
local function GetNameLetters1()
  return {'a', 'e', 'r', 'i', 'n', 'o', 'l', 's', 't', 'h', 'd', 'u', 'm', 'k', 'c'};
end
local function GetNameLetters2()
  return {'a', 'e', 'r', 'i', 'n', 'o', 'l', 's', 't', 'h', 'd', 'u'}
end

local function resetCensusJobs()
  CensusPlus_JobQueue = {};
  CensusPlus_JobQueue.g_NumNewCharacters = 0;
  CensusPlus_JobQueue.g_NumUpdatedCharacters = 0;
  CensusPlus_JobQueue.g_TempCount = nil;
  CensusPlus_JobQueue.g_TempCount = {};
end

--[[	-- Called when the main window is shown
--
]]

function CensusPlus_OnShow() -- referenced by CensusPlus.xml
  -- Initialize if this is the first OnShow event
  if g_CensusPlusInitialized and g_VariablesLoaded then
    CensusPlus_UpdateView();
  end
end

--[[-- Toggle hidden status
--
]]

function CensusPlus_Toggle()
  if (CensusPlus:IsVisible()) then
    CensusPlus:Hide();
  else
    CensusPlus:Show();
  end
end

--[[	-- Toggle options pane
--
]]

function CensusPlus_ToggleOptions(self) -- referenced by CensusPlus.xml
  PlaySound(856, 'Master');
  if (not SettingsPanel:IsShown()) then
    SettingsPanel:Show();
  end
  Settings.OpenToCategory(CensusPlus_OptionCategory:GetID())
end

local function initializeAfterAddonLoaded()
  if CensusPlus_Database.Info == nil then
    CensusPlus_Database['Info'] = {}
    CensusPlus_ResetConfig()
  end
  g_CPWin_background_alpha = CensusPlus_Database.Info.CPWindow_Transparency
  CensusPlusBackground:SetAlpha(g_CPWin_background_alpha / 100)
  CensusPlayerListBackground:SetAlpha(g_CPWin_background_alpha / 100)
end

local CENSUSPLUS_FRAMEPADDING_X, CENSUSPLUS_FRAMEPADDING_Y = 6, 5

---Creates Race bars / legends.
---@param raceCount integer The total race count.
---@param legendWidth integer The legend width.
---@param marginX integer The x margin between each legend.
---@param anchorX number `x` of the TOPLEFT anchor.
---@param anchorY number `y` of the TOPLEFT anchor.
local function createRaceFrames(raceCount, legendWidth, marginX, anchorX, anchorY)
  local raceFrame = CreateFrame('Frame', 'CensusPlusRaceFrame', CensusPlus,
                                'CensusPlusPanelTemplate')
  raceFrame:SetPoint('TOPLEFT', anchorX, anchorY)
  raceFrame:SetSize(
    raceCount * legendWidth + (raceCount - 1) * marginX +
    CENSUSPLUS_FRAMEPADDING_X * 2,
    CENSUSPLUS_FRAMEPADDING_Y * 2 + 130)
  local title = raceFrame:CreateFontString('CensusPlusRacesTitle', 'ARTWORK',
                                           'GameFontHighlight')
  title:SetPoint('CENTER', raceFrame, 'TOP', 0, 12)
  title:SetText(CENSUSPLUS_RACE)
  for i = 1, raceCount do
    local raceLegend = CreateFrame('Button', 'CensusPlusRaceLegend' .. i,
                                   raceFrame, 'CensusPlusRaceLegendTemplate', i)
    raceLegend:SetPoint('TOPLEFT',
                        raceFrame,
                        'BOTTOMLEFT',
                        CENSUSPLUS_FRAMEPADDING_X +
                        (i - 1) * (marginX + legendWidth),
                        -3)
    local raceBar = CreateFrame('Button', 'CensusPlusRaceBar' .. i, raceFrame,
                                'CensusPlusRaceBarTemplate', i)
    raceBar:SetPoint('BOTTOM', raceLegend, 'TOP', 0, 8)
  end
end

---Creates Class bars / legends.
---@param classCount integer The total class count.
---@param legendWidth integer The legend width.
---@param marginX integer The x margin between each legend.
---@param anchorX number `x` of the TOPLEFT anchor.
---@param anchorY number `y` of the TOPLEFT anchor.
local function createClassFrames(
    classCount,
    legendWidth,
    marginX,
    anchorX,
    anchorY)
  local classFrame = CreateFrame('Frame', 'CensusPlusClassFrame', CensusPlus,
                                 'CensusPlusPanelTemplate')
  classFrame:SetPoint('TOPLEFT', anchorX, anchorY)
  classFrame:SetSize(
    classCount * legendWidth + (classCount - 1) * marginX +
    CENSUSPLUS_FRAMEPADDING_X * 2,
    CENSUSPLUS_FRAMEPADDING_Y * 2 + 130)
  local title = classFrame:CreateFontString('CensusPlusClassesTitle', 'ARTWORK',
                                            'GameFontHighlight')
  title:SetPoint('CENTER', classFrame, 'TOP', 0, 12)
  title:SetText(CENSUSPLUS_CLASS)
  for i = 1, classCount do
    local classLegend = CreateFrame('Button', 'CensusPlusClassLegend' .. i,
                                    classFrame, 'CensusPlusClassLegendTemplate',
                                    i)
    classLegend:SetPoint('TOPLEFT',
                         classFrame,
                         'BOTTOMLEFT',
                         CENSUSPLUS_FRAMEPADDING_X +
                         (i - 1) * (marginX + legendWidth),
                         -3)
    local classBar = CreateFrame('Button', 'CensusPlusClassBar' .. i, classFrame,
                                 'CensusPlusClassBarTemplate', i)
    classBar:SetPoint('BOTTOM', classLegend, 'TOP', 0, 8)
  end
end

---Creates level bars.
---@param levelCount integer The total levels.
local function createLevelFrames(levelCount)
  local levelFrame = CreateFrame('Frame', 'CensusPlusLevelFrame', CensusPlus,
                                 'CensusPlusPanelTemplate')
  levelFrame:SetPoint('TOPLEFT', 147, -316)
  levelFrame:SetSize(
    levelCount * 6 + (levelCount - 1) * 4 + CENSUSPLUS_FRAMEPADDING_X * 2,
    CENSUSPLUS_FRAMEPADDING_Y * 2 + 130)
  local title = levelFrame:CreateFontString('CensusPlusLevelsTitle', 'ARTWORK',
                                            'GameFontHighlight')
  title:SetPoint('CENTER', levelFrame, 'TOP', 0, 12)
  title:SetText(CENSUSPLUS_LEVEL)
  for i = 1, levelCount do
    local levelBar = CreateFrame('Button', 'CensusPlusLevelBar' .. i, levelFrame,
                                 'CensusPlusLevelBarTemplate', i)
    local levelBarEmpty = CreateFrame('Button', 'CensusPlusLevelBarEmpty' .. i,
                                      levelFrame,
                                      'CensusPlusLevelBarEmptyTemplate', i)
    if i < 20 then
      levelBar:SetSize(0, 0)
      levelBar:SetPoint('BOTTOMLEFT', levelFrame, 'TOPLEFT', 0, 0)
      levelBarEmpty:SetSize(0, 0)
      levelBarEmpty:SetPoint('BOTTOMLEFT', levelFrame, 'TOPLEFT', 0, 0)
    else
      levelBar:SetPoint('BOTTOMLEFT', levelFrame, 'BOTTOMLEFT',
                        CENSUSPLUS_FRAMEPADDING_X + (i - 1) * (6 + 4),
                        CENSUSPLUS_FRAMEPADDING_Y)
      levelBarEmpty:SetPoint('BOTTOMLEFT', levelFrame, 'TOPLEFT',
                             CENSUSPLUS_FRAMEPADDING_X + (i - 1) * (6 + 4),
                             CENSUSPLUS_FRAMEPADDING_Y)
    end
  end
end

---Creates the guild frame.
---@param anchorX number `x` of the TOPLEFT anchor.
---@param anchorY number `y` of the TOPLEFT anchor.
local function createGuildFrames(anchorX, anchorY)
  local guildButtonCount = 10
  local guildButtonHeight = 16
  local scrollBarWidth = 22
  local guildFrame = CreateFrame('Frame', 'CensusPlusGuildFrame', CensusPlus,
                                 'CensusPlusPanelTemplate')
  guildFrame:SetPoint('TOPLEFT', anchorX, anchorY)
  guildFrame:SetSize(
    250 + CENSUSPLUS_FRAMEPADDING_X * 2 + scrollBarWidth,
    guildButtonHeight * guildButtonCount + CENSUSPLUS_FRAMEPADDING_Y * 2)
  local title = guildFrame:CreateFontString('CensusPlusTopGuildsTitle', 'ARTWORK',
                                            'GameFontHighlight')
  title:SetPoint('CENTER', guildFrame, 'TOP', 0, 12)
  title:SetText(CENSUSPLUS_TOPGUILD)
  for i = 1, guildButtonCount do
    local guildButton = CreateFrame('Button', 'CensusPlusGuildButton' .. i,
                                    guildFrame, 'CensusPlusGuildButtonTemplate',
                                    i)
    guildButton:SetPoint('TOPLEFT', CENSUSPLUS_FRAMEPADDING_X,
                         -((i - 1) * guildButtonHeight + CENSUSPLUS_FRAMEPADDING_Y))
  end
  local guildScrollFrame = CreateFrame('ScrollFrame',
                                       'CensusPlusGuildScrollFrame', guildFrame,
                                       'FauxScrollFrameTemplate')
  guildScrollFrame:SetPoint('TOPLEFT', CENSUSPLUS_FRAMEPADDING_X,
                            -CENSUSPLUS_FRAMEPADDING_Y)
  guildScrollFrame:SetPoint('BOTTOMRIGHT', guildFrame, 'BOTTOMRIGHT',
                            -CENSUSPLUS_FRAMEPADDING_X - scrollBarWidth,
                            CENSUSPLUS_FRAMEPADDING_Y)
  guildScrollFrame:SetScript('OnVerticalScroll', function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, CensusPlus_GUILDBUTTONSIZEY,
                                     CensusPlus_UpdateGuildButtons);
  end)
end

local function initializeRepetitiveFrameItems()
  local raceCount = g_SupportedRaceCount
  local legendWidth = 32
  local marginX = 6
  local raceAnchorX, raceAnchorY = 13, -113
  createRaceFrames(raceCount, legendWidth, marginX, raceAnchorX, raceAnchorY)
  local classAnchorX = 24 + raceAnchorX + raceCount * legendWidth +
      (raceCount - 1) * marginX
  local classAnchorY = raceAnchorY
  local classCount = g_SupportedClassCount
  createClassFrames(classCount, legendWidth, marginX, classAnchorX, classAnchorY)
  createLevelFrames(MAX_CHARACTER_LEVEL)
  local guildAnchorX = 960
  local guildAnchorY = -316
  createGuildFrames(guildAnchorX, guildAnchorY)
end

function CensusPlus_OnLoad(self) -- referenced by CensusPlus.xml
  --print("CensusPlus_OnLoad")

  initializeRepetitiveFrameItems()

  --[[		-- Update the version number
	--
	]]

  CensusPlusText:SetText('Census+ v' ..
    CensusPlus_VERSION ..
    'bpgus' .. CensusPlus_SubVersion .. ' ' .. CPp.CensusPlusLocale);
  -- `www.warcraftrealms.com` is no longer working now. Remove this sentence.
  -- CensusPlusText2:SetText(CENSUSPLUS_UPLOAD);

  --[[		-- Init constant tables
	--
	]]

  InitConstantTables();


  --[[		-- Register for events
	--
	]]

  self:RegisterEvent('ADDON_LOADED');
  self:RegisterEvent('PLAYER_ENTERING_WORLD')

  self:RegisterEvent('ZONE_CHANGED_NEW_AREA');

  --[[	-- Called once on load
--
]]


  -- SLASH_CensusPlusVerbose1 = "/censusverbose";
  -- SlashCmdList["CensusPlusVerbose"] = CensusPlus_Verbose_toggle("alter");

  SLASH_CensusPlusCMD1 = '/CensusPlus';
  SLASH_CensusPlusCMD2 = '/Census+';
  SLASH_CensusPlusCMD3 = '/Census';
  SlashCmdList['CensusPlusCMD'] = CensusPlus_Command;


  CensusPlus_CheckForBattleground();

  --[[	--  Set up an empty frame for updates
	--
	]]
  local updateFrame = CreateFrame('Frame');
  updateFrame:SetScript('OnUpdate', CensusPlus_OnUpdate);
end

local function shuffle(arr)
  for i = 1, #arr - 1 do
    local j = fastrandom(i, #arr)
    arr[i], arr[j] = arr[j], arr[i]
  end
end

local function shuffled_numbers(n)
  local numbers = {}
  for i = 1, n do
    numbers[i] = i
  end
  shuffle(numbers)
  return numbers
end

---Callback to process the Who results.
---@param query string
---@param result WhoInfo[]
function CP_ProcessWhoEvent(query, result)
  local complete = (#result < MAX_WHOS_FROM_SERVER)
  if (CPp.IsCensusPlusInProgress ~= true) then
    return
  end

  local numWhoResults = 0;
  local cpdb_complete_flag = ''
  whoquery_answered = true
  numWhoResults = #result

  if (g_Verbose == true) then
    CensusPlus_Msg(CENSUSPLUS_WHOQUERY ..
      ' ' .. query ..
      ', ' .. CENSUSPLUS_FOUND .. ' ' .. numWhoResults .. cpdb_complete_flag);
    --		CensusPlus_Msg(CENSUSPLUS_WHOQUERY.." "..query);
  end
  --

  if (numWhoResults == 0) then
    --	    print("no results returned")
    local whoText = CensusPlus_CreateWhoText(g_CurrentJob);
    if whoText and whoText == query then
      whoquery_active = false
      whoquery_answered = false
    end
    --	??	-- remove job from the queue
    --	table.remove(CensusPlus_JobQueue)
    return;
  end

  CensusPlus_ProcessWhoResults(result, numWhoResults)

  if complete then return end

  --[[
		-- Who list is overflowed, split the query to make the return smaller
		--
		]]

  local minLevel = g_CurrentJob.m_MinLevel;
  local maxLevel = g_CurrentJob.m_MaxLevel;
  local race = g_CurrentJob.m_Race;
  local class = g_CurrentJob.m_Class;
  local letter = g_CurrentJob.m_Letter;
  local zone = g_CurrentJob.m_Zone;
  local level = minLevel;

  if (minLevel ~= maxLevel) then
    --[[
			-- The level range is greater than a single level, so split it in half and submit the two jobs
			--
			]]
    local pivot = floor((minLevel + maxLevel) / 2);
    local jobLower = CensusPlus_CreateJob(minLevel, pivot, nil, nil, nil);
    InsertJobIntoQueue(jobLower);
    local jobUpper = CensusPlus_CreateJob(pivot + 1, maxLevel, nil, nil, nil);
    InsertJobIntoQueue(jobUpper);
  elseif (race == nil) then
    --[[
				-- This job does not specify race, so split it that way, making jobs for each race
				--
				]]
    local factionGroup = UnitFactionGroup('player');
    local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup);
    local numRaces = #thisFactionRaces;
    for _, i in ipairs(shuffled_numbers(numRaces)) do
      local job = CensusPlus_CreateJob(level, level, thisFactionRaces[i], nil,
                                       nil);
      InsertJobIntoQueue(job);
    end
  elseif (class == nil) then
    --[[
					-- This job does not specify class, so split it that way, making jobs for each class
					--
					]]
    local thisRaceClasses = GetRaceClasses(race);
    local numClasses = #thisRaceClasses;
    --					print(numClasses);
    for _, i in ipairs(shuffled_numbers(numClasses)) do
      --					print(thisRaceClasses[i]);
      local job = CensusPlus_CreateJob(level, level, race,
                                       thisRaceClasses[i], nil);
      InsertJobIntoQueue(job);
    end
  elseif (zone == nil) then
    local shownZones = {}
    for _, whoInfo in ipairs(result) do
      shownZones[whoInfo.area] = (shownZones[whoInfo.area] or 0) + 1
    end
    for shownZone, count in pairs(shownZones) do
      if count > 1 then
        local job = CensusPlus_CreateJob(level, level, race, class, nil,
                                         shownZone)
        InsertJobIntoQueue(job)
      end
    end
  elseif (letter == nil) then
    --[[
						-- There are too many characters with a single level, class and race
						--     The work around we are going to pursue is to check by name for a,e,i,o,r,s,t,u
						--
						]]
    --						print("the dreaded letter splits")
    local letters = {}
    if CP_letterselect == 0 then
      letters = GetNameLetters()
    elseif CP_letterselect == 1 then
      letters = GetNameLetters1()
    elseif CP_letterselect == 2 then
      letters = GetNameLetters2()
    end

    for i = 1, #letters, 1 do
      local job = CensusPlus_CreateJob(level, level, race, class,
                                       letters[i]);
      InsertJobIntoQueue(job);
    end

    --Block of code removed that isn't currently or ever used.. splitting by zone
    --     this commented out section was confusing my editor's code folding routines
  else
    --[[
						-- There are too many characters with a single level, class, race and letter, give up
						--
						]]

    local whoText = CensusPlus_CreateWhoText(g_CurrentJob);
    if (g_Verbose == true) then
      CensusPlus_Msg(format(CENSUSPLUS_TOOMANY, whoText));
    end
  end
end

--[[	-- CensusPlus Friends Frame override to stop the window close sound
--
  ]]

local function CensusPlus_FriendsFrame_OnHide()
  g_Pre_FriendsFrameOnHideOverride();
end

--[[	-- CensusPlus Friends Frame override to stop the window close sound
--
  ]]

local function CensusPlus_FriendsFrame_OnShow()
  g_Pre_FriendsFrameOnShowOverride();
end

--[[	-- CensusPlus command
--
  ]]


function CensusPlus_Command(param)
  local jcmdend = 0
  local jvalend = 0
  local jfolend = 0
  local command = nil
  local value = nil
  local nameval = nil
  local followon = nil
  local levelon = 0
  local _ = nil

  if (param ~= nil) then
    param = string.lower(param)
    _, jcmdend, command = string.find(param, '(%w+)')
    if (command == 'options') then
      CensusPlus_ToggleOptions();
    elseif (command == 'take') then
      CENSUSPLUS_TAKE_OnClick();
    elseif (command == 'me') then
      CensusPlayerOnly = true
      CENSUSPLUS_TAKE_OnClick()
    elseif (command == 'stop') then
      CENSUSPLUS_STOPCENSUS();
    elseif (command == 'serverprune') then
      _, jvalend, value = string.find(param, '(%w+)', jcmdend + 1) -- alphanumeric selector used to warn of bad input
      if (value ~= nil) then
        value = tonumber(value)
        if (value ~= nil) then
          CENSUSPLUS_PRUNEData(value, 1);
        else -- value isn't a number .. bad user input
          CENSUSPLUS_PRUNEData(0, 1);
        end
      else -- value is nil
        CENSUSPLUS_PRUNEData(0, 1);
      end
    elseif (command == 'verbose') then
      CensusPlus_Verbose_toggle('alter');
    elseif (command == 'stealth') then
      CensusPlus_Stealth_toggle('alter');
    elseif (command == 'prune') then
      _, jvalend, value = string.find(param, '(%w+)', jcmdend + 1) -- alphanumeric selector used to warn of bad input
      if (value ~= nil) then
        value = tonumber(value)
        if (value ~= nil) then
          CENSUSPLUS_PRUNEData(value, nil);
        else -- value isn't a number .. bad user input
          CENSUSPLUS_PRUNEData(30, nil);
        end
      else -- value is nil
        CENSUSPLUS_PRUNEData(30, nil);
      end
    elseif (command == 'timer') then
      _, jvalend, value = string.find(param, '(%d+)', jcmdend + 1) -- decimal seletor works here, if bad input just reset timer
      if (value ~= nil) then
        value = tonumber(value)
      end
      CensusPlus_TimerSet(self, value, true)
    elseif (command == 'who') then                                        -- get 2nd term
      _, jvalend, nameval = string.find(param, '(%w+)', jcmdend + 1)      --alphanumeric selector used to give warning of bad input
      if (nameval ~= nil) then                                            -- nameval found non nil
        _, jfalend, followon = string.find(param, '(%a+)', jcmdend + 1)   -- see if same match is found as alpha only
        if (nameval == followon) then                                     -- alpha world so get 3rd term
          _, jfalend, followon = string.find(param, '(%w+)', jvalend + 1) --alphanumeric selector used to give warning of bad input
          if (followon == nil) then                                       -- no 3rd term found
            CensusPlus_InternalWho(string.lower(nameval), nil);
          else                                                            -- 3rd term found
            levelon = tonumber(followon)
            CensusPlus_InternalWho(string.lower(nameval), string.lower(levelon));
          end
        else                                        -- 2nd term is a number
          CensusPlus_Msg(CENSUSPLUS_CMDERR_WHO2NUM) -- 3rd term is NOT a number
        end
      else                                          -- 2nd term is nil
        CensusPlus_Msg(CENSUSPLUS_CMDERR_WHO2)      -- 2nd term is ""
      end
    elseif (command == 'wholibdebug') then
      _, jvalend, value = string.find(param, '(%w+)', jcmdend + 1) -- alphanumeric selector used to warn of bad input
      wholib = wholib or LibStub:GetLibrary('LibWho-3.0', true);
      wholib:SetWhoLibDebug(value)
    elseif (param == 'debug') then
      if (HortonBug == false) then
        chat('Horton puts trunk in Rabbit hole and blows real hard')
        HortonChannelSetup()
        JoinTemporaryChannel(HortonChannel)
        LoggingChat(true)
        HortonBug = true
        says('Hello HortonChannel')
      else
        says('Horton turns off the chatlog')
        LoggingChat(false)
        HortonBug = false
      end
    else
      CensusPlus_DisplayUsage();
    end
  else
    CensusPlus_DisplayUsage()
  end
end

function CensusPlus_Verbose()
  --print(CensusPlus_Database["Info"]["Verbose"])
  --print(CensusPlus_PerCharInfo["Verbose"])
  if ((CensusPlus_PerCharInfo['Verbose'] == nil) and (CensusPlus_Database['Info']['Verbose'] == true)) then
    --print("verbose 1")
    CensusPlus_Verbose_toggle('On')
  elseif ((CensusPlus_PerCharInfo['Verbose'] == nil) and (CensusPlus_Database['Info']['Verbose'] == false)) then
    --print("verbose 2")
    CensusPlus_Verbose_toggle('Off')
  elseif (CensusPlus_PerCharInfo['Verbose'] == true) then
    --print("verbose 3")
    CensusPlus_Verbose_toggle('On')
  elseif (CensusPlus_PerCharInfo['Verbose'] == false) then
    --print("verbose 4")
    CensusPlus_Verbose_toggle('Off')
  else
    --print("call verbose farm")
  end
end

function CensusPlus_Verbose_toggle(state)
  --print(g_Verbose)
  --print(state)
  if (state == 'alter') then
    if (g_Verbose == true) then
      g_Verbose = false
      CensusPlus_Msg(CENSUSPLUS_VERBOSEOFF)
    else
      g_Verbose = true
      g_stealth = false
      CensusPlus_Msg(CENSUSPLUS_VERBOSEON)
    end
  elseif (state == 'On') then
    g_Verbose = true
    g_stealth = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_VERBOSEON)
    end
  elseif (state == 'Off') then
    g_Verbose = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_VERBOSEOFF)
    end
  end
end

local function CensusPlus_Stealth()
  --print(CensusPlus_Database["Info"]["Stealth"])
  --print(CensusPlus_PerCharInfo["Stealth"])
  if ((CensusPlus_PerCharInfo['Stealth'] == nil) and (CensusPlus_Database['Info']['Stealth'] == true)) then
    --print("stealth 1")
    CensusPlus_Stealth_toggle('On')
  elseif ((CensusPlus_PerCharInfo['Stealth'] == nil) and (CensusPlus_Database['Info']['Stealth'] == false)) then
    --print("stealth 2")
    CensusPlus_Stealth_toggle('Off')
  elseif (CensusPlus_PerCharInfo['Stealth'] == true) then
    --print("stealth 3")
    CensusPlus_Stealth_toggle('On')
  elseif (CensusPlus_PerCharInfo['Stealth'] == false) then
    --print("stealth 4")
    CensusPlus_Stealth_toggle('Off')
  else
    --print("call stealth farm")
  end
end

function CensusPlus_Stealth_toggle(state)
  if (state == 'alter') then
    if (g_stealth == true) then
      g_stealth = false
      CensusPlus_Msg(CENSUSPLUS_STEALTHOFF)
    else
      g_Verbose = false
      CensusPlus_Msg(CENSUSPLUS_STEALTHON)
      g_stealth = true
    end
  elseif (state == 'On') then
    g_Verbose = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_STEALTHON)
    end
    g_stealth = true
  elseif (state == 'Off') then
    g_stealth = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_STEALTHOFF)
    end
  end
end

local function CensusPlus_CensusButtonShown()
  --print(CensusPlus_Database["Info"]["CensusButtonShown"])
  --print(CensusPlus_PerCharInfo["CensusButtonShown"])
  if ((CensusPlus_PerCharInfo['CensusButtonShown'] == nil) and (CensusPlus_Database['Info']['CensusButtonShown'] == true)) then
    --print("CensusButtonShown 1")
    --_G[CensusButton:GetName().."Text"]:SetText("C+")
    CensusPlus_CensusButtonShown_toggle('On')
  elseif ((CensusPlus_PerCharInfo['CensusButtonShown'] == nil) and (CensusPlus_Database['Info']['CensusButtonShown'] == false)) then
    --print("CensusButtonShown 2")
    CensusPlus_CensusButtonShown_toggle('Off')
  elseif (CensusPlus_PerCharInfo['CensusButtonShown'] == true) then
    --print("CensusButtonShown 3")
    --CensusButton:SetText("30")
    CensusPlus_CensusButtonShown_toggle('On')
  elseif (CensusPlus_PerCharInfo['CensusButtonShown'] == false) then
    --print("CensusButtonShown 4")
    CensusPlus_CensusButtonShown_toggle('Off')
  else
    --print("call CensusButtonShown farm")
  end
end

function CensusPlus_CensusButtonShown_toggle(state)
  if (state == 'alter') then
    if (g_CensusButtonShown == true) then
      g_CensusButtonShown = false
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONSHOWNOFF)
      CensusButtonFrame:Hide()
    else
      g_CensusButtonShown = true
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONSHOWNON)
      CensusButtonFrame:Show()
    end
  elseif (state == 'On') then
    g_CensusButtonShown = true
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONSHOWNON)
    end
    CensusButtonFrame:Show()
  elseif (state == 'Off') then
    g_CensusButtonShown = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONSHOWNOFF)
    end
    CensusButtonFrame:Hide()
  end
end

local function CensusPlus_CensusButtonAnimi()
  --print(CensusPlus_Database["Info"]["CensusButtonAnimi"])
  --print(CensusPlus_PerCharInfo["CensusButtonAnimi"])
  if ((CensusPlus_PerCharInfo['CensusButtonAnimi'] == nil) and (CensusPlus_Database['Info']['CensusButtonAnimi'] == true)) then
    --print("CensusButtonAnimi 1")
    --_G[CensusButton:GetName().."Text"]:SetText("C+")
    CensusPlus_CensusButtonAnimi_toggle('On')
  elseif ((CensusPlus_PerCharInfo['CensusButtonAnimi'] == nil) and (CensusPlus_Database['Info']['CensusButtonAnimi'] == false)) then
    --print("CensusButtonAnimi 2")
    CensusPlus_CensusButtonAnimi_toggle('Off')
  elseif (CensusPlus_PerCharInfo['CensusButtonAnimi'] == true) then
    --print("CensusButtonAnimi 3")
    --CensusButton:SetText("30")
    CensusPlus_CensusButtonAnimi_toggle('On')
  elseif (CensusPlus_PerCharInfo['CensusButtonAnimi'] == false) then
    --print("CensusButtonAnimi 4")
    CensusPlus_CensusButtonAnimi_toggle('Off')
  else
    --print("call CensusButtonAnimi farm")
  end
end


function CensusPlus_CensusButtonAnimi_toggle(state)
  if (state == 'alter') then
    if (g_CensusButtonAnimi == true) then
      g_CensusButtonAnimi = false
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONANIMIOFF)
      CensusButton:SetNormalFontObject(GameFontNormal)
      CensusButton:SetText('C+')
    else
      g_CensusButtonAnimi = true
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONANIMION)
      --			CensusButtonFrame:Show()
    end
  elseif (state == 'On') then
    g_CensusButtonAnimi = true
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONANIMION)
    end
    --		CensusButtonFrame:Show()
  elseif (state == 'Off') then
    g_CensusButtonAnimi = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_CENSUSBUTTONANIMIOFF)
    end
    CensusButton:SetNormalFontObject(GameFontNormal)
    CensusButton:SetText('C+')
  end
end

function CensusPlus_FinishSound()
  --print(CensusPlus_Database["Info"]["PlayFinishSound"])
  --print(CensusPlus_PerCharInfo["PlayFinishSound"])
  if ((CensusPlus_PerCharInfo['PlayFinishSound'] == nil) and (CensusPlus_Database['Info']['PlayFinishSound'] == true)) then
    --print("FinishSound 1")
    --_G[CensusButton:GetName().."Text"]:SetText("C+")
    CensusPlus_FinishSound_toggle('On')
  elseif ((CensusPlus_PerCharInfo['PlayFinishSound'] == nil) and (CensusPlus_Database['Info']['PlayFinishSound'] == false)) then
    --print("FinishSound 2")
    CensusPlus_FinishSound_toggle('Off')
  elseif (CensusPlus_PerCharInfo['PlayFinishSound'] == true) then
    --print("FinishSound 3")
    --CensusButton:SetText("30")
    CensusPlus_FinishSound_toggle('On')
  elseif (CensusPlus_PerCharInfo['PlayFinishSound'] == false) then
    --print("FinishSound 4")
    CensusPlus_FinishSound_toggle('Off')
  else
    --print("call FinishSound farm")
  end
end

function CensusPlus_FinishSound_toggle(state)
  if (state == 'alter') then
    if (g_PlayFinishSound == true) then
      g_PlayFinishSound = false
      CensusPlus_Msg(CENSUSPLUS_PLAYFINISHSOUNDOFF)
    else
      g_PlayFinishSound = true
      CensusPlus_Msg(CENSUSPLUS_PLAYFINISHSOUNDON)
    end
  elseif (state == 'On') then
    g_PlayFinishSound = true
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_PLAYFINISHSOUNDON)
    end
  elseif (state == 'Off') then
    g_PlayFinishSound = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_PLAYFINISHSOUNDOFF)
    end
  end
end

--[[	-- CensusPlus Auto Census set flag
--
  ]]

local function CensusPlus_SetAutoCensus()
  --print(CensusPlus_Database["Info"]["AutoCensus"]) --((CensusPlus_PerCharInfo["AutoCensus"] == nil)and
  --print(CensusPlus_PerCharInfo["AutoCensus"])
  if ((CensusPlus_PerCharInfo['AutoCensus'] == nil) and (CensusPlus_Database['Info']['AutoCensus'] == true)) then
    --print("AutoCensus 1")
    --_G[CensusButton:GetName().."Text"]:SetText("C+")
    CensusPlus_AutoCensus_toggle('On')
  elseif ((CensusPlus_PerCharInfo['AutoCensus'] == nil) and (CensusPlus_Database['Info']['AutoCensus'] == false)) then
    --print("AutoCensus 2")
    CensusPlus_AutoCensus_toggle('Off')
  elseif (CensusPlus_PerCharInfo['AutoCensus'] == true) then
    --print("AutoCensus 3")
    --CensusButton:SetText("30")
    CensusPlus_AutoCensus_toggle('On')
  elseif (CensusPlus_PerCharInfo['AutoCensus'] == false) then
    --print("AutoCensus 4")
    CensusPlus_AutoCensus_toggle('Off')
  else
    print('call AutoCensus farm')
  end
end

function CensusPlus_AutoCensus_toggle(state)
  if (state == 'alter') then
    if (CPp.AutoCensus == true) then
      CPp.AutoCensus = false
      CensusPlus_Msg(CENSUSPLUS_AUTOCENSUSOFF)
    else
      CPp.AutoCensus = true
      CensusPlus_Msg(CENSUSPLUS_AUTOCENSUSON)
    end
  elseif (state == 'On') then
    CPp.AutoCensus = true
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_AUTOCENSUSON)
    end
  elseif (state == 'Off') then
    CPp.AutoCensus = false
    if (g_Options_confirm_txt and (not (CPp.FirstLoad == true))) then
      CensusPlus_Msg(CENSUSPLUS_AUTOCENSUSOFF)
    end
  end
end

--[[	-- CensusPlus Display Usage
--
  ]]

function CensusPlus_DisplayUsage()
  --    local text;

  CensusPlus:Show();
  local stealthUsage = g_stealth
  g_stealth = false
  CensusPlus_Msg(CENSUSPLUS_USAGE ..
    '\n  /CensusPlus' ..
    CENSUSPLUS_OR ..
    '/Census+ ' .. CENSUSPLUS_OR .. '/Census' .. CENSUSPLUS_AND ..
    CENSUSPLUS_HELP_0);
  CensusPlus_Msg('  /CensusPlus ' .. CENSUS_OPTIONS_VERBOSE .. CENSUSPLUS_HELP_1);
  CensusPlus_Msg('  /CensusPlus ' .. CENSUS_OPTIONS_STEALTH .. CENSUSPLUS_HELP_11);
  CensusPlus_Msg('  /CensusPlus ' .. CENSUSPLUS_BUTTON_OPTIONS ..
    CENSUSPLUS_HELP_2);
  CensusPlus_Msg('  /CensusPlus ' .. CENSUSPLUS_TAKE .. CENSUSPLUS_HELP_3);
  CensusPlus_Msg('  /CensusPlus ' .. CENSUSPLUS_STOP .. CENSUSPLUS_HELP_4);
  CensusPlus_Msg('  /CensusPlus ' .. CENSUSPLUS_PRUNE .. CENSUSPLUS_HELP_5);
  CensusPlus_Msg('  /CensusPlus serverprune' .. CENSUSPLUS_HELP_6);
  CensusPlus_Msg('  /CensusPlus who name' .. CENSUSPLUS_HELP_7);
  CensusPlus_Msg('  /CensusPlus who unguilded 70' .. CENSUSPLUS_HELP_8);
  CensusPlus_Msg('  /CensusPlus timer X ' .. CENSUSPLUS_HELP_9);
  CensusPlus_Msg('  /CensusPlus me' .. CENSUSPLUS_HELP_10);
  g_stealth = stealthUsage
end

--[[	-- CensusPlus_InternalWho -  will go through our local database and see if we have
--		any info on this person
--
  ]]

function CensusPlus_InternalWho(search, level)
  if (CPp.CensusPlusLocale == 'N/A') then
    return;
  end

  g_InternalSearchName = search;
  g_InternalSearchLevel = level;
  g_InternalSearchCount = 0;
  local realmName = CPp.CensusPlusLocale .. GetRealmName();
  local stsrt, _, _ = string.find(realmName, '%(')
  if stsrt ~= nil then
    realmName = string.sub(realmName, 1, stsrt - 2)
  end

  CensusPlus_ForAllCharacters(realmName, UnitFactionGroup('player'), nil, nil,
                              nil, nil, nil, CensusPlus_InternalWhoResult)

  CensusPlus_WhoMsg(CENSUSPLUS_FOUND_CAP ..
    g_InternalSearchCount .. CENSUSPLUS_PLAYERS);
end

function CensusPlus_InternalWhoResult(name, level, guild, race, class, lastSeen)
  lowerName = string.lower(name);
  level = string.lower(level);
  lowerGuild = string.lower(CensusPlus_SafeCheck(guild));
  if (g_InternalSearchName == 'unguilded') then
    if (guild == '') then
      local doit = 1;
      if (g_InternalSearchLevel ~= nil) then
        if (g_InternalSearchLevel ~= level) then
          doit = 0;
        end
      end
      if (doit == 1) then
        local out = name ..
            ' : ' .. LEVEL .. ' ' .. level .. ' ' .. race .. ' ' .. ' ' .. class;
        out = out .. CENSUSPLUS_LASTSEEN_COLON .. lastSeen;
        CensusPlus_WhoMsg(out);
        g_InternalSearchCount = g_InternalSearchCount + 1;
      end
    end
  elseif (string.find(lowerName, g_InternalSearchName) or string.find(lowerGuild, g_InternalSearchName)) then
    -- found someone!
    local out = name ..
        ' : ' .. LEVEL .. ' ' .. level .. ' ' .. race .. ' ' .. ' ' .. class;
    if (guild ~= '') then
      out = out .. ' <' .. guild .. '>';
    end
    out = out .. CENSUSPLUS_LASTSEEN_COLON .. lastSeen;
    CensusPlus_WhoMsg(out);
    g_InternalSearchCount = g_InternalSearchCount + 1;
  end
end

--[[	-- Minimize the window
--
  ]]

function CensusPlus_OnClickMinimize(self) -- referenced by CensusPlus.xml
  if (CensusPlus:IsVisible()) then
    --        MiniCensusPlus:Show();
    CensusPlus:Hide();
  end
end

--[[	-- Minimize the window
--
  ]]

function CensusPlus_OnClickMaximize(self) -- referenced by CensusPlus.xml
  if (MiniCensusPlus:IsVisible()) then
    MiniCensusPlus:Hide();
    CensusPlus:Show();
  end
end

--[[	-- Take or pause a census depending on current status
--
  ]]

function CENSUSPLUS_TAKE_OnClick(self) -- referenced by CensusPlus.xml
  if (CPp.IsCensusPlusInProgress) then
    --      CensusPlus_Msg(CENSUSPLUS_ISINPROGRESS);	
    CensusPlus_TogglePause();
  else
    CensusPlus_StartCensus();
  end
end

--[[	-- Display a tooltip for the take button
--
  ]]

function CENSUSPLUS_TAKE_OnEnter(self, motion) -- referenced by CensusPlus.xml
  if (motion == true) then
    if (CPp.IsCensusPlusInProgress) then
      if (CPp.CensusPlusManuallyPaused) then
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:SetText(CENSUSPLUS_UNPAUSECENSUS, 1.0, 1.0, 1.0);
        GameTooltip:Show();
      else
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
        GameTooltip:SetText(CENSUSPLUS_PAUSECENSUS, 1.0, 1.0, 1.0);
        GameTooltip:Show();
      end
    else
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
      GameTooltip:SetText(CENSUSPLUS_TAKECENSUS, 1.0, 1.0, 1.0);
      GameTooltip:Show();
    end
  else -- frame created underneath cursor.. not cursor movement to frame
  end
end

function CENSUSPLUS_STOP_OnEnter(self, motion) -- referenced by CensusPlus.xml
  if (motion == true) then
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
    GameTooltip:SetText(CENSUSPLUS_STOPCENSUS_TOOLTIP, 1.0, 1.0, 1.0);
    GameTooltip:Show();
  else -- frame created underneath cursor.. not cursor movement to frame
  end
end

function CensusPlus_TimerSet(self, minutes, ovrride)
  if minutes == nil then
    minutes = 30
  end
  if (ovrride) then
    CensusPlus_PerCharInfo['AutoCensusTimer'] = minutes * 60;
    --		print("CCO Timer = "..minutes)
  else
    CensusPlus_Database['Info']['AutoCensusTimer'] = minutes * 60;
    --		print("AW timer = "..minutes)
  end
  --	CensusPlus_Msg( CENSUS_OPTIONS_AUTOCENSUS.." "..CENSUSPLUS_AUTOCENSUS_DELAYTIME .." ".. minutes);
end

local function CensusPlus_BackgroundAlpha(self, steps)
  CensusPlus_Database['Info']['CPWindow_Transparency'] = steps
end

--[[	-- Pause the current census
--
  ]]

function CensusPlus_TogglePause()
  if (CPp.IsCensusPlusInProgress == true) then
    if (CPp.CensusPlusManuallyPaused == true) then
      CensusPlusTakeButton:SetText(CENSUSPLUS_PAUSE);
      CPp.CensusPlusManuallyPaused = false;
    else
      CensusPlusTakeButton:SetText(CENSUSPLUS_UNPAUSE);
      if (g_Verbose == true) then
        CensusPlus_Msg(CENSUSPLUS_PAUSECENSUS);
      end

      CPp.CensusPlusManuallyPaused = true;
      CensusPlayerOnly = false
    end
  end
end

--[[	-- Purge the database for this realm and faction
--
  ]]

function CENSUSPLUS_PURGE_OnClick() -- referenced by CensusPlus.xml
  StaticPopup_Show('CP_PURGE_CONFIRM');
end

--[[	-- CensusPlus_DoPurge
--
  ]]

function CensusPlus_DoPurge()
  CPp.DatabaseOperation.Purge()
  CensusPlus_UpdateView();
  if (not (CPp.FirstLoad == true)) then
    CensusPlus_Msg(CENSUSPLUS_PURGEDALL)
  end
end

--[[	-- Take a CensusPlus
--
  ]]

function CensusPlus_StartCensus()
  CensusPlusTakeButton:SetText(CENSUSPLUS_PAUSE);

  --[[ work in progress - continue census run from last state on DC or valid Character stop restart.
Determine if pre-existing jobqueue exists from running job that was DCed or paused and logged out.
if exists that determine delay since last queue completion..
if more then x time then dump queues and restart as new start else set below states to active run status and process existing queues.
--]]

  g_FirstRun = true -- used to trigger queue processing when OnUpdate
  local g_factionGroup = UnitFactionGroup('player');
  local realm = '';
  local lastjobtimediff = 1;
  realm = GetRealmName();
  realm = PTR_Color_ProblemRealmGuilds_check(realm);
  local realmName = CPp.CensusPlusLocale .. realm;
  -- print( "Prep for start");
  if (CensusPlus_JobQueue.CensusPlus_last_time and CensusPlus_JobQueue.CensusPlus_last_time > 1) then
    lastjobtimediff = time() - CensusPlus_JobQueue.CensusPlus_last_time;
    --		print( "got time");
    --		print( lastjobtimediff);
  else
    CensusPlus_JobQueue.CensusPlus_last_time = 1000;
    lastjobtimediff = time() - CensusPlus_JobQueue.CensusPlus_last_time;
    --		print( "fake time");
    --		print( lastjobtimediff);
  end
  if (not (CensusPlus_JobQueue.CensusPlus_LoginRealm)) then
    CensusPlus_JobQueue.CensusPlus_LoginRealm = ' ';
    --		print( "typed Realm");
  end
  if (not (CensusPlus_JobQueue.CensusPlus_LoginFaction)) then
    CensusPlus_JobQueue.CensusPlus_LoginFaction = ' ';
    --		print( "typed faction");
  end
  --	print(lastjobtimediff);
  if (lastjobtimediff <= 300 and CensusPlus_JobQueue.CensusPlus_LoginFaction and CensusPlus_JobQueue.CensusPlus_LoginRealm and
        (CensusPlus_JobQueue.CensusPlus_LoginFaction == g_factionGroup) and (CensusPlus_JobQueue.CensusPlus_LoginRealm == realmName)) then
    --		print ("continue last Census");
    local queue_entry_count = #CensusPlus_JobQueue;
    --		print (queue_entry_count);
    g_FirstRun = false;
  else
    --		print ("Start new Census");
    resetCensusJobs()
    CensusPlus_Zero_g_TimeDatabase();
    CPp.VRealms = nil;
    CPp.VRealms = {};
  end

  CPp.ConnectedRealmsButton = 0      -- reset connected realms member realm selector
  CensusPlus_CheckCRealmDateStatus() -- reset CensusPlus_CRealm date on UTC rollover
  CensusPlus_UpdateView()
  if (g_factionGroup == nil or g_factionGroup == CENSUSPlus_NEUTRAL) then
    CensusPlus_Msg(CENSUSPLUS_NOTINFACTION);
    CPp.LastCensusRun = time()
    --     return;
  elseif (CPp.IsCensusPlusInProgress) then
    --  if( CPp.CensusPlusManuallyPaused == true ) then
    --      CPp.CensusPlusManuallyPaused = false;
    --      CensusPlusPauseButton:SetText( CENSUSPLUS_PAUSE );
    --  else
    -- D.o not initiate a new CensusPlus whi.le one is in progress
    CensusPlus_Msg('Census in progress but this message should not have shown');
    --	    return
    --  end
  elseif (g_CurrentlyInBG) then
    CPp.LastCensusRun = time() - 600;
    if (not g_CurrentlyInBG_Msg) then
      CensusPlus_Msg(CENSUSPLUS_ISINBG);
      g_CurrentlyInBG_Msg = true;
    end
  else
    --
    --  Set a timer
    --
    g_CensusPlus_StartTime = time();

    --
    -- Initialize the job queue and counters
    --
    CensusPlus_Msg(CENSUSPLUS_TAKINGONLINE);

    local realm = '';
    realm = GetRealmName();
    --debug
    if (HortonBug == true) then
      says('local realm = ' .. realm);
      says('LE_REALM_RELATION_SAME = ' .. LE_REALM_RELATION_SAME)
      says('LE_REALM_RELATION_COALESCED = ' .. LE_REALM_RELATION_COALESCED)
      says('LE_REALM_RELATION_VIRTUAL = ' .. LE_REALM_RELATION_VIRTUAL)
    end

    realm = PTR_Color_ProblemRealmGuilds_check(realm);
    local realmName = CPp.CensusPlusLocale .. realm;
    CensusPlus_JobQueue.CensusPlus_LoginRealm = realmName;
    CensusPlus_JobQueue.CensusPlus_LoginFaction = g_factionGroup;
    if (HortonBug == true) then
      says('after check local realm = ' .. realmName);
    end

    table.insert(CPp.VRealms, realmName);

    if CensusPlayerOnly then
      if (UnitLevel('player') >= MIN_CHARACTER_LEVEL) then
        -- queue who for player into job que
        local meplayer = GetUnitName('player')
        local job = CensusPlus_CreateJob(MIN_CHARACTER_LEVEL, MAX_CHARACTER_LEVEL,
                                         nil, nil, meplayer)
        InsertJobIntoQueue(job)
        CPp.IsCensusPlusInProgress = true;
        CPp.CensusPlusManuallyPaused = false;

        local hour, minute = GetGameTime();
        g_TakeHour = hour;
        g_ResetHour = true;

        wholib = wholib or LibStub:GetLibrary('LibWho-3.0', true);
      elseif (UnitLevel('player') < MIN_CHARACTER_LEVEL) then
        CensusPlus_Msg('Player is below level 20')
        CensusPlayerOnly = false
      elseif (CPp.IsCensusPlusInProgress) then
        CensusPlus_Msg(CENSUSPLUS_ISINPROGRESS)
        CensusPlayerOnly = false
      end
      --					CensusPlus_Msg("line 1554")
      --			return
    else
      --					CensusPlus_Msg("line 1556")

      --
      -- add modify Censusplus button to show job activation
      if (CensusPlus_Database['Info']['CensusButtonAnimi'] == true) then
        --			local fontstring = CensusButton:GetFontString()
        --			print(fontstring)
        --			local fontobj = CensusButton:GetNormalFontObject()
        --			print (fontobj)
        CensusButton:SetNormalFontObject(GameFontNormalSmall)
        --			local fontobj2 = CensusButton:GetNormalFontObject()
        --			print (fontobj2)
        --		CensusButton:SetNormalFontObject(GameFontNormal)
        --			local fontobj3 = CensusButton:GetNormalFontObject()
        --			print (fontobj3)
        CensusButton:SetText(MAX_CHARACTER_LEVEL)
      end

      if (g_FirstRun) then
        CensusPlus_Load_JobQueue();
      end;


      CPp.IsCensusPlusInProgress = true;
      CPp.CensusPlusManuallyPaused = false;

      local hour, minute = GetGameTime();
      g_TakeHour = hour;
      g_ResetHour = true;

      wholib = wholib or LibStub:GetLibrary('LibWho-3.0', true);
      --
      --  Subvert WhoLib
      --
      if (wholib) then
        CensusPlus_Msg(CENSUSPLUS_USING_WHOLIB);
        --				CensusPlus_UPDATEDELAY = 60

        --wholib.RegisterCallback("CensusPlus", "WHOLIB_QUERY_RESULT", CensusPlus_WhoLibEvent)
      end
    end
  end
end

--
-- First we load the stack with our jobs... First in last out
--
function CensusPlus_Load_JobQueue()
  --		local job = {m_MinLevel = 1, m_MaxLevel = MAX_CHARACTER_LEVEL};
  --		InsertJobIntoQueue(job);
  --
  -- as requested by users.. load run for player .. so it is last job processed
  --		local meplayer = GetUnitName("player")
  --		local job = CensusPlus_CreateJob(1,MAX_CHARACTER_LEVEL,nil,nil,meplayer)
  --		InsertJobIntoQueue(job)
  --  Modified job listing, let's go in 5 level increments
  --
  if (MIN_CHARACTER_LEVEL % 10 == 0) then
    local job = CensusPlus_CreateJob(MIN_CHARACTER_LEVEL, MIN_CHARACTER_LEVEL,
                                     nil, nil, nil);
    InsertJobIntoQueue(job)
  end

  -- first load queue with jobs in increment of 10 from 1-10 thru max_character_level-19 - max_character_level-10
  if (MAX_CHARACTER_LEVEL % 10 == 0) then
    --
    --
    for counter = MIN_CHARACTER_LEVEL / 10, floor(MAX_CHARACTER_LEVEL / 10) - 2, 1 do
      local job = CensusPlus_CreateJob(counter * 10 + 1, counter * 10 + 10, nil,
                                       nil, nil);
      InsertJobIntoQueue(job);
    end
  else -- or load queue with jobs in increment of 10 from 1-10 thru max_character_level-14 - max_character_level-5
    for counter = MIN_CHARACTER_LEVEL / 10, floor(MAX_CHARACTER_LEVEL / 10) - 1, 1 do
      local job = CensusPlus_CreateJob(counter * 10 + 1, counter * 10 + 10, nil,
                                       nil, nil);
      InsertJobIntoQueue(job);
    end
  end
  -- next to last job to load is Max_character_level-9 thrun Max_character_level-1  if Max_character_level modulo 10 = 0
  if (MAX_CHARACTER_LEVEL % 10 == 0) then
    local job = CensusPlus_CreateJob(MAX_CHARACTER_LEVEL - 9,
                                     MAX_CHARACTER_LEVEL - 1, nil, nil, nil);
    InsertJobIntoQueue(job);
  else
    -- next to last job to load is Max_character_level-4 thrun Max_character_level-1  if Max_character_level modulo 10 = 5
    local job = CensusPlus_CreateJob(MAX_CHARACTER_LEVEL - 4,
                                     MAX_CHARACTER_LEVEL - 1, nil, nil, nil);
    InsertJobIntoQueue(job);
  end

  -- last job to load in last in first out queus is MAX_CHARACTER_LEVEL to MAX_CHARACTER_LEVEL
  -- this is one job that will almost always en.d up having to be broken up and reloaded (depending on realm population)
  local job = CensusPlus_CreateJob(MAX_CHARACTER_LEVEL, MAX_CHARACTER_LEVEL, nil,
                                   nil, nil);
  InsertJobIntoQueue(job);

  --        for counter = 60, MAX_CHARACTER_LEVEL, 1  d.o
  --			local job = CensusPlus_CreateJob( counter, counter, nil, nil, nil );
  --			InsertJobIntoQueue(job);
  --        e.nd

  --	Test inserts
  --        local job = CensusPlus_CreateJob( 11, 12, "Troll", nil, nil );
  --        InsertJobIntoQueue(job);
end

--[[	-- Stop a CensusPlus
--
  ]]

function CENSUSPLUS_STOPCENSUS() -- referenced by CensusPlus.xml
  if (CPp.IsCensusPlusInProgress) then
    CensusPlusTakeButton:SetText(CENSUSPLUS_TAKE);
    CPp.CensusPlusManuallyPaused = false;
    whoquery_answered = false;
    whoquery_active = false

    CensusPlusScanProgress:SetText(CENSUSPLUS_SCAN_PROGRESS_0);


    CensusPlus_DisplayResults();
    resetCensusJobs()

    --  Clean up the times
    CENSUSPLUS_PRUNETimes();
  else
    CensusPlus_Msg(CENSUSPLUS_NOCENSUS);
  end
  --
  -- Add revert CensusButton back to defauit
  CensusButton:SetNormalFontObject(GameFontNormal)
  CensusButton:SetText('C+')
end

--[[	-- Display Census results
--
  ]]

function CensusPlus_DisplayResults()
  --
  -- We are all done, report our results
  --
  CPp.IsCensusPlusInProgress = false;
  CensusPlusScanProgress:SetText(CENSUSPLUS_SCAN_PROGRESS_0);
  g_Consecutive = g_Consecutive + 1;
  CensusPlusConsecutive:SetText(format(CENSUSPLUS_CONSECUTIVE, g_Consecutive));

  --
  --  Finish our timer
  --
  local total_time = time() - g_CensusPlus_StartTime;
  local realmslisttext = ''
  whoquery_active = false
  if (not (g_stealth)) then
    --	print( CensusPlus_JobQueue.g_NumNewCharacters);
    --	print( CensusPlus_JobQueue.g_NumUpdatedCharacters);
    CensusPlus_Msg(format(CENSUSPLUS_FINISHED,
                          CensusPlus_JobQueue.g_NumNewCharacters,
                          CensusPlus_JobQueue.g_NumUpdatedCharacters,
                          SecondsToTime(total_time)));
    --		print( CP_g_queue_count);
    if (CP_g_queue_count > 0) then
      local avg_Time_per_que = total_time / CP_g_queue_count
      --			print( avg_Time_per_que);
    end
    ChatFrame1:AddMessage(CENSUSPLUS_CONNECTEDREALMSFOUND, 1.0, 0.3, 0.1)
    for k, v in pairs(CPp.VRealms) do
      realmslisttext = realmslisttext .. ', ' ..
          v
    end
    realmslisttext = string.sub(realmslisttext, 3)
    ChatFrame1:AddMessage(realmslisttext, 1.0, 0.3, 0.1)
  end
  CensusPlus_UpdateView();
  CPp.LastCensusRun = time();
  CensusPlus_JobQueue.g_NumNewCharacters = 0;
  CensusPlus_JobQueue.g_NumUpdatedCharacters = 0;
  CensusPlusTakeButton:SetText(CENSUSPLUS_TAKE);
end

--[[	-- Create a who command text for the input job
--
  ]]

function CensusPlus_CreateWhoText(job)
  local whoText = '';
  local race = job.m_Race;
  if (race ~= nil) then
    whoText = whoText .. ' r-\"' .. NLZN.T(race) .. '\"';
  end

  local class = job.m_Class;
  if (class ~= nil) then
    whoText = whoText .. ' c-\"' .. NLZN.T(class) .. '\"';
  end

  local letter = job.m_Letter;
  if (letter ~= nil) then
    whoText = whoText .. ' n-' .. letter;
  end

  local zone = job.m_Zone;
  if (zone ~= nil) then
    whoText = whoText .. ' z-"' .. zone .. '"';
  end

  local minLevel = tostring(job.m_MinLevel);
  if (minLevel == nil) then
    minLevel = '1';
  end
  local maxLevel = job.m_MaxLevel;
  if (maxLevel == nil) then
    maxLevel = MAX_CHARACTER_LEVEL;
  end
  whoText = whoText .. ' ' .. minLevel .. '-' .. maxLevel;

  return whoText;
end

--[[	-- Create a job
--
  ]]

function CensusPlus_CreateJob(minLevel, maxLevel, race, class, letter, zone)
  local job      = {};
  job.m_MinLevel = minLevel;
  job.m_MaxLevel = maxLevel;
  job.m_Race     = race;
  job.m_Class    = class;
  job.m_Letter   = letter;
  job.m_Zone     = zone;

  CensusPlus_DumpJob(job);

  return job;
end

--[[	-- Debug function do dump a job
--
  ]]

function CensusPlus_DumpJob(job)
  local whoText = '';
  local race = job.m_Race;
  if (race ~= nil) then
    whoText = whoText .. ' R: ' .. race;
  end

  local class = job.m_Class;
  if (class ~= nil) then
    whoText = whoText .. ' C: ' .. class;
  end

  local letter = job.m_Letter;
  if (letter ~= nil) then
    whoText = whoText .. ' N: ' .. letter;
  end

  local minLevel = job.m_MinLevel;
  if (minLevel ~= nil) then
    whoText = whoText .. ' min: ' .. minLevel;
  end

  local maxLevel = job.m_MaxLevel;
  if (maxLevel ~= nil) then
    whoText = whoText .. ' max: ' .. maxLevel;
  end

  local zoneLetter = job.m_zoneLetter;
  if (zoneLetter ~= nil) then
    whoText = whoText .. ' Z: ' .. zoneLetter;
  end


  --CensusPlus_Msg( "JOB DUMP: " .. whoText );	
end

--[[	-- Called on events
--
  ]]

function CensusPlus_OnEvent(self, event, ...) -- referenced by CensusPlus.xml
  local arg1, arg2, arg3, arg4 = ...;
  if (arg1 == nil) then
    arg1 = 'nil'
  end
  if (arg2 == nil) then
    arg2 = 'nil'
  end
  if (arg3 == nil) then
    arg3 = 'nil'
  end
  if (arg4 == nil) then
    arg4 = 'nil'
  end

  --
  -- If we have not been initialized,  nothing
  --
  if (g_CensusPlusInitialized == false) then
    if ((event == 'ADDON_LOADED') and (arg1 == 'CensusPlus')) then
      self:UnregisterEvent('ADDON_LOADED') -- need this or we get hit on all preceeding addon loaded.. including the LOD's
      --
      --  Initialize our variables
      --
      initializeAfterAddonLoaded()
      g_addon_loaded = true
      --		print("Addon Loaded")

      return
    end
    if (event == 'PLAYER_ENTERING_WORLD') then
      g_player_loaded = true
      --			print("Player in world")
      self:UnregisterEvent('PLAYER_ENTERING_WORLD')
      if (g_addon_loaded) and (g_player_loaded) then
        CensusPlus_InitializeVariables()
      end
    end
  end


  --
  -- WHO_LIST_UPDATE
  --
  if (event == 'TRAINER_SHOW' or event == 'MERCHANT_SHOW' or event == 'TRADE_SHOW' or event == 'GUILD_REGISTRAR_SHOW'
        or event == 'AUCTION_HOUSE_SHOW' or event == 'BANKFRAME_OPENED' or event == 'QUEST_DETAIL') then
    print(' Event triggered = ' .. event)
    if (CPp.IsCensusPlusInProgress) then
      g_CensusPlusPaused = true;
    end
  elseif (event == 'TRAINER_CLOSED' or event == 'MERCHANT_CLOSED' or event == 'TRADE_CLOSED' or event == 'GUILD_REGISTRAR_CLOSED'
        or event == 'AUCTION_HOUSE_CLOSED' or event == 'BANKFRAME_CLOSED' or event == 'QUEST_FINISHED') then
    print(' Event triggered = ' .. event)
    if (CPp.IsCensusPlusInProgress) then
      g_CensusPlusPaused = false;
    end
    --[[   Guild roster info not ready for release
	els.eif (event == "GUILD_ROSTER_UPDATE") th.en
	    --
	    --  Process Guild info
	    --
--CensusPlus_Msg( " UPDATE GUILD " );
		if(not CP_updatingGuild ) th.en
			CP_updatingGuild  = 1;
			CensusPlus_ProcessGuildResults();
			CP_updatingGuild  = nil;
		en.d
		]]

    --[[
	elseif (( event == "ADDON_LOADED") and (arg1 == "CensusPlus")) then
			self:UnregisterEvent("ADDON_LOADED")   -- need this or we get hit on all preceeding addon loaded.. including the LOD's
	    --
	    --  Initialize our variables
print("2nd init variables")	    --
	    CensusPlus_InitializeVariables()
--]]
  elseif (event == 'ZONE_CHANGED_NEW_AREA') then
    --
    --  We need to check to see if we entered a battleground
    --
    CensusPlus_CheckForBattleground();
  elseif (event == 'UPDATE_BATTLEFIELD_STATUS') then
    CensusPlus_UpdateBattleGroundInfo();
  end
end

--[[	-- ProcessTarget --  called when UNIT_FOCUS event is fired
--
  ]]

function CensusPlus_ProcessTarget(unit)
  --[[ PTR testing ignores the separation between regions
		so if in PTR then disable the block on processing wrong region data
--]]
  if (CensusPlus_PTR ~= false) then
    if (CPp.CensusPlusLocale == 'N/A') then
      return;
    end
  end


  if ((not UnitIsPlayer(unit)) or UnitIsUnit(unit, 'player')) then
    return; -- bail out on non-player unit or unit focus on self
  end

  local sightingData = CensusPlus_CollectSightingData(unit)

  if (sightingData == nil or sightingData.faction == nil or sightingData.faction == CENSUSPlus_NEUTRAL) then
    --	  print("worthless Neutral")
    return
  end

  if (sightingData.level < 1) then
    --	  print("Run away, Run Away.. Uncountable DEATH")
    return
  end

  if sightingData.faction ~= CENSUSPlus_ALLIANCE and sightingData.faction ~= CENSUSPlus_HORDE then
    return
  end

  if (sightingData.guild == nil) then
    sightingData.guild = '';
    -- RGK testing [GUILD]			
    sightingData.guildRankName = '';
    sightingData.guildRankIndex = '';
    --RGK endblock			
  else
    sightingData.guild = PTR_Color_ProblemRealmGuilds_check(sightingData.guild)
  end
  --
  -- Get the portion of the database for this server
  --
  local realmName = nil
  if (sightingData.realm == nil) then
    realmName = CPp.CensusPlusLocale .. GetRealmName()

    realmName = PTR_Color_ProblemRealmGuilds_check(realmName)
  else -- sightingData.realm is not nil
    sightingData.realm = PTR_Color_ProblemRealmGuilds_check(sightingData.realm)
    --[[
			if(	CensusPlus_Database["Info"]["Locale"] == "EU" )then		
-- work around for Blizzards oddball name for EU-Portugese server
				local stsrt,_,_ = string.find(sightingData.realm,'%(')
				if stsrt ~= nil then
					sightingData.realm = string.sub(sightingData.realm,1,stsrt-1)
				end
				local shortrealm = string.gsub(string.lower(sightingData.realm),"%W","")
				for k,v in pairs(CompactRealmsEU) do
					if shortrealm == k then sightingData.realm = v end
				end
				realmName = CPp.CensusPlusLocale .. sightingData.realm
	
			else  -- US region
				local shortrealm = string.gsub(string.lower(sightingData.realm),"%W","")
				for k,v in pairs(CompactRealmsUS) do
					if shortrealm == k then sightingData.realm = v end
				end
			end
--]]
  end
  realmName = CPp.CensusPlusLocale .. sightingData.realm
  if (sightingData.relationship == LE_REALM_RELATION_VIRTUAL) then
    if (CPp.VRealms == nil) then
      CPp.VRealms = {};
    end
    VRealmMembership_verifier(realmName)
  end

  sightingData.name = PTR_Color_ProblemNames_check(sightingData.name);
  sightingData.guildrealm = PTR_Color_ProblemRealmGuilds_check(sightingData
    .guildrealm)
  --[[
		if(	CensusPlus_Database["Info"]["Locale"] == "EU" )then		
-- work around for Blizzards oddball name for EU-Portugese server
				local stsrt,_,_ = string.find(sightingData.guildrealm,'%(')
				if stsrt ~= nil then
					sightingData.guildrealm = string.sub(sightingData.guildrealm,1,stsrt-1)
				end
				local shortrealm = string.gsub(string.lower(sightingData.guildrealm),"%W","")
				for k,v in pairs(CompactRealmsEU) do
					if shortrealm == k then sightingData.guildrealm = v end
				end
				sightingData.guildrealm = CPp.CensusPlusLocale .. sightingData.guildrealm
	
			else  -- US region
				local shortrealm = string.gsub(string.lower(sightingData.guildrealm),"%W","")
				for k,v in pairs(CompactRealmsUS) do
					if shortrealm == k then sightingData.guildrealm = v end
				end
			end
		end	
--]]
  sightingData.guildrealm = CPp.CensusPlusLocale .. sightingData.guildrealm
  CPp.DatabaseOperation.Record(realmName, sightingData)
end

--[[	-- Gather targeting data
--
  ]]

function CensusPlus_CollectSightingData(unit)
  if (UnitIsPlayer(unit) and UnitName(unit) ~= 'Unknown') then
    -- create the return structure as non-nil fields
    ---@type SightingData
    local ret = {
      name = '',
      realm = '',
      relationship = nil,
      race = NLZN.RACE.UNSPECIFIED,
      level = 0,
      class = NLZN.CLASS.UNSPECIFIED,
      guild = '',
      guildrealm = '',
      faction = '',
    }

    -- now populate the return structure
    ret.name, ret.realm = UnitName(unit)           -- returns realm also Y +?
    ret.relationship = UnitRealmRelationship(unit) -- compares against self returns LE_REALM_RELATION_VIRTUAL|LE_REALM_RELATION_COALESCED|LE_REALM_RELATION_SAME
    -- debug
    --		if (ret.relationship == nil) then print ("relationship = nil")
    --		else
    --		  print("relationship = "..ret.relationship)
    --		end
    -- end debug		
    if ((ret.realm == '') or ret.relationship == 1) then
      ret.realm = GetRealmName()
    end
    ret.level = UnitLevel(unit) -- a number  YNum
    --		ret.sex = UnitSex(unit) -- a number 2=male 3=female  YNum
    --race, fileName = UnitRace("unit") -- fileName is A non-localized token representing the unit's race (string)
    local race, _ = UnitRace(unit)   -- localized , non Y + Y non is english race treated as one word.. i.e. Blood Elf  Bloodelf
    ret.race = CPp.Normalization.N(race)
    local class, _ = UnitClass(unit) -- localized ,non (warning if npc the npc name is returned!) y + y  Monk  MONK
    ret.class = CPp.Normalization.N(class)
    -- guildName, guildRankName, guildRankIndex, guildrealm = GetGuildInfo("unit")  -- not listed as localized
    --		ret.guild, _, _,ret.guildrealm = GetGuildInfo(unit) -- ? + ? +Ynum=0?
    ret.guild, ret.guildRankName, ret.guildRankIndex, ret.guildrealm =
        GetGuildInfo(unit) -- ? + ? +Ynum=0?
    --[Note] getGuildinfo call does return all of the above.. or if not valid nil or zero for the index
    if (ret.guild == nil) then
      ret.guild = '';
      ret.guildrealm = '';
    end
    if (ret.guildrealm == nil) then
      if (ret.guild == '') then
        ret.guildrealm = '';
      else
        ret.guildrealm = GetRealmName();
      end
    end
    -- factionGroup, factionName = UnitFactionGroup("unit") or UnitFactionGroup("name") -- factionName is localized  Y+Y
    ret.faction, _ = UnitFactionGroup(unit)
    return ret
  else
    --		print("no sighting here, move along")
    return nil;
  end
end

--[[	-- Initialize our primary save variables --  called when CensusPlus ADDON_LOADED event is fired
--
  ]]

function CensusPlus_InitializeVariables()
  CPp.DatabaseOperation.Initialize()

  if (CensusPlus_Database['Times'] ~= nil) then
    CensusPlus_Database['Times'] = nil;
  end

  --
  --  Make sure info is last so it will be first in the output so we can grab the version number
  --
  if (CensusPlus_Database['Info'] == nil) then
    CensusPlus_Database['Info'] = {};
  end
  if (CensusPlus_PerCharInfo['Version'] == nil) then
    CensusPlus_PerCharInfo['Version'] = {};
  end

  if (CensusPlus_Database['Info']['Version'] ~= nil) then
    g_InterfaceVersion = CensusPlus_Database['Info']['Version']
    -- keep left V.v to compare with V.v in code
    local _, cpsubset = string.find(g_InterfaceVersion, '%.')
    local _, cpsubset2 = string.find(g_InterfaceVersion, '%.', cpsubset + 1)
    g_InterfaceVersion = string.sub(g_InterfaceVersion, 1, cpsubset2 - 1)
  end
  CPp.FirstLoad = true

  CensusPlus_Database['Info']['Version'] = CensusPlus_VERSION;
  local g_templang = GetLocale()
  --	local  realmID, name, apiName, rules, locale, battlegroup, region, timezone, connected, latinName = LibStub("LibRealmInfo"):GetRealmInfoByUnit("Player")
  local realmID, _, _, _, LRlocal, _, regionKey, _, _, _ = LibStub('LibRealmID')
      :GetRealmInfoByUnit('Player')
  -- print("realmID = ")
  -- print(realmID)
  -- print("LRlocal =")
  -- print(LRlocal)
  -- print("regionKey = ")
  -- print(regionKey)
  --[[		local regionKey = GetCVar("portal") == "public-test" and "PTR" or GetCVar("portal")
--		print ("Regionkey ="..regionKey)
		local currentRegion = GetCurrentRegion()
--		print ("Current Region = "..currentRegion)
	if (regionKey ~= g_WoW_regions[currentRegion]) then
		print("Region match fails")
		regionKey = g_WoW_regions[currentRegion]
	end
]]


  if (g_templang == 'enUS' and regionKey == 'EU') then
    g_templang = 'enGB';
  end
  if (g_templang == 'ptBR' and regionKey == 'EU') then
    g_templang = 'ptPT';
  end
  CensusPlus_Database['Info']['ClientLocale'] = GetLocale();

  if (CensusPlus_Database['Info']['ClientLocale'] == 'enUS' and regionKey == 'EU') then
    CensusPlus_Database['Info']['ClientLocale'] = 'enGB';
  end
  if (CensusPlus_Database['Info']['ClientLocale'] == 'ptBR' and regionKey == 'EU') then
    CensusPlus_Database['Info']['ClientLocale'] = 'ptPT';
  end
  CensusPlus_Database['Info']['LoginServer'] = regionKey;

  local localeSetting = CensusPlus_Database['Info']['Locale'];
  if (localeSetting == '??') then
    --  We had problems previously.. we must purge =(
    localeSetting = nil;
  end

  --
  --  Have a new way to detect locale, yay!
  --
  if (CensusPlus_Database['Info']['ClientLocale'] == 'enUS' or
        CensusPlus_Database['Info']['ClientLocale'] == 'esMX' or
        CensusPlus_Database['Info']['ClientLocale'] == 'ptBR') then
    CensusPlus_Database['Info']['Locale'] = 'US';
  elseif (CensusPlus_Database['Info']['ClientLocale'] == 'enGB' or
        CensusPlus_Database['Info']['ClientLocale'] == 'frFR' or
        CensusPlus_Database['Info']['ClientLocale'] == 'deDE' or
        CensusPlus_Database['Info']['ClientLocale'] == 'esES' or
        CensusPlus_Database['Info']['ClientLocale'] == 'ptPT' or
        CensusPlus_Database['Info']['ClientLocale'] == 'itIT') then
    CensusPlus_Database['Info']['Locale'] = 'EU';
  else
    CensusPlus_Database['Info']['Locale'] = '??';
  end
  CensusPlus_Database['Info']['LogVer'] = CensusPlus_VERSION_FULL;


  local locale = CensusPlus_Database['Info']['Locale'];
  CensusPlus_SelectLocale(CensusPlus_Database['Info']['Locale'], true);


  if (CensusPlus_Database['Info']['AutoCensus'] == nil) then
    CensusPlus_Database['Info']['AutoCensus'] = false;
  end
  if (CensusPlus_Database['Info']['Verbose'] == nil) then
    CensusPlus_Database['Info']['Verbose'] = false;
  end
  if (CensusPlus_Database['Info']['Stealth'] == nil) then
    CensusPlus_Database['Info']['Stealth'] = false;
  end
  if (CensusPlus_Database['Info']['PlayFinishSound'] == nil) then
    CensusPlus_Database['Info']['PlayFinishSound'] = false;
  end
  if (CensusPlus_Database['Info']['SoundFile'] == nil) then
    CensusPlus_Database['Info']['SoundFile'] = g_FinishSoundNumber;
  end

  if (CensusPlus_Database['Info']['AutoCensusTimer'] == nil) then
    CensusPlus_Database['Info']['AutoCensusTimer'] = 1800;
  end

  if (CensusPlus_Database['Info']['CPWindow_Transparency'] == nil) then
    CensusPlus_Database['Info']['CPWindow_Transparency'] = 0.5
  end
  if (CensusPlus_Database['Info']['ChattyOptions'] == nil) then
    CensusPlus_Database['Info']['ChattyOptions'] = false
  end

  if (CensusPlus_Database['Info']['CensusButtonShown'] == nil) then
    CensusPlus_Database['Info']['CensusButtonShown'] = true;
  end

  if (CensusPlus_Database['Info']['CensusButtonShown'] == true) then
    CensusButtonFrame:Show();
  else
    CensusButtonFrame:Hide();
  end

  if (CensusPlus_Database['Info']['CensusButtonAnimi'] == nil) then
    CensusPlus_Database['Info']['CensusButtonAnimi'] = true;
  end

  if (CensusPlus_Database['Info']['UseLogBars'] == nil) then
    CensusPlus_Database['Info']['UseLogBars'] = true;
  end

  if (CensusPlus_Database['Info']['UseWorldFrameClicks'] == nil) then
    CensusPlus_Database['Info']['UseWorldFrameClicks'] = false
  end

  if (CensusPlus_Database['Info']['UseInterfaceClicks'] == nil) then
    CensusPlus_Database['Info']['UseInterfaceClicks'] = false
  end

  CensusPlus_Msg(' V' .. CensusPlus_VERSION .. CENSUSPLUS_MSG1);

  g_VariablesLoaded = true;

  -- CensusPlus_CheckTZ();

  InitConstantTables();


  --    CP_OptionAutoShowMinimapButton:SetChecked(CensusPlus_Database["Info"]["CensusButtonShown"]);


  if (CensusPlus_CRealms['UTCDateStamp'] == nil) then
    CensusPlus_CRealms['UTCDateStamp'] = {};
  end

  g_CensusPlusInitialized = true

  --
  --  If we are in a guild, attempt to gather the guild roster data
  --
  --	if (IsInGuild()) then
  --		GuildRoster();
  --	end

  --
  --  Prune times if we have too many
  --
  CENSUSPLUS_PRUNETimes();


  --
  CensusPlus_Unhandled = nil;
  CensusPlus_Unhandled = {};

  CensusPlus_OptionCategory = nil;
  CensusPlusBlizzardOptions()
  CensusPlus_Verbose()
  CensusPlus_Stealth()
  CensusPlus_CensusButtonAnimi()
  CensusPlus_CensusButtonShown()
  CensusPlus_SetAutoCensus()
  CensusPlus_FinishSound()
  CPp.FirstLoad = false -- main table initialized and options initialized

  --	print("CensusTrigger ".. CPp.AutoStartTrigger)
  --	print("AutoStartTimer "..CPp.AutoStartTimer)
  --	local timdif = ((time() + (CPp.AutoStartTimer * 60)) - CPp.LastCensusRun)
  --	print("Time to start "..timdif)
end

function CensusPlus_OnUpdate() -- referenced by CensusPlus.xml
  if (g_FirstRun) then
    if (CPp.AutoStartTrigger > CPp.AutoStartTimer) then
      if (g_VariablesLoaded and
            (not (CPp.IsCensusPlusInProgress)) and
            CPp.AutoCensus == true -- and
          --				(CPp.LastCensusRun < time() - (CPp.AutoStartTimer *60))) then  -- note - processed before <
          ) then
        --				print("Started 1")
        CENSUSPLUS_TAKE_OnClick()
      end
    elseif (CPp.AutoStartTimer < 30) then
      if (g_VariablesLoaded and
            (not (CPp.IsCensusPlusInProgress)) and
            CPp.AutoCensus == true and
            (CPp.LastCensusRun < time() - (CPp.AutoStartTimer * 60))) then -- note - processed before <
        --				print("Started 2")
        CENSUSPLUS_TAKE_OnClick()
      end
    else
    end
  elseif
      (g_VariablesLoaded and
        (not (CPp.IsCensusPlusInProgress)) and
        CPp.AutoCensus == true and
        (CPp.LastCensusRun < time() - (CPp.AutoStartTimer * 60))) then -- note - processed before <
    --		print("started 3")
    CENSUSPLUS_TAKE_OnClick()
  end
  --[[
	if( g_VariablesLoaded and
	(not CPp.IsCensusPlusInProgress) and
	(CPp.AutoCensus == true) and
-	((not (CensusPlus_PerCharInfo["AutoCensus"] == true)) and
	(CPp.LastCensusRun < (time() - 1800)))) then
		CENSUSPLUS_TAKE_OnClick();
	end
 --((CPp.LastCensusRun < time() - CensusPlus_PerCharInfo["AutoCensusTimer"])
--or CensusPlus_Database["Info"]["AutoCensusTimer"]
--]]
  if (CPp.IsCensusPlusInProgress and (not (g_CensusPlusPaused)) and (not (CPp.CensusPlusManuallyPaused))) then
    --
    --  update our progress
    --
    local numJobs = #CensusPlus_JobQueue;
    if (numJobs > 0) then
      CensusPlusScanProgress:SetText(format(CENSUSPLUS_SCAN_PROGRESS, numJobs,
                                            CensusPlus_CreateWhoText(
                                              CensusPlus_JobQueue[numJobs])));
    end

    if (not (whoquery_active) or g_FirstRun) then --ok to request next query
      whoquery_answered = false;

      --
      -- Determine if there is any more work to
      --
      if (numJobs > 0) then
        --
        -- Remove the top job from the queue and send it
        --
        local job = CensusPlus_JobQueue[numJobs];
        table.remove(CensusPlus_JobQueue);
        local whoText = CensusPlus_CreateWhoText(job);
        g_FirstRun = false
        --
        --  Zap our current job
        --
        g_CurrentJob = nil;

        g_CurrentJob = job;

        CensusPlus_SendWho(whoText);
        g_WhoAttempts = 0;
        g_LastOnUpdateTime = GetTime()
        CensusPlus_JobQueue.CensusPlus_last_time = time();
      else
        --
        -- We are all done, hide the friends frame and report our results
        --
        if (CensusPlus_PerCharInfo['PlayFinishSound']) then
          if (CensusPlus_PerCharInfo['SoundFile'] == nil) then
            g_FinishSoundNumber = 1
          else
            g_FinishSoundNumber = CensusPlus_PerCharInfo['SoundFile']
          end
          local CPSoundFile =
              'Interface\\AddOns\\CensusPlus\\Sounds\\CensusComplete' ..
              g_FinishSoundNumber .. '.ogg'
          local willplay = PlaySoundFile(CPSoundFile, 'Master')
          if (not willplay) then
            local CPSoundFile =
                'Interface\\AddOns\\CensusPlus\\Sounds\\CensusComplete' ..
                g_FinishSoundNumber .. '.mp3'
            PlaySoundFile(CPSoundFile, 'Master')
          end
        elseif ((CensusPlus_PerCharInfo['PlayFinishSound'] == nil) and (CensusPlus_Database['Info']['PlayFinishSound'])) then
          if (CensusPlus_Database['Info']['SoundFile'] == nil) then
            g_FinishSoundNumber = 1
          else
            g_FinishSoundNumber = CensusPlus_Database['Info']['SoundFile']
          end
          local CPSoundFile =
              'Interface\\AddOns\\CensusPlus\\Sounds\\CensusComplete' ..
              g_FinishSoundNumber .. '.ogg'
          local willplay = PlaySoundFile(CPSoundFile, 'Master')
          if (not willplay) then
            local CPSoundFile =
                'Interface\\AddOns\\CensusPlus\\Sounds\\CensusComplete' ..
                g_FinishSoundNumber .. '.mp3'
            PlaySoundFile(CPSoundFile, 'Master')
          end
        end
        if (not (CensusPlayerOnly)) then
          CensusPlus_DoTimeCounts();
          CensusPlus_ProcessConnectedRealms()
        end
        CensusPlayerOnly                            = false
        CensusPlus_JobQueue.CensusPlus_LoginRealm   = '';
        CensusPlus_JobQueue.CensusPlus_LoginFaction = '';
        CensusPlus_JobQueue.g_TempCount             = {};
        CensusPlus_DisplayResults();
        --
        -- Add CensusButton reset
        CensusButton:SetText('C+')
      end
    elseif (whoquery_answered) then
      local now = GetTime();
      local delta = now - g_LastOnUpdateTime;
      if (delta > CensusPlus_UPDATEDELAY2) then
        g_LastOnUpdateTime = now;
        print(CENSUSPLUS_TOOSLOW) -- >10 seconds to finish query!
      end
    else
      local now = GetTime();
      local delta2 = now - g_LastOnUpdateTime;
      if (delta2 > CensusPlus_UPDATEDELAY) then
        g_LastOnUpdateTime = now;
        --					print("server hasn't responded to query")  -- > 5 seconds
        --					CENSUSPLUS_STOPCENSUS()
        --					print("stopping census run")
        --
        -- Resend /who command
        --
        g_WhoAttempts = g_WhoAttempts + 1;
        local whoText = CensusPlus_CreateWhoText(g_CurrentJob);
        if (CensusPlus_PerCharInfo['Verbose'] == true) then
          CensusPlus_Msg(CENSUSPLUS_WAITING); -- this hasn't shown up in testing yet.
        end
        if (g_WhoAttempts < 2) then
          CensusPlus_Msg2(whoText .. ' repeat needed');
        end
      end
      --		  		return    -- server hasn't returned query.. so wait for next frame update
    end

    -- cut mark1 here	
  end
end

--[[	 when new virtual realm member found add new realm to g_TempCount table with classes initialized to zero count
--
--]]

--[[	-- Take final tally
--
  ]]

function CensusPlus_DoTimeCounts()
  --	if (HortonBug == true) then
  --		s.ays("CensusPlus_DoTimeCounts");
  --	end

  if (CPp.CensusPlusLocale == 'N/A') then
    if (HortonBug == true) then
      says('CPp.CensusPlusLocale == N/A');
    end
    return;
  end

  -- first zero counts in g_TimeDatabase each realm/faction
  --	CensusPlus_JobQueue.g_NumUpdatedCharacters = 0;
  --	CensusPlus_JobQueue.g_NumNewCharacters = 0;
  local factionGroup = UnitFactionGroup('player');
  -- 5.4 need to modify so that charname is charname-realmname or something
  -- need to be able to separate chars of same name but different realms
  -- need to group realm data so we can cycle through each member realm of virtual realm
  --
  --	read vrealms list
  for VrealmKey, MemberRealm in ipairs(CPp.VRealms) do -- auto assigned integer key, realmname
    --		if (HortonBug == true) then
    --			if ((VrealmKey ~= nil) and (MemberRealm ~= nil)) then
    --				s.ays("VrealmLoop  " .. VrealmKey .."  "..MemberRealm);
    --			end
    --			if ((VrealmKey ~= nil) and (MemberRealm == nil)) then
    --				s.ays("VrealmLoop  " .. VrealmKey .."  nil2 ");
    --			end
    --			if (VrealmKey == nil) then
    --				s.ays("VrealmLoop  nil 1 ");
    --			end
    --		end
    -- zero counts in g_TimeDatabase for current realm/faction
    CensusPlus_Zero_g_TimeDatabase();

    if (MemberRealm ~= nil) then
      local thisFactionClasss = CensusPlus_GetFactionClasses(factionGroup);
      local numClasses = #thisFactionClasss;
      for i = 1, numClasses, 1 do
        local charClass = thisFactionClasss[i];
        local classCount = 0;
        --
        --			g_Times_ForAllCharacters(MemberRealm, factionGroup, classKey, ClassCount);


        for realmKey, factionData in pairs(CensusPlus_JobQueue.g_TempCount) do -- realmname, factionname
          --					if (HortonBug == true) then
          --						if ((realmKey ~= nil) and (factionData ~= nil)) then
          --							s.ays("TempCountOuter  " .. realmKey .."  "..factionData);
          --						end
          --						if ((realmKey ~= nil) and (factionData == nil)) then
          --							s.ays("TempCountOuter  " .. realmKey .."  nil2");
          --						end
          --						if (realmKey == nil) then
          --							s.ays("TempCountOuter  nil1");
          --						end
          --					end

          -- step debug
          if (realmKey == MemberRealm) then
            for factionKey, classData in pairs(factionData) do
              if (factionKey == factionGroup) then
                for classKey, NameData in pairs(classData) do
                  if (charClass == classKey) then
                    for nameKey, charData in pairs(NameData) do
                      --												if (HortonBug == true) then
                      --													s.ays("TempCount level 3");
                      --												end

                      local gotcha = charData[1];
                      if (gotcha == charClass) then
                        classCount = classCount + 1;
                      end
                    end
                  end
                end
              end
            end
          end
        end

        if (CENSUSPlusFemale[charClass] ~= nil) then
          charClass = CENSUSPlusFemale[class];
        end
        CensusPlus_JobQueue.g_TimeDatabase[charClass] = CensusPlus_JobQueue
            .g_TimeDatabase[charClass] + classCount;
        CensusPlus_JobQueue.g_NumUpdatedCharacters = CensusPlus_JobQueue
            .g_NumUpdatedCharacters + classCount;
        -- debug line
        --				if (HortonBug == true) then
        --					s.ays("Class= " .. CensusPlus_JobQueue.g_TimeDatabase[charClass].." Updates= " .. CensusPlus_JobQueue.g_NumUpdatedCharacters);
        --				end
      end
      --]]
      if (CensusPlus_Database['TimesPlus'][MemberRealm] == nil) then
        CensusPlus_Database['TimesPlus'][MemberRealm] = {};
      end
      if (CensusPlus_Database['TimesPlus'][MemberRealm][factionGroup] == nil) then
        CensusPlus_Database['TimesPlus'][MemberRealm][factionGroup] = {};
      end

      if (CensusPLus_DEBUGWRITES) then
        local total_time = time() - g_CensusPlus_StartTime;
        local hour, minute = GetGameTime();
        --					CensusPlus_Database["TimesPlus"][realmData][factionData]["" .. hour .. ""] = CensusPlus_JobQueue.g_TimeDatabase;
        CensusPlus_Database['TimesPlus'][MemberRealm][factionGroup] =
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DRUID] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.HUNTER] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.MAGE] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.PRIEST] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.ROGUE] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.WARLOCK] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.WARRIOR] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.SHAMAN] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.PALADIN] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DEATHKNIGHT] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.MONK] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DEMONHUNTER] .. '&' ..
            CensusPlus_WHOPROCESSOR ..
            ':' ..
            CensusPlus_JobQueue.g_NumNewCharacters ..
            ',' .. CensusPlus_JobQueue.g_NumUpdatedCharacters ..
            ',' .. total_time;
      else
        --				if (HortonBug == true) then
        --					s.ays("build the line");
        --				end
        local hour, minute = GetGameTime();
        --					CensusPlus_Database["TimesPlus"][realmData][factionData]["" .. hour .. ""] = CensusPlus_JobQueue.g_TimeDatabase;
        local TimeDataTime = CensusPlus_DetermineServerDate() ..
            '&' .. hour .. ':' .. minute .. ':00';

        CensusPlus_Database['TimesPlus'][MemberRealm][factionGroup][TimeDataTime] =
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DRUID] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.HUNTER] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.MAGE] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.PRIEST] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.ROGUE] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.WARLOCK] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.WARRIOR] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.SHAMAN] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.PALADIN] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DEATHKNIGHT] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.MONK] .. '&' ..
            CensusPlus_JobQueue.g_TimeDatabase[NLZN.CLASS.DEMONHUNTER];
      end
    end
  end
  CensusPlus_Zero_g_TimeDatabase(); --b temp data no longer needed
end

function CensusPlus_ProcessConnectedRealms()
  local newCrealm = 1
  if (#CPp.VRealms > 1) then
    for k, v in pairs(CensusPlus_CRealms) do
      if (k ~= 'UTCDateStamp') then
        for i = 1, #CPp.VRealms, 1 do
          if (v[1] == CPp.VRealms[i]) then
            newCrealm = 0 -- match found
            break         -- the 4 loop since match found
          end
        end
      end
      if (newCrealm == 0) then
        break -- the 4 loop since match found
      end
    end
    if (newCrealm == 1) then
      CensusPlus_CRealms[CPp.VRealms[1]] = CPp.VRealms
    end
  end
end

--[[	-- Add the contents of the guild results to the database
--
  ]]

local function CensusPlus_ProcessGuildResults()
  if (not (g_VariablesLoaded)) then
    return;
  end

  if (CensusPlus_Database['Info']['Locale'] == nil) then
    return;
  end

  if (CPp.CensusPlusLocale == 'N/A') then
    return;
  end


  --
  --  Grab temp var
  --
  local showOfflineTemp = GetGuildRosterShowOffline();
  SetGuildRosterShowOffline(true);


  --
  -- Walk through the guild info
  --
  local numGuildMembers, numOnline = GetNumGuildMembers();
  if (numOnline < 2) then
    return -- only guild member online is player who is counted elsewhere
  end
  --	CensusPlus_Msg("Processing "..numOnline.." online of "..numGuildMembers.." total guild members.");

  local realmName = CPp.CensusPlusLocale .. GetRealmName();
  CensusPlus_Database['Guilds'] = nil;
  if (CensusPlus_Database['Guilds'] == nil) then
    CensusPlus_Database['Guilds'] = {};
  end

  if (CensusPlus_Database['Guilds'][realmName] == nil) then
    CensusPlus_Database['Guilds'][realmName] = {};
  end

  local guildRealmDatabase = CensusPlus_Database['Guilds'][realmName];
  if (guildRealmDatabase == nil) then
    CensusPlus_Database['Guilds'][realmName] = {};
    guildRealmDatabase = CensusPlus_Database['Guilds'][realmName];
  end

  local factionGroup = UnitFactionGroup('player');
  if (factionGroup == nil) then
    CensusPlus_Database['Guilds'] = nil;
    SetGuildRosterShowOffline(showOfflineTemp);
    return;
  end

  local factionDatabase = guildRealmDatabase[factionGroup];
  if (factionDatabase == nil) then
    guildRealmDatabase[factionGroup] = {};
    factionDatabase = guildRealmDatabase[factionGroup];
  end

  CensusPlus_Database['Guilds'][realmName][factionGroup] = nil;
  CensusPlus_Database['Guilds'][realmName][factionGroup] = {};

  factionDatabase = CensusPlus_Database['Guilds'][realmName][factionGroup];

  local Ginfo = GetGuildInfo('player');
  if (Ginfo == nil) then
    CensusPlus_Database['Guilds'] = nil;
    SetGuildRosterShowOffline(showOfflineTemp);
    return;
  end
  local guildDatabase = factionDatabase[Ginfo];
  if (guildDatabase == nil) then
    factionDatabase[Ginfo] = {};
    guildDatabase = factionDatabase[Ginfo];
  end

  local info = guildDatabase['GuildInfo'];
  if (info == nil) then
    guildDatabase['GuildInfo'] = {};
    info = guildDatabase['GuildInfo'];
  end

  info['Update'] = date('%m-%d-%Y', time()) .. '';
  info['ShowOnline'] = 1; --  Variable comes from FriendsFrame

  guildDatabase['Members'] = nil;
  guildDatabase['Members'] = {};

  local members = guildDatabase['Members'];

  for index = 1, numGuildMembers, 1 do
    local name, rank, rankIndex, level, class, zone, note, officernote, online, status =
        GetGuildRosterInfo(index);

    if (members[name] == nil) then
      members[name] = {};
    end

    --        CensusPlus_Msg( "Name =>" .. name );
    --        CensusPlus_Msg( "rank =>" .. rank );
    --        CensusPlus_Msg( "rankIndex =>" .. rankIndex );
    --        CensusPlus_Msg( "level =>" .. level );
    --        CensusPlus_Msg( "class =>" .. class );
    members[name]['Rank'] = rank;
    members[name]['RankIndex'] = rankIndex;
    members[name]['Level'] = level;
    members[name]['Class'] = class;
    --        members[name]["Zone"]= zone;
    --        members[name]["Note"]= CensusPlus_SafeSet( note );
    --        members[name]["OfficerNote"]= CensusPlus_SafeSet( officernote );
    --        members[name]["Online"]= online;
    --        members[name]["Status"]= CensusPlus_SafeSet( status );
  end

  SetGuildRosterShowOffline(showOfflineTemp);
end

function CensusPlus_SafeCheck(param)
  if (param == nil) then
    return 'nil';
  else
    return param;
  end
end

---Makes a sighting data from the who info.
---@param whoInfo WhoInfo
---@return SightingData
local function makeSightingData(whoInfo)
  ---@type SightingData
  local data = {
    name = '',
    realm = '',
    relationship = nil,
    race = NLZN.RACE.UNSPECIFIED,
    level = whoInfo.level,
    class = NLZN.CLASS.UNSPECIFIED,
    guild = '',
    guildrealm = '',
    faction = UnitFactionGroup('player'),
  }
  local tmpNmst = nil
  local tmpGldst = nil
  local name = whoInfo.fullName

  --[[ Note:  name and realm
      if character tracked is on same realm as player character then name is returned as Name only
      if character tracked is on a non-local connected realm then name is returned as Name-Realm
  ]]

  tmpNmst, _ = string.find(name, '-');
  if (tmpNmst) then
    data.realm = string.sub(name, tmpNmst + 1);
    data.name = string.sub(name, 1, tmpNmst - 1);
  else
    data.realm = GetRealmName(); -- this shouldn't happen except where Blizzard doesn't encode relationships  {sigh and they didn't}
    data.name = name
  end
  -- 5.4
  local guild = whoInfo.fullGuildName
  --[[ Note:  guild and realm
      if character's guild tracked is on same realm as player character then guild is returned as guild only
      if character's guild tracked is on a non-local connected realm then guild is returned as guild-Realm
  ]]
  if (HortonBug == true) then
    says('Who returned ' ..
      whoInfo.fullName .. '  Guild = ' .. whoInfo.fullGuildName);
  end
  if ((guild ~= nil) and (guild ~= '')) then
    local guildName =
    '' -- defined if valid guild returned from who call otherwise nil.. am I sure about this?
    --[[ invalid coding.. GetGuildInfo only works with (unit) not ("name") as indicated at www.wowprogramming.com sigh
      guildName,guildRankName, guildRankIndex, guildRealm = GetGuildInfo(whoInfo.Name)  -- I'm assuming this will be  guild, guildrealm  and not guild-realm, guildrealm
    ]]
    tmpGldst, _ = string.find(guild, '-');
    if (tmpGldst ~= nil) then
      data.guildrealm = string.sub(guild, tmpGldst + 1);
      data.guild = string.sub(guild, 1, tmpGldst - 1);
    else
      data.guildrealm = GetRealmName();
      data.guild = guild
    end
    if (HortonBug == true) then
      says('guild realm =  ' .. data.guildrealm);
    end
  else
    data.guild = '';
    data.guildrealm = '';
  end
  local race = whoInfo.raceStr
  if (CENSUSPlusFemale[race] ~= nil) then
    race = CENSUSPlusFemale[race];
  end
  data.race = NLZN.N(race)
  local class = whoInfo.classStr
  if (CENSUSPlusFemale[class] ~= nil) then
    class = CENSUSPlusFemale[class];
  end
  data.class = NLZN.N(class)

  --[[ PTR testing modifications
    Blizzard has odd naming allowances in PTR realms
    name (US) or name (EU)  ditto for guild names

--]]
  data.realm = PTR_Color_ProblemRealmGuilds_check(data.realm);
  data.name = PTR_Color_ProblemNames_check(data.name);
  if ((data.guild ~= nil) and (data.guild ~= '')) then
    data.guild = PTR_Color_ProblemRealmGuilds_check(data.guild);
  end
  if ((data.guildrealm ~= nil) and (data.guildrealm ~= '')) then
    data.guildrealm = PTR_Color_ProblemRealmGuilds_check(data.guildrealm);
    data.guildrealm = CPp.CensusPlusLocale .. data.guildrealm;
  end
  return data
end

---Adds the contents of the who results to the database.
---@param result WhoInfo[]
---@param numWhoResults integer
function CensusPlus_ProcessWhoResults(result, numWhoResults)
  --
  --  If we are in a BG th.en stop a census
  --
  if (g_CurrentlyInBG and CPp.IsCensusPlusInProgress) then
    CPp.LastCensusRun = time() - 600;
    CensusPlus_Msg(CENSUSPLUS_ISINBG);
    CENSUSPLUS_STOPCENSUS();
  end

  --[[ PTR testing ignores the separation between regions
		so if in PTR then disable the block on processing wrong region data
--]]
  if (CensusPlus_PTR ~= false) then
    if (CPp.CensusPlusLocale == 'N/A') then
      return;
    end
  end

  --[[
Old process, assume single realm.. process realm,faction,level,race,class,
new process no assumption. process realm, then faction, level, race,class
   need to build dotimes for each realm found in Virtual realm set.

   name comes in as name-realm
   split to name, realm
   process

--]]
  --5.4

  if (g_Verbose == true) then
    CensusPlus_Msg(format(CENSUSPLUS_PROCESSING, numWhoResults));
  end

  --	local relate = ""
  for i = 1, numWhoResults, 1 do
    local sightingData = makeSightingData(result[i])
    --
    -- Get the portion of the database for this server
    --
    local realmName = CPp.CensusPlusLocale .. sightingData.realm;
    VRealmMembership_verifier(realmName);
    -- coalesced realms should not show up here via /who queries.

    --
    -- Get the portion of the database for this faction
    --
    local factionGroup = sightingData.faction
    if (factionGroup == nil or factionGroup == 'Neutral') then
      return
    end

    if CPp.DatabaseOperation.Record(realmName, sightingData) then
      CensusPlus_JobQueue.g_NumNewCharacters = CensusPlus_JobQueue
          .g_NumNewCharacters + 1;
    end

    local gct_realm = CensusPlus_JobQueue.g_TempCount[realmName];
    if (gct_realm == nil) then
      CensusPlus_JobQueue.g_TempCount[realmName] = {};
      gct_realm = CensusPlus_JobQueue.g_TempCount[realmName];
    end

    local gct_faction = gct_realm[factionGroup];
    if (gct_faction == nil) then
      gct_realm[factionGroup] = {};
      gct_faction = gct_realm[factionGroup];
    end

    local class = sightingData.class
    local gct_class = gct_faction[class];
    if (gct_class == nil) then
      gct_faction[class] = {};
      gct_class = gct_faction[class];
    end

    local name = sightingData.name
    local gct_name = gct_class[name];
    if (gct_name == nil) then
      gct_class[name] = {};
      gct_name = gct_class[name];
    end
    gct_name[1] = class;
  end


  whoquery_active = false
  --		print("query finished")  --debug
  --	CensusPlus_UpdateView();
end

--[[	-- Process a single entry
--
  ]]

local function WR_ProcessSingleEntry(name, level, race, class, guild, zone) -- not currently used since we don't want to activity record foreign realm characters that we spot id.
  CensusPlus_Msg2(BLIZZARD_STORE_PROCESSING .. name);

  if (CPp.CensusPlusLocale == 'N/A') then
    return;
  end

  if (CENSUSPlusFemale[race] ~= nil) then
    race = CENSUSPlusFemale[race];
  end

  if (CENSUSPlusFemale[class] ~= nil) then
    class = CENSUSPlusFemale[class];
  end

  --
  -- Get the portion of the database for this server
  --
  local realmName = CPp.CensusPlusLocale .. GetRealmName();
  local realmDatabase = CensusPlus_Database['Servers'][realmName];
  if (realmDatabase == nil) then
    CensusPlus_Database['Servers'][realmName] = {};
    realmDatabase = CensusPlus_Database['Servers'][realmName];
  end

  --
  -- Get the portion of the database for this faction
  --
  local factionGroup = UnitFactionGroup('player');
  if (factionGroup == nil) then
    return
  end

  local factionDatabase = realmDatabase[factionGroup];
  if (factionDatabase == nil) then
    realmDatabase[factionGroup] = {};
    factionDatabase = realmDatabase[factionGroup];
  end

  --
  --  Remove the trailing ] that I can't remove through patterns
  --	
  --	local oldname = name;
  --	name = string.sub( oldname, 1, string.len(oldname) - 3 );

  level = tonumber(level);

  --
  --  Test the name for possible color coding
  --
  --  for example |cffff0000Rollie|r
  local karma_check = string.find(name, '|cff');
  if (karma_check ~= nil) then
    name = string.sub(name, 11, -3);
  end

  local pattern = '[0-9\| :]';
  if (string.find(name, pattern) ~= nil) then
    if (not g_ProblematicMessageShown) then
      CensusPlus_Msg(CENSUSPLUS_PROBLEMNAME ..
        name .. CENSUSPLUS_PROBLEMNAME_ACTION);
    end
    return;
  end

  --
  --  Do a race check just to be sure this is working
  --
  if (g_FactionCheck[race] == nil) then
    CensusPlus_Msg(CENSUSPLUS_UNKNOWNRACE ..
      race .. CENSUSPLUS_UNKNOWNRACE_ACTION);
    return;
  end

  --
  -- Get racial database
  --
  local raceDatabase = factionDatabase[race];
  if (raceDatabase == nil) then
    factionDatabase[race] = {};
    raceDatabase = factionDatabase[race];
  end

  --
  -- Get class database
  --
  local classDatabase = raceDatabase[class];
  if (classDatabase == nil) then
    raceDatabase[class] = {};
    classDatabase = raceDatabase[class];
  end

  --
  -- Get this player's entry
  --
  local entry = classDatabase[name];
  if (entry == nil) then
    classDatabase[name] = {};
    entry = classDatabase[name];
    CensusPlus_JobQueue.g_NumNewCharacters = CensusPlus_JobQueue
        .g_NumNewCharacters + 1;
  end

  --
  -- Update the information
  --
  entry[1] = level;
  entry[2] = guild;
  --		local hour, minute = GetGameTime();
  entry[3] = CensusPlus_DetermineServerDate() .. '';

  g_TempCount[name] = class;

  --	CensusPlus_Msg2( "Processed 	" .. name );
end

--[[	-- Find a guild in the CensusPlus_Guilds array by name
--
  ]]

local function FindGuildByName(name)
  local i;
  local size = #CensusPlus_Guilds;
  for i = 1, size, 1 do
    local entry = CensusPlus_Guilds[i];
    --5.4 to be done
    -- if name and realm == name and realm   to differentiate same name guild of different realms
    if (entry.m_Name == name) then
      return i;
    end
  end
  return nil;
end

---Gets an accumulator for counting the number of characters.
---
---The returned `container.count` holds the count of total characters after
---accumulating.
---@return table container, function accumulator
local function getAccumulator()
  local container = {count = 0, race = {}, class = {}, level = {}}
  return container, function(...)
    local name, level, guild, raceName, className, lastseen, realmName, guildRealm = ...
    container.count = container.count + 1;
    if not container.race[raceName] then
      container.race[raceName] = 0
    end
    container.race[raceName] = container.race[raceName] + 1
    if not container.class[className] then
      container.class[className] = 0
    end
    container.class[className] = container.class[className] + 1
    if not container.level[level] then
      container.level[level] = 0
    end
    container.level[level] = container.level[level] + 1
  end
end

local function addPlayerToList(...)
  local name, level, guild, raceName, className, lastseen, realmName, guildRealm = ...
  CensusPlus_AddPlayerToList(name, level, guild, raceName, className, lastseen,
                             realmName, guildRealm)
end

---Adds guilds to CensusPlus_Guilds.
---@param resideToRealm boolean Whether to only add guilds that reside on the same realm.
---@param ... any Arguments from `CensusPlus_ForAllCharacters`.
local function addGuildToList(resideToRealm, ...)
  local name, level, guild, raceName, className, lastseen, realmName, guildRealm = ...
  if (g_TotalCharacterXPPerLevel[level] == nil) then
    InitConstantTables();
  end
  local totalCharacterXP = g_TotalCharacterXPPerLevel[level];
  if (totalCharacterXP == nil) then
    totalCharacterXP = 0;
  end
  -- `guild` seems never be nil.
  if realmName == guildRealm or not resideToRealm then
    local index = FindGuildByName(guild);
    if (index == nil) then
      local size = #CensusPlus_Guilds;
      index = size + 1;
      CensusPlus_Guilds[index] = {
        m_Name = guild,
        m_TotalCharacterXP = 0,
        m_Count = 0,
        m_GuildRealm = guildRealm,
        m_GNfull = guild .. '-' .. guildRealm
      };
    end
    local entry = CensusPlus_Guilds[index];
    entry.m_TotalCharacterXP = entry.m_TotalCharacterXP + totalCharacterXP;
    entry.m_Count = entry.m_Count + 1;
  end
end

--[[	-- Predicate function which can be used to compare two guilds for sorting
--
  ]]

local function GuildPredicate(lhs, rhs)
  --
  -- nil references are always less than
  --
  if (lhs == nil) then
    if (rhs == nil) then
      return false;
    else
      return true;
    end
  elseif (rhs == nil) then
    return false;
  end
  --
  -- Sort by total XP first
  --
  if (rhs.m_TotalCharacterXP < lhs.m_TotalCharacterXP) then
    return true;
  elseif (lhs.m_TotalCharacterXP < rhs.m_TotalCharacterXP) then
    return false;
  end
  --
  -- Sort by name
  --
  if (lhs.m_Name < rhs.m_Name) then
    return true;
  elseif (rhs.m_Name < lhs.m_Name) then
    return false;
  end

  --
  -- identical
  --
  return false;
end

--[[	-- Another accumulator for adding up XP and counts
--
  ]]

local function CensusPlus_Accumulator(name, level, guild)
  if (g_TotalCharacterXPPerLevel[level] == nil) then
    InitConstantTables();
  end
  local totalCharacterXP = g_TotalCharacterXPPerLevel[level];
  if (totalCharacterXP == nil or g_TotalCharacterXPPerLevel[level] == nil) then
    return;
  end
  g_AccumulatorCount = g_AccumulatorCount + 1;
end

--[[	-- Reset the above accumulator
--
  ]]

local function CensusPlus_ResetAccumulator()
  g_AccumulatorCount = 0;
end

--[[ Virtual Realm membership accumulator
--]]

function VRealmMembership_verifier(realmName)
  --5.4  if new virtual realm member add to new table
  local new_VirtRealm_mem = nil;
  for i, v in ipairs(CPp.VRealms) do
    if (realmName == v) then
      new_VirtRealm_mem = 'NO'; -- 'no' means yes.. but really no.. nil = false anything else means true
      -- not a match means maybe until a match is made then NO
    end
  end
  if (new_VirtRealm_mem == nil) then
    table.insert(CPp.VRealms, realmName);
  end
end

---Gets the texture name by the race / class ID.
---@param raceClass string The race / class name (locale aware).
---@returns string The texture name which can be used in `SetNormalTexture()`.
local function getIconTexture(raceClass)
  -- ugly brut force fix..
  local factionGroup = UnitFactionGroup('player');
  if ((factionGroup == 'Horde') and (g_RaceClassList[raceClass] == 34)) then
    g_RaceClassList[raceClass] = 33
  elseif ((factionGroup == 'Alliance') and (g_RaceClassList[raceClass] == 33)) then
    g_RaceClassList[raceClass] = 34
  end
  -- ugly but gets the job done.. now figure out why and get rid of this
  local normalTextureName = ''
  if g_RaceClassList[raceClass] then
    normalTextureName = 'Interface\\AddOns\\CensusPlus\\Skin\\CensusPlus_' ..
        g_RaceClassList[raceClass];
  else
    if raceClass == NLZN.RACE.DRACTHYR then
      normalTextureName = 'interface/icons/ui_dracthyr.blp'
    elseif raceClass == NLZN.CLASS.EVOKER then
      normalTextureName = 'interface/icons/classicon_evoker.blp'
    end
  end
  return normalTextureName
end

local function levelSearchText(levelKey)
  local levelSearch = nil;
  if (levelKey ~= nil) then
    levelSearch = '  (' .. CENSUSPLUS_LEVEL .. ': ';
    local level = levelKey;
    if (levelKey < 0) then
      levelSearch = levelSearch .. '!';
      level = 0 - levelKey;
    end
    levelSearch = levelSearch .. level .. ')';
  end
  return levelSearch
end

---Sets up the fixed UI text.
---@param guildFrameTitle string The guild frame title.
---@param factionGName string The faction group name.
---@param locale string? The locale code.
---@param levelKey integer? The level key.
local function setupFixedUiText(guildFrameTitle, factionGName, locale, levelKey)
  CensusPlusRealmName:SetText(CENSUSPLUS_REALMNAME)
  CensusPlusConnected:SetText(CENSUSPLUS_CONNECTED)
  CensusPlusConnected2:SetText(CENSUSPLUS_CONNECTED2)
  CensusPlusConnected3:SetText(CENSUSPLUS_CONNECTED2)
  CensusPlusTopGuildsTitle:SetText(guildFrameTitle)
  CensusPlusFactionName:SetText(format(CENSUSPLUS_FACTION, factionGName))
  if locale then
    CensusPlusLocaleName:SetText(format(CENSUSPLUS_LOCALE, locale))
  end
  local levelSearch = levelSearchText(levelKey)
  local totalCharactersText = format(CENSUSPLUS_TOTALCHAR, g_TotalCount) ..
      (levelSearch or '')
  CensusPlusTotalCharacters:SetText(totalCharactersText)
  CensusPlusConsecutive:SetText(format(CENSUSPLUS_CONSECUTIVE, g_Consecutive))
end

---Gets the selected realm arguments.
---
---Depends on whether the guild button is toggled, return different realm arguments.
---@param connectedRealmsButton integer The realm button ID that was toggled. 0 denotes that no realm button is toggled.
---@return string? realmName, string guildFrameTitle
local function getRealmArguments(connectedRealmsButton)
  local realmName, guildFrameTitle, accumulateGuildTotal = '', '', false
  if connectedRealmsButton == 0 then
    realmName = CPp.CensusPlusLocale .. GetRealmName()
    guildFrameTitle = CENSUSPLUS_GETGUILD
  else
    realmName = CPp.VRealms[connectedRealmsButton]
    guildFrameTitle = CENSUSPLUS_TOPGUILD
  end
  if realmName ~= nil then
    if (CensusPlus_PTR ~= false) then
      realmName = PTR_Color_ProblemRealmGuilds_check(realmName)
    end                                              -- not PTR must be live
    local stsrt, _, _ = string.find(realmName, '%(') -- strip off problem codes from Blizzards Portuguese realm if that has slipped through to this point
    if stsrt ~= nil then
      realmName = string.sub(realmName, 1, stsrt - 2)
    end
  end
  return realmName, guildFrameTitle
end

---Updates the realm button text.
---@param connectedRealmsButton integer The realm button ID that was toggled. 0 denotes that no realm button is toggled.
local function updateRealmButtonText(connectedRealmsButton)
  local conmemcount = #CPp.VRealms
  for i = 1, conmemcount, 1 do
    local textField = 'CensusPlusConnectedRealmButton' .. i .. 'Text'
    if ((CPp.VRealms[i] == nil) or (CPp.VRealms[i] == '')) then
      _G[textField]:SetText('');
    else
      if (i == connectedRealmsButton) then
        _G[textField]:SetText('|cffffd200' .. CPp.VRealms[i] .. '|r');
      else
        _G[textField]:SetText(CPp.VRealms[i]);
      end
    end
  end
end

local function getSelectedRealmKey()
  if (CPp.ConnectedRealmsButton ~= 0) then
    return CPp.VRealms[CPp.ConnectedRealmsButton]
  end
  return nil
end

local function getSelectedGuildKey()
  local guildRealmKey, guildKey = nil, nil
  if (CPp.ConnectedRealmsButton ~= 0) then
    if (CPp.GuildSelected ~= nil) then
      guildRealmKey = CPp.VRealms[CPp.ConnectedRealmsButton]
      guildKey = CPp.GuildSelected;
    end
  else
    if (CPp.GuildSelected ~= nil) then
      CPp.GuildSelected = nil;
    end
  end
  return guildKey, guildRealmKey
end

local function getSelectedRaceKey(factionGroup)
  if (CPp.RaceSelected > 0) then
    local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup);
    return thisFactionRaces[CPp.RaceSelected];
  end
  return nil
end

local function getSelectedClassKey(factionGroup)
  if (CPp.ClassSelected > 0) then
    local thisFactionClasses = CensusPlus_GetFactionClasses(factionGroup);
    return thisFactionClasses[CPp.ClassSelected];
  end
  return nil
end

local function getSelectedLevelKey()
  if CPp.LevelSelected > 0 or CPp.LevelSelected < 0 then
    return CPp.LevelSelected
  end
  return nil
end

local function isRealmSelected()
  return CPp.ConnectedRealmsButton ~= 0
end

local function isRealmChanged()
  return current_realm ~= CPp.ConnectedRealmsButton
end

local function updateCurrentRealm()
  current_realm = CPp.ConnectedRealmsButton
end

---Updates totals for this criteria.
---
---The total count, guild list, and the player list will be updated.
---@param realmKey string?
---@param guildKey string?
---@param guildRealmKey string?
---@param raceKey string?
---@param classKey string?
---@param levelKey integer?
---@param factionGroup string
---@return table accmulatedContainer The accumulated container, which contains {race, class, level} counts.
local function updateTotals(
    realmKey,
    guildKey,
    guildRealmKey,
    raceKey,
    classKey,
    levelKey,
    factionGroup)
  g_TotalCount = 0
  CensusPlus_Guilds = {}
  local accmulatedContainer = nil
  if (isRealmChanged()) then
    CPp.GuildSelected = nil
    updateCurrentRealm()
  end
  if not isRealmSelected() then -- doing superset .. no guild process
    local container, accumulator = getAccumulator()
    for _, realmName in ipairs(CPp.VRealms) do
      if realmName ~= nil and realmName ~= '' then
        CensusPlus_ForAllCharacters(realmName, factionGroup, raceKey,
                                    classKey, nil, levelKey,
                                    nil, function(...)
                                      accumulator(...)
                                      addPlayerToList(...)
                                    end)
      end
    end
    g_TotalCount = container.count
    accmulatedContainer = container
  elseif CPp.GuildSelected then -- Doing a single guild process.
    -- A guild can contain members from different realms, so we need to search
    -- all realms.
    local container, accumulator = getAccumulator()
    for _, realmName in ipairs(CPp.VRealms) do
      if realmName ~= nil and realmName ~= '' then
        CensusPlus_ForAllCharacters(realmName, factionGroup, raceKey,
                                    classKey, guildKey, levelKey,
                                    guildRealmKey, function(...)
                                      accumulator(...)
                                      addPlayerToList(...)
                                      addGuildToList(false, ...)
                                    end)
      end
    end
    g_TotalCount = container.count
    accmulatedContainer = container
  else -- Doing a single realm process.
    local container, accumulator = getAccumulator()
    CensusPlus_ForAllCharacters(realmKey, factionGroup, raceKey, classKey, nil,
                                levelKey, nil, function(...)
                                  accumulator(...)
                                  addPlayerToList(...)
                                  addGuildToList(true, ...)
                                end)
    g_TotalCount = container.count
    accmulatedContainer = container
  end
  if (#CensusPlus_Guilds > 1) then
    table.sort(CensusPlus_Guilds, GuildPredicate)
  end
  return accmulatedContainer
end

---Updates race / class bars.
---@param buttonPrefix string The button prefix. E.g., 'CensusPlusRace'.
---@param categoryList RACE[]|CLASS[] The category list.
---@param countTable table<RACE|CLASS, integer> The count table.
---@param selectedIndex integer The selected button index.
local function updateCategoryBar(
    buttonPrefix,
    categoryList,
    countTable,
    selectedIndex)
  local maxCount = 0
  for _, v in pairs(countTable) do
    if v > maxCount then
      maxCount = v
    end
  end
  for i, category in ipairs(categoryList) do
    local buttonName = buttonPrefix .. 'Bar' .. i
    local button = _G[buttonName]
    local thisCount = countTable[category]
    if thisCount and thisCount > 0 and maxCount > 0 then
      local height = floor((thisCount / maxCount) * CensusPlus_MAXBARHEIGHT)
      if height < 1 or height == nil then
        height = 1
      end
      button:SetHeight(height)
      button:Show()
    else
      button:Hide()
    end
    local normalTextureName = getIconTexture(category)
    local legendName = buttonPrefix .. 'Legend' .. i
    local legend = _G[legendName]
    legend:SetNormalTexture(normalTextureName)
    if selectedIndex == i then
      legend:LockHighlight()
    else
      legend:UnlockHighlight()
    end
  end
end

local function updateLevelBar(countTable)
  local maxCount = 0
  for _, v in pairs(countTable) do
    if v > maxCount then
      maxCount = v
    end
  end
  local logMaxCount = maxCount < 1.1 and log(2) or log(maxCount)
  for i = MIN_CHARACTER_LEVEL, MAX_CHARACTER_LEVEL, 1 do
    local height = 1
    local buttonName = 'CensusPlusLevelBar' .. i
    local button = _G[buttonName]
    local thisCount = countTable[i]
    if thisCount and thisCount > 0 and maxCount > 0 then
      height = floor((log(thisCount + 0.5) / logMaxCount) *
        CensusPlus_MAXBARHEIGHT)
      if CensusPlus_Database['Info']['UseLogBars'] == false or maxCount <= 10 then
        height = floor((thisCount / maxCount) * CensusPlus_MAXBARHEIGHT)
      end
      if height < 1 or height == nil then
        height = 1
      end -- this happens when this count is at minimum (2) and maxCount > 250
      button:SetHeight(height)
      button:Show()
    else
      button:Hide()
    end
  end
end

--[[	-- Search the character database using the search criteria and update display
--
  ]]

function CensusPlus_UpdateView()
  --
  --  No need to d..o anything if the window is not open
  --
  if (not CensusPlus:IsVisible()) then
    return
  end

  if (not (g_VariablesLoaded)) then -- if variables aren't loaded show partial window data and escape
    return
  end

  if (CPp.CensusPlusLocale == 'N/A') then
    return
  end

  local factionGroup, factionGName = UnitFactionGroup('player');
  if (factionGroup == nil or factionGroup == 'Neutral') then
    return; -- rework this area?.. if neutral display warn message elif display faction  ..or not needed handled in xml
  end

  local realmName, guildFrameTitle = getRealmArguments(
    CPp.ConnectedRealmsButton)
  if (realmName == nil) then
    return;
  end

  -- add realmKey to handle superset realm or individual member realm
  -- realmKey will equal one of  - nil = supersetRealm or member realm name
  local realmKey = getSelectedRealmKey()
  local guildKey, guildRealmKey = getSelectedGuildKey()
  local raceKey = getSelectedRaceKey(factionGroup)
  local classKey = getSelectedClassKey(factionGroup)
  local levelKey = getSelectedLevelKey()

  updateRealmButtonText(CPp.ConnectedRealmsButton)
  local accumulatedContainer = updateTotals(realmKey, guildKey, guildRealmKey,
                                            raceKey, classKey, levelKey,
                                            factionGroup)
  setupFixedUiText(guildFrameTitle, factionGName,
                   CensusPlus_Database['Info']['Locale'], levelKey)
  CensusPlus_UpdateGuildButtons();
  local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup);
  updateCategoryBar('CensusPlusRace', thisFactionRaces, accumulatedContainer
                    .race, CPp.RaceSelected)
  local thisFactionClasss = CensusPlus_GetFactionClasses(factionGroup);
  updateCategoryBar('CensusPlusClass', thisFactionClasss,
                    accumulatedContainer.class, CPp.ClassSelected)
  updateLevelBar(accumulatedContainer.level)
  if (CP_PlayerListWindow:IsVisible()) then
    CensusPlus_PlayerListOnShow();
  end
  g_RaceCount = accumulatedContainer.race
  g_ClassCount = accumulatedContainer.class
  g_LevelCount = accumulatedContainer.level
end

--[[	-- Walk the character database and call the callback function for every entry that matches the search criteria
-- 5.4 Need to add guildRealmKey so we can isolate the local and connected realms
  ]]

function CensusPlus_ForAllCharacters(
    realmKey,
    factionKey,
    raceKey,
    classKey,
    guildKey,
    levelKey,
    guildRealmKey,
    callback)
  for realmName, realmDatabase in pairs(CensusPlus_Database['Servers']) do
    if (realmKey == realmName) then --  ((realmKey == nil) or -- realmKey must always be defined.
      for factionName, factionDatabase in pairs(realmDatabase) do
        if ((factionKey == nil) or (factionKey == factionName)) then
          for raceName, raceDatabase in pairs(factionDatabase) do
            if ((raceKey == nil) or (raceKey == raceName)) then
              for className, classDatabase in pairs(raceDatabase) do
                if ((classKey == nil) or (classKey == className)) then
                  for characterName, character in pairs(classDatabase) do
                    local characterGuildRealm = character[3];
                    --										if ((characterGuildRealm == "") or(guildRealmKey == characterGuildRealm)) then  --   -- guildRealmKey must always be defined
                    local characterGuild = character[2];
                    if (((guildKey == nil) and (guildRealmKey == nil)) or ((guildKey == characterGuild) and (guildRealmKey == characterGuildRealm)) or ((guildKey == nil) and (guildRealmKey == characterGuildRealm))) then
                      local characterLevel = character[1];
                      if (characterLevel == nil) then
                        characterLevel = 0;
                      end
                      --												print(characterLevel)
                      if ((levelKey == nil) or (levelKey == characterLevel) or (levelKey < 0 and levelKey + characterLevel ~= 0)) then
                        callback(characterName, characterLevel, characterGuild,
                                 raceName, className, character[4], realmName,
                                 characterGuildRealm);
                      end
                    end
                    --										print(characterName)
                    --										end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

--[[	-- Race legend clicked
--
  ]]

function CensusPlus_OnClickRace(self) -- referenced by CensusPlus.xml
  --  default click is "LeftButton" and up .. no RegisterForClicks used
  local id = self:GetID();
  if (id == CPp.RaceSelected) then
    CPp.RaceSelected = 0;
  else
    CPp.RaceSelected = id;
  end
  CensusPlus_UpdateView();
end

--[[	-- Class legend clicked
--
  ]]

function CensusPlus_OnClickClass(self) -- referenced by CensusPlus.xml
  --  default click is "LeftButton" and up .. no RegisterForClicks used
  local id = self:GetID();
  if (id == CPp.ClassSelected) then
    CPp.ClassSelected = 0;
  else
    CPp.ClassSelected = id;
  end
  CensusPlus_UpdateView();
end

--[[	-- Level bar loaded
--
  ]]

function CensusPlus_OnLoadLevel(self) -- referenced by CensusPlus.xml
  self:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
  --print("CensusPlus_OnLoadLevel")
end

--[[	-- Level bar clicked
--
  ]]

function CensusPlus_OnClickLevel(self, CP_button) -- referenced by CensusPlus.xml
  -- both right and left buttons up registered.
  local id = self:GetID();
  if (((CP_button == 'LeftButton') and (id == CPp.LevelSelected)) or ((CP_button == 'RightButton') and (id + CPp.LevelSelected == 0))) then
    CPp.LevelSelected = 0;
  elseif (CP_button == 'RightButton') then
    CPp.LevelSelected = 0 - id;
  else
    CPp.LevelSelected = id;
  end
  CensusPlus_UpdateView();
end

--[[	-- Race tooltip
--
  ]]

function CensusPlus_OnEnterRace(self, motion) -- referenced by CensusPlus.xml
  if motion then
    local factionGroup = UnitFactionGroup('player');
    local thisFactionRaces = CensusPlus_GetFactionRaces(factionGroup);
    local id = self:GetID();
    local raceName = NLZN.T(thisFactionRaces[id]);
    local count = g_RaceCount[thisFactionRaces[id]];
    if (count ~= nil) and (g_TotalCount > 0) then
      local percent = floor((count / g_TotalCount) * 100);
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
      GameTooltip:SetText(raceName .. '\n' .. count .. '\n' .. percent .. '%',
                          1.0, 1.0, 1.0);
      GameTooltip:Show();
    else
      -- this should never happen
      --		    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      --		    GameTooltip:SetText(raceName.."\n 0", 1.0, 1.0, 1.0);
      --		    GameTooltip:Show();
    end
  end -- event triggered by frame creation.. not moues movement.. so ignore	
end

--[[	-- Class tooltip
--
  ]]

function CensusPlus_OnEnterClass(self, motion) -- referenced by CensusPlus.xml
  if motion then
    local factionGroup = UnitFactionGroup('player');
    local thisFactionClasses = CensusPlus_GetFactionClasses(factionGroup);
    local id = self:GetID();
    local className = NLZN.T(thisFactionClasses[id]);
    local count = g_ClassCount[thisFactionClasses[id]];
    if (count ~= nil) and (g_TotalCount > 0) then
      local percent = floor((count / g_TotalCount) * 100);
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
      GameTooltip:SetText(className .. '\n' .. count .. '\n' .. percent .. '%',
                          1.0, 1.0, 1.0);
      GameTooltip:Show();
    else
      -- this should never happen
      --		    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      --		    GameTooltip:SetText(className.."\n 0", 1.0, 1.0, 1.0);
      --		    GameTooltip:Show();
    end
  end -- entered via frame creation.. not mouse motion .. ignore
end

--[[	-- Level tooltip
--
  ]]

function CensusPlus_OnEnterLevel(self, motion) -- referenced by CensusPlus.xml
  if motion then
    local id = self:GetID();
    local count = g_LevelCount[id];
    if (count ~= nil) and (g_TotalCount > 0) then
      local percent = floor((count / g_TotalCount) * 100);
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
      GameTooltip:SetText(LEVEL .. ' ' .. id .. '\n' .. count ..
                          '\n' .. percent .. '%', 1.0, 1.0, 1.0);
      GameTooltip:Show();
    else
      -- this should never happen
      --			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
      --			GameTooltip:SetText("Level "..id.."\n 0", 1.0, 1.0, 1.0);
      --			GameTooltip:Show();
    end
  end -- entered via frame creation .. not mouse movement.. ignore
end

--[[	-- Clicked a Connected Realm button
--
  ]]
function CENSUSPLUS_CONNECTEDRealmsButton_OnLoad(self) -- referenced by CensusPlus.xml
  self:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
  --print("CensusPlus_ConnectedRealmsButton_OnLoad")
end

function CENSUSPLUS_CONNECTEDRealmsButton_OnClick(self, CP_button) -- referenced by CensusPlus.xml
  local id = self:GetID();
  if ((CP_button == 'LeftButton') and (id == CPp.ConnectedRealmsButton)) then
    CPp.ConnectedRealmsButton = 0;
  else
    CPp.ConnectedRealmsButton = id;
  end
  CensusPlus_UpdateView();
end

--[[	-- Clicked a guild button
--
  ]]

function CensusPlus_GuildButton_OnClick(self) -- referenced by CensusPlus.xml
  --  default click is "LeftButton" and up .. no RegisterForClicks used
  local id = self:GetID();
  local offset = FauxScrollFrame_GetOffset(CensusPlusGuildScrollFrame);
  local newSelection = id + offset;
  local guildKey = CensusPlus_Guilds[newSelection].m_Name;
  if (CPp.GuildSelected ~= guildKey) then
    CPp.GuildSelected = guildKey;
  else
    CPp.GuildSelected = nil;
  end
  CensusPlus_UpdateView();
end

--[[	-- Update the guild button contents
--
  ]]

function CensusPlus_UpdateGuildButtons()
  --
  -- Determine where the scroll bar is
  --
  local offset = FauxScrollFrame_GetOffset(CensusPlusGuildScrollFrame);
  --
  -- Walk through all the rows in the frame
  --
  local size = #CensusPlus_Guilds;
  --	print("num guild buttons = "..size)
  local i = 1;
  while (i <= CensusPlus_NUMGUILDBUTTONS) do
    --
    -- Get the index to the ad displayed in this row
    --
    local iGuild = i + offset;
    --
    -- Get the button on this row
    --
    local button = _G['CensusPlusGuildButton' .. i];
    --
    -- Is there a valid guild on this row?
    --
    if (iGuild <= size) then
      local guild = CensusPlus_Guilds[iGuild];
      --
      -- Update the button text
      --
      button:Show();
      local textField = 'CensusPlusGuildButton' .. i .. 'Text';
      if (guild.m_Name == '') then
        _G[textField]:SetText(CENSUSPLUS_UNGUILDED);
      else
        if (#CPp.VRealms == 1) then
          _G[textField]:SetText(guild.m_Name);
        else
          _G[textField]:SetText(guild.m_GNfull);
        end
      end
      --
      -- If this is the guild, highlight it
      --
      local guildName = CensusPlus_Guilds[iGuild].m_Name
      if (CPp.GuildSelected == guildName) then
        button:LockHighlight();
      else
        button:UnlockHighlight();
      end
    else
      --
      -- Hide the button
      --
      button:Hide();
    end
    --
    -- Next row
    --
    i = i + 1;
  end
  --
  -- Update the scroll bar
  --
  FauxScrollFrame_Update(CensusPlusGuildScrollFrame, size,
                         CensusPlus_NUMGUILDBUTTONS, CensusPlus_GUILDBUTTONSIZEY);
end

--[[	-- CensusPlus_SelectLocale - Set the locale (US or EU)
--
  ]]

function CensusPlus_SelectLocale(locale, auto) -- referenced by CensusPlus.xml
  if (not auto) then
    CensusPlus_Msg(LOCALE_INFORMATION ..
      CENSUSPLUS_WAS .. CPp.CensusPlusLocale .. CENSUSPLUS_NOW .. locale);
  end

  CPp.CensusPlusLocale = locale;
  if (CPp.CensusPlusLocale == 'EU') then
    CPp.CensusPlusLocale = CPp.CensusPlusLocale .. '-';
  else
    CPp.CensusPlusLocale = '';
  end


  CensusPlus_Database['Info']['Locale'] = locale;

  textLine = _G['CensusPlusText'];
  textLine:SetText('Census+ v' ..
    CensusPlus_VERSION_FULL .. ' ' .. CPp.CensusPlusLocale);

  if ((CENSUSPLUS_DWARF == 'Nain' or CENSUSPLUS_DWARF == 'Zwerg' or CENSUSPLUS_DWARF == 'Nano') and GetLocale() == 'usEN') then
    CensusPlus_Msg(CENSUSPLUS_BADLOCAL_1);
    CensusPlus_Msg(CENSUSPLUS_BADLOCAL_2);
    CensusPlus_Msg(CENSUSPLUS_BADLOCAL_3);
  end

  CP_EU_US_Version:Hide();
end

--[[	-- Walk the character database prune all characters entries that are older than X days
--
  ]]

function CENSUSPLUS_PRUNEData(nDays, sServer) -- referenced by CensusPlus.xml
  local conmemcount = #CPp.VRealms
  local superset = nil

  if (CPp.CensusPlusLocale == 'N/A') then
    return;
  end

  --	local thisRealmName = CPp.CensusPlusLocale .. GetRealmName();
  -- local stsrt,_,_ = string.find(thisRealmName,'%(')
  --	if stsrt ~= nil then
  --		thisRealmName = string.sub(thisRealmName,1,stsrt-2)
  --  end

  local pruneTime = 24 * 60 * 60 * nDays;

  for realmName, realmDatabase in pairs(CensusPlus_Database['Servers']) do
    if (sServer) then -- every thing but
      superset = nil
      for i = 1, conmemcount, 1 do
        if ((CPp.VRealms[i] ~= nil) and (CPp.VRealms[i] ~= '') and (realmName == CPp.VRealms[i])) then
          superset = true -- if superset then don't prune
        end
      end
    else
      superset = nil
      for i = 1, conmemcount, 1 do
        if ((CPp.VRealms[i] ~= nil) and (CPp.VRealms[i] ~= '') and (realmName == CPp.VRealms[i])) then
          superset = true -- if superset then do prune
        end
      end
      --		superset ~= superset  -- flip signal
    end

    if (((sServer ~= nil) and (superset == nil)) or ((sServer == nil) and (superset ~= nil))) then
      for factionName, factionDatabase in pairs(realmDatabase) do
        if ((factionKey == nil) or (factionKey == factionName)) then
          for raceName, raceDatabase in pairs(factionDatabase) do
            if ((raceKey == nil) or (raceKey == raceName)) then
              for className, classDatabase in pairs(raceDatabase) do
                if ((classKey == nil) or (classKey == className)) then
                  for characterName, character in pairs(classDatabase) do
                    if (characterName ~= nil) then
                      --[[											if( sServer == 1 ) then
												if( realmName ~= thisRealmName ) then
													CensusPlus_AccumulatePruneData( realmName, factionName, raceName, className, characterName );
												end
--]]
                      --												else
                      --												if( realmName == thisRealmName ) then
                      local lastSeen     = character[4]; --  2005-05-02
                      local tYear, tMonth, tDay;
                      tYear              = string.sub(lastSeen, 1, 4);
                      tMonth             = string.sub(lastSeen, 6, 7);
                      tDay               = string.sub(lastSeen, 9);

                      local lastSeenTime = time({
                        year = tYear,
                        month = tMonth,
                        day = tDay,
                        hour = 0
                      });

                      if (time() - lastSeenTime > pruneTime) then
                        CensusPlus_AccumulatePruneData(realmName, factionName,
                                                       raceName, className,
                                                       characterName);
                      end
                      --												end
                      --											end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  CENSUSPLUS_PRUNETimes();
  CensusPlus_UpdateView();
  CENSUSPLUS_PRUNETheData();
  CENSUSPLUS_PRUNEDeadBranches()
end

--[[	-- Prune the accumulation
--
  ]]

function CensusPlus_AccumulatePruneData(realm, faction, race, class, name)
  local pruneData = {};
  pruneData.realm = realm;
  pruneData.faction = faction;
  pruneData.race = race;
  pruneData.class = class;
  pruneData.name = name;
  -- print("Prune "..realm.." "..faction.." "..race.." "..class.." "..name)
  table.insert(g_AccumulatedPruneData, pruneData);
end

--[[	-- Prune the accumulation
--
  ]]

function CENSUSPLUS_PRUNETheData()
  local num = #g_AccumulatedPruneData;
  CensusPlus_Msg(format(CENSUSPLUS_PRUNEINFO, num));
  while (num > 0) do
    --
    -- Remove the top job from the queue and send it
    --
    local pruneData = g_AccumulatedPruneData[num];

    CensusPlus_Database['Servers'][pruneData.realm][pruneData.faction][pruneData.race][pruneData.class][pruneData.name] = {
    };
    CensusPlus_Database['Servers'][pruneData.realm][pruneData.faction][pruneData.race][pruneData.class][pruneData.name] = nil;

    table.remove(g_AccumulatedPruneData);
    num = #g_AccumulatedPruneData;
  end
end

--[[	-- Prune time entries
--
  ]]

function CENSUSPLUS_PRUNETimes()
  local pruneDays = 60 * 60 * 24 * 21; --  num seconds
  local accumTimesData = {};
  local PruneCount = 0

  for realmName, realmDatabase in pairs(CensusPlus_Database['TimesPlus']) do
    if (realmName ~= nil) then
      for factionName, factionDatabase in pairs(realmDatabase) do
        if (factionName ~= nil) then
          for moment, count in pairs(factionDatabase) do
            --  Moment is in format of YYYY-MM-DD&HH:MM
            local test       = string.sub(moment, 1, 2);
            local tYear, tMonth, tDay;
            tYear            = string.sub(moment, 1, 4);
            tMonth           = string.sub(moment, 6, 7);
            tDay             = string.sub(moment, 9, 10);
            local momentTime = time({
              year = tYear,
              month = tMonth,
              day = tDay,
              hour = 0
            });

            if (time() - momentTime > pruneDays) then
              --  cull entry
              local pruneData = {};
              pruneData.realm = realmName;
              pruneData.faction = factionName;
              pruneData.entry = moment;
              table.insert(accumTimesData, pruneData);
            end
          end
        end
      end
    end
  end

  local num = #accumTimesData;
  while (num > 0) do
    local pruneData = accumTimesData[num];

    CensusPlus_Database['TimesPlus'][pruneData.realm][pruneData.faction][pruneData.entry] = {
    };
    CensusPlus_Database['TimesPlus'][pruneData.realm][pruneData.faction][pruneData.entry] = nil;
    table.remove(accumTimesData);
    num = #accumTimesData;
  end

  for realmName, realmDatabase in pairs(CensusPlus_Database['TimesPlus']) do
    if (realmName ~= nil) then
      for factionName, factionDatabase in pairs(realmDatabase) do
        if (factionName ~= nil) then
          PruneCount = 0
          for _ in pairs(factionDatabase) do
            PruneCount = PruneCount + 1
          end
          if (PruneCount == 0) then
            realmDatabase[factionName] = {};
            realmDatabase[factionName] = nil;
          end
        end
      end
      PruneCount = 0
      for _ in pairs(realmDatabase) do
        PruneCount = PruneCount + 1
      end
      if (PruneCount == 0) then
        CensusPlus_Database['TimesPlus'][realmName] = {};
        CensusPlus_Database['TimesPlus'][realmName] = nil;
      end
    end
  end
end

function CENSUSPLUS_PRUNEDeadBranches()
  local PruneCount = 0
  --	local PRFCName = ""

  for realmName, realmDatabase in pairs(CensusPlus_Database['Servers']) do
    if (realmName ~= nil) then
      --			print(realmName)
      for factionName, factionDatabase in pairs(realmDatabase) do
        if (factionName ~= nil) then
          for raceName, raceDatabase in pairs(factionDatabase) do
            if (raceName ~= nil) then
              for className, classDatabase in pairs(raceDatabase) do
                if (className ~= nil) then
                  PruneCount = 0
                  --									PRFCName = realmName..", "..factionName..", "..raceName..", "..className
                  --									print(PRFCName)
                  for _ in pairs(classDatabase) do
                    PruneCount = PruneCount + 1
                    if (PruneCount > 0) then
                      break
                    end
                  end
                  --									print(PruneCount)
                  if (PruneCount == 0) then
                    raceDatabase[className] = {};
                    raceDatabase[className] = nil;
                  end
                end
              end
              PruneCount = 0
              --							PRFCName = realmName..", "..factionName..", "..raceName
              --							print(PRFCName)
              for _ in pairs(raceDatabase) do
                PruneCount = PruneCount + 1
                if (PruneCount > 0) then
                  break
                end
              end
              --							print(PruneCount)
              if (PruneCount == 0) then
                factionDatabase[raceName] = {};
                factionDatabase[raceName] = nil;
              end
            end
          end
          PruneCount = 0
          --					PRFCName = realmName..", "..factionName
          --					print(PRFCName)
          for _ in pairs(factionDatabase) do
            PruneCount = PruneCount + 1
            if (PruneCount > 0) then
              break
            end
          end
          --					print(PruneCount)
          if (PruneCount == 0) then
            realmDatabase[factionName] = {};
            realmDatabase[factionName] = nil;
          end
        end
      end
      PruneCount = 0
      --			PRFCName = realmName
      --			print(PRFCName)
      for _ in pairs(realmDatabase) do
        PruneCount = PruneCount + 1
        if (PruneCount > 0) then
          break
        end
      end
      --			print(PruneCount)
      if (PruneCount == 0) then
        CensusPlus_Database['Servers'][realmName] = {};
        CensusPlus_Database['Servers'][realmName] = nil;
      end
    end
  end
end

function CensusPlus_CheckForBattleground()
  --	CensusPlus_Msg( "Checking for BG" );
  g_CurrentlyInBG_Msg = false;

  local battlefieldTime = GetBattlefieldInstanceRunTime();
  if (battlefieldTime > 0) then
    --
    --  We are in a battleground so cancel the current take
    --
    g_CurrentlyInBG = true;
  else
    local maxBattleFieldId = GetMaxBattlefieldID()
    for i = 1, maxBattleFieldId do
      local status, _ = GetBattlefieldStatus(i)
      if (status == 'active') then -- if player in battlefield
        g_CurrentlyInBG = true;
      else
        g_CurrentlyInBG = false;
      end
    end
  end
end

function CensusPlus_CheckCRealmDateStatus()
  if (CensusPlus_CRealms['UTCDateStamp'] == nil) or (CensusPlus_CRealms['UTCDateStamp'] ~= date('!%Y-%m-%d')) then
    CensusPlus_CRealms = nil
    CensusPlus_CRealms = {}
    CensusPlus_CRealms['UTCDateStamp'] = CensusPlus_GetUTCDateStr()
  end
end

function CensusPlus_GetUTCDateTimeStr()
  return date('!%Y-%m-%d %H:%M', time());
end

function CensusPlus_GetUTCDateStr()
  return date('!%Y-%m-%d', time());
end

--[[	-- CensusPlus_DetermineServerDate
--
  ]]

function CensusPlus_DetermineServerDate()
  local strDate;
  local weekday, month, day, year;
  local caltab

  caltab = C_DateAndTime.GetCurrentCalendarTime()
  strDate = string.format('%4d-%02d-%02d', caltab.year, caltab.month,
                          caltab.monthDay);
  return strDate;
end

--
-- Check time zone
--


function CensusPlus_CheckTZ()
  local UTCTimeHour    = date('!%H', time());
  local LocTimeHour    = date('%H', time());
  local hour, minute   = GetGameTime();
  local locDiff        = LocTimeHour - UTCTimeHour;
  local servDiff       = hour - UTCTimeHour;
  g_CensusPlusTZOffset = servDiff;
end

local whoMsg

function ManualWho()
  --print("ManualWho")

  local now = time()
  --  print("Now "..now)
  local deltaManual = now - CPp.LastManualWho

  if deltaManual > CensusPlus_UPDATEDELAY then
    if (g_Verbose == true) and whoquery_active then
      CensusPlus_Msg(format(CENSUSPLUS_SENDING, whoMsg));
      print('ManualWho:', whoMsg)
    end
    CPp.LastManualWho = time()
    if (whoquery_active) then
      wholib:Who(whoMsg, CP_ProcessWhoEvent)
      WhoFrameEditBox:SetText(whoMsg)
      WhoFrameWhoButton:Click()
    end
  else
    local cntdwn = CensusPlus_UPDATEDELAY - deltaManual + 1
    CensusButton:SetNormalFontObject(GameFontNormalSmall)
    cntdwn = '|cffADFF2F' .. cntdwn .. '|r'
    CensusButton:SetNormalFontObject(GameFontNormal)
    CensusButton:SetText(cntdwn)
    --   print("Impatient are we??  "..cntdwn)
  end
end

function CensusPlus_SendWho(msg)
  if (g_Verbose == true) then
    --		CensusPlus_Msg(format(CENSUSPLUS_SENDING, msg));
  end

  -- Add CensusButton show top of whoquery
  if (g_CensusButtonAnimi) then
    local _, _, topwho = string.find(msg, '(%d+)')
    --print(topwho)
    topwho = string.sub(msg, string.find(msg, '-', -4) + 1)
    topwhoval = tonumber(topwho)
    if (topwhoval > 99) then
      --	topwho = topwho - 100
      CensusButton:SetNormalFontObject(GameFontNormalSmall)
      topwho = '|cffff5e16' .. topwho .. '|r'
    else
      CensusButton:SetNormalFontObject(GameFontNormal)
    end
    --print(topwho)
    --]]
    CensusButton:SetText(topwho)
  end

  if wholib then
    wholib:Who(msg, CP_ProcessWhoEvent)
    --		wholib:AskWho({query = msg, queue = wholib.WHOLIB_QUEUE_QUIET, callback = CP_ProcessWhoEvent })
  else
    SendWho(msg);
  end

  whoMsg = msg

  whoquery_active = true
  CP_g_queue_count = CP_g_queue_count + 1
end

function PTR_Color_ProblemNames_check(name)
  --[[ PTR testing modifications
			Blizzard has odd naming allowances in PTR realms
			name (US) or name (EU)  ditto for guild names

--]]
  ---			if (HortonBug == true) then
  ---				s.ays("doing the funky chicken");
  ---			end

  if (CensusPlus_PTR ~= false) then
    local cp_ptr_name_check, _, _ = string.find(name, '  %(');
    if (cp_ptr_name_check ~= nil) then
      name = string.sub(name, 1, cp_ptr_name_check - 1) ..
          string.sub(name, cp_ptr_name_check + 3, cp_ptr_name_check + 4);
      ---			if (HortonBug == true) then
      ---				s.ays("1 "..name);
      ---			end
    end
    local cp_ptr_name_check, _, _ = string.find(name, ' %(');
    if (cp_ptr_name_check ~= nil) then
      name = string.sub(name, 1, cp_ptr_name_check - 1) ..
          string.sub(name, cp_ptr_name_check + 2, cp_ptr_name_check + 3);
      --- 			if (HortonBug == true) then
      ---				s.ays("2 "..name);
      ---			end
    end
    local cp_ptr_name_check, _, _ = string.find(name, '%(');
    if (cp_ptr_name_check ~= nil) then
      name = string.sub(name, 1, cp_ptr_name_check - 1) ..
          string.sub(name, cp_ptr_name_check + 1, cp_ptr_name_check + 2);
      ---			if (HortonBug == true) then
      ---				s.ays("3 "..name);
      ---			end
    end
  end

  --
  --  Test the name for possible color coding
  --
  --  for example |cffff0000Rollie|r
  local karma_check = string.find(name, '|cff');
  if (karma_check ~= nil) then
    name = string.sub(name, 11, -3);
  end
  --
  --  Further check for problematic chars
  --
  local pattern = '[%d| ]';
  if (string.find(name, pattern) ~= nil) then
    if (not g_ProblematicMessageShown) then
      CensusPlus_Msg(CENSUSPLUS_PROBLEMNAME ..
        name .. CENSUSPLUS_PROBLEMNAME_ACTION);
      g_ProblematicMessageShown = true;
    end
    name = '';
  end
  return name;
end

function PTR_Color_ProblemRealmGuilds_check(name)
  --[[ PTR testing modifications
			Blizzard has odd naming allowances in PTR realms
			name (US) or name (EU)  ditto for guild names

--]]
  ---			if (HortonBug == true) then
  ---				s.ays("doing the funky chicken");
  ---			end

  if (CensusPlus_PTR ~= false) then
    local cp_ptr_name_check, _, _ = string.find(name, '  %(');
    if (cp_ptr_name_check ~= nil) then
      name = string.sub(name, 1, cp_ptr_name_check - 1) ..
          string.sub(name, cp_ptr_name_check + 3, cp_ptr_name_check + 4);
      if (HortonBug == true) then
        says('1 ' .. name);
      end
    end
    local cp_ptr_name_check, _, _ = string.find(name, ' %(');
    if (cp_ptr_name_check ~= nil) then
      name = string.sub(name, 1, cp_ptr_name_check - 1) ..
          string.sub(name, cp_ptr_name_check + 2, cp_ptr_name_check + 3);
      if (HortonBug == true) then
        says('2 ' .. name);
      end
    end
    local cp_ptr_name_check, _, _ = string.find(name, '%(');
    if (cp_ptr_name_check ~= nil) then
      name = string.sub(name, 1, cp_ptr_name_check - 1) ..
          string.sub(name, cp_ptr_name_check + 1, cp_ptr_name_check + 2);
      if (HortonBug == true) then
        says('3 ' .. name);
      end
    end
  end

  -- work around for Blizzards oddball name for EU-Portuguese server
  if (CensusPlus_Database['Info']['Locale'] == 'EU') then
    local stsrt, _, _ = string.find(name, '%(')
    if stsrt ~= nil then
      name = string.sub(name, 1, stsrt - 2)
    end
    local shortrealm = string.gsub(string.lower(name), '%W', '')
    for k, v in pairs(CompactRealmsEU) do
      if shortrealm == k then
        name = v
        break
      end
    end
    --				realmName = CPp.CensusPlusLocale .. sightingData.realm
  else -- US region
    local shortrealm = string.gsub(string.lower(name), '%W', '')
    for k, v in pairs(CompactRealmsUS) do
      if shortrealm == k then
        name = v
        break
      end
    end
  end
  return name;
end

--[[ -- removed from .xml
function CensusPlus_Options_OnMouseUp(self)
--		print('Mouse up') -- debug
	if ( self.isMoving ) then
		self:StopMovingOrSizing();
		self.isMoving = false;
	end
end

--function CensusPlus_Options_OnMouseDown(self, CPO_button)
--		if ( ( ( not self.isLocked ) or ( self.isLocked == 0 ) ) and ( CPO_button == "LeftButton" ) ) then
function CensusPlus_Options_OnMouseDown(self, CPO_button)
		if (  ( not self.isLocked ) or ( self.isLocked == 0 )   ) then
			self:StartMoving();
			self.isMoving = true;
		end
end
--]]

--[[ this function not correctly setup.. in fact the mini window isn't setup {acutally is is but hidden and off screen}
  ]]
function CensusPlus_Mini_OnMouseDown(self, mCP_button) -- referenced by CensusPlus.xml
  if (((not self.isLocked) or (self.isLocked == 0)) and (mCP_button == 'LeftButton')) then
    self:StartMoving();
    self.isMoving = true;
  end
end

--                if ( ( ( not self.isLocked ) or ( self.isLocked == 0 ) ) and ( CP_button == "LeftButton" ) ) then
-- function CensusPlus_Census_OnMouseDown( self )

function CensusPlus_Census_OnMouseDown(self, CP_button) -- referenced by CensusPlus.xml
  if ((not self.isLocked) or (self.isLocked == 0)) then
    self:StartMoving();
    self.isMoving = true;
  end
end

CensusPlusVersionTagMixin = {}

function CensusPlusVersionTagMixin:Init(initializer)
  local data = initializer:GetData();
  self.Version:SetTextToFit(data.version);
end

CensusPlusOptionPlainTextMixin = {}

function CensusPlusOptionPlainTextMixin:Init(initializer)
  local data = initializer:GetData();
  self.Text:SetTextToFit(data.text);
end

function CensusPlusBlizzardOptions()
  local SavedVars = CensusPlus_Database.Info
  local categoryName = C_AddOns.GetAddOnMetadata('CensusPlus', 'Title')
  local category, layout = Settings.RegisterVerticalLayoutCategory(categoryName)
  local addonSettings = {
    {
      name = CENSUS_OPTIONS_STEALTH,
      variable = 'CensusPlusCheckButton2',
      variableKey = 'Stealth',
      defaultValue = false,
      tooltip = CENSUS_OPTIONS_STEALTH_TOOLTIP,
      callback = function(setting, value)
        CensusPlus_Stealth()
        if not value then
          CensusPlus_Verbose()
        end
      end,
    },
    {
      name = CENSUS_OPTIONS_VERBOSE,
      variable = 'CensusPlusCheckButton1', -- I actually don't know how this is used.
      variableKey = 'Verbose',
      defaultValue = false,
      tooltip = CENSUS_OPTIONS_VERBOSE_TOOLTIP,
      callback = function(setting, value)
        CensusPlus_Verbose()
      end,
    },
    {
      name = CENSUS_OPTIONS_BUTSHOW,
      variable = 'CensusPlusCheckButton3',
      variableKey = 'CensusButtonShown',
      defaultValue = true,
      tooltip = CENSUS_OPTIONS_BUTSHOW,
      callback = function(setting, value)
        CensusPlus_CensusButtonShown()
        if value then
          CensusPlus_CensusButtonAnimi()
        end
      end,
    },
    {
      name = CENSUSPLUS_CENSUSBUTTONANIMITEXT,
      variable = 'CensusPlusCheckButton4',
      variableKey = 'CensusButtonAnimi',
      defaultValue = true,
      tooltip = ENABLE .. ' ' .. CENSUSPLUS_CENSUSBUTTONANIMITEXT,
      callback = function(setting, value)
        CensusPlus_CensusButtonAnimi()
      end,
    },
    {
      name = CENSUS_OPTIONS_AUTOCENSUS,
      variable = 'CensusPlusCheckButton5',
      variableKey = 'AutoCensus',
      defaultValue = true,
      tooltip = CENSUSPLUS_AUTOCENSUSTEXT,
      callback = function(setting, value)
        CensusPlus_SetAutoCensus()
      end,
    },
    {
      name = CENSUS_OPTIONS_SOUND_ON_COMPLETE,
      variable = 'CensusPlusCheckButton6',
      variableKey = 'PlayFinishSound',
      defaultValue = false,
      tooltip = CENSUSPLUS_AUTOCENSUSTEXT,
      callback = function(setting, value)
        CensusPlus_FinishSound()
      end,
    },
    {
      name = CENSUS_OPTIONS_LOG_BARS,
      variable = 'CensusPlusCheckButton7',
      variableKey = 'UseLogBars',
      defaultValue = true,
      tooltip = CENSUS_OPTIONS_LOG_BARSTEXT,
      callback = function(setting, value) end,
    }
  }
  local stealthInitializer = nil
  local verboseInitializer = nil
  local buttonShowInitializer = nil
  local buttonAniInitializer = nil

  for _, settingParameters in ipairs(addonSettings) do
    local name = settingParameters.name
    local variable = settingParameters.variable
    local variableKey = settingParameters.variableKey
    local variableTbl = SavedVars
    local defaultValue = settingParameters.defaultValue
    local tooltip = settingParameters.tooltip
    local callback = settingParameters.callback
    local setting = Settings.RegisterAddOnSetting(category, variable, variableKey,
                                                  variableTbl, type(defaultValue),
                                                  name, defaultValue)
    setting:SetValueChangedCallback(callback)
    local initializer = Settings.CreateCheckbox(category, setting, tooltip)
    if name == CENSUS_OPTIONS_VERBOSE then
      verboseInitializer = initializer
    elseif name == CENSUS_OPTIONS_STEALTH then
      stealthInitializer = initializer
    elseif name == CENSUS_OPTIONS_BUTSHOW then
      buttonShowInitializer = initializer
    elseif name == CENSUSPLUS_CENSUSBUTTONANIMITEXT then
      buttonAniInitializer = initializer
    end
  end

  local function isModifiable() return not SavedVars.Stealth end
  verboseInitializer:SetParentInitializer(stealthInitializer, isModifiable)
  local function isAniModifiable() return SavedVars.CensusButtonShown end
  buttonAniInitializer:SetParentInitializer(buttonShowInitializer,
                                            isAniModifiable)

  do
    local name = CENSUSPLUS_TRANSPARENCY
    local variable = 'CensusPlusSlider2'
    local defaultValue = 50
    local minValue = 10
    local maxValue = 100
    local step = 10
    local function GetValue()
      return SavedVars.CPWindow_Transparency or defaultValue
    end
    local function SetValue(value)
      g_CPWin_background_alpha = value
      SavedVars.CPWindow_Transparency = g_CPWin_background_alpha
    end
    local setting = Settings.RegisterProxySetting(category, variable,
                                                  type(defaultValue), name,
                                                  defaultValue, GetValue,
                                                  SetValue)
    setting:SetValueChangedCallback(function(setting, value)
      g_CPWin_background_alpha = value
      CensusPlusBackground:SetAlpha(g_CPWin_background_alpha / 100)
      CensusPlayerListBackground:SetAlpha(g_CPWin_background_alpha / 100)
    end)
    local tooltip = CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP
    local options = Settings.CreateSliderOptions(minValue, maxValue, step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    Settings.CreateSlider(category, setting, options, tooltip)
  end

  layout:AddInitializer(Settings.CreateElementInitializer(
    'CensusPlusVersionTagTemplate', {version = CensusPlus_VERSION_FULL}))
  layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(
    CENSUSPLUS_SPECIAL_THANKS))
  local specialThanksList = {
    ['Kevin Chu'] = CENSUSPLUS_FOR_TESTING,
    ['RealPazza, Devin'] = CENSUSPLUS_FOR_WHOLIB_REPOSITORY_SUPPORTS,
  }
  for name, desc in pairs(specialThanksList) do
    layout:AddInitializer(Settings.CreateElementInitializer(
      'CensusPlusOptionPlainTextTemplate', {text = name .. ' - ' .. desc}))
  end
  Settings.RegisterAddOnCategory(category)
  CensusPlus_OptionCategory = category
end

function CensusPlus_ResetConfig() -- reset to defaults
  CensusPlus_Database['Info']['AutoCensus'] = true
  CensusPlus_PerCharInfo['AutoCensus'] = nil
  CensusPlus_Database['Info']['Verbose'] = false
  CensusPlus_PerCharInfo['Verbose'] = nil
  CensusPlus_Database['Info']['Stealth'] = false
  CensusPlus_PerCharInfo['Stealth'] = nil
  CensusPlus_Database['Info']['PlayFinishSound'] = false
  CensusPlus_PerCharInfo['PlayFinishSound'] = nil
  CensusPlus_Database['Info']['SoundFile'] = 1
  CensusPlus_PerCharInfo['SoundFile'] = 1
  CensusPlus_Database['Info']['AutoCensusTimer'] = 1800
  CensusPlus_PerCharInfo['AutoCensusTimer'] = 1800
  CensusPlus_Database['Info']['CensusButtonShown'] = true
  CensusPlus_PerCharInfo['CensusButtonShown'] = nil
  CensusPlus_Database['Info']['CensusButtonAnimi'] = true
  CensusPlus_PerCharInfo['CensusButtonAnimi'] = nil
  CensusPlus_Database['Info']['CPWindow_Transparency'] = 50
  CensusPlus_Database['Info']['UseLogBars'] = true
  CensusPlus_Database['Info']['UseWorldFrameClicks'] = false
  CensusPlus_Database['Info']['UseInterfaceClicks'] = false
  CensusPlus_Database['Info']['ChattyOptions'] = true
  --print("ResetConfig")
end

function CensusPlusRestoreSettings() -- reset any changes to saved settings back to previous saved in backups
  -- account wide and CCO overrides
  CensusPlus_Database['Info']['Verbose'] = CPp.Options_Holder['AccountWide']
      ['Verbose']
  CensusPlus_PerCharInfo['Verbose'] = CPp.Options_Holder['CCOverrides']
      ['Verbose']
  CensusPlus_Database['Info']['Stealth'] = CPp.Options_Holder['AccountWide']
      ['Stealth']
  CensusPlus_PerCharInfo['Stealth'] = CPp.Options_Holder['CCOverrides']
      ['Stealth']
  CensusPlus_Database['Info']['CensusButtonShown'] = CPp.Options_Holder
      ['AccountWide']['CensusButtonShown']
  CensusPlus_PerCharInfo['CensusButtonShown'] = CPp.Options_Holder
      ['CCOverrides']['CensusButtonShown']
  CensusPlus_Database['Info']['CensusButtonAnimi'] = CPp.Options_Holder
      ['AccountWide']['CensusButtonAnimi']
  CensusPlus_PerCharInfo['CensusButtonAnimi'] = CPp.Options_Holder
      ['CCOverrides']['CensusButtonAnimi']
  CensusPlus_Database['Info']['AutoCensus'] = CPp.Options_Holder['AccountWide']
      ['AutoCensus']
  CensusPlus_PerCharInfo['AutoCensus'] = CPp.Options_Holder['CCOverrides']
      ['AutoCensus']
  CensusPlus_Database['Info']['AutoCensusTimer'] = CPp.Options_Holder
      ['AccountWide']['AutoCensusTimer']
  CensusPlus_PerCharInfo['AutoCensusTimer'] = CPp.Options_Holder['CCOverrides']
      ['AutoCensusTimer']
  CensusPlus_Database['Info']['PlayFinishSound'] = CPp.Options_Holder
      ['AccountWide']['PlayFinishSound']
  CensusPlus_PerCharInfo['PlayFinishSound'] = CPp.Options_Holder['CCOverrides']
      ['PlayFinishSound']
  CensusPlus_Database['Info']['SoundFile'] = CPp.Options_Holder['AccountWide']
      ['SoundFile']
  CensusPlus_PerCharInfo['SoundFile'] = CPp.Options_Holder['CCOverrides']
      ['SoundFile']
  -- account wide only
  CensusPlus_Database['Info']['CPWindow_Transparency'] = CPp.Options_Holder
      ['AccountWide']['CPWindow_Transparency']
  CensusPlus_Database['Info']['UseLogBars'] = CPp.Options_Holder['AccountWide']
      ['UseLogBars']
  CensusPlus_Database['Info']['ChattyOptions'] = CPp.Options_Holder
      ['AccountWide']['ChattyOptions']
  CensusPlusCloseOptions()
end

function CensusPlusCloseOptions() -- reset Interface Options frame to Blizzard default CONTROLS_LABEL =='Game.Controls'
  InterfaceOptionsFrame_OpenToCategory(CONTROLS_LABEL)
end

-- UI element configurations
CP_EU_US_Version_BackdropInfo = {
  bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
  edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
  tile = true,
  tileEdge = true,
  tileSize = 32,
  edgeSize = 32,
  insets = {left = 11, right = 12, top = 12, bottom = 11},
};

CP_PlayerListWindow_BackdropInfo = {
  edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
  tileEdge = true,
  tileSize = 32,
  edgeSize = 32,
  insets = {left = 11, right = 12, top = 12, bottom = 11},
}
