-- Lógica de Controle de Fase baseada em Limite de 1500 Membros
-- Este arquivo contém as funções SQL para controlar a fase de contratos pagos

-- Função para verificar se a fase deve estar ativa baseada na contagem de membros
DELIMITER //

CREATE FUNCTION should_activate_paid_contracts_phase()
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE member_count INT DEFAULT 0;
    DECLARE should_activate BOOLEAN DEFAULT FALSE;
    
    -- Contar membros ativos (não deletados)
    SELECT COUNT(*) INTO member_count 
    FROM members 
    WHERE deleted_at IS NULL;
    
    -- Ativar fase quando atingir ou exceder 1500 membros
    IF member_count >= 1500 THEN
        SET should_activate = TRUE;
    END IF;
    
    RETURN should_activate;
END //

-- Função para obter status da fase baseado na contagem
CREATE FUNCTION get_phase_status()
RETURNS JSON
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE member_count INT DEFAULT 0;
    DECLARE max_members INT DEFAULT 1500;
    DECLARE percentage DECIMAL(5,2) DEFAULT 0;
    DECLARE status VARCHAR(20) DEFAULT 'ok';
    DECLARE message VARCHAR(100) DEFAULT '';
    DECLARE should_activate BOOLEAN DEFAULT FALSE;
    DECLARE result JSON;
    
    -- Contar membros ativos
    SELECT COUNT(*) INTO member_count 
    FROM members 
    WHERE deleted_at IS NULL;
    
    -- Calcular porcentagem
    SET percentage = (member_count / max_members) * 100;
    
    -- Determinar status
    IF member_count > max_members THEN
        SET status = 'exceeded';
        SET message = 'Limite excedido';
        SET should_activate = TRUE;
    ELSEIF member_count >= max_members THEN
        SET status = 'reached';
        SET message = 'Limite atingido';
        SET should_activate = TRUE;
    ELSEIF percentage >= 80 THEN
        SET status = 'near';
        SET message = 'Próximo do limite';
        SET should_activate = FALSE;
    ELSE
        SET status = 'ok';
        SET message = 'Dentro do limite';
        SET should_activate = FALSE;
    END IF;
    
    -- Construir JSON de resposta
    SET result = JSON_OBJECT(
        'member_count', member_count,
        'max_members', max_members,
        'percentage', percentage,
        'status', status,
        'message', message,
        'should_activate_phase', should_activate,
        'can_register', member_count < max_members
    );
    
    RETURN result;
END //

-- Procedure para atualizar automaticamente a fase baseada na contagem
CREATE PROCEDURE update_phase_based_on_members()
BEGIN
    DECLARE member_count INT DEFAULT 0;
    DECLARE should_activate BOOLEAN DEFAULT FALSE;
    DECLARE current_phase_status VARCHAR(10) DEFAULT 'false';
    
    -- Contar membros ativos
    SELECT COUNT(*) INTO member_count 
    FROM members 
    WHERE deleted_at IS NULL;
    
    -- Determinar se deve ativar
    IF member_count >= 1500 THEN
        SET should_activate = TRUE;
    END IF;
    
    -- Verificar status atual da fase
    SELECT setting_value INTO current_phase_status
    FROM system_settings 
    WHERE setting_key = 'paid_contracts_phase_active';
    
    -- Atualizar apenas se necessário
    IF should_activate AND current_phase_status = 'false' THEN
        UPDATE system_settings 
        SET setting_value = 'true' 
        WHERE setting_key = 'paid_contracts_phase_active';
        
        SELECT 'Phase activated automatically' as message;
    ELSEIF NOT should_activate AND current_phase_status = 'true' THEN
        UPDATE system_settings 
        SET setting_value = 'false' 
        WHERE setting_key = 'paid_contracts_phase_active';
        
        SELECT 'Phase deactivated automatically' as message;
    ELSE
        SELECT 'No phase change needed' as message;
    END IF;
END //

DELIMITER ;

-- Exemplo de uso:
-- SELECT should_activate_paid_contracts_phase();
-- SELECT get_phase_status();
-- CALL update_phase_based_on_members();
