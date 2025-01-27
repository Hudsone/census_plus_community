--[[
	CensusPlus for World of Warcraft(tm).
	
	Copyright 2005 - 2012 Cooper Sellers and WarcraftRealms.com

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
]]
-- initial translations provided by kisswow@curseforge   many phrases need translation .. and review.

-- WARNING: Phrase keys "CensusPlus_LastSeen", "CENSUSPlus_LASTSEEN" evaluate to the same lua identifier "CENSUSPLUS_LASTSEEN". Only the value of "CENSUSPlus_LASTSEEN" will be used. To fix this, rename one or more of the phrase keys.

-- WARNING: Phrase keys "CensusPlus_Found", "CensusPlus_FOUND" evaluate to the same lua identifier "CENSUSPLUS_FOUND". Only the value of "CensusPlus_FOUND" will be used. To fix this, rename one or more of the phrase keys.
if ( GetLocale() == "koKR" ) then
CENSUS_BUTTON_TOOLTIP = "센서스+ 열기"

CENSUS_OPTIONS_AUTOCENSUS = "자동-센서스"

CENSUS_OPTIONS_AUTOSTART = "자동-시작"
CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP = "배경 투명도 - 10 단계"

CENSUS_OPTIONS_BUTSHOW = "미니맵 버튼 보이기"

-- Missing translation
-- CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE = "Remove Override"

CENSUS_OPTIONS_LOG_BARS = "로그마틱 레벨 그래프"

-- Missing translation
-- CENSUS_OPTIONS_LOG_BARSTEXT = "Enables Logarithmic scaling on display bars"

CENSUS_OPTIONS_SOUND_ON_COMPLETE = "종료시 소리 재생"

CENSUS_OPTIONS_SOUND_TOOLTIP = "사운드 사용 및 사운드 파일 선택"
CENSUS_OPTIONS_SOUNDFILE = "사용자 사운드 파일 번호 선택"
CENSUS_OPTIONS_SOUNDFILETEXT = "원하는 .mp3 또는 .OGG 사운드 파일을 선택하십시오."
-- Missing translation
-- CENSUS_OPTIONS_SOUNDFILEDEFAULT = "Select default SoundFile number "

-- Missing translation
-- CENSUS_OPTIONS_STEALTH = "Stealth"

-- Missing translation
-- CENSUS_OPTIONS_STEALTH_TOOLTIP = "Stealth mode - no chat messages, disables Verbose"
CENSUS_OPTIONS_TIMER_TOOLTIP = "마지막 센서스 결과부터의 지연을 분 단위로 설정합니다."

CENSUS_OPTIONS_VERBOSE = "모두 알림"

-- Missing translation
-- CENSUS_OPTIONS_VERBOSE_TOOLTIP = "Enables verbose text in chat window, disables Stealth mode"

-- Missing translation
-- CENSUSPLUS_ACCOUNT_WIDE = "Account wide"

-- Missing translation
-- CENSUSPLUS_ACCOUNT_WIDE_ONLY_OPTIONS = "Account Wide Only options"

-- Missing translation
-- CENSUSPLUS_AND = " and "

CENSUSPLUS_APANDAREN = "판다렌"

-- Missing translation
-- CENSUSPLUS_AUTOCENSUS_DELAYTIME = "Delay in minutes"
CENSUSPLUS_AUTOCENSUS_DELAYTIME = "지연 시간 (분)"
CENSUSPLUS_AUTOCENSUSOFF = "자동센서스 모드 : OFF"
CENSUSPLUS_AUTOCENSUSON = "자동센서스 모드 : ON"
CENSUSPLUS_AUTOCENSUSTEXT = "초기 지연 후 인구 조사 시작"

-- Missing translation
-- CENSUSPLUS_AUTOCENSUSOFF = "AutoCensus Mode : OFF"

-- Missing translation
-- CENSUSPLUS_AUTOCENSUSON = "AutoCensus Mode : ON"

-- Missing translation
-- CENSUSPLUS_AUTOCENSUSTEXT = "Start Census after initial delay"

CENSUSPLUS_AUTOCENSUS_TOOLTIP = "플레이 시 자동으로 센서스+ 검색 시작"

CENSUSPLUS_AUTOCLOSEWHO = "누구 창 자동으로 닫기"

CENSUSPLUS_AUTOSTARTTEXT = "타이머가 적을 때 로그인시 자동 시작"
CENSUSPLUS_BADLOCAL_1 = "미국 센서스 버전이있는 것 같지만 현지화가 프랑스어 또는 독일어 또는 이탈리아어로 설정되어 있습니다."
CENSUSPLUS_BADLOCAL_2 = "이 문제가 해결 될 때까지 WarcraftRealms에 데이터를 업로드하지 마십시오."
CENSUSPLUS_BADLOCAL_3 = "이것이 틀린 경우, Bringoutyourdead에게 www.WarcraftRealms.com에서 귀하의 상황에 대해 알려서 수정 할 수 있도록하십시오."

CENSUSPLUS_BLOODELF = "블러드 엘프"

CENSUSPLUS_BUTTON_CHARACTERS = "캐릭터 보기"

CENSUSPLUS_BUTTON_OPTIONS = "설정"

CENSUSPLUS_CCO_OPTIONOVERRIDES = "이 문자에 대해서만 옵션 덮어 쓰기"
CENSUSPLUS_CENSUSBUTTONANIMIOFF = "센서스버튼 애니메이션 : OFF"
CENSUSPLUS_CENSUSBUTTONANIMION = "센서스버튼 애니메이션 : ON"
CENSUSPLUS_CENSUSBUTTONANIMITEXT = "센서스 버튼 애니메이션"

-- Missing translation
-- CENSUSPLUS_CENSUSBUTTONSHOWNOFF = "CensusButton Mode : OFF"

-- Missing translation
-- CENSUSPLUS_CENSUSBUTTONSHOWNON = "CensusButton Mode : ON"

CENSUSPLUS_CHARACTERS = "캐릭터"

CENSUSPLUS_CLASS = "직업"

-- Missing translation
-- CENSUSPLUS_CMDERR_WHO2 = "Who commands should be:  who name level  _ no name found, level is optional"

-- Missing translation
-- CENSUSPLUS_CMDERR_WHO2NUM = "Who commands can be: who name  _ no numbers in name"

CENSUSPLUS_CONNECTED = "연결됨:"
CENSUSPLUS_CONNECTED2 = "추가 연결됨:"

-- Missing translation
-- CENSUSPLUS_CONNECTEDREALMSFOUND = "CensusPlus found the following Connected Realms"
CENSUSPLUS_CONSECUTIVE = "연속 인구 조사:"
CENSUSPLUS_DEMONHUNTER = "악마 사냥꾼"

CENSUSPLUS_DEATHKNIGHT = "죽음의 기사"

CENSUSPLUS_DRAENEI = "드레나이"

CENSUSPLUS_DRUID = "드루이드"

CENSUSPLUS_DWARF = "드워프"

CENSUSPLUS_EU_LOCALE = "당신은 유럽서버에서 플레이하면 선택"

CENSUSPLUS_FACTION = "진영: %s"

CENSUSPLUS_FACTIONUNKNOWN = "진영: 알수없음"

CENSUSPLUS_FINISHED = "데이터 수집 완료. %s 의 새 캐릭터가 검색되어 총 %s 캐릭터를 확인했습니다. 소요 시간 :%s"

-- Missing translation
-- CENSUSPLUS_FOUND = "Found "

CENSUSPLUS_FOUND = "발견"

CENSUSPLUS_GETGUILD = "길드 데이터 영역을 클릭하십시오."

CENSUSPLUS_GNOME = "노움"

CENSUSPLUS_GOBLIN = "고블린"

-- Missing translation
-- CENSUSPLUS_GUILDREALM = "Guild's Realm"

-- Missing translation
-- CENSUSPLUS_HELP_0 = " following command as shown below"

-- Missing translation
-- CENSUSPLUS_HELP_1 = " _ Toggle verbose mode off/on"

-- Missing translation
-- CENSUSPLUS_HELP_10 = " _ Does Census update of player only.. this is done automatically when /CensusPlus take finishes."

-- Missing translation
-- CENSUSPLUS_HELP_11 = " _ Toggles stealth mode off/on - disables Verbose and all CensusPlus chat messages."

-- Missing translation
-- CENSUSPLUS_HELP_2 = " _ Brings up the Option window"

-- Missing translation
-- CENSUSPLUS_HELP_3 = " _ Start a Census snapshot"

-- Missing translation
-- CENSUSPLUS_HELP_4 = " _ Stop a Census snapshot"

-- Missing translation
-- CENSUSPLUS_HELP_5 = " X  _ Prune the database by removing characters not seen in X days - default X = 30"

-- Missing translation
-- CENSUSPLUS_HELP_6 = " X _ Prune the database by removing all characters not seen in X days from servers other than the one you are currently on. - default X = 0"

-- Missing translation
-- CENSUSPLUS_HELP_7 = " _  Will display info that matches names."

-- Missing translation
-- CENSUSPLUS_HELP_8 = " _  Will list unguilded characters of that level."

-- Missing translation
-- CENSUSPLUS_HELP_9 = " _  Will set the autocensus timer (to X minutes)."

CENSUSPLUS_HPANDAREN = "판다렌"

CENSUSPLUS_HUMAN = "인간"

CENSUSPLUS_HUNTER = "사냥꾼"

CENSUSPLUS_ISINBG = "현재 전장에 있기 때문에 센서스가 작동하지 않습니다."

CENSUSPLUS_ISINPROGRESS = "센서스+가 진행중입니다, 나중에 다시 시도하십시오."

-- Missing translation
-- CENSUSPLUS_LANGUAGECHANGED = "Client Language changed, Database purged."

-- Missing translation
-- CENSUSPLUS_LASTSEEN = " Last Seen: "

-- Missing translation
-- CENSUSPLUS_LASTSEEN = "Last Seen"

CENSUSPLUS_LEVEL = "레벨"

CENSUSPLUS_LOCALE = "지역 : %s"

CENSUSPLUS_LOCALE_SELECT = "당신이 미국 또는 유럽 서버에서 할 경우 선택합니다."

CENSUSPLUS_LOCALEUNKNOWN = "지역 : 알수없음"

CENSUSPLUS_MAGE = "마법사"

CENSUSPLUS_MAXXED = "MAXXED!"

CENSUSPLUS_MONK = "수도사"

CENSUSPLUS_MSG1 = "센서스+ 로드됨 - /censusplus 나 /census+ 를 입력해 메인 창을 띄울 수 있습니다."

CENSUSPLUS_NIGHTELF = "나이트 엘프"

CENSUSPLUS_NOCENSUS = "센서스가 현재 진행중이 아닙니다."

CENSUSPLUS_NOTINFACTION = "중립 진영 -  캐릭터가 없습니다."

-- Missing translation
-- CENSUSPLUS_NOW = " now "

-- Missing translation
-- CENSUSPLUS_OBSOLETEDATAFORMATTEXT = "Old Database format found, Database purged."

-- Missing translation
-- CENSUSPLUS_OPTIONS_CHATTYCONFIRM = "Chatty Option confirmation - check to enable"

-- Missing translation
-- CENSUSPLUS_OPTIONS_CHATTY_TOOLTIP = "Enable chat to show current options settings - displays on interface options window opening and many CensusPlus option changes"

CENSUSPLUS_OPTIONS_HEADER = "센서스+ 설정"

-- Missing translation
-- CENSUSPLUS_OPTIONS_OVERRIDE = "Override"

-- Missing translation
-- CENSUSPLUS_OR = " or "

CENSUSPLUS_ORC = "오크"

CENSUSPLUS_PALADIN = "성기사"

CENSUSPLUS_PAUSE = "일시중지"

CENSUSPLUS_PAUSECENSUS = "현재 센서스를 일시중지 합니다."

-- Missing translation
-- CENSUSPLUS_PLAYERS = " players."

-- Missing translation
-- CENSUSPLUS_PLAYFINISHSOUNDNUM = "FinishSound number "

-- Missing translation
-- CENSUSPLUS_PLAYFINISHSOUNDOFF = "PlayFinishSound Mode : OFF"

-- Missing translation
-- CENSUSPLUS_PLAYFINISHSOUNDON = "PlayFinishSound Mode : ON"

CENSUSPLUS_PRIEST = "사제"

-- Missing translation
-- CENSUSPLUS_PROBLEMNAME = "This name is problematic => "

-- Missing translation
-- CENSUSPLUS_PROBLEMNAME_ACTION = ", name skipped.  This message will only be shown once."

CENSUSPLUS_PROCESSING = "%s 캐릭터를 수집함."

CENSUSPLUS_PRUNE = "간략화"

CENSUSPLUS_PRUNECENSUS = "30일동안 검색되지 않은 플레이어를 데이터베이스에서 제거해 간략화 합니다."

CENSUSPLUS_PRUNEINFO = "%d 캐릭터 간략화됨."

CENSUSPLUS_PURGE = "삭제"

-- Missing translation
-- CENSUSPLUS_PURGEDALL = "All Census Data Purged"

CENSUSPLUS_PURGEDATABASE = "모든 데이터를 삭제합니다."

CENSUSPLUS_PURGE_LOCAL_CONFIRM = "정말로 로컬 데이터베이스의 모든 자료를 삭제하겠습니까?"

CENSUSPLUS_PURGEMSG = "캐릭터 데이터베이스가 삭제되었습니다."

CENSUSPLUS_RACE = "종족"

-- Missing translation
-- CENSUSPLUS_REALM = "Realm"

CENSUSPLUS_REALMNAME = "서버: %s"

CENSUSPLUS_REALMUNKNOWN = "서버: 알수없음"

CENSUSPLUS_ROGUE = "도적"

CENSUSPLUS_SCAN_PROGRESS = "검색 진행중: %d 개의 질의 대기중 - %s"

CENSUSPLUS_SCAN_PROGRESS_0 = "진행중인 검색이 없습니다."

CENSUSPLUS_SENDING = "검색중 : /누구 %s"

CENSUSPLUS_SHAMAN = "주술사"

-- Missing translation
-- CENSUSPLUS_STEALTHOFF = "Stealth Mode : OFF"

-- Missing translation
-- CENSUSPLUS_STEALTHON = "Stealth Mode : ON"

CENSUSPLUS_STOP = "중지"

CENSUSPLUS_STOPCENSUS_TOOLTIP = "활성중인 센서스+를 중지합니다."

CENSUSPLUS_TAKE = "가져오기"

CENSUSPLUS_TAKECENSUS = "현재 이 서버와 이 진영에 속한 플레이어를 센서스로 가져옵니다."

CENSUSPLUS_TAKINGONLINE = "온라인 상태의 캐릭터를 센서스로 가져오는 중입니다..."

CENSUSPLUS_TAUREN = "타우렌"

CENSUSPLUS_TEXT = "센서스+"

CENSUSPLUS_TOOMANY = "경고: 너무 많은 캐릭터 일치: %s"

-- Missing translation
-- CENSUSPLUS_TOOSLOW = "Update too slow! Computer overloaded?Connection problems?"

CENSUSPLUS_TOPGUILD = "XP 에 의한 길드 순위"

CENSUSPLUS_TOTALCHAR = "모든 캐릭터: %d"

CENSUSPLUS_TOTALCHAR_0 = "모든 캐릭터: 0"

CENSUSPLUS_TOTALCHARXP = ""  -- XP 지수: %d

CENSUSPLUS_TOTALCHARXP_0 = ""  -- XP 지수: 0

-- Missing translation
-- CENSUSPLUS_TRANSPARENCY = "Census window transparency"

CENSUSPLUS_TROLL = "트롤"

CENSUSPLUS_UNDEAD = "언데드"

CENSUSPLUS_UNGUILDED = "(길드없음)"

-- Missing translation
-- CENSUSPLUS_UNKNOWNRACE = "Found an unknown race ( "

-- Missing translation
-- CENSUSPLUS_UNKNOWNRACE_ACTION = " ), please tell Bringoutyourdead at WarcraftRealms.com"

CENSUSPLUS_UNPAUSE = "계속"

CENSUSPLUS_UNPAUSECENSUS = "일시중지된 센서스를 계속 진행합니다."

CENSUSPLUS_UPLOAD = " " -- sorry WarcraftRealms.com can not handle multi-byte Korean character set at this time.  "www.WarcraftRealms.com 에서 센서스+ 업데이트를 확인하세요!"

-- Missing translation
-- CENSUSPLUS_USAGE = "Usage:"

-- Missing translation
-- CENSUSPLUS_USING = "Using "

CENSUSPLUS_US_LOCALE = "당신은 미국서버에서 플레이하면 선택"

-- Missing translation
-- CENSUSPLUS_VERBOSEOFF = "Verbose Mode : OFF"

-- Missing translation
-- CENSUSPLUS_VERBOSEON = "Verbose Mode : ON"

CENSUSPLUS_VERBOSE_TOOLTIP = "스팸 메시지를 멈추려면 해제하세요!"

CENSUSPLUS_WAITING = "누구 명령어를 보내기 위해 기다리는 중..."

CENSUSPLUS_WARLOCK = "흑마법사"

CENSUSPLUS_WARRIOR = "전사"

-- Missing translation
-- CENSUSPLUS_WAS = " was "

CENSUSPLUS_WHOQUERY = "누구 조회:"

CENSUSPLUS_WORGEN = "늑대인간"

-- Missing translation
-- CENSUSPLUS_WRONGLOCAL_PURGE = "Locale differs from previous setting, purging database."
end
