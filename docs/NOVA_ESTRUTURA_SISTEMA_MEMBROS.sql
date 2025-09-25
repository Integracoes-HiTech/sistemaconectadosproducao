-- =====================================================
-- NOVA ESTRUTURA DO SISTEMA - MEMBROS E CONTRATOS PAGOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. TABELA MEMBERS (Membros/Coordenadores)
-- =====================================================
CREATE TABLE IF NOT EXISTS members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL,
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo')),
  
  -- Dados da segunda pessoa (obrigatório - regra do casal)
  couple_name VARCHAR(255) NOT NULL,
  couple_phone VARCHAR(20) NOT NULL,
  couple_instagram VARCHAR(255) NOT NULL,
  
  -- Campos específicos do sistema de membros
  contracts_completed INTEGER DEFAULT 0, -- Contratos pagos completados (máximo 15)
  ranking_position INTEGER, -- Posição no ranking
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_1500 BOOLEAN DEFAULT false, -- Se está entre os top 1500
  can_be_replaced BOOLEAN DEFAULT false, -- Se pode ser substituído (status vermelho)
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. TABELA PAID_CONTRACTS (Contratos Pagos)
-- =====================================================
CREATE TABLE IF NOT EXISTS paid_contracts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  
  -- Dados do casal contratado
  couple_name_1 VARCHAR(255) NOT NULL, -- Nome da primeira pessoa
  couple_name_2 VARCHAR(255) NOT NULL, -- Nome da segunda pessoa
  couple_phone_1 VARCHAR(20) NOT NULL,
  couple_phone_2 VARCHAR(20) NOT NULL,
  couple_instagram_1 VARCHAR(255) NOT NULL,
  couple_instagram_2 VARCHAR(255) NOT NULL,
  
  -- Fiscalização
  instagram_post_1 VARCHAR(255), -- Link do post no Instagram da pessoa 1
  instagram_post_2 VARCHAR(255), -- Link do post no Instagram da pessoa 2
  hashtag_1 VARCHAR(100), -- Hashtag única para pessoa 1
  hashtag_2 VARCHAR(100), -- Hashtag única para pessoa 2
  post_verified_1 BOOLEAN DEFAULT false, -- Se post foi verificado
  post_verified_2 BOOLEAN DEFAULT false, -- Se post foi verificado
  
  -- Status do contrato
  contract_status VARCHAR(20) DEFAULT 'Pendente' CHECK (contract_status IN ('Pendente', 'Ativo', 'Completo', 'Cancelado')),
  contract_date DATE NOT NULL DEFAULT CURRENT_DATE,
  completion_date DATE, -- Data de conclusão
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. TABELA SYSTEM_SETTINGS (Configurações do Sistema)
-- =====================================================
CREATE TABLE IF NOT EXISTS system_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 4. TABELA MEMBER_RANKING (Ranking dos Membros)
-- =====================================================
CREATE TABLE IF NOT EXISTS member_ranking (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  ranking_position INTEGER NOT NULL,
  contracts_completed INTEGER DEFAULT 0,
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(member_id, ranking_position)
);

-- =====================================================
-- 5. TABELA PHASE_CONTROL (Controle de Fases)
-- =====================================================
CREATE TABLE IF NOT EXISTS phase_control (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  phase_name VARCHAR(50) NOT NULL, -- 'members_registration', 'paid_contracts'
  is_active BOOLEAN DEFAULT false,
  start_date DATE,
  end_date DATE,
  max_limit INTEGER, -- Limite máximo (1500 para membros, etc.)
  current_count INTEGER DEFAULT 0, -- Contagem atual
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 6. TABELA USER_LINKS (Links de Cadastro)
-- =====================================================
CREATE TABLE IF NOT EXISTS user_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  link_type VARCHAR(20) DEFAULT 'members' CHECK (link_type IN ('members', 'friends')),
  click_count INTEGER DEFAULT 0,
  registration_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. TABELA INSTAGRAM_POSTS (Fiscalização)
-- =====================================================
CREATE TABLE IF NOT EXISTS instagram_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  contract_id UUID NOT NULL REFERENCES paid_contracts(id) ON DELETE CASCADE,
  person_number INTEGER NOT NULL CHECK (person_number IN (1, 2)), -- 1 ou 2 (qual pessoa do casal)
  post_url VARCHAR(500) NOT NULL,
  hashtag VARCHAR(100) NOT NULL,
  post_date DATE NOT NULL,
  verified BOOLEAN DEFAULT false,
  verified_by UUID REFERENCES auth_users(id),
  verified_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para members
CREATE INDEX IF NOT EXISTS idx_members_ranking_status ON members(ranking_status);
CREATE INDEX IF NOT EXISTS idx_members_contracts_completed ON members(contracts_completed);
CREATE INDEX IF NOT EXISTS idx_members_is_top_1500 ON members(is_top_1500);
CREATE INDEX IF NOT EXISTS idx_members_ranking_position ON members(ranking_position);

-- Índices para paid_contracts
CREATE INDEX IF NOT EXISTS idx_paid_contracts_member_id ON paid_contracts(member_id);
CREATE INDEX IF NOT EXISTS idx_paid_contracts_status ON paid_contracts(contract_status);
CREATE INDEX IF NOT EXISTS idx_paid_contracts_date ON paid_contracts(contract_date);

-- Índices para member_ranking
CREATE INDEX IF NOT EXISTS idx_member_ranking_position ON member_ranking(ranking_position);
CREATE INDEX IF NOT EXISTS idx_member_ranking_status ON member_ranking(ranking_status);

-- Índices para instagram_posts
CREATE INDEX IF NOT EXISTS idx_instagram_posts_contract_id ON instagram_posts(contract_id);
CREATE INDEX IF NOT EXISTS idx_instagram_posts_verified ON instagram_posts(verified);

-- =====================================================
-- CONFIGURAÇÕES INICIAIS DO SISTEMA
-- =====================================================

-- Inserir configurações padrão
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('max_members', '1500', 'Limite máximo de membros cadastrados'),
('contracts_per_member', '15', 'Número máximo de contratos pagos por membro'),
('ranking_green_threshold', '15', 'Número de contratos para status Verde'),
('ranking_yellow_threshold', '1', 'Número mínimo de contratos para status Amarelo'),
('paid_contracts_phase_active', 'false', 'Se a fase de contratos pagos está ativa'),
('paid_contracts_start_date', '2026-07-01', 'Data de início da fase de contratos pagos'),
('member_links_type', 'members', 'Tipo de links gerados pelos membros: members (novos membros) ou friends (contratos pagos)'),
('admin_controls_link_type', 'true', 'Se administradores podem controlar o tipo de links gerados')
ON CONFLICT (setting_key) DO NOTHING;

-- Inserir controle de fases inicial
INSERT INTO phase_control (phase_name, is_active, max_limit, current_count) VALUES
('members_registration', true, 1500, 0),
('paid_contracts', false, 22500, 0) -- 1500 membros × 15 contratos
ON CONFLICT DO NOTHING;

-- =====================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA
-- =====================================================

-- Trigger para atualizar ranking quando contratos mudam
CREATE OR REPLACE FUNCTION update_member_ranking()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualizar contagem de contratos do membro
  UPDATE members 
  SET contracts_completed = (
    SELECT COUNT(*) 
    FROM paid_contracts 
    WHERE member_id = NEW.member_id 
    AND contract_status = 'Completo'
  )
  WHERE id = NEW.member_id;
  
  -- Atualizar status do ranking baseado nos contratos
  UPDATE members 
  SET ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
  END
  WHERE id = NEW.member_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_member_ranking
  AFTER INSERT OR UPDATE OR DELETE ON paid_contracts
  FOR EACH ROW EXECUTE FUNCTION update_member_ranking();

-- Trigger para atualizar contagem de membros
CREATE OR REPLACE FUNCTION update_member_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE phase_control 
  SET current_count = (SELECT COUNT(*) FROM members WHERE status = 'Ativo')
  WHERE phase_name = 'members_registration';
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_member_count
  AFTER INSERT OR UPDATE OR DELETE ON members
  FOR EACH ROW EXECUTE FUNCTION update_member_count();

-- =====================================================
-- POLÍTICAS DE SEGURANÇA (RLS)
-- =====================================================

-- Habilitar RLS
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE paid_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_ranking ENABLE ROW LEVEL SECURITY;
ALTER TABLE instagram_posts ENABLE ROW LEVEL SECURITY;

-- Políticas para members (todos podem ver, apenas admins podem modificar)
CREATE POLICY "members_select_policy" ON members FOR SELECT USING (true);
CREATE POLICY "members_insert_policy" ON members FOR INSERT WITH CHECK (true);
CREATE POLICY "members_update_policy" ON members FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM auth_users 
    WHERE auth_users.id = auth.uid() 
    AND auth_users.role IN ('Admin', 'Administrador')
  )
);

-- Políticas para paid_contracts
CREATE POLICY "paid_contracts_select_policy" ON paid_contracts FOR SELECT USING (true);
CREATE POLICY "paid_contracts_insert_policy" ON paid_contracts FOR INSERT WITH CHECK (true);
CREATE POLICY "paid_contracts_update_policy" ON paid_contracts FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM auth_users 
    WHERE auth_users.id = auth.uid() 
    AND auth_users.role IN ('Admin', 'Administrador')
  )
);

-- =====================================================
-- FUNÇÕES AUXILIARES
-- =====================================================

-- Função para verificar se pode cadastrar mais membros
CREATE OR REPLACE FUNCTION can_register_member()
RETURNS BOOLEAN AS $$
DECLARE
  current_member_count INTEGER;
  max_member_limit INTEGER;
BEGIN
  SELECT pc.current_count, pc.max_limit 
  INTO current_member_count, max_member_limit
  FROM phase_control pc
  WHERE pc.phase_name = 'members_registration';
  
  RETURN current_member_count < max_member_limit;
END;
$$ LANGUAGE plpgsql;

-- Função para verificar se pode cadastrar contratos pagos
CREATE OR REPLACE FUNCTION can_register_paid_contract()
RETURNS BOOLEAN AS $$
DECLARE
  phase_active BOOLEAN;
BEGIN
  SELECT is_active 
  INTO phase_active
  FROM phase_control 
  WHERE phase_name = 'paid_contracts';
  
  RETURN phase_active;
END;
$$ LANGUAGE plpgsql;

-- Função para atualizar ranking completo
CREATE OR REPLACE FUNCTION update_complete_ranking()
RETURNS VOID AS $$
BEGIN
  -- Atualizar posições do ranking baseado em contratos completados
  WITH ranked_members AS (
    SELECT 
      id,
      ROW_NUMBER() OVER (ORDER BY contracts_completed DESC, created_at ASC) as new_position
    FROM members 
    WHERE status = 'Ativo'
  )
  UPDATE members 
  SET ranking_position = rm.new_position
  FROM ranked_members rm
  WHERE members.id = rm.id;
  
  -- Atualizar status de top 1500
  UPDATE members 
  SET is_top_1500 = (ranking_position <= 1500)
  WHERE status = 'Ativo';
  
  -- Atualizar quem pode ser substituído (vermelhos fora do top 1500)
  UPDATE members 
  SET can_be_replaced = (ranking_status = 'Vermelho' AND NOT is_top_1500)
  WHERE status = 'Ativo';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS PARA RELATÓRIOS
-- =====================================================

-- View para ranking completo
CREATE OR REPLACE VIEW v_member_ranking AS
SELECT 
  m.id,
  m.name,
  m.instagram,
  m.city,
  m.sector,
  m.contracts_completed,
  m.ranking_position,
  m.ranking_status,
  m.is_top_1500,
  m.can_be_replaced,
  COUNT(pc.id) as total_contracts,
  COUNT(CASE WHEN pc.contract_status = 'Completo' THEN 1 END) as completed_contracts,
  COUNT(CASE WHEN pc.contract_status = 'Pendente' THEN 1 END) as pending_contracts
FROM members m
LEFT JOIN paid_contracts pc ON m.id = pc.member_id
WHERE m.status = 'Ativo'
GROUP BY m.id, m.name, m.instagram, m.city, m.sector, m.contracts_completed, 
         m.ranking_position, m.ranking_status, m.is_top_1500, m.can_be_replaced
ORDER BY m.ranking_position;

-- View para estatísticas gerais
CREATE OR REPLACE VIEW v_system_stats AS
SELECT 
  (SELECT COUNT(*) FROM members WHERE status = 'Ativo') as total_members,
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Verde' AND status = 'Ativo') as green_members,
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Amarelo' AND status = 'Ativo') as yellow_members,
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Vermelho' AND status = 'Ativo') as red_members,
  (SELECT COUNT(*) FROM members WHERE is_top_1500 = true AND status = 'Ativo') as top_1500_members,
  (SELECT COUNT(*) FROM paid_contracts WHERE contract_status = 'Completo') as completed_contracts,
  (SELECT COUNT(*) FROM paid_contracts WHERE contract_status = 'Pendente') as pending_contracts,
  (SELECT current_count FROM phase_control WHERE phase_name = 'members_registration') as current_member_count,
  (SELECT max_limit FROM phase_control WHERE phase_name = 'members_registration') as max_member_limit;

-- =====================================================
-- MIGRAÇÃO DE DADOS EXISTENTES (se necessário)
-- =====================================================

-- Migrar dados da tabela users para members (se a tabela users existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
    INSERT INTO members (name, phone, instagram, city, sector, referrer, registration_date, status, created_at)
    SELECT name, phone, instagram, city, sector, referrer, registration_date, status, created_at
    FROM users
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- =====================================================
-- COMENTÁRIOS FINAIS
-- =====================================================

COMMENT ON TABLE members IS 'Tabela principal dos membros/coordenadores do sistema';
COMMENT ON TABLE paid_contracts IS 'Contratos pagos (amigos) que cada membro pode cadastrar';
COMMENT ON TABLE system_settings IS 'Configurações gerais do sistema';
COMMENT ON TABLE member_ranking IS 'Ranking e posições dos membros';
COMMENT ON TABLE phase_control IS 'Controle das fases do sistema (membros, contratos pagos)';
COMMENT ON TABLE instagram_posts IS 'Fiscalização via posts do Instagram';

COMMENT ON COLUMN members.contracts_completed IS 'Número de contratos pagos completados (0-15)';
COMMENT ON COLUMN members.ranking_status IS 'Status do ranking: Verde (15 contratos), Amarelo (1-14), Vermelho (0)';
COMMENT ON COLUMN members.is_top_1500 IS 'Se está entre os top 1500 membros';
COMMENT ON COLUMN members.can_be_replaced IS 'Se pode ser substituído por alguém da reserva';

COMMENT ON COLUMN paid_contracts.contract_status IS 'Status: Pendente, Ativo, Completo, Cancelado';
COMMENT ON COLUMN paid_contracts.post_verified_1 IS 'Se o post da primeira pessoa foi verificado';
COMMENT ON COLUMN paid_contracts.post_verified_2 IS 'Se o post da segunda pessoa foi verificado';
