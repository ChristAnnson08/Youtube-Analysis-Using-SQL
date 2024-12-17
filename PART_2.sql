-- 1: In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?

SELECT CATEGORY_TITLE FROM table_youtube_category
GROUP BY CATEGORY_TITLE
HAVING 
    COUNT(DISTINCT CATEGORYID) > 1
LIMIT 1;

-- 2: In “table_youtube_category” which category_title only appears in one country?

SELECT 
    CATEGORY_TITLE
FROM 
    table_youtube_category
GROUP BY 
    CATEGORY_TITLE
HAVING 
    COUNT(DISTINCT COUNTRY) = 1;
    
--  3: In “table_youtube_final”, what is the categoryid of the missing category_titles?

SELECT  CATEGORY_ID 
FROM table_youtube_final
WHERE CATEGORY_TITLE IS NULL ;

--4.Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question.

UPDATE table_youtube_final
SET category_title = (
    SELECT CATEGORY_TITLE FROM table_youtube_category
    GROUP BY CATEGORY_TITLE
    HAVING COUNT(DISTINCT COUNTRY)=1
)
WHERE category_title IS NULL;

--5: In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)? 

SELECT TITLE
FROM table_youtube_final
WHERE CHANNEL_TITLE IS NULL;

--6:Delete from “table_youtube_final“, any record with video_id = “#NAME?”

DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';

--7.Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates by using the row_number() function

CREATE OR REPLACE TABLE table_youtube_duplicates AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY video_id, country, trending_date ORDER BY view_count desc) AS row_num
    FROM table_youtube_final
) AS duplicates
WHERE row_num > 1;

select*from table_youtube_duplicates;

--8  Delete records from table_youtube_final that are found in table_youtube_duplicates

DELETE FROM table_youtube_final 
WHERE id IN (
    SELECT id 
    FROM table_youtube_duplicates);

--9 .Count the number of rows in “table_youtube_final“ and check that it is equal to 2,597,494 rows. rows.

SELECT COUNT(*)
FROM table_youtube_final;