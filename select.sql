USE pagespeed_audit;

-- ============================================================
-- 1. BASIC "SELECT ALL" QUERIES
-- ============================================================
SHOW TABLES;


SELECT * FROM categories;
SELECT * FROM overall_score;
SELECT * FROM core_web_vitals;
SELECT * FROM sub_factors;
SELECT * FROM detail_factors;
SELECT * FROM optimization_suggestions;


-- ============================================================
-- 2. CATEGORY-LEVEL QUERIES
-- ============================================================

-- All categories sorted worst to best
SELECT category_name, weight, reported_score, status
FROM categories
ORDER BY reported_score ASC;

-- Categories that need improvement
SELECT category_name, reported_score, status
FROM categories
WHERE status != 'Excellent';

-- Weighted contribution of each category to the overall score
SELECT category_name, weight, reported_score,
       ROUND(weight * reported_score, 2) AS weighted_contribution
FROM categories
ORDER BY weighted_contribution DESC;


-- ============================================================
-- 3. CORE WEB VITALS
-- ============================================================

-- Vitals that are failing
SELECT metric_name, result, status
FROM core_web_vitals
WHERE status != 'Good';


-- ============================================================
-- 4. SUB-FACTOR QUERIES
-- ============================================================

-- Sub-factors joined with their parent category name
SELECT sf.subfactor_id, c.category_name, sf.subfactor_name, sf.weight, sf.score
FROM sub_factors sf
JOIN categories c ON sf.category_id = c.category_id
ORDER BY sf.score ASC;

-- Sub-factors scoring below 100 (i.e. not perfect)
SELECT sf.subfactor_id, c.category_name, sf.subfactor_name, sf.score
FROM sub_factors sf
JOIN categories c ON sf.category_id = c.category_id
WHERE sf.score < 100
ORDER BY sf.score ASC;

-- Sub-factors belonging to a specific category (e.g. Performance)
SELECT sf.subfactor_id, sf.subfactor_name, sf.weight, sf.score
FROM sub_factors sf
JOIN categories c ON sf.category_id = c.category_id
WHERE c.category_name = 'Performance'
ORDER BY sf.score ASC;

-- Average sub-factor score per category
SELECT c.category_name, ROUND(AVG(sf.score), 2) AS avg_subfactor_score
FROM sub_factors sf
JOIN categories c ON sf.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_subfactor_score ASC;


-- ============================================================
-- 5. DETAIL FACTOR QUERIES
-- ============================================================

-- All detail factors flagged as needing a fix
SELECT df.factor_id, sf.subfactor_name, df.factor_name, df.value, df.unit,
       df.threshold, df.good_range, df.flag
FROM detail_factors df
JOIN sub_factors sf ON df.subfactor_id = sf.subfactor_id
WHERE df.flag = 'Fix';

-- Full drill-down: category -> sub-factor -> detail factor
SELECT c.category_name, sf.subfactor_name, df.factor_name,
       df.value, df.unit, df.score, df.flag
FROM detail_factors df
JOIN sub_factors sf ON df.subfactor_id = sf.subfactor_id
JOIN categories c ON sf.category_id = c.category_id
ORDER BY c.category_name, sf.subfactor_name;

-- Detail factors with a non-zero measured value (i.e. something was actually found)
SELECT df.factor_id, sf.subfactor_name, df.factor_name, df.value, df.unit, df.flag
FROM detail_factors df
JOIN sub_factors sf ON df.subfactor_id = sf.subfactor_id
WHERE df.value > 0;

-- Detail factors for a specific sub-factor (e.g. Color Contrast)
SELECT factor_name, value, unit, threshold, good_range, score, flag
FROM detail_factors
WHERE subfactor_id = 'A1';

-- Lowest-scoring detail factors overall (top 10 worst)
SELECT df.factor_id, sf.subfactor_name, df.factor_name, df.score, df.flag
FROM detail_factors df
JOIN sub_factors sf ON df.subfactor_id = sf.subfactor_id
ORDER BY df.score ASC
LIMIT 10;


-- ============================================================
-- 6. OPTIMIZATION SUGGESTIONS
-- ============================================================

-- All suggestions ordered by priority (High first)
SELECT suggestion_id, subfactor_id, problem, recommendation, est_score_gain, priority
FROM optimization_suggestions
ORDER BY FIELD(priority, 'High', 'Medium', 'Low');

-- High-priority suggestions only
SELECT suggestion_id, problem, recommendation, est_score_gain
FROM optimization_suggestions
WHERE priority = 'High';

-- Suggestions joined with sub-factor and category context
SELECT c.category_name, sf.subfactor_name, os.problem, os.recommendation,
       os.est_score_gain, os.priority
FROM optimization_suggestions os
JOIN sub_factors sf ON os.subfactor_id = sf.subfactor_id
JOIN categories c ON sf.category_id = c.category_id
ORDER BY os.est_score_gain DESC;

-- Total potential score gain if all suggestions were implemented
SELECT SUM(est_score_gain) AS total_potential_gain
FROM optimization_suggestions;

-- Suggestions with an actual measurable score gain (ignore 0-gain maintenance items)
SELECT suggestion_id, problem, recommendation, est_score_gain, priority
FROM optimization_suggestions
WHERE est_score_gain > 0
ORDER BY est_score_gain DESC;


-- ============================================================
-- 7. CROSS-TABLE SUMMARY / DASHBOARD-STYLE QUERIES
-- ============================================================

-- Full audit summary: category, weight, score, status, and count of "Fix" items under it
SELECT c.category_name, c.weight, c.reported_score, c.status,
       COUNT(CASE WHEN df.flag = 'Fix' THEN 1 END) AS fix_count
FROM categories c
LEFT JOIN sub_factors sf ON sf.category_id = c.category_id
LEFT JOIN detail_factors df ON df.subfactor_id = sf.subfactor_id
GROUP BY c.category_id, c.category_name, c.weight, c.reported_score, c.status
ORDER BY c.reported_score ASC;

-- Everything related to Performance in one view (category -> subfactor -> detail -> suggestion)
SELECT c.category_name, sf.subfactor_name, df.factor_name, df.flag,
       os.recommendation, os.priority
FROM categories c
JOIN sub_factors sf ON sf.category_id = c.category_id
LEFT JOIN detail_factors df ON df.subfactor_id = sf.subfactor_id
LEFT JOIN optimization_suggestions os ON os.subfactor_id = sf.subfactor_id
WHERE c.category_name = 'Performance'
ORDER BY sf.subfactor_name;