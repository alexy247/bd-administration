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
    DECLARE @path NVARCHAR(100)
    SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'
    DECLARE @time nvarchar(200)
    SET @time = FORMAT(CURRENT_TIMESTAMP, N'dd-mm-yyyyTHH.mm.ss')

	DECLARE @full_path nvarchar(200), @isFull BIT
	SET @full_path = @path + '\' + @dataBase + '_' + @time

    -- Изучаем файлы в @path, чтобы определить, какую из копий надо делать (full/diff)
    IF OBJECT_ID(@dataBase.#DirectoryTree)IS NOT NULL
      DROP TABLE #DirectoryTree;
    CREATE TABLE #DirectoryTree (
        id int IDENTITY(1,1)
        ,subdirectory nvarchar(512)
        ,depth int
        ,isfile bit);
    
    INSERT #DirectoryTree(subdirectory,depth,isfile)
    EXEC master.sys.xp_dirtree @path,1,1;
    
    SELECT * FROM #DirectoryTree
    WHERE isfile = 1 AND
        RIGHT(subdirectory,4) = '.bak' AND
        CHARINDEX(@dataBase, subdirectory) > 0 AND
        CHARINDEX(@dataBase, subdirectory) > 0
    ORDER BY subdirectory;
    GO

	IF @isFull = 0
		BEGIN
		SET @full_path = @full_path + 'diff-copy.bak'
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