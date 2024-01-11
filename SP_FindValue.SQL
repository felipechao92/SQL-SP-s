/****** Object:  StoredProcedure [ea].[LookUpValue]    Script Date: 12/15/2023 2:10:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
=======================================================================================
Overview
ea.LookUpValue is a dynamic SQL-based stored procedure in SQL Server, designed to search a specific column across all tables within a given schema for a specified value. 
It is particularly useful for locating a value within a large database where the exact table containing the value is unknown.

Features
Dynamically searches all tables within a specified schema.
Focuses on a specific column name provided by the user.
Returns the count of matches found in each table where the column exists.
Applicable to databases with a large number of tables or complex schemas.

Parameters
@SchemaName NVARCHAR(128): Schema name to search within.
@ColumnName NVARCHAR(128): Column name to search for.
@SearchValue NVARCHAR(128): Value to search within the specified column.

Behavior
Iterates over each table in the specified schema using a cursor.
For each table, checks if the specified column exists.
If the column exists, constructs and executes a dynamic SQL query to count occurrences of the search value in that column.
Returns a result set with the table name and the count of matches for each table where the column is found.
Implements error handling to close and deallocate the cursor in case of an exception.

EXEC ea.LookUpValue 
  @SchemaName = 'YourSchemaName',
  @ColumnName = 'YourColumnName',
  @SearchValue = 'YourSearchValue';


Author         : Felipe Chao 16 Feb 2023
========================================================================================= 
*/
CREATE PROCEDURE [ea].[LookUpValue]
    @SchemaName NVARCHAR(128),
    @ColumnName NVARCHAR(128),
    @SearchValue NVARCHAR(128)
AS
BEGIN
    BEGIN TRY
        DECLARE @TableName NVARCHAR(128);
        DECLARE @Sql NVARCHAR(MAX);

        DECLARE table_cursor CURSOR FOR
        SELECT TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = @SchemaName
            AND TABLE_TYPE = 'BASE TABLE'; -- Add this condition to filter out views

        OPEN table_cursor;

        FETCH NEXT FROM table_cursor INTO @TableName;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check if the table has the specified column
            IF EXISTS (
                SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = @SchemaName
                    AND TABLE_NAME = @TableName
                    AND COLUMN_NAME = @ColumnName
            )
            BEGIN
                SET @Sql = 'DECLARE @CountMatches INT;
                            SELECT @CountMatches = COUNT(*) 
                            FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) +
                            ' WHERE ' + QUOTENAME(@ColumnName) + ' = @SearchValue;

                            IF @CountMatches > 0
                            BEGIN
                                SELECT ''' + @TableName + ''' AS TableName, @CountMatches AS CountMatches;
                            END';

                EXEC sp_executesql @Sql, N'@SearchValue NVARCHAR(128)', @SearchValue;
            END

            FETCH NEXT FROM table_cursor INTO @TableName;
        END;

        CLOSE table_cursor;
        DEALLOCATE table_cursor;
    END TRY
    BEGIN CATCH
        -- Handle the error (you can customize the error handling logic here)
        CLOSE table_cursor;
        DEALLOCATE table_cursor;
        PRINT 'An error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
