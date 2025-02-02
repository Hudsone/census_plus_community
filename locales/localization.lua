--[[
	CensusPlus for World of Warcraft(tm).
	
	Copyright 2005 - 2016 Cooper Sellers and WarcraftRealms.com

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
--print("English localization loading")
CENSUS_OPTIONS_SOUNDFILEDEFAULT =
'CensusPlus\\Sounds\\CensusComplete' -- "Select default SoundFile number "; - DO NOT LOCALIZE
CENSUSPlusFemale                = {};

-- Translations start below

CENSUSPLUS_TEXT                 = 'Census+';

CENSUSPLUS_MSG1                 =
' Loaded - type /censusplus or /census+  or /census for valid commands';
CENSUSPLUS_UPLOAD               =
'Be sure to upload your CensusPlus data to www.WarcraftRealms.com!';
CENSUSPLUS_PAUSE                = 'Pause';
CENSUSPLUS_UNPAUSE              = 'Resume';
CENSUSPLUS_STOP                 = 'Stop';

CENSUSPLUS_PRUNE                = 'Prune';
CENSUSPLUS_PRUNECENSUS          =
'Prune the database by removing characters not seen in 30 days.';
CENSUSPLUS_PRUNEINFO            = 'Pruned %d characters.';
CENSUSPLUS_PURGEDATABASE        = 'Purge the database of all data';
CENSUSPLUS_PURGE                = 'Purge';
CENSUSPLUS_PURGEMSG             = 'Purged character database.';
CENSUSPLUS_PURGE_LOCAL_CONFIRM  =
'Are you sure you wish to PURGE your local database?';

CENSUSPLUS_TAKECENSUS           =
'Take a census of players \ncurrently online on this server \nand in this faction';
CENSUSPLUS_PAUSECENSUS          = 'Pause the current census';
CENSUSPLUS_UNPAUSECENSUS        = 'Resume the current census';
CENSUSPLUS_STOPCENSUS_TOOLTIP   = 'Stop the currently active CensusPlus';
CENSUSPLUS_ISINPROGRESS         = 'A CensusPlus is in progress, try again later';
CENSUSPLUS_TAKINGONLINE         = 'Taking census of characters online...';
CENSUSPLUS_NOCENSUS             = 'A Census is not currently in progress';
CENSUSPLUS_NOTINFACTION         = 'Neutral faction - census not allowed';
CENSUSPLUS_FINISHED             =
'Finished Taking data. Found %s new characters and saw %s. Took %s.';
CENSUSPLUS_TOOMANY              = 'WARNING: Too many characters matching: %s';
CENSUSPLUS_WAITING              = 'Waiting to send who request...';
CENSUSPLUS_SENDING              = 'Ready to Send /who %s';
CENSUSPLUS_WHOQUERY             = 'Who query:'
CENSUSPLUS_FOUND                = 'found'

CENSUSPLUS_PROCESSING           = 'Processing %s characters.';
CENSUSPLUS_REALM                = 'Realm';
CENSUSPLUS_REALMNAME            = 'Realm: ';
CENSUSPLUS_CONNECTED            = 'Connected:';
CENSUSPLUS_CONNECTED2           = 'Additional Connected:';
CENSUSPLUS_CONSECUTIVE          = 'Consecutive Census: %d';
CENSUSPLUS_CONSECUTIVE_0        = 'Consecutive Census: 0';
CENSUSPLUS_REALMUNKNOWN         = 'Realm: Unknown';
CENSUSPLUS_FACTION              = 'Faction: %s';
CENSUSPLUS_FACTIONUNKNOWN       = 'Faction: Unknown'; -- replace this text with notinfaction above?
CENSUSPLUS_LOCALE               = 'Locale : %s';
CENSUSPLUS_LOCALEUNKNOWN        = 'Locale : Unknown';
CENSUSPLUS_TOTALCHAR            = 'Total Characters: %d';
CENSUSPLUS_TOTALCHAR_0          = 'Total Characters: 0';
CENSUSPLUS_TOTALCHARXP          = ''; -- XP Factor: %d
CENSUSPLUS_TOTALCHARXP_0        = ''; -- XP Factor: %d
CENSUSPLUS_SCAN_PROGRESS        = 'Scan Progress: %d queries in the queue - %s';
CENSUSPLUS_SCAN_PROGRESS_0      = 'No Scan In Progress';
CENSUSPLUS_AUTOCLOSEWHO         = 'Automatically Close Who';
CENSUSPLUS_UNGUILDED            = '(Unguilded)';
CENSUSPLUS_TAKE                 = 'Take';
CENSUSPLUS_GETGUILD             = 'Click Realm for Guild data';
CENSUSPLUS_TOPGUILD             = 'Top Guilds By XP';
CENSUSPLUS_RACE                 = 'Races';
CENSUSPLUS_CLASS                = 'Classes';
CENSUSPLUS_LEVEL                = 'Levels';
CENSUSPLUS_MAXXED               = 'MAXXED!';
CENSUSPLUS_GUILDREALM           = "Guild's Realm";
CENSUSPLUS_LASTSEEN             = 'Last Seen';

CENSUSPLUS_DRUID                = 'Druid';
CENSUSPLUS_HUNTER               = 'Hunter';
CENSUSPLUS_MAGE                 = 'Mage';
CENSUSPLUS_PRIEST               = 'Priest';
CENSUSPLUS_ROGUE                = 'Rogue';
CENSUSPLUS_WARLOCK              = 'Warlock';
CENSUSPLUS_WARRIOR              = 'Warrior';
CENSUSPLUS_SHAMAN               = 'Shaman';
CENSUSPLUS_PALADIN              = 'Paladin';
CENSUSPLUS_DEATHKNIGHT          = 'Death Knight';
CENSUSPLUS_MONK                 = 'Monk';
CENSUSPLUS_DEMONHUNTER          = 'Demon Hunter';
CENSUSPLUS_EVOKER               = 'Evoker';

CENSUSPLUS_DWARF                = 'Dwarf';
CENSUSPLUS_GNOME                = 'Gnome';
CENSUSPLUS_HUMAN                = 'Human';
CENSUSPLUS_NIGHTELF             = 'Night Elf';
CENSUSPLUS_DRAENEI              = 'Draenei';
CENSUSPLUS_WORGEN               = 'Worgen';
CENSUSPLUS_APANDAREN            = 'Pandaren';
CENSUSPLUS_LIGHTFORGED          = 'Lightforged Draenei';
CENSUSPLUS_VOIDELF              = 'Void Elf';
CENSUSPLUS_DARKIRON             = 'Dark Iron Dwarf';
CENSUSPLUS_KULTIRAN             = 'Kul Tiran';
CENSUSPLUS_MECHAGNOME           = 'Mechagnome';

CENSUSPLUS_ORC                  = 'Orc';
CENSUSPLUS_TAUREN               = 'Tauren';
CENSUSPLUS_TROLL                = 'Troll';
CENSUSPLUS_UNDEAD               = 'Undead';
CENSUSPLUS_BLOODELF             = 'Blood Elf';
CENSUSPLUS_GOBLIN               = 'Goblin';
CENSUSPLUS_HPANDAREN            = 'Pandaren';
CENSUSPLUS_HIGHMOUNTAIN         = 'Highmountain Tauren';
CENSUSPLUS_NIGHTBORNE           = 'Nightborne';
CENSUSPLUS_MAGHAR               = "Mag'har Orc";
CENSUSPLUS_ZANDALARI            = 'Zandalari Troll';
CENSUSPLUS_VULPERA              = 'Vulpera';

CENSUSPLUS_DRACTHYR             = 'Dracthyr'
CENSUSPLUS_EARTHEN              = 'Earthen'

-- Blizzard provided translations THESE MUST BE AFTER THE ENGLISH DEFINITIONS
--.. right or wrong it must match what Blizzard provides
--frFR
if (GetLocale() == 'frFR') then
    --    CENSUSPLUS_DRUID            = "Druide";
    CENSUSPlusFemale['Druidesse'] = 'Druide';
    --    CENSUSPLUS_HUNTER           = "Chasseur";
    CENSUSPlusFemale['Chasseresse'] = 'Chasseur';
    --    CENSUSPLUS_MAGE             = "Mage";
    --    CENSUSPLUS_PRIEST           = "Prêtre";
    CENSUSPlusFemale['Prêtresse'] = 'Prêtre';
    --    CENSUSPLUS_ROGUE            = "Voleur";
    CENSUSPlusFemale['Voleuse'] = 'Voleur';
    --    CENSUSPLUS_WARLOCK          = "Démoniste";
    --    CENSUSPLUS_WARRIOR          = "Guerrier";
    CENSUSPlusFemale['Guerrière'] = 'Guerrier';
    --    CENSUSPLUS_SHAMAN           = "Chaman";
    CENSUSPlusFemale['Chamane'] = 'Chaman';
    --    CENSUSPLUS_PALADIN          = "Paladin";
    CENSUSPLUS_DEATHKNIGHT = 'Chevalier de la mort';
    --  CENSUSPLUS_MONK             = "Moine";
    CENSUSPlusFemale['Moniale'] = 'Moine';
    --	CENSUSPLUS_DEMONHUNTER		= "Chasseur de démons";
    CENSUSPlusFemale['Chasseuse de démons'] = 'Chasseur de démons';

    --   CENSUSPLUS_DWARF            = "Nain";
    CENSUSPlusFemale['Naine'] = 'Nain';
    --    CENSUSPLUS_GNOME            = "Gnome";
    --   CENSUSPLUS_HUMAN            = "Humain";
    CENSUSPlusFemale['Humaine'] = 'Humain';
    --    CENSUSPLUS_NIGHTELF         = "Elfe de la nuit";
    -- 	  CENSUSPLUS_DRAENEI          = "Draeneï";
    --		CENSUSPLUS_WORGEN			= "Worgen";
    --		CENSUSPLUS_APANDAREN        = "Pandaren";
    CENSUSPlusFemale['Pandarène'] = 'Pandaren';
    --		CENSUSPLUS_LIGHTFORGED = "Draeneï sancteforge"
    -- CENSUSPLUS_DARKIRON			= "Nain sombrefer";
    CENSUSPlusFemale['Naine sombrefer'] = 'Nain sombrefer';
    --CENSUSPLUS_KULTIRAN			= "Kultirassien"
    CENSUSPlusFemale['Kultirassienne'] = 'Kultirassien';
    --CENSUSPLUS_MECHAGNOME = "Mécagnome";
    --   CENSUSPLUS_ORC              = "Orc";
    CENSUSPlusFemale['Orque'] = 'Orc';
    --    CENSUSPLUS_TAUREN           = "Tauren";
    CENSUSPlusFemale['Taurène'] = 'Tauren';
    --   CENSUSPLUS_TROLL            = "Troll";
    CENSUSPlusFemale['Trollesse'] = 'Troll';
    --   CENSUSPLUS_UNDEAD           = "Mort-vivant";
    CENSUSPlusFemale['Morte-vivante'] = 'Mort-vivant';
    --	  CENSUSPLUS_BLOODELF         = "Elfe de sang";
    --    CENSUSPLUS_GOBLIN           = "Gobelin";
    CENSUSPlusFemale['Gobeline'] = 'Gobelin';
    --		CENSUSPLUS_HPANDAREN        = "Pandaren";
    CENSUSPlusFemale['Pandarène'] = 'Pandaren';
    --	CENSUSPLUS_HIGHMOUNTAIN = "Tauren de Haut-Roc"
    CENSUSPlusFemale['Taurène de Haut-Roc'] = 'Tauren de Haut-Roc';
    --		CENSUSPLUS_NIGHTBORNE = "Sacrenuit";
    --		CENSUSPLUS_VOIDELF = "Elfe du Vide";
    -- CENSUSPLUS_MAGHAR		= "Orc mag’har";
    CENSUSPlusFemale['Orque mag’har'] = 'Orc mag’har';
    -- CENSUSPLUS_VULPERA = "Vulpérin";
end
--
--deDE
--
if (GetLocale() == 'deDE') then
    --	CENSUSPLUS_DRUID            = "Druide";
    CENSUSPlusFemale['Druidin']                   = 'Druide';
    --	CENSUSPLUS_HUNTER           = "Jäger";
    CENSUSPlusFemale['Jägerin']                   = 'Jäger';
    --	CENSUSPLUS_MAGE             = "Magier";
    CENSUSPlusFemale['Magierin']                  = 'Magier';
    --	CENSUSPLUS_PRIEST           = "Priester";
    CENSUSPlusFemale['Priesterin']                = 'Priester';
    --	CENSUSPLUS_ROGUE            = "Schurke";
    CENSUSPlusFemale['Schurkin']                  = 'Schurke';
    --	CENSUSPLUS_WARLOCK          = "Hexenmeister";
    CENSUSPlusFemale['Hexenmeisterin']            = 'Hexenmeister';
    --	CENSUSPLUS_WARRIOR          = "Krieger";
    CENSUSPlusFemale['Kriegerin']                 = 'Krieger';
    --	CENSUSPLUS_SHAMAN           = "Schamane";
    CENSUSPlusFemale['Schamanin']                 = 'Schamane';
    --	CENSUSPLUS_PALADIN          = "Paladin";
    CENSUSPLUS_DEATHKNIGHT                        = 'Todesritter';
    --  CENSUSPLUS_MONK             = "Mönch";
    --	CENSUSPLUS_DEMONHUNTER		= "Dämonenjäger";
    CENSUSPlusFemale['Dämonenjägerin']            = 'Dämonenjäger';

    --	CENSUSPLUS_DWARF            = "Zwerg";
    CENSUSPlusFemale['Zwergin']                   = 'Zwerg';
    --	CENSUSPLUS_GNOME            = "Gnom";
    --	CENSUSPLUS_HUMAN            = "Mensch";
    --	CENSUSPLUS_NIGHTELF         = "Nachtelf";
    CENSUSPlusFemale['Nachtelfe']                 = 'Nachtelf';
    --	CENSUSPLUS_DRAENEI          = "Draenei";
    --  CENSUSPLUS_APANDAREN        = "Pandaren";
    -- CENSUSPLUS_NIGHTBORNE = "Nachtgeborener"
    CENSUSPlusFemale['Nachtgeborene']             = 'Nachtgeborener';
    -- CENSUSPLUS_DARKIRON			= "Dunkeleisenzwerg";
    CENSUSPlusFemale['Dunkeleisenzwergin']        = 'Dunkeleisenzwerg';

    -- CENSUSPLUS_LIGHTFORGED = "Lichtgeschmiedeter Draenei"
    CENSUSPlusFemale['Lichtgeschmiedete Draenei'] = 'Lichtgeschmiedeter Draenei';
    -- CENSUSPLUS_VOIDELF = "Leerenelf"
    CENSUSPlusFemale['Leerenelfe']                = 'Leerenelf';
    -- CENSUSPLUS_KULTIRAN			= "Kul Tiraner"
    CENSUSPlusFemale['Kul Tiranerin']             = 'Kul Tiraner';
    -- CENSUSPLUS_MECHAGNOME = "Mechagnom";
    --	CENSUSPLUS_ORC              = "Orc";
    --	CENSUSPLUS_TAUREN           = "Tauren";
    --	CENSUSPLUS_TROLL            = "Troll";
    --	CENSUSPLUS_UNDEAD           = "Untoter";
    CENSUSPlusFemale['Untote']                    = 'Untoter';
    --	CENSUSPLUS_BLOODELF         = "Blutelf";
    CENSUSPlusFemale['Blutelfe']                  = 'Blutelf';
    --  CENSUSPLUS_GOBLIN			= "Goblin";
    -- CENSUSPLUS_HPANDAREN        = "Pandaren"; 	
    --CENSUSPLUS_HIGHMOUNTAIN = "Hochbergtauren"
    -- CENSUSPLUS_MAGHAR		= "Mag'har";
    --    CENSUSPlusFemale["Mag'har"] = "Mag'har";
end
--
--ptBR
--
if (GetLocale() == 'ptBR') then
    --CENSUSPLUS_DRUID = "Druida";
    CENSUSPlusFemale['Druidesa'] = 'Druida'
    --CENSUSPLUS_HUNTER = "Caçador";
    CENSUSPlusFemale['Caçadora'] = 'Caçador';
    --CENSUSPLUS_MAGE = "Mago";
    CENSUSPlusFemale['Maga'] = 'Mago'
    --CENSUSPLUS_PRIEST = "Sacerdote";
    CENSUSPlusFemale['Sacerdotisa'] = 'Sacerdote'
    --CENSUSPLUS_ROGUE = "Ladino";
    CENSUSPlusFemale['Ladina'] = 'Ladino'
    --CENSUSPLUS_WARLOCK = "Bruxo";
    CENSUSPlusFemale['Bruxa'] = 'Bruxo'
    --CENSUSPLUS_WARRIOR = "Guerreiro";
    CENSUSPlusFemale['Guerreira'] = 'Guerreiro';
    --CENSUSPLUS_SHAMAN = "Xamã";
    --CENSUSPLUS_PALADIN = "Paladino";
    CENSUSPlusFemale['Paladina'] = 'Paladino'
    --CENSUSPLUS_DEATHKNIGHT = "Cavaleiro da Morte";
    CENSUSPlusFemale['Cavaleira da Morte'] = 'Cavaleiro da Morte'
    --CENSUSPLUS_MONK   = "Monge";
    CENSUSPlusFemale['Monja'] = 'Monge';
    --	CENSUSPLUS_DEMONHUNTER		= "Caçador de Demônios";
    CENSUSPlusFemale['Caçadora de Demônios'] = 'Caçador de Demônios';


    --CENSUSPLUS_DWARF = "Anão";
    CENSUSPlusFemale['Anã'] = 'Anão';
    --CENSUSPLUS_GNOME = "Gnomo";
    CENSUSPlusFemale['Gnomida'] = 'Gnomo';
    --CENSUSPLUS_HUMAN = "Humano";
    CENSUSPlusFemale['Humana'] = 'Humano';
    --CENSUSPLUS_NIGHTELF = "Elfo Noturno";
    CENSUSPlusFemale['Elfa Noturna'] = 'Elfo Noturno';
    -- CENSUSPLUS_DRAENEI = "Draenei";
    CENSUSPlusFemale['Draenaia'] = 'Draenei';
    --CENSUSPLUS_WORGEN			= "Worgen/Worgenin";
    CENSUSPlusFemale['Worgenin'] = 'Worgen'
    -- CENSUSPLUS_APANDAREN        = "Pandaren";
    CENSUSPlusFemale['Pandarena'] = 'Pandaren';
    --CENSUSPLUS_LIGHTFORGED = "Draenei Forjado a Luz"
    CENSUSPlusFemale['Draenaia Forjada a Luz'] = 'Draenei Forjado a Luz';
    --CENSUSPLUS_VOIDELF = "Elfo Caótico"
    CENSUSPlusFemale['Elfa Caótica'] = 'Elfo Caótico';
    --CENSUSPLUS_KULTIRAN			= "Kultireno";
    CENSUSPlusFemale['Kultirena'] = 'Kultireno';
    --CENSUSPLUS_MECHAGNOME = "Gnomecânico";
    -- CENSUSPLUS_ORC = "Orc";
    CENSUSPlusFemale['Orquisa'] = 'Orc';
    -- CENSUSPLUS_TROLL = "Troll";
    CENSUSPlusFemale['Trolesa'] = 'Troll';
    -- CENSUSPLUS_TAUREN = "Tauren";
    CENSUSPlusFemale['Taurena'] = 'Tauren';
    --CENSUSPLUS_UNDEAD = "Morto-vivo";
    CENSUSPlusFemale['Morta-viva'] = 'Morto-vivo';
    --CENSUSPLUS_BLOODELF = "Elfo Sangrento";
    CENSUSPlusFemale['Elfa Sangrenta'] = 'Elfo Sangrento';
    -- CENSUSPLUS_GOBLIN   = "Goblin";
    CENSUSPlusFemale['Goblina'] = 'Goblin';
    -- CENSUSPLUS_HPANDAREN        = "Pandaren";
    CENSUSPlusFemale['Pandarena'] = 'Pandaren';
    -- CENSUSPLUS_NIGHTBORNE = "Filho da Noite"
    CENSUSPlusFemale['Filha da Noite'] = 'Filho da Noite';
    -- CENSUSPLUS_HIGHMOUNTAIN = "Tauren Altamontês"
    CENSUSPlusFemale['Taurena Altamontesa'] = 'Tauren Altamontês';
    -- CENSUSPLUS_DARKIRON			= "Anão Ferro Negro";
    CENSUSPlusFemale['Anã Ferro Negro'] = 'Anão Ferro Negro';
    -- CENSUSPLUS_MAGHAR		= "Orc Mag'har";
    --    CENSUSPlusFemale["Orc Mag'har"] = "Orc Mag'har";
end

--
--itIT
--
if (GetLocale() == 'itIT') then
    CENSUSPLUS_DRUID                          = 'Druido';
    CENSUSPlusFemale['Druida']                = 'Druido';
    CENSUSPLUS_HUNTER                         = 'Cacciatore';
    CENSUSPlusFemale['Cacciatrice']           = 'Cacciatore';
    CENSUSPLUS_MAGE                           = 'Mago';
    CENSUSPlusFemale['Maga']                  = 'Mago';
    CENSUSPLUS_PRIEST                         = 'Sacerdote';
    CENSUSPlusFemale['Sacerdotessa']          = 'Sacerdote';
    CENSUSPLUS_ROGUE                          = 'Ladro';
    CENSUSPlusFemale['Ladra']                 = 'Ladro';
    CENSUSPLUS_WARLOCK                        = 'Stregone';
    CENSUSPlusFemale['Strega']                = 'Stregone';
    CENSUSPLUS_WARRIOR                        = 'Guerriero';
    CENSUSPlusFemale['Guerriera']             = 'Guerriero';
    CENSUSPLUS_SHAMAN                         = 'Sciamano';
    CENSUSPlusFemale['Sciamana']              = 'Sciamano';
    CENSUSPLUS_PALADIN                        = 'Paladino';
    CENSUSPlusFemale['Paladina']              = 'Paladino';
    CENSUSPLUS_DEATHKNIGHT                    = 'Cavaliere della Morte';
    CENSUSPLUS_MONK                           = 'Monaco';
    CENSUSPlusFemale['Monaca']                = 'Monaco';
    CENSUSPLUS_DEMONHUNTER                    = 'Cacciatore di Demoni';
    CENSUSPlusFemale['Cacciatrice di Demoni'] = 'Cacciatore di Demoni';

    CENSUSPLUS_DWARF                          = 'Nano';
    CENSUSPlusFemale['Nana']                  = 'Nano';
    CENSUSPLUS_GNOME                          = 'Gnomo';
    CENSUSPlusFemale['Gnoma']                 = 'Gnomo';
    CENSUSPLUS_HUMAN                          = 'Umano';
    CENSUSPlusFemale['Umana']                 = 'Umano';
    CENSUSPLUS_NIGHTELF                       = 'Elfo della Notte';
    CENSUSPlusFemale['Elfa della Notte']      = 'Elfo della Notte';
    CENSUSPLUS_WORGEN                         = 'Worgen';
    CENSUSPLUS_APANDAREN                      = 'Pandaren';
    CENSUSPLUS_LIGHTFORGED                    = 'Draenei Forgialuce';
    CENSUSPLUS_VOIDELF                        = 'Elfo del Vuoto';
    CENSUSPlusFemale['Elfa del Vuoto']        = 'Elfo del Vuoto';
    CENSUSPLUS_DARKIRON                       = 'Nano Ferroscuro';
    CENSUSPlusFemale['Nana Ferroscuro']       = 'Nano Ferroscuro';
    CENSUSPLUS_KULTIRAN                       = 'Kul Tirano';
    CENSUSPlusFemale['Kul Tirana']            = 'Kul Tirano';
    CENSUSPLUS_MECHAGNOME                     = 'Meccagnomo';
    CENSUSPlusFemale['Meccagnoma']            = 'Meccagnomo';

    CENSUSPLUS_ORC                            = 'Orco';
    CENSUSPlusFemale['Orchessa']              = 'Orco';
    CENSUSPLUS_TAUREN                         = 'Tauren';
    CENSUSPLUS_TROLL                          = 'Troll';
    CENSUSPLUS_UNDEAD                         = 'Non Morto';
    CENSUSPlusFemale['Non Morta']             = 'Non Morto';
    CENSUSPLUS_DRAENEI                        = 'Draenei';
    CENSUSPLUS_BLOODELF                       = 'Elfo del Sangue';
    CENSUSPlusFemale['Elfa del Sangue']       = 'Elfo del Sangue';
    CENSUSPLUS_GOBLIN                         = 'Goblin';
    CENSUSPLUS_HPANDAREN                      = 'Pandaren';
    CENSUSPLUS_HIGHMOUNTAIN                   = 'Tauren di Alto Monte';
    CENSUSPLUS_NIGHTBORNE                     = 'Nobile Oscuro';
    CENSUSPlusFemale['Nobile Oscura']         = 'Nobile Oscuro';
    CENSUSPLUS_ZANDALARI                      = 'Troll Zandalari';
    CENSUSPLUS_MAGHAR                         = "Orco Mag'har";
    CENSUSPlusFemale["Orchessa Mag'har"]      = "Orco Mag'har";
end
--
--esES
--
if (GetLocale() == 'esES' or GetLocale() == 'esMX') then
    CENSUSPLUS_DRUID                         = 'Druida';
    CENSUSPLUS_HUNTER                        = 'Cazador';
    CENSUSPlusFemale['Cazadora']             = 'Cazador';
    CENSUSPLUS_MAGE                          = 'Mago';
    CENSUSPlusFemale['Maga']                 = 'Mago';
    CENSUSPLUS_PRIEST                        = 'Sacerdote';
    CENSUSPlusFemale['Sacerdotisa']          = 'Sacerdote';
    CENSUSPLUS_ROGUE                         = 'Pícaro';
    CENSUSPlusFemale['Pícara']               = 'Pícaro';
    CENSUSPLUS_WARLOCK                       = 'Brujo';
    CENSUSPlusFemale['Bruja']                = 'Brujo';
    CENSUSPLUS_WARRIOR                       = 'Guerrero';
    CENSUSPlusFemale['Guerrera']             = 'Guerrero';
    CENSUSPLUS_SHAMAN                        = 'Chamán';
    CENSUSPLUS_PALADIN                       = 'Paladín';
    CENSUSPLUS_DEATHKNIGHT                   = 'Caballero de la Muerte';
    CENSUSPLUS_MONK                          = 'Monje';
    CENSUSPLUS_DEMONHUNTER                   = 'Cazador de demonios';
    CENSUSPlusFemale['Cazadora de demonios'] = 'Cazador de demonios';

    CENSUSPLUS_DWARF                         = 'Enano';
    CENSUSPlusFemale['Enana']                = 'Enano';
    CENSUSPLUS_GNOME                         = 'Gnomo';
    CENSUSPlusFemale['Gnoma']                = 'Gnomo';
    CENSUSPLUS_HUMAN                         = 'Humano';
    CENSUSPlusFemale['Humana']               = 'Humano';
    CENSUSPLUS_NIGHTELF                      = 'Elfo de la noche';
    CENSUSPlusFemale['Elfa de la noche']     = 'Elfo de la noche';
    --   CENSUSPLUS_DRAENEI          = "Draenei";
    CENSUSPLUS_WORGEN                        = 'Huargen';
    --   CENSUSPLUS_APANDAREN        = "Pandaren";
    CENSUSPLUS_VOIDELF                       = 'Elfo del Vacío';
    CENSUSPlusFemale['Elfa del Vacío']       = 'Elfo del Vacío';
    CENSUSPLUS_DARKIRON                      = 'Enano Hierro Negro';
    CENSUSPlusFemale['Enana Hierro Negro']   = 'Enano Hierro Negro';
    CENSUSPLUS_MECHAGNOME                    = 'Mecagnomo';
    CENSUSPlusFemale['Mecagnoma']            = 'Mecagnomo';
    CENSUSPLUS_ORC                           = 'Orco';
    --   CENSUSPLUS_TAUREN           = "Tauren";
    CENSUSPLUS_TROLL                         = 'Trol';
    CENSUSPLUS_UNDEAD                        = 'No-muerto';
    CENSUSPlusFemale['No-muerta']            = 'No-muerto';
    CENSUSPLUS_BLOODELF                      = 'Elfo de sangre';
    CENSUSPlusFemale['Elfa de sangre']       = 'Elfo de sangre';
    --   CENSUSPLUS_GOBLIN              = "Goblin";
    --   CENSUSPLUS_HPANDAREN        = "Pandaren";
    CENSUSPLUS_DARKIRON                      = 'Enano Hierro Negro';
    CENSUSPlusFemale['Enana Hierro Negro']   = 'Enano Hierro Negro';
    CENSUSPLUS_MAGHAR                        = "Orco mag'har";
    CENSUSPlusFemale["Orco mag'har"]         = "Orco mag'har";
end
if (GetLocale() == 'esES') then
    CENSUSPLUS_LIGHTFORGED                         = 'Draenei forjado por la Luz';
    CENSUSPlusFemale['Draenei forjada por la Luz'] = 'Draenei forjado por la Luz';
    CENSUSPLUS_KULTIRAN                            = 'Ciudadano de Kul Tiras';
    CENSUSPlusFemale['Ciudadana de Kul Tiras']     = 'Ciudadano de Kul Tiras';
    CENSUSPLUS_HIGHMOUNTAIN                        = 'Tauren Monte Alto';
    CENSUSPLUS_NIGHTBORNE                          = 'Nocheterna';
    CENSUSPLUS_ZANDALARI                           = 'Trol Zandalari';
end

if (GetLocale() == 'esMX') then
    CENSUSPLUS_LIGHTFORGED           = 'Draenei templeluz';
    --   CENSUSPlusFemale["Draenei forjada por la Luz"] = "Draenei forjado por la Luz";
    CENSUSPLUS_KULTIRAN              = 'Kultirano';
    CENSUSPlusFemale['Kultirana']    = 'Kultirano';
    CENSUSPLUS_HIGHMOUNTAIN          = 'Tauren de Altamontaña';
    CENSUSPLUS_NIGHTBORNE            = 'Natonocturno';
    CENSUSPlusFemale['Natonocturna'] = 'Natonocturno';
    CENSUSPLUS_ZANDALARI             = 'Trol zandalari';
end

CENSUSPLUS_US_LOCALE                           = 'Select if you play on US Servers';
CENSUSPLUS_EU_LOCALE                           = 'Select if you play on EURO Servers';
CENSUSPLUS_LOCALE_SELECT                       = 'Select if you play on US or EURO servers';
CENSUSPLUS_OPTIONS_OVERRIDE                    = 'Override'
CENSUSPLUS_BUTTON_OPTIONS                      = 'Options';
CENSUSPLUS_OPTIONS_HEADER                      = 'Census+ Options';
CENSUSPLUS_ACCOUNT_WIDE                        = 'Account wide'
CENSUSPLUS_ACCOUNT_WIDE_ONLY_OPTIONS           = 'Account Wide Only options'
CENSUSPLUS_CCO_OPTIONOVERRIDES                 = 'Option overrides for this character only'
CENSUSPLUS_ISINBG                              =
'You are currently in a Battleground so a Census cannot be taken';
CENSUS_OPTIONS_BUTSHOW                         = 'Show Census Button';
CENSUS_OPTIONS_AUTOCENSUS                      = 'Auto-Census';
CENSUS_OPTIONS_AUTOSTART                       = 'Auto-Start';
CENSUS_OPTIONS_VERBOSE                         = 'Verbose';
CENSUS_OPTIONS_VERBOSE_TOOLTIP                 =
'Enables verbose text in chat window, disables Stealth mode'
CENSUS_OPTIONS_STEALTH                         = 'Stealth'
CENSUS_OPTIONS_STEALTH_TOOLTIP                 =
'Stealth mode - no chat messages, disables Verbose'
CENSUS_OPTIONS_SOUND_ON_COMPLETE               = 'Play Sound When Done';
CENSUS_OPTIONS_SOUND_TOOLTIP                   = 'Enable Sound then select Sound File';
CENSUS_OPTIONS_SOUNDFILE                       = 'Select User provided SoundFile number ';
CENSUS_OPTIONS_SOUNDFILETEXT                   = 'Select desired .mp3 or .OGG sound file'
CENSUS_OPTIONS_TIMER_TOOLTIP                   =
'Sets delay in minutes from the last Census ending.'
CENSUS_OPTIONS_LOG_BARS                        = 'Logarithmic Level Bars';
CENSUS_OPTIONS_LOG_BARSTEXT                    = 'Enables Logarithmic scaling on display bars'
CENSUS_OPTIONS_BACKGROUND_TRANSPARENCY_TOOLTIP =
'Background transparency - ten steps'
CENSUSPLUS_VERBOSE_TOOLTIP                     = 'Deselect to stop the spam!';
CENSUSPlus_AUTOCENSUS_TOOLTIP                  =
'Enable Census+ to run automatically while playing';
CENSUSPLUS_OPTIONS_CHATTYCONFIRM               = 'Chatty Option confirmation - check to enable'
CENSUSPLUS_OPTIONS_CHATTY_TOOLTIP              =
'Enable chat to show current options settings - displays on interface options window opening and many CensusPlus option changes'

CENSUSPLUS_BUTTON_CHARACTERS                   = 'Show Chars';
CENSUSPLUS_CHARACTERS                          = 'Characters';

CENSUS_BUTTON_TOOLTIP                          = 'Open CensusPlus';
-- >6.1.2
-- CensusPlus_
CENSUSPLUS_PROBLEMNAME                         = 'This name is problematic => ';
CENSUSPLUS_PROBLEMNAME_ACTION                  =
', name skipped.  This message will only be shown once.';
CENSUSPLUS_BADLOCAL_1                          =
'You appear to have a US Census version, yet your localization is set to French or German or Italian.';
CENSUSPLUS_BADLOCAL_2                          =
'Please do not upload data to WarcraftRealms until this has been resolved.';
CENSUSPLUS_BADLOCAL_3                          =
'If this is incorrect, please let Bringoutyourdead know at www.WarcraftRealms.com about your situation so he can make corrections.';
CENSUSPLUS_WRONGLOCAL_PURGE                    =
'Locale differs from previous setting, purging database.';
CENSUSPLUS_WAS                                 = ' was ';
CENSUSPLUS_NOW                                 = ' now ';
CENSUSPLUS_USING_WHOLIB                        = 'Using WhoLib';
CENSUSPLUS_LASTSEEN_COLON                      = ' Last Seen: ';
CENSUSPLUS_FOUND_CAP                           = 'Found ';
CENSUSPLUS_PLAYERS                             = ' players.';
CENSUSPLUS_AND                                 = ' and ';
CENSUSPLUS_OR                                  = ' or ';
CENSUSPLUS_USAGE                               = 'Usage:';
CENSUSPLUS_STEALTHON                           = 'Stealth Mode : ON';
CENSUSPLUS_STEALTHOFF                          = 'Stealth Mode : OFF';
CENSUSPLUS_VERBOSEON                           = 'Verbose Mode : ON';
CENSUSPLUS_VERBOSEOFF                          = 'Verbose Mode : OFF';
CENSUSPLUS_CENSUSBUTTONSHOWNON                 = 'CensusButton Mode : ON';
CENSUSPLUS_CENSUSBUTTONSHOWNOFF                = 'CensusButton Mode : OFF';
CENSUSPLUS_CENSUSBUTTONANIMION                 = 'CensusButton Animation : ON';
CENSUSPLUS_CENSUSBUTTONANIMIOFF                = 'CensusButton Animation : OFF';
CENSUSPLUS_CENSUSBUTTONANIMITEXT               = 'Census button animation'
CENSUSPLUS_AUTOCENSUSON                        = 'AutoCensus Mode : ON';
CENSUSPLUS_AUTOCENSUSOFF                       = 'AutoCensus Mode : OFF';
CENSUSPLUS_AUTOCENSUSTEXT                      = 'Start Census after initial delay'
CENSUSPLUS_AUTOCENSUS_DELAYTIME                = 'Delay in minutes';
CENSUSPLUS_AUTOSTARTTEXT                       = 'Auto Start on login when timer less then '
CENSUSPLUS_PLAYFINISHSOUNDON                   = 'PlayFinishSound Mode : ON';
CENSUSPLUS_PLAYFINISHSOUNDOFF                  = 'PlayFinishSound Mode : OFF';
CENSUSPLUS_PLAYFINISHSOUNDNUM                  = 'FinishSound number '
CENSUS_OPTIONS_CCO_REMOVE_OVERRIDE             = 'Remove Override'
CENSUSPLUS_UNKNOWNRACE                         = 'Found an unknown race ( ';
CENSUSPLUS_UNKNOWNRACE_ACTION                  =
' ), please tell Bringoutyourdead at WarcraftRealms.com';
CENSUSPLUS_TOOSLOW                             = 'Update too slow! Computer overloaded?Connection problems?';
CENSUSPLUS_LANGUAGECHANGED                     = 'Client Language changed, Database purged.';
CENSUSPLUS_CONNECTEDREALMSFOUND                =
'CensusPlus found the following Connected Realms';
CENSUSPLUS_OBSOLETEDATAFORMATTEXT              = 'Old Database format found, Database purged.'
CENSUSPLUS_TRANSPARENCY                        = 'Census window transparency'
CENSUSPLUS_PURGEDALL                           = 'All Census Data Purged';
CENSUSPLUS_HELP_0                              = ' following command as shown below';
CENSUSPLUS_HELP_1                              = ' _ Toggle verbose mode off/on';
CENSUSPLUS_HELP_2                              = ' _ Brings up the Option window';
CENSUSPLUS_HELP_3                              = ' _ Start a Census snapshot';
CENSUSPLUS_HELP_4                              = ' _ Stop a Census snapshot';
CENSUSPLUS_HELP_5                              =
' X  _ Prune the database by removing characters not seen in X days - default X = 30';
CENSUSPLUS_HELP_6                              =
' X _ Prune the database by removing all characters not seen in X days from servers other than the one you are currently on. - default X = 0';
CENSUSPLUS_HELP_7                              = ' _  Will display info that matches names.';
CENSUSPLUS_HELP_8                              = ' _  Will list unguilded characters of that level.';
CENSUSPLUS_HELP_9                              = ' _  Will set the autocensus timer (to X minutes).';
CENSUSPLUS_HELP_10                             =
' _ Does Census update of player only.. this is done automatically when /CensusPlus take finishes.';
CENSUSPLUS_HELP_11                             =
' _ Toggles stealth mode off/on - disables Verbose and all CensusPlus chat messages.';
CENSUSPLUS_CMDERR_WHO2NUM                      = 'Who commands can be: who name  _ no numbers in name';
CENSUSPLUS_CMDERR_WHO2                         =
'Who commands should be:  who name level  _ no name found, level is optional';
-- CensusPlus_
--playerlist.lua


--[[
if ( GetLocale() == "itIT" ) then

CENSUSPLUS_TEXT      = "Census+";

CENSUSPLUS_MSG1             = " Loaded - - tipo /censusplus o /census+ o /census per aprire la finestra principale";
CENSUSPLUS_UPLOAD           = "Assicurarsi di caricare i dati CensusPlus a www.WarcraftRealms.com!";
CENSUSPLUS_PAUSE            = "Sospendi";
CENSUSPLUS_UNPAUSE          = "Riattiva";
CENSUSPLUS_STOP             = "Arresto";

CENSUSPLUS_PRUNE						= "Potare";
CENSUSPLUS_PRUNECENSUS		= "Prune the database by removing characters not seen in 30 days.";
CENSUSPLUS_PRUNEINFO		= "Pruned %d characters.";
CENSUSPLUS_PURGEDATABASE    = "Spurgare il database di tutti i dati";
CENSUSPLUS_PURGE            = "Purge";
CENSUSPLUS_PURGEMSG         = "Purged character database.";
CENSUSPLUS_PURGE_LOCAL_CONFIRM = "Are you sure you wish to PURGE your local database?";

CENSUSPLUS_TAKECENSUS       = "Prendete un censimento dei giocatori \nattualmente online su questo server \ne in questa fazione";
CENSUSPLUS_PAUSECENSUS      = "Sospendi il censimento in corso";
CENSUSPLUS_UNPAUSECENSUS    = "Riattiva il censimento in corso";
CENSUSPLUS_STOPCENSUS       = "Stop the currently active CensusPlus";
CENSUSPLUS_ISINPROGRESS     = "A CensusPlus is in progress, try again later";
CENSUSPLUS_TAKINGONLINE     = "Taking census of characters online...";
CENSUSPLUS_NOCENSUS         = "A Census is not currently in progress";
CENSUSPLUS_NOTINFACTION     = "Fazione neutrale - non consentito censimento";
CENSUSPLUS_FINISHED         = "Finished Taking data. Found %s new characters and saw %s. Took %s.";
CENSUSPLUS_TOOMANY          = "WARNING: Too many characters matching: %s";
CENSUSPLUS_WAITING          = "Waiting to send who request...";
CENSUSPLUS_SENDING          = "Sending /who %s";
CENSUSPLUS_WHOQUERY			= "Who query:"
CensusPlus_FOUND					= "found"
CENSUSPLUS_PROCESSING       = "Processing %s characters.";

CENSUSPLUS_REALMNAME        = "Realm: ";
CENSUSPLUS_REALMUNKNOWN     = "Realm: Unknown";
CENSUSPLUS_CONNECTED		= "I server collegati: ";
CENSUSPLUS_FACTION          = "Faction: %s";
CENSUSPLUS_FACTIONUNKNOWN   = "Faction: Unknown"; -- replace this text with notinfaction above?
CENSUSPLUS_LOCALE           = "Locale : %s";
CENSUSPLUS_LOCALEUNKNOWN    = "Locale : Unknown";
CENSUSPLUS_TOTALCHAR        = "Total Characters: %d";
CENSUSPLUS_TOTALCHAR_0      = "Total Characters: 0";
CENSUSPLUS_TOTALCHARXP      = "XP Factor: %d";
CENSUSPLUS_TOTALCHARXP_0    = "XP Factor: 0";
CENSUSPLUS_SCAN_PROGRESS    = "Scan Progress: %d queries in the queue - %s";
CENSUSPLUS_SCAN_PROGRESS_0  = "No Scan In Progress";
CENSUSPLUS_AUTOCLOSEWHO     = "Automatically Close Who";
CENSUSPLUS_UNGUILDED        = "(Unguilded)";
CENSUSPLUS_TAKE             = "Take";
CENSUSPLUS_TOPGUILD         = "Top Guilds By XP";
CENSUSPLUS_RACE             = "Races";
CENSUSPLUS_CLASS            = "Classes";
CENSUSPLUS_LEVEL            = "Levels";
CENSUSPLUS_MAXXED			= "MAXXED!";

CENSUSPLUS_DRUID            = "Druido";
CENSUSPlusFemale["Druida"] = "Druido";
CENSUSPLUS_HUNTER           = "Cacciatore";
CENSUSPlusFemale["Cacciatrice"] = "Cacciatore";
CENSUSPLUS_MAGE             = "Mago";
CENSUSPlusFemale["Maga"] = "Mago";
CENSUSPLUS_PRIEST           = "Sacerdote";
CENSUSPlusFemale["Sacerdotessa"] = "Sacerdote";
CENSUSPLUS_ROGUE            = "Ladro";
CENSUSPlusFemale["Ladra"] = "Ladro";
CENSUSPLUS_WARLOCK          = "Stregone";
CENSUSPlusFemale["Strega"] = "Stregone";
CENSUSPLUS_WARRIOR          = "Guerriero";
CENSUSPlusFemale["Guerriera"] = "Guerriero";
CENSUSPLUS_SHAMAN           = "Sciamano";
CENSUSPlusFemale["Sciamana"] = "Sciamano";
CENSUSPLUS_PALADIN          = "Paladino";
CENSUSPlusFemale["Paladina"] = "Paladino";
CENSUSPLUS_DEATHKNIGHT		= "Cavaliere della Morte";
CENSUSPLUS_MONK             = "Monaco";
CENSUSPlusFemale["Monaca"] = "Monaco";

CENSUSPLUS_DWARF            = "Nano";
CENSUSPlusFemale["Nana"] = "Nano";
CENSUSPLUS_GNOME            = "Gnomo";
CENSUSPlusFemale["Gnoma"] = "Gnomo";
CENSUSPLUS_HUMAN            = "Umano";
CENSUSPlusFemale["Umana"] = "Umano";
CENSUSPLUS_NIGHTELF         = "Elfo della Notte";
CENSUSPlusFemale["Elfa della Notte"] = "Elfo della Notte";
CENSUSPLUS_WORGEN			= "Worgen";
CENSUSPLUS_APANDAREN        = "Pandaren";

CENSUSPLUS_ORC              = "Orco";
CENSUSPlusFemale["Orchessa"] = "Orco";
CENSUSPLUS_TAUREN           = "Tauren";
CENSUSPLUS_TROLL            = "Troll";
CENSUSPLUS_UNDEAD           = "Non Morto";
CENSUSPlusFemale["Non Morta"] = "Non Morto";
CENSUSPLUS_DRAENEI          = "Draenei";
CENSUSPLUS_BLOODELF         = "Elfo del sangue";
CENSUSPlusFemale["Elfa del Sangue"] = "Elfo del sangue";
CENSUSPLUS_GOBLIN			= "Goblin";
CENSUSPLUS_HPANDAREN        = "Pandaren";

CENSUSPLUS_US_LOCALE		= "Select if you play on US Servers";
CENSUSPLUS_EU_LOCALE		= "Select if you play on EURO Servers";
CENSUSPLUS_LOCALE_SELECT	= "Select if you play on US or EURO servers";

CENSUSPLUS_BUTTON_OPTIONS	= "Options";
CENSUSPLUS_OPTIONS_HEADER	= "Census+ Options";
CENSUSPLUS_ISINBG			= "You are currently in a Battleground so a Census cannot be taken";
CENSUS_OPTIONS_BUTSHOW      = "Show Minimap Button";
CENSUS_OPTIONS_AUTOCENSUS   = "Auto-Census";
CENSUS_OPTIONS_AUTOSTART    = "Auto-Start";
CENSUS_OPTIONS_VERBOSE      = "Verbose";
CENSUS_OPTIONS_SOUND_ON_COMPLETE = "Play Sound When Done";
CENSUS_OPTIONS_LOG_BARS		= "Logarithmic Level Bars";

CENSUSPlus_AUTOSTART_TOOLTIP = "Enable Census+ to start automatically";
CENSUSPLUS_VERBOSE_TOOLTIP  = "Deselect to stop the spam!";
CENSUSPlus_AUTOCENSUS_TOOLTIP = "Enable Census+ to run automatically while playing";

CENSUSPLUS_BUTTON_CHARACTERS = "Show Chars";
CENSUSPLUS_CHARACTERS		= "Characters";

CENSUS_BUTTON_TOOLTIP		= "Open CensusPlus";



CENSUSPLUS_PURGE_LOCAL_CONFIRM = "Are you sure you wish to PURGE your local database?";
end
--]]
-- print("English localization loaded")
