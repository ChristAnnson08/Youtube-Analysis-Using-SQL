--1. What are the 3 most viewed videos for each country in the “Gaming” category for the trending_date = ‘'2024-04-01'’. Order the result by country and the rank

SELECT country, title, channel_title, view_count, RANK() OVER (PARTITION BY country ORDER BY view_count DESC) AS RK
FROM
    table_youtube_final
WHERE
    category_title = 'Gaming'
    AND trending_date = '2024-04-01'
QUALIFY
    RK <= 3
ORDER BY
    country,
    RK;
    
--2.For each country, count the number of distinct video with a title containing the word “BTS” and order the result by count in a descending order

SELECT country, COUNT(DISTINCT VIDEO_ID) AS Number_Count
FROM table_youtube_final
WHERE title LIKE '%BTS%'
GROUP BY country
ORDER BY Number_Count DESC;

--3.	For each country, year and month (in a single column), which video is the most viewed and what is its likes_ratio (defined as the percentage of likes against view_count) truncated to 2 decimals. Order the result by year_month and country. 

WITH VideoStats AS (
    SELECT
        country,
        EXTRACT(YEAR FROM trending_date) AS year,
        EXTRACT(MONTH FROM trending_date) AS month,
        video_id,
        title,
        channel_title,
        category_title,
        view_count,
        likes,
        dislikes,
        CASE
            WHEN view_count = 0 THEN 0
            ELSE ROUND((likes::NUMERIC / view_count) * 100, 2)
        END AS likes_ratio,
        RANK() OVER (PARTITION BY country, EXTRACT(YEAR FROM trending_date), EXTRACT(MONTH FROM trending_date) ORDER BY view_count DESC) AS video_rank
    FROM
        table_youtube_final
)
SELECT
    country,
    TO_DATE(year || '-' || TO_CHAR(month, 'FM00') || '-01', 'YYYY-MM-DD') AS year_month,
    title,
    channel_title AS CHANNELTITLE,
    category_title,
    view_count,
    likes_ratio
FROM
    VideoStats
WHERE
    video_rank = 1
    AND year = 2024
ORDER BY
    year_month,
    country;
    
-- 4.For each country, which category_title has the most distinct videos and what is its percentage (12 decimals) out of the total distinct number of videos of that country? Only look at the data from before 2022. Order the result by category_title and country

WITH VideoCategories AS (
    SELECT
        country,
        category_title,
        COUNT(DISTINCT video_id) AS total_category_video
    FROM
        table_youtube_final
    WHERE
        EXTRACT(YEAR FROM trending_date) >= 2022  
    GROUP BY
        country,
        category_title
),
TotalCountryVideos AS (
    SELECT
        country,
        COUNT(DISTINCT video_id) AS total_country_video
    FROM
        table_youtube_final
    WHERE
        EXTRACT(YEAR FROM trending_date) >= 2022  
    GROUP BY
        country
)
SELECT
    vc.country AS COUNTRY,
    vc.category_title AS CATEGORY_TITLE,
    vc.total_category_video AS TOTAL_CATEGORY_VIDEO,
    tc.total_country_video AS TOTAL_COUNTRY_VIDEO,
    ROUND((vc.total_category_video::NUMERIC / tc.total_country_video) * 100, 2) AS PERCENTAGE  
FROM
    VideoCategories vc
JOIN
    TotalCountryVideos tc
ON
    vc.country = tc.country
WHERE
    (vc.country, vc.total_category_video) IN (
        SELECT
            country,
            MAX(total_category_video)
        FROM
            VideoCategories
        GROUP BY
            country
    )
ORDER BY
    vc.category_title,
    vc.country;  
--5.	Which channeltitle has produced the most distinct videos and what is this number? 
WITH ChannelVideoCounts AS (
    SELECT
        channel_title,
        COUNT(DISTINCT video_id) AS distinct_video_count
    FROM
        table_youtube_final
    GROUP BY
        channel_title
)
SELECT
    channel_title,
    distinct_video_count
FROM
    ChannelVideoCounts
WHERE
    distinct_video_count = (SELECT MAX(distinct_video_count) FROM ChannelVideoCounts);