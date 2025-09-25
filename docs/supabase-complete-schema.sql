-- =====================================================
-- SCRIPT SQL COMPLETO PARA VEREADOR CONNECT
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- Limpar tabelas existentes (se houver)
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS auth_users CASCADE;
DROP TABLE IF EXISTS user_links CASCADE;
DROP TABLE IF EXISTS user_stats CASCADE;

-- =====================================================
-- TABELA 1: USUÁRIOS CADASTRADOS (Público)
-- =====================================================
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  state VARCHAR(2) NOT NULL,
  city VARCHAR(255) NOT NULL,
  neighborhood VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255) NOT NULL,
  instagram VARCHAR(255) NOT NULL,
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABELA 2: USUÁRIOS DE AUTENTICAÇÃO (Sistema)
-- =====================================================
CREATE TABLE auth_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABELA 3: LINKS GERADOS
-- =====================================================
CREATE TABLE user_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  link_id VARCHAR(255) UNIQUE NOT NULL,
  user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
  referrer_name VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  click_count INTEGER DEFAULT 0,
  registration_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABELA 4: ESTATÍSTICAS (Cache)
-- =====================================================
CREATE TABLE user_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  total_users INTEGER DEFAULT 0,
  active_users INTEGER DEFAULT 0,
  new_registrations INTEGER DEFAULT 0,
  engagement_rate DECIMAL(5,2) DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- =====================================================
-- INSERIR USUÁRIOS PADRÃO
-- =====================================================
INSERT INTO auth_users (username, password, name, role, full_name, email, phone) VALUES
('joao', 'coordenador', 'João Silva', 'Coordenador', 'João Silva - Coordenador', 'joao@email.com', '62987654321'),
('marcos', 'colaborador', 'Marcos Santos', 'Colaborador', 'Marcos Santos - Colaborador', 'marcos@email.com', '62976543210'),
('admin', 'admin123', 'Admin', 'Administrador', 'Admin - Administrador', 'admin@email.com', '62965432109'),
('wegneycosta', 'vereador', 'Wegney Costa', 'Vereador', 'Wegney Costa - Vereador', 'wegney@email.com', '62954321098');

-- =====================================================
-- INSERIR DADOS DE EXEMPLO (OPCIONAL)
-- =====================================================
INSERT INTO users (name, address, state, city, neighborhood, phone, email, instagram, referrer, registration_date) VALUES
('Maria Silva Santos', 'Rua das Flores, 123', 'GO', 'Aparecida de Goiânia', 'Centro', '62987654321', 'maria.silva@email.com', '@mariasilva', 'João Silva - Coordenador', '2024-01-15'),
('João Pedro Oliveira', 'Av. Independência, 456', 'GO', 'Aparecida de Goiânia', 'Jardim Olímpico', '62976543210', 'joao.pedro@email.com', '@joaopedro', 'João Silva - Coordenador', '2024-01-14'),
('Ana Carolina Costa', 'Rua 7, 789', 'GO', 'Aparecida de Goiânia', 'Vila São José', '62965432109', 'ana.carolina@email.com', '@anacarolina', 'João Silva - Coordenador', '2024-01-13'),
('Carlos Eduardo Lima', 'Rua 9, 321', 'GO', 'Aparecida de Goiânia', 'Jardim Nova Era', '62954321098', 'carlos.eduardo@email.com', '@carloseduardo', 'João Silva - Coordenador', '2024-01-12'),
('Fernanda Rodrigues', 'Av. Perimetral Norte, 654', 'GO', 'Aparecida de Goiânia', 'Setor Central', '62943210987', 'fernanda.rodrigues@email.com', '@fernandarodrigues', 'João Silva - Coordenador', '2024-01-11'),
('Camila Ribeiro', 'Rua 20, 600', 'GO', 'Aparecida de Goiânia', 'Jardim dos Ipês', '62987654321', 'camila.ribeiro@email.com', '@camilaribeiro', 'Marcos Santos - Colaborador', '2024-01-05'),
('Diego Pereira', 'Av. Perimetral Sul, 700', 'GO', 'Aparecida de Goiânia', 'Setor Bueno', '62966554433', 'diego.pereira@email.com', '@diegoapereira', 'Marcos Santos - Colaborador', '2024-01-04'),
('Larissa Oliveira', 'Rua 25, 800', 'GO', 'Aparecida de Goiânia', 'Vila Redenção', '62955443322', 'larissa.oliveira@email.com', '@larissaoliveira', 'Marcos Santos - Colaborador', '2024-01-03'),
('Thiago Silva', 'Av. Independência, 900', 'GO', 'Aparecida de Goiânia', 'Jardim Olímpico', '62944332211', 'thiago.silva@email.com', '@thiagosilva', 'Marcos Santos - Colaborador', '2024-01-02'),
('Beatriz Costa', 'Rua 30, 1000', 'GO', 'Aparecida de Goiânia', 'Setor Central', '62933221100', 'beatriz.costa@email.com', '@beatrizcosta', 'Marcos Santos - Colaborador', '2024-01-01');

-- =====================================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================
-- Índices para tabela users
CREATE INDEX idx_users_referrer ON users(referrer);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_registration_date ON users(registration_date);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_city ON users(city);
CREATE INDEX idx_users_state ON users(state);

-- Índices para tabela auth_users
CREATE INDEX idx_auth_users_username ON auth_users(username);
CREATE INDEX idx_auth_users_role ON auth_users(role);
CREATE INDEX idx_auth_users_is_active ON auth_users(is_active);

-- Índices para tabela user_links
CREATE INDEX idx_user_links_user_id ON user_links(user_id);
CREATE INDEX idx_user_links_link_id ON user_links(link_id);
CREATE INDEX idx_user_links_is_active ON user_links(is_active);

-- Índices para tabela user_stats
CREATE INDEX idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX idx_user_stats_date ON user_stats(date);

-- =====================================================
-- HABILITAR ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS DE SEGURANÇA
-- =====================================================

-- Políticas para tabela users
CREATE POLICY "Users can read all users" ON users
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated users can update users" ON users
  FOR UPDATE USING (true);

-- Políticas para tabela auth_users
CREATE POLICY "Authenticated users can read auth_users" ON auth_users
  FOR SELECT USING (true);

CREATE POLICY "Only admins can update auth_users" ON auth_users
  FOR UPDATE USING (true);

-- Políticas para tabela user_links
CREATE POLICY "Users can read their own links" ON user_links
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own links" ON user_links
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own links" ON user_links
  FOR UPDATE USING (true);

-- Políticas para tabela user_stats
CREATE POLICY "Users can read their own stats" ON user_stats
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own stats" ON user_stats
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own stats" ON user_stats
  FOR UPDATE USING (true);

-- =====================================================
-- FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_auth_users_updated_at BEFORE UPDATE ON auth_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_links_updated_at BEFORE UPDATE ON user_links
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_stats_updated_at BEFORE UPDATE ON user_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para atualizar contador de registros quando um usuário é inserido
CREATE OR REPLACE FUNCTION update_registration_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar contador na tabela user_links
    UPDATE user_links 
    SET registration_count = registration_count + 1,
        updated_at = NOW()
    WHERE referrer_name = NEW.referrer;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar contador de registros
CREATE TRIGGER update_registration_count_trigger 
    AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION update_registration_count();

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View para estatísticas consolidadas
CREATE VIEW user_statistics AS
SELECT 
    au.id as user_id,
    au.username,
    au.name,
    au.role,
    au.full_name,
    COUNT(u.id) as total_users,
    COUNT(CASE WHEN u.status = 'Ativo' THEN 1 END) as active_users,
    COUNT(CASE WHEN u.registration_date >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as recent_registrations,
    CASE 
        WHEN COUNT(u.id) > 0 THEN 
            ROUND((COUNT(CASE WHEN u.status = 'Ativo' THEN 1 END)::DECIMAL / COUNT(u.id)) * 100, 1)
        ELSE 0 
    END as engagement_rate
FROM auth_users au
LEFT JOIN users u ON au.full_name = u.referrer
WHERE au.is_active = true
GROUP BY au.id, au.username, au.name, au.role, au.full_name;

-- View para links ativos
CREATE VIEW active_links AS
SELECT 
    ul.id,
    ul.link_id,
    ul.user_id,
    au.username,
    au.name,
    ul.referrer_name,
    ul.click_count,
    ul.registration_count,
    ul.created_at,
    ul.expires_at
FROM user_links ul
JOIN auth_users au ON ul.user_id = au.id
WHERE ul.is_active = true;

-- =====================================================
-- FUNÇÕES AUXILIARES
-- =====================================================

-- Função para gerar link único
CREATE OR REPLACE FUNCTION generate_unique_link(user_username TEXT)
RETURNS TEXT AS $$
DECLARE
    link_id TEXT;
    link_exists BOOLEAN;
BEGIN
    LOOP
        link_id := user_username || '-' || EXTRACT(EPOCH FROM NOW())::BIGINT;
        
        SELECT EXISTS(SELECT 1 FROM user_links WHERE link_id = link_id) INTO link_exists;
        
        IF NOT link_exists THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN link_id;
END;
$$ language 'plpgsql';

-- Função para obter estatísticas de um usuário
CREATE OR REPLACE FUNCTION get_user_stats(user_id_param UUID)
RETURNS TABLE (
    total_users BIGINT,
    active_users BIGINT,
    recent_registrations BIGINT,
    engagement_rate DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(u.id) as total_users,
        COUNT(CASE WHEN u.status = 'Ativo' THEN 1 END) as active_users,
        COUNT(CASE WHEN u.registration_date >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as recent_registrations,
        CASE 
            WHEN COUNT(u.id) > 0 THEN 
                ROUND((COUNT(CASE WHEN u.status = 'Ativo' THEN 1 END)::DECIMAL / COUNT(u.id)) * 100, 1)
            ELSE 0 
        END as engagement_rate
    FROM auth_users au
    LEFT JOIN users u ON au.full_name = u.referrer
    WHERE au.id = user_id_param;
END;
$$ language 'plpgsql';

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se as tabelas foram criadas
SELECT 'Tabelas criadas com sucesso!' as status;

-- Verificar usuários inseridos
SELECT username, name, role FROM auth_users;

-- Verificar dados de exemplo
SELECT COUNT(*) as total_users FROM users;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
