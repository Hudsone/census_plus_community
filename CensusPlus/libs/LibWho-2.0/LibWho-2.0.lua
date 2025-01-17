---
--- check for an already loaded old WhoLib
---
if WhoLibByALeX or WhoLib then
  -- the WhoLib-1.0 (WhoLibByALeX) or WhoLib (by Malex) is loaded -> fail!
  error("an other WhoLib is already running - disable them first!\n")
  return
end -- if

---
--- check version
---

assert(LibStub, "LibWho-2.0 requires LibStub")

local major_version = 'LibWho-2.0'
local minor_version = tonumber(("2.0.179"):match("%d+%.%d+%.(%d+)")) or 99999

local lib = LibStub:NewLibrary(major_version, minor_version)

if IntellisenseTrick_ExposeGlobal then LibWho = lib end

if not lib then
  return -- already loaded and no upgrade necessary
end

-- todo: localizations
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
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
---@field flags integer
---@field callback function | string | nil The callback to call when the query is done. If it is a string, it will be treated as a method of the `handler`.
---@field handler table | nil The handler of the callback if `callback` is a string.
---@field gui boolean | nil
---@field console_show boolean | nil It is only specified interanlly in `ConsoleWho()` and used to mark if this Task has been shown in a "queued" message.
---@field whotoui boolean | nil

-------------------------------------------------------------------------------

---Initializes the library.
---
---The reason why to create a function to do so is to make it easier to fold.
local function Initialize()

  ---
  --- initalize base
  ---

  if type(lib['hooked']) ~= 'table' then lib['hooked'] = {} end -- if

  if type(lib['hook']) ~= 'table' then lib['hook'] = {} end -- if

  if type(lib['events']) ~= 'table' then lib['events'] = {} end -- if

  if type(lib['embeds']) ~= 'table' then lib['embeds'] = {} end -- if

  if type(lib['frame']) ~= 'table' then
    lib['frame'] = CreateFrame('Frame', major_version);
  end -- if
  lib['frame']:Hide()

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
  lib.SetWhoToUIState = false

  lib.MinInterval = 2.5
  lib.MaxInterval = 10

  ---
  --- locale
  ---

  if (GetLocale() == "ruRU") then
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
    'WHOLIB_QUEUE_USER', 'WHOLIB_QUEUE_QUIET', 'WHOLIB_QUEUE_SCANNING',
    'WHOLIB_FLAG_ALWAYS_CALLBACK', 'Who', 'UserInfo', 'CachedUserInfo',
    'GetWhoLibDebug', 'SetWhoLibDebug'
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
---@param defhandler table Usually LibWho itself since it was called with the form `LibWho:Who(...)`.
---@param query string The query to send to the server.
---@param opts {queue: integer, flags: number, callback: function | string | nil, handler: table | nil} A table of options.
function lib.Who(defhandler, query, opts)
  local self, args, usage = lib, {}, 'Who(query, [opts])'

  args.query = self:CheckArgument(usage, 'query', 'string', query)
  opts = self:CheckArgument(usage, 'opts', 'table', opts, {})
  args.queue = self:CheckPreset(usage, 'opts.queue', queue_all, opts.queue,
                                self.WHOLIB_QUEUE_SCANNING)
  args.flags = self:CheckArgument(usage, 'opts.flags', 'number', opts.flags, 0)
  args.callback, args.handler = self:CheckCallback(usage, 'opts.',
                                                   opts.callback, opts.handler,
                                                   defhandler)
  -- now args - copied and verified from opts

  if args.queue == self.WHOLIB_QUEUE_USER then
    if WhoFrame:IsShown() then
      self:GuiWho(args.query)
    else
      self:ConsoleWho(args.query)
    end
  else
    self:AskWho(args)
  end
end

local function ignoreRealm(name)
  local _, realm = string.split("-", name)
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
  if name:find("%-") and ignoreRealm(name) then return end

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
      data = {Name = args.name},
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
  if (GetLocale() == "ruRU") then -- in ruRU with n- not show information about player in WIM addon
    if args.name and args.name:len() > 0 then
      local query = 'и-"' .. args.name .. '"'
      cachedName.inqueue = true
      if (args.callback ~= nil) then tinsert(cachedName.callback, args) end
      self.CacheQueue[query] = args.name
      dbg('Info(' .. args.name .. ') added to queue')
      self:AskWho({
        query = query,
        queue = args.queue,
        flags = 0,
        info = args.name
      })
    end
  else
    if args.name and args.name:len() > 0 then
      local query = 'n-"' .. args.name .. '"'
      cachedName.inqueue = true
      if (args.callback ~= nil) then tinsert(cachedName.callback, args) end
      self.CacheQueue[query] = args.name
      dbg('Info(' .. args.name .. ') added to queue')
      self:AskWho({
        query = query,
        queue = args.queue,
        flags = 0,
        info = args.name
      })
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

  dbg("Waiting to send next who")
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
lib['frame']:SetScript("OnUpdate", function(frame, elapsed)
  lib.Timeout_time = lib.Timeout_time - elapsed
  if lib.Timeout_time <= 0 then
    lib['frame']:Hide()
    lib.readyForNext = true
  end -- if
end);

-- queue scheduler
local queue_weights = {[1] = 0.6, [2] = 0.2, [3] = 0.2}
local queue_bounds = {[1] = 0.6, [2] = 0.2, [3] = 0.2}

-- allow for single queries from the user to get processed faster
local lastInstantQuery = time()
local INSTANT_QUERY_MIN_INTERVAL = 60 -- only once every 1 min

function lib:UpdateWeights()
  local weightsum, sum, count = 0, 0, 0
  for k, v in pairs(queue_weights) do
    sum = sum + v
    weightsum = weightsum + v * #self.Queue[k]
  end

  if weightsum == 0 then
    for k, v in pairs(queue_weights) do queue_bounds[k] = v end
    return
  end

  local adjust = sum / weightsum

  for k, v in pairs(queue_bounds) do
    queue_bounds[k] = queue_weights[k] * adjust * #self.Queue[k]
  end
end

function lib:GetNextFromScheduler()
  self:UpdateWeights()

  -- Since an addon could just fill up the user q for instant processing
  -- we have to limit instants to 1 per INSTANT_QUERY_MIN_INTERVAL
  -- and only try instant fulfilment if it will empty the user queue
  if #self.Queue[1] == 1 then
    if time() - lastInstantQuery > INSTANT_QUERY_MIN_INTERVAL then
      dbg("INSTANT")
      lastInstantQuery = time()
      return 1, self.Queue[1]
    end
  end

  local n, i = math.random(), 0
  repeat
    i = i + 1
    n = n - queue_bounds[i]
  until i >= #self.Queue or n <= 0

  dbg(("Q=%d, bound=%d"):format(i, queue_bounds[i]))

  if #self.Queue[i] > 0 then
    dbg(("Q=%d, bound=%d"):format(i, queue_bounds[i]))
    return i, self.Queue[i]
  else
    dbg("Queues empty, waiting")
  end
end

lib.queue_bounds = queue_bounds

---Asks the next who query.
---
---lib.WhoInProgress will be turned on if a query is found.
function lib:AskWhoNext()
  if lib.frame:IsShown() or not self.readyForNext then
    dbg("Already waiting or not processing")
    return
  end
  self.readyForNext = false
  self:CancelPendingWhoNext()  -- This looks unnecessary.

  if self.WhoInProgress then
    assert(self.Args, "self.Args should never be nil if WhoInProgress is true.")
    -- if we had a who going, it didnt complete
    dbg("TIMEOUT: " .. self.Args.query)
    local args = self.Args
    self.Args = nil
    --		if args.info and self.CacheQueue[args.query] ~= nil then
    dbg("Requeing " .. args.query)
    tinsert(self.Queue[args.queue], args)
    if args.console_show ~= nil then
      DEFAULT_CHAT_FRAME:AddMessage(
          ("Timeout on result of '%s' - retrying..."):format(args.query), 1, 1,
          0)
      args.console_show = true
    end
    --		end

    -- Since we are in progress and got AskWhoNext invoked again, which might
    -- indicate that queryInterval was set to a value too low. Increase it.
    if queryInterval < lib.MaxInterval then
      queryInterval = queryInterval + 0.5
      dbg("--Throttling down to 1 who per " .. queryInterval .. "s")
    end
  end

  self.WhoInProgress = false

  local v, k, args = nil
  local kludge = 10
  repeat
    k, v = self:GetNextFromScheduler()
    if not k then break end  -- It doesn't look like this will ever happen.
    -- If WhoFrame is shown and we only have WHOLIB_QUEUE_SCANNING to process,
    -- we give up for now in order not to break the UI opened by the player.
    if (WhoFrame:IsShown() and k > self.WHOLIB_QUEUE_QUIET) then break end
    if (#v > 0) then
      args = tremove(v, 1)
      break
    end
    kludge = kludge - 1
  until kludge <= 0  -- I don't know why to iterate 10 times here.

  if args then
    self.WhoInProgress = true
    self.Result = {}
    self.Args = args
    self.Total = -1
    if (args.console_show == true) then
      DEFAULT_CHAT_FRAME:AddMessage(string.format(self.L['console_query'],
                                                  args.query), 1, 1, 0)
    end

    if args.queue == self.WHOLIB_QUEUE_USER then
      WhoFrameEditBox:SetText(args.query)
      self.Quiet = false

      if args.whotoui then
        self.hooked.SetWhoToUi(args.whotoui)
      else
        self.hooked.SetWhoToUi(args.gui and true or false)
      end
    else
      self.hooked.SetWhoToUi(true)
      self.Quiet = true
    end

    dbg("QUERY: " .. args.query)
    self.hooked.SendWho(args.query)
  else
    self.Args = nil
    self.WhoInProgress = false
  end

  -- Keep processing the who queue if there is more work
  if not self:AllQueuesEmpty() then
    self:AskWhoNextIn5sec()
  else
    dbg("*** Done processing requests ***")
  end
end

---Inserts a who request to the queue. `self.readyForNext` is set to true.
---@param args Task The task to insert.
function lib:AskWho(args)
  tinsert(self.Queue[args.queue], args)
  dbg('[' .. args.queue .. '] added "' .. args.query .. '", queues=' ..
          #self.Queue[1] .. '/' .. #self.Queue[2] .. '/' .. #self.Queue[3])
  self:TriggerEvent('WHOLIB_QUERY_ADDED')

  -- This is quite strainge because it should be timeout-bound. Setting true
  -- directly here can be misleading.

  self.readyForNext = true
end

function lib:ReturnWho()
  if not self.Args then
    self.Quiet = nil
    return
  end

  if (self.Args.queue == self.WHOLIB_QUEUE_QUIET or self.Args.queue ==
      self.WHOLIB_QUEUE_SCANNING) then self.Quiet = nil end

  if queryInterval > self.MinInterval then
    queryInterval = queryInterval - 0.5
    dbg("--Throttling up to 1 who per " .. queryInterval .. "s")
  end

  self.WhoInProgress = false
  dbg("RESULT: " .. self.Args.query)
  dbg(
      '[' .. self.Args.queue .. '] returned "' .. self.Args.query .. '", total=' ..
          self.Total .. ' , queues=' .. #self.Queue[1] .. '/' .. #self.Queue[2] ..
          '/' .. #self.Queue[3])
  local now = time()
  local complete = (self.Total == #self.Result) and
                       (self.Total < MAX_WHOS_FROM_SERVER)
  for _, v in pairs(self.Result) do
    if (self.Cache[v.Name] == nil) then
      self.Cache[v.Name] = {inqueue = false, callback = {}}
    end

    local cachedName = self.Cache[v.Name]

    cachedName.valid = true -- is now valid
    cachedName.data = v -- update data
    cachedName.data.Online = true -- player is online
    cachedName.last = now -- update timestamp
    if (cachedName.inqueue) then
      if (self.Args.info and self.CacheQueue[self.Args.query] == v.Name) then
        -- found by the query which was created to -> remove us from query
        self.CacheQueue[self.Args.query] = nil
      else
        -- found by another query
        for k2, v2 in pairs(self.CacheQueue) do
          if (v2 == v.Name) then
            for i = self.WHOLIB_QUEUE_QUIET, self.WHOLIB_QUEUE_SCANNING do
              for k3, v3 in pairs(self.Queue[i]) do
                if (v3.query == k2 and v3.info) then
                  -- remove the query which was generated for this user, cause another query was faster...
                  dbg("Found '" .. v.Name .. "' early via query '" ..
                          self.Args.query .. "'")
                  table.remove(self.Queue[i], k3)
                  self.CacheQueue[k2] = nil
                end
              end
            end
          end
        end
      end
      dbg('Info(' .. v.Name .. ') returned: on')
      for _, v2 in pairs(cachedName.callback) do
        self:RaiseCallback(v2, self:ReturnUserInfo(v.Name))
      end
      cachedName.callback = {}
    end
    cachedName.inqueue = false -- query is done
  end
  if (self.Args.info and self.CacheQueue[self.Args.query]) then
    -- the query did not deliver the result => not online!
    local name = self.CacheQueue[self.Args.query]
    local cachedName = self.Cache[name]
    if (cachedName.inqueue) then
      -- nothing found (yet)
      cachedName.valid = true -- is now valid
      cachedName.inqueue = false -- query is done?
      cachedName.last = now -- update timestamp
      if (complete) then
        cachedName.data.Online = false -- player is offline
      else
        cachedName.data.Online = nil -- player is unknown (more results from who than can be displayed)
      end
    end
    dbg('Info(' .. name .. ') returned: ' ..
            (cachedName.data.Online == false and 'off' or 'unkn'))
    for _, v in pairs(cachedName.callback) do
      self:RaiseCallback(v, self:ReturnUserInfo(name))
    end
    cachedName.callback = {}
    self.CacheQueue[self.Args.query] = nil
  end
  self:RaiseCallback(self.Args, self.Args.query, self.Result, complete,
                     self.Args.info)
  self:TriggerEvent('WHOLIB_QUERY_RESULT', self.Args.query, self.Result,
                    complete, self.Args.info)

  if not self:AllQueuesEmpty() then self:AskWhoNextIn5sec() end
end

---Makes a who request and gets GUI event later.
---
---This function is expected to be called from the source WHOLIB_QUEUE_USER.
---@param msg string Looks like the query itself. However, it's strange that it is also used to compare with localized strings. When invoked from lib:Who(), it is the query string.
function lib:GuiWho(msg)
  if (msg == self.L['gui_wait']) then return end

  -- If there is any user query that is with `gui` set to true, we will give up
  -- this time. But why?
  for _, v in pairs(self.Queue[self.WHOLIB_QUEUE_USER]) do
    if (v.gui == true) then return end
  end
  -- I guess that if WhoInProgress was true, we show the message on the edit box
  -- of WhoFrame.
  if (self.WhoInProgress) then WhoFrameEditBox:SetText(self.L['gui_wait']) end
  -- I would say that this saved text should be used in somewhere after
  -- WhoInProgress is done. However, it is not used anywhere and is saved in all
  -- cases.
  self.savedText = msg
  self:AskWho({
    query = msg,
    queue = self.WHOLIB_QUEUE_USER,
    flags = 0,
    gui = true
  })
  WhoFrameEditBox:ClearFocus();
end

---Makes a who request and gets console event later.
---@param msg string The query to send to the server.
function lib:ConsoleWho(msg)
  -- WhoFrameEditBox:SetText(msg)
  local console_show = false
  local q1 = self.Queue[self.WHOLIB_QUEUE_USER]
  local q1count = #q1

  if (q1count > 0 and q1[q1count].query == msg) then -- last query is itdenical: drop
    return
  end

  if (q1count > 0 and q1[q1count].console_show == false) then -- display 'queued' if console and not yet shown
    DEFAULT_CHAT_FRAME:AddMessage(string.format(self.L['console_queued'],
                                                q1[q1count].query), 1, 1, 0)
    q1[q1count].console_show = true
  end
  if (q1count > 0 or self.WhoInProgress) then
    DEFAULT_CHAT_FRAME:AddMessage(string.format(self.L['console_queued'], msg),
                                  1, 1, 0)
    console_show = true
  end
  self:AskWho({
    query = msg,
    queue = self.WHOLIB_QUEUE_USER,
    flags = 0,
    console_show = console_show
  })
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
  end -- if
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
    end -- for
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
  end -- for

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

local MULTIBYTE_FIRST_CHAR = "^([\192-\255]?%a?[\128-\191]*)"

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
--SlashCmdList['WHO'] = function(msg)
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
--end
--
--SlashCmdList['WHOLIB_DEBUG'] = function()
--  -- /wholibdebug: toggle debug on/off
--  local self = lib
--
--  self:SetWhoLibDebug(not self.Debug)
--end

SLASH_WHOLIB_DEBUG1 = '/wholibdebug'

-- Why to make these hooks?
-- I would think that we want to replace the original functions. The intention
-- is to do additional things when any other addon calls these functions. I
-- would guess that we might want to avoid the original functions to be called,
-- which can interfere the temple of us to retrieve the who data.
-- What I'm think about is ... maybe we can skip this part?
--
-- TODO(GH-5): Consider to realize these parts once our addon really casues a problem.
-----
----- hook activation
-----
--
---- functions to hook
--local hooks = {
--  'WhoFrameEditBox_OnEnterPressed'
--  --	'FriendsFrame_OnEvent',
--}
--
---- hook all functions (which are not yet hooked)
--for _, name in pairs(hooks) do
--  if not lib['hooked'][name] then
--    lib['hooked'][name] = _G[name]
--    _G[name] = function(...) lib.hook[name](lib, ...) end -- function
--  end -- if
--end -- for
--
---- C_FriendList functions to hook
--local CFL_hooks = {'SendWho', 'SetWhoToUi'}
--
---- hook all C_FriendList functions (which are not yet hooked)
--for _, name in pairs(CFL_hooks) do
--  if not lib['hooked'][name] then
--    lib['hooked'][name] = _G["C_FriendList"][name]
--    _G["C_FriendList"][name] = function(...) lib.hook[name](lib, ...) end -- function
--  end -- if
--end -- for
--
---- fake 'WhoFrame:Hide' as hooked
--table.insert(hooks, 'WhoFrame_Hide')
--
---- check for unused hooks -> remove function
--for name, _ in pairs(lib['hook']) do
--  if not hooks[name] then lib['hook'][name] = function() end end -- if
--end -- for
--
---- secure hook 'WhoFrame:Hide'
--if not lib['hooked']['WhoFrame_Hide'] then
--  lib['hooked']['WhoFrame_Hide'] = true
--  hooksecurefunc(WhoFrame, 'Hide',
--                 function(...) lib['hook']['WhoFrame_Hide'](lib, ...) end -- function
--  )
--end -- if

----- Coroutine based implementation (future)
-- function lib:sendWhoResult(val)
--    coroutine.yield(val)
-- end
--
-- function lib:sendWaitState(val)
--    coroutine.yield(val)
-- end
--
-- function lib:producer()
--    return coroutine.create(
--    function()
--        lib:AskWhoNext()
--        lib:sendWaitState(true)
--
--        -- Resumed look for data
--
--    end)
-- end

---
--- hook replacements
---

function lib.hook.SendWho(self, msg)
  dbg("SendWho: " .. msg)
  lib.AskWho(self, {
    query = msg,
    queue = lib.WHOLIB_QUEUE_USER,
    whotoui = lib.SetWhoToUIState,
    flags = 0
  })
end

function lib.hook.WhoFrameEditBox_OnEnterPressed(self)
  lib:GuiWho(WhoFrameEditBox:GetText())
end

--[[
function lib.hook.FriendsFrame_OnEvent(self, ...)
	if event ~= 'WHO_LIST_UPDATE' or not lib.Quiet then
		lib.hooked.FriendsFrame_OnEvent(...)
	end
end
]]

hooksecurefunc(FriendsFrame, 'RegisterEvent', function(self, event)
  if (event == "WHO_LIST_UPDATE") then self:UnregisterEvent("WHO_LIST_UPDATE"); end
end);

function lib.hook.SetWhoToUi(self, state) lib.SetWhoToUIState = state end

function lib.hook.WhoFrame_Hide(self)
  if (not lib.WhoInProgress) then lib:AskWhoNextIn5sec() end
end

---
--- WoW events
---

local who_pattern = string.gsub(WHO_NUM_RESULTS, '%%d', '%%d%+')

function lib:CHAT_MSG_SYSTEM(arg1)
  if arg1 and arg1:find(who_pattern) then lib:ProcessWhoResults() end
end

FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")

function lib:WHO_LIST_UPDATE()
  if not lib.Quiet then
    WhoList_Update()
    FriendsFrame_Update()
  end

  lib:ProcessWhoResults()
end

function lib:ProcessWhoResults()
  self.Result = self.Result or {}

  local num
  self.Total, num = C_FriendList.GetNumWhoResults()
  for i = 1, num do
    --	self.Result[i] = C_FriendList.GetWhoInfo(i)
    local info = C_FriendList.GetWhoInfo(i)
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

  self:ReturnWho()
end

---
--- event activation
---

lib['frame']:UnregisterAllEvents();

lib['frame']:SetScript("OnEvent",
                       function(frame, event, ...) lib[event](lib, ...) end);

for _, name in pairs({'CHAT_MSG_SYSTEM', 'WHO_LIST_UPDATE'}) do
  lib['frame']:RegisterEvent(name);
end -- for

---
--- re-embed
---

for target, _ in pairs(lib['embeds']) do
  if type(target) == 'table' then lib:Embed(target) end -- if
end -- for

---
--- Old deprecated functions as of 8.1/1.13
---

local version, build, date, tocversion = GetBuildInfo()
local isWoWClassic = tocversion >= 11302 and tocversion < 20000

if isWoWClassic then
  -- Friend list API update

  -- Use C_FriendList.GetNumFriends and C_FriendList.GetNumOnlineFriends instead
  function GetNumFriends()
    return C_FriendList.GetNumFriends(), C_FriendList.GetNumOnlineFriends();
  end

  -- Use C_FriendList.GetFriendInfo or C_FriendList.GetFriendInfoByIndex instead
  function GetFriendInfo(friend)
    local info;
    if type(friend) == "number" then
      info = C_FriendList.GetFriendInfoByIndex(friend);
    elseif type(friend) == "string" then
      info = C_FriendList.GetFriendInfo(friend);
    end

    if info then
      local chatFlag = "";
      if info.dnd then
        chatFlag = CHAT_FLAG_DND;
      elseif info.afk then
        chatFlag = CHAT_FLAG_AFK;
      end
      return info.name, info.level, info.className, info.area, info.connected,
             chatFlag, info.notes, info.referAFriend, info.guid;
    end
  end

  -- Use C_FriendList.SetSelectedFriend instead
  SetSelectedFriend = C_FriendList.SetSelectedFriend;

  -- Use C_FriendList.GetSelectedFriend instead
  GetSelectedFriend = C_FriendList.GetSelectedFriend;

  -- Use C_FriendList.AddOrRemoveFriend instead
  AddOrRemoveFriend = C_FriendList.AddOrRemoveFriend;

  -- Use C_FriendList.AddFriend instead
  AddFriend = C_FriendList.AddFriend;

  -- Use C_FriendList.RemoveFriend or C_FriendList.RemoveFriendByIndex instead
  function RemoveFriend(friend)
    if type(friend) == "number" then
      C_FriendList.RemoveFriendByIndex(friend);
    elseif type(friend) == "string" then
      C_FriendList.RemoveFriend(friend);
    end
  end

  -- Use C_FriendList.ShowFriends instead
  ShowFriends = C_FriendList.ShowFriends;

  -- Use C_FriendList.SetFriendNotes or C_FriendList.SetFriendNotesByIndex instead
  function SetFriendNotes(friend, notes)
    if type(friend) == "number" then
      C_FriendList.SetFriendNotesByIndex(friend, notes);
    elseif type(friend) == "string" then
      C_FriendList.SetFriendNotes(friend, notes);
    end
  end

  -- Use C_FriendList.IsFriend instead. No longer accepts unit tokens.
  IsCharacterFriend = C_FriendList.IsFriend;

  -- Use C_FriendList.GetNumIgnores instead
  GetNumIgnores = C_FriendList.GetNumIgnores;
  GetNumIngores = C_FriendList.GetNumIgnores;

  -- Use C_FriendList.GetIgnoreName instead
  GetIgnoreName = C_FriendList.GetIgnoreName;

  -- Use C_FriendList.SetSelectedIgnore instead
  SetSelectedIgnore = C_FriendList.SetSelectedIgnore;

  -- Use C_FriendList.GetSelectedIgnore instead
  GetSelectedIgnore = C_FriendList.GetSelectedIgnore;

  -- Use C_FriendList.AddOrDelIgnore instead
  AddOrDelIgnore = C_FriendList.AddOrDelIgnore;

  -- Use C_FriendList.AddIgnore instead
  AddIgnore = C_FriendList.AddIgnore;

  -- Use C_FriendList.DelIgnore or C_FriendList.DelIgnoreByIndex instead
  function DelIgnore(friend)
    if type(friend) == "number" then
      C_FriendList.DelIgnoreByIndex(friend);
    elseif type(friend) == "string" then
      C_FriendList.DelIgnore(friend);
    end
  end

  -- Use C_FriendList.IsIgnored or the new C_FriendList.IsIgnoredByGuid instead.
  IsIgnored = C_FriendList.IsIgnored;

  -- Use C_FriendList.SendWho instead
  SendWho = C_FriendList.SendWho;

  -- Use C_FriendList.GetNumWhoResults instead
  GetNumWhoResults = C_FriendList.GetNumWhoResults;

  -- Use C_FriendList.GetWhoInfo instead
  function GetWhoInfo(index)
    local info = C_FriendList.GetWhoInfo(index);
    return info.fullName, info.fullGuildName, info.level, info.raceStr,
           info.classStr, info.area, info.filename, info.gender;
  end

  -- Use C_FriendList.SetWhoToUi instead
  SetWhoToUI = C_FriendList.SetWhoToUi;

  -- Use C_FriendList.SortWho instead
  SortWho = C_FriendList.SortWho;
end
