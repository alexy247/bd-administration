-- Проверка и вывод прав 

-- Задание. Написать хранимую процедуру, выдающую все права пользователя на действия в каждой таблице текущей БД

CREATE PROCEDURE CheckPermissions AS
BEGIN
	SELECT * INTO #AllPermissionsTable FROM fn_my_permissions(NULL, 'SERVER') UNION SELECT * FROM fn_my_permissions(NULL, 'DATABASE');
	DECLARE p_cur CURSOR FOR
		SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
        OPEN p_cur
        DECLARE @t_name SYSNAME
        FETCH NEXT FROM p_cur INTO @t_name
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO #AllPermissionsTable SELECT * FROM fn_my_permissions(@t_name, 'Object')
            FETCH NEXT FROM p_cur INTO @t_name
        END
        CLOSE p_cur
	DEALLOCATE p_cur
	SELECT * FROM #AllPermissionsTable
	DROP TABLE #AllPermissionsTable
END