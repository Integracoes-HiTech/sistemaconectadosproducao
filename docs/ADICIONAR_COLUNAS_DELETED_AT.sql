-- =====================================================
-- ADICIONAR COLUNAS deleted_at NECESSÁRIAS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ADICIONAR COLUNA deleted_at NA TABELA auth_users
-- =====================================================

-- Verificar se a coluna já existe
SELECT 
    'VERIFICAR ANTES' as status,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'auth_users' 
AND column_name = 'deleted_at';

-- Adicionar coluna se não existir
ALTER TABLE auth_users 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- =====================================================
-- 2. ADICIONAR COLUNA deleted_at NA TABELA user_links
-- =====================================================

-- Verificar se a coluna já existe
SELECT 
    'VERIFICAR ANTES' as status,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name = 'user_links' 
AND column_name = 'deleted_at';

-- Adicionar coluna se não existir
ALTER TABLE user_links 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- =====================================================
-- 3. VERIFICAR SE AS COLUNAS FORAM ADICIONADAS
-- =====================================================

SELECT 
    'VERIFICAR DEPOIS' as status,
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN ('auth_users', 'user_links', 'members')
AND column_name = 'deleted_at'
ORDER BY table_name;

-- =====================================================
-- 4. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para melhorar performance das consultas
CREATE INDEX IF NOT EXISTS idx_auth_users_deleted_at ON auth_users(deleted_at);
CREATE INDEX IF NOT EXISTS idx_user_links_deleted_at ON user_links(deleted_at);

-- =====================================================
-- 5. COMENTÁRIOS DAS COLUNAS
-- =====================================================

COMMENT ON COLUMN auth_users.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';
COMMENT ON COLUMN user_links.deleted_at IS 'Data e hora da exclusão lógica. NULL = não excluído, TIMESTAMP = excluído';

-- =====================================================
-- 6. VERIFICAR RESULTADO FINAL
-- =====================================================

SELECT 
    'RESULTADO FINAL' as status,
    'Colunas deleted_at adicionadas com sucesso!' as mensagem,
    NOW() as timestamp;
