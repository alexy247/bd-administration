USE [PaymentData]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CreateBackup]
		@dataBase = PaymentData,
		@isFull = 0,
		@path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'

SELECT	'Return Value' = @return_value

GO
