CREATE OR ALTER TRIGGER dbo.trg_orders_UpdateCustomerStats
ON dbo.orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ChangedCustomers AS (
        SELECT o_custkey FROM inserted
        UNION
        SELECT o_custkey FROM deleted
    )
    MERGE dbo.CustomerOrderStats AS tgt
    USING (
        SELECT
            o.o_custkey,
            COUNT(*)           AS order_count,
            MAX(o.o_orderdate) AS last_orderdate
        FROM dbo.orders AS o
        JOIN ChangedCustomers AS c
            ON c.o_custkey = o.o_custkey
        GROUP BY o.o_custkey
    ) AS src
        ON tgt.c_custkey = src.o_custkey
    WHEN MATCHED THEN
        UPDATE SET
            tgt.order_count    = src.order_count,
            tgt.last_orderdate = src.last_orderdate
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (c_custkey, order_count, last_orderdate)
        VALUES (src.o_custkey, src.order_count, src.last_orderdate);
END
GO
