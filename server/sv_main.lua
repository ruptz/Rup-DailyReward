local QBCore = exports['qb-core']:GetCoreObject()

-- Function to get the date
local function getCurrentDate()
    return os.date("%Y-%m-%d")
end

-- Function to convert milliseconds to date
local function msDate(ms)
    local seconds = ms / 1000
    return os.date("%Y-%m-%d", seconds)
end

-- Function to calculate rewards
local function getReward(daysClaimed)
    local reward = Config.BaseReward  -- Default reward if no match is found

    for _, rewardEntry in ipairs(Config.Rewards) do
        if daysClaimed >= rewardEntry.days then
            reward = rewardEntry.reward
        else
            break
        end
    end

    print('Claimed Days:', daysClaimed)
    print('Calculated Reward:', reward)

    return reward
end

-- Function to handle daily reward
local function dailyReward(source)
    local currentDate = getCurrentDate()
    local Player = QBCore.Functions.GetPlayer(source)
    local identifier = Player.PlayerData.citizenid

    -- Fetch the last claim date and claim count from the database
    exports.oxmysql:fetch('SELECT last_claim_date, claim_count FROM player_rewards WHERE identifier = ?', {identifier}, function(result)
        if not result then
            print('Database result is nil')
            return
        end

        if result[1] then
            local lastClaimDate = msDate(result[1].last_claim_date)
            local claimCount = result[1].claim_count or 0
            print('Current Date:', currentDate)
            print('Database Date:', lastClaimDate)

            if lastClaimDate == currentDate then
                -- Player has already claimed reward today
                TriggerClientEvent('QBCore:Notify', source, "You have already claimed your daily reward for today.", "error")
            else
                -- Claim count logic
                local newClaimCount = claimCount + 1
                local rewardAmount = getReward(newClaimCount)

                -- Update the last claim date, claim count, and give reward
                Player.Functions.AddMoney("cash", rewardAmount, "daily-reward")
                exports.oxmysql:execute('UPDATE player_rewards SET last_claim_date = ?, claim_count = ? WHERE identifier = ?', {os.date("%Y-%m-%d"), newClaimCount, identifier})
                TriggerClientEvent('QBCore:Notify', source, "You have received your daily reward of $" .. rewardAmount .. ".", "success")
            end
        else
            -- Insert new record for the player
            local rewardAmount = getReward(1)
            Player.Functions.AddMoney("cash", rewardAmount, "daily-reward")
            exports.oxmysql:execute('INSERT INTO player_rewards (identifier, last_claim_date, claim_count) VALUES (?, ?, ?)', {identifier, os.date("%Y-%m-%d"), 1})
            TriggerClientEvent('QBCore:Notify', source, "You have received your daily reward of $" .. rewardAmount .. ".", "success")
        end
    end)
end

-- Register the command
lib.addCommand(Config.Command, {
    help = 'Claim your daily reward',
}, function(source, args, raw)
    dailyReward(source)
end)