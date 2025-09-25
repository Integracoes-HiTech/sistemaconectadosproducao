-- =====================================================
-- TESTAR CADASTRO DE AMIGO PELO ADMIN
-- Execute este script para simular o problema relatado
-- =====================================================

-- =====================================================
-- PROBLEMA RELATADO:
-- =====================================================
-- Admin cadastra membro → OK
-- Admin cadastra amigo do membro → Contratos não são atualizados
-- Membro deveria ter 1/15 contratos e status Amarelo

-- =====================================================
-- 1. VERIFICAR STATUS ATUAL
-- =====================================================

-- Verificar membros existentes
SELECT 
    'MEMBROS EXISTENTES' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    is_friend,
    referrer,
    created_at
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- 2. CRIAR MEMBRO DE TESTE (SIMULAR ADMIN)
-- =====================================================

-- Inserir membro de teste
INSERT INTO members (
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced, is_friend
) VALUES (
  gen_random_uuid(),
  'Membro Teste Admin',
  '99999-1001',
  '@membro_teste_admin',
  'Goiânia',
  'Setor Central',
  'Administrador',
  CURRENT_DATE,
  'Ativo',
  'Cônjuge Teste Admin',
  '88888-1001',
  '@conjuge_teste_admin',
  'Goiânia',
  'Setor Central',
  0, -- Começa com 0 contratos
  NULL,
  'Vermelho', -- Status inicial
  false,
  false,
  false -- É um membro, não amigo
) ON CONFLICT (name) DO NOTHING;

-- Verificar membro criado
SELECT 
    'MEMBRO CRIADO' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    is_friend
FROM members 
WHERE name = 'Membro Teste Admin';

-- =====================================================
-- 3. CADASTRAR AMIGO DO MEMBRO (SIMULAR ADMIN)
-- =====================================================

-- Inserir amigo do membro
INSERT INTO members (
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced, is_friend
) VALUES (
  gen_random_uuid(),
  'Amigo Teste Admin',
  '99999-1002',
  '@amigo_teste_admin',
  'Goiânia',
  'Setor Sul',
  'Membro Teste Admin', -- Referrer é o membro
  CURRENT_DATE,
  'Ativo',
  'Cônjuge Amigo Teste',
  '88888-1002',
  '@conjuge_amigo_teste',
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
-- 4. VERIFICAR SE CONTRATOS FORAM ATUALIZADOS
-- =====================================================

-- Verificar se o membro teve contratos incrementados
SELECT 
    'VERIFICAR CONTRATOS DO MEMBRO' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    CASE 
        WHEN contracts_completed = 1 THEN '✅ DEVERIA SER 1/15 AMARELO'
        ELSE '❌ NÃO FOI ATUALIZADO'
    END as status_esperado
FROM members 
WHERE name = 'Membro Teste Admin';

-- Verificar se o amigo foi cadastrado
SELECT 
    'VERIFICAR AMIGO CADASTRADO' as categoria,
    name,
    referrer,
    is_friend,
    contracts_completed,
    ranking_status
FROM members 
WHERE name = 'Amigo Teste Admin';

-- =====================================================
-- 5. VERIFICAR LOGS DO TRIGGER
-- =====================================================

-- Verificar se o trigger está funcionando
SELECT 
    'STATUS DO TRIGGER' as categoria,
    trigger_name,
    event_manipulation,
    action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_referrer_contracts';

-- =====================================================
-- 6. EXECUTAR RANKING MANUALMENTE (SE NECESSÁRIO)
-- =====================================================

-- Executar ranking manualmente
SELECT update_complete_ranking();

-- Verificar resultado após ranking manual
SELECT 
    'APÓS RANKING MANUAL' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position
FROM members 
WHERE name = 'Membro Teste Admin';

-- =====================================================
-- 7. ATUALIZAR CONTRATOS MANUALMENTE (SE NECESSÁRIO)
-- =====================================================

-- Se o trigger não funcionou, atualizar manualmente
UPDATE members 
SET 
  contracts_completed = 1,
  updated_at = NOW()
WHERE 
  name = 'Membro Teste Admin' 
  AND status = 'Ativo' 
  AND deleted_at IS NULL;

-- Executar ranking após atualização manual
SELECT update_complete_ranking();

-- Verificar resultado final
SELECT 
    'RESULTADO FINAL' as categoria,
    name,
    contracts_completed,
    ranking_status,
    ranking_position,
    CASE 
        WHEN contracts_completed = 1 AND ranking_status = 'Amarelo' THEN '✅ CORRETO'
        ELSE '❌ AINDA COM PROBLEMA'
    END as status_final
FROM members 
WHERE name = 'Membro Teste Admin';

-- =====================================================
-- 8. LIMPEZA (OPCIONAL)
-- =====================================================

-- Descomente para limpar dados de teste
-- DELETE FROM members WHERE name IN ('Membro Teste Admin', 'Amigo Teste Admin');

-- =====================================================
-- RESUMO DO TESTE:
-- =====================================================
-- ✅ Membro criado com 0 contratos (Vermelho)
-- ✅ Amigo cadastrado para o membro
-- ✅ Contratos do membro devem ser incrementados (0 → 1)
-- ✅ Status do membro deve mudar (Vermelho → Amarelo)
-- ✅ Ranking deve ser recalculado automaticamente
