/*Step 2: Historical Preview
Objective: Analyze Spanish GP history (1991–2024) for journalists and team directors.
Task H1: Race Winners by Year
Description: List winners with year, driver name, and constructor.*/
SELECT
	ra.year AS Season,
	d.forename + ' ' + d.surname AS Driver,
	c.name AS Constructor
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
JOIN constructors c ON c.constructorId = r.constructorId
WHERE ra.circuitId = 4 AND r.positionOrder = 1
ORDER BY Season ASC;

/*Task H2: Qualifying Pole Counts
Description: Count poles per driver (2003–2024).*/
SELECT
	d.forename + ' ' + d.surname AS Driver,
	COUNT(*) AS TotalPoles
FROM qualifying q
JOIN drivers d ON d.driverId = q.driverId
JOIN races ra ON ra.raceId = q.raceId 
JOIN circuits c ON ra.circuitId = c.circuitId
WHERE c.circuitId = 4 AND q.position = 1 AND ra.year BETWEEN 2003 AND 2024
GROUP BY d.forename + ' ' + d.surname
ORDER BY TotalPoles DESC;

/*Task H3: Constructor Wins by Decade*/
SELECT
	c.name AS CONSTRUCTOR,
	CASE WHEN ra.year BETWEEN 1990 AND 1999 THEN '90s'
		WHEN ra.year BETWEEN 2000 AND 2009 THEN '00s'
		WHEN ra.year BETWEEN 2010 AND 2019 THEN '10s'
		ELSE '20s' END AS Decade,
	SUM(CASE WHEN r.positionOrder = 1 THEN 1 ELSE 0 END) AS TotalWins
FROM races ra
JOIN results r ON ra.raceId = r.raceId
JOIN constructors c ON c.constructorId = r.constructorId
WHERE ra.circuitId = 4
GROUP BY c.name, CASE WHEN ra.year BETWEEN 1990 AND 1999 THEN '90s'
		WHEN ra.year BETWEEN 2000 AND 2009 THEN '00s'
		WHEN ra.year BETWEEN 2010 AND 2019 THEN '10s'
		ELSE '20s' END
HAVING SUM(CASE WHEN r.positionOrder = 1 THEN 1 ELSE 0 END) > 0
ORDER BY TotalWins DESC;

/*Task H5: Average Finish Position by Grid
Description: Calculate average race position per grid spot.*/
SELECT
	r.grid AS StartingPosition,
	AVG(r.positionorder) AS AVGFinish
FROM results r
JOIN races ra ON ra.raceId = r.raceId
WHERE ra.circuitId = 4 AND r.grid > 0
GROUP BY r.grid
ORDER BY r.grid ASC;

/*Task H11: Podium Finishes by Driver
Description: Count podium finishes (positions 1–3) per driver.*/
SELECT
	d.forename + ' ' + d.surname AS Driver,
	SUM(CASE WHEN r.positionorder <= 3 THEN 1 ELSE 0 END) AS TotalPodiums
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4
GROUP BY d.forename + ' ' + d.surname
HAVING SUM(CASE WHEN r.positionorder <= 3 THEN 1 ELSE 0 END) > 0
ORDER BY TotalPodiums DESC;

/*Task H12: Constructor Points by Year (2010–2024)
Description: Sum points per constructor per year (modern points system).*/
SELECT
	ra.year,
	c.name AS Constructor,
	SUM(r.points) AS TotalPoints
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN constructors c ON c.constructorId = r.constructorId
WHERE ra.circuitId = 4 AND ra.year >=2010
GROUP BY c.name, ra.year
HAVING SUM(r.points) > 0
ORDER BY ra.year ASC, TotalPoints DESC;

/*Task H14: Race Finish Rate by Constructor
Description: Compute percentage of non-DNF finishes per constructor.*/
WITH TotalSpainGP AS
(SELECT
	c.name AS Constructor,
	SUM(CASE WHEN s.status IN('Finished', '+1 Lap', '+2 Laps', '+3 Laps') THEN 1 ELSE 0 END) AS TotalFinishedRaces,
	COUNT(*) AS TotalSpainGP
FROM results r
JOIN constructors c ON c.constructorId = r.constructorId
JOIN status s ON s.statusId = r.statusId
JOIN races ra ON ra.raceId = r.raceId
WHERE ra.circuitId = 4
GROUP BY c.name
HAVING SUM(CASE WHEN s.status IN('Finished', '+1 Lap', '+2 Laps', '+3 Laps') THEN 1 ELSE 0 END) > 0)
SELECT
	Constructor,
	TotalSpainGP,
	TotalFinishedRaces,
	ROUND((CAST(TotalFinishedRaces as float) / TotalSpainGP) * 100,2) AS FinishedPercentage
FROM TotalSpainGP
ORDER BY TotalSpainGP DESC;

/*Report Ready Tasks*/
/*Task H6: Top 5 Winning Drivers
Description: Rank drivers by total wins.*/
SELECT TOP 5
	d.forename + ' ' + d.surname AS Driver,
	COUNT(DISTINCT r.raceId) AS TotalSpainGPWins
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4 and r.positionOrder = 1
GROUP BY d.forename + ' ' + d.surname
ORDER BY TotalSpainGPWins DESC;

/*Task H7: Constructor Pole Frequency (2014–2024)
Description: Calculate pole frequency for top constructors.*/
WITH TotalPoles AS
(SELECT
	c.name AS Constructor,
	SUM(CASE WHEN q.position = 1 THEN 1 ELSE 0 END) AS TotalPoles,
	COUNT(q.raceid) / 2 AS TotalRaces
FROM qualifying q
JOIN races ra ON ra.raceId = q.raceId
JOIN constructors c ON c.constructorId = q.constructorId
WHERE ra.circuitId = 4 AND ra.year >= 2014
GROUP BY c.name
HAVING SUM(CASE WHEN q.position = 1 THEN 1 ELSE 0 END) > 0)
SELECT
	Constructor,
	TotalPoles,
	ROUND((CAST(totalpoles AS float) / TotalRaces) * 100,2) AS PoleFrequency
FROM TotalPoles;

/*Task H8: DNF Rate by Grid Position
Description: Assess crash risk by grid (top 10).*/
WITH TotalDNF AS
(SELECT
	r.grid AS GridPosition,
	COUNT(DISTINCT r.raceId)  AS TotalRaces,
	SUM(CASE WHEN s.status NOT IN('+1 Lap', '+2 Laps', '+3 Laps', 'Finished') THEN 1 ELSE 0 END) AS TotalDNF
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN status s ON s.statusId = r.statusId
WHERE ra.circuitId = 4 AND r.grid > 0
GROUP BY r.grid)
SELECT
	GridPosition,
	TotalDNF,
	ROUND((CAST(TotalDNF as float) / TotalRaces) * 100,2) AS DNFRate
FROM TotalDNF
ORDER BY GridPosition ASC;

/*Task H10: Top Points Scorers
Description: Rank drivers by points.*/
SELECT TOP 5
	d.forename + ' ' + d.surname AS Driver,
	SUM(r.points) AS TotalPoints
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4
GROUP BY d.forename + ' ' + d.surname
ORDER BY TotalPoints DESC;
