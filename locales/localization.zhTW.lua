--[[
	CensusPlus for World of Warcraft(tm).
	
	Copyright 2025 Hsiwei Chang (Hudsone)

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 3
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 52 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

if ( GetLocale() == 'zhTW' ) then

CENSUSPLUS_TEXT = 'Census+'

CENSUSPLUS_MSG1 = '載入完成——輸入 /censusplus 或者 /census+ 或者 /census 取得更多有效命令'
CENSUSPLUS_UPLOAD = '確保將你的人口統計資料上傳到www.WarcraftRealms.com!'
CENSUSPLUS_PAUSE = '暫停'
CENSUSPLUS_UNPAUSE = '繼續'
CENSUSPLUS_STOP = '停止'

CENSUSPLUS_PRUNE = '清理資料'
CENSUSPLUS_PRUNECENSUS = '透過刪除在過去30天內未查詢到的角色來清理資料庫'
CENSUSPLUS_PRUNEINFO = '已清理 %d 個角色'
CENSUSPLUS_PURGEDATABASE = '清空所有資料'
CENSUSPLUS_PURGE = '清空'
CENSUSPLUS_PURGEMSG = '清空角色資料庫'
CENSUSPLUS_PURGE_LOCAL_CONFIRM = '你確定想要 清空 你的本地資料庫？'

CENSUSPLUS_TAKECENSUS = [=[統計玩家 
目前伺服器在線 
並且處於該陣營]=]
CENSUSPLUS_PAUSECENSUS = '暫停正在進行的人口普查'
CENSUSPLUS_UNPAUSECENSUS = '繼續目前的人口統計'
CENSUSPLUS_STOPCENSUS_TOOLTIP = '停止目前啟用的 CensusPlus'
CENSUSPLUS_ISINPROGRESS = '人口普查正在進行，請稍後再試'
CENSUSPLUS_TAKINGONLINE = '進行目前在線角色的人口普查'
CENSUSPLUS_NOCENSUS = '目前沒有正在進行的人口普查'
CENSUSPLUS_NOTINFACTION = '中立陣營 - 無法進行人口普查'
CENSUSPLUS_FINISHED = '取得資料完成。發現新角色：%s ，看到：%s。取得：%s。'
CENSUSPLUS_TOOMANY = '警告: 符合條件的角色太多: %s'
CENSUSPLUS_WAITING = '等待傳送 \'who\' 請求...'
CENSUSPLUS_SENDING = '執行 /who %s 命令'
CENSUSPLUS_WHOQUERY = 'Who 查詢:'
CENSUSPLUS_FOUND = '已發現'

CENSUSPLUS_PROCESSING = '進行中: 已取得 %s 個角色'
CENSUSPLUS_REALM = '伺服器'
CENSUSPLUS_REALMNAME = '伺服器: '
CENSUSPLUS_CONNECTED = '已連線:'
CENSUSPLUS_CONNECTED2 = '額外連線:'
CENSUSPLUS_CONSECUTIVE = '連續統計:'
CENSUSPLUS_CONSECUTIVE_0 = '連續統計: 0'
CENSUSPLUS_REALMUNKNOWN = '伺服器: 未知伺服器'
CENSUSPLUS_FACTION = '陣營: %s'
CENSUSPLUS_FACTIONUNKNOWN = '陣營: 未知'
CENSUSPLUS_LOCALE = '地區: %s'
CENSUSPLUS_LOCALEUNKNOWN = '地區: 未知'
CENSUSPLUS_TOTALCHAR = '全部角色: %d'
CENSUSPLUS_TOTALCHAR_0 = '角色總數: 0'
CENSUSPLUS_TOTALCHARXP = ''
CENSUSPLUS_TOTALCHARXP_0 = ''
CENSUSPLUS_SCAN_PROGRESS = '掃描進展: %d 個查詢正在佇列中 - %s'
CENSUSPLUS_SCAN_PROGRESS_0 = '沒有正在進行的掃描'
CENSUSPLUS_AUTOCLOSEWHO = '自動關閉 /who 命令'
CENSUSPLUS_UNGUILDED = '(無公會)'
CENSUSPLUS_TAKE = '開始'
CENSUSPLUS_GETGUILD = '選擇伺服器以查看公會資料'
CENSUSPLUS_TOPGUILD = 'Top Guilds By XP'
CENSUSPLUS_RACE = '種族'
CENSUSPLUS_CLASS = '職業'
CENSUSPLUS_LEVEL = '等級'
CENSUSPLUS_MAXXED = '最大值！'
CENSUSPLUS_GUILDREALM = '公會所屬伺服器'
CENSUSPLUS_LASTSEEN = '最後發現'

CENSUSPLUS_DRUID = '德魯伊'
CENSUSPLUS_HUNTER = '獵人'
CENSUSPLUS_MAGE = '法師'
CENSUSPLUS_PRIEST = '牧師'
CENSUSPLUS_ROGUE = '盜賊'
CENSUSPLUS_WARLOCK = '術士'
CENSUSPLUS_WARRIOR = '戰士'
CENSUSPLUS_SHAMAN = '薩滿'
CENSUSPLUS_PALADIN = '聖騎士'
CENSUSPLUS_DEATHKNIGHT = '死亡騎士'
CENSUSPLUS_MONK = '武僧'
CENSUSPLUS_DEMONHUNTER = '惡魔獵人'
CENSUSPLUS_EVOKER = '喚能師';

CENSUSPLUS_DWARF = '矮人'
CENSUSPLUS_GNOME = '地精'
CENSUSPLUS_HUMAN = '人類'
CENSUSPLUS_NIGHTELF = '夜精靈'
CENSUSPLUS_DRAENEI = '德萊尼'
CENSUSPLUS_WORGEN = '狼人'
CENSUSPLUS_APANDAREN = '熊貓人'
CENSUSPLUS_LIGHTFORGED = '光鑄德萊尼'
CENSUSPLUS_VOIDELF = '虛無精靈'
CENSUSPLUS_DARKIRON = '黑鐵矮人'
CENSUSPLUS_KULTIRAN = '庫爾提拉斯人'
CENSUSPLUS_MECHAGNOME = '機械地精'

CENSUSPLUS_ORC = '獸人'
CENSUSPLUS_TAUREN = '牛頭人'
CENSUSPLUS_TROLL = '食人妖'
CENSUSPLUS_UNDEAD = '不死族'
CENSUSPLUS_BLOODELF = '血精靈'
CENSUSPLUS_GOBLIN = '哥布林'
CENSUSPLUS_HPANDAREN = '熊貓人'
CENSUSPLUS_HIGHMOUNTAIN = '高嶺牛頭人';
CENSUSPLUS_NIGHTBORNE = '夜裔精靈';
CENSUSPLUS_MAGHAR = "瑪格哈獸人";
CENSUSPLUS_ZANDALARI = '贊達拉食人妖';
CENSUSPLUS_VULPERA = '狐狸人';
CENSUSPLUS_DRACTHYR = '半龍人'
CENSUSPLUS_EARTHEN = '土靈'

CENSUSPLUS_US_LOCALE = '玩家處於美服則選擇該項'
CENSUSPLUS_EU_LOCALE = '玩家處於歐服則選擇該項'
CENSUSPLUS_LOCALE_SELECT = '玩家處於美服或者歐服則選擇該項'
CENSUSPLUS_OPTIONS_OVERRIDE = '覆蓋'
CENSUSPLUS_BUTTON_OPTIONS = '選項'
CENSUSPLUS_OPTIONS_HEADER = 'Census+ 選項'
CENSUSPLUS_ACCOUNT_WIDE = '帳號通用'
CENSUSPLUS_ACCOUNT_WIDE_ONLY_OPTIONS = '僅帳號通用選項'
CENSUSPLUS_CCO_OPTIONOVERRIDES = '為目前角色覆蓋的選項'
CENSUSPLUS_ISINBG = '處於戰場環境下不能進行人口普查'
CENSUS_OPTIONS_BUTSHOW = '顯示小地圖按鈕'
CENSUS_OPTIONS_AUTOCENSUS = '自動統計'
CENSUS_OPTIONS_AUTOSTART = '自動開始'
CENSUS_OPTIONS_VERBOSE = '詳細訊息模式'
CENSUS_OPTIONS_VERBOSE_TOOLTIP = '啟用在聊天框顯示詳細訊息，停用隱形模式'
CENSUS_OPTIONS_STEALTH = '隱形模式'
CENSUS_OPTIONS_STEALTH_TOOLTIP = '隱形模式 - 無聊天訊息，停用詳細訊息模式'
CENSUS_OPTIONS_SOUND_ON_COMPLETE = '完成統計後播放提示音'
CENSUS_OPTIONS_SOUND_TOOLTIP = '啟用提示音之後選擇音訊檔案'
CENSUS_OPTIONS_SOUNDFILE = '選擇使用者提供的音訊檔案編號 '
CENSUS_OPTIONS_SOUNDFILETEXT = '選擇想要的 .mp3 或 .OGG 音訊檔案'
CENSUS_OPTIONS_TIMER_TOOLTIP = '設定自上次統計結束後的延遲時間.'
CENSUS_OPTIONS_LOG_BARS = '對數統計長條圖'
CENSUS_OPTIONS_LOG_BARSTEXT = '啟用對數縮放顯示長條圖'
CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP = '背景透明度 - 10 個級別'
CENSUSPLUS_VERBOSE_TOOLTIP = '取消勾選以停止顯示詳細訊息！'
CENSUSPlus_AUTOCENSUS_TOOLTIP = '在遊戲中自動開始統計'
CENSUSPLUS_OPTIONS_CHATTYCONFIRM = '聊天框選項確認訊息 - 勾選以啟用'
CENSUSPLUS_OPTIONS_CHATTY_TOOLTIP = '啟用在聊天框顯示目前選項設定 - 當選項視窗開啟時或者設定改變時顯示'

CENSUSPLUS_BUTTON_CHARACTERS = '顯示角色名單'
CENSUSPLUS_CHARACTERS = '角色'

CENSUS_BUTTON_TOOLTIP = '開啟 CensusPlus'
CENSUSPLUS_PROBLEMNAME = '目前名字存在問題 => '
CENSUSPLUS_PROBLEMNAME_ACTION = ', 名字跳過。該資訊只會顯示一次。'
CENSUSPLUS_BADLOCAL_1 = '你似乎安裝了英文版本的 CensusPlus，但你的語言設定為了法語或德語或義大利語。'
CENSUSPLUS_BADLOCAL_2 = '在問題解決之前請不要將資料上傳到 WarcraftRealms。'
CENSUSPLUS_BADLOCAL_3 = '如果這不正確，請將你的情況回報給 www.WarcraftRealms.com 的 Bringoutyourdead，他能修正這些錯誤。'
CENSUSPLUS_WRONGLOCAL_PURGE = '語言設定與之前不同，清空不相容的資料';
CENSUSPLUS_WAS = ' 曾為 '
CENSUSPLUS_NOW = ' 現在 '
CENSUSPLUS_USING_WHOLIB = '使用 WhoLib'
CENSUSPLUS_LASTSEEN_COLON = ' 最後發現: '
CENSUSPLUS_FOUND_CAP = '已發現 '
CENSUSPLUS_PLAYERS = ' 玩家。'
CENSUSPLUS_AND = ' 與 '
CENSUSPLUS_OR = ' 或 '
CENSUSPLUS_USAGE = '用法:'
CENSUSPLUS_STEALTHON = '隱形模式 : 啟用'
CENSUSPLUS_STEALTHOFF = '隱形模式 : 停用'
CENSUSPLUS_VERBOSEON = '詳細訊息模式 : 啟用'
CENSUSPLUS_VERBOSEOFF = '詳細訊息模式 : 停用'
CENSUSPLUS_CENSUSBUTTONSHOWNON = '小地圖按鈕 : 啟用'
CENSUSPLUS_CENSUSBUTTONSHOWNOFF = '小地圖按鈕 : 停用'
CENSUSPLUS_CENSUSBUTTONANIMION = '小地圖按鈕動畫 : 啟用'
CENSUSPLUS_CENSUSBUTTONANIMIOFF = '小地圖按鈕動畫 : 停用'
CENSUSPLUS_CENSUSBUTTONANIMITEXT = '小地圖按鈕動畫'
CENSUSPLUS_AUTOCENSUSON = '自動統計 : 啟用'
CENSUSPLUS_AUTOCENSUSOFF = '自動統計 : 停用'
CENSUSPLUS_AUTOCENSUSTEXT = '初步延遲後開始統計'
CENSUSPLUS_AUTOCENSUS_DELAYTIME = '延遲分鐘數'
CENSUSPLUS_AUTOSTARTTEXT = '登入後自動開始統計，當計時器小於 '
CENSUSPLUS_PLAYFINISHSOUNDON = '播放統計完成提示音 : 啟用'
CENSUSPLUS_PLAYFINISHSOUNDOFF = '播放統計完成提示音 : 停用'
CENSUSPLUS_PLAYFINISHSOUNDNUM = '完成提示音 編號 '
CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE = '移除覆蓋'
CENSUSPLUS_UNKNOWNRACE = '發現未知種族 ( '
CENSUSPLUS_UNKNOWNRACE_ACTION = ' )，請告知WarcraftRealms.com的Bringoutyourdead'
CENSUSPLUS_TOOSLOW = '更新過慢！電腦不給力？網路連線有問題？'
CENSUSPLUS_LANGUAGECHANGED = '客戶端語言改變，資料庫已清空。'
CENSUSPLUS_CONNECTEDREALMSFOUND = 'CensusPlus 已發現以下連線的伺服器'
CENSUSPLUS_OBSOLETEDATAFORMATTEXT = '資料庫格式過時，資料庫已清空。'
CENSUSPLUS_TRANSPARENCY = '統計視窗透明度'
CENSUSPLUS_PURGEDALL = '所有統計資料已清空'
CENSUSPLUS_HELP_0 = ' 命令如下'
CENSUSPLUS_HELP_1 = ' _ 啟用/停用詳細訊息'
CENSUSPLUS_HELP_2 = ' _ 開啟選項視窗'
CENSUSPLUS_HELP_3 = ' _ 開始 Census 快照'
CENSUSPLUS_HELP_4 = ' _ 停止 Census 快照'
CENSUSPLUS_HELP_5 = ' X  _ 整理資料庫，刪除 X 天內沒有發現過的角色，預設 X = 30'
CENSUSPLUS_HELP_6 = ' X _ 整理資料庫，刪除非目前伺服器中 X 天內沒有發現過的角色，預設 X = 0'
CENSUSPLUS_HELP_7 = ' _  將顯示符合名字的訊息。'
CENSUSPLUS_HELP_8 = ' _  將顯示該級別無公會的角色。'
CENSUSPLUS_HELP_9 = ' _  將設定自動統計的計時器 (為 X 分鐘)。'
CENSUSPLUS_HELP_10 = ' _ 更新玩家角色資訊…… /CensusPlus 完成時自動進行。';
CENSUSPLUS_HELP_11 = ' _ 啟用/停用隱形模式，啟用會關閉詳細訊息模式並隱藏 CensusPlus 所有的訊息。'

end