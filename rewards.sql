CREATE TABLE player_rewards (
    identifier VARCHAR(50) PRIMARY KEY,
    last_claim_date DATE,
    claim_count INT DEFAULT 0
);