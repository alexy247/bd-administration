USE [master]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CreateBackup]
		@dataBase = N'PaymentData'

SELECT	'Return Value' = @return_value

GO
