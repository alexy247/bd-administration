USE [master]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[CreatePartitioning]

SELECT	'Return Value' = @return_value

GO
