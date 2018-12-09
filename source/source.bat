@echo OFF
chcp 1252
SETLOCAL EnableDelayedExpansion

call C:\app\DRS\config\config.bat

SET "LOG_START=LOG_START_%date:~-10,2%%date:~-7,2%%date:~-4,4%.log"
SET "DB_RESTORE=none"

:: INICIO DO LOG
echo == Inicio do processo ==	>  %LOG%\%LOG_START%
echo. 							>> %LOG%\%LOG_START%

echo == Populando semaforo ==	>> %LOG%\%LOG_START%
echo. 							>> %LOG%\%LOG_START%
echo - Bases qualificadas :		>> %LOG%\%LOG_START%

:: Executa o script StartQueue.sql no ambiente principal para identificar os bancos qualificados e popular o semaforo.
sqlcmd -S %INSTANCE_PRD% -d Traces -U %USER% -P %PASS% -h -1 -i %SCRIPT%\StartQueue.sql >> %LOG%\%LOG_START%
echo. 							>> %LOG%\%LOG_START%

goto :while

:while
:: Executa o script DbTop.sql para atribuir um dos bancos do semaforo na variavel DB_RESTORE.
For /F "Delims=" %%A In ('
    "sqlcmd.exe -S %INSTANCE_PRD% -d Traces -U %USER% -P %PASS% -h -1 -i %SCRIPT%\DbTop.sql"
') Do set "DB_RESTORE=%%A"

:: Remove espa�os em branco da DB_RESTORE e agora DBNAME � o banco de dados da restaura��o.
for /f "tokens=* delims= " %%A in ('echo %DB_RESTORE%') do set DBNAME=%%A
set DBNAME=%DBNAME:~0,-1%

:: Se n�o existir nenhum banco no semaforo, o script ir� encontrar a palavra "none"
:: Sendo assim o processo � encerrado
:: Caso exista um banco, NEW_NAME ser� o nome do banco restaurado. Ex: MeuBanco_DRS
if %DBNAME%==none (
	goto :exit
) else (	
	SET "NEW_NAME=%DBNAME%_DRS"
	goto :restore
)

:restore
echo == Restore atual ==	>> %LOG%\%LOG_START%
echo.						>> %LOG%\%LOG_START%

:: Procura no diret�rio de backup(FBAK) uma pe�a do banco(DBNAME);
:: Ao encontrar, � criado um arquivo temporado com o diret�rio absoluto
forfiles /S /P %FBAK% /m %DBNAME%*.bak /c "cmd /c echo @PATH> %TEMP%\peca_%DBNAME%.tmp"

:: Cria vari�vel para diret�rio absoluto DIR_BKP
set /p DIR_BKP=<%TEMP%\peca_%DBNAME%.tmp

echo - Nome Original da base : %DBNAME%		>> %LOG%\%LOG_START%
echo - Nome Restauracao da base: %NEW_NAME%	>> %LOG%\%LOG_START%
echo - Peca utilizada: %DIR_BKP:~1,-1%		>> %LOG%\%LOG_START%
echo - Data de inicio: %date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2% >> %LOG%\%LOG_START%

:: Chama o batch respons�vel por criar o Script de Restore(FileRestore.bat) passando os parametros necess�rio para execu��o
:: Par�metro 1: Nome do banco restaurado;
:: Par�metro 2: Log do processo;
:: Par�metro 3: Diret�rio absoluto da pe�a de backup;
:: Par�metro 4: Diret�rio para arquivos MDF;
:: Par�metro 5: Diret�rio para arquivos NDF;
:: Par�metro 6: Diret�rio para arquivos LDF;
:: Par�metro 7: Diret�rio para arquivos tempor�rios;
:: Par�metro 8: Nome do banco original.
call C:\app\DRS\source\FileRestore.bat %NEW_NAME% %LOG%\%LOG_START% %DIR_BKP:~1,-1% %DIR_MDF% %DIR_NDF% %DIR_LDF% %TEMP% %DBNAME%

echo - Status do restore: 					>> %LOG%\%LOG_START%
echo.										>> %LOG%\%LOG_START%

:: Executa o restore da pe�a selecionada com o novo nome por meio do script gerado pelo processo(ScriptRestore_MeuBanco.sql)
sqlcmd -S %INSTANCE_DEST% -d Traces -U %USER% -P %PASS% -h -1 -i %TEMP%\ScriptRestore_%DBNAME%.sql>> %LOG%\%LOG_START%

:: Remove o banco restarado do semaforo
sqlcmd -S %INSTANCE_PRD% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;DELETE FROM [dbo].[BACKUPQUEUE] WHERE NOME='%DBNAME%'" >> %LOG%\%LOG_START%

echo.										>> %LOG%\%LOG_START%

:: Executa a procedure sp_DropRestore respons�vel por dropar o banco restaurado
:: Par�metro 1: Nome do banco restaurado;
:: Par�metro 2: Usu�rio de restore;
sqlcmd -S %INSTANCE_DEST% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;exec Traces.dbo.sp_DropRestore '%NEW_NAME%','%USER%'" >> %LOG%\%LOG_START%

echo - Data de Termino: %date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2% >> %LOG%\%LOG_START%

echo.										>> %LOG%\%LOG_START%
echo == Fim do Restore ==					>> %LOG%\%LOG_START%
echo. 										>> %LOG%\%LOG_START%
echo. 										>> %LOG%\%LOG_START%

:: Volta para a verifica��o no semaforo.
goto :while

:exit

:: Limpa semaforo
sqlcmd -S %INSTANCE_PRD% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;DELETE FROM [dbo].[BACKUPQUEUE]" >> %LOG%\%LOG_START%

echo.										>> %LOG%\%LOG_START%
echo == Fim do processo. N�o existem bases para restaura��o. ==>>  %LOG%\%LOG_START%
echo. 										>> %LOG%\%LOG_START%
pause
exit