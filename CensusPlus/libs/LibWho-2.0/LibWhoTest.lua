--[[
    @file LibWho-Test.lua
    @brief Test cases for LibWho-2.0.

    This file contains the tests that can be run to verify the functionality of WhoLib.
]]

---@class Testcase
---@field name string The name of the test.
---@field func function The function to test.

---@class Tester
---@field tests Testcase[] The list of tests.
---@field results boolean[] The list of results of the tests.
local tester = {tests = {}, results = {}}
local lib = LibStub('LibWho-2.0')
if IntellisenseTrick_ExposeGlobal then lib = LibWho end

--
-- Test cases
--
-- Test case should be defined as the following format:
-- local function <TestName>(test_idx)
--   -- Test code here
--   tester:ReportTestResult(test_idx, <TestResult>)
-- end
--
-- After the test has been defined, you need to push the test to the tester.
-- Just check the `Slash command` section for more information.
--

local function unitTest_Tester_ShouldReportTestResults(test_idx)
  tester:ReportTestResult(test_idx, true)
end

local function functionalTest_Who_ShouldReturnResults(test_idx)
  lib:Who('0-500', function(query, result)
    assert(#result >= 1)
    assert(query == '0-500')
    tester:ReportTestResult(test_idx, true)
  end)
end

local function functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery(
    test_idx)
  local player_name = UnitName("player")
  assert(lib.setWhoToUiState == false, 'This test requires WhoToUi to be false first.')
  ---Callback.
  ---
  ---We invoke a normal `C_FriendList.SendWho` in the callback to perform a
  ---consecutive call, this call cannot get the response due to the server
  ---throttling, so that it should be queued and get the result after the
  ---throttling is done.
  ---
  ---We also test the API call to be responded with the CHAT_MSG_SYSTEM event.
  ---@param query string
  ---@param results WhoInfo[]
  local function sendWho(query, results)
    assert(#results == 0)
    assert(query == '0-10')
    tester:DebugMessage('Quiet who 0-10 done')
    local frame = tester:GetAFrame()
    frame:RegisterEvent('WHO_LIST_UPDATE')
    frame:RegisterEvent('CHAT_MSG_SYSTEM')
    frame:SetScript('OnEvent', function(_, event, ...)
      tester:DebugMessage('Got event ' .. event)
      assert(event ~= 'WHO_LIST_UPDATE', 'The SetWhoToUi is not restored.')
      if event ~= 'CHAT_MSG_SYSTEM' then return end
      local numWhos, totalNumWhos = C_FriendList.GetNumWhoResults()
      assert(numWhos == 1)
      assert(totalNumWhos == 1)
      frame:UnregisterEvent('WHO_LIST_UPDATE')
      frame:UnregisterEvent('CHAT_MSG_SYSTEM')
      tester:ReportTestResult(test_idx, true)
    end)
    tester:DebugMessage('Sending who ' .. player_name)
    C_FriendList.SendWho(player_name)
  end
  tester:DebugMessage('Sending quiet who 0-10')
  lib:Who('0-10', sendWho)
end

--
-- Slash command
--

-- You can add a filter after the command. E.g., /wholib-test ReportTest
SLASH_WHOLIB_TEST1 = '/wholib-test'
SlashCmdList['WHOLIB_TEST'] = function(msg)
  local test_list = {
    unitTest_Tester_ShouldReportTestResults =
    unitTest_Tester_ShouldReportTestResults,
    functionalTest_Who_ShouldReturnResults =
    functionalTest_Who_ShouldReturnResults,
    functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery =
    functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery,
  }
  for name, func in pairs(test_list) do
    if not msg or string.match(name, msg) then
      tester:PushTest(name, func)
    end
  end
  tester:StartTest()
end

--
-- Tester functions
--

local sPassed = '\124c0000FF00PASSED\124r'
local sFailed = '\124c00FF0000FAILED\124r'

function tester:PushTest(name, func)
  tinsert(self.tests, {
    name = name,
    func = function(idx)
      print('\124c00AAAA00Start test ' .. tostring(idx) .. '\124r')
      func(idx)
    end
  })
end

function tester:StartTest()
  print('Note: Please click to enable the hardware event.')
  lib.RegisterCallback(self, 'WHOLIB_READY', function(...)
    print('Please click to continue the tests.')
  end)
  if #self.tests == 0 then
    self:FinalizeTest()
  else
    self.tests[1].func(1)
  end
end

function tester:ReportTestResult(idx, result)
  local sResult = result and sPassed or sFailed
  print('\124c00AAAA00Test ' .. tostring(idx) .. '\124r ' .. sResult)
  self.results[idx] = result
  if #self.results == #self.tests then
    self:FinalizeTest()
  else
    self.tests[idx + 1].func(idx + 1)
  end
end

function tester:FinalizeTest()
  lib.UnregisterCallback(self, 'WHOLIB_READY')
  print('Test results:')
  local passed = 0
  for i, result in pairs(self.results) do
    print(string.format('%s: %s', result and sPassed or sFailed,
                        self.tests[i].name))
    if result then passed = passed + 1 end
  end
  print(string.format('Total %d/%d tests passed.', passed, #self.tests))
  self.tests, self.results = {}, {}
end

function tester:GetAFrame()
  if not tester.frame then tester.frame = CreateFrame('Frame') end
  return tester.frame
end

---Prints test message in special color.
---
---To trace a lot of asynchornous test operations, we may need to print some
---messages. It would be better to print these messages in special color so
---that we can easier to distinguish them from other messages.
---@param msg string The message to shown.
function tester:DebugMessage(msg)
  if not lib.GetWhoLibDebug() then
    return
  end
  local colorCode = '000088ff'
  print('\124c' .. colorCode .. msg .. '\124r')
end
