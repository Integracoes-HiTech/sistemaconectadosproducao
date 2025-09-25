-- =====================================================
-- CRIAÇÃO DA TABELA FRIENDS (AMIGOS)
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. TABELA FRIENDS (AMIGOS)
-- =====================================================

CREATE TABLE IF NOT EXISTS friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  
  -- Dados do casal amigo
  couple_name_1 VARCHAR(255) NOT NULL, -- Nome da primeira pessoa
  couple_name_2 VARCHAR(255) NOT NULL, -- Nome da segunda pessoa
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
  users_cadastrados INTEGER DEFAULT 0, -- Contador de usuários cadastrados
  ranking_position INTEGER, -- Posição no ranking de amigos
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_performer BOOLEAN DEFAULT false, -- Se está entre os top performers
  
  -- Fiscalização
  instagram_post_1 VARCHAR(255), -- Link do post no Instagram da pessoa 1
  instagram_post_2 VARCHAR(255), -- Link do post no Instagram da pessoa 2
  hashtag_1 VARCHAR(100), -- Hashtag única para pessoa 1
  hashtag_2 VARCHAR(100), -- Hashtag única para pessoa 2
  post_verified_1 BOOLEAN DEFAULT false, -- Se post foi verificado
  post_verified_2 BOOLEAN DEFAULT false, -- Se post foi verificado
  
  -- Datas
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  last_activity_date DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comentários para documentação
COMMENT ON TABLE friends IS 'Tabela de amigos (contratos pagos) cadastrados pelos membros';
COMMENT ON COLUMN friends.member_id IS 'ID do membro responsável por cadastrar este amigo';
COMMENT ON COLUMN friends.couple_name_1 IS 'Nome da primeira pessoa do casal amigo';
COMMENT ON COLUMN friends.couple_name_2 IS 'Nome da segunda pessoa do casal amigo';
COMMENT ON COLUMN friends.users_cadastrados IS 'Número de usuários cadastrados por este amigo';
COMMENT ON COLUMN friends.ranking_position IS 'Posição no ranking de amigos que mais cadastraram';
COMMENT ON COLUMN friends.ranking_status IS 'Status do ranking: Verde (top), Amarelo (médio), Vermelho (baixo)';
COMMENT ON COLUMN friends.is_top_performer IS 'Se está entre os top performers de cadastros';

-- =====================================================
-- 2. TABELA FRIEND_REFERRALS (USUÁRIOS CADASTRADOS PELOS AMIGOS)
-- =====================================================

CREATE TABLE IF NOT EXISTS friend_referrals (
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

-- =====================================================
-- 3. VIEW PARA RANKING DOS AMIGOS
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

-- Comentário para a view
COMMENT ON VIEW v_friends_ranking IS 'View para ranking dos amigos que mais cadastraram usuários';

-- =====================================================
-- 4. FUNÇÃO PARA ATUALIZAR RANKING DOS AMIGOS
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
        WHEN users_cadastrados >= 15 THEN 'Verde' -- Exemplo: 15 usuários para Verde
        WHEN users_cadastrados >= 5 THEN 'Amarelo' -- Exemplo: 5 usuários para Amarelo
        ELSE 'Vermelho'
      END as new_status,
      (users_cadastrados >= 15) as new_top_performer -- Exemplo: 15 usuários para top performer
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

-- Comentário para a função
COMMENT ON FUNCTION update_friends_ranking() IS 'Função para atualizar o ranking dos amigos após cada inserção em friend_referrals';

-- =====================================================
-- 5. TRIGGER PARA ATUALIZAR RANKING DOS AMIGOS
-- =====================================================

-- Trigger para atualizar o ranking dos amigos após cada inserção em friend_referrals
CREATE OR REPLACE TRIGGER trg_update_friends_ranking
AFTER INSERT ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- Trigger para atualizar o ranking dos amigos após cada atualização em friend_referrals
CREATE OR REPLACE TRIGGER trg_update_friends_ranking_update
AFTER UPDATE ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

-- =====================================================
-- 6. ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para a tabela friends
CREATE INDEX IF NOT EXISTS idx_friends_member_id ON friends(member_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(friend_status);
CREATE INDEX IF NOT EXISTS idx_friends_ranking_position ON friends(ranking_position);
CREATE INDEX IF NOT EXISTS idx_friends_users_cadastrados ON friends(users_cadastrados);
CREATE INDEX IF NOT EXISTS idx_friends_registration_date ON friends(registration_date);

-- Índices para a tabela friend_referrals
CREATE INDEX IF NOT EXISTS idx_friend_referrals_friend_id ON friend_referrals(friend_id);
CREATE INDEX IF NOT EXISTS idx_friend_referrals_status ON friend_referrals(referral_status);
CREATE INDEX IF NOT EXISTS idx_friend_referrals_date ON friend_referrals(referral_date);

-- =====================================================
-- 7. POLÍTICAS RLS (ROW LEVEL SECURITY)
-- =====================================================

-- Habilitar RLS nas tabelas
ALTER TABLE friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE friend_referrals ENABLE ROW LEVEL SECURITY;

-- Política para friends: usuários autenticados podem ver todos os amigos
CREATE POLICY "Users can view all friends" ON friends
FOR SELECT USING (auth.role() = 'authenticated');

-- Política para friends: apenas administradores podem inserir/atualizar/deletar
CREATE POLICY "Only admins can modify friends" ON friends
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'Admin'
  )
);

-- Política para friend_referrals: usuários autenticados podem ver todas as referências
CREATE POLICY "Users can view all friend referrals" ON friend_referrals
FOR SELECT USING (auth.role() = 'authenticated');

-- Política para friend_referrals: apenas administradores podem inserir/atualizar/deletar
CREATE POLICY "Only admins can modify friend referrals" ON friend_referrals
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'Admin'
  )
);

-- =====================================================
-- 8. DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================

-- Inserir alguns amigos de exemplo (descomente se necessário)
/*
INSERT INTO friends (member_id, couple_name_1, couple_name_2, couple_phone_1, couple_phone_2, couple_instagram_1, couple_instagram_2, couple_city, couple_sector, friend_status) VALUES
-- Substitua os UUIDs pelos IDs reais dos membros
('uuid-do-membro-1', 'João Silva', 'Maria Silva', '(62) 99999-9999', '(62) 88888-8888', '@joaosilva', '@mariasilva', 'Goiânia', 'Centro', 'Ativo'),
('uuid-do-membro-2', 'Pedro Costa', 'Ana Costa', '(62) 77777-7777', '(62) 66666-6666', '@pedrocosta', '@anacosta', 'Aparecida de Goiânia', 'Setor Central', 'Ativo'),
('uuid-do-membro-3', 'Lucas Rocha', 'Julia Rocha', '(62) 55555-5555', '(62) 44444-4444', '@lucasrocha', '@juliarocha', 'Trindade', 'Centro', 'Ativo');
*/

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

-- Verificar se as tabelas foram criadas
SELECT 
  'friends' as tabela,
  COUNT(*) as registros
FROM friends
UNION ALL
SELECT 
  'friend_referrals' as tabela,
  COUNT(*) as registros
FROM friend_referrals
UNION ALL
SELECT 
  'v_friends_ranking' as tabela,
  COUNT(*) as registros
FROM v_friends_ranking;
