@echo off
echo ================================================
echo   MotherBlocker: TPC-H Locking/Blocking Storm
echo ================================================
echo.

REM Adjust server and database as needed
set SERVER=ROCKYPC
set DB=tpch10

echo Creating or updating triggers...

sqlcmd -S %SERVER% -d %DB% -E -i trg_lineitem_UpdateOrderTotals.sql
sqlcmd -S %SERVER% -d %DB% -E -i trg_orders_UpdateCustomerStats.sql


echo Starting Session 1: Multi-table transactional updates...
start "Session1" cmd /c sqlcmd -S %SERVER% -d %DB% -E -i usp_UpdateOrdersAndLineitem.sql

echo Starting Session 2: MERGE into lineitem...
start "Session2" cmd /c sqlcmd -S %SERVER% -d %DB% -E -i usp_MergeLineitemFromStage.sql

echo Starting Session 3: Reporting-style read workload...
start "Session3" cmd /c sqlcmd -S %SERVER% -d %DB% -E -i ReportingQuery.sql

echo All sessions launched.
echo Use sp_whoisactive, your Locking & Blocking goal, or DMVs to observe blocking.
