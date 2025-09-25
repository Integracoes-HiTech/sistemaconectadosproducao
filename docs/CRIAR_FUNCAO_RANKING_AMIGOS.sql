-- =====================================================
-- CRIAR FUNÇÃO update_friends_ranking
-- Execute este script ANTES dos inserts
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

-- Testar a função
SELECT update_friends_ranking();
