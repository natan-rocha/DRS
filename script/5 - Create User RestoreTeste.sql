USE [master]
GO
CREATE LOGIN [RestoreTeste] WITH PASSWORD=N'RestoreTeste', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER SERVER ROLE [dbcreator] ADD MEMBER [RestoreTeste]
GO
use [Traces]
GO
use [master]
GO
USE [Traces]
GO
CREATE USER [RestoreTeste] FOR LOGIN [RestoreTeste]
GO
USE [Traces]
GO
ALTER ROLE [db_owner] ADD MEMBER [RestoreTeste]
GO