@echo off

:: Nome do cliente
SET "CLIENT=Natan Rocha"

:: Instância Produção
SET "INSTANCE_PRD=HOME\LAB"

:: Instância Destino
SET "INSTANCE_DEST=HOME\LAB_TESTE"

:: Usuário de restore
SET "USER=RestoreTeste"

:: Senha usuário de restore
SET "PASS=RestoreTeste"

:: Diretório das peças de backup
SET "FBAK=D:\backup"

:: Diretório raiz
SET "ROOT=C:\app\DRS"

:: Diretório arquivos de log
SET "LOG=%ROOT%\log"

:: Diretório arquivos temporários
SET "TEMP=%ROOT%\temp"

:: Diretório arquivos executaveis
SET "SOURCE=%ROOT%\source"

:: Diretório arquivos configuração
SET	"CONFIG=%ROOT%\config"

:: Diretório arquivos scripts
SET	"SCRIPT=%ROOT%\script"

:: Diretório arquivos MDF
SET DIR_MDF=C:\app\DRS\

:: Diretório arquivos NDF
SET DIR_NDF=C:\app\DRS\

:: Diretório arquivos LDF
SET DIR_LDF=C:\app\DRS\
