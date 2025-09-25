-- =====================================================
-- CRIAR FUNÇÃO PARA ATUALIZAR RANKING DOS AMIGOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. CRIAR FUNÇÃO update_friends_ranking
-- =====================================================

CREATE OR REPLACE FUNCTION update_friends_ranking()
RETURNS void AS $$
BEGIN
  -- Atualizar ranking_position dos amigos baseado em contracts_completed
  WITH ranked_friends AS (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        ORDER BY 
          contracts_completed DESC,  -- Mais usuários cadastrados primeiro
          created_at ASC            -- Em caso de empate, mais antigo primeiro
      ) as new_ranking_position
    FROM friends 
    WHERE status = 'Ativo' AND deleted_at IS NULL
  )
  UPDATE friends 
  SET 
    ranking_position = ranked_friends.new_ranking_position,
    updated_at = NOW()
  FROM ranked_friends
  WHERE friends.id = ranked_friends.id;

  -- Atualizar ranking_status baseado em contracts_completed
  UPDATE friends 
  SET 
    ranking_status = CASE
      WHEN contracts_completed >= 15 THEN 'Verde'
      WHEN contracts_completed >= 1 THEN 'Amarelo'
      ELSE 'Vermelho'
    END,
    updated_at = NOW()
  WHERE status = 'Ativo' AND deleted_at IS NULL;

  -- Atualizar is_top_1500 baseado no ranking
  UPDATE friends 
  SET 
    is_top_1500 = CASE
      WHEN ranking_position <= 10 THEN true
      ELSE false
    END,
    updated_at = NOW()
  WHERE status = 'Ativo' AND deleted_at IS NULL;

  RAISE NOTICE 'Ranking dos amigos atualizado com sucesso';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. CRIAR TRIGGER PARA ATUALIZAR RANKING AUTOMATICAMENTE
-- =====================================================

-- Função para trigger
CREATE OR REPLACE FUNCTION trigger_update_friends_ranking()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar ranking após inserção, atualização ou exclusão
  PERFORM update_friends_ranking();
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger para inserção
DROP TRIGGER IF EXISTS trigger_friends_insert_ranking ON friends;
CREATE TRIGGER trigger_friends_insert_ranking
  AFTER INSERT ON friends
  FOR EACH ROW
  EXECUTE FUNCTION trigger_update_friends_ranking();

-- Trigger para atualização
DROP TRIGGER IF EXISTS trigger_friends_update_ranking ON friends;
CREATE TRIGGER trigger_friends_update_ranking
  AFTER UPDATE ON friends
  FOR EACH ROW
  EXECUTE FUNCTION trigger_update_friends_ranking();

-- Trigger para exclusão (soft delete)
DROP TRIGGER IF EXISTS trigger_friends_delete_ranking ON friends;
CREATE TRIGGER trigger_friends_delete_ranking
  AFTER UPDATE OF deleted_at ON friends
  FOR EACH ROW
  WHEN (OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL)
  EXECUTE FUNCTION trigger_update_friends_ranking();

-- =====================================================
-- 3. TESTAR A FUNÇÃO
-- =====================================================

-- Executar a função para testar
SELECT update_friends_ranking();

-- Verificar resultado
SELECT 
    'RANKING ATUALIZADO' as categoria,
    ranking_position,
    name,
    contracts_completed,
    ranking_status,
    is_top_1500
FROM friends 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY ranking_position ASC
LIMIT 10;

-- =====================================================
-- 4. VERIFICAR TRIGGERS
-- =====================================================

-- Verificar se os triggers foram criados
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'friends'
ORDER BY trigger_name;
