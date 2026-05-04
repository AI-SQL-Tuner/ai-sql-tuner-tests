CREATE OR ALTER TRIGGER dbo.trg_lineitem_UpdateOrderTotals
ON dbo.lineitem
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ChangedOrders AS (
        SELECT l_orderkey FROM inserted
        UNION
        SELECT l_orderkey FROM deleted
    )
    MERGE dbo.OrderTotals AS tgt
    USING (
        SELECT
            l.l_orderkey,
            SUM(l.l_quantity)      AS total_quantity,
            SUM(l.l_extendedprice) AS total_value
        FROM dbo.lineitem AS l
        JOIN ChangedOrders AS c
            ON c.l_orderkey = l.l_orderkey
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
END
GO
