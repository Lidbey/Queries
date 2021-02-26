DROP TABLE NEIGHBOURS, PACKAGE_LOCATION, TRANSPORT, PACKAGE, PAYMENT, DRIVER, PACKAGE_FORMAT, WAREHOUSE, LIVES_AT, PERSON, ADDRESSES, CITY


CREATE TABLE CITY (
	ID INT identity(1,1) PRIMARY KEY,
	CityName VARCHAR(20) NOT NULL,
	CityPopulation INT);

CREATE TABLE ADDRESSES(
	ID INT identity(1,1) PRIMARY KEY,
	Postcode CHAR(6) NOT NULL CHECK( POSTCODE LIKE '[0-9][0-9]-[0-9][0-9][0-9]'),
	Street VARCHAR(20) NOT NULL,
	HouseNumber INT NOT NULL CHECK( HouseNumber >= 0),
	ApartmentNumber INT CHECK( ApartmentNumber >= 0 ),
	CityID INT REFERENCES CITY ON DELETE SET NULL
	);

CREATE TABLE PERSON (
	ID INT identity(1,1) PRIMARY KEY,
	PName VARCHAR(20) NOT NULL CHECK ( PName NOT LIKE '%[^¹êóŸ¿æñ³œêa-zA-Z]%'),
	PSurname VARCHAR(20) NOT NULL CHECK ( PSurname NOT LIKE '%[^¹êóŸ¿æñ³œêa-zA-Z]%')
	);

CREATE TABLE LIVES_AT (
	P_ID INT REFERENCES PERSON ON DELETE CASCADE,
	A_ID INT REFERENCES ADDRESSES ON DELETE CASCADE,
	PRIMARY KEY(P_ID, A_ID));
	
	
	/*only to reference to composite key*/
CREATE TABLE NEIGHBOURS (
	ID INT identity(1,1) PRIMARY KEY,
	N_ID INT REFERENCES PERSON,
	P_ID INT,
	A_ID INT,
	FOREIGN KEY (P_ID,A_ID) REFERENCES LIVES_AT(P_ID,A_ID) ON DELETE CASCADE
	);

CREATE TABLE PAYMENT (
	ID INT identity(1,1) PRIMARY KEY,
	IsPaid BIT DEFAULT 0,
	PaymentMethod VARCHAR(20) DEFAULT 'cash' CHECK (PaymentMethod IN ('card', 'blik', 'cash')),
	Price SMALLMONEY NOT NULL CHECK (Price>=0),
	DateAndTime DATETIME,
	P_ID INT REFERENCES PERSON ON DELETE SET NULL
	);

CREATE TABLE PACKAGE_FORMAT (
	FormatType VARCHAR(20) PRIMARY KEY CHECK (FormatType IN ('tiny','small','medium','large', 'biggest', 'smallest')),
	Max_SizeX INT NOT NULL CHECK( Max_SizeX > 0 ),
	Max_SizeY INT NOT NULL CHECK( Max_SizeY > 0 ),
	Max_SizeZ INT NOT NULL CHECK( Max_SizeZ > 0 ),
	Max_Weight INT NOT NULL CHECK( Max_Weight > 0 ),
	Price SMALLMONEY NOT NULL CHECK( Price >= 0 )
	);

CREATE TABLE PACKAGE (
	ID INT identity(1,1) PRIMARY KEY,
	HighPriority BIT DEFAULT 0,
	PaymentID INT NOT NULL REFERENCES PAYMENT ON DELETE CASCADE,
	FormatType VARCHAR(20) NOT NULL REFERENCES PACKAGE_FORMAT ON UPDATE CASCADE,
	SenderID INT REFERENCES PERSON ON DELETE SET NULL,
	SenderAddressID INT REFERENCES ADDRESSES ON DELETE SET NULL,
	ReceiverID INT REFERENCES PERSON,
	ReceiverAddressID INT NOT NULL REFERENCES ADDRESSES
	);

CREATE TABLE WAREHOUSE (
	ID INT identity(1,1) PRIMARY KEY,
	WName VARCHAR(20),
	WAddress INT NOT NULL REFERENCES ADDRESSES
	);

CREATE TABLE DRIVER (
	ID INT identity(1,1) PRIMARY KEY,
	DName VARCHAR(20) NOT NULL CHECK ( DName NOT LIKE '%[^¹êóŸ¿æñ³œêa-zA-Z]%'),
	DSurname VARCHAR(20) NOT NULL CHECK ( DSurname NOT LIKE '%[^¹êóŸ¿æñ³œêa-zA-Z]%'),
	License VARCHAR(10)
	);

CREATE TABLE TRANSPORT (
	ID INT identity(1,1) PRIMARY KEY,
	TransportType VARCHAR(20),
	A_Start INT REFERENCES ADDRESSES ON DELETE SET NULL,
	A_End INT NOT NULL REFERENCES ADDRESSES,
	D_ID INT NOT NULL REFERENCES DRIVER ON DELETE CASCADE
	);

CREATE TABLE PACKAGE_LOCATION (
	ID INT identity(1,1) PRIMARY KEY,
	DateStart DATETIME,
	DateEnd DATETIME,
	PackageID INT NOT NULL REFERENCES PACKAGE ON DELETE CASCADE,
	WarehouseID INT REFERENCES WAREHOUSE ON DELETE SET NULL,
	TransportID INT REFERENCES TRANSPORT ON DELETE SET NULL);

INSERT INTO CITY VALUES 
	('Rumia', 47000), 
	('Gdynia', 200000),
	('Gdañsk', 500000),
	('Wejherowo', 48000)

INSERT INTO ADDRESSES VALUES
	('84-230', 'Sobieskiego', 28, NULL, (SELECT ID FROM CITY WHERE CityName = 'Rumia')),
	('84-230', 'Sobieskiego', 27, NULL, (SELECT ID FROM CITY WHERE CityName = 'Rumia')),
	('84-230', 'Czereœniowa', 20, NULL, (SELECT ID FROM CITY WHERE CityName = 'Rumia')),
	('84-207', 'Wi¹zowa', 25, NULL, (SELECT ID FROM CITY WHERE CityName = 'Rumia')),
	('81-000', 'Sobieskiego', 28, NULL, (SELECT ID FROM CITY WHERE CityName = 'Gdynia')),
	('81-000', 'Gdañska', 30, NULL, (SELECT ID FROM CITY WHERE CityName = 'Gdynia')),
	('81-000', 'Gdañska', 28, 15, (SELECT ID FROM CITY WHERE CityName = 'Gdynia')),
	('81-005', 'Czerwona', 3, 24, (SELECT ID FROM CITY WHERE CityName = 'Gdynia')),
	('80-031', 'Dobra', 34, 23, (SELECT ID FROM CITY WHERE CityName = 'Gdañsk')),
	('80-031', 'Wielkopolska', 23, 13, (SELECT ID FROM CITY WHERE CityName = 'Gdañsk')),
	('80-027', 'Poznañska', 2, 3, (SELECT ID FROM CITY WHERE CityName = 'Gdañsk')),
	('80-027', 'Warszawska', 3, NULL, (SELECT ID FROM CITY WHERE CityName = 'Gdañsk')),
	('84-200', 'Rumska', 1, NULL, (SELECT ID FROM CITY WHERE CityName = 'Wejherowo')),
	('84-200', 'Rumska', 2, NULL, (SELECT ID FROM CITY WHERE CityName = 'Wejherowo')),
	('84-200', 'Rumska', 3, 3, (SELECT ID FROM CITY WHERE CityName = 'Wejherowo')),
	('84-241', 'Rumska', 4, NULL, (SELECT ID FROM CITY WHERE CityName = 'Wejherowo'))

INSERT INTO PERSON VALUES
	('Jan', 'Kowalski'),
	('Krystyna', 'Kowalska'),
	('John', 'Paul'),
	('Pawe³', 'Wielgus'),
	('Roman', 'Grab'),
	('Waldemar', 'Król'),
	('Weronika', 'Paw³owska'),
	('Wiktoria', 'Grubba'),
	('Maciej', 'Jaki')

INSERT INTO LIVES_AT VALUES
	(1, 1),
	(2, 1),
	(3, 5),
	(4, 9),
	(5, 13),
	(6, 13),
	(8, 8),
	(9, 10)

INSERT INTO WAREHOUSE VALUES
	('Gdañsk Warehouse One', 12),
	('Gdañsk Warehouse Two', 11),
	('Gdynia Warehouse', 6),
	('Rumia Warehouse', 3),
	('Wejherowo Warehouse', 16)

INSERT INTO PACKAGE_FORMAT VALUES
	('Tiny', 1, 5, 10, 100, 5.00),
	('Small', 10, 10, 10, 1000, 7.50),
	('Medium', 30, 30, 30, 10000, 12.50),
	('Large', 100, 100, 200, 10000, 25.00)

INSERT INTO DRIVER VALUES
	('Samuel', 'Jackson', 'C+E'),
	('Karol', 'Bazan', 'B'),
	('Paulina', 'Weber', 'B')

INSERT INTO PAYMENT VALUES
	(1, 'Card', 35.00, '20200112 6:17:30 PM', 1),
	(1, 'Cash', 30.00, '20200112 4:30:00 PM', 2),
	(1, 'Blik', 12.50, '20200112 4:32:00 PM', 2),
	(1, 'Cash', 7.50, '20200112 5:30:00 PM', 5),
	(0, NULL, 12.50, NULL, NULL),
	(0, NULL, 7.50, NULL, NULL),
	(1, 'Cash', 7.50, '20200112 7:20:00 PM', 4)

INSERT INTO PACKAGE VALUES
	(1, 1, 'Tiny', 1, 1, 3, 5),
	(0, 2, 'Large', 2, 4, 4, 5),
	(0, 3, 'Medium', 2, 1, 6, 13),
	(1, 4, 'Small', 5, 8, 7, 9),
	(0, 1, 'Tiny', 6, 13, 4, 14),
	(1, 1, 'Large', 7, 13, 8, 12),
	(0, 2, 'Tiny', 8, 14, 5, 13),
	(0, 5, 'Medium', 7, 15, 5, 13),
	(0, 6, 'Small', 2, 8, 1, 1),
	(0, 7, 'Small', 4, 9, 2, 3)

INSERT INTO TRANSPORT VALUES
	('Car', 3, 6, 1),
	('Car', 6, 5, 2),
	('Car', 3, 16, 3),
	('Car', 16, 13, 3),
	('Car', 16, 14, 3),
	('Car', 16, 12, 3),
	('Car', 6, 3, 1),
	('Car', 6, 11, 2),
	('Car', 11, 9, 2),
	('Car', 11, 3, 2),
	('Car', 3, 1, 1)

INSERT INTO PACKAGE_LOCATION VALUES
	('20200112 6:17:30 PM', '20200112 6:20:00 PM', 1, 4, NULL),
	('20200112 6:20:00 PM', '20200112 7:00:00 PM', 1, NULL, 1),
	('20200112 7:00:00 PM', '20200113 6:00:00 AM', 1, 3, NULL),
	('20200113 6:00:00 AM', '20200113 6:30:00 AM', 1, NULL, 2),
	('20200112 4:30:00 PM', '20200112 6:20:00 PM', 2, 4, NULL),
	('20200112 6:20:00 PM', '20200112 7:00:00 PM', 2, NULL, 1),
	('20200112 7:00:00 PM', '20200113 6:00:00 AM', 2, 3, NULL),
	('20200113 6:00:00 AM', '20200113 6:30:00 AM', 2, NULL, 2),
	('20200112 4:32:00 PM', '20200113 6:10:00 AM', 3, 4, NULL),
	('20200113 6:10:00 AM', '20200113 7:30:00 AM', 3, NULL, 3),
	('20200113 7:30:00 AM', '20200113 7:45:00 AM', 3, 5, NULL),
	('20200113 7:45:00 AM', '20200113 9:00:00 AM', 3, NULL, 4),
	('20200112 5:30:00 PM', '20200113 6:00:00 AM', 4, 3, NULL),
	('20200113 6:00:00 AM', '20200113 7:30:00 AM', 4, NULL, 8),
	('20200113 7:30:00 AM', '20200113 7:35:00 AM', 4, 2, NULL),
	('20200113 7:35:00 AM', '20200113 8:30:00 AM', 4, NULL, 9),
	('20200112 6:17:30 PM', '20200113 7:45:00 AM', 5, 5, NULL),
	('20200113 7:45:00 AM', '20200113 9:30:00 AM', 5, NULL, 5),
	('20200112 6:17:30 PM', '20200113 7:45:00 AM', 6, 5, NULL),
	('20200113 7:45:00 AM', '20200113 8:20:00 AM', 6, NULL, 6),
	('20200112 4:30:00 PM', '20200113 7:45:00 AM', 7, 5, NULL),
	('20200113 7:45:00 AM', '20200113 9:00:00 AM', 7, NULL, 4),
	('20200112 9:30:00 AM', '20200113 7:45:00 AM', 8, 5, NULL),
	('20200113 7:45:00 AM', '20200113 9:00:00 AM', 8, NULL, 4),
	('20200112 8:00:00 AM', '20200113 6:00:00 AM', 9, 3, NULL),
	('20200113 6:00:00 AM', '20200113 7:00:00 AM', 9, NULL, 7),
	('20200113 7:00:00 AM', '20200113 7:05:00 AM', 9, 4, NULL),
	('20200113 7:05:00 AM', '20200113 7:30:00 AM', 9, NULL, 11),
	('20200112 7:20:00 PM', '20200113 7:35:00 AM', 10, 2, NULL),
	('20200113 7:35:00 AM', '20200113 10:00:00 AM', 10, NULL, 10)


	/* It was only to show reference to composite key, not important, and not a big sense behind it, I hope it is not a problem, as all my previous database was consistent(names, people living etc), and I don't want to mess it up
	(by consistent, I mean, an interesting selects we can choose from it, as there is some logic behind e.g. NULL values)*/
INSERT INTO NEIGHBOURS VALUES
	(1, 3, 5),
	(5, 9, 10)