USE tpch10
GO

CREATE OR ALTER PROCEDURE dbo.usp_UpdateOrdersAndLineitem
    @FromDate DATE,
    @ToDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Single transaction per call. Keep it focused: one logical unit of work.
    BEGIN TRAN;

    -- Update orders comments for the date window
    UPDATE o
    SET o.o_comment = LEFT(CONCAT(o.o_comment, ' | BATCH_UPDATE ', CONVERT(varchar(10), @FromDate, 120), '-', CONVERT(varchar(10), @ToDate, 120)), 79)
    FROM dbo.orders AS o
    WHERE o.o_orderdate BETWEEN @FromDate AND @ToDate;

    -- Update lineitems for those orders
    UPDATE l
    SET l.l_comment = LEFT(CONCAT(l.l_comment, ' | BATCH_UPDATE ', CONVERT(varchar(10), @FromDate, 120), '-', CONVERT(varchar(10), @ToDate, 120)), 44)
    FROM dbo.lineitem AS l
    JOIN dbo.orders AS o
        ON o.o_orderkey = l.l_orderkey
    WHERE o.o_orderdate BETWEEN @FromDate AND @ToDate;

    -- Recompute order totals for affected orders
    MERGE dbo.OrderTotals AS tgt
    USING (
        SELECT
            l.l_orderkey,
            SUM(l.l_quantity)      AS total_quantity,
            SUM(l.l_extendedprice) AS total_value
        FROM dbo.lineitem AS l
        JOIN dbo.orders AS o
            ON o.o_orderkey = l.l_orderkey
        WHERE o.o_orderdate BETWEEN @FromDate AND @ToDate
        GROUP BY l.l_orderkey
    ) AS src
        ON tgt.o_orderkey = src.l_orderkey
    WHEN MATCHED THEN
        UPDATE SET
            tgt.total_quantity = src.total_quantity,
            tgt.total_value    = src.total_value
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (o_orderkey, total_quantity, total_value)
        VALUES (src.l_orderkey, src.total_quantity, src.total_value);

    COMMIT TRAN;
END
GO
