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

--
-- Slash command
--

SLASH_WHOLIB_TEST1 = '/wholib-test'
SlashCmdList['WHOLIB_TEST'] = function(msg)
  tester:PushTest('unitTest_Tester_ShouldReportTestResults',
                  unitTest_Tester_ShouldReportTestResults)
  tester:PushTest('functionalTest_Who_ShouldReturnResults',
                  functionalTest_Who_ShouldReturnResults)
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
  for i, test in pairs(self.tests) do test.func(i) end
end

function tester:ReportTestResult(idx, result)
  self.results[idx] = result
  if #self.results == #self.tests then self:FinalizeTest() end
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
