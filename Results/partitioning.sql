-- Разделение

/* 
Задание - написать SQL-код для разделения какой-нибудь реальной таблицы с данными. Реальную таблицу взять из какой-нибудь действующей (настоящей, не "игрушечной") БД.
Можно использовать один из двух сценариев: 
1) создание пустой разделенной таблицы + перенос данных и переименование таблиц
2) применение кластерного индекса
*/

ALTER DATABASE PaymentData
ADD FILEGROUP fileGroup1;
ALTER DATABASE PaymentData
ADD FILEGROUP fileGroup2;
ALTER DATABASE PaymentData
ADD FILEGROUP fileGroup3;

ALTER DATABASE PaymentData
ADD FILE
(
NAME = file1,
FILENAME = 'C:\Users\alyon\bd-administration\Results\fileGroup1.ndf'
) TO FILEGROUP fileGroup1;

ALTER DATABASE PaymentData
ADD FILE
(
NAME = file2,
FILENAME = 'C:\Users\alyon\bd-administration\Results\fileGroup2.ndf'
) TO FILEGROUP fileGroup2;

ALTER DATABASE PaymentData
ADD FILE
(
NAME = file3,
FILENAME = 'C:\Users\alyon\bd-administration\Results\fileGroup3.ndf'
) TO FILEGROUP fileGroup3;

CREATE PARTITION FUNCTION CreatePartitionFunction(NVARCHAR(100))
AS
RANGE LEFT
FOR VALUES ('A', 'P')

CREATE PARTITION SCHEME CreatePartitionScheme
AS PARTITION CreatePartitionFunction
TO (fileGroup1, fileGroup2, fileGroup3)

CREATE TABLE temp_table (
	Oid UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
	FirstName NVARCHAR(100) NULL,
	SecondName NVARCHAR(100) NULL,
	Phone NVARCHAR(100) NULL

)
ON CreatePartitionScheme(FirstName);

INSERT INTO temp_table SELECT * FROM Client;
DROP TABLE Client;
EXEC sp_rename temp_table, Client;