-- =====================================================
-- CRIAR DADOS DE EXEMPLO PARA FRIENDS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR SE EXISTEM MEMBROS PARA USAR COMO REFERÊNCIA
-- =====================================================

-- Verificar membros existentes
SELECT 
  id,
  name,
  couple_name,
  city,
  sector
FROM members 
WHERE status = 'Ativo'
LIMIT 5;

-- =====================================================
-- 2. INSERIR AMIGOS DE EXEMPLO
-- =====================================================

-- Inserir alguns amigos de exemplo
-- Substitua os UUIDs pelos IDs reais dos membros da consulta acima

INSERT INTO friends (
  member_id,
  couple_name_1,
  couple_name_2,
  couple_phone_1,
  couple_phone_2,
  couple_instagram_1,
  couple_instagram_2,
  couple_city,
  couple_sector,
  friend_status,
  users_cadastrados,
  ranking_status,
  is_top_performer,
  registration_date
) VALUES
-- Amigo 1 - Top Performer (Verde)
(
  (SELECT id FROM members WHERE status = 'Ativo' LIMIT 1), -- Substitua pelo ID real
  'João Silva',
  'Maria Silva',
  '(62) 99999-9999',
  '(62) 88888-8888',
  '@joaosilva',
  '@mariasilva',
  'Goiânia',
  'Centro',
  'Ativo',
  18, -- 18 usuários cadastrados (Verde)
  'Verde',
  true, -- Top performer
  '2024-01-15'
),

-- Amigo 2 - Médio (Amarelo)
(
  (SELECT id FROM members WHERE status = 'Ativo' LIMIT 1 OFFSET 1), -- Segundo membro
  'Pedro Costa',
  'Ana Costa',
  '(62) 77777-7777',
  '(62) 66666-6666',
  '@pedrocosta',
  '@anacosta',
  'Aparecida de Goiânia',
  'Setor Central',
  'Ativo',
  8, -- 8 usuários cadastrados (Amarelo)
  'Amarelo',
  false,
  '2024-01-20'
),

-- Amigo 3 - Baixo (Vermelho)
(
  (SELECT id FROM members WHERE status = 'Ativo' LIMIT 1 OFFSET 2), -- Terceiro membro
  'Lucas Rocha',
  'Julia Rocha',
  '(62) 55555-5555',
  '(62) 44444-4444',
  '@lucasrocha',
  '@juliarocha',
  'Trindade',
  'Centro',
  'Ativo',
  2, -- 2 usuários cadastrados (Vermelho)
  'Vermelho',
  false,
  '2024-01-25'
),

-- Amigo 4 - Médio (Amarelo)
(
  (SELECT id FROM members WHERE status = 'Ativo' LIMIT 1 OFFSET 3), -- Quarto membro
  'Carlos Santos',
  'Paula Santos',
  '(62) 33333-3333',
  '(62) 22222-2222',
  '@carlossantos',
  '@paulasantos',
  'Goiânia',
  'Setor Bueno',
  'Ativo',
  7, -- 7 usuários cadastrados (Amarelo)
  'Amarelo',
  false,
  '2024-02-01'
),

-- Amigo 5 - Top Performer (Verde)
(
  (SELECT id FROM members WHERE status = 'Ativo' LIMIT 1 OFFSET 4), -- Quinto membro
  'Marcos Lima',
  'Fernanda Lima',
  '(62) 11111-1111',
  '(62) 00000-0000',
  '@marcoslima',
  '@fernandalima',
  'Goiânia',
  'Setor Marista',
  'Ativo',
  16, -- 16 usuários cadastrados (Verde)
  'Verde',
  true, -- Top performer
  '2024-02-05'
);

-- =====================================================
-- 3. INSERIR REFERÊNCIAS DE EXEMPLO (USUÁRIOS CADASTRADOS PELOS AMIGOS)
-- =====================================================

-- Inserir referências para o João Silva (Top Performer)
INSERT INTO friend_referrals (
  friend_id,
  referred_user_name,
  referred_user_phone,
  referred_user_instagram,
  referred_user_city,
  referred_user_sector,
  referral_status,
  instagram_post,
  hashtag,
  post_verified
) VALUES
-- Referências do João Silva (18 usuários)
(
  (SELECT id FROM friends WHERE couple_name_1 = 'João Silva'),
  'Ana Beatriz',
  '(62) 99999-0001',
  '@anabeatriz',
  'Goiânia',
  'Centro',
  'Ativo',
  'https://instagram.com/p/abc123',
  '#VereadorConnect001',
  true
),
(
  (SELECT id FROM friends WHERE couple_name_1 = 'João Silva'),
  'Bruno Oliveira',
  '(62) 99999-0002',
  '@brunooliveira',
  'Goiânia',
  'Setor Bueno',
  'Ativo',
  'https://instagram.com/p/def456',
  '#VereadorConnect002',
  true
),
(
  (SELECT id FROM friends WHERE couple_name_1 = 'João Silva'),
  'Carla Mendes',
  '(62) 99999-0003',
  '@carlamendes',
  'Aparecida de Goiânia',
  'Setor Central',
  'Ativo',
  'https://instagram.com/p/ghi789',
  '#VereadorConnect003',
  true
);

-- Inserir referências para o Pedro Costa (Médio)
INSERT INTO friend_referrals (
  friend_id,
  referred_user_name,
  referred_user_phone,
  referred_user_instagram,
  referred_user_city,
  referred_user_sector,
  referral_status,
  instagram_post,
  hashtag,
  post_verified
) VALUES
-- Referências do Pedro Costa (8 usuários)
(
  (SELECT id FROM friends WHERE couple_name_1 = 'Pedro Costa'),
  'Diego Alves',
  '(62) 88888-0001',
  '@diegoalves',
  'Goiânia',
  'Centro',
  'Ativo',
  'https://instagram.com/p/jkl012',
  '#VereadorConnect004',
  true
),
(
  (SELECT id FROM friends WHERE couple_name_1 = 'Pedro Costa'),
  'Elena Souza',
  '(62) 88888-0002',
  '@elenasouza',
  'Trindade',
  'Centro',
  'Ativo',
  'https://instagram.com/p/mno345',
  '#VereadorConnect005',
  false
);

-- Inserir referências para o Lucas Rocha (Baixo)
INSERT INTO friend_referrals (
  friend_id,
  referred_user_name,
  referred_user_phone,
  referred_user_instagram,
  referred_user_city,
  referred_user_sector,
  referral_status,
  instagram_post,
  hashtag,
  post_verified
) VALUES
-- Referências do Lucas Rocha (2 usuários)
(
  (SELECT id FROM friends WHERE couple_name_1 = 'Lucas Rocha'),
  'Felipe Torres',
  '(62) 77777-0001',
  '@felipetorres',
  'Goiânia',
  'Setor Marista',
  'Ativo',
  'https://instagram.com/p/pqr678',
  '#VereadorConnect006',
  true
);

-- =====================================================
-- 4. ATUALIZAR CONTADORES E RANKING
-- =====================================================

-- Atualizar contadores de users_cadastrados para todos os amigos
UPDATE friends 
SET users_cadastrados = (
  SELECT COUNT(*)
  FROM friend_referrals
  WHERE friend_id = friends.id
  AND referral_status = 'Ativo'
);

-- Atualizar ranking_position e ranking_status
WITH ranked_friends AS (
  SELECT
    id,
    users_cadastrados,
    RANK() OVER (ORDER BY users_cadastrados DESC, registration_date ASC) as new_rank,
    CASE
      WHEN users_cadastrados >= 15 THEN 'Verde'
      WHEN users_cadastrados >= 5 THEN 'Amarelo'
      ELSE 'Vermelho'
    END as new_status,
    (users_cadastrados >= 15) as new_top_performer
  FROM friends
  WHERE friend_status = 'Ativo'
)
UPDATE friends f
SET
  ranking_position = rf.new_rank,
  ranking_status = rf.new_status,
  is_top_performer = rf.new_top_performer,
  updated_at = NOW()
FROM ranked_friends rf
WHERE f.id = rf.id;

-- =====================================================
-- 5. VERIFICAR OS DADOS CRIADOS
-- =====================================================

-- Verificar amigos criados
SELECT 
  f.id,
  f.couple_name_1,
  f.couple_name_2,
  f.couple_city,
  f.couple_sector,
  f.users_cadastrados,
  f.ranking_position,
  f.ranking_status,
  f.is_top_performer,
  m.name as member_name
FROM friends f
JOIN members m ON f.member_id = m.id
ORDER BY f.ranking_position;

-- Verificar referências criadas
SELECT 
  fr.id,
  fr.referred_user_name,
  fr.referred_user_phone,
  fr.referred_user_instagram,
  fr.referred_user_city,
  fr.referred_user_sector,
  fr.referral_status,
  fr.post_verified,
  f.couple_name_1 as friend_name
FROM friend_referrals fr
JOIN friends f ON fr.friend_id = f.id
ORDER BY fr.created_at;

-- Verificar view de ranking
SELECT 
  friend_id,
  couple_name_1,
  couple_name_2,
  users_cadastrados,
  global_rank,
  ranking_status,
  is_top_performer,
  member_name
FROM v_friends_ranking
ORDER BY global_rank;

-- =====================================================
-- 6. ESTATÍSTICAS FINAIS
-- =====================================================

-- Estatísticas dos amigos
SELECT 
  COUNT(*) as total_friends,
  COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as amigos_verde,
  COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as amigos_amarelo,
  COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as amigos_vermelho,
  COUNT(CASE WHEN is_top_performer = true THEN 1 END) as top_performers,
  SUM(users_cadastrados) as total_usuarios_cadastrados
FROM friends
WHERE friend_status = 'Ativo';

-- Estatísticas das referências
SELECT 
  COUNT(*) as total_referencias,
  COUNT(CASE WHEN referral_status = 'Ativo' THEN 1 END) as referencias_ativas,
  COUNT(CASE WHEN post_verified = true THEN 1 END) as posts_verificados
FROM friend_referrals;

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

-- Mensagem de sucesso
SELECT 'Dados de exemplo criados com sucesso!' as status;
