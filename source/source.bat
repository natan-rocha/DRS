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

:: Remove espaços em branco da DB_RESTORE e agora DBNAME é o banco de dados da restauração.
for /f "tokens=* delims= " %%A in ('echo %DB_RESTORE%') do set DBNAME=%%A
set DBNAME=%DBNAME:~0,-1%

:: Se não existir nenhum banco no semaforo, o script irá encontrar a palavra "none"
:: Sendo assim o processo é encerrado
:: Caso exista um banco, NEW_NAME será o nome do banco restaurado. Ex: MeuBanco_DRS
if %DBNAME%==none (
	goto :exit
) else (	
	SET "NEW_NAME=%DBNAME%_DRS"
	goto :restore
)

:restore
echo == Restore atual ==	>> %LOG%\%LOG_START%
echo.						>> %LOG%\%LOG_START%

:: Procura no diretório de backup(FBAK) uma peça do banco(DBNAME);
:: Ao encontrar, é criado um arquivo temporado com o diretório absoluto
forfiles /S /P %FBAK% /m %DBNAME%*.bak /c "cmd /c echo @PATH> %TEMP%\peca_%DBNAME%.tmp"

:: Cria variável para diretório absoluto DIR_BKP
set /p DIR_BKP=<%TEMP%\peca_%DBNAME%.tmp

echo - Nome Original da base : %DBNAME%		>> %LOG%\%LOG_START%
echo - Nome Restauracao da base: %NEW_NAME%	>> %LOG%\%LOG_START%
echo - Peca utilizada: %DIR_BKP:~1,-1%		>> %LOG%\%LOG_START%
echo - Data de inicio: %date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2% >> %LOG%\%LOG_START%

:: Chama o batch responsável por criar o Script de Restore(FileRestore.bat) passando os parametros necessário para execução
:: Parâmetro 1: Nome do banco restaurado;
:: Parâmetro 2: Log do processo;
:: Parâmetro 3: Diretório absoluto da peça de backup;
:: Parâmetro 4: Diretório para arquivos MDF;
:: Parâmetro 5: Diretório para arquivos NDF;
:: Parâmetro 6: Diretório para arquivos LDF;
:: Parâmetro 7: Diretório para arquivos temporários;
:: Parâmetro 8: Nome do banco original.
call C:\app\DRS\source\FileRestore.bat %NEW_NAME% %LOG%\%LOG_START% %DIR_BKP:~1,-1% %DIR_MDF% %DIR_NDF% %DIR_LDF% %TEMP% %DBNAME%

echo - Status do restore: 					>> %LOG%\%LOG_START%
echo.										>> %LOG%\%LOG_START%

:: Executa o restore da peça selecionada com o novo nome por meio do script gerado pelo processo(ScriptRestore_MeuBanco.sql)
sqlcmd -S %INSTANCE_DEST% -d Traces -U %USER% -P %PASS% -h -1 -i %TEMP%\ScriptRestore_%DBNAME%.sql>> %LOG%\%LOG_START%

:: Remove o banco restarado do semaforo
sqlcmd -S %INSTANCE_PRD% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;DELETE FROM [dbo].[BACKUPQUEUE] WHERE NOME='%DBNAME%'" >> %LOG%\%LOG_START%

echo.										>> %LOG%\%LOG_START%

:: Executa a procedure sp_DropRestore responsável por dropar o banco restaurado
:: Parâmetro 1: Nome do banco restaurado;
:: Parâmetro 2: Usuário de restore;
sqlcmd -S %INSTANCE_DEST% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;exec Traces.dbo.sp_DropRestore '%NEW_NAME%','%USER%'" >> %LOG%\%LOG_START%

echo - Data de Termino: %date:~-4%_%date:~3,2%_%date:~0,2%_%time:~0,2%_%time:~3,2%_%time:~6,2% >> %LOG%\%LOG_START%

echo.										>> %LOG%\%LOG_START%
echo == Fim do Restore ==					>> %LOG%\%LOG_START%
echo. 										>> %LOG%\%LOG_START%
echo. 										>> %LOG%\%LOG_START%

:: Volta para a verificação no semaforo.
goto :while

:exit

:: Limpa semaforo
sqlcmd -S %INSTANCE_PRD% -d Traces -U %USER% -P %PASS% -h -1 -Q "SET NOCOUNT ON;DELETE FROM [dbo].[BACKUPQUEUE]" >> %LOG%\%LOG_START%

echo.										>> %LOG%\%LOG_START%
echo == Fim do processo. Não existem bases para restauração. ==>>  %LOG%\%LOG_START%
echo. 										>> %LOG%\%LOG_START%
pause
exit