USE tpch10;
GO

IF OBJECT_ID('dbo.OrderTotals') IS NULL
BEGIN
    CREATE TABLE dbo.OrderTotals
    (
        o_orderkey     int        NOT NULL PRIMARY KEY,
        total_quantity decimal(18,2) NOT NULL,
        total_value    decimal(18,2) NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.CustomerOrderStats') IS NULL
BEGIN
    CREATE TABLE dbo.CustomerOrderStats
    (
        c_custkey      int         NOT NULL PRIMARY KEY,
        order_count    int         NOT NULL,
        last_orderdate date        NULL
    );
END
GO
