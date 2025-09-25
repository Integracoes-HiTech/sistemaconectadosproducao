-- =====================================================
-- CORRIGIR CONTADORES DOS CARDS DO DASHBOARD
-- Execute este script no SQL Editor do Supabase
-- =====================================================

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
-- 2. SEGUNDO: Recriar view v_system_stats
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
  
  -- Contratos completos
  (SELECT SUM(contracts_completed) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL) as completed_contracts,
  
  -- Contratos pendentes
  0 as pending_contracts,
  
  -- Contador atual da fase
  (SELECT COALESCE(current_count, 0) FROM phase_control WHERE phase_name = 'members_registration') as current_member_count,
  
  -- Limite máximo da fase
  (SELECT COALESCE(max_limit, 1500) FROM phase_control WHERE phase_name = 'members_registration') as max_member_limit;

-- =====================================================
-- 3. TERCEIRO: Atualizar contador da fase
-- =====================================================

UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- 4. VERIFICAR RESULTADO
-- =====================================================

SELECT 'Resultado Final' as categoria, * FROM v_system_stats;
