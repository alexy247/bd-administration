-- Восстановление

/* 
2) Для восстановления БД из хранимого набора резервных копий с указанием даты/времени, на которую надо восстановить БД.
При наличии нескольких вариантов следует выбирать ближайший по времени (либо ближайший предшествующий) к указанному параметру.
*/

CREATE PROCEDURE CreateRestore
    @dataBase NVARCHAR(100)
AS
BEGIN
    DECLARE @path NVARCHAR(100), @full_path nvarchar(200), @isFull BIT
    SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'

    -- Изучаем файлы в @path, чтобы определить, какую из копий надо делать (full/diff)
	IF OBJECT_ID('tempdb..#RestoreDirectoryTree') IS NOT NULL
	DROP TABLE #RestoreDirectoryTree;

	CREATE TABLE #RestoreDirectoryTree (
		id int IDENTITY(1,1)
		,subdirectory nvarchar(512)
		,depth int
		,isfile bit);
    
	INSERT #RestoreDirectoryTree(subdirectory,depth,isfile)
	EXEC master.sys.xp_dirtree @path,1,1;
    
	SELECT @lastVersion = 'version', @full_path = 'subdirectory'
	FROM (
		SELECT TOP(1) *, SUBSTRING(subdirectory, 1, @dateRegLen) AS 'date',
		SUBSTRING(RIGHT(subdirectory, 13), 1, 4) AS 'version' 
		FROM #RestoreDirectoryTree
		WHERE isfile = 1 AND
			RIGHT(subdirectory,4) = '.bak' AND
			CHARINDEX(@dataBase, subdirectory) > 0
		ORDER BY 'date' DESC
		) last;
	IF @lastVersion IS NULL OR @lastVersion = 'full'
	SET @isFull = 1
	ELSE
	SET @isFull = 0;
	PRINT(@full_path)
    PRINT(@isFull)
	IF @isFull = 0
		BEGIN
		RESTORE DATABASE @dataBase
		TO
		DISK = @full_path
		WITH RECOVERY;
		END
	ELSE
		BEGIN
		RESTORE DATABASE @dataBase
        TO
		DISK = @full_path
		WITH NORECOVERY;
		END
END