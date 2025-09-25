-- =====================================================
-- ATUALIZAR RANKING POSITION DOS AMIGOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- O campo ranking_position não está sendo calculado corretamente
-- Precisamos atualizar baseado na ordenação por contracts_completed

-- =====================================================
-- 1. ATUALIZAR RANKING POSITION DOS AMIGOS
-- =====================================================

-- Atualizar ranking_position baseado na ordenação por contracts_completed
WITH ranked_friends AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      ORDER BY 
        contracts_completed DESC,  -- Mais usuários cadastrados primeiro
        created_at ASC            -- Em caso de empate, mais antigo primeiro
    ) as new_ranking_position
  FROM friends 
  WHERE status = 'Ativo' AND deleted_at IS NULL
)
UPDATE friends 
SET 
  ranking_position = ranked_friends.new_ranking_position,
  updated_at = NOW()
FROM ranked_friends
WHERE friends.id = ranked_friends.id;

-- =====================================================
-- 2. ATUALIZAR RANKING STATUS BASEADO EM CONTRACTS_COMPLETED
-- =====================================================

-- Atualizar ranking_status baseado em contracts_completed
UPDATE friends 
SET 
  ranking_status = CASE
    WHEN contracts_completed >= 15 THEN 'Verde'
    WHEN contracts_completed >= 1 THEN 'Amarelo'
    ELSE 'Vermelho'
  END,
  updated_at = NOW()
WHERE status = 'Ativo' AND deleted_at IS NULL;

-- =====================================================
-- 3. ATUALIZAR IS_TOP_1500 BASEADO NO RANKING
-- =====================================================

-- Marcar top performers (primeiros 10 por enquanto)
UPDATE friends 
SET 
  is_top_1500 = CASE
    WHEN ranking_position <= 10 THEN true
    ELSE false
  END,
  updated_at = NOW()
WHERE status = 'Ativo' AND deleted_at IS NULL;

-- =====================================================
-- 4. VERIFICAR RESULTADO
-- =====================================================

-- Verificar ranking atualizado
SELECT 
    'RANKING ATUALIZADO' as categoria,
    ranking_position,
    name,
    contracts_completed,
    ranking_status,
    is_top_1500,
    created_at
FROM friends 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY ranking_position ASC
LIMIT 20;

-- =====================================================
-- 5. VERIFICAR ESTATÍSTICAS
-- =====================================================

-- Verificar distribuição por status
SELECT 
    'DISTRIBUIÇÃO POR STATUS' as categoria,
    ranking_status,
    COUNT(*) as quantidade,
    MIN(ranking_position) as menor_posicao,
    MAX(ranking_position) as maior_posicao
FROM friends 
WHERE status = 'Ativo' AND deleted_at IS NULL
GROUP BY ranking_status
ORDER BY 
    CASE ranking_status 
        WHEN 'Verde' THEN 1 
        WHEN 'Amarelo' THEN 2 
        WHEN 'Vermelho' THEN 3 
    END;

-- =====================================================
-- 6. RECRIAR VIEW v_friends_ranking COM RANKING CORRETO
-- =====================================================

DROP VIEW IF EXISTS v_friends_ranking;

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
ORDER BY f.ranking_position ASC;

-- =====================================================
-- 7. TESTAR VIEW ATUALIZADA
-- =====================================================

-- Testar view de ranking de amigos
SELECT 'Ranking de Amigos' as categoria, COUNT(*) as total FROM v_friends_ranking;

-- Verificar primeiros 10 do ranking
SELECT 
    'TOP 10 AMIGOS' as categoria,
    ranking_position,
    name,
    contracts_completed,
    ranking_status
FROM v_friends_ranking
ORDER BY ranking_position ASC
LIMIT 10;
