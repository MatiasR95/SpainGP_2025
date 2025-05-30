/*Report-Ready Tasks
Task F6: Argentinian Driver Performance
Description: Summarize Argentinian races, wins, points, best finish.*/
SELECT
	d.forename + ' ' + d.surname AS Driver,
	COUNT(r.raceid) AS TotalRacesAtSpain,
	SUM(r.points) AS TotalPoints,
	MIN(r.positionorder) AS BestFinish
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4  AND d.nationality IN ('Argentine')
GROUP BY d.forename + ' ' + d.surname;

/*Task F7: Points Probability by Grid (2014–2024)
Description: Calculate points likelihood from grid position.*/
WITH TotalPointsRaces AS
(SELECT
	r.grid AS GridPosition,
	SUM(CASE WHEN r.positionorder <= 10 THEN 1 ELSE 0 END) AS PointsRaces,
	COUNT(DISTINCT r.raceId) AS TotalRaces
FROM results r
JOIN races ra ON ra.raceId = r.raceId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0
GROUP BY r.grid)
SELECT
	GridPosition,
	PointsRaces,
	ROUND((CAST(PointsRaces AS FLOAT) / TotalRaces) * 100,2) AS PointsProbability
FROM TotalPointsRaces;

/*Task F8: Position Gain Probability (2014–2024)
Description: Assess overtaking odds by grid (top 10).*/
WITH PositionStats AS (
	SELECT
		r.grid,
		COUNT(r.raceId) AS TotalRaces,
		SUM(CASE WHEN r.grid > r.positionOrder THEN 1 ELSE 0 END) AS RacesWithPositionGain,
		AVG(CAST(r.grid AS FLOAT) - CAST(r.positionOrder AS FLOAT)) AS AvgPositionGain
	FROM results r
	JOIN races ra ON ra.raceId = r.raceId
	WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0 AND r.positionOrder > 0
	GROUP BY r.grid
)
SELECT
	grid AS GridPosition,
	ROUND((CAST(RacesWithPositionGain AS FLOAT) / TotalRaces) * 100, 2) AS GainProbability,
	ROUND(AvgPositionGain, 1) AS AvgPositionGain
FROM PositionStats
WHERE grid <= 20
ORDER BY grid ASC;

/*Task F9: Top Qualifying Constructors (2014–2024)
Description: Count top-10 qualifying entries (Q3 appearances) by constructor in the hybrid era.*/
SELECT
	c.name AS Constructor,
	SUM(CASE WHEN q.q3 NOT IN ('\N') THEN 1 ELSE 0 END) AS Top10Count
FROM qualifying q
JOIN races ra ON ra.raceId = q.raceId
JOIN constructors c ON c.constructorId = q.constructorId
WHERE ra.circuitId = 4 AND ra.year >= 2014
GROUP BY c.name
ORDER BY Top10Count DESC;

/*Task F10: Pole-to-Win Conversion Rate (2014–2024)
Description: Calculate the percentage of pole positions converting to race wins in the hybrid era.*/
WITH WinsFromPoles AS
(SELECT
	SUM(CASE WHEN q.position = 1 AND r.positionorder = 1 THEN 1 ELSE 0 END) AS WinsFromPole,
	SUM(CASE WHEN q.position = 1 THEN 1 ELSE 0 END) AS TotalPoles
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN qualifying q ON q.raceId = r.raceId AND q.constructorId = r.constructorId AND q.driverId = r.driverId
WHERE ra.circuitId = 4 AND ra.year >= 2014)
SELECT
	*,
	ROUND((CAST(WinsFromPole AS FLOAT) / TotalPoles) * 100,2) AS ConversionRate
FROM WinsFromPoles;
