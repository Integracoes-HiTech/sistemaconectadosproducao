-- =====================================================
-- TESTAR SISTEMA DE ATUALIZAÇÃO DE CONTRATOS
-- Execute este script para testar se o sistema está funcionando
-- =====================================================

-- =====================================================
-- TESTE 1: VERIFICAR STATUS ATUAL
-- =====================================================

-- Verificar membros disponíveis para teste
SELECT 
    'MEMBROS DISPONÍVEIS PARA TESTE' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    is_friend
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND is_friend = false
ORDER BY contracts_completed DESC
LIMIT 5;

-- =====================================================
-- TESTE 2: SIMULAR CADASTRO DE AMIGO
-- =====================================================

-- Criar um membro de teste para ser referrer
INSERT INTO members (
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced, is_friend
) VALUES (
  gen_random_uuid(),
  'João Teste Referrer',
  '99999-0001',
  '@joao_teste_referrer',
  'Goiânia',
  'Setor Central',
  'Administrador',
  CURRENT_DATE,
  'Ativo',
  'Maria Teste Referrer',
  '88888-0001',
  '@maria_teste_referrer',
  'Goiânia',
  'Setor Central',
  5, -- 5 contratos iniciais
  NULL,
  'Amarelo',
  false,
  false,
  false
) ON CONFLICT (name) DO NOTHING;

-- Verificar contratos antes do teste
SELECT 
    'CONTRATOS ANTES DO TESTE' as categoria,
    name,
    contracts_completed,
    ranking_status
FROM members 
WHERE name = 'João Teste Referrer';

-- =====================================================
-- TESTE 3: CADASTRAR AMIGO (SIMULAR TRIGGER)
-- =====================================================

-- Cadastrar um amigo para o João Teste Referrer
INSERT INTO members (
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced, is_friend
) VALUES (
  gen_random_uuid(),
  'Pedro Teste Amigo',
  '99999-0002',
  '@pedro_teste_amigo',
  'Goiânia',
  'Setor Sul',
  'João Teste Referrer', -- Referrer é o João
  CURRENT_DATE,
  'Ativo',
  'Ana Teste Amigo',
  '88888-0002',
  '@ana_teste_amigo',
  'Goiânia',
  'Setor Sul',
  0, -- Amigo começa com 0 contratos
  NULL,
  'Vermelho',
  false,
  false,
  true -- É um amigo (contrato pago)
);

-- =====================================================
-- TESTE 4: VERIFICAR RESULTADO
-- =====================================================

-- Verificar se os contratos do referrer foram incrementados
SELECT 
    'CONTRATOS APÓS CADASTRO DE AMIGO' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position
FROM members 
WHERE name = 'João Teste Referrer';

-- Verificar se o amigo foi cadastrado
SELECT 
    'AMIGO CADASTRADO' as categoria,
    name,
    referrer,
    is_friend,
    contracts_completed,
    ranking_status
FROM members 
WHERE name = 'Pedro Teste Amigo';

-- =====================================================
-- TESTE 5: VERIFICAR RANKING ATUALIZADO
-- =====================================================

-- Verificar ranking geral
SELECT 
    'RANKING ATUALIZADO' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    is_top_1500
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND ranking_status IS NOT NULL
ORDER BY ranking_position ASC
LIMIT 10;

-- =====================================================
-- TESTE 6: LIMPEZA (OPCIONAL)
-- =====================================================

-- Descomente as linhas abaixo para limpar os dados de teste
-- DELETE FROM members WHERE name IN ('João Teste Referrer', 'Pedro Teste Amigo');

-- =====================================================
-- TESTE 7: VERIFICAR FUNCIONAMENTO DO TRIGGER
-- =====================================================

-- Verificar se o trigger está funcionando
SELECT 
    'STATUS DO TRIGGER' as categoria,
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_referrer_contracts';

-- =====================================================
-- RESUMO DO TESTE:
-- =====================================================
-- ✅ Membro de teste criado com 5 contratos
-- ✅ Amigo cadastrado para o membro
-- ✅ Contratos do referrer devem ter sido incrementados (5 → 6)
-- ✅ Ranking deve ter sido recalculado
-- ✅ Status do ranking deve ter sido atualizado
-- ✅ Trigger deve estar funcionando automaticamente
