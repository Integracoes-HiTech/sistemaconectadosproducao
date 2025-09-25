-- =====================================================
-- RANKING DOS AMIGOS QUE MAIS CADASTRARAM USUÁRIOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ADICIONAR CAMPOS NA TABELA PAID_CONTRACTS
-- =====================================================

-- Adicionar campos para rastrear cadastros dos amigos
ALTER TABLE paid_contracts 
ADD COLUMN IF NOT EXISTS users_cadastrados INTEGER DEFAULT 0, -- Contador de usuários cadastrados
ADD COLUMN IF NOT EXISTS ranking_position INTEGER, -- Posição no ranking de amigos
ADD COLUMN IF NOT EXISTS ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
ADD COLUMN IF NOT EXISTS is_top_performer BOOLEAN DEFAULT false; -- Se está entre os top performers

-- Comentários para documentação
COMMENT ON COLUMN paid_contracts.users_cadastrados IS 'Número de usuários cadastrados por este amigo';
COMMENT ON COLUMN paid_contracts.ranking_position IS 'Posição no ranking de amigos que mais cadastraram';
COMMENT ON COLUMN paid_contracts.ranking_status IS 'Status do ranking: Verde (top), Amarelo (médio), Vermelho (baixo)';
COMMENT ON COLUMN paid_contracts.is_top_performer IS 'Se está entre os top performers de cadastros';

-- =====================================================
-- 2. TABELA PARA RASTREAR CADASTROS DOS AMIGOS
-- =====================================================

CREATE TABLE IF NOT EXISTS friend_referrals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  friend_contract_id UUID NOT NULL REFERENCES paid_contracts(id) ON DELETE CASCADE,
  
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
COMMENT ON TABLE friend_referrals IS 'Rastreia usuários cadastrados pelos amigos (contratos pagos)';
COMMENT ON COLUMN friend_referrals.friend_contract_id IS 'Referência ao contrato do amigo que fez o cadastro';
COMMENT ON COLUMN friend_referrals.referred_user_name IS 'Nome do usuário cadastrado pelo amigo';
COMMENT ON COLUMN friend_referrals.referral_date IS 'Data do cadastro realizado pelo amigo';

-- =====================================================
-- 3. ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para paid_contracts
CREATE INDEX IF NOT EXISTS idx_paid_contracts_users_cadastrados ON paid_contracts(users_cadastrados);
CREATE INDEX IF NOT EXISTS idx_paid_contracts_ranking_position ON paid_contracts(ranking_position);
CREATE INDEX IF NOT EXISTS idx_paid_contracts_ranking_status ON paid_contracts(ranking_status);
CREATE INDEX IF NOT EXISTS idx_paid_contracts_is_top_performer ON paid_contracts(is_top_performer);

-- Índices para friend_referrals
CREATE INDEX IF NOT EXISTS idx_friend_referrals_contract_id ON friend_referrals(friend_contract_id);
CREATE INDEX IF NOT EXISTS idx_friend_referrals_date ON friend_referrals(referral_date);
CREATE INDEX IF NOT EXISTS idx_friend_referrals_status ON friend_referrals(referral_status);

-- =====================================================
-- 4. VIEW PARA RANKING DOS AMIGOS
-- =====================================================

CREATE OR REPLACE VIEW v_friends_ranking AS
SELECT 
  pc.id as contract_id,
  pc.member_id,
  m.name as member_name,
  m.instagram as member_instagram,
  pc.couple_name_1,
  pc.couple_name_2,
  pc.couple_phone_1,
  pc.couple_phone_2,
  pc.couple_instagram_1,
  pc.couple_instagram_2,
  pc.contract_date,
  pc.contract_status,
  pc.users_cadastrados,
  pc.ranking_position,
  pc.ranking_status,
  pc.is_top_performer,
  COUNT(fr.id) as total_referrals,
  COUNT(CASE WHEN fr.referral_status = 'Ativo' THEN 1 END) as active_referrals,
  COUNT(CASE WHEN fr.referral_status = 'Inativo' THEN 1 END) as inactive_referrals,
  COUNT(CASE WHEN fr.post_verified = true THEN 1 END) as verified_posts
FROM paid_contracts pc
LEFT JOIN members m ON pc.member_id = m.id
LEFT JOIN friend_referrals fr ON pc.id = fr.friend_contract_id
WHERE pc.contract_status IN ('Ativo', 'Completo')
GROUP BY pc.id, pc.member_id, m.name, m.instagram, pc.couple_name_1, pc.couple_name_2,
         pc.couple_phone_1, pc.couple_phone_2, pc.couple_instagram_1, pc.couple_instagram_2,
         pc.contract_date, pc.contract_status, pc.users_cadastrados, pc.ranking_position,
         pc.ranking_status, pc.is_top_performer
ORDER BY pc.users_cadastrados DESC, pc.ranking_position ASC;

-- Comentário para a view
COMMENT ON VIEW v_friends_ranking IS 'Ranking dos amigos (contratos pagos) que mais cadastraram usuários';

-- =====================================================
-- 5. FUNÇÃO PARA ATUALIZAR RANKING DOS AMIGOS
-- =====================================================

CREATE OR REPLACE FUNCTION update_friends_ranking()
RETURNS VOID AS $$
DECLARE
  friend_record RECORD;
  position_counter INTEGER := 1;
BEGIN
  -- Resetar posições
  UPDATE paid_contracts SET ranking_position = NULL;
  
  -- Atualizar contador de usuários cadastrados
  UPDATE paid_contracts 
  SET users_cadastrados = (
    SELECT COUNT(*) 
    FROM friend_referrals 
    WHERE friend_contract_id = paid_contracts.id 
    AND referral_status = 'Ativo'
  );
  
  -- Atualizar ranking por ordem de cadastros
  FOR friend_record IN 
    SELECT id, users_cadastrados
    FROM paid_contracts 
    WHERE contract_status IN ('Ativo', 'Completo')
    ORDER BY users_cadastrados DESC, contract_date ASC
  LOOP
    UPDATE paid_contracts 
    SET ranking_position = position_counter
    WHERE id = friend_record.id;
    
    position_counter := position_counter + 1;
  END LOOP;
  
  -- Atualizar status do ranking
  UPDATE paid_contracts 
  SET ranking_status = CASE
    WHEN users_cadastrados >= 10 THEN 'Verde'
    WHEN users_cadastrados >= 5 THEN 'Amarelo'
    ELSE 'Vermelho'
  END,
  is_top_performer = (users_cadastrados >= 10)
  WHERE contract_status IN ('Ativo', 'Completo');
  
END;
$$ LANGUAGE plpgsql;

-- Comentário para a função
COMMENT ON FUNCTION update_friends_ranking() IS 'Atualiza o ranking dos amigos baseado no número de usuários cadastrados';

-- =====================================================
-- 6. TRIGGER PARA ATUALIZAR RANKING AUTOMATICAMENTE
-- =====================================================

-- Função do trigger
CREATE OR REPLACE FUNCTION trigger_update_friends_ranking()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM update_friends_ranking();
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar ranking quando friend_referrals muda
CREATE OR REPLACE TRIGGER tr_update_friends_ranking_on_referrals
  AFTER INSERT OR UPDATE OR DELETE ON friend_referrals
  FOR EACH STATEMENT
  EXECUTE FUNCTION trigger_update_friends_ranking();

-- Trigger para atualizar ranking quando paid_contracts muda
CREATE OR REPLACE TRIGGER tr_update_friends_ranking_on_contracts
  AFTER UPDATE ON paid_contracts
  FOR EACH STATEMENT
  EXECUTE FUNCTION trigger_update_friends_ranking();

-- =====================================================
-- 7. VIEW PARA ESTATÍSTICAS DOS AMIGOS
-- =====================================================

CREATE OR REPLACE VIEW v_friends_stats AS
SELECT 
  COUNT(*) as total_friends,
  COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as green_friends,
  COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as yellow_friends,
  COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as red_friends,
  COUNT(CASE WHEN is_top_performer = true THEN 1 END) as top_performers,
  SUM(users_cadastrados) as total_users_cadastrados,
  AVG(users_cadastrados) as avg_users_per_friend,
  MAX(users_cadastrados) as max_users_cadastrados
FROM paid_contracts 
WHERE contract_status IN ('Ativo', 'Completo');

-- Comentário para a view
COMMENT ON VIEW v_friends_stats IS 'Estatísticas gerais dos amigos e seus cadastros';

-- =====================================================
-- 8. CONFIGURAÇÕES INICIAIS
-- =====================================================

-- Inserir configurações para ranking de amigos
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('friends_ranking_green_threshold', '10', 'Número de cadastros para status Verde no ranking de amigos'),
('friends_ranking_yellow_threshold', '5', 'Número mínimo de cadastros para status Amarelo no ranking de amigos'),
('friends_ranking_enabled', 'true', 'Se o ranking de amigos está ativo')
ON CONFLICT (setting_key) DO NOTHING;

-- =====================================================
-- 9. EXEMPLO DE USO
-- =====================================================

-- Exemplo: Inserir um cadastro feito por um amigo
/*
INSERT INTO friend_referrals (
  friend_contract_id,
  referred_user_name,
  referred_user_phone,
  referred_user_instagram,
  referred_user_city,
  referred_user_sector,
  referral_status
) VALUES (
  'uuid-do-contrato-do-amigo',
  'João Silva',
  '(62) 99999-9999',
  '@joaosilva',
  'Goiânia',
  'Setor Central',
  'Ativo'
);
*/

-- Exemplo: Consultar ranking dos amigos
/*
SELECT 
  couple_name_1,
  couple_name_2,
  users_cadastrados,
  ranking_position,
  ranking_status,
  total_referrals,
  active_referrals
FROM v_friends_ranking
ORDER BY ranking_position
LIMIT 10;
*/
