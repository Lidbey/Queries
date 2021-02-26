USE DB

/*QUERY 1*/

/* Get an address of a sender and receiver from a package*/
CREATE VIEW [USER_DATA] AS
	SELECT P.ID AS "Package_ID", C1.CityName "Sender_City", A1.Street AS "Sender_Address", A1.HouseNumber AS "Sender_House_number", 
			C2.CityName AS "Receiver_City", A2.Street AS "Receiver_Address", A2.HouseNumber AS "Receiver_House_number"
		FROM PACKAGE P
		JOIN ADDRESSES A1 ON A1.ID=P.SenderAddressID
		JOIN ADDRESSES A2 ON A2.ID=P.ReceiverAddressID
		JOIN CITY C1 ON C1.ID=A1.CityID
		JOIN CITY C2 ON C2.ID=A2.CityID

SELECT * FROM [USER_DATA]

SELECT Receiver_City, Receiver_Address, Receiver_House_Number, COUNT(*) AS NUM
	FROM [USER_DATA]
	/*WHERE (Sender_City = 'Rumia') AND Receiver_City LIKE 'G%'*/
	GROUP BY Receiver_City, Receiver_Address, Receiver_House_Number
	HAVING COUNT(*)>1
	ORDER BY NUM DESC

DROP VIEW [USER_DATA]



/*QUERY 2*/

/*Get info about people who didn't send any package*/
SELECT *
	FROM PERSON
	WHERE NOT EXISTS
		(SELECT *
			FROM PACKAGE
			WHERE PERSON.ID=PACKAGE.SenderID)



/* Let's assume that it's 2020-01-13, hour 8:30 AM, so packages that are
not yet delivered(we set their DateEnd to NULL), will be still 'in delivery'*/
SELECT *
	FROM PACKAGE_LOCATION
	WHERE PACKAGE_LOCATION.DateEnd >= Convert(datetime, '2020-01-13 08:30 AM')


UPDATE PACKAGE_LOCATION
	SET DateEnd=NULL
	WHERE DateEnd>=Convert(datetime, '2020-01-13 08:30 AM')

SELECT * FROM PACKAGE_LOCATION



/*QUERY 3*/

/* Now, select packages that are already delivered*/
SELECT *
	FROM PACKAGE
	WHERE NOT EXISTS
		(SELECT *
		FROM PACKAGE_LOCATION
		WHERE PACKAGE_LOCATION.DateEnd IS NULL AND PACKAGE.ID=PACKAGE_LOCATION.PackageID)


/* Now, select packages that are not yet delivered <- won't be counted*/
/*SELECT *
	FROM PACKAGE
	WHERE EXISTS
		(SELECT *
		FROM PACKAGE_LOCATION
		WHERE PACKAGE_LOCATION.DateEnd IS NULL AND PACKAGE.ID=PACKAGE_LOCATION.PackageID)*/



/*QUERY 4*/

/* Check names of people that are waiting for package: <- try with join*/
SELECT *
	FROM PERSON
	WHERE EXISTS
		(SELECT *
			FROM PACKAGE
			WHERE PERSON.ID=PACKAGE.ReceiverID AND EXISTS
				(SELECT *
					FROM PACKAGE_LOCATION
					WHERE PACKAGE_LOCATION.DateEnd IS NULL AND PACKAGE.ID=PACKAGE_LOCATION.PackageID))

/* The same, but with join: */

SELECT DISTINCT PName, PSurname
	FROM PERSON
	INNER JOIN PACKAGE ON PERSON.ID=PACKAGE.ReceiverID /*Inner join because I want only people who are receivers*/
	JOIN PACKAGE_LOCATION ON PACKAGE.ID=PACKAGE_LOCATION.PackageID 
	WHERE DateEnd IS NULL




/*QUERY 5*/

/* List people with information about when did they send their packages*/
SELECT PX.ID AS "Package ID", 'Send by' AS "Sender:", PName AS "Name", PSurname AS "Surname", MinDate AS "Date of sending"
	FROM PERSON P
	JOIN PACKAGE PX ON PX.SenderID=P.ID
	JOIN 
	(
		SELECT PackageID, MIN(DateStart) AS MinDate
			FROM PACKAGE_LOCATION
			GROUP BY PackageID
	) PL ON PL.PackageID=PX.ID


SELECT * FROM PACKAGE_LOCATION




/*QUERY 6*/

/*Calculate number of packages associated with each transport*/
SELECT P.TransportID, COUNT(*) AS Number_of_packages, D.DName AS DName
	FROM PACKAGE_LOCATION P
	JOIN TRANSPORT T ON T.ID=P.TransportID
	JOIN DRIVER D ON T.D_ID=D.ID
	WHERE TransportID IS NOT NULL
	GROUP BY TransportID, T.D_ID, D.DName
	ORDER BY Number_of_packages DESC



/*QUERY 7*/

/*Count number of transports done by each driver*/
SELECT D.DName AS DName, COUNT(P.TransportID) AS Suma
	FROM PACKAGE_LOCATION P
	JOIN TRANSPORT T ON T.ID=P.TransportID
	JOIN DRIVER D ON T.D_ID=D.ID
	WHERE TransportID IS NOT NULL
	GROUP BY D.DName
	ORDER BY SUMA DESC



/*QUERY 8*/

/*Calculate the time it took for each package to deliver*/
/*Some comments:
- If there's a NULL at DateEnd in Package_Location near any packageID, it means, that this package is in delivery(in particular delivery)
So what we do (from the query that's the most nested)
1. Select Package Locations that has at least ONE null(it's important to search for one null, instead for those with no nulls - probably all packages has at least one NOT NULL)
2. Select Package Locations that are not the ones with at least one null(pnt. 1) <- the ones with no nulls at all - those will be already delivered packages(package is neither at transport not at warehouse)
3. Select from Package locations: for a Package ID: minimum of DateStart, and maximum of DateEnd 
Min of datestart is the date of first occurence of package in a company, and maximum of dateEnd(IF NOT NULL, pt. 1,2), is the date when the package is not at company any more
4. And at the end, select Particular package properties(I chose ID and Format), calculate the time of delivery by subtracting maxDateEnd and minDateStart, and list it with it.
/\ THERE WILL BE NULLS, because we removed the packages that are still in delivery from subquery <- we change the null to 'Not yet delivered'
5. Order by duration :)
*/
SELECT P.ID, P.FormatType, ISNULL(CONVERT(VARCHAR(17),DATEDIFF(HOUR,MinDate,MaxDate)),'Not yet delivered') AS 'Duration[Hours]'
	FROM PACKAGE P
	LEFT JOIN  -- swap between JOIN/LEFT JOIN to either get all packages with info not yet delivered, or only those already delivered
	(
		SELECT PackageID, MIN(DateStart) AS MinDate, MAX(DateEnd) AS MaxDate
			FROM 
			(
				SELECT * FROM PACKAGE_LOCATION PL1
				WHERE NOT EXISTS
					(
					SELECT * 
					FROM PACKAGE_LOCATION PL2
					WHERE DateEnd IS NULL AND PL1.PackageID=PL2.PackageID
					)
			) PL3
			GROUP BY PackageID
	) PL4 ON P.ID=PL4.PackageID
	ORDER BY 'Duration[Hours]' ASC


/* QUERY 9 */
/*Find average delivery time of our company*/

SELECT AVG(Diff) AS 'Company average delivery time[Hours]'
FROM (
	SELECT DATEDIFF(HOUR,MIN(DateStart),MAX(DateEnd)) AS 'Diff'
	FROM
		(
		SELECT DateStart,DateEnd,PackageID
		FROM PACKAGE_LOCATION PL1
		WHERE NOT EXISTS
			(
			SELECT *
			FROM PACKAGE_LOCATION PL2
			WHERE DateEnd IS NULL AND PL1.PackageID=PL2.PackageID
			)
		) X
	GROUP BY PackageID
	) X1


/* QUERY 10 */
/* select people in our database that did not send, nor received any package in last 5 years */
/* useful in case if we would like to save some space in our database :) */

/* This update just sets the year to 2014 from 2020 for locations of packages number 1*/
UPDATE PACKAGE_LOCATION
	SET DateEnd=DATEADD(YEAR, -6, DateEnd),
		DateStart=DATEADD(YEAR,-6,DateStart)
	WHERE PackageID=1

SELECT PE.ID, PE.PName, PE.PSurname, ISNULL(CONVERT(VARCHAR(12),MAX(Maximum)),'No data') AS 'Last package received/delivered'
	FROM PERSON PE
	LEFT JOIN 
		(
		SELECT *
		FROM PACKAGE PA
			LEFT JOIN 
			(
			SELECT PackageID,
				CASE WHEN 
					MAX(PL.DateEnd)>MAX(PL.DateStart) THEN MAX(PL.DateEnd)
					ELSE MAX(PL.DateStart)
				END AS 'Maximum'
			FROM PACKAGE_LOCATION PL
			GROUP BY PackageID
			) Dates ON PA.ID=Dates.PackageID
		) PEPA ON PEPA.ReceiverID=PE.ID OR PEPA.SenderID=PE.ID
	GROUP BY PE.ID, PE.PName, PE.PSurname
	HAVING MAX(Maximum) IS NULL OR DATEDIFF(YEAR,MAX(Maximum), GETDATE())>5