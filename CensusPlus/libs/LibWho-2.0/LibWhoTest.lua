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
  local function sendWho()
    tester:DebugMessage('Quiet who 0-10 done')
    local frame = tester:GetAFrame()
    local registered = frame:RegisterEvent('WHO_LIST_UPDATE')
    frame:SetScript('OnEvent', function(_, event, ...)
      tester:DebugMessage('Got event ' .. event)
      if event ~= 'WHO_LIST_UPDATE' then return end
      local numWhos, totalNumWhos = C_FriendList.GetNumWhoResults()
      assert(numWhos > 0)
      assert(totalNumWhos > 0)
      frame:UnregisterEvent('WHO_LIST_UPDATE')
      tester:ReportTestResult(test_idx, true)
    end)
    tester:DebugMessage('Sending who 0-500')
    C_FriendList.SendWho('0-500')
  end
  tester:DebugMessage('Sending quiet who 0-10')
  lib:Who('0-10', sendWho)
end

--
-- Slash command
--

SLASH_WHOLIB_TEST1 = '/wholib-test'
SlashCmdList['WHOLIB_TEST'] = function(msg)
  tester:PushTest('unitTest_Tester_ShouldReportTestResults',
                  unitTest_Tester_ShouldReportTestResults)
  tester:PushTest('functionalTest_Who_ShouldReturnResults',
                  functionalTest_Who_ShouldReturnResults)
  tester:PushTest(
    'functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery',
    functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery)
  tester:StartTest()
end

--
-- Tester functions
--

function tester:PushTest(name, func)
  tinsert(self.tests, {name = name, func = func})
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
  self.results[idx] = result
  if #self.results == #self.tests then
    self:FinalizeTest()
  else
    self.tests[idx + 1].func(idx + 1)
  end
end

function tester:FinalizeTest()
  lib.UnregisterCallback(self, 'WHOLIB_READY')
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
