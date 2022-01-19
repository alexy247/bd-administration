-- Резервное копирование и восстановление

/* 
Задание - написать 2 хранимые процедуры:
1) Для создания резервной копии (полной или разностной) заданной БД. Имя БД определяется аргументом процедуры. 
При сохранениии нужно учитывать время создания резервной копии. Рекомендуется задействовать как полную, так и разностную копии.
Можно разработать стратегию для резервного копирования: например, делать полную копию раз в неделю/10 дней/месяц, а разностную - раз в день/12 часов/час.

2) Для восстановления БД из хранимого набора резервных копий с указанием даты/времени, на которую надо восстановить БД.
При наличии нескольких вариантов следует выбирать ближайший по времени (либо ближайший предшествующий) к указанному параметру.
*/

CREATE PROCEDURE CreateBackup
@dataBase NVARCHAR(100),
@isFull BIT = 1,
@path NVARCHAR(100)
AS
BEGIN
    DECLARE @time nvarchar(200)
    SET @time = FORMAT(CURRENT_TIMESTAMP, N'dd-mm-yyyyTHH.mm.ss')
	DECLARE @full_path nvarchar(200)
	SET @full_path = @path + '\' + @dataBase + '_' + @time
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

CREATE PROCEDURE CreateRestore
@dataBase NVARCHAR(100),
@isFull BIT = 1,
@path NVARCHAR(100)
AS
BEGIN
    DECLARE @time nvarchar(200)
    SET @time = FORMAT(CURRENT_TIMESTAMP, N'dd-mm-yyyyTHH.mm.ss')
	DECLARE @full_path nvarchar(200)
	SET @full_path = @path + '\' + @dataBase + '_' + @time
	IF @isFull = 0
		BEGIN
		SET @full_path = @full_path + 'diff-copy.bak'
		RESTORE DATABASE @dataBase
		TO
		DISK = @full_path
		WITH RECOVERY;
		END
	ELSE
		BEGIN
		SET @full_path = @full_path + '_full-copy.bak'
		RESTORE DATABASE @dataBase
        TO
		DISK = @full_path
		WITH NORECOVERY;
		END
END