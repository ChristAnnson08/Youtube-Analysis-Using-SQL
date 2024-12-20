## PROJECT OVERVIEW ##

For this project, I used Snowflake's Data Lakehouse architecture to analyse YouTube trending and category data across multiple countries, including the United States, Great Britain, Germany, Canada, France, Brazil, Mexico, South Korea, Japan, and India. The dataset included trending video data in CSV format and category information in JSON format. The trending data captured key details such as video titles, channel names, view counts, likes, dislikes, comments, and trending dates, offering insights into popular content and viewing habits across different regions. The category data provided a comprehensive classification of content, with titles and unique IDs for various video formats.
The dataset was initially uploaded to Azure cloud storage and then ingested as external tables into Snowflake. I transformed this data into structured internal tables, ensuring correct data types and integrity. Trending and category data were merged using unique identifiers generated with the UUID_STRING() method to create the final table. Data cleaning involved handling duplicates, filling missing values, and ensuring consistency. The analysis focused on identifying top-performing content by region, examining trends in video popularity, and analyzing category preferences over time. This approach offered valuable insights into global digital content consumption trends and highlighted opportunities for optimizing YouTube content strategy.


## ******* READ README.PDF FILE ********* ##

