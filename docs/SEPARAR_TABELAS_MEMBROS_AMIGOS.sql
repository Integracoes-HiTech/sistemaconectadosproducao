-- =====================================================
-- SEPARAR TABELAS DE MEMBROS E AMIGOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- A tabela 'members' está misturando dados de membros e amigos,
-- causando confusão nos contadores e na lógica do sistema.
-- Precisamos separar em duas tabelas distintas.

-- =====================================================
-- 1. CRIAR TABELA DE MEMBROS (LIMPA)
-- =====================================================

-- Criar tabela de membros sem dados de amigos
CREATE TABLE IF NOT EXISTS members_clean (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL,
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) DEFAULT 'Ativo',
  
  -- Dados da segunda pessoa (obrigatório - regra do casal)
  couple_name VARCHAR(255) NOT NULL,
  couple_phone VARCHAR(20) NOT NULL,
  couple_instagram VARCHAR(255) NOT NULL,
  couple_city VARCHAR(255) NOT NULL,
  couple_sector VARCHAR(255) NOT NULL,
  
  -- Campos específicos do sistema de membros
  contracts_completed INTEGER DEFAULT 0,
  ranking_position INTEGER,
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_1500 BOOLEAN DEFAULT false,
  can_be_replaced BOOLEAN DEFAULT false,
  
  -- Campo para soft delete
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. CRIAR TABELA DE AMIGOS (MESMA ESTRUTURA DE MEMBROS)
-- =====================================================

-- Criar tabela de amigos com mesma estrutura de membros
CREATE TABLE IF NOT EXISTS friends_clean (
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
  
  -- Campos específicos do sistema de amigos (mesma lógica de membros)
  contracts_completed INTEGER DEFAULT 0, -- Quantos usuários este amigo cadastrou
  ranking_position INTEGER, -- Posição no ranking de amigos
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_1500 BOOLEAN DEFAULT false, -- Se está entre os top performers
  can_be_replaced BOOLEAN DEFAULT false,
  
  -- Campos de verificação de posts
  post_verified_1 BOOLEAN DEFAULT false,
  post_verified_2 BOOLEAN DEFAULT false,
  post_url_1 TEXT,
  post_url_2 TEXT,
  
  -- Campo para soft delete
  deleted_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Foreign key para o membro que cadastrou
  CONSTRAINT fk_friend_member FOREIGN KEY (member_id) REFERENCES members_clean(id) ON DELETE CASCADE
);

-- =====================================================
-- 3. MIGRAR DADOS EXISTENTES
-- =====================================================

-- Migrar membros (is_friend = false ou NULL)
INSERT INTO members_clean (
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
  deleted_at, created_at, updated_at
)
SELECT 
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
  deleted_at, created_at, updated_at
FROM members 
WHERE is_friend = false OR is_friend IS NULL;

-- Migrar amigos (is_friend = true) - mesma estrutura de membros
INSERT INTO friends_clean (
  id, member_id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
  post_verified_1, post_verified_2, post_url_1, post_url_2,
  deleted_at, created_at, updated_at
)
SELECT 
  m.id,
  -- Buscar o ID do membro que cadastrou este amigo
  (SELECT id FROM members_clean WHERE name = m.referrer LIMIT 1) as member_id,
  m.name,
  m.phone,
  m.instagram,
  m.city,
  m.sector,
  m.referrer, -- Nome do membro que cadastrou
  m.registration_date,
  m.status,
  m.couple_name,
  m.couple_phone,
  m.couple_instagram,
  m.couple_city,
  m.couple_sector,
  0 as contracts_completed, -- Inicialmente 0 (quantos usuários este amigo cadastrou)
  NULL as ranking_position, -- Será calculado depois
  'Vermelho' as ranking_status, -- Inicialmente vermelho
  false as is_top_1500,
  false as can_be_replaced,
  false as post_verified_1,
  false as post_verified_2,
  NULL as post_url_1,
  NULL as post_url_2,
  m.deleted_at,
  m.created_at,
  m.updated_at
FROM members m
WHERE m.is_friend = true;

-- =====================================================
-- 4. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tabela de membros
CREATE INDEX IF NOT EXISTS idx_members_clean_status ON members_clean(status);
CREATE INDEX IF NOT EXISTS idx_members_clean_ranking_status ON members_clean(ranking_status);
CREATE INDEX IF NOT EXISTS idx_members_clean_deleted_at ON members_clean(deleted_at);
CREATE INDEX IF NOT EXISTS idx_members_clean_referrer ON members_clean(referrer);

-- Índices para tabela de amigos
CREATE INDEX IF NOT EXISTS idx_friends_clean_member_id ON friends_clean(member_id);
CREATE INDEX IF NOT EXISTS idx_friends_clean_contract_status ON friends_clean(contract_status);
CREATE INDEX IF NOT EXISTS idx_friends_clean_ranking_status ON friends_clean(ranking_status);
CREATE INDEX IF NOT EXISTS idx_friends_clean_deleted_at ON friends_clean(deleted_at);

-- =====================================================
-- 5. VERIFICAR MIGRAÇÃO
-- =====================================================

-- Verificar quantos membros foram migrados
SELECT 
    'MEMBROS MIGRADOS' as categoria,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as verdes,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as amarelos,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as vermelhos
FROM members_clean;

-- Verificar quantos amigos foram migrados
SELECT 
    'AMIGOS MIGRADOS' as categoria,
    COUNT(*) as total,
    COUNT(CASE WHEN contract_status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as verdes,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as amarelos,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as vermelhos
FROM friends_clean;

-- =====================================================
-- 6. PRÓXIMOS PASSOS
-- =====================================================

-- Após executar este script, você precisará:
-- 1. Atualizar os hooks (useMembers, useFriendsRanking)
-- 2. Atualizar o dashboard para usar as novas tabelas
-- 3. Criar novas views para estatísticas
-- 4. Testar o sistema
-- 5. Fazer backup da tabela 'members' original
-- 6. Renomear as tabelas (members_clean -> members, friends_clean -> friends)
