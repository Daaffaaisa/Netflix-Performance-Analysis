/*
====================================================================
PROJECT     : Netflix Content Strategy & Localization ROI
AUTHOR      : Daffa Kumara
DESCRIPTION : PostgreSQL queries for Exploratory Data Analysis (EDA)
              targeting market gaps, duration performance, and 
              localization efficiency.
====================================================================
*/

-- -----------------------------------------------------------------
-- EXPERIMENT 1: Genre Market Gap Analysis
-- Objective: Identify niche genres with high ratings but low supply
-- -----------------------------------------------------------------
SELECT
    genre_tunggal,
    COUNT(*) AS total_produksi,
    ROUND(AVG(rating::numeric), 2) AS rata_rating,
    SUM(vote::int) AS total_engagement
FROM netflix_shows
GROUP BY genre_tunggal
ORDER BY rata_rating DESC;


-- -----------------------------------------------------------------
-- EXPERIMENT 2: Duration Categories & Attention Span Test
-- Objective: Test audience engagement on long-form content (>2 hours)
-- -----------------------------------------------------------------
SELECT
    CASE
        WHEN duration < 60 THEN 'Sangat Pendek (<1 Jam)'
        WHEN duration BETWEEN 60 AND 120 THEN 'Standar (1-2 Jam)'
        ELSE 'Panjang (>2 Jam)'
    END AS kategori_durasi,
    COUNT(*) AS jumlah_konten,
    ROUND(AVG(rating::numeric), 2) AS rata_rata_rating,
    ROUND(AVG(vote::int), 0) AS rata_rata_vote
FROM netflix_shows
WHERE duration IS NOT NULL
GROUP BY 1
ORDER BY rata_rata_rating DESC;


-- -----------------------------------------------------------------
-- EXPERIMENT 3: Localization Efficiency (Non-US Markets)
-- Objective: Rank countries by quality-to-quantity ratio (Post-2010)
-- -----------------------------------------------------------------
SELECT
    country,
    COUNT(*) AS jumlah_konten,
    ROUND(AVG(rating::numeric), 2) AS rata_rata_rating,
    SUM(vote::int) AS total_daya_tarik
FROM netflix_shows
WHERE country <> 'Unknown'
    AND country <> 'United States'
    AND year >= 2010
    AND rating IS NOT NULL
GROUP BY country
HAVING COUNT(*) >= 10
ORDER BY rata_rata_rating DESC, total_daya_tarik DESC
LIMIT 5;
