-- Função para atualizar status e contadores do membro após cadastro de amigo
-- Esta função será chamada automaticamente sempre que um amigo for cadastrado

DELIMITER //

CREATE PROCEDURE update_member_after_friend_registration(
    IN p_member_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE member_exists INT DEFAULT 0;
    DECLARE current_contracts INT DEFAULT 0;
    DECLARE new_ranking_status VARCHAR(20);
    DECLARE new_ranking_position INT;
    DECLARE total_members INT DEFAULT 0;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Erro ao atualizar membro após cadastro de amigo';
    END;
    
    START TRANSACTION;
    
    -- Verificar se o membro existe
    SELECT COUNT(*) INTO member_exists 
    FROM members 
    WHERE id = p_member_id;
    
    IF member_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Membro não encontrado';
        ROLLBACK;
    ELSE
        -- Contar quantos amigos o membro já cadastrou
        SELECT COUNT(*) INTO current_contracts 
        FROM friends 
        WHERE member_id = p_member_id AND deleted_at IS NULL;
        
        -- Determinar novo status baseado no número de contratos
        IF current_contracts >= 15 THEN
            SET new_ranking_status = 'Verde';
        ELSEIF current_contracts >= 1 THEN
            SET new_ranking_status = 'Amarelo';
        ELSE
            SET new_ranking_status = 'Vermelho';
        END IF;
        
        -- Calcular nova posição no ranking (baseado no número de contratos)
        SELECT COUNT(*) + 1 INTO new_ranking_position
        FROM members m
        WHERE m.contracts_completed > current_contracts
        AND m.deleted_at IS NULL;
        
        -- Atualizar o membro com novos dados
        UPDATE members 
        SET 
            contracts_completed = current_contracts,
            ranking_status = new_ranking_status,
            ranking_position = new_ranking_position,
            updated_at = NOW()
        WHERE id = p_member_id;
        
        -- Recalcular posições de todos os membros para manter ranking correto
        UPDATE members m
        SET ranking_position = (
            SELECT COUNT(*) + 1
            FROM members m2
            WHERE m2.contracts_completed > m.contracts_completed
            AND m2.deleted_at IS NULL
        )
        WHERE m.deleted_at IS NULL;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Membro atualizado: ', current_contracts, ' contratos, status: ', new_ranking_status, ', posição: ', new_ranking_position);
        
        COMMIT;
    END IF;
    
END //

DELIMITER ;

-- Trigger para chamar automaticamente a procedure quando um amigo for inserido
DELIMITER //

CREATE TRIGGER after_friend_insert
AFTER INSERT ON friends
FOR EACH ROW
BEGIN
    DECLARE success BOOLEAN DEFAULT FALSE;
    DECLARE message VARCHAR(500) DEFAULT '';
    
    -- Chamar a procedure para atualizar o membro
    CALL update_member_after_friend_registration(NEW.member_id, success, message);
    
    -- Log do resultado (opcional)
    INSERT INTO system_logs (action, details, created_at) 
    VALUES ('friend_registered', CONCAT('Amigo cadastrado para membro ID: ', NEW.member_id, ' - ', message), NOW());
    
END //

DELIMITER ;
