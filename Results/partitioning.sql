-- Разделение

/* 
Задание - написать SQL-код для разделения какой-нибудь реальной таблицы с данными. Реальную таблицу взять из какой-нибудь действующей (настоящей, не "игрушечной") БД.
Можно использовать один из двух сценариев: 
1) создание пустой разделенной таблицы + перенос данных и переименование таблиц
2) применение кластерного индекса
*/

CREATE PROCEDURE ApartTable
@dataBase NVARCHAR(100)
AS
BEGIN
	ALTER DATABASE @dataBase
	ADD FILEGROUP fileGroup1
	ALTER DATABASE @dataBase
	ADD FILEGROUP fileGroup2

	ALTER DATABASE @dataBase
	ADD FILE
	(
	NAME = fileGroup1,
	FILENAME = 'C:\Users\alyon\bd-administration\Results\fileGroup1.ndf'
	) TO FILEGROUP group1;

	ALTER DATABASE @dataBase
	ADD FILE
	(
	NAME = fileGroup2,
	FILENAME = 'C:\Users\alyon\bd-administration\Results\fileGroup2.ndf'
	) TO FILEGROUP group2;

	CREATE PARTITION FUNCTION CreatePartitionFunction(bit)
	AS
	RANGE LEFT
	FOR VALUES (0)

	CREATE PARTITION SCHEME CreatePartitionScheme
	AS PARTITION CreatePartitionFunction
	TO (group1, group2)

	CREATE TABLE temp_table (id int, text_field text, part_id bit)
	ON CreatePartitionScheme(part_id);
	INSERT INTO temp_table SELECT * FROM Table_task3;
	DROP TABLE Table_task3;
	EXEC sp_rename temp_table, Table_task3;
END