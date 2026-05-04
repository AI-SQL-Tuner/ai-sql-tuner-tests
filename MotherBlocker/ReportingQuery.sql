USE tpch10;
GO

SELECT
    o.o_orderkey,
    o.o_orderdate,
    ot.total_quantity,
    ot.total_value
FROM dbo.orders AS o
LEFT JOIN dbo.OrderTotals AS ot
    ON ot.o_orderkey = o.o_orderkey
WHERE o.o_orderdate BETWEEN '1995-06-01' AND '1995-06-30';
