-- ============================================
-- MathKids Supabase Setup
-- Run this in Supabase Dashboard > SQL Editor
-- ============================================

-- Drop existing objects first (safe reset)
DROP FUNCTION IF EXISTS get_leaderboard(TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS get_overall_leaderboard(TEXT, TEXT);
DROP FUNCTION IF EXISTS upsert_score(TEXT, TEXT, INT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS recover_by_email(TEXT);
DROP TRIGGER IF EXISTS update_mk_scores_modtime ON mk_scores;
DROP TRIGGER IF EXISTS update_mk_players_modtime ON mk_players;
DROP TABLE IF EXISTS mk_scores;
DROP TABLE IF EXISTS mk_players;
DROP FUNCTION IF EXISTS update_modified_column();

-- 1. Players table (user profiles + data backup)
CREATE TABLE mk_players (
  uid TEXT PRIMARY KEY,              -- MK-XXXXXX unique code
  name TEXT NOT NULL DEFAULT 'Player',
  age INT DEFAULT 6,
  char_key TEXT DEFAULT 'fox',
  country TEXT DEFAULT 'US',
  lang TEXT DEFAULT 'en',
  total_stars INT DEFAULT 0,
  total_coins INT DEFAULT 0,
  parent_email TEXT DEFAULT '',      -- for account recovery
  data JSONB,                        -- full localStorage backup for sync
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Scores table (per-category scores for leaderboard)
CREATE TABLE mk_scores (
  uid TEXT NOT NULL REFERENCES mk_players(uid) ON DELETE CASCADE,
  cat_id TEXT NOT NULL,              -- count, add, sub, mul, div, frac, shape, time, money
  score INT DEFAULT 0,
  country TEXT DEFAULT '',
  mascot TEXT DEFAULT '',
  name TEXT DEFAULT 'Player',
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (uid, cat_id)
);

-- 3. Indexes for fast leaderboard queries
CREATE INDEX idx_scores_cat_score ON mk_scores (cat_id, score DESC);
CREATE INDEX idx_scores_cat_country_score ON mk_scores (cat_id, country, score DESC);

-- 4. Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_mk_players_modtime
  BEFORE UPDATE ON mk_players
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_mk_scores_modtime
  BEFORE UPDATE ON mk_scores
  FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- 5. RLS Policies (permissive for anon key - this is a kids game)
ALTER TABLE mk_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE mk_scores ENABLE ROW LEVEL SECURITY;

-- Anyone can read (for leaderboard)
CREATE POLICY "Public read players" ON mk_players FOR SELECT USING (true);
CREATE POLICY "Public read scores" ON mk_scores FOR SELECT USING (true);

-- Anyone can insert/update (no auth - identified by uid)
CREATE POLICY "Public insert players" ON mk_players FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update players" ON mk_players FOR UPDATE USING (true);
CREATE POLICY "Public insert scores" ON mk_scores FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update scores" ON mk_scores FOR UPDATE USING (true);

-- 6. Leaderboard view function (top 50 per category)
CREATE OR REPLACE FUNCTION get_leaderboard(p_cat_id TEXT, p_scope TEXT DEFAULT 'global', p_country TEXT DEFAULT '')
RETURNS TABLE (
  uid TEXT,
  name TEXT,
  mascot TEXT,
  country TEXT,
  score INT,
  rank BIGINT
) AS $$
BEGIN
  IF p_scope = 'global' THEN
    RETURN QUERY
      SELECT s.uid, s.name, s.mascot, s.country, s.score,
             ROW_NUMBER() OVER (ORDER BY s.score DESC) AS rank
      FROM mk_scores s
      WHERE s.cat_id = p_cat_id
      ORDER BY s.score DESC
      LIMIT 50;
  ELSE
    RETURN QUERY
      SELECT s.uid, s.name, s.mascot, s.country, s.score,
             ROW_NUMBER() OVER (ORDER BY s.score DESC) AS rank
      FROM mk_scores s
      WHERE s.cat_id = p_cat_id AND s.country = p_country
      ORDER BY s.score DESC
      LIMIT 50;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 7. Upsert score function
CREATE OR REPLACE FUNCTION upsert_score(
  p_uid TEXT, p_cat_id TEXT, p_score INT, p_country TEXT, p_mascot TEXT, p_name TEXT
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO mk_scores (uid, cat_id, score, country, mascot, name)
  VALUES (p_uid, p_cat_id, p_score, p_country, p_mascot, p_name)
  ON CONFLICT (uid, cat_id) DO UPDATE
  SET score = GREATEST(mk_scores.score, p_score),
      country = p_country,
      mascot = p_mascot,
      name = p_name;
END;
$$ LANGUAGE plpgsql;

-- 8. Overall leaderboard (sum of all category scores)
CREATE OR REPLACE FUNCTION get_overall_leaderboard(p_scope TEXT DEFAULT 'global', p_country TEXT DEFAULT '')
RETURNS TABLE (
  uid TEXT,
  name TEXT,
  mascot TEXT,
  country TEXT,
  score BIGINT,
  rank BIGINT
) AS $$
BEGIN
  IF p_scope = 'global' THEN
    RETURN QUERY
      SELECT s.uid, MAX(s.name)::TEXT AS name, MAX(s.mascot)::TEXT AS mascot, MAX(s.country)::TEXT AS country,
             SUM(s.score)::BIGINT AS score,
             ROW_NUMBER() OVER (ORDER BY SUM(s.score) DESC) AS rank
      FROM mk_scores s
      GROUP BY s.uid
      ORDER BY score DESC
      LIMIT 50;
  ELSE
    RETURN QUERY
      SELECT s.uid, MAX(s.name)::TEXT AS name, MAX(s.mascot)::TEXT AS mascot, MAX(s.country)::TEXT AS country,
             SUM(s.score)::BIGINT AS score,
             ROW_NUMBER() OVER (ORDER BY SUM(s.score) DESC) AS rank
      FROM mk_scores s
      WHERE s.country = p_country
      GROUP BY s.uid
      ORDER BY score DESC
      LIMIT 50;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 9. Account recovery by parent email
CREATE OR REPLACE FUNCTION recover_by_email(p_email TEXT)
RETURNS TABLE (
  uid TEXT,
  name TEXT,
  char_key TEXT,
  country TEXT,
  total_stars INT
) AS $$
BEGIN
  RETURN QUERY
    SELECT p.uid, p.name, p.char_key, p.country, p.total_stars
    FROM mk_players p
    WHERE LOWER(p.parent_email) = LOWER(p_email) AND p.parent_email != ''
    ORDER BY p.updated_at DESC;
END;
$$ LANGUAGE plpgsql;

-- 9. Index for email recovery
CREATE INDEX idx_players_email ON mk_players (LOWER(parent_email));
