CREATE DATABASE halloween;

USE halloween;

CREATE TABLE usuario (
	id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome_usuario VARCHAR (150),
    email VARCHAR (100),
    idade INT
);


DELIMITER $$

CREATE PROCEDURE insereusuariosaleatorios()
BEGIN
    DECLARE i INT DEFAULT 0;
    
    
    WHILE i < 10000 DO
        
        SET @nome := CONCAT('usuario', i);
        SET @email := CONCAT('usuario', i, '@exemplo.com');
        SET @idade := FLOOR(RAND() * 80) + 18;  -- Gera uma idade entre 18 e 97 anos
        
        
        INSERT INTO tabela_usuarios (nome_usuario, email, idade) VALUES (@nome, @email, @idade);
        
        SET i = i + 1;
    END WHILE;
END$$ 


DELIMITER ;
