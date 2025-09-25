-- =====================================================
-- MIGRAR AMIGOS DA TABELA MEMBERS PARA FRIENDS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR DADOS EXISTENTES
-- =====================================================

-- Verificar quantos amigos existem na tabela members
SELECT 
    'AMIGOS EXISTENTES' as categoria,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as verdes,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as amarelos,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as vermelhos
FROM members 
WHERE is_friend = true;

-- =====================================================
-- 2. MIGRAR AMIGOS PARA TABELA FRIENDS
-- =====================================================

-- Migrar amigos (is_friend = true) para tabela friends
INSERT INTO friends (
  id, member_id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced,
  post_verified_1, post_verified_2, post_url_1, post_url_2,
  deleted_at, created_at, updated_at
)
SELECT 
  m.id,
  -- Buscar o ID do membro que cadastrou este amigo
  (SELECT id FROM members WHERE name = m.referrer AND (is_friend = false OR is_friend IS NULL) LIMIT 1) as member_id,
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
-- 3. VERIFICAR MIGRAÇÃO
-- =====================================================

-- Verificar quantos amigos foram migrados
SELECT 
    'AMIGOS MIGRADOS' as categoria,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as verdes,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as amarelos,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as vermelhos
FROM friends;

-- =====================================================
-- 4. VERIFICAR ASSOCIAÇÕES COM MEMBROS
-- =====================================================

-- Verificar se todos os amigos têm membro associado
SELECT 
    'ASSOCIAÇÕES COM MEMBROS' as categoria,
    COUNT(*) as total_amigos,
    COUNT(member_id) as com_membro_associado,
    COUNT(*) - COUNT(member_id) as sem_membro_associado
FROM friends;

-- Listar amigos sem membro associado (se houver)
SELECT 
    'AMIGOS SEM MEMBRO ASSOCIADO' as categoria,
    id,
    name,
    referrer,
    'Membro não encontrado' as problema
FROM friends 
WHERE member_id IS NULL;

-- =====================================================
-- 5. ATUALIZAR RANKING DE AMIGOS
-- =====================================================

-- Atualizar ranking_status baseado em contracts_completed
UPDATE friends 
SET ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
END
WHERE status = 'Ativo' AND deleted_at IS NULL;

-- =====================================================
-- 6. TESTAR VIEWS
-- =====================================================

-- Testar view de ranking de amigos
SELECT 'Ranking de Amigos' as categoria, COUNT(*) as total FROM v_friends_ranking;

-- Testar view de estatísticas de amigos
SELECT 'Estatísticas de Amigos' as categoria, * FROM v_friends_stats;

-- =====================================================
-- 7. LIMPAR TABELA MEMBERS (OPCIONAL)
-- =====================================================

-- ⚠️ CUIDADO: Execute apenas se a migração foi bem-sucedida!
-- Remover amigos da tabela members (soft delete)
-- UPDATE members 
-- SET deleted_at = NOW()
-- WHERE is_friend = true;

-- =====================================================
-- 8. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar estrutura final
SELECT 
    'ESTRUTURA FINAL' as categoria,
    'Membros' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos
FROM members 
WHERE is_friend = false OR is_friend IS NULL

UNION ALL

SELECT 
    'ESTRUTURA FINAL' as categoria,
    'Amigos' as tipo,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos
FROM friends;
