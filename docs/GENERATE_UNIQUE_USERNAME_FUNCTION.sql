-- Função para gerar username único baseado no Instagram
-- Remove @ e caracteres especiais, adiciona sufixo numérico se necessário

DELIMITER //

CREATE FUNCTION generate_unique_username(instagram_input VARCHAR(255))
RETURNS VARCHAR(255)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE base_username VARCHAR(255);
    DECLARE final_username VARCHAR(255);
    DECLARE counter INT DEFAULT 0;
    DECLARE username_exists INT DEFAULT 1;
    
    -- Limpar o Instagram: remover @ e caracteres especiais, converter para minúsculas
    SET base_username = LOWER(REGEXP_REPLACE(instagram_input, '[^a-zA-Z0-9]', ''));
    
    -- Garantir que não está vazio
    IF base_username = '' THEN
        SET base_username = 'user';
    END IF;
    
    -- Limitar tamanho (máximo 20 caracteres para deixar espaço para sufixo)
    IF CHAR_LENGTH(base_username) > 20 THEN
        SET base_username = LEFT(base_username, 20);
    END IF;
    
    -- Tentar o username base primeiro
    SET final_username = base_username;
    
    -- Verificar se existe e adicionar sufixo numérico se necessário
    WHILE username_exists > 0 DO
        SELECT COUNT(*) INTO username_exists 
        FROM auth_users 
        WHERE username COLLATE utf8mb4_unicode_ci = final_username COLLATE utf8mb4_unicode_ci;
        
        IF username_exists > 0 THEN
            SET counter = counter + 1;
            SET final_username = CONCAT(base_username, '_', counter);
            
            -- Limitar tentativas para evitar loop infinito
            IF counter > 9999 THEN
                SET final_username = CONCAT(base_username, '_', UNIX_TIMESTAMP());
                SET username_exists = 0;
            END IF;
        END IF;
    END WHILE;
    
    RETURN final_username;
END //

DELIMITER ;

-- Função para gerar password baseado no Instagram e telefone
DELIMITER //

CREATE FUNCTION generate_password(instagram_input VARCHAR(255), phone_input VARCHAR(20))
RETURNS VARCHAR(255)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE clean_instagram VARCHAR(255);
    DECLARE last_four_digits VARCHAR(4);
    
    -- Limpar Instagram: remover @ e caracteres especiais
    SET clean_instagram = REGEXP_REPLACE(instagram_input, '[^a-zA-Z0-9]', '');
    
    -- Pegar últimos 4 dígitos do telefone
    SET last_four_digits = RIGHT(REGEXP_REPLACE(phone_input, '[^0-9]', ''), 4);
    
    -- Se não tiver 4 dígitos, usar '0000'
    IF CHAR_LENGTH(last_four_digits) < 4 THEN
        SET last_four_digits = '0000';
    END IF;
    
    RETURN CONCAT(clean_instagram, last_four_digits);
END //

DELIMITER ;

-- Procedure para criar usuário com credenciais baseadas nos dados do membro
DELIMITER //

CREATE PROCEDURE create_user_from_member(
    IN p_member_id INT,
    OUT p_username VARCHAR(255),
    OUT p_password VARCHAR(255),
    OUT p_user_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE member_instagram VARCHAR(255);
    DECLARE member_phone VARCHAR(20);
    DECLARE member_name VARCHAR(255);
    DECLARE member_referrer VARCHAR(255);
    DECLARE clean_instagram VARCHAR(255);
    DECLARE last_four_digits VARCHAR(4);
    DECLARE counter INT DEFAULT 0;
    DECLARE username_exists INT DEFAULT 1;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Erro ao criar usuário de autenticação';
        SET p_username = NULL;
        SET p_password = NULL;
        SET p_user_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Buscar dados do membro
    SELECT instagram, phone, name, referrer 
    INTO member_instagram, member_phone, member_name, member_referrer
    FROM members 
    WHERE id = p_member_id;
    
    -- Verificar se o membro existe
    IF member_instagram IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Membro não encontrado';
        SET p_username = NULL;
        SET p_password = NULL;
        SET p_user_id = NULL;
        ROLLBACK;
    ELSE
    
    -- Gerar username: Instagram sem @
    SET clean_instagram = REGEXP_REPLACE(member_instagram, '[^a-zA-Z0-9]', '');
    SET p_username = clean_instagram;
    
    -- Verificar se username já existe e adicionar sufixo se necessário
    WHILE username_exists > 0 DO
        SELECT COUNT(*) INTO username_exists 
        FROM auth_users 
        WHERE username COLLATE utf8mb4_unicode_ci = p_username COLLATE utf8mb4_unicode_ci;
        
        IF username_exists > 0 THEN
            SET counter = counter + 1;
            SET p_username = CONCAT(clean_instagram, '_', counter);
            
            -- Limitar tentativas
            IF counter > 9999 THEN
                SET p_username = CONCAT(clean_instagram, '_', UNIX_TIMESTAMP());
                SET username_exists = 0;
            END IF;
        END IF;
    END WHILE;
    
    -- Gerar password: Instagram + últimos 4 dígitos do telefone
    SET last_four_digits = RIGHT(REGEXP_REPLACE(member_phone, '[^0-9]', ''), 4);
    IF CHAR_LENGTH(last_four_digits) < 4 THEN
        SET last_four_digits = '0000';
    END IF;
    SET p_password = CONCAT(clean_instagram, last_four_digits);
    
    -- Inserir usuário na tabela auth_users
    INSERT INTO auth_users (
        username, 
        password, 
        name, 
        role, 
        full_name, 
        instagram, 
        phone, 
        is_active,
        created_at,
        updated_at
    ) VALUES (
        p_username,
        p_password,
        member_name,
        'Membro',
        CONCAT(member_name, ' - Membro'),
        member_instagram,
        member_phone,
        FALSE, -- Status inativo por padrão
        NOW(),
        NOW()
    );
    
    -- Obter o ID do usuário criado
    SET p_user_id = LAST_INSERT_ID();
    
    SET p_success = TRUE;
    SET p_message = 'Usuário criado com sucesso';
    
    COMMIT;
    END IF;
END //

DELIMITER ;
