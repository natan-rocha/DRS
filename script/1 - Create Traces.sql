CREATE DATABASE [Traces] 
ON  PRIMARY ( 
NAME = N'Traces', FILENAME = N'C:\app\DRS\temp\Traces.mdf' , 
SIZE = 500 MB , FILEGROWTH = 500 MB 
)
LOG ON ( 
NAME = N'Traces_log', FILENAME = N'C:\app\DRS\temp\Traces_log.ldf' , 
SIZE = 100 MB , FILEGROWTH = 100 MB 
)

ALTER DATABASE [Traces] SET RECOVERY SIMPLE;