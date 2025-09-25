-- Script SQL para atualizar o banco de dados conforme as mudanças implementadas
-- Execute este script no SQL Editor do Supabase

-- 1. REMOVER COLUNAS DESNECESSÁRIAS DA TABELA USERS
-- Remover colunas: address, state, neighborhood, email
ALTER TABLE users DROP COLUMN IF EXISTS address;
ALTER TABLE users DROP COLUMN IF EXISTS state;
ALTER TABLE users DROP COLUMN IF EXISTS neighborhood;
ALTER TABLE users DROP COLUMN IF EXISTS email;

-- 2. ADICIONAR NOVA COLUNA SECTOR NA TABELA USERS
ALTER TABLE users ADD COLUMN IF NOT EXISTS sector VARCHAR(255) NOT NULL DEFAULT 'Centro';

-- 3. ATUALIZAR TABELA AUTH_USERS PARA INCLUIR INSTAGRAM E PHONE
-- Adicionar colunas instagram e phone na tabela auth_users
ALTER TABLE auth_users ADD COLUMN IF NOT EXISTS instagram VARCHAR(255);
ALTER TABLE auth_users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE auth_users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT false;
ALTER TABLE auth_users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;

-- 4. REMOVER COLUNA EMAIL DA TABELA AUTH_USERS (se existir)
ALTER TABLE auth_users DROP COLUMN IF EXISTS email;

-- 5. ATUALIZAR ÍNDICES
-- Remover índices desnecessários
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_address;

-- Adicionar novos índices
CREATE INDEX IF NOT EXISTS idx_users_instagram ON users(instagram);
CREATE INDEX IF NOT EXISTS idx_users_sector ON users(sector);
CREATE INDEX IF NOT EXISTS idx_auth_users_instagram ON auth_users(instagram);
CREATE INDEX IF NOT EXISTS idx_auth_users_is_active ON auth_users(is_active);

-- 6. ATUALIZAR DADOS EXISTENTES (se necessário)
-- Definir setor padrão para usuários existentes que não têm setor
UPDATE users SET sector = 'Centro' WHERE sector IS NULL OR sector = '';

-- 7. ADICIONAR CONSTRAINTS DE UNICIDADE
-- Garantir que Instagram seja único na tabela users
ALTER TABLE users ADD CONSTRAINT unique_instagram UNIQUE (instagram);

-- 8. ATUALIZAR POLÍTICAS DE SEGURANÇA (se necessário)
-- As políticas existentes devem continuar funcionando

-- 9. VERIFICAR ESTRUTURA FINAL DAS TABELAS
-- Para verificar se as mudanças foram aplicadas corretamente, execute:
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'users' 
-- ORDER BY ordinal_position;

-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'auth_users' 
-- ORDER BY ordinal_position;

-- 10. COMENTÁRIOS SOBRE AS MUDANÇAS
/*
MUDANÇAS IMPLEMENTADAS:

TABELA USERS:
- REMOVIDO: address, state, neighborhood, email
- ADICIONADO: sector
- MANTIDO: id, name, phone, instagram, city, referrer, registration_date, status, created_at, updated_at

TABELA AUTH_USERS:
- REMOVIDO: email (se existia)
- ADICIONADO: instagram, phone, is_active, last_login
- MANTIDO: id, username, password, name, role, full_name, created_at, updated_at

NOVOS ÍNDICES:
- idx_users_instagram: Para busca rápida por Instagram
- idx_users_sector: Para filtros por setor
- idx_auth_users_instagram: Para autenticação por Instagram
- idx_auth_users_is_active: Para filtros de usuários ativos

CONSTRAINTS:
- unique_instagram: Garante que cada Instagram seja único no sistema
*/
