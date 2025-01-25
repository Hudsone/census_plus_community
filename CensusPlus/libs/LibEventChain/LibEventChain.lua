--[[ World of Warcraft Addon Library - LibEventChain

  Copyright (C) 2025 Hsiwei Chang

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
]]

-- This library is used to provide simple implementation of chaining events.
-- It's something as what a Promise would look like.

local major_version = 'LibEventChain'
local minor_version = 1
local lib = LibStub:NewLibrary(major_version, minor_version)
if not lib then return end
local tester = LibStub:GetLibrary('LibSimpleTester')
if IntellisenseTrick_ExposeGlobal then
  LibEventChain = lib
  tester = LibSimpleTester
end

local locals = {}

---@class EventChain The event chain.
---@field Next function Creates the EventChain which succeeds this one.
---@field NextCallback function Creates the CallbackChain which succeeds this one.
---@field turnOn function Turns on the this EventChain.
---@field event string The event to listen.
---@field callback function The callback, which all event payloads will be passed to it (the parameters after the event name).
---@field regardTheCallbackReturn boolean `true` to launch the next event chain only when the callback returns true. `false` to chain events immediately when the specified event was triggered.
---@field next EventChain[] The next EventChains.

---@class CallbackChain The callback chain.
---@field Next function Creates the EventChain which succeeds this one.
---@field NextCallback function Creates the CallbackChain which succeeds this one.
---@field turnOn function Turns on the this CallbackChain.
---@field callback function The callback, which all event payloads will be passed to it (the parameters after the event name).
---@field next EventChain[] The next EventChains.

---Creates an EventChain that executes the callback on the given event.
---@param event string The event name.
---@param callback function The callback, which all event payloads will be passed to it (the parameters after the event name).
---@param regardTheCallbackReturn? boolean `true` to launch the next event chain only when the callback returns true. `false` to chain events immediately when the specified event was triggered.
---@return EventChain eventChain The event chain.
function lib:CreateEventChain(event, callback, regardTheCallbackReturn)
  local chain = locals:createEventChain(event, callback, regardTheCallbackReturn)
  chain:turnOn()
  return chain
end

---Creates a CallbackChain that executes the callback after the previous callback.
---
---A CallbackChain is like an EventChain but invokes the callback directly. The
---user provided callback function should only accept a callback as the first
---parameter which you must invoke it when your callback has done.
---@param callback function The callback, which should accept a single callback function as its first parameter, all remaining parameters will be delegate to the callback of the next CallbackChain. Requires to be async or the following callbacks cannot be hooked.
function lib:CreateCallbackChain(callback)
  local chain = locals:createCallbackChain(callback)
  chain:turnOn()
  return chain
end

---@class FrameResource The frame with used bit.
---@field frame Frame The actual WOW frame.
---@field available boolean Whether the frame is available.

local function initializeLocals()
  ---@type FrameResource[]
  locals.frames = {}
end

initializeLocals()

---Gets a frame.
---@return Frame frame The new available frame.
function locals:getFrame()
  for _, frameResource in pairs(self.frames) do
    if frameResource.available then
      frameResource.available = false
      return frameResource.frame
    end
  end
  local newFrame = CreateFrame('Frame')
  tinsert(self.frames, {frame = newFrame, available = false})
  return newFrame
end

---Frees a frame got from the `getFrame` method.
---@param frame Frame
function locals:freeFrame(frame)
  for _, frameResource in pairs(self.frames) do
    if frameResource.frame == frame then
      frame:UnregisterAllEvents()
      frame:SetScript('OnEvent', nil)
      frameResource.available = true
    end
  end
end

---Creates an EventChain after this one.
---@param self EventChain|CallbackChain Depends on which chain to attach.
---@param nextEvent string The event name.
---@param nextCallback function The callback, which all event payloads will be passed to it (the parameters after the event name).
---@param nextRegardTheCallbackReturn boolean `true` to launch the next event chain only when the callback returns true. `false` to chain events immediately when the specified event was triggered.
---@return EventChain eventChain The event chain.
local function createNext(
    self,
    nextEvent,
    nextCallback,
    nextRegardTheCallbackReturn)
  local nextChain = locals:createEventChain(nextEvent, nextCallback,
                                            nextRegardTheCallbackReturn)
  tinsert(self.next, nextChain)
  return nextChain
end

---Creates a CallbackChain after this one.
---@param self EventChain|CallbackChain Depends on which chain to attach.
---@param nextCallback function The callback that is going to be called when the current one is done.
local function createNextCallback(self, nextCallback)
  local nextChain = locals:createCallbackChain(nextCallback)
  tinsert(self.next, nextChain)
  return nextChain
end

---Creates an EventChain object.
---@param event string
---@param callback function
---@param regardTheCallbackReturn boolean
function locals:createEventChain(event, callback, regardTheCallbackReturn)
  ---@type EventChain
  local chain = {
    Next = createNext,
    NextCallback = createNextCallback,
    turnOn = function(chainSelf) locals:turnOnEventChain(chainSelf) end,
    event = event,
    callback = callback,
    regardTheCallbackReturn = regardTheCallbackReturn,
    next = {}
  }
  return chain
end

---Extracts the possible parameters from the results.
---@param results any[] The result values.
---@return any[]|nil possibleParameters The parameters to pass on if any.
local function extractPossibleParameters(results)
  local possibleParameters = {}
  for i, parameter in pairs(results) do
    if i > 1 then
      tinsert(possibleParameters, parameter)
    end
  end
  return #possibleParameters > 0 and possibleParameters or nil
end

---Turns on the EventChain.
---@param chain EventChain
function locals:turnOnEventChain(chain)
  chain.boundFrame = locals:getFrame()
  chain.boundFrame:RegisterEvent(chain.event)
  chain.boundFrame:SetScript('OnEvent', function(_, _, ...) -- self, event
    -- Note these parameters are only passed to CallbackChain items since the EventChain accepts the payloads from the event itself.
    local possibleParameters = nil
    if chain.regardTheCallbackReturn then
      local callbackResults = {chain.callback(...)}
      if not callbackResults[1] then return end
      possibleParameters = extractPossibleParameters(callbackResults)
    end
    locals:freeFrame(chain.boundFrame)
    chain.boundFrame = nil
    chain.Next = nil -- No longer able to chain new events.
    for _, nextChain in pairs(chain.next) do
      if possibleParameters then
        nextChain:turnOn(unpack(possibleParameters))
      else
        nextChain:turnOn()
      end
    end
    if not chain.regardTheCallbackReturn then
      chain.callback(...)
    end
  end)
end

---Creates a CallbackChain object.
---@param callback function
function locals:createCallbackChain(callback)
  ---@type CallbackChain
  local chain = {
    Next = createNext,
    NextCallback = createNextCallback,
    callback = callback,
    next = {}
  }

  ---Executes the callback.
  ---@param ... any All parameters will be delegated to the callback function as the parameters start from the 2nd (first one is the next callback function).
  function chain:turnOn(...)
    self.callback(
      function(...)
        for _, nextChain in pairs(self.next) do
          nextChain:turnOn(...)
        end
      end,
      ...)
  end

  return chain
end

--
-- Tests
--

local function unitTest_getFrame_ShouldReturnCachedFrameIfPossible(reporter)
  local frame1 = locals:getFrame()
  local frame2 = locals:getFrame()
  locals:freeFrame(frame1)
  locals:freeFrame(frame2)
  local frame3 = locals:getFrame()
  locals:freeFrame(frame3)
  reporter(frame3 == frame1 or frame3 == frame1)
end

local function unitTest_freeFrame_ShouldRemoveAllEvents(reporter)
  local frame = locals:getFrame()
  frame:RegisterEvent('WHO_LIST_UPDATE')
  locals:freeFrame(frame)
  reporter(frame:IsEventRegistered('WHO_LIST_UPDATE') == false)
end

local function functionalTest_CreateEventChain_EventsRegardlessCallback(reporter)
  local passed = true
  lib:CreateEventChain('CHAT_MSG_SYSTEM', function(text)
    passed = passed and (string.match(text, 'test'))
    SendChatMessage('afk_test', 'DND')
  end):Next('CHAT_MSG_SYSTEM', function(text)
    passed = passed and (string.match(text, 'afk_test'))
    SendChatMessage('', 'DND')
    reporter(passed)
  end)
  SendChatMessage('test', 'DND')
end

local function functionalTest_CreateEventChain_EventsRegardCallback(reporter)
  lib:CreateEventChain(
    'CHAT_MSG_SYSTEM',
    function(text)
      if string.match(text, 'test yes') then
        C_Timer.After(1, function() SendChatMessage('test no', 'DND') end)
        return true
      end
    end, true):Next(
    'CHAT_MSG_SYSTEM',
    function(text)
      SendChatMessage('', 'DND')
      reporter(string.match(text, 'test no'))
    end)
  SendChatMessage('test no', 'DND')
  SendChatMessage('test yes', 'DND')
end

local function unitTest_CreateCallbackChain(reporter)
  local value = 0
  lib:CreateCallbackChain(function(callback)
    value = value + 10
    C_Timer.After(0.1, function() callback(3, 4, 5) end)
  end):NextCallback(function(callback, a, b, c)
    value = (value + a + b) * c
    C_Timer.After(0.1, function() callback(value) end)
  end):NextCallback(function(_, result)
    reporter(result == 85)
  end)
end

local function functionalTest_CreateCallbackChain_MixWithEventChain(reporter)
  local value = 0
  lib:CreateCallbackChain(function(callback)
    value = value + 10
    C_Timer.After(0.1, function() callback() end)
    C_Timer.After(1, function() SendChatMessage('5', 'DND') end)
  end):Next(
    'CHAT_MSG_SYSTEM',
    function(text)
      local valueToAdd = string.match(text, '%d') + 1
      return true, valueToAdd
    end,
    true):NextCallback(
    function(_, valueToAdd)
      reporter(value + valueToAdd == 16)
    end)
end

SLASH_EVENTCHAIN_TEST1 = '/eventchain-test'
SlashCmdList['EVENTCHAIN_TEST'] = function(msg)
  local test_list = {
    unitTest_getFrame_ShouldReturnCachedFrameIfPossible =
        unitTest_getFrame_ShouldReturnCachedFrameIfPossible,
    unitTest_freeFrame_ShouldRemoveAllEvents =
        unitTest_freeFrame_ShouldRemoveAllEvents,
    functionalTest_CreateEventChain_EventsRegardlessCallback =
        functionalTest_CreateEventChain_EventsRegardlessCallback,
    functionalTest_CreateEventChain_EventsRegardCallback =
        functionalTest_CreateEventChain_EventsRegardCallback,
    unitTest_CreateCallbackChain = unitTest_CreateCallbackChain,
    functionalTest_CreateCallbackChain_MixWithEventChain =
        functionalTest_CreateCallbackChain_MixWithEventChain,
  }
  tester:PushTestsWithFilter(test_list, msg)
  tester:StartTest()
end
