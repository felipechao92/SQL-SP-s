/****** Object:  StoredProcedure [ea].[Rollback_Table]    Script Date: 1/11/2024 12:38:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
=======================================================================================
Overview
The ea.Rollback_Table stored procedure is designed to restore data from a backup table to the main table in SQL Server. 
This procedure is particularly useful for reverting changes made to a table by restoring its previous state from the backup.

Features
Truncates the main table and refills it with data from the backup table.
Handles identity columns intelligently, ensuring that identity insert settings are managed correctly.
Provides error handling to capture and raise errors during the rollback process.

Parameters
@backup_schema NVARCHAR(255): The schema of the backup table.
@backup_table_name NVARCHAR(255): The name of the backup table.
@main_schema NVARCHAR(255): The schema of the main table to be restored.
@main_table NVARCHAR(255): The name of the main table to be restored.
Behavior

Truncates the main table to prepare for data restoration.
Checks if the main table has an identity column and sets a flag accordingly.
If the main table has an identity column, it enables identity insert and then inserts data from the backup table. Otherwise, it simply inserts data from the backup table.
If identity insert was enabled, it is turned off after data insertion.
In case of an error during the process, captures the error details and raises an error with the information.

Example

EXEC ea.Rollback_Table @backup_schema = N'bkup'
					  ,@backup_table_name = N'Fact_52341'
					  ,@main_schema = N'dwh'
					  ,@main_table = N'Fact'

Author         : Felipe Chao 16 Feb 2023
========================================================================================= 
*/

CREATE PROCEDURE [ea].[Rollback_Table]
  @backup_schema NVARCHAR(255),
  @backup_table_name NVARCHAR(255),
  @main_schema NVARCHAR(255),
  @main_table NVARCHAR(255)

AS
BEGIN
    BEGIN TRY

  DECLARE @identity_insert_enabled BIT = 0;

  DECLARE @sql_truncate NVARCHAR(MAX);
  SET @sql_truncate = N'TRUNCATE TABLE ' + QUOTENAME(@main_schema) + '.' + QUOTENAME(@main_table);
  EXEC sp_executesql @sql_truncate;

  IF (OBJECTPROPERTY(OBJECT_ID(QUOTENAME(@main_schema) + '.' + QUOTENAME(@main_table)), 'TableHasIdentity') = 1) 
  SET @identity_insert_enabled = 1;

  IF @identity_insert_enabled = 1
  BEGIN
    DECLARE @sql_enable_identity_insert NVARCHAR(MAX);
    SET @sql_enable_identity_insert = N'SET IDENTITY_INSERT ' + QUOTENAME(@main_schema) + '.' + QUOTENAME(@main_table) + N' ON; ' 
    + 'INSERT INTO ' + QUOTENAME(@main_schema) + '.' + QUOTENAME(@main_table) 
    + ' (' + (SELECT STUFF((SELECT ', ' + QUOTENAME(c.name) 
                           FROM sys.columns c 
                           WHERE c.object_id = OBJECT_ID(@main_schema + '.' + @main_table) 
                           FOR XML PATH('')), 1, 2, '')) + ') '
    + ' SELECT ' + (SELECT STUFF((SELECT ', ' + QUOTENAME(c.name) 
                                 FROM sys.columns c 
                                 WHERE c.object_id = OBJECT_ID(@backup_schema + '.' + @backup_table_name) 
                                 FOR XML PATH('')), 1, 2, '')) 
    + ' FROM ' + QUOTENAME(@backup_schema) + '.' + QUOTENAME(@backup_table_name);
    EXEC sp_executesql @sql_enable_identity_insert;
  END
  ELSE
  BEGIN
    DECLARE @sql_copy NVARCHAR(MAX);
    SET @sql_copy = N'INSERT INTO ' + QUOTENAME(@main_schema) + '.' + QUOTENAME(@main_table) + N' SELECT * FROM ' + QUOTENAME(@backup_schema) + '.' + QUOTENAME(@backup_table_name);
    EXEC sp_executesql @sql_copy;
  END

  IF @identity_insert_enabled = 1
  BEGIN
    DECLARE @sql_disable_identity_insert NVARCHAR(MAX);
    SET @sql_disable_identity_insert = N'SET IDENTITY_INSERT ' + QUOTENAME(@main_schema) + '.' + QUOTENAME(@main_table) + N' OFF';
    EXEC sp_executesql @sql_disable_identity_insert;
  END;

END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
