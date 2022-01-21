-- Восстановление

/* 
2) Для восстановления БД из хранимого набора резервных копий с указанием даты/времени, на которую надо восстановить БД.
При наличии нескольких вариантов следует выбирать ближайший по времени (либо ближайший предшествующий) к указанному параметру.
*/

CREATE PROCEDURE CreateRestore
    @dataBase NVARCHAR(100)
AS
BEGIN
    DECLARE @path NVARCHAR(100), @full_path nvarchar(200), @full_dif_path nvarchar(200), @isFull BIT, @lastVersion NVARCHAR(4), @time nvarchar(200), @dateRegLen BIGINT
    SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'
	SET @time = FORMAT(CURRENT_TIMESTAMP, N'dd-mm-yyyyTHH.mm.ss')
	SET @dateRegLen = LEN(@time)

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
    
	SELECT @lastVersion = version, @full_path = subdirectory
	FROM (
		SELECT TOP(1) *, SUBSTRING(subdirectory, 1, @dateRegLen) AS 'date',
		SUBSTRING(RIGHT(subdirectory, 13), 1, 4) AS 'version' 
		FROM #RestoreDirectoryTree
		WHERE isfile = 1 AND
			RIGHT(subdirectory,13) = 'full-copy.bak' AND
			CHARINDEX(@dataBase, subdirectory) > 0
		ORDER BY 'date' DESC
		) last;

	SELECT @full_dif_path = subdirectory
	FROM (
		SELECT TOP(1) *, SUBSTRING(subdirectory, 1, @dateRegLen) AS 'date'
		FROM #RestoreDirectoryTree
		WHERE isfile = 1 AND
			RIGHT(subdirectory,13) = 'diff-copy.bak' AND
			CHARINDEX(@dataBase, subdirectory) > 0
		ORDER BY 'date' DESC
		) diff;
	IF @full_dif_path IS NULL
	SET @isFull = 1
	ELSE
	SET @isFull = 0;

	IF @isFull = 0
		BEGIN
			RESTORE DATABASE @dataBase
			FROM
			DISK = @full_path
			WITH NORECOVERY, REPLACE;

			RESTORE DATABASE @dataBase
			FROM
			DISK = @full_dif_path
			WITH RECOVERY, REPLACE;
		END;
	ELSE
		BEGIN
			RESTORE DATABASE @dataBase
			FROM
			DISK = @full_path
			WITH RECOVERY, REPLACE;
		END;
	SELECT @full_path, @isFull,  @full_dif_path;
END