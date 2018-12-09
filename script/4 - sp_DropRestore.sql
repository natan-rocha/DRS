CREATE PROC sp_DropRestore(@BANCO VARCHAR(MAX)
						  ,@OWNER VARCHAR(MAX))
AS
BEGIN

if exists(select suser_sname(owner_sid) Owner, create_date
            from sys.databases 
           where name = @BANCO
             and suser_sname(owner_sid)=@OWNER
             and create_date >= DATEADD(hh, -2, GETDATE()))
begin
	EXEC  ('DROP DATABASE '+@BANCO)
	select '- Banco '+@BANCO+' eliminado' as Info
end
else
	select 'Banco de dados não existe ou usuário sem permissão para esta operação' as Info

END;