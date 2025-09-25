-- ATUALIZAR TABELA USER_LINKS
-- Script para atualizar todos os links existentes baseado na configuração do sistema

-- 1. VERIFICAR CONFIGURAÇÃO ATUAL DO SISTEMA
SELECT 
    'CONFIGURAÇÃO ATUAL' as tipo,
    setting_value as tipo_links_atual
FROM system_settings 
WHERE setting_key = 'member_links_type';

-- 2. VERIFICAR ESTADO ATUAL DOS LINKS
SELECT 
    'ESTADO ATUAL DOS LINKS' as tipo,
    link_type,
    COUNT(*) as quantidade
FROM user_links 
GROUP BY link_type
ORDER BY link_type;

-- 3. BUSCAR UUID DO ADMIN
SELECT 
    'UUID DO ADMIN' as tipo,
    id as admin_uuid,
    username,
    full_name
FROM auth_users 
WHERE username = 'admin' OR full_name ILIKE '%admin%'
LIMIT 1;

-- 4. VERIFICAR LINKS DO ADMIN (NÃO DEVEM SER ALTERADOS)
-- Substitua 'ADMIN_UUID_AQUI' pelo UUID real do admin
SELECT 
    'LINKS DO ADMIN' as tipo,
    user_id,
    link_type,
    COUNT(*) as quantidade
FROM user_links 
WHERE user_id = (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1)
GROUP BY user_id, link_type;

-- 5. ATUALIZAR LINKS PARA 'FRIENDS' (EXCETO ADMIN)
-- Execute apenas se a configuração for 'friends'
UPDATE user_links 
SET 
    link_type = 'friends',
    updated_at = NOW()
WHERE 
    link_type = 'members' 
    AND user_id != (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1);

-- 6. ATUALIZAR LINKS PARA 'MEMBERS' (EXCETO ADMIN)
-- Execute apenas se a configuração for 'members'
UPDATE user_links 
SET 
    link_type = 'members',
    updated_at = NOW()
WHERE 
    link_type = 'friends' 
    AND user_id != (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1);

-- 6. VERIFICAR RESULTADO APÓS ATUALIZAÇÃO
SELECT 
    'RESULTADO APÓS ATUALIZAÇÃO' as tipo,
    link_type,
    COUNT(*) as quantidade
FROM user_links 
GROUP BY link_type
ORDER BY link_type;

-- 7. VERIFICAR SE ADMIN PERMANECEU COMO 'MEMBERS'
SELECT 
    'ADMIN APÓS ATUALIZAÇÃO' as tipo,
    user_id,
    link_type,
    COUNT(*) as quantidade
FROM user_links 
WHERE user_id = (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1)
GROUP BY user_id, link_type;

-- 8. RESUMO GERAL
SELECT 
    'RESUMO GERAL' as tipo,
    COUNT(*) as total_links,
    COUNT(CASE WHEN link_type = 'members' THEN 1 END) as links_members,
    COUNT(CASE WHEN link_type = 'friends' THEN 1 END) as links_friends,
    COUNT(CASE WHEN user_id = 'admin' THEN 1 END) as links_admin
FROM user_links;

-- 9. SCRIPT AUTOMÁTICO BASEADO NA CONFIGURAÇÃO
-- Este script atualiza automaticamente baseado na configuração atual
DO $$
DECLARE
    current_setting TEXT;
    updated_count INTEGER;
BEGIN
    -- Buscar configuração atual
    SELECT setting_value INTO current_setting
    FROM system_settings 
    WHERE setting_key = 'member_links_type';
    
    RAISE NOTICE 'Configuração atual: %', current_setting;
    
    -- Atualizar baseado na configuração
    IF current_setting = 'friends' THEN
        -- Atualizar todos os links 'members' para 'friends' (exceto admin)
        UPDATE user_links 
        SET 
            link_type = 'friends',
            updated_at = NOW()
        WHERE 
            link_type = 'members' 
            AND user_id != (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1);
        
        GET DIAGNOSTICS updated_count = ROW_COUNT;
        RAISE NOTICE 'Atualizados % links para FRIENDS (exceto admin)', updated_count;
        
    ELSIF current_setting = 'members' THEN
        -- Atualizar todos os links 'friends' para 'members' (exceto admin)
        UPDATE user_links 
        SET 
            link_type = 'members',
            updated_at = NOW()
        WHERE 
            link_type = 'friends' 
            AND user_id != (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1);
        
        GET DIAGNOSTICS updated_count = ROW_COUNT;
        RAISE NOTICE 'Atualizados % links para MEMBERS (exceto admin)', updated_count;
        
    ELSE
        RAISE NOTICE 'Configuração não reconhecida: %', current_setting;
    END IF;
    
    -- Verificar resultado
    RAISE NOTICE 'Links atualizados com sucesso!';
END $$;

-- 10. VERIFICAÇÃO FINAL
SELECT 
    'VERIFICAÇÃO FINAL' as tipo,
    link_type,
    COUNT(*) as quantidade,
    CASE 
        WHEN user_id = (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1) THEN 'ADMIN'
        ELSE 'MEMBROS'
    END as tipo_usuario
FROM user_links 
GROUP BY link_type, CASE WHEN user_id = (SELECT id FROM auth_users WHERE username = 'admin' LIMIT 1) THEN 'ADMIN' ELSE 'MEMBROS' END
ORDER BY link_type, tipo_usuario;
