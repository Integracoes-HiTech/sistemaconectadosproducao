-- =====================================================
-- SOLUÇÃO RÁPIDA PARA O ERRO DA TABELA FRIEND_REFERRALS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR ESTRUTURA ATUAL
-- =====================================================

-- Verificar se a tabela friend_referrals existe e sua estrutura
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'friend_referrals' 
ORDER BY ordinal_position;

-- =====================================================
-- 2. CRIAR TABELA FRIENDS SE NÃO EXISTIR
-- =====================================================

CREATE TABLE IF NOT EXISTS friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  
  -- Dados do casal amigo
  couple_name_1 VARCHAR(255) NOT NULL,
  couple_name_2 VARCHAR(255) NOT NULL,
  couple_phone_1 VARCHAR(20) NOT NULL,
  couple_phone_2 VARCHAR(20) NOT NULL,
  couple_instagram_1 VARCHAR(255) NOT NULL,
  couple_instagram_2 VARCHAR(255) NOT NULL,
  
  -- Dados adicionais
  couple_city VARCHAR(255),
  couple_sector VARCHAR(255),
  
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
-- 3. RECRIAR TABELA FRIEND_REFERRALS COM ESTRUTURA CORRETA
-- =====================================================

-- Dropar a tabela existente (isso vai apagar os dados!)
DROP TABLE IF EXISTS friend_referrals CASCADE;

-- Recriar com a estrutura correta
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

CREATE OR REPLACE VIEW v_friends_ranking AS
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
  RANK() OVER (ORDER BY f.users_cadastrados DESC, f.registration_date ASC) as global_rank
FROM friends f
LEFT JOIN members m ON f.member_id = m.id
LEFT JOIN friend_referrals fr ON f.id = fr.friend_id
WHERE f.friend_status = 'Ativo'
GROUP BY f.id, f.member_id, m.name, m.instagram, f.couple_name_1, f.couple_name_2,
         f.couple_phone_1, f.couple_phone_2, f.couple_instagram_1, f.couple_instagram_2,
         f.couple_city, f.couple_sector, f.friend_status, f.users_cadastrados, f.ranking_position,
         f.ranking_status, f.is_top_performer, f.registration_date, f.last_activity_date
ORDER BY global_rank;

-- =====================================================
-- 5. CRIAR FUNÇÃO E TRIGGERS PARA RANKING
-- =====================================================

-- Dropar a função existente se houver (para evitar conflito de tipo de retorno)
DROP FUNCTION IF EXISTS update_friends_ranking() CASCADE;
DROP FUNCTION IF EXISTS update_friends_ranking(trigger) CASCADE;

-- Dropar triggers existentes se houver
DROP TRIGGER IF EXISTS trg_update_friends_ranking ON friend_referrals;
DROP TRIGGER IF EXISTS trg_update_friends_ranking_update ON friend_referrals;

-- Função para atualizar ranking dos amigos
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

-- Triggers para executar a função
CREATE TRIGGER trg_update_friends_ranking
AFTER INSERT ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

CREATE TRIGGER trg_update_friends_ranking_update
AFTER UPDATE ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- =====================================================
-- 6. VERIFICAR SE TUDO FOI CRIADO CORRETAMENTE
-- =====================================================

-- Verificar estrutura da tabela friend_referrals
SELECT 
  'friend_referrals' as tabela,
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'friend_referrals' 
ORDER BY ordinal_position;

-- Verificar estrutura da tabela friends
SELECT 
  'friends' as tabela,
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'friends' 
ORDER BY ordinal_position;

-- Verificar se a view existe
SELECT EXISTS (
  SELECT FROM information_schema.views 
  WHERE table_name = 'v_friends_ranking'
) as view_exists;

-- Testar a view (deve retornar 0 se não houver dados)
SELECT COUNT(*) as total_friends FROM v_friends_ranking;

-- =====================================================
-- 7. INSERIR DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir alguns amigos de exemplo
-- Substitua os UUIDs pelos IDs reais dos membros
/*
INSERT INTO friends (member_id, couple_name_1, couple_name_2, couple_phone_1, couple_phone_2, couple_instagram_1, couple_instagram_2, couple_city, couple_sector, friend_status) VALUES
-- Exemplo (substitua pelos IDs reais):
('uuid-do-membro-1', 'João Silva', 'Maria Silva', '(62) 99999-9999', '(62) 88888-8888', '@joaosilva', '@mariasilva', 'Goiânia', 'Centro', 'Ativo'),
('uuid-do-membro-2', 'Pedro Costa', 'Ana Costa', '(62) 77777-7777', '(62) 66666-6666', '@pedrocosta', '@anacosta', 'Aparecida de Goiânia', 'Setor Central', 'Ativo');
*/

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

-- Mensagem de sucesso
SELECT 'Estrutura de friends criada com sucesso!' as status;
