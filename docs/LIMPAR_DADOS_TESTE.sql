-- =====================================================
-- SCRIPT PARA LIMPAR DADOS DE TESTE
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. LIMPEZA COMPLETA DOS DADOS DE TESTE
-- =====================================================

-- Limpar user_links de teste (manter apenas admin)
DELETE FROM user_links 
WHERE user_id != (SELECT id FROM auth_users WHERE username = 'admin');

-- Limpar friends de teste
DELETE FROM friends 
WHERE referrer != 'Admin';

-- Limpar members de teste (manter apenas Admin)
DELETE FROM members 
WHERE name != 'Admin';

-- Limpar auth_users de teste (manter apenas admin)
DELETE FROM auth_users 
WHERE username != 'admin';

-- =====================================================
-- 2. VERIFICAÇÃO DA LIMPEZA
-- =====================================================

-- Verificar quantos registros restaram
SELECT 'MEMBROS RESTANTES' as tipo, COUNT(*) as total FROM members;
SELECT 'AMIGOS RESTANTES' as tipo, COUNT(*) as total FROM friends;
SELECT 'AUTH_USERS RESTANTES' as tipo, COUNT(*) as total FROM auth_users;
SELECT 'USER_LINKS RESTANTES' as tipo, COUNT(*) as total FROM user_links;

-- =====================================================
-- 3. VERIFICAR SE RESTOU APENAS O ADMIN
-- =====================================================

-- Verificar se restou apenas o Admin
SELECT 
    'VERIFICAÇÃO FINAL' as tipo,
    CASE 
        WHEN COUNT(*) = 1 AND MAX(name) = 'Admin' THEN '✅ APENAS ADMIN RESTANTE'
        ELSE '❌ AINDA HÁ DADOS DE TESTE'
    END as status
FROM members;

-- =====================================================
-- RESUMO:
-- =====================================================
/*
ESTE SCRIPT LIMPA:

✅ user_links: Remove todos exceto admin
✅ friends: Remove todos exceto Admin
✅ members: Remove todos exceto Admin  
✅ auth_users: Remove todos exceto admin

RESULTADO ESPERADO:
- Apenas 1 membro (Admin)
- Apenas 1 auth_user (admin)
- Apenas 1 user_link (admin)
- 0 amigos
- Sistema limpo para novos testes
*/
