USE BatchInsights;
GO

-- Import AppStatus data from CSV
BULK INSERT AppStatus
FROM '/data/csv/DCSBatchAppStatus-1.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Import AppItemValue data from CSV
USE BatchInsights;
GO

INSERT INTO dbo.AppItemValue
(
  ID, DateTimeStamp, GroupId, BatchId, CommonBlock, RecipeName, UnitName,
  ItemName, CommonBlockStatus, ItemValue, PlantNo, SiteName, ProductName
)
SELECT
  TRY_CONVERT(int, ID),
  TRY_CONVERT(datetime2(3), DateTimeStamp),
  GroupId,BatchId, CommonBlock, RecipeName, UnitName,
  ItemName, CommonBlockStatus, ItemValue,
  PlantNo, SiteName, ProductName
FROM OPENROWSET(
  BULK '/data/csv/DCSBatchAppItemValues-1.csv',
  FORMAT = 'CSV',
  FIRSTROW = 2
) WITH (
  ID                varchar(50),
  DateTimeStamp     varchar(50),
  GroupId           varchar(50),
  BatchId           varchar(100),
  CommonBlock       varchar(100),
  RecipeName        varchar(100),
  UnitName          varchar(100),
  ItemName          varchar(200),   -- "S1SAMF[4,2]" will land here correctly
  CommonBlockStatus varchar(50),
  ItemValue         varchar(200),
  PlantNo           varchar(50),
  SiteName          varchar(100),
  ProductName       varchar(100)
) AS x;
GO

PRINT 'Data imported successfully';
GO

