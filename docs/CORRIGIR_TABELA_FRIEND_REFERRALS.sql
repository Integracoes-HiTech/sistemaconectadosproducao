-- =====================================================
-- CORREÇÃO DA TABELA FRIEND_REFERRALS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR SE A TABELA FRIEND_REFERRALS EXISTE
-- =====================================================

-- Verificar se a tabela existe e sua estrutura atual
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'friend_referrals' 
ORDER BY ordinal_position;

-- =====================================================
-- 2. OPÇÃO A: DROPAR E RECRIAR A TABELA (SE NÃO HOUVER DADOS IMPORTANTES)
-- =====================================================

-- ATENÇÃO: Isso vai apagar todos os dados da tabela friend_referrals!
-- Execute apenas se não houver dados importantes

/*
-- Dropar a tabela existente
DROP TABLE IF EXISTS friend_referrals CASCADE;

-- Recriar a tabela com a estrutura correta
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
  instagram_post VARCHAR(255), -- Link do post no Instagram
  hashtag VARCHAR(100), -- Hashtag única
  post_verified BOOLEAN DEFAULT false, -- Se post foi verificado
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comentários para documentação
COMMENT ON TABLE friend_referrals IS 'Usuários cadastrados pelos amigos (contratos pagos)';
COMMENT ON COLUMN friend_referrals.friend_id IS 'ID do amigo que cadastrou este usuário';
COMMENT ON COLUMN friend_referrals.referred_user_name IS 'Nome do usuário cadastrado pelo amigo';
*/

-- =====================================================
-- 3. OPÇÃO B: ALTERAR A TABELA EXISTENTE (SE HOUVER DADOS IMPORTANTES)
-- =====================================================

-- Verificar se existe a coluna friend_contract_id
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'friend_referrals' 
AND column_name = 'friend_contract_id';

-- Se existir friend_contract_id, vamos renomear para friend_id
-- ATENÇÃO: Isso assume que friend_contract_id se refere à tabela friends
-- Se não for o caso, você precisará ajustar os dados manualmente

-- Passo 1: Adicionar nova coluna friend_id
ALTER TABLE friend_referrals 
ADD COLUMN IF NOT EXISTS friend_id UUID REFERENCES friends(id) ON DELETE CASCADE;

-- Passo 2: Copiar dados de friend_contract_id para friend_id (se necessário)
-- ATENÇÃO: Isso só funciona se friend_contract_id se refere à tabela friends
-- Se não for o caso, você precisará mapear os dados manualmente
UPDATE friend_referrals 
SET friend_id = friend_contract_id 
WHERE friend_contract_id IS NOT NULL 
AND friend_id IS NULL;

-- Passo 3: Tornar friend_id NOT NULL (após copiar os dados)
ALTER TABLE friend_referrals 
ALTER COLUMN friend_id SET NOT NULL;

-- Passo 4: Remover a coluna antiga friend_contract_id (opcional)
-- ALTER TABLE friend_referrals DROP COLUMN IF EXISTS friend_contract_id;

-- =====================================================
-- 4. VERIFICAR SE A TABELA FRIENDS EXISTE
-- =====================================================

-- Verificar se a tabela friends existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_name = 'friends'
) as friends_table_exists;

-- Se a tabela friends não existir, criar ela primeiro
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
-- 5. RECRIAR A VIEW V_FRIENDS_RANKING
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
-- 6. RECRIAR OS TRIGGERS
-- =====================================================

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

-- Dropar triggers existentes se houver
DROP TRIGGER IF EXISTS trg_update_friends_ranking ON friend_referrals;
DROP TRIGGER IF EXISTS trg_update_friends_ranking_update ON friend_referrals;

-- Criar novos triggers
CREATE TRIGGER trg_update_friends_ranking
AFTER INSERT ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

CREATE TRIGGER trg_update_friends_ranking_update
AFTER UPDATE ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- =====================================================
-- 7. VERIFICAR A ESTRUTURA FINAL
-- =====================================================

-- Verificar estrutura da tabela friend_referrals
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'friend_referrals' 
ORDER BY ordinal_position;

-- Verificar estrutura da tabela friends
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'friends' 
ORDER BY ordinal_position;

-- Verificar se a view existe
SELECT EXISTS (
  SELECT FROM information_schema.views 
  WHERE table_name = 'v_friends_ranking'
) as view_exists;

-- Testar a view
SELECT COUNT(*) as total_friends FROM v_friends_ranking;
