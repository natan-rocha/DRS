CREATE PROC sp_FileRestore(@ORIGEM NVARCHAR(MAX)
						  ,@DEST_MDF NVARCHAR(MAX),@DEST_NDF NVARCHAR(MAX),@DEST_LDF NVARCHAR(MAX))
AS
BEGIN

declare @SQL NVARCHAR(1000)

IF OBJECT_ID('tempdb..#backupdetails') IS NOT NULL DROP TABLE #backupdetails;
 
	CREATE TABLE #backupdetails
	  (
		 LogicalName          NVARCHAR(255),
		 PhysicalName         NVARCHAR(255),
		 Type                 NVARCHAR(1),
		 FileGroupName        NVARCHAR(255),
		 Size                 BIGINT,
		 MaxSize              BIGINT,
		 FileId               INT NULL,
		 CreateLSN            NUMERIC(25, 0) NULL,
		 DropLSN              NUMERIC(25, 0) NULL,
		 UniqueFileId         UNIQUEIDENTIFIER NULL,
		 readonlyLSN          NUMERIC(25, 0) NULL,
		 readwriteLSN         NUMERIC(25, 0) NULL,
		 BackupSizeInBytes    BIGINT NULL,
		 SourceBlkSize        INT NULL,
		 FileGroupId          INT NULL,
		 LogGroupGuid         UNIQUEIDENTIFIER NULL,
		 DifferentialBaseLsn  NUMERIC(25, 0) NULL,
		 DifferentialBaseGuid UNIQUEIDENTIFIER NULL,
		 IsReadOnly           BIT NULL,
		 IsPresent            BIT NULL,
		 TDEThumbprint        VARBINARY(32) NULL
		 ,SnapshotUrl  NVARCHAR(360)
	  ) 
 
	SET @SQL ='RESTORE FILELISTONLY FROM DISK=''' + @ORIGEM + ''''
 
	INSERT #backupdetails
	EXEC(@SQL);

	Select	CASE Type
			when 'D' then LTRIM(RTRIM(',MOVE '+CHAR(39)+LogicalName+CHAR(39)+' TO '+CHAR(39)+@DEST_MDF+'\'+LogicalName+'_DRS.mdf'+CHAR(39)))  
			when 'N' then LTRIM(RTRIM(',MOVE '+CHAR(39)+LogicalName+CHAR(39)+' TO '+CHAR(39)+@DEST_NDF+'\'+LogicalName+'_DRS.ndf'+CHAR(39)))
			when 'L' then LTRIM(RTRIM(',MOVE '+CHAR(39)+LogicalName+CHAR(39)+' TO '+CHAR(39)+@DEST_LDF+'\'+LogicalName+'_DRS.ldf'+CHAR(39)))
			end as nome
			from #backupdetails

DROP TABLE #backupdetails;

END;
