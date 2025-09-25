-- =====================================================
-- CORRIGIR REFERRERS EXISTENTES
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Amigos foram cadastrados com referrer = full_name do auth_users
-- Mas deveria ser referrer = name do auth_users
-- Isso impede a atualização de contratos dos membros

-- =====================================================
-- 1. VERIFICAR SITUAÇÃO ATUAL
-- =====================================================

-- Verificar amigos com referrer incorreto
SELECT 
    'AMIGOS COM REFERRER INCORRETO' as categoria,
    m.name as amigo,
    m.referrer as referrer_atual,
    au.name as referrer_correto,
    au.full_name as auth_full_name
FROM members m
LEFT JOIN auth_users au ON au.full_name = m.referrer
WHERE m.status = 'Ativo' 
  AND m.deleted_at IS NULL 
  AND m.is_friend = true
  AND au.name IS NOT NULL
ORDER BY m.created_at DESC;

-- =====================================================
-- 2. CORRIGIR REFERRERS DOS AMIGOS
-- =====================================================

-- Atualizar referrers para usar o name correto do auth_users
UPDATE members 
SET 
  referrer = au.name,
  updated_at = NOW()
FROM auth_users au
WHERE members.referrer = au.full_name
  AND members.status = 'Ativo'
  AND members.deleted_at IS NULL
  AND members.is_friend = true
  AND au.name IS NOT NULL;

-- =====================================================
-- 3. VERIFICAR CORREÇÃO
-- =====================================================

-- Verificar se as correções foram aplicadas
SELECT 
    'APÓS CORREÇÃO' as categoria,
    m.name as amigo,
    m.referrer as referrer_corrigido,
    au.name as auth_name,
    au.full_name as auth_full_name
FROM members m
LEFT JOIN auth_users au ON au.name = m.referrer
WHERE m.status = 'Ativo' 
  AND m.deleted_at IS NULL 
  AND m.is_friend = true
ORDER BY m.created_at DESC;

-- =====================================================
-- 4. RECALCULAR CONTRATOS DOS MEMBROS
-- =====================================================

-- Contar amigos por membro e atualizar contratos
WITH amigos_por_membro AS (
  SELECT 
    referrer as membro,
    COUNT(*) as amigos_cadastrados
  FROM members 
  WHERE status = 'Ativo' 
    AND deleted_at IS NULL 
    AND is_friend = true 
    AND referrer IS NOT NULL
  GROUP BY referrer
)
UPDATE members 
SET 
  contracts_completed = apm.amigos_cadastrados,
  updated_at = NOW()
FROM amigos_por_membro apm
WHERE members.name = apm.membro
  AND members.status = 'Ativo'
  AND members.deleted_at IS NULL
  AND members.is_friend = false;

-- =====================================================
-- 5. EXECUTAR RANKING
-- =====================================================

-- Executar função de ranking para atualizar status e posições
SELECT update_complete_ranking();

-- =====================================================
-- 6. VERIFICAR RESULTADO FINAL
-- =====================================================

-- Verificar membros com contratos atualizados
SELECT 
    'MEMBROS COM CONTRATOS ATUALIZADOS' as categoria,
    name as membro,
    contracts_completed as contratos,
    ranking_status as status,
    ranking_position as posicao,
    CASE 
        WHEN contracts_completed >= 15 THEN '🟢 Verde (15+ contratos)'
        WHEN contracts_completed >= 1 THEN '🟡 Amarelo (1-14 contratos)'
        ELSE '🔴 Vermelho (0 contratos)'
    END as status_descricao
FROM members 
WHERE status = 'Ativo' 
  AND deleted_at IS NULL 
  AND is_friend = false
ORDER BY contracts_completed DESC;

-- Verificar amigos cadastrados
SELECT 
    'AMIGOS CADASTRADOS' as categoria,
    name as amigo,
    referrer as membro_que_cadastrou,
    is_friend,
    contracts_completed,
    ranking_status,
    created_at
FROM members 
WHERE status = 'Ativo' 
  AND deleted_at IS NULL 
  AND is_friend = true
ORDER BY created_at DESC;

-- =====================================================
-- 7. RESUMO FINAL
-- =====================================================

-- Resumo geral do sistema
SELECT 
    'RESUMO FINAL' as categoria,
    COUNT(CASE WHEN is_friend = false THEN 1 END) as total_membros,
    COUNT(CASE WHEN is_friend = true THEN 1 END) as total_amigos,
    COUNT(CASE WHEN contracts_completed >= 15 THEN 1 END) as membros_verdes,
    COUNT(CASE WHEN contracts_completed >= 1 AND contracts_completed < 15 THEN 1 END) as membros_amarelos,
    COUNT(CASE WHEN contracts_completed = 0 THEN 1 END) as membros_vermelhos,
    SUM(contracts_completed) as total_contratos
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL;

-- =====================================================
-- RESUMO DAS CORREÇÕES:
-- =====================================================
-- ✅ Referrers dos amigos corrigidos (full_name → name)
-- ✅ Contratos dos membros recalculados
-- ✅ Ranking atualizado automaticamente
-- ✅ Status atualizado (Verde/Amarelo/Vermelho)
-- ✅ Posições do ranking atualizadas
-- ✅ Sistema funcionando corretamente
