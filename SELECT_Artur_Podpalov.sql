--1
WITH RankedStaff AS (
    SELECT
        s.store_id,
        st.first_name,
        st.last_name,
        SUM(p.amount) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS rank
    FROM
        store s
    JOIN
        staff st ON s.store_id = st.store_id
    JOIN
        payment p ON st.staff_id = p.staff_id
    JOIN
        rental r ON p.rental_id = r.rental_id
    WHERE
        EXTRACT(YEAR FROM r.rental_date) = 2017
    GROUP BY
        s.store_id, st.first_name, st.last_name
)
SELECT
    store_id,
    first_name,
    last_name,
    total_revenue
FROM
    RankedStaff
WHERE
    rank = 1
ORDER BY
    total_revenue DESC, store_id;
   
--2
WITH TopMovies AS (
    SELECT
        f.film_id,
        f.title,
        f.rating,
        COUNT(*) AS rental_count
    FROM
        film f
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id, f.title, f.rating
    ORDER BY
        rental_count DESC
    LIMIT 5
)
SELECT
    tm.title,
    tm.rating,
    tm.rental_count
    
FROM
    TopMovies tm
ORDER BY
    rental_count DESC;

--3

WITH ActorFilmYears AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        f.release_year,
        LAG(f.release_year) OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS prev_film_release_year
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    JOIN
        film f ON fa.film_id = f.film_id
)
SELECT
    afy.actor_id,
    afy.first_name,
    afy.last_name,
    MAX(afy.release_year) AS last_film_release_year,
    MAX(afy.release_year) - MAX(afy.prev_film_release_year) AS years_since_last_film
FROM
    ActorFilmYears afy
GROUP BY
    afy.actor_id, afy.first_name, afy.last_name
ORDER BY
    years_since_last_film DESC;

   
--1
WITH RankedStaff AS (
    SELECT
        s.store_id,
        st.staff_id,
        st.first_name,
        st.last_name,
        SUM(p.amount) AS total_revenue
    FROM
        store s
    JOIN
        staff st ON s.store_id = st.store_id
    JOIN
        payment p ON st.staff_id = p.staff_id
    JOIN
        rental r ON p.rental_id = r.rental_id
    WHERE
        EXTRACT(YEAR FROM r.rental_date) = 2017
    GROUP BY
        s.store_id, st.staff_id, st.first_name, st.last_name
)
SELECT
    sr.store_id,
    sr.first_name,
    sr.last_name,
    sr.total_revenue
FROM
    StaffRevenue sr
JOIN (
    SELECT
        store_id,
        MAX(total_revenue) AS max_revenue
    FROM
        StaffRevenue
    GROUP BY
        store_id
) max_revenue ON sr.store_id = max_revenue.store_id AND sr.total_revenue = max_revenue.max_revenue
ORDER BY
    sr.total_revenue DESC, sr.store_id;


   --2
WITH MovieRanks AS (
    SELECT
        f.title,
        f.rating,
        COUNT(*) AS rental_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM
        film f
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        f.title, f.rating
)
SELECT
    mr.title,
    mr.rating,
    mr.rental_count
FROM
    MovieRanks mr
WHERE
    mr.rank <= 5
ORDER BY
    mr.rental_count DESC;

--3
WITH ActorFilmYears AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        f.release_year,
        LAG(f.release_year) OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS prev_film_release_year
    FROM
        actor a
    JOIN
        film_actor fa ON a.actor_id = fa.actor_id
    JOIN
        film f ON fa.film_id = f.film_id
)
SELECT
    actor_id,
    first_name,
    last_name,
    MAX(release_year) AS last_film_release_year,
    MAX(release_year) - COALESCE(MAX(prev_film_release_year), MAX(release_year)) AS years_since_last_film
FROM
    ActorFilmYears
GROUP BY
    actor_id, first_name, last_name
ORDER BY
    years_since_last_film DESC;

   

