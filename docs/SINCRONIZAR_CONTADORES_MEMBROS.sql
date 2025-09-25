-- =====================================================
-- SCRIPT: SINCRONIZAR CONTADORES DE MEMBROS
-- =====================================================
-- Este script cria funções para sincronizar automaticamente
-- os contadores de contratos dos membros baseado nos amigos cadastrados
-- =====================================================

-- Função para sincronizar contadores de um membro específico
CREATE OR REPLACE FUNCTION sync_member_counters(member_name TEXT)
RETURNS void AS $$
DECLARE
    member_record RECORD;
    friends_count INTEGER;
    new_status TEXT;
BEGIN
    -- Buscar o membro
    SELECT id, name, contracts_completed, ranking_status
    INTO member_record
    FROM members 
    WHERE name = member_name 
    AND status = 'Ativo' 
    AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RAISE NOTICE 'Membro % não encontrado', member_name;
        RETURN;
    END IF;
    
    -- Contar amigos ativos do membro
    SELECT COUNT(*)
    INTO friends_count
    FROM friends 
    WHERE referrer = member_name 
    AND status = 'Ativo' 
    AND deleted_at IS NULL;
    
    -- Calcular novo status
    new_status := CASE
        WHEN friends_count >= 15 THEN 'Verde'
        WHEN friends_count >= 1 THEN 'Amarelo'
        ELSE 'Vermelho'
    END;
    
    -- Atualizar contadores do membro
    UPDATE members 
    SET 
        contracts_completed = friends_count,
        ranking_status = new_status,
        updated_at = NOW()
    WHERE id = member_record.id;
    
    RAISE NOTICE 'Membro %: % contratos → % contratos, Status: % → %', 
        member_name, 
        member_record.contracts_completed, 
        friends_count,
        member_record.ranking_status,
        new_status;
        
END;
$$ LANGUAGE plpgsql;

-- Função para sincronizar contadores de todos os membros
CREATE OR REPLACE FUNCTION sync_all_members_counters()
RETURNS void AS $$
DECLARE
    member_record RECORD;
    friends_count INTEGER;
    new_status TEXT;
BEGIN
    -- Para cada membro ativo
    FOR member_record IN 
        SELECT id, name, contracts_completed, ranking_status
        FROM members 
        WHERE status = 'Ativo' 
        AND deleted_at IS NULL
    LOOP
        -- Contar amigos ativos do membro
        SELECT COUNT(*)
        INTO friends_count
        FROM friends 
        WHERE referrer = member_record.name 
        AND status = 'Ativo' 
        AND deleted_at IS NULL;
        
        -- Calcular novo status
        new_status := CASE
            WHEN friends_count >= 15 THEN 'Verde'
            WHEN friends_count >= 1 THEN 'Amarelo'
            ELSE 'Vermelho'
        END;
        
        -- Atualizar contadores do membro
        UPDATE members 
        SET 
            contracts_completed = friends_count,
            ranking_status = new_status,
            updated_at = NOW()
        WHERE id = member_record.id;
        
        RAISE NOTICE 'Membro %: % contratos → % contratos, Status: % → %', 
            member_record.name, 
            member_record.contracts_completed, 
            friends_count,
            member_record.ranking_status,
            new_status;
    END LOOP;
    
    -- Atualizar ranking de todos os membros
    PERFORM update_complete_ranking();
    
    RAISE NOTICE 'Sincronização de contadores concluída';
END;
$$ LANGUAGE plpgsql;

-- Função para verificar inconsistências nos contadores
CREATE OR REPLACE FUNCTION check_counters_inconsistency()
RETURNS TABLE(
    member_name TEXT,
    current_contracts INTEGER,
    actual_friends INTEGER,
    status_mismatch BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.name,
        m.contracts_completed,
        COALESCE(f.friends_count, 0)::INTEGER,
        (m.contracts_completed != COALESCE(f.friends_count, 0)) AS status_mismatch
    FROM members m
    LEFT JOIN (
        SELECT 
            referrer,
            COUNT(*) as friends_count
        FROM friends 
        WHERE status = 'Ativo' 
        AND deleted_at IS NULL
        GROUP BY referrer
    ) f ON m.name = f.referrer
    WHERE m.status = 'Ativo' 
    AND m.deleted_at IS NULL
    ORDER BY m.name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TESTES E EXEMPLOS DE USO
-- =====================================================

-- 1. Verificar inconsistências antes da sincronização
-- SELECT * FROM check_counters_inconsistency();

-- 2. Sincronizar contadores de um membro específico
-- SELECT sync_member_counters('Antonio Netto');

-- 3. Sincronizar contadores de todos os membros
-- SELECT sync_all_members_counters();

-- 4. Verificar inconsistências após a sincronização
-- SELECT * FROM check_counters_inconsistency();

-- =====================================================
-- TRIGGERS AUTOMÁTICOS (OPCIONAL)
-- =====================================================

-- Trigger para atualizar contadores automaticamente quando um amigo é inserido
CREATE OR REPLACE FUNCTION trigger_update_member_counters_on_friend_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar contadores do membro referrer
    PERFORM sync_member_counters(NEW.referrer);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar contadores automaticamente quando um amigo é atualizado
CREATE OR REPLACE FUNCTION trigger_update_member_counters_on_friend_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o status ou referrer mudou, atualizar contadores
    IF OLD.status != NEW.status OR OLD.referrer != NEW.referrer THEN
        -- Atualizar contadores do referrer antigo (se mudou)
        IF OLD.referrer != NEW.referrer THEN
            PERFORM sync_member_counters(OLD.referrer);
        END IF;
        -- Atualizar contadores do referrer novo
        PERFORM sync_member_counters(NEW.referrer);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar contadores automaticamente quando um amigo é deletado (soft delete)
CREATE OR REPLACE FUNCTION trigger_update_member_counters_on_friend_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar contadores do membro referrer
    PERFORM sync_member_counters(OLD.referrer);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Criar os triggers (descomente se quiser ativação automática)
-- DROP TRIGGER IF EXISTS trigger_friend_insert ON friends;
-- CREATE TRIGGER trigger_friend_insert
--     AFTER INSERT ON friends
--     FOR EACH ROW
--     EXECUTE FUNCTION trigger_update_member_counters_on_friend_insert();

-- DROP TRIGGER IF EXISTS trigger_friend_update ON friends;
-- CREATE TRIGGER trigger_friend_update
--     AFTER UPDATE ON friends
--     FOR EACH ROW
--     EXECUTE FUNCTION trigger_update_member_counters_on_friend_update();

-- DROP TRIGGER IF EXISTS trigger_friend_delete ON friends;
-- CREATE TRIGGER trigger_friend_delete
--     AFTER UPDATE ON friends
--     FOR EACH ROW
--     WHEN (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL)
--     EXECUTE FUNCTION trigger_update_member_counters_on_friend_delete();

-- =====================================================
-- COMENTÁRIOS FINAIS
-- =====================================================

-- Este script fornece:
-- 1. Função para sincronizar contadores de um membro específico
-- 2. Função para sincronizar contadores de todos os membros
-- 3. Função para verificar inconsistências
-- 4. Triggers automáticos (opcionais) para manter sincronização
-- 5. Exemplos de uso e testes

-- Use estas funções quando necessário para manter os contadores sincronizados
-- ou execute manualmente quando detectar inconsistências nos dados.
