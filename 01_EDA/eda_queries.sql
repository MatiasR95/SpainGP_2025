/*Step 1: Exploratory Data Analysis (EDA)
Objective: Understand the dataset to guide task design, practicing basic DQL.
Task E1: List All Tables
Description: Retrieve all table names in the database.*/
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

/*Task E2: Verify Circuit Details
Description: Get details for Circuit de Barcelona-Catalunya.*/
SELECT
	location,
	country,
	circuitId, -- ID = 4
	circuitRef
FROM circuits
WHERE country = 'Spain';

/*Task E3: Count Races
Description: Count total Spanish GP races.*/
SELECT
	COUNT(DISTINCT raceId) AS TotalRaces -- 34
FROM races
WHERE circuitId = 4;

/*Task E4: Qualifying Data by Year
Description: Count qualifying entries per year.*/
SELECT
	ra.year AS Season, --No info from 1998 to 2002
	COUNT(DISTINCT q.driverid) AS QualyCount
FROM qualifying q
JOIN races ra ON ra.raceId = q.raceId
WHERE ra.circuitId = 4
GROUP BY ra.year
ORDER BY Season ASC;

/*Task E5: Race Years List
Description: List all race years, IDs, names, and dates.*/
SELECT
	year AS Year,
	raceId AS ID,
	name AS GrandPrix,
	FORMAT(date, 'dd-MMM-yyyy') AS RaceDate
FROM races
WHERE circuitId = 4
ORDER BY year ASC;

/*Task E6: Driver Participation by Year
Description: Count drivers per race year.*/
SELECT
	year,
	COUNT(DISTINCT r.driverId) AS TotalDrivers
FROM races ra
JOIN results r ON r.raceid = ra.raceid
WHERE circuitId = 4
GROUP BY year
ORDER BY year ASC;

/*Task E7: Unique Constructors
Description: List distinct constructors.*/
SELECT
	DISTINCT(c.name) AS Constructor
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN constructors c ON c.constructorId = r.constructorId
WHERE ra.circuitId = 4;

/*Task E8: Race Status Summary
Description: Count occurrences by status (e.g., finished, DNF).*/
SELECT
	s.status,
	COUNT(*) AS Count
FROM results r
JOIN races ra ON ra.raceId = r.raceId
JOIN status s ON s.statusId = r.statusId
WHERE ra.circuitId = 4
GROUP BY s.status
ORDER BY Count DESC;

/*Task E9: Points by Position (2010–2024)
Description: Sum points by finishing position.*/
SELECT
	positionOrder,
	SUM(points) AS TotalPoints
FROM results r
JOIN races ra ON r.raceId = ra.raceId
WHERE ra.circuitId = 4 AND ra.year BETWEEN 2010 AND 2024
GROUP BY positionOrder
ORDER BY TotalPoints DESC;
