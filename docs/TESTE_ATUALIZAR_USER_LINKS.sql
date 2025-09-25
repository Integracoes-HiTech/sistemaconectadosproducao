-- TESTE SIMPLES PARA VERIFICAR SE O SCRIPT ESTÁ FUNCIONANDO
-- Execute este script primeiro para testar

-- 1. VERIFICAR SE A TABELA AUTH_USERS EXISTE E TEM O ADMIN
SELECT 
    'VERIFICAÇÃO INICIAL' as tipo,
    COUNT(*) as total_auth_users,
    COUNT(CASE WHEN username = 'admin' THEN 1 END) as admin_count
FROM auth_users;

-- 2. VERIFICAR SE O ADMIN EXISTE
SELECT 
    'ADMIN ENCONTRADO' as tipo,
    id as admin_uuid,
    username,
    full_name,
    role
FROM auth_users 
WHERE username = 'admin'
LIMIT 1;

-- 3. VERIFICAR CONFIGURAÇÃO ATUAL DO SISTEMA
SELECT 
    'CONFIGURAÇÃO ATUAL' as tipo,
    setting_value as tipo_links_atual
FROM system_settings 
WHERE setting_key = 'member_links_type';

-- 4. VERIFICAR ESTADO ATUAL DOS LINKS
SELECT 
    'ESTADO ATUAL DOS LINKS' as tipo,
    link_type,
    COUNT(*) as quantidade
FROM user_links 
GROUP BY link_type
ORDER BY link_type;

-- 5. VERIFICAR LINKS DO ADMIN
SELECT 
    'LINKS DO ADMIN' as tipo,
    user_id,
    link_type,
    COUNT(*) as quantidade
FROM user_links 
WHERE user_id = (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1)
GROUP BY user_id, link_type;
