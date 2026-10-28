-- Anonymous learning events, to find the koans people get stuck on.
-- No user ids, IPs or cookies: just which koan, what happened, what was typed.
CREATE TABLE events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  at INTEGER NOT NULL,            -- unix seconds
  koan TEXT NOT NULL,             -- e.g. flutter/flex/4
  outcome TEXT NOT NULL,          -- wrong | reveal | solve | hint
  answer TEXT,                    -- what was typed, for wrong answers
  attempts INTEGER,               -- misses before solving, for solve
  locale TEXT
);
CREATE INDEX events_koan ON events (koan, outcome);
