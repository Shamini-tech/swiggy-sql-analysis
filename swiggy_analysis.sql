-- =====================================================
-- Swiggy Restaurant Analysis (SQLite)
-- Dataset: Swiggy Restaurants Dataset (Kaggle, ashishjangra27)
-- Tool: DB Browser for SQLite
-- Setup: File > Import > Table from CSV file -> table name `swiggy`
-- =====================================================

-- -----------------------------------------------------
-- 1. Inspect the raw data
-- -----------------------------------------------------
SELECT COUNT(*) FROM swiggy;          -- 148,541 rows
PRAGMA table_info(swiggy);            -- rating, rating_count, cost are TEXT
SELECT * FROM swiggy LIMIT 10;

-- -----------------------------------------------------
-- 2. Clean: build a new table with numeric columns
--    (the raw `swiggy` table is left untouched)
--    - rating: '--' (unrated) becomes NULL
--    - cost: '₹ 200' becomes 200
--    - rating_count: '50+ ratings' becomes 50, '1K+ ratings' becomes 1000
--      ('Too Few Ratings' becomes NULL)
-- -----------------------------------------------------
CREATE TABLE swiggy_clean AS
SELECT
  id,
  name,
  city,
  cuisine,
  rating,
  rating_count,
  cost,
  CASE WHEN rating GLOB '[0-9]*' THEN CAST(rating AS REAL) END AS rating_num,
  CASE
    WHEN REPLACE(REPLACE(REPLACE(cost, '₹', ''), ' ', ''), ',', '') GLOB '[0-9]*'
    THEN CAST(REPLACE(REPLACE(REPLACE(cost, '₹', ''), ' ', ''), ',', '') AS INTEGER)
  END AS cost_num,
  CASE
    WHEN rating_count LIKE '%K+%'
      THEN CAST(SUBSTR(rating_count, 1, INSTR(rating_count, 'K') - 1) AS REAL) * 1000
    WHEN rating_count GLOB '[0-9]*'
      THEN CAST(rating_count AS INTEGER)
  END AS rating_count_num
FROM swiggy;

-- -----------------------------------------------------
-- 3. Validate the cleaning
--    Result: 148541 total | 61441 rated | 148410 with cost | 61441 with rating count
-- -----------------------------------------------------
SELECT
  COUNT(*) AS total_rows,
  COUNT(rating_num) AS rated_rows,
  COUNT(cost_num) AS rows_with_cost,
  COUNT(rating_count_num) AS rows_with_count
FROM swiggy_clean;

-- -----------------------------------------------------
-- 4. Analysis
-- -----------------------------------------------------

-- Q1: Which locations have the most restaurants?
SELECT city, COUNT(*) AS total_restaurants
FROM swiggy_clean
GROUP BY city
ORDER BY total_restaurants DESC
LIMIT 10;

-- Q2: Most common cuisine listings
SELECT cuisine, COUNT(*) AS total
FROM swiggy_clean
GROUP BY cuisine
ORDER BY total DESC
LIMIT 10;

-- Q3: Chains with the most branches
SELECT name, COUNT(*) AS branches
FROM swiggy_clean
GROUP BY name
ORDER BY branches DESC
LIMIT 10;

-- Q4: Best rated locations (more than 50 rated restaurants)
SELECT city,
       ROUND(AVG(rating_num), 2) AS avg_rating,
       COUNT(rating_num) AS rated_restaurants
FROM swiggy_clean
GROUP BY city
HAVING COUNT(rating_num) > 50
ORDER BY avg_rating DESC
LIMIT 5;

-- Q5: Most expensive locations by average cost (more than 30 restaurants)
SELECT city,
       ROUND(AVG(cost_num), 0) AS avg_cost,
       COUNT(cost_num) AS restaurants
FROM swiggy_clean
GROUP BY city
HAVING COUNT(cost_num) > 30
ORDER BY avg_cost DESC
LIMIT 10;

-- Q6: Best rated cuisines (more than 100 rated restaurants)
SELECT cuisine,
       ROUND(AVG(rating_num), 2) AS avg_rating,
       COUNT(rating_num) AS rated_restaurants
FROM swiggy_clean
GROUP BY cuisine
HAVING COUNT(rating_num) > 100
ORDER BY avg_rating DESC
LIMIT 10;

-- Q7: Top restaurants (rating 4.5+ with 1000+ ratings)
SELECT name, city, rating_num, rating_count_num, cost_num
FROM swiggy_clean
WHERE rating_num >= 4.5
  AND rating_count_num >= 1000
ORDER BY rating_num DESC, rating_count_num DESC
LIMIT 20;

-- Q8: Best value for money (high rating, low cost; more than 30 rated restaurants)
SELECT city,
       ROUND(AVG(rating_num), 2) AS avg_rating,
       ROUND(AVG(cost_num), 0) AS avg_cost,
       COUNT(rating_num) AS rated_restaurants
FROM swiggy_clean
GROUP BY city
HAVING COUNT(rating_num) > 30
ORDER BY avg_rating DESC, avg_cost ASC
LIMIT 10;
