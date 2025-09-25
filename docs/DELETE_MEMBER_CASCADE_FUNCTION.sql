-- Função para deletar membro com cascade (soft delete do membro, hard delete de links e auth_users)
DELIMITER //

CREATE PROCEDURE delete_member_with_cascade(
    IN p_member_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
BEGIN
    DECLARE member_exists INT DEFAULT 0;
    DECLARE auth_user_id INT DEFAULT NULL;
    DECLARE user_link_id VARCHAR(255) DEFAULT NULL;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Erro ao deletar membro com cascade';
    END;
    
    START TRANSACTION;
    
    -- Verificar se o membro existe e não está deletado
    SELECT COUNT(*) INTO member_exists 
    FROM members 
    WHERE id = p_member_id AND deleted_at IS NULL;
    
    IF member_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Membro não encontrado ou já foi excluído';
        ROLLBACK;
    ELSE
        -- Buscar o auth_user_id do membro
        SELECT au.id INTO auth_user_id
        FROM auth_users au
        JOIN members m ON au.username = REPLACE(m.instagram, '@', '')
        WHERE m.id = p_member_id AND m.deleted_at IS NULL
        LIMIT 1;
        
        -- Se encontrou auth_user, buscar user_link
        IF auth_user_id IS NOT NULL THEN
            SELECT ul.id INTO user_link_id
            FROM user_links ul
            WHERE ul.user_id = auth_user_id
            LIMIT 1;
            
            -- Deletar user_link permanentemente
            IF user_link_id IS NOT NULL THEN
                DELETE FROM user_links WHERE id = user_link_id;
                SET p_message = CONCAT('Membro deletado. User link ', user_link_id, ' removido permanentemente.');
            END IF;
            
            -- Deletar auth_user permanentemente
            DELETE FROM auth_users WHERE id = auth_user_id;
            SET p_message = CONCAT(IFNULL(p_message, 'Membro deletado. '), 'Auth user ', auth_user_id, ' removido permanentemente.');
        ELSE
            SET p_message = 'Membro deletado (sem auth_user associado).';
        END IF;
        
        -- Soft delete do membro (apenas deleted_at)
        UPDATE members 
        SET deleted_at = NOW() 
        WHERE id = p_member_id;
        
        SET p_success = TRUE;
        
        COMMIT;
    END IF;
END //

DELIMITER ;
