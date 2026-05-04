USE tpch10;
GO

CREATE OR ALTER PROCEDURE dbo.usp_UpdateOrdersAndLineitem
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRAN;

    UPDATE o
    SET o.o_comment = CONCAT(o.o_comment, ' | BATCH_UPDATE')
    FROM dbo.orders AS o
    WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-12-31';

    UPDATE l
    SET l.l_comment = CONCAT(l.l_comment, ' | BATCH_UPDATE')
    FROM dbo.lineitem AS l
    JOIN dbo.orders AS o
        ON o.o_orderkey = l.l_orderkey
    WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-12-31';

    MERGE dbo.OrderTotals AS tgt
    USING (
        SELECT
            l.l_orderkey,
            SUM(l.l_quantity)      AS total_quantity,
            SUM(l.l_extendedprice) AS total_value
        FROM dbo.lineitem AS l
        JOIN dbo.orders AS o
            ON o.o_orderkey = l.l_orderkey
        WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
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

EXEC dbo.usp_UpdateOrdersAndLineitem;
