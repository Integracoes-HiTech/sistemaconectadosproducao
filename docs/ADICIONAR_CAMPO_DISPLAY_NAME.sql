-- =====================================================
-- ADICIONAR CAMPO display_name NA TABELA AUTH_USERS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ADICIONAR CAMPO display_name NA TABELA AUTH_USERS
-- =====================================================

-- Adicionar coluna display_name na tabela auth_users
ALTER TABLE auth_users 
ADD COLUMN IF NOT EXISTS display_name VARCHAR(255);

-- =====================================================
-- 2. COMENTÁRIO DA COLUNA
-- =====================================================

COMMENT ON COLUMN auth_users.display_name IS 'Nome de exibição personalizado escolhido pelo usuário';

-- =====================================================
-- 3. VERIFICAR SE A COLUNA FOI ADICIONADA
-- =====================================================

-- Verificar se a coluna foi criada corretamente
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'auth_users' 
    AND column_name = 'display_name';

-- =====================================================
-- 4. ATUALIZAR REGISTROS EXISTENTES (OPCIONAL)
-- =====================================================

-- Se você quiser definir o display_name baseado no name para registros existentes
-- UPDATE auth_users SET display_name = name WHERE display_name IS NULL;

-- =====================================================
-- 5. VERIFICAR DADOS APÓS ATUALIZAÇÃO
-- =====================================================

-- Verificar quantos usuários têm display_name definido
SELECT 
    CASE 
        WHEN display_name IS NOT NULL THEN 'Com nome personalizado'
        ELSE 'Sem nome personalizado'
    END as status,
    COUNT(*) as quantidade
FROM auth_users 
GROUP BY (display_name IS NOT NULL)
ORDER BY (display_name IS NOT NULL);

-- =====================================================
-- RESUMO:
-- =====================================================
-- ✅ Adicionada coluna display_name na tabela auth_users
-- ✅ Campo opcional para nome de exibição personalizado
-- ✅ Usuários podem escolher como querem ser chamados no sistema
