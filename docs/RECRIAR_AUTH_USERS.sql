-- SCRIPT PARA RECRIAR DADOS NA TABELA AUTH_USERS
-- Execute este script no SQL Editor do Supabase

-- 1. PRIMEIRO, VERIFICAR SE A TABELA AUTH_USERS EXISTE
-- Se não existir, criar a tabela
CREATE TABLE IF NOT EXISTS auth_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  instagram VARCHAR(255),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. LIMPAR DADOS EXISTENTES (se necessário)
-- DESCOMENTE A LINHA ABAIXO SE QUISER LIMPAR TODOS OS DADOS EXISTENTES
-- DELETE FROM auth_users;

-- 3. INSERIR USUÁRIOS PADRÃO DO SISTEMA
INSERT INTO auth_users (username, password, name, role, full_name, instagram, phone, is_active) VALUES
-- Administrador principal
('wegneycosta', 'vereador', 'Wegney Costa', 'admin', 'Wegney Costa - Administrador', 'wegneycosta', '62999999999', true),

-- Coordenadores principais
('joao', 'coordenador', 'João Silva', 'Membro', 'João Silva - Coordenador', 'joaosilva', '62988888888', true),
('marcos', 'colaborador', 'Marcos Santos', 'Membro', 'Marcos Santos - Colaborador', 'marcossantos', '62977777777', true),

-- Administrador do sistema
('admin', 'admin123', 'Admin Sistema', 'admin', 'Admin Sistema - Administrador', 'admin', '62966666666', true),

-- Membros da equipe
('ana', 'membro123', 'Ana Costa', 'Membro', 'Ana Costa - Membro', 'anacosta', '62955555555', true),
('carlos', 'membro123', 'Carlos Oliveira', 'Membro', 'Carlos Oliveira - Membro', 'carlosoliveira', '62944444444', true),
('maria', 'membro123', 'Maria Santos', 'Membro', 'Maria Santos - Membro', 'mariasantos', '62933333333', true),

-- Amigos/Convidados
('pedro', 'amigo123', 'Pedro Lima', 'Amigo', 'Pedro Lima - Amigo', 'pedrolima', '62922222222', true),
('julia', 'amigo123', 'Julia Ferreira', 'Amigo', 'Julia Ferreira - Amigo', 'juliaferreira', '62911111111', true),

-- Convidados especiais
('roberto', 'convidado123', 'Roberto Silva', 'Convidado', 'Roberto Silva - Convidado', 'robertosilva', '62900000000', true),
('fernanda', 'convidado123', 'Fernanda Costa', 'Convidado', 'Fernanda Costa - Convidado', 'fernandacosta', '62899999999', true)

ON CONFLICT (username) DO UPDATE SET
  password = EXCLUDED.password,
  name = EXCLUDED.name,
  role = EXCLUDED.role,
  full_name = EXCLUDED.full_name,
  instagram = EXCLUDED.instagram,
  phone = EXCLUDED.phone,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- 4. VERIFICAR SE EXISTEM USUÁRIOS NA TABELA USERS QUE PRECISAM SER CRIADOS COMO AUTH_USERS
-- Este script identifica usuários que podem precisar de acesso ao sistema
WITH users_with_referrer AS (
  SELECT DISTINCT 
    referrer,
    COUNT(*) as total_referrals
  FROM users 
  WHERE referrer IS NOT NULL AND referrer != ''
  GROUP BY referrer
  HAVING COUNT(*) >= 5  -- Apenas referrers com 5+ indicações
)
INSERT INTO auth_users (username, password, name, role, full_name, instagram, phone, is_active)
SELECT 
  LOWER(REPLACE(REPLACE(referrer, ' ', ''), '-', '')) as username,
  'senha123' as password,
  referrer as name,
  CASE 
    WHEN total_referrals >= 20 THEN 'Membro'
    WHEN total_referrals >= 10 THEN 'Amigo'
    ELSE 'Convidado'
  END as role,
  referrer || ' - ' || CASE 
    WHEN total_referrals >= 20 THEN 'Membro'
    WHEN total_referrals >= 10 THEN 'Amigo'
    ELSE 'Convidado'
  END as full_name,
  LOWER(REPLACE(REPLACE(referrer, ' ', ''), '-', '')) as instagram,
  '62900000000' as phone,
  true as is_active
FROM users_with_referrer
WHERE referrer NOT IN (
  SELECT name FROM auth_users WHERE name = referrer
)
ON CONFLICT (username) DO NOTHING;

-- 5. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_auth_users_username ON auth_users(username);
CREATE INDEX IF NOT EXISTS idx_auth_users_role ON auth_users(role);
CREATE INDEX IF NOT EXISTS idx_auth_users_is_active ON auth_users(is_active);
CREATE INDEX IF NOT EXISTS idx_auth_users_instagram ON auth_users(instagram);

-- 6. VERIFICAR RESULTADOS
SELECT 
  'RESUMO DOS USUÁRIOS CRIADOS' as tipo,
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN role = 'admin' THEN 1 END) as administradores,
  COUNT(CASE WHEN role = 'Membro' THEN 1 END) as membros,
  COUNT(CASE WHEN role = 'Amigo' THEN 1 END) as amigos,
  COUNT(CASE WHEN role = 'Convidado' THEN 1 END) as convidados,
  COUNT(CASE WHEN is_active = true THEN 1 END) as usuarios_ativos
FROM auth_users;

-- 7. LISTAR TODOS OS USUÁRIOS CRIADOS
SELECT 
  username,
  name,
  role,
  full_name,
  instagram,
  phone,
  is_active,
  created_at
FROM auth_users
ORDER BY 
  CASE role 
    WHEN 'admin' THEN 1
    WHEN 'Membro' THEN 2
    WHEN 'Amigo' THEN 3
    WHEN 'Convidado' THEN 4
    ELSE 5
  END,
  name;

-- 8. VERIFICAR USUÁRIOS QUE PODEM PRECISAR DE ACESSO
SELECT 
  'USUÁRIOS COM MUITAS INDICAÇÕES' as tipo,
  referrer,
  COUNT(*) as total_indicacoes,
  'Pode precisar de acesso ao sistema' as observacao
FROM users 
WHERE referrer IS NOT NULL AND referrer != ''
GROUP BY referrer
HAVING COUNT(*) >= 5
ORDER BY COUNT(*) DESC;
