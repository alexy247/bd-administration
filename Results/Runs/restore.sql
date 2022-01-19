USE master;
GO
DECLARE	@return_value int

EXEC	@return_value = [dbo].[CreateRestore]
		@dataBase = N'PaymentData',
		@isFull = 1,
		@path = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\PaymentData_20-28-2022T01.28.20_full-copy.bak'

SELECT	'Return Value' = @return_value

GO
