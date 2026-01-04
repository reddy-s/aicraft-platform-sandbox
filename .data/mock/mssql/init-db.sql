-- Create BatchInsights database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'BatchInsights')
BEGIN
    CREATE DATABASE BatchInsights;
END
GO

USE BatchInsights;
GO

-- Create AppStatus table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppStatus')
BEGIN
    CREATE TABLE AppStatus (
        ID INT PRIMARY KEY,
        DateTimeStamp DATETIME2,
        GroupId VARCHAR(50),
        BatchId VARCHAR(100),
        BatchStatus VARCHAR(50),
        CommonBlock VARCHAR(100),
        UnitName VARCHAR(100),
        UnitStatus VARCHAR(50),
        UnitStartTime VARCHAR(50),
        UnitEndTime VARCHAR(50),
        RecipeName VARCHAR(100),
        RecipeCreatedDate VARCHAR(50),
        RecipeComment VARCHAR(500),
        ProductName VARCHAR(100),
        RecipeVersion VARCHAR(20),
        RecipeModifiedDate VARCHAR(50),
        RecipeAuthor VARCHAR(100),
        PersonApproved VARCHAR(100),
        ApprovalDate VARCHAR(50),
        MasterRecipeStatus VARCHAR(50),
        RecipeEngUnit VARCHAR(50),
        SecurityLevel VARCHAR(20),
        Description VARCHAR(500),
        BatchStartTime VARCHAR(50),
        BatchEndTime VARCHAR(50)
    );
END
GO

-- Create AppItemValue table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AppItemValue')
BEGIN
    CREATE TABLE AppItemValue (
        ID INT PRIMARY KEY,
        DateTimeStamp DATETIME2,
        GroupId VARCHAR(50),
        BatchId VARCHAR(100),
        CommonBlock VARCHAR(100),
        RecipeName VARCHAR(100),
        UnitName VARCHAR(100),
        ItemName VARCHAR(100),
        CommonBlockStatus VARCHAR(50),
        ItemValue VARCHAR(50),
        PlantNo VARCHAR(50),
        SiteName VARCHAR(100),
        ProductName VARCHAR(100)
    );
END
GO

PRINT 'Database and tables created successfully';
GO

