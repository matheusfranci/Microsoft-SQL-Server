USE [master]
GO

CREATE LOGIN [teste] WITH PASSWORD=N'aaa', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-- Utilizar senha aleatória de 4 números (para testes)
CREATE LOGIN [teste_senha] WITH PASSWORD='0156', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
























SELECT 
	[name],
    password_hash
FROM
    sys.sql_logins
    

SELECT LoginProperty('dirceu.resende', 'PasswordHash')


SELECT PWDCOMPARE('teste', 0x0200469FD739185EF9E4083AD773C0F708376F53BF4A984B9ADA0D21668BF10AF53E2AE218AD9BAC59A2218C5804DAD5DD59A079A6DD14923AF6D6BC99982CF2614F9C52B760)
SELECT PWDCOMPARE('dirceu', 0x0200469FD739185EF9E4083AD773C0F708376F53BF4A984B9ADA0D21668BF10AF53E2AE218AD9BAC59A2218C5804DAD5DD59A079A6DD14923AF6D6BC99982CF2614F9C52B760)



























SET NOCOUNT ON


IF (OBJECT_ID('tempdb..#Senhas') IS NOT NULL) DROP TABLE #Senhas
CREATE TABLE #Senhas (
    Senha VARCHAR(100)
)

-- Gera as senhas (maiúsculas e números)
DECLARE @Caracteres TABLE ( Caractere VARCHAR(1) )

DECLARE 
    @Contador INT = 48, -- 33
    @Total INT = 57 -- 165

WHILE(@Contador < @Total)
BEGIN

	IF (@Contador NOT IN (127, 134, 143, 145, 146, 152, 153, 154, 155, 156, 157, 158, 159))
	BEGIN
	
		INSERT INTO @Caracteres
		VALUES(CHAR(@Contador))

	END

	SET @Contador += 1

END


INSERT INTO #Senhas
SELECT * FROM @Caracteres



SET @Contador = 1
SET @Total = 4

WHILE(@Contador <= @Total)
BEGIN
	
	INSERT INTO #Senhas
	SELECT 
		A.Senha + B.Caractere
	FROM
		#Senhas A
		JOIN @Caracteres B ON 1=1

	
	SET @Contador += 1

END



-- Inserindo senhas mais comuns (pesquisei no google)
INSERT INTO #Senhas
VALUES 
    ('teste'), ('TESTE'), ('password'), ('qwerty'),
    ('football'), ('baseball'), ('welcome'), ('abc123'),
    ('1qaz2wsx'), ('dragon'), ('master'), ('monkey'), ('letmein'),
    ('login'), ('princess'), ('qwertyuiop'), ('solo'), ('passw0rd'), 
    ('starwars'), ('teste123'), ('TESTE123'), ('deuseamor'), ('jesuscristo'),
    ('iloveyou'), ('MARCELO'), ('jc2512'), ('maria'), ('jose'), ('batman'),
    ('123123'), ('123123123'), ('FaMiLia'), (''), (' '), ('sexy'),
    ('abel123'), ('freedom'), ('whatever'), ('qazwsx'), ('trustno1'), ('sucesso'),
    ('1q2w3e4r'), ('1qaz2wsx'), ('1qazxsw2'), ('zaq12wsx'), ('! qaz2wsx'),
    ('!qaz2wsx'), ('123mudar'), ('gabriel'), ('102030'), ('010203'), ('101010'), ('131313'),
    ('vitoria'), ('flamengo'), ('felipe'), ('brasil'), ('felicidade'), ('mariana'), ('101010')
    

-- Logins
INSERT INTO #Senhas
SELECT [name]
FROM sys.sql_logins

INSERT INTO #Senhas
SELECT LOWER([name])
FROM sys.sql_logins

INSERT INTO #Senhas
SELECT UPPER([name])
FROM sys.sql_logins


SELECT DISTINCT
    A.[name],
    B.Senha
FROM 
    sys.sql_logins			A
    CROSS APPLY #Senhas		B
WHERE
	PWDCOMPARE(B.Senha, A.password_hash) = 1

	






-- https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?redirectedfrom=MSDN&view=sql-server-ver15
-- https://howsecureismypassword.net/
-- https://haveibeenpwned.com/Passwords
-- https://www.my1login.com/resources/password-strength-test/
-- http://www.passwordmeter.com/

-- https://www.lastpass.com/pt/password-generator
-- https://www.4devs.com.br/gerador_de_senha



