-- =====================================================
-- IMPLEMENTAR SISTEMA DE SOFT DELETE (EXCLUSÃO LÓGICA)
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ADICIONAR CAMPO deleted_at NAS TABELAS PRINCIPAIS
-- =====================================================

-- Adicionar campo deleted_at na tabela members
ALTER TABLE members 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Adicionar campo deleted_at na tabela user_links
ALTER TABLE user_links 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Adicionar campo deleted_at na tabela users (se existir)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- =====================================================
-- 2. COMENTÁRIOS DAS COLUNAS
-- =====================================================

COMMENT ON COLUMN members.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';
COMMENT ON COLUMN user_links.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';
COMMENT ON COLUMN users.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';

-- =====================================================
-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para melhorar performance das consultas
CREATE INDEX IF NOT EXISTS idx_members_deleted_at ON members(deleted_at);
CREATE INDEX IF NOT EXISTS idx_user_links_deleted_at ON user_links(deleted_at);
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);

-- Índices compostos para consultas comuns
CREATE INDEX IF NOT EXISTS idx_members_active ON members(deleted_at, is_friend) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_user_links_active ON user_links(deleted_at, is_active) WHERE deleted_at IS NULL;

-- =====================================================
-- 4. FUNÇÃO PARA SOFT DELETE DE MEMBERS
-- =====================================================

CREATE OR REPLACE FUNCTION soft_delete_member(member_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar se o membro existe e não está excluído
    IF NOT EXISTS (
        SELECT 1 FROM members 
        WHERE id = member_id 
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Membro não encontrado ou já excluído';
    END IF;

    -- Marcar como excluído
    UPDATE members 
    SET deleted_at = NOW()
    WHERE id = member_id;

    -- Retornar sucesso
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. FUNÇÃO PARA SOFT DELETE DE USER_LINKS
-- =====================================================

CREATE OR REPLACE FUNCTION soft_delete_user_link(link_id_param TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verificar se o link existe e não está excluído
    IF NOT EXISTS (
        SELECT 1 FROM user_links 
        WHERE link_id = link_id_param 
        AND deleted_at IS NULL
    ) THEN
        RAISE EXCEPTION 'Link não encontrado ou já excluído';
    END IF;

    -- Marcar como excluído
    UPDATE user_links 
    SET deleted_at = NOW()
    WHERE link_id = link_id_param;

    -- Retornar sucesso
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;


-- =====================================================
-- 6. VIEW PARA MEMBERS ATIVOS (NÃO EXCLUÍDOS)
-- =====================================================

CREATE OR REPLACE VIEW v_active_members AS
SELECT 
    id,
    name,
    email,
    phone,
    city,
    sector,
    referrer,
    is_friend,
    contracts_completed,
    ranking_position,
    ranking_status,
    is_top_1500,
    can_be_replaced,
    created_at,
    updated_at
FROM members 
WHERE deleted_at IS NULL;

-- =====================================================
-- 7. VIEW PARA USER_LINKS ATIVOS (NÃO EXCLUÍDOS)
-- =====================================================

CREATE OR REPLACE VIEW v_active_user_links AS
SELECT 
    link_id,
    user_id,
    is_active,
    click_count,
    created_at,
    updated_at
FROM user_links 
WHERE deleted_at IS NULL;

-- =====================================================
-- 8. VERIFICAR SE AS COLUNAS FORAM ADICIONADAS
-- =====================================================

-- Verificar se as colunas foram criadas corretamente
SELECT 
    table_name,
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name IN ('members', 'user_links', 'users')
    AND column_name = 'deleted_at'
ORDER BY table_name;

-- =====================================================
-- 9. VERIFICAR FUNÇÕES CRIADAS
-- =====================================================

-- Verificar se as funções foram criadas
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
    AND routine_name LIKE '%soft_delete%'
ORDER BY routine_name;

-- =====================================================
-- 10. VERIFICAR VIEWS CRIADAS
-- =====================================================

-- Verificar se as views foram criadas
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_name LIKE 'v_%'
ORDER BY table_name;

-- =====================================================
-- 11. TESTE DAS FUNÇÕES (OPCIONAL)
-- =====================================================

-- Para testar as funções, você pode usar:
-- SELECT soft_delete_member('uuid-do-membro');
-- SELECT soft_delete_user_link('link-id');

-- =====================================================
-- RESUMO DA IMPLEMENTAÇÃO:
-- =====================================================
-- ✅ Campo deleted_at adicionado nas tabelas principais
-- ✅ Índices criados para melhorar performance
-- ✅ Funções de soft delete criadas
-- ✅ Views para membros ativos criadas
-- ✅ Sistema de exclusão lógica implementado
-- 
-- COMO USAR:
-- 1. Para excluir: SELECT soft_delete_member('uuid');
-- 2. Para consultar ativos: SELECT * FROM v_active_members;
-- 
-- NOTA: Membros excluídos não aparecem na interface, mas dados são mantidos no banco
