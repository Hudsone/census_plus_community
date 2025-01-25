--[[
    @file LibWho-Test.lua
    @brief Test cases for LibWho-2.0.

    This file contains the tests that can be run to verify the functionality of WhoLib.
]]

local tester = LibStub('LibSimpleTester')
local lib = LibStub('LibWho-2.0')
if IntellisenseTrick_ExposeGlobal then
  lib = LibWho
  tester = LibSimpleTester
end

--
-- Test cases
--

local function functionalTest_Who_ShouldReturnResults(reporter)
  lib:Who('0-500', function(query, result)
    assert(#result >= 1)
    assert(query == '0-500')
    reporter(true)
  end)
end

local function functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery(
    reporter)
  local player_name = UnitName('player')
  assert(lib.setWhoToUiState == false,
         'This test requires WhoToUi to be false first.')
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
      reporter(true)
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
    functionalTest_Who_ShouldReturnResults =
        functionalTest_Who_ShouldReturnResults,
    functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery =
        functionalTest_C_FriendList_SendWho_ShouldGetQueuedIfFollowingAQuietQuery,
  }
  tester:PushTestsWithFilter(test_list, msg)
  tester:StartTest()
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
  local colorCode = '000088ff'
  print('\124c' .. colorCode .. msg .. '\124r')
end
