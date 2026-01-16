-- =====================================
-- Sprindu Coin - Turtle WoW (1.12.1)
-- =====================================

-- Initialize SavedVariables
if not SprinduCoinDB then
    SprinduCoinDB = {
        balances = {},
        distributors = {}
    }
end

-- =====================================
-- Utility Functions
-- =====================================

local function PlayerName()
    return UnitName("player")
end

-- Vanilla-safe Guild Master check
local function IsGuildMaster()
    if not IsInGuild() then return false end
    local name, rank, rankIndex = GetGuildInfo("player")
    return rankIndex == 0
end

local function IsDistributor()
    return IsGuildMaster() or SprinduCoinDB.distributors[PlayerName()]
end

local function AddCoins(player, amount)
    SprinduCoinDB.balances[player] = (SprinduCoinDB.balances[player] or 0) + amount
end

local function GetBalance(player)
    return SprinduCoinDB.balances[player] or 0
end

-- =====================================
-- Popup Menu
-- =====================================

StaticPopupDialogs["SPRINDU_COIN_MENU"] = {
    text = "Sprindu Coin Menu",
    button1 = "OK",
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnAccept = function()
        print("|cff00ff00Sprindu Coin Commands:|r")
        print("/sprindu give <player> <amount>")
        print("/sprindu balance [player]")
        print("/sprindu authorize <player>  (Guild Master)")
        print("/sprindu revoke <player>     (Guild Master)")
    end
}

-- =====================================
-- Slash Commands
-- =====================================

SLASH_SPRINDU1 = "/sprindu"
SlashCmdList["SPRINDU"] = function(msg)
    local args = {}
    for word in string.gfind(msg, "%S+") do
        table.insert(args, word)
    end

    local cmd = args[1]

    -- Open menu
    if cmd == "menu" or cmd == nil then
        StaticPopup_Show("SPRINDU_COIN_MENU")
        return
    end

    -- Give coins
    if cmd == "give" then
        if not IsDistributor() then
            print("|cffff0000You are not authorized to give Sprindu Coins.|r")
            return
        end

        local target = args[2]
        local amount = tonumber(args[3])

        if not target or not amount or amount <= 0 then
            print("Usage: /sprindu give <player> <amount>")
            return
        end

        AddCoins(target, amount)
        print("|cff00ff00Gave|r", amount, "Sprindu Coins to", target)
        return
    end

    -- Check balance
    if cmd == "balance" then
        local target = args[2] or PlayerName()
        print(target .. " has " .. GetBalance(target) .. " Sprindu Coins")
        return
    end

    -- Authorize distributor
    if cmd == "authorize" then
        if not IsGuildMaster() then
            print("|cffff0000Only the Guild Master can authorize distributors.|r")
            return
        end

        local target = args[2]
        if not target then
            print("Usage: /sprindu authorize <player>")
            return
        end

        SprinduCoinDB.distributors[target] = true
        print(target .. " is now authorized to give Sprindu Coins")
        return
    end

    -- Revoke distributor
    if cmd == "revoke" then
        if not IsGuildMaster() then
            print("|cffff0000Only the Guild Master can revoke distributors.|r")
            return
        end

        local target = args[2]
        SprinduCoinDB.distributors[target] = nil
        print(target .. " is no longer authorized")
        return
    end

    -- Help
    print("|cff00ff00Sprindu Coin Commands:|r")
    print("/sprindu menu")
    print("/sprindu give <player> <amount>")
    print("/sprindu balance [player]")
    print("/sprindu authorize <player>")
    print("/sprindu revoke <player>")
end

-- =====================================
-- Load Event
-- =====================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function()
    print("|cff00ff00Sprindu Coin loaded for Turtle WoW.|r")
end)
