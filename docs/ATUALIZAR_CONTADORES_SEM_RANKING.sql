-- =====================================================
-- ATUALIZAR CONTADORES PARA MEMBROS SEM RANKING
-- Execute este script após inserir os 1500 membros de Goiás
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Os 1500 membros inseridos não têm ranking definido (NULL)
-- Isso significa que não aparecerão nos contadores atuais
-- Precisamos ajustar a lógica para contar membros sem ranking

-- =====================================================
-- 1. ATUALIZAR CONTADOR DA FASE
-- =====================================================

-- Contar todos os membros ativos (incluindo os sem ranking)
UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- 2. RECRIAR VIEW v_system_stats (INCLUINDO SEM RANKING)
-- =====================================================

DROP VIEW IF EXISTS v_system_stats;

CREATE OR REPLACE VIEW v_system_stats AS
SELECT 
  -- Total de membros ativos (incluindo os sem ranking)
  (SELECT COUNT(*) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL) as total_members,
  
  -- Membros verdes (15+ contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_members,
  
  -- Membros amarelos (1-14 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_members,
  
  -- Membros vermelhos (0 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_members,
  
  -- Top 1500 membros (apenas os com ranking)
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

-- Verificar contadores atualizados
SELECT 
    'CONTADORES ATUALIZADOS' as categoria,
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

-- Verificar distribuição de status
SELECT 
    'DISTRIBUIÇÃO DE STATUS' as categoria,
    CASE 
        WHEN ranking_status IS NULL THEN 'SEM RANKING'
        ELSE ranking_status
    END as status,
    COUNT(*) as quantidade,
    CASE 
        WHEN ranking_status IS NULL THEN '⚪'
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

-- Verificar alguns membros sem ranking
SELECT 
    'MEMBROS SEM RANKING' as categoria,
    name,
    city,
    sector,
    contracts_completed,
    ranking_position,
    ranking_status
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- 4. FUNÇÃO PARA ATUALIZAR RANKING QUANDO NECESSÁRIO
-- =====================================================

-- Criar função para atualizar ranking quando membros começarem a cadastrar amigos
CREATE OR REPLACE FUNCTION update_ranking_when_needed()
RETURNS VOID AS $$
BEGIN
  -- Atualizar ranking_status baseado em contracts_completed
  UPDATE members 
  SET ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
  END
  WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NULL;
  
  -- Atualizar posições do ranking baseado em contratos completados
  WITH ranked_members AS (
    SELECT 
      id,
      ROW_NUMBER() OVER (ORDER BY contracts_completed DESC, created_at ASC) as new_position
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NOT NULL
  )
  UPDATE members 
  SET ranking_position = rm.new_position
  FROM ranked_members rm
  WHERE members.id = rm.id;
  
  -- Atualizar status de top 1500
  UPDATE members 
  SET is_top_1500 = (ranking_position <= 1500)
  WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NOT NULL;
  
  -- Atualizar quem pode ser substituído (vermelhos fora do top 1500)
  UPDATE members 
  SET can_be_replaced = (ranking_status = 'Vermelho' AND NOT is_top_1500)
  WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- RESUMO DAS MODIFICAÇÕES:
-- =====================================================
-- ✅ Contador da fase atualizado para incluir membros sem ranking
-- ✅ View v_system_stats recriada para contar todos os membros ativos
-- ✅ Função update_ranking_when_needed() criada para atualizar ranking quando necessário
-- ✅ Verificações incluídas para confirmar funcionamento
-- ✅ Membros sem ranking não afetam contadores até começarem a cadastrar amigos
