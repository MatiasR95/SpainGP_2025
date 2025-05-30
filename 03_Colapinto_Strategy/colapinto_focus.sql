/*Step 3: Franco’s Focus
Objective: Analyze Colapinto-specific insights for 2025 strategy.

Task F1: Argentinian Driver Participation
Description: List Argentinian drivers and race counts.*/
SELECT
	d.forename + ' ' + d.surname AS Driver,
	COUNT(r.raceId) AS TotalSpainRaces
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4 AND d.nationality = 'Argentine'
GROUP BY d.forename + ' ' + d.surname
ORDER BY TotalSpainRaces DESC;

/*Task F2: Qualifying Position Distribution (2014–2024)
Description: Count grid positions for top-10 finishes.*/
SELECT
	r.grid AS GridPosition,
	SUM(CASE WHEN r.positionorder <= 10 THEN 1 ELSE 0 END) AS TotalPointsFinishes
FROM results r
JOIN races ra ON ra.raceId = r.raceId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0
GROUP BY r.grid
ORDER BY r.grid ASC;

/*Task F3: Overtaking Frequency (2014–2024)
Description: Count races with position gains.*/
SELECT
	ra.year AS Season,
	SUM(CASE WHEN r.grid > r.positionorder THEN 1 ELSE 0 END) AS TotalOvertakes
FROM results r
JOIN races ra ON ra.raceId = r.raceId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0
GROUP BY ra.year
ORDER BY ra.year ASC;

/*Task F4: Points by Constructor (2014–2024)
Description: Sum points by constructor.*/
SELECT TOP 5
	c.name AS Constructor,
	SUM(r.points) AS TotalPoints
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN constructors c ON c.constructorId = r.constructorId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0
GROUP BY c.name
ORDER BY TotalPoints DESC;

/*Task F6: Rookie Driver Success (2014–2024)
Description: Summarize points scored and best finishing position for rookie drivers (first-year competitors) in the Spanish GP during the hybrid era (2014–2024), limited to the top 5 by points.*/
WITH RacesAtSpain AS
(SELECT
	d.forename + ' ' + d.surname AS Driver,
	SUM(r.points) AS TotalPointsScored,
	MIN(r.positionOrder) AS FinishPosition,
	ra.year AS Season,
	ROW_NUMBER () OVER(PARTITION BY r.driverid ORDER BY ra.year) AS TimesAtSpainGP
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4 
GROUP BY d.forename + ' ' + d.surname, r.driverId, ra.year)
SELECT TOP 5
	Driver,
	Season,
	TotalPointsScored,
	BestFinishPosition
FROM RacesAtSpain
WHERE TimesAtSpainGP = 1 AND Season >=2014
ORDER BY TotalPointsScored DESC, BestFinishPosition ASC;

/*Task F11: Argentinian Drivers’ Finishing Positions
Description: List finishing positions for Argentinian drivers, including DNFs.*/
SELECT
	d.forename + ' ' + d.surname AS Driver,
	FORMAT(ra.date, 'MMM - dd - yyyy') AS Date,
	r.positionOrder AS Position,
	s.status AS Status
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
LEFT JOIN status s ON s.statusId = r.statusId
WHERE ra.circuitId = 4 AND d.nationality = 'Argentine'
ORDER BY Date ASC;

/*Task F12: Points Scored by Grid Position (2014–2024)
Description: Sum points from each grid position.*/
SELECT
	r.grid AS GridPosition,
	SUM(r.points) AS TotalPoints
FROM results r
JOIN races ra ON ra.raceId = r.raceId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0
GROUP BY r.grid
ORDER BY r.grid ASC;

/*Task F13: Position Changes by Driver (2014–2024)
Description: Calculate net position changes per driver.*/
SELECT
	d.forename + ' ' + d.surname AS Driver,
	ROUND(AVG(CAST(r.grid AS FLOAT)),1) AS GridPosition,
	ROUND(AVG(CAST(r.positionOrder AS FLOAT)),1) AS FinishPosition,
	ROUND(AVG(CAST(r.grid AS FLOAT) - r.positionorder),1) AS AVGPositionChange
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN drivers d ON d.driverId = r.driverId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND r.grid > 0
GROUP BY d.forename + ' ' + d.surname
ORDER BY GridPosition ASC;

/*Task F14: Constructor Qualifying Consistency (2014–2024)
Description: Count Q3 appearances for both cars per constructor.*/
WITH TotalCarsQ3 AS
(SELECT
	c.name AS Constructor,
	COUNT(q.q3) AS TotalCarsInQ3,
	ra.year AS Season
FROM qualifying q
JOIN races ra ON ra.raceId = q.raceId
JOIN constructors c ON c.constructorId = q.constructorId
WHERE ra.circuitId = 4 AND ra.year >= 2014 AND q.q3 NOT IN ('\N')
GROUP BY c.name, ra.year)
SELECT
	Constructor,
	SUM(CASE WHEN TotalCarsInQ3 = 2 THEN 1 ELSE 0 END) AS TotalQ3WithBothCars
FROM TotalCarsQ3
GROUP BY Constructor, TotalCarsInQ3
HAVING SUM(CASE WHEN TotalCarsInQ3 = 2 THEN 1 ELSE 0 END) > 0
ORDER BY TotalQ3WithBothCars DESC;
