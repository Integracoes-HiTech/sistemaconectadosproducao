-- =====================================================
-- CORREÇÃO SIMPLES DOS CONTADORES DE MEMBROS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ATUALIZAR CONTADOR DA FASE
-- =====================================================

UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- 2. RECRIAR VIEW v_system_stats
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
-- 3. VERIFICAR RESULTADO
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
