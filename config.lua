Config = {
    Command = 'dailyreward',

    BaseReward = 500, -- Amount for the first week of playing

    Rewards = {
        {days = 7, reward = 1000},   -- 1 week
        {days = 14, reward = 2000},  -- 2 weeks
        {days = 21, reward = 3000},  -- 3 weeks
        {days = 28, reward = 4000},  -- 4 weeks
        {days = 35, reward = 5000},  -- 5 weeks
        {days = 42, reward = 6000},  -- 6 weeks
        {days = 49, reward = 7000},  -- 7 weeks
        -- Add more as needed
    }    
}