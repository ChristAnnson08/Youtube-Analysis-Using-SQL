/* Creating a DataBase called Assignment1 */

CREATE OR REPLACE DATABASE assignment_1;
USE DATABASE assignment_1;

--Creating a Stage Called stage_assignment, pointing to Azure storage 

CREATE OR REPLACE STAGE stage_assignment
URL='azure://bdas1.blob.core.windows.net/bd-as-1'
CREDENTIALS=(AZURE_SAS_TOKEN='?sv=2022-11-02&ss=b&srt=co&sp=rwdlaciytfx&se=2024-12-30T14:19:42Z&st=2024-08-28T07:19:42Z&spr=https&sig=Fq9YilGA6fq18X2w9dnJJoAiTn732LYAvqGOmPrpmP4%3D')
;

/* this above query directly take files from the azure storege by using the url and the token */


LIST@stage_assignment; --listing the file from the stage

--Going to insert all youtube trending data into ex_table_youtube_trending

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=CSV);
SELECT*
FROM assignment_1.public.ex_table_youtube_trending; --lets view the data

--we going to mention all the values as varchar this will help us to identify the title easily 

SELECT
value:c1::VARCHAR,
value:c2::varchar,
value:c3::varchar,
value:c4::varchar,
value:c5::varchar,
value:c6::varchar,
value:c7::varchar,
value:c8::varchar,
value:c9::varchar,
value:c10::varchar,
value:c11::varchar
FROM assignment_1.public.ex_table_youtube_trending
LIMIT 1
;
--WE going to create a file format skipping the header, adding delimeters and type as csv to create a external table 
CREATE OR REPLACE FILE FORMAT file_format_csv
TYPE = 'CSV'
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('\\N', 'NULL', 'NUL', '')
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

--Created a external table using the file format we created 

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '[A-Z]{2}_youtube_trending_data.csv'; -- patten will help us to bring all the csv file from the storage.

--Going to mention all the header manually 
SELECT
value:c1::varchar as VIDEOID,
value:c2::varchar as TITLE,
value:c3::varchar as PUBLISHEDAT,
value:c4::varchar as CHANNELID,
value:c5::varchar as CHANNELTITLE,
value:c6::varchar as CATEGORYID,
value:c7::varchar as TRENDINGDATE,
value:c8::varchar as VIEWCOUNT,
value:c9::varchar as LIKES,
value:c10::varchar as DISLIKES,
value:c11::varchar as COMMENTCOUNT
FROM assignment_1.public.ex_table_youtube_trending;
SELECT*
FROM ex_table_youtube_trending;

--As We Entered the header maually, we going to correct the data type for each column manually 

CREATE OR REPLACE  EXTERNAL TABLE ex_table_youtube_trending 
(
Videoid STRING as (value:c1::STRING),
TITLE STRING as (value:c2::STRING),
PUBLISHEDAT DATE as (value:c3::DATE),
CHANNELID STRING as (value:c4::STRING),
CHANNELTITLE STRING as (value:c5::STRING),
CATEGORYID INT as (value:c6::INT),
TRENDING_DATE DATE as (value:c7::DATE),
VIEW_COUNT INT as (value:c8::INT),
LIKES INT as (value:c9::INT),
DISLIKES INT as (value:c10::INT),
COMMENT_COUNT INT as (value:c11::INT),
COUNTRY STRING AS SUBSTRING(METADATA$FILENAME, 1, 2)
)
WITH LOCATION = @stage_assignment
FILE_FORMAT = file_format_csv
PATTERN = '[A-Z]{2}_youtube_trending_data.csv';;
SELECT *
FROM ex_table_youtube_trending;

/* Going to create a table name table youtube trending and transfer data from external table into this table youtube trending table */

CREATE OR REPLACE TABLE table_youtube_trending AS
SELECT *
FROM ex_table_youtube_trending
;
SELECT*
FROM table_youtube_trending;

--WE CANNOT ALTER A EXTERNAL TABLE BUT WE CAN ALTER A TABLE SO WE GOING TO DROP THE COLUMN VALUE, WE DO NOT HAVE ANY USE FROM IT 

ALTER TABLE table_youtube_trending DROP COLUMN VALUE ;
SELECT*
FROM table_youtube_trending;

/* FOR JSON FILE */

--Going to move all the data  into a external table 

CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category 
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE=JSON)
PATTERN = '.*_category_id[.]json';

SELECT*
FROM ex_table_youtube_category LIMIT 1 ;

-- QUERY TO VIEW THW FILE NAMES 

SELECT
metadata$filename
FROM ex_table_youtube_category;

-- USING SPLIT PART TO EXTRACT THE COUNTRY NAME FROM THE FILE NAME 

SELECT
split_part(metadata$filename,'_',1)as country
FROM ex_table_youtube_category;

-- QUERY TO MOVE DATA FROM EXTERNAL TABLE TO A TABLE NAME TABLE_YOUTUBE_CATEGORY

CREATE OR REPLACE TABLE table_youtube_category AS
SELECT 
  split_part(metadata$filename,'_',1)as country,
  l.value:id::string as CATEGORYID,
  l.value:snippet:title::string as CATEGORY_TITLE
FROM ex_table_youtube_category, LATERAL FLATTEN(value:items) l;

SELECT*FROM table_youtube_category;

--QUERY TO COMBINE BOTH TRENDING TABLE AND CATEGORY TABLE INTO A SINGLE TABLE NAME table_youtube_final
-- INSTEAD OF MERGE WE GONNA USE JOIN FUNCTION, IT ALLOW US TO COMBINE THE TABLE EVEN WE DONT HAVE EQUAL NUMBER OF COLUMNS IN BOTH TABLES BASED ON A CONDITION 
-- GONNA CREATE A NEW COLUMN IN A THE TABLE NAME ID, AND WE GONNA USE UUID TO POPULATE THE COLUMN 

CREATE OR REPLACE TABLE table_youtube_final AS
SELECT 
    UUID_STRING() AS id, --UUID_STRING() function is executed for each row in the table, generating a distinct UUID for each row
    t.Videoid AS VIDEO_ID,
    t.TITLE AS TITLE,
    t.PUBLISHEDAT AS PUBLISHEDATE,
    t.CHANNELID AS CHANNEL_ID,
    t.CHANNELTITLE AS CHANNEL_TITLE,
    t.CATEGORYID AS CATEGORY_ID,
    c.CATEGORY_TITLE AS CATEGORY_TITLE,
    t.TRENDING_DATE AS TRENDING_DATE,
    t.VIEW_COUNT AS VIEW_COUNT,
    t.LIKES AS LIKES,
    t.DISLIKES AS DISLIKES,
    t.COMMENT_COUNT AS COMMENT_COUNT,
    t.COUNTRY AS COUNTRY
FROM table_youtube_trending t
LEFT JOIN table_youtube_category c
    ON t.COUNTRY = c.COUNTRY AND t.CATEGORYID = c.CATEGORYID;

SELECT*FROM table_youtube_final;

--ROW COUNT 
SELECT COUNT(*)
FROM table_youtube_final;









