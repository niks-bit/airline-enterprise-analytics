	-- Flight Analytics Case Study
	-- Author: Nikki Dobles
	-- Dataset: flights.csv + feedback.csv
	-- Goal: Explore airline performance and customer feedback to simulate enterprise-level insights
	
# Dataset Context
This analysis uses mock data simulating **one week of Cebu Pacific domestic operations**. It includes:
- Flight-level data: date, origin, destination, delays, distance, passengers
- Customer feedback data: satisfaction ratings, seat comfort, recommendation likelihood
	
	/* SECTION 1: Database Exploration
	
	-- 1. Show all tables
	SELECT name
	FROM sqlite_master
	WHERE type = 'table';

	--2 Preview the first few rows from each table
	SELECT *
	FROM flights
	LIMIT 5;
	
	SELECT *
	FROM feedback
	LIMIT 5;
	
	/* SECTION 2: BUSIEST ROUTES WITH MOST DELAYS
	3. To identify which routes have high flight volume and poor on-time performance
	
	-- Among the most flown routes, which ones have delay issues (high-impact)
	-- Fixing delays on the busiest routes have more impact. It doesn't necessarily mean that the busiest routes have the highest and most delays
    --A 10-min improvement on a busiest route affects thousands more customers than a low-traffic one
	
	SELECT origin, 
					destination,
					COUNT (*) AS total_flights,
					AVG(departure_delay) AS avg_departure_delay,
					AVG(arrival_delay) AS avg_arrival_delay
	FROM flights
	GROUP BY origin, destination
	ORDER BY total_flights DESC, 
	LIMIT 5;

-- INTERPRETATION
1) Total Flights (Volume): Route CEB-DVO and ZAM-MNL collectively account for 14% of all flights; considered as backbone routes
2) Among the Top 5 busiest routes, CEB-DVO and ZAM-MNL have consistent delays (averaging >= 30 mins delay time on departure and arrival); others are on a fluctuating trend
3) Might have something to do with internal inefficiencies in ground ops and boarding during departure and external factors such as air traffic and congestion during flight
-- RECOMMENDATION: conduct root-cause analysis

/* SECTION 3: DELAY IMPACT ON CX
4. To understand how delays impact passenger satisfaction
 Are delays the ones that have the highest impact on ratings and recommendations
-- Look at the correlation between delays and average rating

4.1 Combine data from flights + feedback 
-- create wide view of each flight and see corresponding passenger response

SELECT
	f.flight_id,
	f.origin,
	f.destination,
	f.departure_delay,
	f.arrival_delay,
	fb.rating,
	fb.seat_comfort,
	fb.service_quality,
	fb.would_recommend
FROM flights AS f
JOIN feedback AS fb 
ON f.flight_id = fb.flight_id;

4.2 Raw delay vs. recommendation
-- do passengers with longer delays tend to say they wouldn't recommend the airline? floor/ceiling?
-- observe behavioral patterns-- "when delays go above [n] mins, people stop recommending"

SELECT 
	f.departure_delay,
	f.arrival_delay,
	fb.would_recommend,
	COUNT (*) AS total_passengers
FROM flights AS f
JOIN feedback AS fb 
ON f.flight_id = fb.flight_id
GROUP BY f.departure_delay, f.arrival_delay, fb.would_recommend
ORDER BY f.departure_delay DESC, f.arrival_delay DESC;
	
--INTERPRETATION
1) no pattern in the intersection between departure and arrival delays-- recommendations are fluctuating
2) delays do not affect loyalty; it is not the driver of recommendations
3) service/comfort may have balanced ut the inconvenience
4) expectations may have been low on the onset
5) passengers were willing to compromise because of cheap flights??

SELECT 
	f.departure_delay,
	fb.would_recommend,
	COUNT (*) AS total_passengers
FROM flights AS f
JOIN feedback AS fb 
ON f.flight_id = fb.flight_id
GROUP BY f.departure_delay,  fb.would_recommend
ORDER BY f.departure_delay DESC

-- same observation with departure_delay

SELECT 
	f.arrival_delay,
	fb.would_recommend,
	COUNT (*) AS total_passengers
FROM flights AS f
JOIN feedback AS fb 
ON f.flight_id = fb.flight_id
GROUP BY  f.arrival_delay, fb.would_recommend
ORDER BY f.arrival_delay DESC;

-- same observation with arrival_delay

SELECT
  CASE
    WHEN arrival_delay <= 0 THEN 'On Time or Early'
    WHEN arrival_delay <= 15 THEN 'Slight Delay (1-15m)'
    WHEN arrival_delay <= 60 THEN 'Moderate Delay (16-60m)'
    ELSE 'Severe Delay (>60m)'
  END AS delay_category,
  ROUND(AVG(rating), 2) AS avg_rating,
  COUNT(*) AS num_flights
FROM flights f
JOIN feedback fb ON f.flight_id = fb.flight_id
GROUP BY delay_category
ORDER BY avg_rating ASC;

--for validation: separate rating analysis (average checking)
-- strengthens analysis; whether on-time or early/slight delay/moderate delay, average rating stayed around = 3-- even if most flights are delayed


/* SECTION 4: Route-Level Experience Perfomance
4. To understand how delays impact passenger satisfaction
-- looking at repeatable issues (routes are repeatable)
-- if something's broken at the route-level, it's sytematic and worth optimizing (e.g. airport issues, crew training)
-- why not date? not enough time-series. why not distance? correlated with route already. why not aircraft? little to no variance in per route per week data

SELECT
    f.origin,
    f.destination,
    COUNT(*) AS total_flights,
    SUM(f.passengers) AS total_passengers,
	 ROUND(AVG(f.departure_delay), 1) AS avg_departure_delay,
    ROUND(AVG(f.arrival_delay), 1) AS avg_arrival_delay,
    ROUND(AVG(fb.rating), 2) AS avg_rating,
    ROUND(AVG(fb.service_quality), 2) AS avg_service_quality,
    ROUND(AVG(fb.seat_comfort), 2) AS avg_seat_comfort,
    ROUND(
        SUM(CASE WHEN fb.would_recommend = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        1
    ) AS recommend_rate_pct
FROM flights f
JOIN feedback fb ON f.flight_id = fb.flight_id
GROUP BY f.origin, f.destination
ORDER BY total_passengers DESC

--INTERPRETATION:
1) not much variance in flights per destination MAX=7, MIN=1
2) TOP 1: ZAM-MNL at 7 total flights, 1006 total passengers; TOP 5: ZAM-DV0 at 5 total flights, 816 total passengers
3) TOP 3 routes (ZAM-MNL, CEB-DVO, DVO-CLARK) have departure=arrival delays averaging 30 mins (lowest delay is 0, highest is 60)
4) Among the top 5 busiest routes, average passenger ratings remain mediocre (2.5–3.0), while recommendation rates vary significantly — from 71.4% on the top route down to just 40% on others.
5) Among the top 5 busiest routes, ZAM–DVO stands out with only a 40% recommendation rate — despite serving over 800 passengers. While not the busiest, its low customer satisfaction makes it a strong candidate for CX improvement efforts.
6) ZAM-DVO has the same delay ave as that of the rest of the top 5, indicating delay isn't the problem (maybe pain-point specific: high-service qual, low seat confort)


## TAKEAWAY (prioritizing route frequency and passenger volume)
## We started wide — identifying high-impact routes. Then we challenged a common assumption: that delays drive dissatisfaction. Upon proving otherwise, we took a route-level lens to uncover that experience quality, not punctuality, is what drives loyalty. That led us to ZAM–DVO — a high-volume route with significant experience issues — as the most actionable opportunity.
## ZAM–DVO stands out as the only major route where poor passenger experience — not delays — is driving low loyalty, making it the clearest candidate for improvement.


	PRAGMA table_info (flights);
	PRAGMA table_info (feedback);
	