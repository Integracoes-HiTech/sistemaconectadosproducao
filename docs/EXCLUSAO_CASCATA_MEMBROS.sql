-- =====================================================
-- EXCLUSÃO EM CASCATA PARA MEMBROS
-- Quando um membro é excluído, também remove auth_users e user_links
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ADICIONAR COLUNA deleted_at NA TABELA auth_users (SE NÃO EXISTIR)
-- =====================================================

-- Adicionar campo deleted_at na tabela auth_users se não existir
ALTER TABLE auth_users 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Adicionar campo deleted_at na tabela user_links se não existir
ALTER TABLE user_links 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Comentários das colunas
COMMENT ON COLUMN auth_users.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';
COMMENT ON COLUMN user_links.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_auth_users_deleted_at ON auth_users(deleted_at);
CREATE INDEX IF NOT EXISTS idx_user_links_deleted_at ON user_links(deleted_at);

-- =====================================================
-- 2. FUNÇÃO PARA EXCLUSÃO EM CASCATA DE MEMBROS
-- =====================================================

-- Remover função existente se houver
DROP FUNCTION IF EXISTS soft_delete_member_cascade(UUID);

CREATE OR REPLACE FUNCTION soft_delete_member_cascade(member_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    member_name TEXT;
    auth_user_id UUID;
    links_count INTEGER;
BEGIN
    -- Verificar se o membro existe e não está excluído
    IF NOT EXISTS (
        SELECT 1 FROM members 
        WHERE id = member_id 
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Membro não encontrado ou já excluído';
    END IF;

    -- Buscar o nome do membro
    SELECT name INTO member_name
    FROM members 
    WHERE id = member_id;

    -- Buscar o auth_user correspondente pelo nome
    SELECT id INTO auth_user_id
    FROM auth_users 
    WHERE name = member_name 
    AND role IN ('Membro', 'Amigo')
    LIMIT 1;

    -- Se encontrou o auth_user, excluir em cascata
    IF auth_user_id IS NOT NULL THEN
        -- Contar quantos links serão excluídos
        SELECT COUNT(*) INTO links_count
        FROM user_links 
        WHERE user_id = auth_user_id 
        AND deleted_at IS NULL;

        -- Excluir user_links (exclusão física)
        DELETE FROM user_links 
        WHERE user_id = auth_user_id;

        -- Excluir auth_user (exclusão física)
        DELETE FROM auth_users 
        WHERE id = auth_user_id;

        -- Log da exclusão
        RAISE NOTICE 'Membro % excluído. Auth_user % excluído. % links excluídos.', 
            member_name, auth_user_id, links_count;
    ELSE
        -- Se não encontrou auth_user, apenas excluir o membro
        RAISE NOTICE 'Membro % excluído. Nenhum auth_user correspondente encontrado.', member_name;
    END IF;

    -- Excluir o membro (soft delete)
    UPDATE members 
    SET deleted_at = NOW()
    WHERE id = member_id;

    -- Retornar sucesso
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. FUNÇÃO PARA RESTAURAR MEMBRO (SEM AUTH_USERS E USER_LINKS)
-- =====================================================

-- Remover função existente se houver
DROP FUNCTION IF EXISTS restore_member_cascade(UUID);
DROP FUNCTION IF EXISTS restore_member_only(UUID);

CREATE OR REPLACE FUNCTION restore_member_only(member_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    member_name TEXT;
BEGIN
    -- Verificar se o membro existe e está excluído
    IF NOT EXISTS (
        SELECT 1 FROM members 
        WHERE id = member_id 
        AND deleted_at IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Membro não encontrado ou não está excluído';
    END IF;

    -- Buscar o nome do membro
    SELECT name INTO member_name
    FROM members 
    WHERE id = member_id;

    -- Restaurar apenas o membro (auth_users e user_links foram removidos fisicamente)
    UPDATE members 
    SET deleted_at = NULL
    WHERE id = member_id;

    -- Log da restauração
    RAISE NOTICE 'Membro % restaurado. Auth_users e user_links não podem ser restaurados (foram removidos fisicamente).', member_name;

    -- Retornar sucesso
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. FUNÇÃO PARA VERIFICAR EXCLUSÃO EM CASCATA
-- =====================================================

-- Remover função existente se houver
DROP FUNCTION IF EXISTS check_member_cascade_deletion(UUID);

CREATE OR REPLACE FUNCTION check_member_cascade_deletion(member_id UUID)
RETURNS TABLE(
    member_name TEXT,
    member_deleted_at TIMESTAMP WITH TIME ZONE,
    auth_user_exists BOOLEAN,
    links_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.name as member_name,
        m.deleted_at as member_deleted_at,
        CASE WHEN au.id IS NOT NULL THEN true ELSE false END as auth_user_exists,
        COUNT(ul.id) as links_count
    FROM members m
    LEFT JOIN auth_users au ON au.name = m.name AND au.role IN ('Membro', 'Amigo')
    LEFT JOIN user_links ul ON ul.user_id = au.id
    WHERE m.id = member_id
    GROUP BY m.name, m.deleted_at, au.id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. COMENTÁRIOS DAS FUNÇÕES
-- =====================================================

COMMENT ON FUNCTION soft_delete_member_cascade(UUID) IS 'Exclui membro (soft delete) e remove fisicamente auth_users e user_links';
COMMENT ON FUNCTION restore_member_only(UUID) IS 'Restaura apenas o membro (auth_users e user_links foram removidos fisicamente)';
COMMENT ON FUNCTION check_member_cascade_deletion(UUID) IS 'Verifica o status de exclusão de um membro e se auth_users ainda existem';

-- =====================================================
-- 5. TESTE DAS FUNÇÕES
-- =====================================================

-- Para testar, execute:
-- SELECT check_member_cascade_deletion('UUID_DO_MEMBRO_AQUI');
-- SELECT soft_delete_member_cascade('UUID_DO_MEMBRO_AQUI');
-- SELECT restore_member_cascade('UUID_DO_MEMBRO_AQUI');
