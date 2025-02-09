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

---@class SightingData
---@field name string The character name.
---@field realm string The realm.
---@field relationship integer? Maybe one of LE_REALM_RELATION_SAME, LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL.
---@field race RACE The race of the character.
---@field level integer The character level.
---@field class CLASS The class of the character.
---@field guild string The guild of the character.
---@field guildrealm string The Realm which the guild belongs.
---@field faction string "englishFaction" from the Blizzard API.

local _, addon_tableID = ...
local CPp = addon_tableID
CPp.DatabaseOperation = {}
local lib = CPp.DatabaseOperation

if IntellisenseTrick_ExposeGlobal then
  DatabaseOperation = lib
end

---Initializes the Census data.
function lib.Initialize()
  if (CensusPlus_Database['Servers'] == nil) then
    CensusPlus_Database['Servers'] = {};
  end

  if (CensusPlus_Database['TimesPlus'] == nil) then
    CensusPlus_Database['TimesPlus'] = {};
  end
end

---Purges the Census data.
function lib.Purge()
  if (CensusPlus_Database['Servers'] ~= nil) then
    CensusPlus_Database['Servers'] = nil;
  end
  CensusPlus_Database['Servers'] = {};

  if (CensusPlus_Database['Guilds'] ~= nil) then
    CensusPlus_Database['Guilds'] = nil;
  end
  CensusPlus_Database['Guilds'] = {};

  if (CensusPlus_Database['TimesPlus'] ~= nil) then
    CensusPlus_Database['TimesPlus'] = nil;
  end
  CensusPlus_Database['TimesPlus'] = {};
end

---Records a character to Census data.
---@param realm string The NORMALIZED realm name.
---@param faction string "englishFaction" from the Blizzard API.
---@param race RACE
---@param class CLASS
---@param name any
---@param level any
---@param guild any
---@param guildrealm any
function lib.Record(realm, faction, race, class, name, level, guild, guildrealm)
  local censusData = CensusPlus_Database['Servers']
  local realmDatabase = censusData[realm];
  if (realmDatabase == nil) then
    censusData[realm] = {};
    realmDatabase = censusData[realm];
  end
  local factionDatabase = realmDatabase[faction];
  if (factionDatabase == nil) then
    realmDatabase[faction] = {};
    factionDatabase = realmDatabase[faction];
  end
  local raceDatabase = factionDatabase[race];
  if (raceDatabase == nil) then
    factionDatabase[race] = {};
    raceDatabase = factionDatabase[race];
  end
  local classDatabase = raceDatabase[class];
  if (classDatabase == nil) then
    raceDatabase[class] = {};
    classDatabase = raceDatabase[class];
  end
  local entry = classDatabase[name];
  if (entry == nil) then
    classDatabase[name] = {};
    entry = classDatabase[name];
  end
  entry[1] = level;
  entry[2] = guild;
  entry[3] = guildrealm
  entry[4] = CensusPlus_DetermineServerDate();
end
