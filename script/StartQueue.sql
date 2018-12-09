:setvar SQLCMDMAXVARTYPEWIDTH 30
:setvar SQLCMDMAXFIXEDTYPEWIDTH 30
SET NOCOUNT ON; 

DECLARE @QUERY NVARCHAR(MAX)
DECLARE @COUNT INT
DECLARE @CntCommand NVARCHAR(MAX);
DECLARE @DAYS NVARCHAR(MAX);

SET @DAYS=-48

SET @QUERY=N'SELECT msdb.dbo.backupset.database_name  
  FROM    msdb.dbo.backupset 
 WHERE     msdb.dbo.backupset.type = ''D''
   and msdb.dbo.backupset.database_name not in (''master'',''tempdb'',''msdb'',''model'')
 GROUP BY msdb.dbo.backupset.database_name 
HAVING      (MAX(msdb.dbo.backupset.backup_finish_date) > DATEADD(hh, '+ @DAYS +', GETDATE()))'

SET @CntCommand = 'SELECT @count = COUNT(*) FROM (' + @QUERY + ') x'

EXEC sp_executesql @CntCommand, N'@COUNT INT OUTPUT', @COUNT=@COUNT OUTPUT;

IF @COUNT > 0
begin
insert into [Traces].[dbo].[BACKUPQUEUE] EXEC(@QUERY);
end
ELSE
begin
insert into [Traces].[dbo].[BACKUPQUEUE] (nome) values ('none ')
end

select * from  [Traces].[dbo].[BACKUPQUEUE] 