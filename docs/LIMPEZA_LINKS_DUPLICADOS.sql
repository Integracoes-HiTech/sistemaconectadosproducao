-- =====================================================
-- SCRIPT SQL PARA LIMPAR LINKS DUPLICADOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. Verificar links duplicados por user_id
SELECT 
    user_id,
    COUNT(*) as total_links,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_links
FROM user_links 
GROUP BY user_id 
HAVING COUNT(*) > 1
ORDER BY total_links DESC;

-- 2. Criar tabela temporária com links únicos (manter o mais antigo)
CREATE TEMP TABLE temp_unique_links AS
SELECT DISTINCT ON (user_id) 
    id,
    user_id,
    link_id,
    referrer_name,
    is_active,
    click_count,
    registration_count,
    created_at,
    expires_at,
    updated_at
FROM user_links 
ORDER BY user_id, created_at ASC;

-- 3. Verificar quantos links serão mantidos
SELECT COUNT(*) as links_to_keep FROM temp_unique_links;

-- 4. Verificar quantos links serão removidos
SELECT 
    (SELECT COUNT(*) FROM user_links) - (SELECT COUNT(*) FROM temp_unique_links) as links_to_remove;

-- 5. BACKUP: Criar backup dos links antes de deletar
CREATE TABLE user_links_backup AS 
SELECT * FROM user_links;

-- 6. Limpar tabela user_links
TRUNCATE TABLE user_links;

-- 7. Inserir apenas os links únicos
INSERT INTO user_links (
    id,
    user_id,
    link_id,
    referrer_name,
    is_active,
    click_count,
    registration_count,
    created_at,
    expires_at,
    updated_at
)
SELECT 
    id,
    user_id,
    link_id,
    referrer_name,
    is_active,
    click_count,
    registration_count,
    created_at,
    expires_at,
    updated_at
FROM temp_unique_links;

-- 8. Atualizar links para usar o formato user-{user_id}
UPDATE user_links 
SET link_id = 'user-' || user_id::text
WHERE link_id NOT LIKE 'user-%';

-- 9. Verificar resultado final
SELECT 
    user_id,
    link_id,
    referrer_name,
    is_active,
    click_count,
    registration_count,
    created_at
FROM user_links 
ORDER BY created_at DESC;

-- 10. Verificar se ainda há duplicatas
SELECT 
    user_id,
    COUNT(*) as total_links
FROM user_links 
GROUP BY user_id 
HAVING COUNT(*) > 1;

-- 11. Limpar tabela temporária
DROP TABLE temp_unique_links;

-- =====================================================
-- SCRIPT ADICIONAL: ATUALIZAR STATUS INATIVO POR PADRÃO
-- =====================================================

-- Atualizar todos os usuários criados recentemente para inativo (exceto admins)
UPDATE auth_users 
SET is_active = false 
WHERE is_active = true 
  AND role NOT IN ('admin', 'Administrador')
  AND created_at > NOW() - INTERVAL '1 day';

-- Verificar usuários inativos
SELECT 
    username,
    name,
    role,
    is_active,
    created_at
FROM auth_users 
WHERE is_active = false
ORDER BY created_at DESC;

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se as modificações foram aplicadas
SELECT 'Links únicos por usuário implementados!' as status;

-- Verificar usuários ativos vs inativos
SELECT 
    CASE WHEN is_active THEN 'Ativo' ELSE 'Inativo' END as status,
    COUNT(*) as total
FROM auth_users 
GROUP BY is_active;

-- Verificar links ativos
SELECT 
    COUNT(*) as total_links,
    COUNT(DISTINCT user_id) as unique_users
FROM user_links 
WHERE is_active = true;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
