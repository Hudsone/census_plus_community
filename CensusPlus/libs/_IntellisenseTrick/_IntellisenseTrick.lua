--[[
    Example usage:

    -- Lib_A.lua
    local lib = LibStub:NewLibrary("Lib_A", 1)
    if IntellisenseTrick_ExposeGlobal then
    Lib_A = lib
    end

    -- Lib_B.lua
    local lib_a
    if IntellisenseTrick_ExposeGlobal then
    lib_a = Lib_A
    else
    lib_a = LibStub:GetLibrary("Lib_A")
    end
--]]

---Keep it disabled. Write global patching code within blocks guard by this
---variable. Then it won't be executed in game.
IntellisenseTrick_ExposeGlobal = false
