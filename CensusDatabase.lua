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

local _, addon_tableID = ...
local CPp = addon_tableID
CPp.DatabaseOperation = {}
local lib = CPp.DatabaseOperation

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
