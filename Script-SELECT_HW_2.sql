
--домашняя работа 07.03.23
--1.Количество исполнителей в каждом жанре
SELECT name_genre AS Жанр, COUNT(artist_id) AS Исполнителей
  FROM genre g 
  	   JOIN genre_artist ga USING (genre_id)
 GROUP BY Жанр
;

--2.Количество треков, вошедших в альбомы 2019–2020 годов.
SELECT COUNT(track_id) AS Количество_треков_2019_2020
  FROM track t
  	   JOIN album a USING (album_id)
 WHERE year_album IN (2019, 2020)
; 
 
 --3.Средняя продолжительность треков по каждому альбому.
SELECT title_album AS Альбом, 
		CASE 
			WHEN AVG(time_track) IS NULL THEN 'нет треков'
			ELSE 
				 CONCAT(FLOOR(AVG(time_track) / 60), 
				   		CASE
				   		  	WHEN ROUND(AVG(time_track) - FLOOR(AVG(time_track) / 60) * 60, 0) < 10 THEN ':0'
				   		  	ELSE ':'
				   		END,
				   		ROUND(AVG(time_track) - FLOOR(AVG(time_track) / 60) * 60, 0))		
		END  AS Средняя_длительность_трека		  		  	   		  
  FROM album a 
  	   LEFT JOIN track t USING (album_id)
 GROUP BY title_album 
 ORDER BY title_album 
;

--4.Все исполнители, которые не выпустили альбомы в 2020 году. - вариант 1
WITH alb2020 (ar_id) AS
	 (SELECT artist_id, name_artist, year_album
	    FROM artist a 
			 LEFT JOIN album_artist aa USING (artist_id)
			  	       LEFT JOIN album a2 USING (album_id)
	   WHERE year_album = 2020)
SELECT a.name_artist AS Исполнители
  FROM artist a 
	   LEFT JOIN alb2020 ON a.artist_id = ar_id 
 WHERE year_album IS NULL
 ORDER BY Исполнители 
;
--4.Все исполнители, которые не выпустили альбомы в 2020 году. - вариант 2	
SELECT DISTINCT name_artist  AS Исполнители  
  FROM artist a3 
 WHERE artist_id NOT IN
	   (SELECT artist_id
		  FROM artist a 
			   LEFT JOIN album_artist aa USING (artist_id)
			  	   		 LEFT JOIN album a2 USING (album_id)
		 WHERE year_album = 2020)
 ORDER BY Исполнители 			
;			
  	   
--5.Названия сборников, в которых присутствует конкретный исполнитель - Deep Purple.
 SELECT DISTINCT title_compilation AS Сборник
   FROM compilation c 
 		JOIN compilation_track ct USING (compilation_id)
 			 JOIN track t USING (track_id)
 				  JOIN album a USING (album_id)
 					   JOIN album_artist aa USING (album_id)
 							JOIN artist a2 USING (artist_id)
  WHERE name_artist = 'Deep Purple'
;


--6.Названия альбомов, в которых присутствуют исполнители более чем одного жанра.
--разъяснение от Елены Максимовой: В этой задаче имелись в виду сборники с участием нескольких исполнителей.
--переформулируем условие: Названия СБОРНИКОВ, в которых присутствуют исполнители более чем одного жанра.
SELECT DISTINCT title_compilation AS Сборник
  FROM compilation c 
 	   JOIN compilation_track ct USING (compilation_id)
 			JOIN track t USING (track_id)
 				 JOIN album a USING (album_id)
 					  JOIN album_artist aa USING (album_id)
 						   JOIN artist a2 USING (artist_id)
 						   		JOIN genre_artist ga USING (artist_id)
 						   			 JOIN genre USING (genre_id)
 GROUP BY title_compilation  
HAVING MAX(genre_id) <> MIN(genre_id) 
;
-- в этот запрос попадают сборники от одного исполнителя Queen и Frank Sinatra, т.к. оба
--эти исполнителя приндлежат двум жанрам, что видно из следующего запроса:
SELECT name_artist, name_genre
  FROM artist a 
	   JOIN genre_artist ga USING (artist_id)
			JOIN genre g USING (genre_id)
;			
			
--6.Названия СБОРНИКОВ, с участием нескольких исполнителей.
SELECT DISTINCT title_compilation AS Сборник, COUNT(DISTINCT name_artist) AS Количество_исполнителей
  FROM compilation c 
 	   JOIN compilation_track ct USING (compilation_id)
 			JOIN track t USING (track_id)
 				 JOIN album a USING (album_id)
 					  JOIN album_artist aa USING (album_id)
 						   JOIN artist a2 USING (artist_id)
 						   		JOIN genre_artist ga USING (artist_id)
 						   			 JOIN genre USING (genre_id)
 GROUP BY title_compilation  
HAVING COUNT(DISTINCT name_artist) <> 1
;

--7.Наименования треков, которые не входят в сборники.
SELECT title_track AS Трек
  FROM track t 
WHERE track_id NOT IN (SELECT track_id 
						 FROM compilation_track) 	   		
;  	   		

--8.Исполнитель или исполнители, написавшие самый короткий по продолжительности трек, — теоретически таких треков может быть несколько.
SELECT title_track AS Трек, name_artist AS Исполнитель
  FROM track t
	   JOIN album a USING (album_id)
			JOIN album_artist aa USING (album_id)
				 JOIN artist a2 USING (artist_id)
 WHERE time_track = (SELECT MIN(time_track) 
					   FROM track) 
;

--9.Названия альбомов, содержащих наименьшее количество треков.
--в запрос не попадают альбомы, у которых нет треков, если надо их учитывать, то 
--условие HAVING надо изменить: HAVING COUNT(track_id) <= (... 
SELECT title_album AS Альбом, COUNT(track_id) AS Количество_треков
  FROM track t
	   RIGHT JOIN album a USING (album_id)
 GROUP BY title_album 
HAVING COUNT(track_id) = (
			SELECT COUNT(track_id) AS num 
			  FROM track
			 GROUP BY album_id
			 ORDER BY num
			 LIMIT 1
			)
;

