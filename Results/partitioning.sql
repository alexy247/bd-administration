-- Разделение

/* 
Задание - написать SQL-код для разделения какой-нибудь реальной таблицы с данными. Реальную таблицу взять из какой-нибудь действующей (настоящей, не "игрушечной") БД.
Можно использовать один из двух сценариев: 
1) создание пустой разделенной таблицы + перенос данных и переименование таблиц
2) применение кластерного индекса
*/
USE PaymentData;
GO
ALTER DATABASE PaymentData
ADD FILEGROUP fileGroup1;
ALTER DATABASE PaymentData
ADD FILEGROUP fileGroup2;
ALTER DATABASE PaymentData
ADD FILEGROUP fileGroup3;

ALTER DATABASE PaymentData
ADD FILE
(
NAME = 'f1',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\file1.ndf'
) TO FILEGROUP fileGroup1;

ALTER DATABASE PaymentData
ADD FILE
(
NAME = 'f2',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\file2.ndf'
) TO FILEGROUP fileGroup2;

ALTER DATABASE PaymentData
ADD FILE
(
NAME = 'f3',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\file3.ndf'
) TO FILEGROUP fileGroup3;

CREATE PARTITION FUNCTION CreatePartitionFunction(INT)
AS
RANGE LEFT
FOR VALUES (10, 15)

CREATE PARTITION SCHEME CreatePartitionScheme
AS PARTITION CreatePartitionFunction
TO (fileGroup1, fileGroup2, fileGroup3)

CREATE TABLE temp_table (
	[Oid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [nvarchar](100) NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL
) ON CreatePartitionScheme(GCRecord);

INSERT INTO temp_table (Oid, Name, OptimisticLockField, GCRecord) SELECT Oid, Name, OptimisticLockField, GCRecord FROM AccountType;

SELECT * FROM temp_table;