-- =====================================================
-- CORRIGIR FUNÇÃO DE RANKING STATUS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- A função update_complete_ranking() NÃO atualiza o ranking_status
-- baseado nos contracts_completed. Ela só atualiza posições.
-- 
-- RESULTADO: Membros com 0 contratos aparecem como "Verde" 
-- porque o ranking_status não é recalculado.

-- =====================================================
-- SOLUÇÃO: FUNÇÃO CORRIGIDA
-- =====================================================

-- Função para atualizar ranking completo (CORRIGIDA)
CREATE OR REPLACE FUNCTION update_complete_ranking()
RETURNS VOID AS $$
BEGIN
  -- 1. PRIMEIRO: Atualizar ranking_status baseado em contracts_completed
  UPDATE members 
  SET ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
  END
  WHERE status = 'Ativo';

  -- 2. SEGUNDO: Atualizar posições do ranking baseado em contratos completados
  WITH ranked_members AS (
    SELECT 
      id,
      ROW_NUMBER() OVER (ORDER BY contracts_completed DESC, created_at ASC) as new_position
    FROM members 
    WHERE status = 'Ativo'
  )
  UPDATE members 
  SET ranking_position = rm.new_position
  FROM ranked_members rm
  WHERE members.id = rm.id;
  
  -- 3. TERCEIRO: Atualizar status de top 1500
  UPDATE members 
  SET is_top_1500 = (ranking_position <= 1500)
  WHERE status = 'Ativo';
  
  -- 4. QUARTO: Atualizar quem pode ser substituído (vermelhos fora do top 1500)
  UPDATE members 
  SET can_be_replaced = (ranking_status = 'Vermelho' AND NOT is_top_1500)
  WHERE status = 'Ativo';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FUNÇÃO PARA ATUALIZAR APENAS RANKING STATUS
-- =====================================================

-- Função específica para atualizar apenas o ranking_status
CREATE OR REPLACE FUNCTION update_ranking_status_only()
RETURNS VOID AS $$
BEGIN
  UPDATE members 
  SET ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
  END
  WHERE status = 'Ativo';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- EXECUTAR CORREÇÃO IMEDIATA
-- =====================================================

-- Executar a função corrigida para atualizar todos os ranking_status
SELECT update_complete_ranking();

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Verificar distribuição de ranking_status após correção
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

-- Verificar alguns exemplos específicos
SELECT 
    name,
    contracts_completed,
    ranking_status,
    CASE 
        WHEN contracts_completed >= 15 THEN '✅ Deveria ser Verde'
        WHEN contracts_completed >= 1 THEN '✅ Deveria ser Amarelo'
        ELSE '✅ Deveria ser Vermelho'
    END as status_esperado
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY contracts_completed DESC
LIMIT 10;

-- =====================================================
-- RESUMO DA CORREÇÃO:
-- =====================================================
-- ✅ Função update_complete_ranking() corrigida
-- ✅ Agora atualiza ranking_status baseado em contracts_completed
-- ✅ Lógica correta: 0=Vermelho, 1-14=Amarelo, 15+=Verde
-- ✅ Função update_ranking_status_only() criada para uso específico
-- ✅ Correção aplicada imediatamente
-- ✅ Verificação dos resultados incluída
