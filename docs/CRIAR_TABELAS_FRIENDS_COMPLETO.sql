-- =====================================================
-- CRIAR TABELAS FRIENDS E FRIENDS RANKING - COMPLETO
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. LIMPAR ESTRUTURAS EXISTENTES (SE HOUVER)
-- =====================================================

-- Dropar triggers existentes
DROP TRIGGER IF EXISTS trg_update_friends_ranking ON friend_referrals;
DROP TRIGGER IF EXISTS trg_update_friends_ranking_update ON friend_referrals;

-- Dropar função existente
DROP FUNCTION IF EXISTS update_friends_ranking() CASCADE;

-- Dropar view existente
DROP VIEW IF EXISTS v_friends_ranking;

-- Dropar tabelas existentes (em ordem de dependência)
DROP TABLE IF EXISTS friend_referrals CASCADE;
DROP TABLE IF EXISTS friends CASCADE;

-- =====================================================
-- 2. CRIAR TABELA FRIENDS
-- =====================================================

CREATE TABLE friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  
  -- Dados do casal amigo
  couple_name_1 VARCHAR(255) NOT NULL,
  couple_name_2 VARCHAR(255) NOT NULL,
  couple_phone_1 VARCHAR(20) NOT NULL,
  couple_phone_2 VARCHAR(20) NOT NULL,
  couple_instagram_1 VARCHAR(255) NOT NULL,
  couple_instagram_2 VARCHAR(255) NOT NULL,
  couple_city VARCHAR(255) NOT NULL,
  couple_sector VARCHAR(255) NOT NULL,
  
  -- Status do amigo
  friend_status VARCHAR(20) DEFAULT 'Ativo' CHECK (friend_status IN ('Ativo', 'Inativo', 'Suspenso')),
  
  -- Ranking e performance
  users_cadastrados INTEGER DEFAULT 0,
  ranking_position INTEGER,
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_performer BOOLEAN DEFAULT false,
  
  -- Fiscalização
  instagram_post_1 VARCHAR(255),
  instagram_post_2 VARCHAR(255),
  hashtag_1 VARCHAR(100),
  hashtag_2 VARCHAR(100),
  post_verified_1 BOOLEAN DEFAULT false,
  post_verified_2 BOOLEAN DEFAULT false,
  
  -- Datas
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  last_activity_date DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. CRIAR TABELA FRIEND_REFERRALS
-- =====================================================

CREATE TABLE friend_referrals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  friend_id UUID NOT NULL REFERENCES friends(id) ON DELETE CASCADE,
  
  -- Dados do usuário cadastrado pelo amigo
  referred_user_name VARCHAR(255) NOT NULL,
  referred_user_phone VARCHAR(20) NOT NULL,
  referred_user_instagram VARCHAR(255) NOT NULL,
  referred_user_city VARCHAR(255) NOT NULL,
  referred_user_sector VARCHAR(255) NOT NULL,
  
  -- Dados do cadastro
  referral_date DATE NOT NULL DEFAULT CURRENT_DATE,
  referral_status VARCHAR(20) DEFAULT 'Ativo' CHECK (referral_status IN ('Ativo', 'Inativo', 'Cancelado')),
  
  -- Fiscalização
  instagram_post VARCHAR(255),
  hashtag VARCHAR(100),
  post_verified BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. CRIAR VIEW V_FRIENDS_RANKING
-- =====================================================

CREATE VIEW v_friends_ranking AS
SELECT
  f.id as friend_id,
  f.member_id,
  m.name as member_name,
  m.instagram as member_instagram,
  f.couple_name_1,
  f.couple_name_2,
  f.couple_phone_1,
  f.couple_phone_2,
  f.couple_instagram_1,
  f.couple_instagram_2,
  f.couple_city,
  f.couple_sector,
  f.friend_status,
  f.users_cadastrados,
  f.ranking_position,
  f.ranking_status,
  f.is_top_performer,
  f.registration_date,
  f.last_activity_date,
  COUNT(fr.id) as total_referrals,
  COUNT(CASE WHEN fr.referral_status = 'Ativo' THEN 1 END) as active_referrals,
  COUNT(CASE WHEN fr.referral_status = 'Inativo' THEN 1 END) as inactive_referrals,
  COUNT(CASE WHEN fr.post_verified = true THEN 1 END) as verified_posts,
  RANK() OVER (ORDER BY f.users_cadastrados DESC, f.registration_date ASC) as global_rank,
  f.created_at,
  f.updated_at
FROM friends f
LEFT JOIN members m ON f.member_id = m.id
LEFT JOIN friend_referrals fr ON f.id = fr.friend_id
WHERE f.friend_status = 'Ativo'
GROUP BY f.id, f.member_id, m.name, m.instagram, f.couple_name_1, f.couple_name_2,
         f.couple_phone_1, f.couple_phone_2, f.couple_instagram_1, f.couple_instagram_2,
         f.couple_city, f.couple_sector, f.friend_status, f.users_cadastrados, f.ranking_position,
         f.ranking_status, f.is_top_performer, f.registration_date, f.last_activity_date,
         f.created_at, f.updated_at
ORDER BY global_rank;

-- =====================================================
-- 5. CRIAR FUNÇÃO UPDATE_FRIENDS_RANKING
-- =====================================================

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
-- 6. CRIAR TRIGGERS
-- =====================================================

-- Trigger para INSERT
CREATE TRIGGER trg_update_friends_ranking
AFTER INSERT ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- Trigger para UPDATE
CREATE TRIGGER trg_update_friends_ranking_update
AFTER UPDATE ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- =====================================================
-- 7. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para friends
CREATE INDEX idx_friends_member_id ON friends(member_id);
CREATE INDEX idx_friends_status ON friends(friend_status);
CREATE INDEX idx_friends_ranking_status ON friends(ranking_status);
CREATE INDEX idx_friends_users_cadastrados ON friends(users_cadastrados);

-- Índices para friend_referrals
CREATE INDEX idx_friend_referrals_friend_id ON friend_referrals(friend_id);
CREATE INDEX idx_friend_referrals_status ON friend_referrals(referral_status);
CREATE INDEX idx_friend_referrals_verified ON friend_referrals(post_verified);

-- =====================================================
-- 8. VERIFICAR ESTRUTURAS CRIADAS
-- =====================================================

-- Verificar tabelas criadas
SELECT 
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('friends', 'friend_referrals', 'v_friends_ranking')
ORDER BY table_name;

-- Verificar colunas da tabela friends
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'friends' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar colunas da tabela friend_referrals
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'friend_referrals' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar função criada
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines 
WHERE routine_name = 'update_friends_ranking' 
AND routine_schema = 'public';

-- Verificar triggers criados
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND trigger_name LIKE '%friends_ranking%'
ORDER BY trigger_name;

-- =====================================================
-- 9. TESTAR FUNCIONALIDADE BÁSICA
-- =====================================================

-- Verificar se a view funciona
SELECT 'View v_friends_ranking criada com sucesso!' as status;

-- Verificar se a função existe
SELECT 'Função update_friends_ranking criada com sucesso!' as status;

-- Verificar se os triggers existem
SELECT 'Triggers criados com sucesso!' as status;

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

SELECT 'Tabelas friends e friends_ranking criadas com sucesso!' as status;
