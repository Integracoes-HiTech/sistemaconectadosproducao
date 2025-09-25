-- =====================================================
-- VERIFICAR E CORRIGIR CONTADORES DE MEMBROS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Os contadores não estão atualizando quando:
-- 1. Membros são adicionados
-- 2. Membros são excluídos (soft delete)
-- 3. A mensagem de limite não distingue entre "atingiu" e "excedeu"

-- =====================================================
-- VERIFICAR STATUS ATUAL
-- =====================================================

-- Verificar contadores atuais
SELECT 
    'Contadores Atuais' as categoria,
    COUNT(*) as total_members,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as active_members,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho') THEN 1 END) as active_with_status,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as green_members,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as yellow_members,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as red_members
FROM members;

-- Verificar contador da fase
SELECT 
    'Contador da Fase' as categoria,
    current_count,
    max_limit,
    ROUND((current_count::NUMERIC / max_limit::NUMERIC) * 100, 2) as percentage
FROM phase_control 
WHERE phase_name = 'members_registration';

-- Verificar view v_system_stats
SELECT 
    'View v_system_stats' as categoria,
    total_members,
    green_members,
    yellow_members,
    red_members,
    current_member_count,
    max_member_limit
FROM v_system_stats;

-- =====================================================
-- CORRIGIR CONTADOR DA FASE
-- =====================================================

-- Atualizar contador da fase com dados corretos
UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IN ('Verde', 'Amarelo', 'Vermelho')
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- RECRIAR VIEW v_system_stats (ATUALIZADA)
-- =====================================================

-- Remover view existente
DROP VIEW IF EXISTS v_system_stats;

-- Criar view atualizada
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
-- VERIFICAR RESULTADO FINAL
-- =====================================================

-- Verificar contadores após correção
SELECT 
    'Após Correção' as categoria,
    total_members,
    green_members,
    yellow_members,
    red_members,
    current_member_count,
    max_member_limit,
    ROUND((current_member_count::NUMERIC / max_member_limit::NUMERIC) * 100, 2) as percentage
FROM v_system_stats;

-- Verificar status do limite
SELECT 
    CASE 
        WHEN current_member_count > max_member_limit THEN 'EXCEDIDO'
        WHEN current_member_count = max_member_limit THEN 'ATINGIDO'
        WHEN current_member_count >= (max_member_limit * 0.9) THEN 'PRÓXIMO'
        ELSE 'OK'
    END as status_limite,
    current_member_count,
    max_member_limit,
    ROUND((current_member_count::NUMERIC / max_member_limit::NUMERIC) * 100, 2) as percentage
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
        ELSE '⚪'
    END as emoji
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
GROUP BY ranking_status
ORDER BY 
    CASE ranking_status 
        WHEN 'Verde' THEN 1 
        WHEN 'Amarelo' THEN 2 
        WHEN 'Vermelho' THEN 3 
        ELSE 4
    END;

-- =====================================================
-- RESUMO DA CORREÇÃO:
-- =====================================================
-- ✅ Contador da fase atualizado com dados corretos
-- ✅ View v_system_stats recriada com filtros corretos
-- ✅ Distinção entre "atingiu" (100%) e "excedeu" (>100%)
-- ✅ Contadores sincronizados entre tabela e view
-- ✅ Verificações incluídas para confirmar funcionamento
