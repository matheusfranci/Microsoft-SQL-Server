ALTER DATABASE ARQUIMEDESDB	MODIFY FILE	(NAME ='ARQUIMEDESDB_log', FILENAME = 'G:\MSSQL\TESS\LOG\ARQUIMEDESDB_log.ldf'); GO
ALTER DATABASE BI MODIFY FILE (NAME ='BI_log', FILENAME = 'G:\MSSQL\TESS\LOG\BI_log.ldf'); GO
ALTER DATABASE BKPGPE MODIFY FILE (NAME ='BKPGPE_log',	FILENAME = 'G:\MSSQL\TESS\LOG\BKPGPE_log.ldf'); GO
ALTER DATABASE BROCKTON	MODIFY FILE	(NAME ='BROCKTON_log', FILENAME = 'G:\MSSQL\TESS\LOG\BROCKTON_log.ldf'); GO


ALTER DATABASE CONTROLE	MODIFY FILE	(NAME ='CONTROLE_log', FILENAME = 'G:\MSSQL\TESS\LOG\CONTROLE_log.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_01', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_log2.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_02', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_log13.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_03', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_log14.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_04', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_log15.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_05', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_log16.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_200', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_log23.ldf'); GO
ALTER DATABASE DADOSADV	MODIFY FILE	(NAME ='DADOSADV_Log_06', FILENAME = 'G:\MSSQL\TESS\LOG\DADOSADV_Log_06.ldf'); GO

-- Verificação
SELECT 
    mdf.database_id, 
    mdf.name, 
    mdf.physical_name as data_file, 
    ldf.physical_name as log_file, 
    db_size = CAST((mdf.size * 8.0)/1024 AS DECIMAL(8,2)), 
    log_size = CAST((ldf.size * 8.0 / 1024) AS DECIMAL(8,2))
FROM (SELECT * FROM sys.master_files WHERE type_desc = 'ROWS' ) mdf
JOIN (SELECT * FROM sys.master_files WHERE type_desc = 'LOG' ) ldf
ON mdf.database_id = ldf.database_id

-- Verificação apenas dos mdf's

SELECT 
mdf.database_id, 
mdf.name, 
mdf.physical_name as data_file
FROM (SELECT * FROM sys.master_files WHERE type_desc = 'ROWS' ) mdf;