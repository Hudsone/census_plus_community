---
--- check for an already loaded old WhoLib
---
if WhoLibByALeX or WhoLib then
  -- the WhoLib-1.0 (WhoLibByALeX) or WhoLib (by Malex) is loaded -> fail!
  error('an other WhoLib is already running - disable them first!\n')
  return
end -- if

---
--- check version
---

assert(LibStub, 'LibWho-2.0 requires LibStub')

local major_version = 'LibWho-2.0'
local minor_version = tonumber(('2.0.179'):match('%d+%.%d+%.(%d+)')) or 99999

local lib = LibStub:NewLibrary(major_version, minor_version)

if IntellisenseTrick_ExposeGlobal then LibWho = lib end

if not lib then
  return -- already loaded and no upgrade necessary
end

-- todo: localizations
lib.callbacks = lib.callbacks or LibStub('CallbackHandler-1.0'):New(lib)
local callbacks = lib.callbacks

local am = {}
local om = getmetatable(lib)
if om then for k, v in pairs(om) do am[k] = v end end
am.__tostring = function() return major_version end
setmetatable(lib, am)

local function dbgfunc(...) if lib.Debug then print(...) end end
local function NOP() return end
local dbg = NOP

-- Class Definitions ----------------------------------------------------------

---@class Task
---@field query string The query to send to the server.
---@field queue integer The queue to send the query to. Should only be WHOLIB_QUEUE_USER, WHOLIB_QUEUE_QUIET, or WHOLIB_QUEUE_SCANNING.
---@field callback function The callback to call when the query is done. If it is a string, it will be treated as a method of the `handler`.

-------------------------------------------------------------------------------

---Initializes the library.
---
---The reason why to create a function to do so is to make it easier to fold.
local function Initialize()
  ---
  --- initalize base
  ---

  if type(lib['hooked']) ~= 'table' then lib['hooked'] = {} end -- if

  if type(lib['hook']) ~= 'table' then lib['hook'] = {} end     -- if

  if type(lib['events']) ~= 'table' then lib['events'] = {} end -- if

  if type(lib['embeds']) ~= 'table' then lib['embeds'] = {} end -- if

  if type(lib['frame']) ~= 'table' then
    lib['frame'] = CreateFrame('Frame', major_version);
  end -- if
  lib['frame']:Hide()

  ---Used to handle ther WHO_LIST_UPDATE event.
  local function eventHandler(_, event, ...) lib[event](lib, ...) end
  lib.whoListUpdater = CreateFrame('Frame')
  lib.whoListUpdater:SetScript('OnEvent', eventHandler)
  lib.whoListUpdater:Hide()

  ---@type Task[][]
  lib.Queue = {[1] = {}, [2] = {}, [3] = {}}
  ---This flag is set to `true` only when `AskWhoNext()` is called. Reset to
  ---`false` while invoking `GetNextFromScheduler()` or when `ReturnWho()` is
  ---called.
  lib.WhoInProgress = false
  lib.Result = nil
  ---Only get set and reset in `AskWhoNext()`. Since it's not reset within
  ---`ReturnWho()`, it might just denote the last query, whether it's on
  ---process or not, and get reset only when no any available query is going to
  ---be processed.
  ---@type Task | nil
  lib.Args = nil
  lib.Total = nil
  lib.Quiet = nil
  lib.Debug = false
  lib.Cache = {}
  lib.CacheQueue = {}
  ---Reacts to SetWhoToUi() in the hooked API. This variable always represent
  ---the value set by the call of C_FriendList.SetWhoToUi().
  lib.SetWhoToUIState = false
  lib.friendsFrameEventRegistered, _ = FriendsFrame:IsEventRegistered(
    'WHO_LIST_UPDATE')

  lib.MinInterval = 2.5
  lib.MaxInterval = 10

  ---
  --- locale
  ---

  if (GetLocale() == 'ruRU') then
    lib.L = {
      ['console_queued'] = 'Добавлено в очередь "/who %s"',
      ['console_query'] = 'Результат "/who %s"',
      ['gui_wait'] = '- Пожалуйста подождите -'
    }
  else
    -- enUS is the default
    lib.L = {
      ['console_queued'] = 'Added "/who %s" to queue',
      ['console_query'] = 'Result of "/who %s"',
      ['gui_wait'] = '- Please Wait -'
    }
  end -- if

  ---
  --- external functions/constants
  ---

  lib['external'] = {
    'WHOLIB_QUEUE_USER',
    'WHOLIB_QUEUE_QUIET',
    'WHOLIB_QUEUE_SCANNING',
    'WHOLIB_FLAG_ALWAYS_CALLBACK',
    'Who',
    'UserInfo',
    'CachedUserInfo',
    'GetWhoLibDebug',
    'SetWhoLibDebug'
    --	'RegisterWhoLibEvent',
  }

  -- queues
  lib['WHOLIB_QUEUE_USER'] = 1
  lib['WHOLIB_QUEUE_QUIET'] = 2
  lib['WHOLIB_QUEUE_SCANNING'] = 3

  -- bit masks!
  lib['WHOLIB_FLAG_ALWAYS_CALLBACK'] = 1
end

Initialize()

---@enum SYSTEM_STATE
local SYSTEM_STATE = {READY = 0, COOLING_DOWN = 1, WAITING_FOR_RESPONSE = 2}

local queue_all = {
  [1] = 'WHOLIB_QUEUE_USER',
  [2] = 'WHOLIB_QUEUE_QUIET',
  [3] = 'WHOLIB_QUEUE_SCANNING'
}

local queue_quiet = {[2] = 'WHOLIB_QUEUE_QUIET', [3] = 'WHOLIB_QUEUE_SCANNING'}

function lib:Reset()
  self.Queue = {[1] = {}, [2] = {}, [3] = {}}
  self.Cache = {}
  self.CacheQueue = {}
end

---Makes a who request.
---
---The function is the main entry point for the library.
---@async
---@param query string The query to send to the server.
---@param callback function The callback that receives `(query string, results WhoInfo[])`.
function lib:Who(query, callback)
  local usage = 'Who(query, callback)'
  ---@type Task
  local args = {}
  args.query = self:CheckArgument(usage, 'query', 'string', query)
  args.callback = self:CheckArgument(usage, 'callback', 'function', callback)
  args.queue = self.WHOLIB_QUEUE_QUIET
  -- now args - copied and verified from opts

  self:AskWho(args)
end

local function ignoreRealm(name)
  local _, realm = string.split('-', name)
  local connectedServers = GetAutoCompleteRealms()
  if connectedServers then
    for i = 1, #connectedServers do
      if realm == connectedServers[i] then return false end
    end
  end
  return SelectedRealmName() ~= realm
end

function lib.UserInfo(defhandler, name, opts)
  local self, args, usage = lib, {}, 'UserInfo(name, [opts])'
  local now = time()

  name = self:CheckArgument(usage, 'name', 'string', name)
  --    name = Ambiguate(name, "None")
  if name:len() == 0 then return end

  -- There is no api to tell connected realms from cross realm by name. As such, we check known connections table before excluding who inquiry
  -- UnitRealmRelationship and UnitIsSameServer don't work with "name". They require unitID so they are useless here
  if name:find('%-') and ignoreRealm(name) then return end

  args.name = self:CapitalizeInitial(name)
  opts = self:CheckArgument(usage, 'opts', 'table', opts, {})
  args.queue = self:CheckPreset(usage, 'opts.queue', queue_quiet, opts.queue,
                                self.WHOLIB_QUEUE_SCANNING)
  args.flags = self:CheckArgument(usage, 'opts.flags', 'number', opts.flags, 0)
  args.timeout = self:CheckArgument(usage, 'opts.timeout', 'number',
                                    opts.timeout, 5)
  args.callback, args.handler = self:CheckCallback(usage, 'opts.',
                                                   opts.callback, opts.handler,
                                                   defhandler)

  -- now args - copied and verified from opts
  local cachedName = self.Cache[args.name]

  if (cachedName ~= nil) then
    -- user is in cache
    if (cachedName.valid == true and
          (args.timeout < 0 or cachedName.last + args.timeout * 60 > now)) then
      -- cache is valid and timeout is in range
      -- dbg('Info(' .. args.name ..') returned immedeatly')
      if (bit.band(args.flags, self.WHOLIB_FLAG_ALWAYS_CALLBACK) ~= 0) then
        self:RaiseCallback(args, cachedName.data)
        return false
      else
        return self:DupAll(self:ReturnUserInfo(args.name))
      end
    elseif (cachedName.valid == false) then
      -- query is already running (first try)
      if (args.callback ~= nil) then tinsert(cachedName.callback, args) end
      -- dbg('Info(' .. args.name ..') returned cause it\'s already searching')
      return nil
    end
  else
    self.Cache[args.name] = {
      valid = false,
      inqueue = false,
      callback = {},
      data = {
        Name = args.name
      },
      last = now
    }
  end

  local cachedName = self.Cache[args.name]

  if (cachedName.inqueue) then
    -- query is running!
    if (args.callback ~= nil) then tinsert(cachedName.callback, args) end
    dbg('Info(' .. args.name .. ') returned cause it\'s already searching')
    return nil
  end
  if (GetLocale() == 'ruRU') then -- in ruRU with n- not show information about player in WIM addon
    if args.name and args.name:len() > 0 then
      local query = 'и-"' .. args.name .. '"'
      cachedName.inqueue = true
      if (args.callback ~= nil) then tinsert(cachedName.callback, args) end
      self.CacheQueue[query] = args.name
      dbg('Info(' .. args.name .. ') added to queue')
      self:AskWho({query = query, queue = args.queue, flags = 0, info = args.name})
    end
  else
    if args.name and args.name:len() > 0 then
      local query = 'n-"' .. args.name .. '"'
      cachedName.inqueue = true
      if (args.callback ~= nil) then tinsert(cachedName.callback, args) end
      self.CacheQueue[query] = args.name
      dbg('Info(' .. args.name .. ') added to queue')
      self:AskWho({query = query, queue = args.queue, flags = 0, info = args.name})
    end
  end
  return nil
end

function lib.CachedUserInfo(_, name)
  local self, usage = lib, 'CachedUserInfo(name)'

  name = self:CapitalizeInitial(
    self:CheckArgument(usage, 'name', 'string', name))

  if self.Cache[name] == nil then
    return nil
  else
    return self:DupAll(self:ReturnUserInfo(name))
  end
end

function lib.GetWhoLibDebug(_, mode) return lib.Debug end

function lib.SetWhoLibDebug(_, mode)
  lib.Debug = mode
  dbg = mode and dbgfunc or NOP
end

-- function lib.RegisterWhoLibEvent(defhandler, event, callback, handler)
--	local self, usage = lib, 'RegisterWhoLibEvent(event, callback, [handler])'
--	
--	self:CheckPreset(usage, 'event', self.events, event)
--	local callback, handler = self:CheckCallback(usage, '', callback, handler, defhandler, true)
--	table.insert(self.events[event], {callback=callback, handler=handler})
-- end

-- non-embedded externals

function lib.Embed(_, handler)
  local self, usage = lib, 'Embed(handler)'

  self:CheckArgument(usage, 'handler', 'table', handler)

  for _, name in pairs(self.external) do handler[name] = self[name] end -- do
  self['embeds'][handler] = true

  return handler
end

function lib.Library(_)
  local self = lib

  return self:Embed({})
end

---
--- internal functions
---

function lib:AllQueuesEmpty()
  local queueCount = #self.Queue[1] + #self.Queue[2] + #self.Queue[3] +
      #self.CacheQueue

  -- Be sure that we have cleared the in-progress status
  if self.WhoInProgress then queueCount = queueCount + 1 end

  return queueCount == 0
end

local queryInterval = 5

function lib:GetQueryInterval() return queryInterval end

---Triggers a countdown process for 5 secs to turn on `lib.readyForNext`.
function lib:AskWhoNextIn5sec()
  if self.frame:IsShown() then return end

  dbg('Waiting to send next who')
  self.Timeout_time = queryInterval
  self['frame']:Show()
end

---Cancels the countdown process of `lib.readyForNext` (hides the frame).
function lib:CancelPendingWhoNext()
  lib['frame']:Hide()
  ---If this bit is set to `true`, it means the server timeout should be passed
  ---and the next query can be proceeded.
  lib.readyForNext = false
end

-- This looks like attampting to control the bit of lib.readyForNext.
-- The logic is as the following:
-- 1. When the frame is shown, the timeout is decreased by the elapsed time.
-- 2. If the timeout is less than or equal to 0, the frame is hidden and
--    lib.readyForNext is set to true.
-- 3. This means that we are ready for the next query.
lib['frame']:SetScript('OnUpdate', function(frame, elapsed)
  lib.Timeout_time = lib.Timeout_time - elapsed
  if lib.Timeout_time <= 0 then
    lib['frame']:Hide()
    lib.readyForNext = true
  end -- if
end);

---Gets the next query from the scheduler.
---
---Priority: WHOLIB_QUEUE_USER > WHOLIB_QUEUE_QUIET > WHOLIB_QUEUE_SCANNING
---@return integer queue_index, Task[] queue The queue to process.
function lib:GetNextFromScheduler()
  if #self.Queue[1] > 0 then return 1, self.Queue[1] end
  if #self.Queue[2] > 0 then return 2, self.Queue[2] end
  if #self.Queue[3] > 0 then return 3, self.Queue[3] end
  return 0, {}
end

lib.queue_bounds = queue_bounds

---Inserts a who request to the queue. `self.readyForNext` is set to true.
---@param args Task The task to insert.
function lib:AskWho(args)
  tinsert(self.Queue[args.queue], args)
  dbg('[' .. args.queue .. '] added "' .. args.query .. '", queues=' ..
    #self.Queue[1] .. '/' .. #self.Queue[2] .. '/' .. #self.Queue[3])
  self:TriggerEvent('WHOLIB_QUERY_ADDED')
end

function lib:ReturnUserInfo(name)
  if (name ~= nil and self ~= nil and self.Cache ~= nil and self.Cache[name] ~=
        nil) then
    return self.Cache[name].data, (time() - self.Cache[name].last) / 60
  end
end

function lib:RaiseCallback(args, ...)
  if type(args.callback) == 'function' then
    args.callback(self:DupAll(...))
  elseif args.callback then -- must be a string
    args.handler[args.callback](args.handler, self:DupAll(...))
  end                       -- if
end

---Validates the arguments by type.
---
---Performs a generic type checking for the arguments.
---
---Example usage: `self:CheckArgument('Who(query, options)', 'query', 'string', query, 'all')`
---@param func string The prototype of the function.
---@param name string The argument name in the prototype.
---@param argtype string The expected type of the argument.
---@param arg any The argument to check.
---@param defarg any The default value of the argument if it is nil. Note this will not be type checked.
---@return any `arg` if it is valid. `defarg` if `arg` is nil. Otherwise, it throws an error.
function lib:CheckArgument(func, name, argtype, arg, defarg)
  if arg == nil and defarg ~= nil then
    return defarg
  elseif type(arg) == argtype then
    return arg
  else
    error(string.format("%s: '%s' - %s%s expected got %s", func, name,
                        (defarg ~= nil) and 'nil or ' or '', argtype, type(arg)),
          3)
  end -- if
end

---Validates the arguments by value.
---
---Performs a generic value checking for the arguments.
---
---Example usage: `self:CheckPreset('Who(query, options)', 'options', {'OPT_1', 'OPT_2'}, options, 2)`
---@param func string The prototype of the function.
---@param name string The argument name in the prototype.
---@param preset table The valid values of the argument. `arg` will be checked as the `key` of this table.
---@param arg any The argument to check.
---@param defarg any The default value of the argument if it is nil. Not this will not be validated.
---@return any `arg` if it is valid. `defarg` if `arg` is nil. Otherwise, it throws an error.
function lib:CheckPreset(func, name, preset, arg, defarg)
  if arg == nil and defarg ~= nil then
    return defarg
  elseif arg ~= nil and preset[arg] ~= nil then
    return arg
  else
    local p = {}
    for k, v in pairs(preset) do
      if type(v) ~= 'string' then
        table.insert(p, k)
      else
        table.insert(p, v)
      end -- if
    end   -- for
    error(string.format("%s: '%s' - one of %s%s expected got %s", func, name,
                        (defarg ~= nil) and 'nil, ' or '',
                        table.concat(p, ', '), self:simple_dump(arg)), 3)
  end -- if
end

---Validates the callback.
---
---Performs a generic value checking for the callbacks.
---
---Example usage: `self:CheckPreset('Who(query, options)', 'options.', options.callback, options.handler, defhandler, true)`
---@param func string The prototype of the function.
---@param prefix string The prefix of the callback pair in the prototype.
---@param callback function | string | nil The callback to check. If it is a string, it will be treated as a method of the `handler`.
---@param handler table | nil The handler of the callback if `callback` is a string.
---@param defhandler table | nil The default handler of the callback if `handler` is nil.
---@param nonil boolean | nil If true, `callback` cannot be nil.
---@return function | string | nil callback, table | nil handler If they are valid. Otherwise, it throws an error.
function lib:CheckCallback(func, prefix, callback, handler, defhandler, nonil)
  if not nonil and callback == nil then
    -- no callback: ignore handler
    return nil, nil
  elseif type(callback) == 'function' then
    -- simple function
    if handler ~= nil then
      error(
        string.format("%s: '%shandler' - nil expected got %s", func, prefix,
                      type(arg)), 3)
    end -- if
  elseif type(callback) == 'string' then
    -- method
    if handler == nil then handler = defhandler end -- if
    if type(handler) ~= 'table' or type(handler[callback]) ~= 'function' or
        handler == self then
      error(string.format("%s: '%shandler' - nil or function expected got %s",
                          func, prefix, type(arg)), 3)
    end -- if
  else
    error(string.format(
            "%s: '%scallback' - %sfunction or string expected got %s", func,
            prefix, nonil and 'nil or ' or '', type(arg)), 3)
  end -- if

  return callback, handler
end

-- helpers

function lib:simple_dump(x)
  if type(x) == 'string' then
    return 'string \'' .. x .. '\''
  elseif type(x) == 'number' then
    return 'number ' .. x
  else
    return type(x)
  end
end

function lib:Dup(from)
  local to = {}

  for k, v in pairs(from) do
    if type(v) == 'table' then
      to[k] = self:Dup(v)
    else
      to[k] = v
    end -- if
  end   -- for

  return to
end

function lib:DupAll(x, ...)
  if type(x) == 'table' then
    return self:Dup(x), self:DupAll(...)
  elseif x ~= nil then
    return x, self:DupAll(...)
  else
    return nil
  end -- if
end

local MULTIBYTE_FIRST_CHAR = '^([\192-\255]?%a?[\128-\191]*)'

function lib:CapitalizeInitial(name)
  return name:gsub(MULTIBYTE_FIRST_CHAR, string.upper, 1)
end

---
--- user events (Using CallbackHandler)
---

lib.PossibleEvents = {'WHOLIB_QUERY_RESULT', 'WHOLIB_QUERY_ADDED'}

function lib:TriggerEvent(event, ...) callbacks:Fire(event, ...) end

---
--- slash commands
---
-- TODO(GH-6): We will go back to enable these part once it's required.
--
-- SlashCmdList['WHO'] = function(msg)
--  dbg("console /who: " .. msg)
--  -- new /who function
--  -- local self = lib
--
--  if (msg == '') then
--    lib:GuiWho(WhoFrame_GetDefaultWhoCommand())
--  elseif (WhoFrame:IsVisible()) then
--    lib:GuiWho(msg)
--  else
--    lib:ConsoleWho(msg)
--  end
-- end
--
-- SlashCmdList['WHOLIB_DEBUG'] = function()
--  -- /wholibdebug: toggle debug on/off
--  local self = lib
--
--  self:SetWhoLibDebug(not self.Debug)
-- end

SLASH_WHOLIB_DEBUG1 = '/wholibdebug'

-- Why to make these hooks?
-- I would think that we want to replace the original functions. The intention
-- is to do additional things when any other addon calls these functions. I
-- would guess that we might want to avoid the original functions to be called,
-- which can interfere the temple of us to retrieve the who data.
-- What I'm think about is ... maybe we can skip this part?
-- The answer is 'yes', but I realized that there are `hook` and `hooked`, the
-- original version is saved properly, so I don't need to be worried about it.
---
--- hook activation
---

-- functions to hook
local hooks = {
  -- 'WhoFrameEditBox_OnEnterPressed'
  --	'FriendsFrame_OnEvent',
}

-- hook all functions (which are not yet hooked)
for _, name in pairs(hooks) do
  if not lib['hooked'][name] then
    lib['hooked'][name] = _G[name]
    _G[name] = function(...) lib.hook[name](lib, ...) end -- function
  end                                                     -- if
end                                                       -- for

-- C_FriendList functions to hook
local CFL_hooks = {'SendWho', 'SetWhoToUi'}

-- hook all C_FriendList functions (which are not yet hooked)
for _, name in pairs(CFL_hooks) do
  if not lib['hooked'][name] then
    lib['hooked'][name] = _G['C_FriendList'][name]
    _G['C_FriendList'][name] = function(...) lib.hook[name](lib, ...) end -- function
  end                                                                     -- if
end                                                                       -- for

-- fake 'WhoFrame:Hide' as hooked
table.insert(hooks, 'WhoFrame_Hide')

-- check for unused hooks -> remove function
for name, _ in pairs(lib['hook']) do
  if not hooks[name] then lib['hook'][name] = function() end end -- if
end                                                              -- for

-- secure hook 'WhoFrame:Hide'
-- if not lib['hooked']['WhoFrame_Hide'] then
--  lib['hooked']['WhoFrame_Hide'] = true
--  hooksecurefunc(WhoFrame, 'Hide',
--                 function(...) lib['hook']['WhoFrame_Hide'](lib, ...) end -- function
--  )
-- end -- if

---
--- hook replacements
---

function lib.hook.SendWho(self, msg, ...) self.hooked.SendWho(msg, ...) end

function lib.hook.WhoFrameEditBox_OnEnterPressed(self)
  -- lib:GuiWho(WhoFrameEditBox:GetText())
end

hooksecurefunc(FriendsFrame, 'RegisterEvent', function(_, event)
  lib:cancelRegisterWhoListUpdateOnQuietQuery(event)
end);

hooksecurefunc(FriendsFrame, 'UnregisterEvent',
               function(_, event) lib:unsetFriendsFrameEventBit(event) end);

hooksecurefunc(FriendsFrame, 'UnregisterAllEvents',
               function(_, event) lib:unsetFriendsFrameEventBit(event) end);

function lib.hook.SetWhoToUi(self, state)
  lib.SetWhoToUIState = state
  lib:updateSetWhoToUi()
end

-- function lib.hook.WhoFrame_Hide(self)
--  if (not lib.WhoInProgress) then lib:AskWhoNextIn5sec() end
-- end

---
--- WoW events
---

---Reacts to the `WHO_LIST_UPDATE` event.
---
---We need to do cleanups in reversed order from doQuietQuery and process the
---results when the `WHO_LIST_UPDATE` event.
function lib:WHO_LIST_UPDATE()
  --  if not lib.Quiet then
  --    WhoList_Update()
  --    FriendsFrame_Update()
  --  end

  lib:restoreFriendsFrameRegistery()
  lib.whoListUpdater:UnregisterEvent('WHO_LIST_UPDATE')
  lib:ProcessWhoResults(lib.Args)
  lib:updateSetWhoToUi()
  lib:endWhoInProgress()
  lib:startCoolDown()
end

---Marks the start of the Who request progress.
---@param args Task The task to query.
function lib:startWhoInProgress(args)
  lib.Args = args
  lib.WhoInProgress = true
end

---Ends the Who request progress.
function lib:endWhoInProgress()
  self.WhoInProgress = false
  tremove(lib.Queue[self.Args.queue], 1)
  self.Args = nil
end

---Processes the who results and invokes the callback.
---@param args Task The task queried.
function lib:ProcessWhoResults(args)
  local numWhos, totalNumWhos = C_FriendList.GetNumWhoResults()
  -- I actually don't know which one is the correct number of results.
  whoCount = math.max(numWhos, totalNumWhos)
  self.Result = {}
  for i = 1, whoCount do
    info = C_FriendList.GetWhoInfo(i)
    -- backwards compatibility START
    info.Name = info.fullName
    info.Guild = info.fullGuildName
    info.Level = info.level
    info.Race = info.raceStr
    info.Class = info.classStr
    info.Zone = info.area
    info.NoLocaleClass = info.filename
    info.Sex = info.gender
    -- backwards compatibility END
    self.Result[i] = info
  end
  args.callback(args.query, self.Result)
end

---Starts the cooldown process.
---
---Blizzard throttled the `SendWho` function to prevent the server from being
---overloaded. We try to create a timer to wait for the cooldown to be passed.
function lib:startCoolDown() lib:AskWhoNextIn5sec() end

---Updates the `SetWhoToUi` state.
---
---Invoke this function when updating the `SetWhoToUi` state is required.
function lib:updateSetWhoToUi()
  local state = self:state()
  -- If we are waiting for the response, it means we have committed a
  -- `SendWho`, and we should not change the state.
  if state ~= SYSTEM_STATE.WAITING_FOR_RESPONSE then
    self.hooked.SetWhoToUi(self.SetWhoToUIState)
  end
end

---Gets the current system state.
---@return SYSTEM_STATE state The current system state.
function lib:state()
  if self.WhoInProgress then return SYSTEM_STATE.WAITING_FOR_RESPONSE end
  if self.frame:IsShown() then return SYSTEM_STATE.COOLING_DOWN end
  return SYSTEM_STATE.READY
end

local function extendCooldown()
  queryInterval = queryInterval + 0.5
  queryInterval = math.min(queryInterval, lib.MaxInterval)
end

---Cancels the register attempts for the WHO_LIST_UPDATE event.
---
---When we're doing a quiet query, we want to avoid the FriendsFrame from
---updating the UI. Therefore, we need to cancel the register attempts for the
---WHO_LIST_UPDATE event.
---@param event string The event to cancel the register.
function lib:cancelRegisterWhoListUpdateOnQuietQuery(event)
  if event ~= 'WHO_LIST_UPDATE' then return end
  if self:state() == SYSTEM_STATE.WAITING_FOR_RESPONSE then
    FriendsFrame:UnregisterEvent(event)
    self.friendsFrameEventRegistered = true
  end
end

---Unsets the bit of registering the WHO_LIST_UPDATE event.
---
---The self.friendsFrameEventRegistered is tracking the registration status of
---the WHO_LIST_UPDATE event. This function is to unset the bit.
---@param event any
function lib:unsetFriendsFrameEventBit(event)
  if event ~= 'WHO_LIST_UPDATE' then return end
  self.friendsFrameEventRegistered = false
end

---Unregisters the WHO_LIST_UPDATE event.
---
---This function is called when we need to unregister from the `WHO_LIST_UPDATE`
---event in a quiet query because we want to remember the previous state.
function lib:unregisterFriendsFrameFromWhoListUpdateEvent()
  local previousState = self.friendsFrameEventRegistered
  FriendsFrame:UnregisterEvent('WHO_LIST_UPDATE')
  self.friendsFrameEventRegistered = previousState
end

---Restores the FriendsFrame registery for the WHO_LIST_UPDATE event.
function lib:restoreFriendsFrameRegistery()
  if self.friendsFrameEventRegistered then
    FriendsFrame:RegisterEvent('WHO_LIST_UPDATE')
  end
end

---Makes a quiet who query.
---
---A quiet who query is a query that is not shown in the UI. It tried the best
---to prevent the interference with the player's UI.
---
---When we performs a SendWho, it is almostly always a WHO_LIST_UPDATE query
---because the result usually exceeds 4. To be easier process, we always use
---SetWhoToUi(true) to make it consistant. Therefore, we need to set this bit on
---and restore it after the SendWho is done.
---@param args Task The task to query.
local function doQuietQuery(args)
  assert(lib:state() ~= SYSTEM_STATE.COOLING_DOWN)
  lib:startWhoInProgress(args)
  lib.hooked.SetWhoToUi(true)
  lib.hooked.SendWho(args.query)
  lib.whoListUpdater:RegisterEvent('WHO_LIST_UPDATE')
  lib:unregisterFriendsFrameFromWhoListUpdateEvent()
end

---Invoked when the hardware event is triggered.
---
---This function is the only available entry point that we can invoke a
---`SendWho` function (hardware event protected).
local function hardwareEventTriggered()
  local state = lib:state()
  dbg('Hardware event triggered, state=' .. state)
  if state == SYSTEM_STATE.COOLING_DOWN then return end
  -- If it's still waiting for the response after cooling down, it means the
  -- server is throttling us. We should extend the cooldown.
  if state == SYSTEM_STATE.WAITING_FOR_RESPONSE then extendCooldown() end
  local idx, queue = lib:GetNextFromScheduler()
  if idx == 0 then return end
  if idx == lib.WHOLIB_QUEUE_USER then
    -- To be designed.
  else
    doQuietQuery(queue[1])
  end
end

WorldFrame:HookScript('OnMouseDown', function(_, _) hardwareEventTriggered() end)

---
--- re-embed
---

for target, _ in pairs(lib['embeds']) do
  if type(target) == 'table' then lib:Embed(target) end -- if
end                                                     -- for

---
--- Tests
---

---@class Testcase
---@field name string The name of the test.
---@field func function The function to test.

---@class Tester
---@field tests Testcase[] The list of tests.
---@field results boolean[] The list of results of the tests.

---@type Tester
local tester = {tests = {}, results = {}}

function tester:PushTest(name, func)
  tinsert(self.tests, {name = name, func = func})
end

function tester:StartTest() for i, test in pairs(self.tests) do test.func(i) end end

function tester:ReportTestResult(idx, result)
  self.results[idx] = result
  if #self.results == #self.tests then self:FinalizeTest() end
end

function tester:FinalizeTest()
  local sPassed = '\124c0000FF00PASSED\124r'
  local sFailed = '\124c00FF0000FAILED\124r'
  print('Test results:')
  local passed = 0
  for i, result in pairs(self.results) do
    print(string.format('%s: %s', result and sPassed or sFailed,
                        self.tests[i].name))
    if result then passed = passed + 1 end
  end
  print(string.format('Total %d/%d tests passed.', passed, #self.tests))
end

local function unitTest_Tester_ShouldReportTestResults(idx)
  tester:ReportTestResult(idx, true)
end

local function functionalTest_Who_ShouldReturnResults(test_idx)
  print('Note: Please click to enable the hardware event.')
  lib:Who('0-500', function(query, result)
    assert(#result >= 1)
    assert(query == '0-500')
    tester:ReportTestResult(test_idx, true)
  end)
end

SLASH_WHOLIB_TEST1 = '/wholib-test'
SlashCmdList['WHOLIB_TEST'] = function(msg)
  tester:PushTest('unitTest_Tester_ShouldReportTestResults',
                  unitTest_Tester_ShouldReportTestResults)
  tester:PushTest('functionalTest_Who_ShouldReturnResults',
                  functionalTest_Who_ShouldReturnResults)
  tester:StartTest()
end

---
--- Debug Information
---

---Simple conversion of a table to a string.
---@param t table The table to convert.
---@param level? string Indentation string. Just leave it empty.
---@return string v The string representation of the table.
local function tableToString(t, level)
  if not level then level = '  ' end
  local output = ''
  for k, v in pairs(t) do
    local row
    if type(v) == 'table' then
      display_v = tableToString(v, level .. '  ')
      row = string.format('%s%s:\n%s\n', level, k, display_v)
    else
      row = string.format('%s%s: %s\n', level, k, tostring(v))
    end
    output = output .. row
  end
  return output
end

---Displays the library status.
---@param argument? string The filter string of Lua match pattern.
local function showLibStatus(argument)
  local filter =
      argument and function(x) return string.match(x, argument) end or
      function(_) return true end
  for k, v in pairs(lib) do
    if filter(k) then
      if type(v) == 'table' then
        print('\124c00FFFF00' .. k .. '\124r')
        print(tableToString(v))
      else
        print('\124c00FFFF00' .. k .. '\124r', v)
      end
    end
  end
end

-- /wholib-debug on
-- /wholib-debug off
-- /wholib-debug status [match_string]
--   e.g., /wholib-debug status Queue

SLASH_WHOLIB_DEBUG1 = '/wholib-debug'
SlashCmdList['WHOLIB_DEBUG'] = function(msg)
  command, argument = strsplit(' ', msg, 2)
  if command == 'on' then
    dbg = print
    print('Debug mode is on.')
  end
  if command == 'off' then
    dbg = NOP
    print('Debug mode is off.')
  end
  if command == 'status' then showLibStatus(argument) end
end
