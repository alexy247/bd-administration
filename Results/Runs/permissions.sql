USE [PaymentData]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[GetPermissions]

SELECT	'Return Value' = @return_value

GO
