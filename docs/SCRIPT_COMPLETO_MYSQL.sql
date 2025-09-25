-- =====================================================
-- SCRIPT SQL COMPLETO PARA MYSQL (phpMyAdmin)
-- Migração completa do Supabase para MySQL
-- Baseado na estrutura ATUAL do banco Supabase
-- =====================================================

-- Limpar tabelas existentes (se houver)
DROP TABLE IF EXISTS user_stats;
DROP TABLE IF EXISTS user_links;
DROP TABLE IF EXISTS auth_users;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS sectors;
DROP TABLE IF EXISTS friends;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS paid_contracts;
DROP TABLE IF EXISTS member_ranking;
DROP TABLE IF EXISTS phase_control;
DROP TABLE IF EXISTS instagram_posts;
DROP TABLE IF EXISTS system_settings;

-- =====================================================
-- TABELA 1: USUÁRIOS CADASTRADOS (Público) - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL UNIQUE,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL DEFAULT 'Centro',
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 2: USUÁRIOS DE AUTENTICAÇÃO (Sistema) - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE auth_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  instagram VARCHAR(255),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  last_login DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 3: LINKS GERADOS - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE user_links (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  link_type ENUM('members', 'friends') DEFAULT 'members',
  click_count INT DEFAULT 0,
  registration_count INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES auth_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 4: MEMBROS (Sistema Principal) - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL,
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo',
  
  -- Dados da segunda pessoa (obrigatório - regra do casal)
  couple_name VARCHAR(255) NOT NULL,
  couple_phone VARCHAR(20) NOT NULL,
  couple_instagram VARCHAR(255) NOT NULL,
  
  -- Campos específicos do sistema de membros
  contracts_completed INT DEFAULT 0, -- Contratos pagos completados (máximo 15)
  ranking_position INT, -- Posição no ranking
  ranking_status ENUM('Verde', 'Amarelo', 'Vermelho') DEFAULT 'Vermelho',
  is_top_1500 BOOLEAN DEFAULT false, -- Se está entre os top 1500
  can_be_replaced BOOLEAN DEFAULT false, -- Se pode ser substituído (status vermelho)
  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 5: AMIGOS (Contratos Pagos) - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE friends (
  id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL, -- Referência ao membro que cadastrou
  
  -- Mesma estrutura de membros
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL,
  referrer VARCHAR(255) NOT NULL, -- Nome do membro que cadastrou
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo',
  
  -- Dados da segunda pessoa (obrigatório - regra do casal)
  couple_name VARCHAR(255) NOT NULL,
  couple_phone VARCHAR(20) NOT NULL,
  couple_instagram VARCHAR(255) NOT NULL,
  couple_city VARCHAR(255) NOT NULL,
  couple_sector VARCHAR(255) NOT NULL,
  
  -- Campos específicos do sistema (mesma lógica de membros)
  contracts_completed INT DEFAULT 0, -- Quantos usuários este amigo cadastrou
  ranking_position INT, -- Posição no ranking de amigos
  ranking_status ENUM('Verde', 'Amarelo', 'Vermelho') DEFAULT 'Vermelho',
  is_top_1500 BOOLEAN DEFAULT false, -- Se está entre os top performers
  can_be_replaced BOOLEAN DEFAULT false,
  
  -- Campos de verificação de posts (específicos de amigos)
  post_verified_1 BOOLEAN DEFAULT false,
  post_verified_2 BOOLEAN DEFAULT false,
  post_url_1 TEXT,
  post_url_2 TEXT,
  
  -- Campo para soft delete
  deleted_at DATETIME,
  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign key para o membro que cadastrou
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 6: CONTRATOS PAGOS - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE paid_contracts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL,
  
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
  contract_status ENUM('Pendente', 'Ativo', 'Completo', 'Cancelado') DEFAULT 'Pendente',
  contract_date DATE NOT NULL DEFAULT CURRENT_DATE,
  completion_date DATE, -- Data de conclusão
  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 7: CONFIGURAÇÕES DO SISTEMA - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 8: RANKING DOS MEMBROS - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE member_ranking (
  id INT AUTO_INCREMENT PRIMARY KEY,
  member_id INT NOT NULL,
  ranking_position INT NOT NULL,
  contracts_completed INT DEFAULT 0,
  ranking_status ENUM('Verde', 'Amarelo', 'Vermelho') DEFAULT 'Vermelho',
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY unique_member_position (member_id, ranking_position),
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 9: CONTROLE DE FASES - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE phase_control (
  id INT AUTO_INCREMENT PRIMARY KEY,
  phase_name VARCHAR(50) NOT NULL, -- 'members_registration', 'paid_contracts'
  is_active BOOLEAN DEFAULT false,
  start_date DATE,
  end_date DATE,
  max_limit INT, -- Limite máximo (1500 para membros, etc.)
  current_count INT DEFAULT 0, -- Contagem atual
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TABELA 10: POSTS DO INSTAGRAM (Fiscalização) - ESTRUTURA ATUAL
-- =====================================================
CREATE TABLE instagram_posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  contract_id INT NOT NULL,
  person_number INT NOT NULL, -- 1 ou 2 (qual pessoa do casal)
  post_url VARCHAR(500) NOT NULL,
  hashtag VARCHAR(100) NOT NULL,
  post_date DATE NOT NULL,
  verified BOOLEAN DEFAULT false,
  verified_by INT,
  verified_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (contract_id) REFERENCES paid_contracts(id) ON DELETE CASCADE,
  FOREIGN KEY (verified_by) REFERENCES auth_users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- INSERIR USUÁRIOS PADRÃO
-- =====================================================
INSERT INTO auth_users (username, password, name, role, full_name, instagram, phone) VALUES
('joao', 'coordenador', 'João Silva', 'Coordenador', 'João Silva - Coordenador', '@joaosilva', '62987654321'),
('marcos', 'colaborador', 'Marcos Santos', 'Colaborador', 'Marcos Santos - Colaborador', '@marcossantos', '62976543210'),
('admin', 'admin123', 'Admin', 'Administrador', 'Admin - Administrador', '@admin', '62965432109'),
('wegneycosta', 'vereador', 'Wegney Costa', 'Vereador', 'Wegney Costa - Vereador', '@wegneycosta', '62954321098');

-- =====================================================
-- INSERIR DADOS DE EXEMPLO
-- =====================================================
INSERT INTO users (name, phone, instagram, city, sector, referrer, registration_date) VALUES
('Maria Silva Santos', '62987654321', '@mariasilva', 'Aparecida de Goiânia', 'Centro', 'João Silva - Coordenador', '2024-01-15'),
('João Pedro Oliveira', '62976543210', '@joaopedro', 'Aparecida de Goiânia', 'Jardim Olímpico', 'João Silva - Coordenador', '2024-01-14'),
('Ana Carolina Costa', '62965432109', '@anacarolina', 'Aparecida de Goiânia', 'Vila São José', 'João Silva - Coordenador', '2024-01-13'),
('Carlos Eduardo Lima', '62954321098', '@carloseduardo', 'Aparecida de Goiânia', 'Jardim Nova Era', 'João Silva - Coordenador', '2024-01-12'),
('Fernanda Rodrigues', '62943210987', '@fernandarodrigues', 'Aparecida de Goiânia', 'Setor Central', 'João Silva - Coordenador', '2024-01-11');

-- =====================================================
-- INSERIR CONFIGURAÇÕES INICIAIS DO SISTEMA
-- =====================================================
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('max_members', '1500', 'Limite máximo de membros cadastrados'),
('contracts_per_member', '15', 'Número máximo de contratos pagos por membro'),
('ranking_green_threshold', '15', 'Número de contratos para status Verde'),
('ranking_yellow_threshold', '1', 'Número mínimo de contratos para status Amarelo'),
('paid_contracts_phase_active', 'false', 'Se a fase de contratos pagos está ativa'),
('paid_contracts_start_date', '2026-07-01', 'Data de início da fase de contratos pagos'),
('member_links_type', 'members', 'Tipo de links gerados pelos membros: members (novos membros) ou friends (contratos pagos)'),
('admin_controls_link_type', 'true', 'Se administradores podem controlar o tipo de links gerados');

-- =====================================================
-- INSERIR CONTROLE DE FASES INICIAL
-- =====================================================
INSERT INTO phase_control (phase_name, is_active, max_limit, current_count) VALUES
('members_registration', true, 1500, 0),
('paid_contracts', false, 22500, 0); -- 1500 membros × 15 contratos

-- =====================================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================
-- Índices para tabela users
CREATE INDEX idx_users_referrer ON users(referrer);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_registration_date ON users(registration_date);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_city ON users(city);
CREATE INDEX idx_users_instagram ON users(instagram);
CREATE INDEX idx_users_sector ON users(sector);

-- Índices para tabela auth_users
CREATE INDEX idx_auth_users_username ON auth_users(username);
CREATE INDEX idx_auth_users_role ON auth_users(role);
CREATE INDEX idx_auth_users_is_active ON auth_users(is_active);
CREATE INDEX idx_auth_users_instagram ON auth_users(instagram);

-- Índices para tabela user_links
CREATE INDEX idx_user_links_user_id ON user_links(user_id);
CREATE INDEX idx_user_links_link_type ON user_links(link_type);

-- Índices para tabela members
CREATE INDEX idx_members_ranking_status ON members(ranking_status);
CREATE INDEX idx_members_contracts_completed ON members(contracts_completed);
CREATE INDEX idx_members_is_top_1500 ON members(is_top_1500);
CREATE INDEX idx_members_ranking_position ON members(ranking_position);
CREATE INDEX idx_members_status ON members(status);
CREATE INDEX idx_members_referrer ON members(referrer);

-- Índices para tabela friends
CREATE INDEX idx_friends_member_id ON friends(member_id);
CREATE INDEX idx_friends_status ON friends(status);
CREATE INDEX idx_friends_ranking_status ON friends(ranking_status);
CREATE INDEX idx_friends_deleted_at ON friends(deleted_at);
CREATE INDEX idx_friends_referrer ON friends(referrer);
CREATE INDEX idx_friends_contracts_completed ON friends(contracts_completed);

-- Índices para tabela paid_contracts
CREATE INDEX idx_paid_contracts_member_id ON paid_contracts(member_id);
CREATE INDEX idx_paid_contracts_status ON paid_contracts(contract_status);
CREATE INDEX idx_paid_contracts_date ON paid_contracts(contract_date);

-- Índices para tabela member_ranking
CREATE INDEX idx_member_ranking_position ON member_ranking(ranking_position);
CREATE INDEX idx_member_ranking_status ON member_ranking(ranking_status);

-- Índices para tabela instagram_posts
CREATE INDEX idx_instagram_posts_contract_id ON instagram_posts(contract_id);
CREATE INDEX idx_instagram_posts_verified ON instagram_posts(verified);

-- =====================================================
-- TRIGGERS PARA ATUALIZAR CONTADORES
-- =====================================================

-- Trigger para atualizar ranking quando contratos mudam
DELIMITER //
CREATE TRIGGER trigger_update_member_ranking
    AFTER INSERT OR UPDATE OR DELETE ON paid_contracts
    FOR EACH ROW
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
END//
DELIMITER ;

-- Trigger para atualizar contagem de membros
DELIMITER //
CREATE TRIGGER trigger_update_member_count
    AFTER INSERT OR UPDATE OR DELETE ON members
    FOR EACH ROW
BEGIN
    UPDATE phase_control 
    SET current_count = (SELECT COUNT(*) FROM members WHERE status = 'Ativo')
    WHERE phase_name = 'members_registration';
END//
DELIMITER ;

-- =====================================================
-- FUNÇÕES AUXILIARES (Simuladas com Procedures)
-- =====================================================

-- Procedure para verificar se pode cadastrar mais membros
DELIMITER //
CREATE PROCEDURE can_register_member(OUT can_register BOOLEAN)
BEGIN
    DECLARE current_member_count INT DEFAULT 0;
    DECLARE max_member_limit INT DEFAULT 0;
    
    SELECT pc.current_count, pc.max_limit 
    INTO current_member_count, max_member_limit
    FROM phase_control pc
    WHERE pc.phase_name = 'members_registration';
    
    SET can_register = (current_member_count < max_member_limit);
END//
DELIMITER ;

-- Procedure para verificar se pode cadastrar contratos pagos
DELIMITER //
CREATE PROCEDURE can_register_paid_contract(OUT can_register BOOLEAN)
BEGIN
    DECLARE phase_active BOOLEAN DEFAULT false;
    
    SELECT is_active 
    INTO phase_active
    FROM phase_control 
    WHERE phase_name = 'paid_contracts';
    
    SET can_register = phase_active;
END//
DELIMITER ;

-- Procedure para atualizar ranking completo
DELIMITER //
CREATE PROCEDURE update_complete_ranking()
BEGIN
    -- Atualizar posições do ranking baseado em contratos completados
    UPDATE members 
    SET ranking_position = (
        SELECT COUNT(*) + 1
        FROM members m2
        WHERE m2.contracts_completed > members.contracts_completed
        AND m2.status = 'Ativo'
    )
    WHERE status = 'Ativo';
    
    -- Atualizar status de top 1500
    UPDATE members 
    SET is_top_1500 = (ranking_position <= 1500)
    WHERE status = 'Ativo';
    
    -- Atualizar quem pode ser substituído (vermelhos fora do top 1500)
    UPDATE members 
    SET can_be_replaced = (ranking_status = 'Vermelho' AND NOT is_top_1500)
    WHERE status = 'Ativo';
END//
DELIMITER ;

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View para ranking completo
CREATE VIEW v_member_ranking AS
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
CREATE VIEW v_system_stats AS
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
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se as tabelas foram criadas
SELECT 'Tabelas criadas com sucesso!' as status;

-- Verificar usuários inseridos
SELECT username, name, role FROM auth_users;

-- Verificar dados de exemplo
SELECT COUNT(*) as total_users FROM users;

-- Verificar configurações do sistema
SELECT setting_key, setting_value FROM system_settings;

-- Verificar controle de fases
SELECT phase_name, is_active, max_limit, current_count FROM phase_control;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
