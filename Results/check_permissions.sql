CREATE PROCEDURE CheckPermissions
AS
BEGIN
    SELECT entity_name, permission_name 
    FROM fn_my_permissions((SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES), 'OBJECT')
END