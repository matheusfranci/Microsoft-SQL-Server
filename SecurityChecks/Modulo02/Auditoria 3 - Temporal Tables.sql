USE [Auditoria]
GO

----------------------------------------------------
-- -- Quais tabelas s�o temporais na minha base?
----------------------------------------------------

SELECT
    A.[name],
    A.[object_id],
    A.temporal_type,
    A.temporal_type_desc,
    A.history_table_id,
    B.[name]
FROM
    sys.tables A
    LEFT JOIN sys.tables B ON B.[object_id] = A.history_table_id
WHERE
    A.temporal_type <> 0
ORDER BY
    A.[name]


----------------------------------------------------
-- Como criar uma Tabela Temporal (Versionada)?
----------------------------------------------------

IF (OBJECT_ID('dbo.Tabela_Temporal') IS NOT NULL) 
BEGIN
    ALTER TABLE dbo.Tabela_Temporal SET (SYSTEM_VERSIONING=OFF)
    ALTER TABLE dbo.Tabela_Temporal DROP PERIOD FOR SYSTEM_TIME;
    
	ALTER TABLE dbo.Tabela_Temporal DROP COLUMN Dt_Inicio, Dt_Fim;
    IF (OBJECT_ID('dbo.Tabela_Temporal_Historico') IS NOT NULL) DROP TABLE dbo.Tabela_Temporal_Historico

    DROP TABLE dbo.Tabela_Temporal

END


CREATE TABLE dbo.Tabela_Temporal (
    
    -- Dados normais da tabela
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ds_Nome VARCHAR(100) NOT NULL,
    Dt_Nascimento DATETIME NOT NULL,
    Nr_Telefone VARCHAR(15) NOT NULL,
    Nr_CPF VARCHAR(14) NOT NULL,

    -- Informa��es referentes ao versionamento (Temporal table)
    Dt_Inicio DATETIME2(0) GENERATED ALWAYS AS ROW START, 
    Dt_Fim DATETIME2(0) GENERATED ALWAYS AS ROW END, 
    PERIOD FOR SYSTEM_TIME (Dt_Inicio, Dt_Fim)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Tabela_Temporal_Historico))



----------------------------------------------------
-- Como converter uma tabela comum para Tabela Temporal?
----------------------------------------------------

IF (OBJECT_ID('dbo.Tabela_Comum') IS NOT NULL) 
BEGIN
    ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=OFF);
    ALTER TABLE dbo.Tabela_Comum DROP PERIOD FOR SYSTEM_TIME;

    DROP TABLE dbo.Tabela_Comum
END


CREATE TABLE dbo.Tabela_Comum (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ds_Nome VARCHAR(100) NOT NULL,
    Dt_Nascimento DATETIME NOT NULL,
    Nr_Telefone VARCHAR(15) NOT NULL,
    Nr_CPF VARCHAR(14) NOT NULL,
) WITH(DATA_COMPRESSION=PAGE)

INSERT INTO dbo.Tabela_Comum
VALUES ( 'Dirceu Resende', '1987-05-28', '111111', '22222' )


-- Crio as colunas de metadados para controlar a validade dos registros
ALTER TABLE dbo.Tabela_Comum ADD 
    Dt_Inicio DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL, 
    Dt_Fim DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (Dt_Inicio, Dt_Fim)


-- Ativo o versionamento na tabela
ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=ON (HISTORY_TABLE = dbo.Tabela_Comum_Historico))



----------------------------------------------------
-- E se a tabela j� possuir registros ?
----------------------------------------------------

-- Cria��o normal de uma tabela
IF (OBJECT_ID('dbo.Tabela_Comum') IS NOT NULL) 
BEGIN
    ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=OFF)
    DROP TABLE dbo.Tabela_Comum
END


CREATE TABLE dbo.Tabela_Comum (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ds_Nome VARCHAR(100) NOT NULL,
    Dt_Nascimento DATETIME NOT NULL,
    Nr_Telefone VARCHAR(15) NOT NULL,
    Nr_CPF VARCHAR(14) NOT NULL,
) WITH(DATA_COMPRESSION=PAGE)


INSERT INTO dbo.Tabela_Comum
(
    Ds_Nome,
    Dt_Nascimento,
    Nr_Telefone,
    Nr_CPF
)
VALUES
(
    'Dirceu Resende', -- Ds_Nome - varchar(100)
    '1990-01-01', -- Dt_Nascimento - datetime
    '2799999999', -- Nr_Telefone - varchar(15)
    '11111111111' -- Nr_CPF - varchar(14)
)


-- Crio as colunas de metadados para controlar a validade dos registros
ALTER TABLE dbo.Tabela_Comum ADD 
    Dt_Inicio DATETIME2 GENERATED ALWAYS AS ROW START CONSTRAINT DF_Tabela_Comum_Dt_Inicio DEFAULT SYSUTCDATETIME() NOT NULL, 
    Dt_Fim DATETIME2 GENERATED ALWAYS AS ROW END CONSTRAINT DF_Tabela_Comum_Dt_Fim DEFAULT '9999-12-31 23:59:59.9999999' NOT NULL,
    PERIOD FOR SYSTEM_TIME (Dt_Inicio, Dt_Fim)



-- Ativo o versionamento na tabela
ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=ON (HISTORY_TABLE = dbo.Tabela_Comum_Historico))



----------------------------------------------------
-- Como consultar os dados da Tabela Temporal?
----------------------------------------------------

INSERT INTO dbo.Tabela_Temporal
(
    Ds_Nome,
    Dt_Nascimento,
    Nr_Telefone,
    Nr_CPF
)
VALUES
(
    'Dirceu Resende', -- Ds_Nome - varchar(100)
    '1900-05-28', -- Dt_Nascimento - datetime
    '2799999999', -- Nr_Telefone - varchar(15)
    '12345678909'
),
(
    'Teste 2', -- Ds_Nome - varchar(100)
    '1900-01-01', -- Dt_Nascimento - datetime
    '27888888888', -- Nr_Telefone - varchar(15)
    '11111111111'
)
GO

UPDATE dbo.Tabela_Temporal
SET Ds_Nome = 'Teste'
WHERE Ds_Nome = 'Teste 2'
GO

UPDATE dbo.Tabela_Temporal
SET Nr_CPF = '22222222222'
WHERE Ds_Nome = 'Dirceu Resende'
GO

DELETE FROM dbo.Tabela_Temporal
WHERE Ds_Nome = 'Teste'
GO


-- Consulta b�sica
SELECT * FROM dbo.Tabela_Temporal


-- Retorna todas as altera��es realizadas na tabela
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME ALL
ORDER BY Dt_Inicio, Id


-- Retorna todas as altera��es numa data espec�fica
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME AS OF '2020-12-16 12:02:00'
ORDER BY Dt_Inicio, Id


-- Retorna todas as altera��es num intervalo de tempo (Dt_Inicial < data final informada e 
-- campo Dt_Final > data inicial informada)
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME FROM '2020-12-16 12:02:00' TO '2020-12-16 12:03:01'
ORDER BY Dt_Inicio, Id


-- Retorna todas as altera��es num intervalo de datas (Dt_Inicial <= data final informada e 
-- campo Dt_Final > data inicial informada)
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME BETWEEN '2020-12-16 12:02:00' AND '2020-12-16 12:03:01'
ORDER BY Dt_Inicio, Id


-- Retorna todas as altera��es num intervalo de datas (Dt_Inicial >= data inicial informada e 
-- campo Dt_Final <= data final informada)
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME CONTAINED IN('2020-12-16 12:02:00', '9999-12-31 23:59:59')
ORDER BY Dt_Inicio, Id


----------------------------------------------------
-- Como desativar o versionamento de uma Tabela Temporal?
----------------------------------------------------

-- Desativa temporariamente
ALTER TABLE dbo.Tabela_Temporal SET (SYSTEM_VERSIONING = OFF);

-- Remove os metadados da tabela temporal
ALTER TABLE dbo.Tabela_Temporal DROP PERIOD FOR SYSTEM_TIME;

-- Apaga as colunas de controle temporal na tabela original
ALTER TABLE dbo.Tabela_Temporal DROP COLUMN Dt_Inicio, Dt_Fim;

-- Apaga a tabela de hist�rico
IF (OBJECT_ID('dbo.Tabela_Temporal_Historico') IS NOT NULL) DROP TABLE dbo.Tabela_Temporal_Historico


----------------------------------------------------
-- Como fazer expurgo dos dados
----------------------------------------------------

ALTER TABLE dbo.Tabela_Temporal SET (SYSTEM_VERSIONING = OFF)
GO

DELETE FROM dbo.Tabela_Temporal_Historico
WHERE Dt_Fim <= DATEADD(DAY, -30, GETDATE())

ALTER TABLE dbo.Tabela_Temporal
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Tabela_Temporal_Historico], DATA_CONSISTENCY_CHECK = ON))


-- REFER�NCIA
-- https://www.dirceuresende.com/blog/sql-server-2016-como-viajar-no-tempo-utilizando-o-recurso-temporal-tables/


