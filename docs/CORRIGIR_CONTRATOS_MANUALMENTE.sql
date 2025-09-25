-- =====================================================
-- CORRIGIR CONTRATOS MANUALMENTE
-- Execute este script para corrigir contratos que não foram atualizados
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Amigos foram cadastrados mas contratos dos membros não foram incrementados
-- Precisamos contar quantos amigos cada membro cadastrou e atualizar os contratos

-- =====================================================
-- 1. VERIFICAR SITUAÇÃO ATUAL
-- =====================================================

-- Contar amigos cadastrados por cada membro
SELECT 
    'AMIGOS POR MEMBRO' as categoria,
    referrer as membro,
    COUNT(*) as amigos_cadastrados,
    MAX(created_at) as ultimo_amigo_cadastrado
FROM members 
WHERE status = 'Ativo' 
  AND deleted_at IS NULL 
  AND is_friend = true 
  AND referrer IS NOT NULL
GROUP BY referrer
ORDER BY amigos_cadastrados DESC;

-- =====================================================
-- 2. VERIFICAR CONTRATOS ATUAIS DOS MEMBROS
-- =====================================================

-- Verificar contratos atuais dos membros
SELECT 
    'CONTRATOS ATUAIS DOS MEMBROS' as categoria,
    name as membro,
    contracts_completed as contratos_atuais,
    ranking_status as status_atual,
    ranking_position as posicao_atual
FROM members 
WHERE status = 'Ativo' 
  AND deleted_at IS NULL 
  AND is_friend = false
ORDER BY contracts_completed DESC;

-- =====================================================
-- 3. CALCULAR CONTRATOS CORRETOS
-- =====================================================

-- Calcular quantos contratos cada membro deveria ter
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
),
contratos_atuais AS (
  SELECT 
    name as membro,
    contracts_completed
  FROM members 
  WHERE status = 'Ativo' 
    AND deleted_at IS NULL 
    AND is_friend = false
)
SELECT 
    'CÁLCULO DE CONTRATOS' as categoria,
    COALESCE(apm.membro, ca.membro) as membro,
    COALESCE(apm.amigos_cadastrados, 0) as amigos_cadastrados,
    COALESCE(ca.contracts_completed, 0) as contratos_atuais,
    COALESCE(apm.amigos_cadastrados, 0) as contratos_corretos,
    CASE 
        WHEN COALESCE(ca.contracts_completed, 0) != COALESCE(apm.amigos_cadastrados, 0) THEN '❌ PRECISA CORRIGIR'
        ELSE '✅ CORRETO'
    END as status
FROM amigos_por_membro apm
FULL OUTER JOIN contratos_atuais ca ON apm.membro = ca.membro
ORDER BY COALESCE(apm.amigos_cadastrados, 0) DESC;

-- =====================================================
-- 4. CORRIGIR CONTRATOS DOS MEMBROS
-- =====================================================

-- Atualizar contratos baseado no número de amigos cadastrados
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
-- 5. EXECUTAR RANKING APÓS CORREÇÃO
-- =====================================================

-- Executar função de ranking para atualizar status e posições
SELECT update_complete_ranking();

-- =====================================================
-- 6. VERIFICAR RESULTADO DA CORREÇÃO
-- =====================================================

-- Verificar contratos após correção
SELECT 
    'CONTRATOS APÓS CORREÇÃO' as categoria,
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

-- =====================================================
-- 7. VERIFICAR AMIGOS CADASTRADOS
-- =====================================================

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
-- 8. RESUMO DA CORREÇÃO
-- =====================================================

-- Resumo final
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
-- ✅ Contratos calculados baseado em amigos cadastrados
-- ✅ Contratos atualizados para todos os membros
-- ✅ Ranking recalculado automaticamente
-- ✅ Status atualizado (Verde/Amarelo/Vermelho)
-- ✅ Posições do ranking atualizadas
-- ✅ Verificações incluídas para confirmar funcionamento
