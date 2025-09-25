-- =====================================================
-- FUNÇÃO MYSQL PARA GERAR LINK ÚNICO
-- Equivalente à função generate_unique_link do Supabase
-- =====================================================

DELIMITER $$

-- Função para gerar link único no MySQL
CREATE FUNCTION generate_unique_link(user_username VARCHAR(255))
RETURNS VARCHAR(500)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE link_id VARCHAR(500);
    DECLARE link_exists INT DEFAULT 1;
    DECLARE attempts INT DEFAULT 0;
    DECLARE max_attempts INT DEFAULT 100;
    
    -- Loop para gerar link único
    WHILE link_exists > 0 AND attempts < max_attempts DO
        -- Gerar link usando username + timestamp + random
        SET link_id = CONCAT(
            user_username, 
            '-', 
            UNIX_TIMESTAMP(NOW()), 
            '-', 
            LPAD(FLOOR(RAND() * 10000), 4, '0')
        );
        
        -- Verificar se o link já existe
        SELECT COUNT(*) INTO link_exists 
        FROM user_links 
        WHERE link_id = link_id;
        
        SET attempts = attempts + 1;
        
        -- Pequena pausa para evitar timestamps idênticos
        IF link_exists > 0 THEN
            SET @sleep_time = RAND() * 0.001;
            DO SLEEP(@sleep_time);
        END IF;
    END WHILE;
    
    -- Se não conseguiu gerar link único após max_attempts
    IF attempts >= max_attempts THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não foi possível gerar link único após múltiplas tentativas';
    END IF;
    
    RETURN link_id;
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE PARA GERAR E INSERIR LINK ÚNICO
-- Combina geração e inserção em uma operação atômica
-- =====================================================

DELIMITER $$

CREATE PROCEDURE generate_and_insert_user_link(
    IN p_user_id VARCHAR(255),
    IN p_user_username VARCHAR(255),
    IN p_link_type VARCHAR(50),
    OUT p_link_id VARCHAR(500),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Erro ao gerar link único';
        RESIGNAL;
    END;
    
    DECLARE EXIT HANDLER FOR SQLWARNING
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Aviso durante geração do link';
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Desativar todos os links antigos do usuário
    UPDATE user_links 
    SET is_active = 0, updated_at = NOW() 
    WHERE user_id = p_user_id;
    
    -- Gerar novo link único
    SET p_link_id = generate_unique_link(p_user_username);
    
    -- Inserir novo link
    INSERT INTO user_links (
        link_id, 
        user_id, 
        link_type, 
        is_active, 
        created_at, 
        updated_at
    ) VALUES (
        p_link_id,
        p_user_id,
        p_link_type,
        1,
        NOW(),
        NOW()
    );
    
    COMMIT;
    
    SET p_success = TRUE;
    SET p_message = 'Link gerado com sucesso';
    
END$$

DELIMITER ;

-- =====================================================
-- PROCEDURE PARA VERIFICAR E RETORNAR LINK EXISTENTE
-- Verifica se usuário já tem link ativo e retorna
-- =====================================================

DELIMITER $$

CREATE PROCEDURE get_or_generate_user_link(
    IN p_user_id VARCHAR(255),
    IN p_user_username VARCHAR(255),
    IN p_link_type VARCHAR(50),
    OUT p_link_id VARCHAR(500),
    OUT p_is_existing BOOLEAN,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE existing_link_id VARCHAR(500);
    DECLARE link_count INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_message = 'Erro ao processar link do usuário';
        RESIGNAL;
    END;
    
    -- Verificar se usuário já tem link ativo
    SELECT link_id INTO existing_link_id
    FROM user_links 
    WHERE user_id = p_user_id 
    AND is_active = 1 
    ORDER BY created_at DESC 
    LIMIT 1;
    
    -- Verificar se encontrou link existente
    SELECT COUNT(*) INTO link_count
    FROM user_links 
    WHERE user_id = p_user_id 
    AND is_active = 1;
    
    IF link_count > 0 THEN
        -- Usuário já tem link ativo
        SET p_link_id = existing_link_id;
        SET p_is_existing = TRUE;
        SET p_success = TRUE;
        SET p_message = 'Link existente retornado';
    ELSE
        -- Usuário não tem link ativo, gerar novo
        CALL generate_and_insert_user_link(
            p_user_id, 
            p_user_username, 
            p_link_type, 
            p_link_id, 
            p_success, 
            p_message
        );
        SET p_is_existing = FALSE;
    END IF;
    
END$$

DELIMITER ;

-- =====================================================
-- TESTES DA FUNÇÃO
-- =====================================================

-- Teste 1: Gerar link único
-- SELECT generate_unique_link('joao') as link_gerado;

-- Teste 2: Verificar se função detecta duplicatas
-- SELECT generate_unique_link('teste') as link1, generate_unique_link('teste') as link2;

-- Teste 3: Usar procedure completa
-- CALL get_or_generate_user_link('3', 'admin', 'members', @link_id, @is_existing, @success, @message);
-- SELECT @link_id, @is_existing, @success, @message;

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se as funções foram criadas
SELECT 'Funções MySQL criadas com sucesso!' as status;

-- Mostrar funções criadas
SHOW FUNCTION STATUS WHERE Name LIKE '%generate%';
SHOW PROCEDURE STATUS WHERE Name LIKE '%link%';
