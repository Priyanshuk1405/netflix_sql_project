-- Netflix Project

SELECT COUNT(*) FROM netflix;

SELECT * FROM netflix;

-- 1. Count the Number of Movies VS TV Shows.
SELECT 
	DISTINCT type, COUNT(*) as total_entries
FROM netflix
GROUP BY 1;


-- 2. Find the most common rating for movies and TV shows.
SELECT 
	type,
	rating as most_common_rating
FROM (	

	SELECT 
		type,
		rating,
		count(*),
		rank() over(partition by type order by count(*) DESC) as ranking
	FROM netflix
	group by 1,2
	-- order by 3 DESC
) as t1
WHERE ranking = 1;


-- 3. List all movies released in a specific year 2020.
SELECT * FROM netflix;

SELECT 
	type,
	title,
	release_year
FROM netflix
where type = 'Movie' AND release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix.

SELECT *
FROM
(SELECT 
	unnest(string_to_array(country,',')) as new_country,
	count(show_id) as total_content
FROM netflix
GROUP BY 1) as t1
-- WHERE new_country is NOT NULL
order by total_content DESC
limit 5;

-- SELECT 
-- unnest(string_to_array(country,',')) as new_country
-- FROM netflix;

-- 5. Identify the Longest Movie.
SELECT *
FROM netflix
WHERE type = 'Movie'
and duration = (select max(duration) from netflix);

SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


-- 6. Find Content added in last 5 years.

select * from netflix;

SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD, Year') >= CURRENT_DATE - INTERVAL '5 Years';

-- Select date_added, TO_DATE(date_added,'Month DD, Year') FROM netflix;


-- 7. Find all the movies/TV Shows by Director 'Rajiv Chilaka'.
SELECT * 
FROM 
(
	SELECT 
		*,
		unnest(string_to_array(director,',')) as director_name
	FROM netflix
) as t
WHERE director_name = 'Rajiv Chilaka';


-- 8. List All TV Shows with More Than 5 Seasons.
SELECT  *
FROM netflix
WHERE type = 'TV Show'
and split_part(duration,' ', 1) :: INT >5;

-- SELECT split_part(duration,' ', 1) :: INT >5 FROM netflix;


-- 9. Count the number of content items in each genre.
-- SELECT genre, 
-- count(*) as total_content
-- FROM
-- (select
-- 	*,
-- 	UNNEST(string_to_array(listed_in,',')) as genre
-- FROM netflix)
-- GROUP BY 1;


-- SELECT 
--     UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
--     COUNT(*) AS total_content
-- FROM netflix
-- GROUP BY 1;

SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


-- 10. Find each year and the average numbers of content release in India on netflix.

select 
	Extract(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as years,
	count(*),
	Round((count(*)::numeric/ (select count(*) from netflix where country = 'India') *100 ),2)as avg_content_release
from netflix
where country = 'India'
group by 1;



-- 11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';



-- 12. Find all content writer a director

SELECT * FROM netflix
WHERE director is NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years.

SELECT * FROM netflix
where 
	cast_team ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- SELECT * FROM netflix WHERE show_id = 's2340'	


-- 14. Find the Top 10 actors who appeared in the highest number of movies produced in INDIA.

SELECT 
	TRIM(UNNEST(string_to_array(cast_team, ','))) as actors,
	Count(*) as actors_appearance
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY actors_appearance DESC
LIMIT 10;


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
-- SELECT 
-- 	category,
-- 	count(*)
-- FROM
-- 	(SELECT
-- 		CASE
-- 		WHEN description ILIKE '%Kill%' or description ILIKE '%Violence%' THEN 'Bad'
-- 		ELSE 'Good'
-- 		END as category
-- 	FROM netflix) as t
-- GROUP BY category;	

WITH new_table as
(SELECT *,
		CASE
		WHEN description ILIKE '%Kill%' or description ILIKE '%Violence%' THEN 'Bad'
		ELSE 'Good'
		END as category
	FROM netflix) 
SELECT 
	category,
	count (*) as total_contant
FROM new_table
GROUP BY category; 

