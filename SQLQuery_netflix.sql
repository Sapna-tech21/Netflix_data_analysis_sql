USE NetflixDB;

-- Count the number of Movies vs TV Shows.
SELECT * FROM netflix_titles;

SELECT type, COUNT(*) AS Total_M_TS
FROM netflix_titles
GROUP BY type;

-- Find the most common rating for movies and TV shows

WITH RatingCount AS (
SELECT type,rating, COUNT(*) AS Rating_count
FROM netflix_titles
GROUP BY type, rating
),
RatingRank AS (
SELECT type, rating, Rating_count,
RANK() OVER (PARTITION BY type ORDER BY Rating_count DESC) AS Ranks
FROM RatingCount
)
SELECT
type,
rating AS Frequent_rating
FROM RatingRank
WHERE Ranks = 1;


-- List all movies released in a specific year (e.g., 2021)

SELECT release_year, COUNT(*) AS Total_Movie_Release_2021 FROM netflix_titles
WHERE release_year IN (2021,2020,2019)
GROUP BY release_year;

-- Find the top 5 countries with the most content on Netflix

SELECT TOP 5
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;


-- Identify the top 5 longest movie
SELECT TOP 5 title, duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;

-- -- Identify the top 5 longest TV Shows

SELECT TOP 5 title, duration
FROM netflix_titles
WHERE type = 'TV Show'
ORDER BY CAST(LEFT(duration,CHARINDEX(' ',duration) - 1) AS INT) DESC;

-- Find content added in the last 7 years

SELECT *
FROM netflix_titles
WHERE TRY_CONVERT(DATE, date_added) >= DATEADD(YEAR, -7, GETDATE());

-- Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT COUNT(*) AS Director_movie
FROM netflix_titles
CROSS APPLY STRING_SPLIT(director, ',') AS Director_Name
WHERE TRIM(Director_Name.value) = 'Rajiv Chilaka';

-- List all TV shows with more than 5 seasons

SELECT COUNT(*) AS TVShow_more_than5_seasons
FROM netflix_titles
WHERE type = 'TV Show'
AND
CAST(LEFT(duration,CHARINDEX(' ',duration) - 1) AS INT) >5;

-- Count the top 10 number of content items in each genre

SELECT TOP 10
TRIM(value) AS Genre,
COUNT(*) AS Total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in,',')
GROUP BY TRIM(value)
ORDER BY Total_content DESC;

-- Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT TOP 5
country, release_year,
COUNT(show_id) AS Total_release,
ROUND( CAST(COUNT(show_id) AS DECIMAL(10,2))/
    CAST(
        (SELECT COUNT(show_id) 
         FROM netflix_titles
         WHERE country = 'India') AS DECIMAL(10,2))* 100,2) AS avg_release
FROM netflix_titles
WHERE country = 'India'
GROUP BY Country,release_year
ORDER BY avg_release desc;


-- List all movies that are documentaries

SELECT COUNT(*) AS Number_Of_Document
FROM netflix_titles
WHERE listed_in LIKE '%Documentaries';

-- Find all content without a director

SELECT * FROM netflix_titles
WHERE director IS NULL;

-- Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix_titles
WHERE cast Like '%salman khan%'
AND release_year > YEAR(GETDATE()) - 10;

-- Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10
    TRIM(s.value) AS Actor,
    COUNT(*) AS Total_Shows
FROM netflix_titles
CROSS APPLY STRING_SPLIT([cast], ',') AS s
WHERE country = 'India'
GROUP BY TRIM(s.value)
ORDER BY Total_Shows DESC;

-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN description LIKE '%kill%' 
                 OR description LIKE '%violence%' 
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category, type
ORDER BY type;

