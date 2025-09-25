-- =====================================================
-- VERIFICAR SE O TRIGGER DE CONTRATOS ESTÁ FUNCIONANDO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR SE O TRIGGER EXISTE
-- =====================================================

SELECT 
    'STATUS DO TRIGGER' as categoria,
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement,
    action_orientation
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_referrer_contracts';

-- =====================================================
-- 2. VERIFICAR SE A FUNÇÃO EXISTE
-- =====================================================

SELECT 
    'STATUS DA FUNÇÃO' as categoria,
    proname as function_name,
    prosrc as function_body
FROM pg_proc 
WHERE proname = 'update_referrer_contracts_on_friend_registration';

-- =====================================================
-- 3. VERIFICAR MEMBROS COM CONTRATOS
-- =====================================================

SELECT 
    'MEMBROS COM CONTRATOS' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    is_friend,
    referrer
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY contracts_completed DESC
LIMIT 10;

-- =====================================================
-- 4. VERIFICAR AMIGOS CADASTRADOS
-- =====================================================

SELECT 
    'AMIGOS CADASTRADOS' as categoria,
    name,
    referrer,
    is_friend,
    contracts_completed,
    ranking_status,
    created_at
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND is_friend = true
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- 5. TESTE MANUAL - ATUALIZAR CONTRATOS DE UM MEMBRO
-- =====================================================

-- Encontrar um membro para testar
SELECT 
    'MEMBRO PARA TESTE' as categoria,
    name,
    contracts_completed,
    ranking_status
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND is_friend = false
LIMIT 1;

-- =====================================================
-- 6. SIMULAR ATUALIZAÇÃO MANUAL DE CONTRATOS
-- =====================================================

-- Descomente e execute para testar manualmente (substitua 'NOME_DO_MEMBRO' pelo nome real)
-- UPDATE members 
-- SET 
--   contracts_completed = contracts_completed + 1,
--   updated_at = NOW()
-- WHERE 
--   name = 'NOME_DO_MEMBRO' 
--   AND status = 'Ativo' 
--   AND deleted_at IS NULL;

-- =====================================================
-- 7. EXECUTAR RANKING MANUALMENTE
-- =====================================================

-- Executar função de ranking manualmente
SELECT update_complete_ranking();

-- =====================================================
-- 8. VERIFICAR RESULTADO APÓS ATUALIZAÇÃO
-- =====================================================

SELECT 
    'RESULTADO APÓS ATUALIZAÇÃO' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY contracts_completed DESC
LIMIT 10;
