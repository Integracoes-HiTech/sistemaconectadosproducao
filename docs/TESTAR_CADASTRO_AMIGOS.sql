-- =====================================================
-- TESTAR CADASTRO DE AMIGOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. VERIFICAR ESTRUTURAS EXISTENTES
-- =====================================================

-- Verificar se as tabelas existem
SELECT 
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('friends', 'friend_referrals', 'members', 'user_links')
ORDER BY table_name;

-- Verificar se a view existe
SELECT 
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'v_friends_ranking';

-- =====================================================
-- 2. VERIFICAR DADOS EXISTENTES
-- =====================================================

-- Verificar membros existentes
SELECT 
  id,
  name,
  couple_name,
  city,
  sector,
  status
FROM members 
WHERE status = 'Ativo'
LIMIT 5;

-- Verificar links existentes
SELECT 
  id,
  user_id,
  link_type,
  clicks_count,
  registrations_count
FROM user_links 
WHERE link_type = 'friends'
LIMIT 5;

-- =====================================================
-- 3. CRIAR LINK DE TESTE PARA CADASTRO DE AMIGOS
-- =====================================================

-- Buscar um membro para criar link de teste
WITH member_sample AS (
  SELECT id, name FROM members WHERE status = 'Ativo' LIMIT 1
)
INSERT INTO user_links (
  user_id,
  link_type,
  clicks_count,
  registrations_count,
  created_at
)
SELECT 
  id,
  'friends',
  0,
  0,
  NOW()
FROM member_sample;

-- =====================================================
-- 4. VERIFICAR LINK CRIADO
-- =====================================================

-- Verificar o link criado
SELECT 
  ul.id as link_id,
  ul.link_type,
  ul.clicks_count,
  ul.registrations_count,
  m.name as member_name
FROM user_links ul
JOIN members m ON ul.user_id = m.id
WHERE ul.link_type = 'friends'
ORDER BY ul.created_at DESC
LIMIT 1;

-- =====================================================
-- 5. SIMULAR CADASTRO DE AMIGO VIA FORMULÁRIO
-- =====================================================

-- Simular inserção de amigo (como seria feito pelo formulário)
WITH link_sample AS (
  SELECT id, user_id FROM user_links WHERE link_type = 'friends' ORDER BY created_at DESC LIMIT 1
),
member_sample AS (
  SELECT id FROM members WHERE status = 'Ativo' LIMIT 1
)
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
)
SELECT 
  ms.id,
  'João Teste',
  'Maria Teste',
  '(62) 99999-9999',
  '(62) 88888-8888',
  '@joaoteste',
  '@mariateste',
  'Goiânia',
  'Centro',
  'Ativo',
  0,
  'Vermelho',
  false,
  CURRENT_DATE
FROM member_sample ms;

-- =====================================================
-- 6. VERIFICAR AMIGO CRIADO
-- =====================================================

-- Verificar o amigo criado
SELECT 
  f.id,
  f.couple_name_1,
  f.couple_name_2,
  f.couple_phone_1,
  f.couple_phone_2,
  f.couple_instagram_1,
  f.couple_instagram_2,
  f.couple_city,
  f.couple_sector,
  f.friend_status,
  f.users_cadastrados,
  f.ranking_status,
  f.is_top_performer,
  f.registration_date,
  m.name as member_name
FROM friends f
JOIN members m ON f.member_id = m.id
ORDER BY f.created_at DESC
LIMIT 1;

-- =====================================================
-- 7. SIMULAR REFERÊNCIA DE USUÁRIO PELO AMIGO
-- =====================================================

-- Simular inserção de referência (usuário cadastrado pelo amigo)
WITH friend_sample AS (
  SELECT id FROM friends ORDER BY created_at DESC LIMIT 1
)
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
)
SELECT 
  id,
  'Ana Referência',
  '(62) 77777-7777',
  '@anareferencia',
  'Goiânia',
  'Setor Bueno',
  'Ativo',
  'https://instagram.com/p/teste123',
  '#VereadorConnectTeste',
  true
FROM friend_sample;

-- =====================================================
-- 8. VERIFICAR REFERÊNCIA CRIADA
-- =====================================================

-- Verificar a referência criada
SELECT 
  fr.id,
  fr.referred_user_name,
  fr.referred_user_phone,
  fr.referred_user_instagram,
  fr.referred_user_city,
  fr.referred_user_sector,
  fr.referral_status,
  fr.instagram_post,
  fr.hashtag,
  fr.post_verified,
  f.couple_name_1 as friend_name
FROM friend_referrals fr
JOIN friends f ON fr.friend_id = f.id
ORDER BY fr.created_at DESC
LIMIT 1;

-- =====================================================
-- 9. VERIFICAR RANKING ATUALIZADO
-- =====================================================

-- Verificar se o ranking foi atualizado automaticamente
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
-- 10. VERIFICAR ESTATÍSTICAS
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
-- 11. TESTAR FUNCIONALIDADE COMPLETA
-- =====================================================

-- Verificar se o sistema está funcionando corretamente
SELECT 
  'Sistema de Cadastro de Amigos' as teste,
  CASE 
    WHEN (SELECT COUNT(*) FROM friends) > 0 THEN '✅ Tabela friends funcionando'
    ELSE '❌ Tabela friends vazia'
  END as status_friends,
  CASE 
    WHEN (SELECT COUNT(*) FROM friend_referrals) > 0 THEN '✅ Tabela friend_referrals funcionando'
    ELSE '❌ Tabela friend_referrals vazia'
  END as status_referrals,
  CASE 
    WHEN (SELECT COUNT(*) FROM v_friends_ranking) > 0 THEN '✅ View v_friends_ranking funcionando'
    ELSE '❌ View v_friends_ranking vazia'
  END as status_ranking;

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================

SELECT 'Teste do sistema de cadastro de amigos concluído!' as status;
