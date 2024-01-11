/****** Object:  StoredProcedure [ea].[Backup_Table]    Script Date: 1/11/2024 12:34:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=======================================================================================
Overview
The ea.Backup_Table stored procedure is designed to create a backup of a specified table in SQL Server. This procedure dynamically generates and executes a SQL script to create a backup table.

Features
Dynamically creates a new table as a backup of an existing table.
Handles potential errors during the backup process.
The backup table's name is a combination of the original table name and a provided ticket number.

Parameters
@source_table NVARCHAR(120): The name of the source table to back up.
@source_schema NVARCHAR(120): The schema of the source table.
@backup_schema NVARCHAR(120): The schema for the backup table.
@ticket INT: A unique identifier that is appended to the backup table's name.

Behavior
Constructs the backup table name by appending the provided ticket number to the source table name.
Generates a SQL script to:
Check if the backup table already exists, and if so, drop it.
Create a new backup table by selecting all data from the source table.
Executes the generated SQL script.
In case of an error, it captures the error message and details, and raises an error with the captured information.

Example:
EXEC ea.Backup_Table @source_table = N'Fact'
					,@source_schema = N'dwh'
					,@backup_schema = N'bkup'
					,@ticket = 52341


Author         : Felipe Chao 16 Feb 2023
========================================================================================= 
*/

CREATE PROCEDURE [ea].[Backup_Table]
    @source_table NVARCHAR(120),
    @source_schema NVARCHAR(120),
    @backup_schema NVARCHAR(120),
    @ticket INT
AS
BEGIN
    BEGIN TRY   
        DECLARE @backup_table_name AS NVARCHAR(120);

        SET @backup_table_name = CONCAT(@source_table, '_', @ticket);

        DECLARE @query AS NVARCHAR(MAX) = CONCAT(
            'IF OBJECT_ID(''', QUOTENAME(@backup_schema), '.', QUOTENAME(@backup_table_name), ''') IS NOT NULL ',
            'BEGIN ',
            'DROP TABLE ', QUOTENAME(@backup_schema), '.', QUOTENAME(@backup_table_name), '; ',
            'END; ',
            'SELECT * INTO ', QUOTENAME(@backup_schema), '.', QUOTENAME(@backup_table_name), ' FROM ', QUOTENAME(@source_schema), '.', QUOTENAME(@source_table)
        );

        PRINT 'Backup table created: ' + @backup_schema + '.' + @backup_table_name;

        EXEC sp_executesql @query;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);																
    END CATCH
END
