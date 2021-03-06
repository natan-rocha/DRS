:setvar SQLCMDMAXVARTYPEWIDTH 30
:setvar SQLCMDMAXFIXEDTYPEWIDTH 30
SET NOCOUNT ON; 

DECLARE @QUERY NVARCHAR(MAX)
DECLARE @COUNT INT
DECLARE @CntCommand NVARCHAR(MAX);

SET @QUERY=N'SELECT TOP 1 * FROM BACKUPQUEUE'

SET @CntCommand = 'SELECT @count = COUNT(*) FROM (' + @QUERY + ') x'

EXEC sp_executesql @CntCommand, N'@COUNT INT OUTPUT', @COUNT=@COUNT OUTPUT;

IF @COUNT > 0
begin
	EXEC(@QUERY);
end
ELSE
begin
	SELECT 'none ' as nome;
end
