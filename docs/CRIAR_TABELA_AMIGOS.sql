-- =====================================================
-- CRIAR TABELA DE AMIGOS IGUAL À DE MEMBROS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. CRIAR TABELA DE AMIGOS (MESMA ESTRUTURA DE MEMBROS)
-- =====================================================

CREATE TABLE IF NOT EXISTS friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL, -- Referência ao membro que cadastrou
  
  -- Mesma estrutura de membros
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL,
  referrer VARCHAR(255) NOT NULL, -- Nome do membro que cadastrou
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) DEFAULT 'Ativo',
  
  -- Dados da segunda pessoa (obrigatório - regra do casal)
  couple_name VARCHAR(255) NOT NULL,
  couple_phone VARCHAR(20) NOT NULL,
  couple_instagram VARCHAR(255) NOT NULL,
  couple_city VARCHAR(255) NOT NULL,
  couple_sector VARCHAR(255) NOT NULL,
  
  -- Campos específicos do sistema (mesma lógica de membros)
  contracts_completed INTEGER DEFAULT 0, -- Quantos usuários este amigo cadastrou
  ranking_position INTEGER, -- Posição no ranking de amigos
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_1500 BOOLEAN DEFAULT false, -- Se está entre os top performers
  can_be_replaced BOOLEAN DEFAULT false,
  
  -- Campos de verificação de posts (específicos de amigos)
  post_verified_1 BOOLEAN DEFAULT false,
  post_verified_2 BOOLEAN DEFAULT false,
  post_url_1 TEXT,
  post_url_2 TEXT,
  
  -- Campo para soft delete
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Foreign key para o membro que cadastrou
  CONSTRAINT fk_friend_member FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

-- =====================================================
-- 2. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tabela de amigos
CREATE INDEX IF NOT EXISTS idx_friends_member_id ON friends(member_id);
CREATE INDEX IF NOT EXISTS idx_friends_status ON friends(status);
CREATE INDEX IF NOT EXISTS idx_friends_ranking_status ON friends(ranking_status);
CREATE INDEX IF NOT EXISTS idx_friends_deleted_at ON friends(deleted_at);
CREATE INDEX IF NOT EXISTS idx_friends_referrer ON friends(referrer);
CREATE INDEX IF NOT EXISTS idx_friends_contracts_completed ON friends(contracts_completed);

-- =====================================================
-- 3. COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE friends IS 'Tabela de amigos (contratos pagos) com mesma estrutura de membros';
COMMENT ON COLUMN friends.member_id IS 'ID do membro que cadastrou este amigo';
COMMENT ON COLUMN friends.contracts_completed IS 'Quantos usuários este amigo cadastrou';
COMMENT ON COLUMN friends.ranking_position IS 'Posição no ranking de amigos';
COMMENT ON COLUMN friends.ranking_status IS 'Status do ranking: Verde (15+), Amarelo (1-14), Vermelho (0)';
COMMENT ON COLUMN friends.is_top_1500 IS 'Se está entre os top performers de amigos';
COMMENT ON COLUMN friends.post_verified_1 IS 'Se o post do primeiro membro foi verificado';
COMMENT ON COLUMN friends.post_verified_2 IS 'Se o post do segundo membro foi verificado';

-- =====================================================
-- 4. VERIFICAR SE A TABELA FOI CRIADA
-- =====================================================

-- Verificar estrutura da tabela
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'friends' 
ORDER BY ordinal_position;

-- =====================================================
-- 5. CRIAR VIEW PARA RANKING DE AMIGOS
-- =====================================================

CREATE OR REPLACE VIEW v_friends_ranking AS
SELECT 
  f.id,
  f.member_id,
  -- Dados do amigo (mesma estrutura de membros)
  f.name,
  f.phone,
  f.instagram,
  f.city,
  f.sector,
  f.referrer,
  f.registration_date,
  f.status,
  f.couple_name,
  f.couple_phone,
  f.couple_instagram,
  f.couple_city,
  f.couple_sector,
  f.contracts_completed, -- Quantos usuários este amigo cadastrou
  f.ranking_position,
  f.ranking_status,
  f.is_top_1500,
  f.can_be_replaced,
  f.post_verified_1,
  f.post_verified_2,
  f.post_url_1,
  f.post_url_2,
  f.created_at,
  f.updated_at,
  -- Dados do membro que cadastrou
  m.name as member_name,
  m.instagram as member_instagram,
  m.phone as member_phone,
  m.city as member_city,
  m.sector as member_sector
FROM friends f
LEFT JOIN members m ON f.member_id = m.id
WHERE f.status = 'Ativo' AND f.deleted_at IS NULL
ORDER BY f.contracts_completed DESC, f.created_at ASC;

-- =====================================================
-- 6. CRIAR VIEW PARA ESTATÍSTICAS DE AMIGOS
-- =====================================================

CREATE OR REPLACE VIEW v_friends_stats AS
SELECT 
  -- Total de amigos ativos
  (SELECT COUNT(*) FROM friends WHERE status = 'Ativo' AND deleted_at IS NULL) as total_friends,
  
  -- Amigos verdes (15+ usuários cadastrados)
  (SELECT COUNT(*) FROM friends WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_friends,
  
  -- Amigos amarelos (1-14 usuários cadastrados)
  (SELECT COUNT(*) FROM friends WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_friends,
  
  -- Amigos vermelhos (0 usuários cadastrados)
  (SELECT COUNT(*) FROM friends WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_friends,
  
  -- Total de usuários cadastrados por amigos
  (SELECT SUM(contracts_completed) FROM friends WHERE status = 'Ativo' AND deleted_at IS NULL) as total_users_cadastrados,
  
  -- Posts verificados
  (SELECT COUNT(*) FROM friends WHERE (post_verified_1 = true OR post_verified_2 = true) AND status = 'Ativo' AND deleted_at IS NULL) as verified_posts;

-- =====================================================
-- 7. TESTAR AS VIEWS
-- =====================================================

-- Testar view de ranking de amigos
SELECT 'Ranking de Amigos' as categoria, COUNT(*) as total FROM v_friends_ranking;

-- Testar view de estatísticas de amigos
SELECT 'Estatísticas de Amigos' as categoria, * FROM v_friends_stats;

-- =====================================================
-- 8. PRÓXIMOS PASSOS
-- =====================================================

-- Após executar este script, você precisará:
-- 1. Migrar dados existentes de amigos da tabela 'members' para 'friends'
-- 2. Atualizar hooks para usar a nova tabela 'friends'
-- 3. Atualizar dashboard para usar as novas views
-- 4. Testar cadastro de novos amigos
-- 5. Verificar contadores e rankings
