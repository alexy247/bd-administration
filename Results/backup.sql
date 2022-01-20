-- Резервное копирование

/* 
Задание - написать 2 хранимые процедуры:
1) Для создания резервной копии (полной или разностной) заданной БД. Имя БД определяется аргументом процедуры. 
При сохранениии нужно учитывать время создания резервной копии. Рекомендуется задействовать как полную, так и разностную копии.
Можно разработать стратегию для резервного копирования: например, делать полную копию раз в неделю/10 дней/месяц, а разностную - раз в день/12 часов/час.
*/

CREATE PROCEDURE CreateBackup
    @dataBase NVARCHAR(100)
AS
BEGIN
    DECLARE @path NVARCHAR(100), @time nvarchar(200), @full_path nvarchar(200), @dateRegLen BIGINT, @lastVersion NVARCHAR(4), @isFull BIT
    SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'
    SET @time = FORMAT(CURRENT_TIMESTAMP, N'dd-mm-yyyyTHH.mm.ss')
	SET @full_path = @path + '\'+ @time + '_' + @dataBase 
	SET @dateRegLen = LEN(@time)

	-- Изучаем файлы в @path, чтобы определить, какую из копий надо делать (full/diff)
	IF OBJECT_ID('tempdb..#BackupDirectoryTree') IS NOT NULL
	DROP TABLE #BackupDirectoryTree;

	CREATE TABLE #BackupDirectoryTree (
		id int IDENTITY(1,1)
		,subdirectory nvarchar(512)
		,depth int
		,isfile bit);
    
	INSERT #BackupDirectoryTree(subdirectory,depth,isfile)
	EXEC master.sys.xp_dirtree @path,1,1;
    
	SELECT @lastVersion = 'version'
	FROM (
		SELECT TOP(1) *, SUBSTRING(subdirectory, 1, @dateRegLen) AS 'date',
		SUBSTRING(RIGHT(subdirectory, 13), 1, 4) AS 'version' 
		FROM #BackupDirectoryTree
		WHERE isfile = 1 AND
			RIGHT(subdirectory,4) = '.bak' AND
			CHARINDEX(@dataBase, subdirectory) > 0
		ORDER BY 'date' DESC
		) last;
	IF @lastVersion IS NULL OR @lastVersion = 'full'
	SET @isFull = 1
	ELSE
	SET @isFull = 0;
	PRINT(@isFull)
	IF @isFull = 0
		BEGIN
		SET @full_path = @full_path + '_diff-copy.bak'
		BACKUP DATABASE @dataBase
		TO
		DISK = @full_path
		WITH DIFFERENTIAL, INIT;
		END
	ELSE
		BEGIN
		SET @full_path = @full_path + '_full-copy.bak'
		BACKUP DATABASE @dataBase
        TO
		DISK = @full_path
		WITH INIT;
		END
END