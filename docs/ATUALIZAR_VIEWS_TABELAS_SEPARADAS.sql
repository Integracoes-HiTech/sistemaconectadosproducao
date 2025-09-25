-- =====================================================
-- ATUALIZAR VIEWS PARA TABELAS SEPARADAS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. RECRIAR VIEW v_system_stats PARA MEMBROS
-- =====================================================

DROP VIEW IF EXISTS v_system_stats;

CREATE OR REPLACE VIEW v_system_stats AS
SELECT 
  -- Total de membros ativos
  (SELECT COUNT(*) FROM members_clean WHERE status = 'Ativo' AND deleted_at IS NULL) as total_members,
  
  -- Membros verdes (15+ contratos)
  (SELECT COUNT(*) FROM members_clean WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_members,
  
  -- Membros amarelos (1-14 contratos)
  (SELECT COUNT(*) FROM members_clean WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_members,
  
  -- Membros vermelhos (0 contratos)
  (SELECT COUNT(*) FROM members_clean WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_members,
  
  -- Top 1500 membros
  (SELECT COUNT(*) FROM members_clean WHERE is_top_1500 = true AND status = 'Ativo' AND deleted_at IS NULL) as top_1500_members,
  
  -- Contratos completos (soma de todos os contratos dos membros)
  (SELECT SUM(contracts_completed) FROM members_clean WHERE status = 'Ativo' AND deleted_at IS NULL) as completed_contracts,
  
  -- Contratos pendentes (0 por enquanto)
  0 as pending_contracts,
  
  -- Contador atual da fase
  (SELECT COALESCE(current_count, 0) FROM phase_control WHERE phase_name = 'members_registration') as current_member_count,
  
  -- Limite máximo da fase
  (SELECT COALESCE(max_limit, 1500) FROM phase_control WHERE phase_name = 'members_registration') as max_member_limit;

-- =====================================================
-- 2. CRIAR VIEW PARA ESTATÍSTICAS DE AMIGOS
-- =====================================================

CREATE OR REPLACE VIEW v_friends_stats AS
SELECT 
  -- Total de amigos ativos
  (SELECT COUNT(*) FROM friends_clean WHERE status = 'Ativo' AND deleted_at IS NULL) as total_friends,
  
  -- Amigos verdes (15+ usuários cadastrados)
  (SELECT COUNT(*) FROM friends_clean WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_friends,
  
  -- Amigos amarelos (1-14 usuários cadastrados)
  (SELECT COUNT(*) FROM friends_clean WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_friends,
  
  -- Amigos vermelhos (0 usuários cadastrados)
  (SELECT COUNT(*) FROM friends_clean WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_friends,
  
  -- Total de usuários cadastrados por amigos
  (SELECT SUM(contracts_completed) FROM friends_clean WHERE status = 'Ativo' AND deleted_at IS NULL) as total_users_cadastrados,
  
  -- Posts verificados
  (SELECT COUNT(*) FROM friends_clean WHERE (post_verified_1 = true OR post_verified_2 = true) AND status = 'Ativo' AND deleted_at IS NULL) as verified_posts;

-- =====================================================
-- 3. CRIAR VIEW PARA RANKING DE AMIGOS
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
FROM friends_clean f
LEFT JOIN members_clean m ON f.member_id = m.id
WHERE f.status = 'Ativo' AND f.deleted_at IS NULL
ORDER BY f.contracts_completed DESC, f.created_at ASC;

-- =====================================================
-- 4. CRIAR VIEW PARA RANKING DE MEMBROS
-- =====================================================

CREATE OR REPLACE VIEW v_members_ranking AS
SELECT 
  m.id,
  m.name,
  m.phone,
  m.instagram,
  m.city,
  m.sector,
  m.referrer,
  m.registration_date,
  m.status,
  m.couple_name,
  m.couple_phone,
  m.couple_instagram,
  m.couple_city,
  m.couple_sector,
  m.contracts_completed,
  m.ranking_position,
  m.ranking_status,
  m.is_top_1500,
  m.can_be_replaced,
  m.created_at,
  m.updated_at,
  -- Contar quantos amigos este membro cadastrou
  (SELECT COUNT(*) FROM friends_clean f WHERE f.member_id = m.id AND f.contract_status = 'Ativo' AND f.deleted_at IS NULL) as friends_cadastrados
FROM members_clean m
WHERE m.status = 'Ativo' AND m.deleted_at IS NULL
ORDER BY m.contracts_completed DESC, m.created_at ASC;

-- =====================================================
-- 5. ATUALIZAR CONTADOR DA FASE
-- =====================================================

UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members_clean 
    WHERE status = 'Ativo' AND deleted_at IS NULL
)
WHERE phase_name = 'members_registration';

-- =====================================================
-- 6. VERIFICAR VIEWS CRIADAS
-- =====================================================

-- Testar view de estatísticas de membros
SELECT 'Estatísticas de Membros' as categoria, * FROM v_system_stats;

-- Testar view de estatísticas de amigos
SELECT 'Estatísticas de Amigos' as categoria, * FROM v_friends_stats;

-- Testar view de ranking de amigos
SELECT 'Ranking de Amigos' as categoria, COUNT(*) as total FROM v_friends_ranking;

-- Testar view de ranking de membros
SELECT 'Ranking de Membros' as categoria, COUNT(*) as total FROM v_members_ranking;
