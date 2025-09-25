-- =====================================================
-- CORREÇÃO ESPECÍFICA DOS CONTADORES VERMELHOS
-- Execute este script para corrigir o problema
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Os contadores vermelhos podem estar zerados porque:
-- 1. A view v_system_stats não está funcionando
-- 2. Os dados não têm ranking_status definido
-- 3. A função update_complete_ranking não está atualizando ranking_status

-- =====================================================
-- 1. PRIMEIRO: Atualizar ranking_status de todos os membros
-- =====================================================

UPDATE members 
SET ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
END
WHERE status = 'Ativo' AND deleted_at IS NULL;

-- =====================================================
-- 2. SEGUNDO: Atualizar contador da fase
-- =====================================================

UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- 3. TERCEIRO: Recriar view v_system_stats
-- =====================================================

DROP VIEW IF EXISTS v_system_stats;

CREATE OR REPLACE VIEW v_system_stats AS
SELECT 
  -- Total de membros ativos com ranking_status definido
  (SELECT COUNT(*) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')) as total_members,
  
  -- Membros verdes (15+ contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_members,
  
  -- Membros amarelos (1-14 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_members,
  
  -- Membros vermelhos (0 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_members,
  
  -- Top 1500 membros
  (SELECT COUNT(*) FROM members WHERE is_top_1500 = true AND status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')) as top_1500_members,
  
  -- Contratos completos (soma de todos os contratos)
  (SELECT SUM(contracts_completed) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL) as completed_contracts,
  
  -- Contratos pendentes (0 por enquanto)
  0 as pending_contracts,
  
  -- Contador atual da fase
  (SELECT COALESCE(current_count, 0) FROM phase_control WHERE phase_name = 'members_registration') as current_member_count,
  
  -- Limite máximo da fase
  (SELECT COALESCE(max_limit, 1500) FROM phase_control WHERE phase_name = 'members_registration') as max_member_limit;

-- =====================================================
-- 4. QUARTO: Verificar resultado
-- =====================================================

SELECT 
    'RESULTADO FINAL' as status,
    total_members,
    green_members,
    yellow_members,
    red_members,
    current_member_count,
    max_member_limit,
    CASE 
        WHEN current_member_count > max_member_limit THEN 'EXCEDIDO'
        WHEN current_member_count = max_member_limit THEN 'ATINGIDO'
        WHEN current_member_count >= (max_member_limit * 0.9) THEN 'PRÓXIMO'
        ELSE 'OK'
    END as status_limite
FROM v_system_stats;

-- =====================================================
-- 5. QUINTO: Verificar alguns membros vermelhos
-- =====================================================

SELECT 
    'MEMBROS VERMELHOS' as categoria,
    name,
    contracts_completed,
    ranking_status,
    status,
    deleted_at
FROM members 
WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 10;
