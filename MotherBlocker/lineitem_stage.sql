IF OBJECT_ID('dbo.lineitem_stage') IS NULL
BEGIN
    SELECT TOP (100000) *
    INTO dbo.lineitem_stage
    FROM dbo.lineitem;
END
GO
