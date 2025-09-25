-- =====================================================
-- INSERTS DE AMIGOS PARA VALIDAR CONTADORES
-- 12 amigos cadastrados pelo membro "Antonio Netto"
-- =====================================================

-- Primeiro, vamos verificar se o membro "Antonio Netto" existe
-- e pegar seu ID para usar nos inserts
-- SELECT id, name FROM members WHERE name ILIKE '%Antonio Netto%';

-- =====================================================
-- INSERTS DE AMIGOS (12 registros)
-- =====================================================

-- Amigo 1
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'João Silva Santos',
  '(62) 99999-0001',
  'joao_silva_santos',
  'Goiânia',
  'Setor Central',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Maria Silva Santos',
  '(62) 99999-0002',
  'maria_silva_santos',
  'Goiânia',
  'Setor Central',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 2
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Pedro Oliveira Costa',
  '(62) 99999-0003',
  'pedro_oliveira_costa',
  'Aparecida de Goiânia',
  'Setor Central',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Ana Oliveira Costa',
  '(62) 99999-0004',
  'ana_oliveira_costa',
  'Aparecida de Goiânia',
  'Setor Central',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 3
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Carlos Eduardo Lima',
  '(62) 99999-0005',
  'carlos_eduardo_lima',
  'Goiânia',
  'Setor Sul',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Fernanda Lima',
  '(62) 99999-0006',
  'fernanda_lima',
  'Goiânia',
  'Setor Sul',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 4
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Rafael Mendes Pereira',
  '(62) 99999-0007',
  'rafael_mendes_pereira',
  'Goiânia',
  'Setor Norte',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Juliana Mendes Pereira',
  '(62) 99999-0008',
  'juliana_mendes_pereira',
  'Goiânia',
  'Setor Norte',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 5
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Lucas Rodrigues Alves',
  '(62) 99999-0009',
  'lucas_rodrigues_alves',
  'Aparecida de Goiânia',
  'Setor Sul',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Camila Rodrigues Alves',
  '(62) 99999-0010',
  'camila_rodrigues_alves',
  'Aparecida de Goiânia',
  'Setor Sul',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 6
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Diego Souza Barbosa',
  '(62) 99999-0011',
  'diego_souza_barbosa',
  'Goiânia',
  'Setor Central',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Patricia Souza Barbosa',
  '(62) 99999-0012',
  'patricia_souza_barbosa',
  'Goiânia',
  'Setor Central',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 7
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Marcos Antonio Ferreira',
  '(62) 99999-0013',
  'marcos_antonio_ferreira',
  'Goiânia',
  'Setor Oeste',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Sandra Antonio Ferreira',
  '(62) 99999-0014',
  'sandra_antonio_ferreira',
  'Goiânia',
  'Setor Oeste',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 8
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'André Luiz Martins',
  '(62) 99999-0015',
  'andre_luiz_martins',
  'Aparecida de Goiânia',
  'Setor Norte',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Renata Luiz Martins',
  '(62) 99999-0016',
  'renata_luiz_martins',
  'Aparecida de Goiânia',
  'Setor Norte',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 9
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Bruno Henrique Gomes',
  '(62) 99999-0017',
  'bruno_henrique_gomes',
  'Goiânia',
  'Setor Sul',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Larissa Henrique Gomes',
  '(62) 99999-0018',
  'larissa_henrique_gomes',
  'Goiânia',
  'Setor Sul',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 10
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Thiago César Nunes',
  '(62) 99999-0019',
  'thiago_cesar_nunes',
  'Goiânia',
  'Setor Central',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Gabriela César Nunes',
  '(62) 99999-0020',
  'gabriela_cesar_nunes',
  'Goiânia',
  'Setor Central',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 11
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Felipe Augusto Rocha',
  '(62) 99999-0021',
  'felipe_augusto_rocha',
  'Aparecida de Goiânia',
  'Setor Oeste',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Beatriz Augusto Rocha',
  '(62) 99999-0022',
  'beatriz_augusto_rocha',
  'Aparecida de Goiânia',
  'Setor Oeste',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- Amigo 12
INSERT INTO friends (
  member_id,
  name,
  phone,
  instagram,
  city,
  sector,
  referrer,
  registration_date,
  status,
  couple_name,
  couple_phone,
  couple_instagram,
  couple_city,
  couple_sector,
  contracts_completed,
  ranking_position,
  ranking_status,
  is_top_1500,
  can_be_replaced,
  post_verified_1,
  post_verified_2,
  post_url_1,
  post_url_2,
  deleted_at,
  created_at,
  updated_at
) VALUES (
  (SELECT id FROM members WHERE name ILIKE '%Antonio Netto%' LIMIT 1),
  'Roberto Carlos Silva',
  '(62) 99999-0023',
  'roberto_carlos_silva',
  'Goiânia',
  'Setor Norte',
  'Antonio Netto',
  CURRENT_DATE,
  'Ativo',
  'Cristina Carlos Silva',
  '(62) 99999-0024',
  'cristina_carlos_silva',
  'Goiânia',
  'Setor Norte',
  0,
  NULL,
  'Vermelho',
  false,
  false,
  false,
  false,
  NULL,
  NULL,
  NULL,
  NOW(),
  NOW()
);

-- =====================================================
-- VERIFICAÇÕES APÓS OS INSERTS
-- =====================================================

-- Verificar se os inserts foram bem-sucedidos
SELECT 
  COUNT(*) as total_amigos_antonio_netto,
  'Antonio Netto' as membro_referrer
FROM friends 
WHERE referrer = 'Antonio Netto' 
  AND deleted_at IS NULL;

-- Verificar o ranking de amigos
SELECT 
  f.name,
  f.referrer,
  f.contracts_completed,
  f.ranking_position,
  f.ranking_status,
  f.created_at
FROM friends f
WHERE f.referrer = 'Antonio Netto'
  AND f.deleted_at IS NULL
ORDER BY f.created_at;

-- Verificar estatísticas do membro Antonio Netto
SELECT 
  m.name as membro,
  COUNT(f.id) as total_amigos_cadastrados,
  SUM(f.contracts_completed) as total_contratos_amigos
FROM members m
LEFT JOIN friends f ON m.id = f.member_id AND f.deleted_at IS NULL
WHERE m.name ILIKE '%Antonio Netto%'
GROUP BY m.id, m.name;

-- =====================================================
-- ATUALIZAR RANKING APÓS OS INSERTS
-- =====================================================

-- Atualizar ranking_position manualmente (caso a função não exista)
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

-- Atualizar is_top_1500 baseado no ranking
UPDATE friends 
SET 
  is_top_1500 = CASE
    WHEN ranking_position <= 10 THEN true
    ELSE false
  END,
  updated_at = NOW()
WHERE status = 'Ativo' AND deleted_at IS NULL;

-- Verificar o ranking atualizado
SELECT 
  f.name,
  f.referrer,
  f.contracts_completed,
  f.ranking_position,
  f.ranking_status,
  f.created_at
FROM friends f
WHERE f.referrer = 'Antonio Netto'
  AND f.deleted_at IS NULL
ORDER BY f.ranking_position;
