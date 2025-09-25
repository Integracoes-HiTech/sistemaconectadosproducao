-- Script SQL para criar as tabelas no Supabase
-- Execute este script no SQL Editor do Supabase

-- Tabela de usuários cadastrados
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
  registration_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de usuários de autenticação
CREATE TABLE auth_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir usuários de exemplo
INSERT INTO auth_users (username, password, name, role, full_name) VALUES
('joao', 'coordenador', 'João Silva', 'Coordenador', 'João Silva - Coordenador'),
('marcos', 'colaborador', 'Marcos Santos', 'Colaborador', 'Marcos Santos - Colaborador'),
('admin', 'admin123', 'Admin', 'Administrador', 'Admin - Administrador'),
('wegneycosta', 'vereador', 'Wegney Costa', 'Vereador', 'Wegney Costa - Vereador');

-- Criar índices para melhor performance
CREATE INDEX idx_users_referrer ON users(referrer);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_registration_date ON users(registration_date);
CREATE INDEX idx_auth_users_username ON auth_users(username);

-- Habilitar Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_users ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança para a tabela users
-- Permitir leitura para todos os usuários autenticados
CREATE POLICY "Users can read all users" ON users
  FOR SELECT USING (true);

-- Permitir inserção para todos
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

-- Políticas de segurança para a tabela auth_users
-- Permitir leitura apenas para usuários autenticados
CREATE POLICY "Authenticated users can read auth_users" ON auth_users
  FOR SELECT USING (true);

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
