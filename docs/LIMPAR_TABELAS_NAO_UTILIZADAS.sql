-- =====================================================
-- LIMPAR TABELAS NÃO UTILIZADAS - ESTRUTURA UNIFICADA
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. TABELAS QUE PODEM SER REMOVIDAS
-- =====================================================

-- Com a nova estrutura unificada usando apenas a tabela 'members' 
-- com campo 'is_friend', as seguintes tabelas não são mais necessárias:

-- ❌ TABELAS PARA REMOVER:
-- - friends (substituída por members com is_friend = true)
-- - friend_referrals (não está sendo usada)
-- - paid_contracts (não está sendo usada)
-- - instagram_posts (não está sendo usada)
-- - v_friends_ranking (view baseada na tabela friends)

-- ✅ TABELAS QUE DEVEM PERMANECER:
-- - members (tabela principal unificada)
-- - user_links (links de cadastro)
-- - system_settings (configurações do sistema)
-- - auth_users (usuários de autenticação)
-- - users (compatibilidade - ainda sendo usada)
-- - cities (dados de cidades)
-- - sectors (dados de setores)
-- - phase_control (controle de fases)
-- - v_system_stats (estatísticas do sistema)

-- =====================================================
-- 2. VERIFICAR DEPENDÊNCIAS ANTES DE REMOVER
-- =====================================================

-- Verificar se há dados importantes nas tabelas antes de remover
SELECT 'friends' as tabela, COUNT(*) as registros FROM friends
UNION ALL
SELECT 'friend_referrals' as tabela, COUNT(*) as registros FROM friend_referrals
UNION ALL
SELECT 'paid_contracts' as tabela, COUNT(*) as registros FROM paid_contracts
UNION ALL
SELECT 'instagram_posts' as tabela, COUNT(*) as registros FROM instagram_posts;

-- =====================================================
-- 3. BACKUP DOS DADOS IMPORTANTES (OPCIONAL)
-- =====================================================

-- Se você quiser fazer backup dos dados antes de remover:
-- CREATE TABLE backup_friends AS SELECT * FROM friends;
-- CREATE TABLE backup_friend_referrals AS SELECT * FROM friend_referrals;
-- CREATE TABLE backup_paid_contracts AS SELECT * FROM paid_contracts;

-- =====================================================
-- 4. REMOVER TABELAS NÃO UTILIZADAS
-- =====================================================

-- ⚠️ ATENÇÃO: Execute apenas se tiver certeza de que não precisa dos dados!

-- Remover triggers primeiro (se existirem)
DROP TRIGGER IF EXISTS trg_update_friends_ranking ON friend_referrals;
DROP TRIGGER IF EXISTS trg_update_friends_ranking_update ON friend_referrals;

-- Remover funções (se existirem)
DROP FUNCTION IF EXISTS update_friends_ranking() CASCADE;

-- Remover views
DROP VIEW IF EXISTS v_friends_ranking;

-- Remover tabelas (em ordem de dependência)
DROP TABLE IF EXISTS friend_referrals CASCADE;
DROP TABLE IF EXISTS friends CASCADE;
DROP TABLE IF EXISTS paid_contracts CASCADE;
DROP TABLE IF EXISTS instagram_posts CASCADE;

-- =====================================================
-- 5. VERIFICAR TABELAS RESTANTES
-- =====================================================

-- Listar todas as tabelas restantes
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- =====================================================
-- 6. VERIFICAR SE A ESTRUTURA ESTÁ CORRETA
-- =====================================================

-- Verificar se a tabela members tem o campo is_friend
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'members' 
    AND column_name = 'is_friend';

-- Verificar quantos membros e amigos existem
SELECT 
    CASE 
        WHEN is_friend = true THEN 'Amigos (Contratos Pagos)'
        WHEN is_friend = false THEN 'Membros Normais'
        ELSE 'Não Definido'
    END as tipo,
    COUNT(*) as quantidade
FROM members 
GROUP BY is_friend
ORDER BY is_friend;

-- =====================================================
-- 7. LIMPEZA ADICIONAL (OPCIONAL)
-- =====================================================

-- Se você quiser remover também a tabela 'users' (que parece ser duplicada):
-- ⚠️ CUIDADO: Verifique se não há dados importantes primeiro!
-- DROP TABLE IF EXISTS users CASCADE;

-- =====================================================
-- 8. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se todas as tabelas necessárias estão presentes
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'members') 
        THEN '✅ Tabela members existe'
        ELSE '❌ Tabela members não encontrada'
    END as status_members,
    
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_links') 
        THEN '✅ Tabela user_links existe'
        ELSE '❌ Tabela user_links não encontrada'
    END as status_user_links,
    
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'system_settings') 
        THEN '✅ Tabela system_settings existe'
        ELSE '❌ Tabela system_settings não encontrada'
    END as status_system_settings;

-- =====================================================
-- RESUMO DAS TABELAS REMOVIDAS:
-- =====================================================
-- ❌ friends (substituída por members com is_friend)
-- ❌ friend_referrals (não utilizada)
-- ❌ paid_contracts (não utilizada)
-- ❌ instagram_posts (não utilizada)
-- ❌ v_friends_ranking (view baseada em friends)
-- 
-- ✅ TABELAS MANTIDAS:
-- ✅ members (tabela principal unificada)
-- ✅ user_links (links de cadastro)
-- ✅ system_settings (configurações)
-- ✅ auth_users (autenticação)
-- ✅ users (compatibilidade)
-- ✅ cities (dados de cidades)
-- ✅ sectors (dados de setores)
-- ✅ phase_control (controle de fases)
-- ✅ v_system_stats (estatísticas)
