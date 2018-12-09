@echo OFF
SETLOCAL EnableDelayedExpansion

:: Recebe parâmetros
set NEW_NAME=%1
set LOG=%2
set DIR_BKP=%3
set DIR_MDF=%4
set DIR_NDF=%5
set DIR_LDF=%6
set SQL_DIR=%7
set DBNAME=%8

:: Cria script de restore(ScriptRestore_MeuBanco.sql)
echo RESTORE DATABASE %NEW_NAME%>%SQL_DIR%\ScriptRestore_%DBNAME%.sql
echo FROM DISK = '%DIR_BKP%'>>%SQL_DIR%\ScriptRestore_%DBNAME%.sql
echo WITH RECOVERY, STATS = 10>>%SQL_DIR%\ScriptRestore_%DBNAME%.sql
echo.>>%SQL_DIR%\ScriptRestore_%DBNAME%.sql

:: Executa a procedure sp_FileRestore para apontar o novo local e nome dos arquivos MDF, NDF, LDF
:: Parâmetro 1: Diretório absoluto da peça de backup;
:: Parâmetro 2: Diretório para arquivos MDF;
:: Parâmetro 3: Diretório para arquivos NDF;
:: Parâmetro 4: Diretório para arquivos LDF;
sqlcmd -S %INSTANCE_DEST% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;exec sp_FileRestore N'%DIR_BKP%','%DIR_MDF%','%DIR_NDF%','%DIR_LDF%'">>%SQL_DIR%\ScriptRestore_%DBNAME%.sql

echo GO>>%SQL_DIR%\ScriptRestore_%DBNAME%.sql

echo - Script de restore: %SQL_DIR%\ScriptRestore_%DBNAME%.sql>>%LOG%