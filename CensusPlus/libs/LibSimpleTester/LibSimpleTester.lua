--[[ World of Warcraft Addon Library - LibSimpleTester

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

---@class Testcase
---@field name string The name of the test.
---@field func function The function to test.

local major_version = 'LibSimpleTester'
local minor_version = 1
local lib = LibStub:NewLibrary(major_version, minor_version)
if not lib then return end
if IntellisenseTrick_ExposeGlobal then LibSimpleTester = lib end
local tester = {}

---Pushs a test for later testing.
---@param name string The test name that used to show on the messages.
---@param func function The test function: `func(reporter(passed: boolean))`.
function lib:PushTest(name, func)
  tester:PushTest(name, func)
end

---Pushs filtered tests.
---
---Sometimes you may want to filter the tests that are going to be executed due
---to some debugging purposes. You can prepare the tests first and invoke this
---function to batch pushing them with filters that only the test names matched
---the filter string get pushsed.
---@param tests table<string, function> The prepared tests.
---@param filter string The string to filter the test name.
function lib:PushTestsWithFilter(tests, filter)
  for name, func in pairs(tests) do
    if not filter or string.match(name, filter) then
      lib:PushTest(name, func)
    end
  end
end

---Starts the test.
function lib:StartTest()
  tester:StartTest()
end

--
-- Test cases
--
-- Test case should be defined as the following format:
-- local function <TestName>(reporter)
--   -- Test code here
--   reporter(<TestResult>)
-- end
--
-- After the test has been defined, you need to push the test to the tester.
-- Just check the `Run example tests` section for more information.
--

local function unitTest_Tester_ShouldReportTestResults(reporter)
  reporter(true)
end

--
-- Run example tests
--
-- /simpletester-test
--

SLASH_SIMPLETESTER_TEST1 = '/simpletester-test'
SlashCmdList['SIMPLETESTER_TEST'] = function(msg)
  local test_list = {
    unitTest_Tester_ShouldReportTestResults =
        unitTest_Tester_ShouldReportTestResults,
  }
  lib:PushTestsWithFilter(test_list, msg)
  lib:StartTest()
end

--
-- Tester functions
--

---@type Testcase[] The list of tests.
tester.tests = {}
---@type boolean[] The list of results of the tests.
tester.results = {}
local sPassed = '\124c0000FF00PASSED\124r'
local sFailed = '\124c00FF0000FAILED\124r'

---Pushs a test for later testing.
---@param name string The test name that used to show on the messages.
---@param func function The test function: `func(reporter(passed: boolean))`.
function tester:PushTest(name, func)
  tinsert(self.tests, {
    name = name,
    func = function(idx)
      print('\124c00AAAA00Start test ' .. tostring(idx) .. '\124r', name)
      func(function(passed)
        tester:ReportTestResult(idx, passed)
      end)
    end
  })
end

---Starts the test.
function tester:StartTest()
  if #self.tests == 0 then
    self:FinalizeTest()
  else
    self.tests[1].func(1)
  end
end

---Reports the test result.
---
---This function should be called in the test function. Otherwise, the tester
---won't know if the test is successful or failed.
---@param idx integer Should be passed as what it
---@param result any
function tester:ReportTestResult(idx, result)
  if result == nil then
    result = false
  end
  local sResult = result and sPassed or sFailed
  print('\124c00AAAA00Test ' .. tostring(idx) .. '\124r ' .. sResult)
  self.results[idx] = result
  if #self.results == #self.tests then
    self:FinalizeTest()
  else
    C_Timer.After(0, function() self.tests[idx + 1].func(idx + 1) end)
  end
end

function tester:FinalizeTest()
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
