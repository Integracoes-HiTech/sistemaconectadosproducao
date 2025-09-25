-- =====================================================
-- CORRIGIR CONTADORES DO DASHBOARD
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Os contadores do dashboard (total de membros, verdes, amarelos, vermelhos)
-- não estão funcionando porque:
-- 1. A view v_system_stats pode não existir
-- 2. A view pode estar com erro
-- 3. Os dados podem estar inconsistentes

-- =====================================================
-- VERIFICAR STATUS ATUAL
-- =====================================================

-- Verificar se a view existe
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views 
WHERE viewname = 'v_system_stats';

-- Verificar dados básicos da tabela members
SELECT 
    COUNT(*) as total_members,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as active_members,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho') THEN 1 END) as active_with_status,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as green_members,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as yellow_members,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as red_members,
    COUNT(CASE WHEN ranking_status IS NULL OR ranking_status NOT IN ('Verde', 'Amarelo', 'Vermelho') THEN 1 END) as without_status,
    COUNT(CASE WHEN deleted_at IS NULL THEN 1 END) as not_deleted
FROM members;

-- =====================================================
-- RECRIAR VIEW v_system_stats (CORRIGIDA)
-- =====================================================

-- Remover view existente se houver
DROP VIEW IF EXISTS v_system_stats;

-- Criar view corrigida
CREATE OR REPLACE VIEW v_system_stats AS
SELECT 
  -- Total de membros ativos com ranking_status definido (Verde, Amarelo ou Vermelho)
  (SELECT COUNT(*) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')) as total_members,
  
  -- Membros verdes (15+ contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_members,
  
  -- Membros amarelos (1-14 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_members,
  
  -- Membros vermelhos (0 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_members,
  
  -- Top 1500 membros (apenas com ranking_status definido)
  (SELECT COUNT(*) FROM members WHERE is_top_1500 = true AND status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')) as top_1500_members,
  
  -- Contratos completos (baseado em contracts_completed da tabela members)
  (SELECT SUM(contracts_completed) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL) as completed_contracts,
  
  -- Contratos pendentes (0 por enquanto, pois não há tabela separada)
  0 as pending_contracts,
  
  -- Contador atual da fase
  (SELECT COALESCE(current_count, 0) FROM phase_control WHERE phase_name = 'members_registration') as current_member_count,
  
  -- Limite máximo da fase
  (SELECT COALESCE(max_limit, 1500) FROM phase_control WHERE phase_name = 'members_registration') as max_member_limit;

-- =====================================================
-- VERIFICAR SE A VIEW FUNCIONA
-- =====================================================

-- Testar a view
SELECT * FROM v_system_stats;

-- =====================================================
-- ATUALIZAR CONTADOR DA FASE
-- =====================================================

-- Atualizar contador da fase de membros (apenas com ranking_status definido)
UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- VERIFICAR RESULTADO FINAL
-- =====================================================

-- Verificar dados da view
SELECT 
    'Total de Membros' as categoria,
    total_members as quantidade,
    '👥' as emoji
FROM v_system_stats
UNION ALL
SELECT 
    'Membros Verdes' as categoria,
    green_members as quantidade,
    '🟢' as emoji
FROM v_system_stats
UNION ALL
SELECT 
    'Membros Amarelos' as categoria,
    yellow_members as quantidade,
    '🟡' as emoji
FROM v_system_stats
UNION ALL
SELECT 
    'Membros Vermelhos' as categoria,
    red_members as quantidade,
    '🔴' as emoji
FROM v_system_stats
UNION ALL
SELECT 
    'Top 1500' as categoria,
    top_1500_members as quantidade,
    '⭐' as emoji
FROM v_system_stats
UNION ALL
SELECT 
    'Contador da Fase' as categoria,
    current_member_count as quantidade,
    '📊' as emoji
FROM v_system_stats;

-- =====================================================
-- VERIFICAR DISTRIBUIÇÃO DE RANKING
-- =====================================================

-- Verificar distribuição de ranking_status
SELECT 
    ranking_status,
    COUNT(*) as quantidade,
    CASE 
        WHEN ranking_status = 'Verde' THEN '🟢'
        WHEN ranking_status = 'Amarelo' THEN '🟡'
        WHEN ranking_status = 'Vermelho' THEN '🔴'
    END as emoji
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
GROUP BY ranking_status
ORDER BY 
    CASE ranking_status 
        WHEN 'Verde' THEN 1 
        WHEN 'Amarelo' THEN 2 
        WHEN 'Vermelho' THEN 3 
    END;

-- =====================================================
-- RESUMO DA CORREÇÃO:
-- =====================================================
-- ✅ View v_system_stats recriada com filtros corretos
-- ✅ Filtros de deleted_at IS NULL adicionados
-- ✅ FILTRO POR RANKING_STATUS: apenas Verde, Amarelo ou Vermelho
-- ✅ Total de membros conta apenas os com status definido
-- ✅ Contador da fase atualizado (apenas com ranking_status)
-- ✅ Referências à tabela paid_contracts removidas (não existe)
-- ✅ Contratos completos calculados via SUM(contracts_completed)
-- ✅ Verificações incluídas para confirmar funcionamento
-- ✅ Distribuição de ranking verificada
