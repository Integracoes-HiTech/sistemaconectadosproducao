-- =====================================================
-- CORREÇÃO DA FUNÇÃO UPDATE_FRIENDS_RANKING
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR FUNÇÕES EXISTENTES
-- =====================================================

-- Verificar se a função existe e sua assinatura
SELECT 
  routine_name,
  routine_type,
  data_type as return_type,
  routine_definition
FROM information_schema.routines 
WHERE routine_name = 'update_friends_ranking';

-- =====================================================
-- 2. DROPAR A FUNÇÃO EXISTENTE
-- =====================================================

-- Dropar a função existente (com todas as possíveis assinaturas)
DROP FUNCTION IF EXISTS update_friends_ranking() CASCADE;
DROP FUNCTION IF EXISTS update_friends_ranking(trigger) CASCADE;

-- =====================================================
-- 3. DROPAR TRIGGERS EXISTENTES
-- =====================================================

-- Dropar triggers existentes se houver
DROP TRIGGER IF EXISTS trg_update_friends_ranking ON friend_referrals;
DROP TRIGGER IF EXISTS trg_update_friends_ranking_update ON friend_referrals;

-- =====================================================
-- 4. CRIAR A FUNÇÃO CORRETA
-- =====================================================

-- Criar a função com a assinatura correta para trigger
CREATE OR REPLACE FUNCTION update_friends_ranking()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualiza a contagem de users_cadastrados para o amigo
  UPDATE friends
  SET users_cadastrados = (
    SELECT COUNT(*)
    FROM friend_referrals
    WHERE friend_id = NEW.friend_id
    AND referral_status = 'Ativo'
  ),
  last_activity_date = CURRENT_DATE
  WHERE id = NEW.friend_id;

  -- Recalcula o ranking e status para todos os amigos
  WITH ranked_friends AS (
    SELECT
      id,
      users_cadastrados,
      RANK() OVER (ORDER BY users_cadastrados DESC, registration_date ASC) as new_rank,
      CASE
        WHEN users_cadastrados >= 15 THEN 'Verde'
        WHEN users_cadastrados >= 5 THEN 'Amarelo'
        ELSE 'Vermelho'
      END as new_status,
      (users_cadastrados >= 15) as new_top_performer
    FROM friends
    WHERE friend_status = 'Ativo'
  )
  UPDATE friends f
  SET
    ranking_position = rf.new_rank,
    ranking_status = rf.new_status,
    is_top_performer = rf.new_top_performer,
    updated_at = NOW()
  FROM ranked_friends rf
  WHERE f.id = rf.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. CRIAR OS TRIGGERS
-- =====================================================

-- Trigger para inserção
CREATE TRIGGER trg_update_friends_ranking
AFTER INSERT ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- Trigger para atualização
CREATE TRIGGER trg_update_friends_ranking_update
AFTER UPDATE ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- =====================================================
-- 6. VERIFICAR SE A FUNÇÃO FOI CRIADA CORRETAMENTE
-- =====================================================

-- Verificar a função criada
SELECT 
  routine_name,
  routine_type,
  data_type as return_type
FROM information_schema.routines 
WHERE routine_name = 'update_friends_ranking';

-- Verificar os triggers criados
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers 
WHERE trigger_name LIKE '%friends_ranking%';

-- =====================================================
-- 7. TESTAR A FUNÇÃO (OPCIONAL)
-- =====================================================

-- Testar se a função funciona (apenas se houver dados)
-- SELECT update_friends_ranking();

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

-- Mensagem de sucesso
SELECT 'Função update_friends_ranking corrigida com sucesso!' as status;
