-- THE GOAL IS TO FIND OUT WHICH CATEGORIES FREQUENTLY HAVE TRENDING VIDEOS. THEN IT WILL EASY FOR ME TO FIGURE OUT WHICH CATEGORY VIDEO I CAN MAKE THAT WILL APPEAR ON TRENDING LIST OT NOT 
WITH VideoStats AS (
    SELECT
        country,
        category_title,
        RANK() OVER (PARTITION BY country, EXTRACT(YEAR FROM trending_date), EXTRACT(MONTH FROM trending_date) ORDER BY view_count DESC) AS TRENDING_CT_RK
    FROM
        table_youtube_final
    WHERE NOT 
        category_title IN ('Music', 'Entertainment') -- (EXCLUDING MUSIC AND ENTERTAINMENT)
)
SELECT
    country,
    category_title,
    COUNT(*) AS TRENDING_CT_RK
FROM
    VideoStats
WHERE
    TRENDING_CT_RK = 1
GROUP BY
    country,
    category_title
ORDER BY
    country,
    TRENDING_CT_RK DESC;

-- According to the data, I will create a YouTube channel and make a video in the Gaming category. It has a high chance of appearing in the top trend on YouTube in Brazil. However, this won't work in every country.
