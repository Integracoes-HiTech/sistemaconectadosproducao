-- =====================================================
-- TESTAR EXCLUSÃO EM CASCATA DE MEMBROS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR SE AS COLUNAS deleted_at EXISTEM
-- =====================================================

-- Verificar se a coluna deleted_at existe na tabela auth_users
SELECT 
    'VERIFICAR COLUNAS' as teste,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name IN ('auth_users', 'user_links', 'members')
AND column_name = 'deleted_at'
ORDER BY table_name;

-- =====================================================
-- 2. VERIFICAR SE AS FUNÇÕES EXISTEM
-- =====================================================

SELECT 
    'VERIFICAR FUNÇÕES' as teste,
    routine_name,
    routine_type
FROM information_schema.routines 
WHERE routine_name LIKE '%cascade%'
ORDER BY routine_name;

-- =====================================================
-- 2. VERIFICAR MEMBROS DISPONÍVEIS PARA TESTE
-- =====================================================

SELECT 
    'MEMBROS ATIVOS' as teste,
    id,
    name,
    referrer,
    status,
    deleted_at
FROM members 
WHERE deleted_at IS NULL 
ORDER BY created_at DESC
LIMIT 5;

-- =====================================================
-- 3. VERIFICAR AUTH_USERS CORRESPONDENTES
-- =====================================================

SELECT 
    'AUTH_USERS CORRESPONDENTES' as teste,
    au.id,
    au.name,
    au.role,
    au.deleted_at,
    m.id as member_id,
    m.name as member_name
FROM auth_users au
LEFT JOIN members m ON m.name = au.name
WHERE au.role IN ('Membro', 'Amigo')
AND au.deleted_at IS NULL
ORDER BY au.created_at DESC
LIMIT 5;

-- =====================================================
-- 4. VERIFICAR USER_LINKS CORRESPONDENTES
-- =====================================================

SELECT 
    'USER_LINKS CORRESPONDENTES' as teste,
    ul.id,
    ul.link_id,
    ul.user_id,
    ul.link_type,
    ul.deleted_at,
    au.name as auth_user_name,
    au.role as auth_user_role
FROM user_links ul
LEFT JOIN auth_users au ON au.id = ul.user_id
WHERE ul.deleted_at IS NULL
ORDER BY ul.created_at DESC
LIMIT 5;

-- =====================================================
-- 5. TESTAR FUNÇÃO DE VERIFICAÇÃO (SUBSTITUA O UUID)
-- =====================================================

-- Substitua 'UUID_DO_MEMBRO' pelo UUID real de um membro
-- SELECT check_member_cascade_deletion('UUID_DO_MEMBRO');

-- =====================================================
-- 6. VERIFICAR SE HÁ ERROS NAS FUNÇÕES
-- =====================================================

-- Testar se a função existe e pode ser chamada
SELECT 
    'TESTE FUNÇÃO' as teste,
    soft_delete_member_cascade('00000000-0000-0000-0000-000000000000'::UUID) as resultado;

-- =====================================================
-- 7. VERIFICAR LOGS DE ERRO (se houver)
-- =====================================================

-- Verificar se há mensagens de erro recentes
SELECT 
    'LOGS RECENTES' as teste,
    NOW() as timestamp,
    'Execute os testes acima para verificar o status' as mensagem;
