-- =====================================================
-- ATUALIZAR CONTRATOS QUANDO AMIGO É CADASTRADO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- Quando um membro cadastra um amigo (contrato pago), 
-- os contratos_completed do membro devem ser incrementados
-- e o ranking deve ser recalculado automaticamente

-- =====================================================
-- 1. FUNÇÃO PARA ATUALIZAR CONTRATOS DO REFERRER
-- =====================================================

CREATE OR REPLACE FUNCTION update_referrer_contracts_on_friend_registration()
RETURNS TRIGGER AS $$
BEGIN
  -- Só executar se é um amigo (contrato pago) e tem referrer
  IF NEW.is_friend = true AND NEW.referrer IS NOT NULL THEN
    -- Incrementar contratos do referrer
    UPDATE members 
    SET 
      contracts_completed = contracts_completed + 1,
      updated_at = NOW()
    WHERE 
      name = NEW.referrer 
      AND status = 'Ativo' 
      AND deleted_at IS NULL;
    
    -- Log da operação
    RAISE NOTICE 'Contratos incrementados para referrer: %', NEW.referrer;
    
    -- Atualizar ranking após mudança nos contratos
    PERFORM update_complete_ranking();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. TRIGGER PARA EXECUTAR A FUNÇÃO
-- =====================================================

-- Remover trigger existente se houver
DROP TRIGGER IF EXISTS trigger_update_referrer_contracts ON members;

-- Criar trigger que executa após inserção de membro
CREATE TRIGGER trigger_update_referrer_contracts
  AFTER INSERT ON members
  FOR EACH ROW
  EXECUTE FUNCTION update_referrer_contracts_on_friend_registration();

-- =====================================================
-- 3. FUNÇÃO PARA ATUALIZAR RANKING COMPLETO
-- =====================================================

-- Recriar função de ranking para garantir que está atualizada
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
  WHERE status = 'Ativo' AND deleted_at IS NULL;
  
  -- 2. SEGUNDO: Atualizar posições do ranking baseado em contratos completados
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
  
  -- 3. TERCEIRO: Atualizar status de top 1500
  UPDATE members 
  SET is_top_1500 = (ranking_position <= 1500)
  WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NOT NULL;
  
  -- 4. QUARTO: Atualizar quem pode ser substituído (vermelhos fora do top 1500)
  UPDATE members 
  SET can_be_replaced = (ranking_status = 'Vermelho' AND NOT is_top_1500)
  WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NOT NULL;
  
  -- Log da operação
  RAISE NOTICE 'Ranking atualizado com sucesso';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. FUNÇÃO PARA TESTAR O SISTEMA
-- =====================================================

CREATE OR REPLACE FUNCTION test_friend_registration_system()
RETURNS TABLE (
  test_name TEXT,
  result TEXT,
  details TEXT
) AS $$
DECLARE
  test_member_id UUID;
  test_friend_id UUID;
  contracts_before INTEGER;
  contracts_after INTEGER;
BEGIN
  -- Teste 1: Verificar se trigger existe
  RETURN QUERY SELECT 
    'Trigger Exists'::TEXT,
    CASE WHEN EXISTS (
      SELECT 1 FROM pg_trigger 
      WHERE tgname = 'trigger_update_referrer_contracts'
    ) THEN 'PASS' ELSE 'FAIL' END,
    'Verificando se trigger foi criado'::TEXT;
  
  -- Teste 2: Verificar se função existe
  RETURN QUERY SELECT 
    'Function Exists'::TEXT,
    CASE WHEN EXISTS (
      SELECT 1 FROM pg_proc 
      WHERE proname = 'update_referrer_contracts_on_friend_registration'
    ) THEN 'PASS' ELSE 'FAIL' END,
    'Verificando se função foi criada'::TEXT;
  
  -- Teste 3: Verificar se há membros para testar
  RETURN QUERY SELECT 
    'Members Available'::TEXT,
    CASE WHEN EXISTS (
      SELECT 1 FROM members 
      WHERE status = 'Ativo' AND deleted_at IS NULL AND is_friend = false
    ) THEN 'PASS' ELSE 'FAIL' END,
    'Verificando se há membros para testar'::TEXT;
  
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. VERIFICAR RESULTADO
-- =====================================================

-- Executar testes
SELECT * FROM test_friend_registration_system();

-- Verificar alguns membros com contratos
SELECT 
    'MEMBROS COM CONTRATOS' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    is_friend
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND contracts_completed > 0
ORDER BY contracts_completed DESC
LIMIT 10;

-- Verificar distribuição de contratos
SELECT 
    'DISTRIBUIÇÃO DE CONTRATOS' as categoria,
    contracts_completed,
    COUNT(*) as quantidade,
    CASE 
        WHEN contracts_completed >= 15 THEN '🟢 Verde'
        WHEN contracts_completed >= 1 THEN '🟡 Amarelo'
        ELSE '🔴 Vermelho'
    END as status_ranking
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
GROUP BY contracts_completed
ORDER BY contracts_completed DESC;

-- =====================================================
-- RESUMO DAS MODIFICAÇÕES:
-- =====================================================
-- ✅ Função update_referrer_contracts_on_friend_registration() criada
-- ✅ Trigger trigger_update_referrer_contracts criado
-- ✅ Função update_complete_ranking() atualizada
-- ✅ Função de teste test_friend_registration_system() criada
-- ✅ Verificações incluídas para confirmar funcionamento
-- ✅ Sistema automático: quando amigo é cadastrado, contratos do referrer são incrementados
-- ✅ Ranking é recalculado automaticamente após mudança nos contratos
