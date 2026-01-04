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
BULK INSERT AppItemValue
FROM '/data/csv/DCSBatchAppItemValues-1.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

PRINT 'Data imported successfully';
GO

