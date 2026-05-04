USE tpch10;
GO

IF OBJECT_ID('dbo.lineitem_stage') IS NULL
BEGIN
    SELECT TOP (100000) *
    INTO dbo.lineitem_stage
    FROM dbo.lineitem;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_MergeLineitemFromStage
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRAN;

    MERGE dbo.lineitem AS target
    USING dbo.lineitem_stage AS src
        ON target.l_orderkey   = src.l_orderkey
       AND target.l_linenumber = src.l_linenumber
    WHEN MATCHED THEN
        UPDATE SET
            target.l_quantity      = src.l_quantity,
            target.l_extendedprice = src.l_extendedprice,
            target.l_comment       = CONCAT(target.l_comment, ' | MERGED')
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (l_orderkey, l_partkey, l_suppkey, l_linenumber,
                l_quantity, l_extendedprice, l_discount, l_tax,
                l_returnflag, l_linestatus, l_shipdate, l_commitdate,
                l_receiptdate, l_shipinstruct, l_shipmode, l_comment)
        VALUES (src.l_orderkey, src.l_partkey, src.l_suppkey, src.l_linenumber,
                src.l_quantity, src.l_extendedprice, src.l_discount, src.l_tax,
                src.l_returnflag, src.l_linestatus, src.l_shipdate, src.l_commitdate,
                src.l_receiptdate, src.l_shipinstruct, src.l_shipmode, src.l_comment);

    COMMIT TRAN;
END
GO

EXEC dbo.usp_MergeLineitemFromStage;
