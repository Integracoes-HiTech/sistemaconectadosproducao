-- =====================================================
-- RECRIAR TRIGGER DE CONTRATOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- O trigger não está funcionando quando amigos são cadastrados
-- Precisamos recriar o trigger e garantir que está funcionando

-- =====================================================
-- 1. REMOVER TRIGGER E FUNÇÃO EXISTENTES
-- =====================================================

-- Remover trigger existente
DROP TRIGGER IF EXISTS trigger_update_referrer_contracts ON members;

-- Remover função existente
DROP FUNCTION IF EXISTS update_referrer_contracts_on_friend_registration();

-- =====================================================
-- 2. RECRIAR FUNÇÃO PARA ATUALIZAR CONTRATOS
-- =====================================================

CREATE OR REPLACE FUNCTION update_referrer_contracts_on_friend_registration()
RETURNS TRIGGER AS $$
BEGIN
  -- Log da operação
  RAISE NOTICE 'Trigger executado para: %', NEW.name;
  RAISE NOTICE 'É amigo: %, Referrer: %', NEW.is_friend, NEW.referrer;
  
  -- Só executar se é um amigo (contrato pago) e tem referrer
  IF NEW.is_friend = true AND NEW.referrer IS NOT NULL THEN
    RAISE NOTICE 'Atualizando contratos para referrer: %', NEW.referrer;
    
    -- Incrementar contratos do referrer
    UPDATE members 
    SET 
      contracts_completed = contracts_completed + 1,
      updated_at = NOW()
    WHERE 
      name = NEW.referrer 
      AND status = 'Ativo' 
      AND deleted_at IS NULL;
    
    -- Verificar se a atualização funcionou
    IF FOUND THEN
      RAISE NOTICE 'Contratos incrementados com sucesso para: %', NEW.referrer;
    ELSE
      RAISE WARNING 'Referrer não encontrado: %', NEW.referrer;
    END IF;
    
    -- Atualizar ranking após mudança nos contratos
    RAISE NOTICE 'Executando update_complete_ranking...';
    PERFORM update_complete_ranking();
    RAISE NOTICE 'Ranking atualizado com sucesso';
  ELSE
    RAISE NOTICE 'Não é amigo ou não tem referrer - pulando atualização';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. RECRIAR TRIGGER
-- =====================================================

CREATE TRIGGER trigger_update_referrer_contracts
  AFTER INSERT ON members
  FOR EACH ROW
  EXECUTE FUNCTION update_referrer_contracts_on_friend_registration();

-- =====================================================
-- 4. VERIFICAR SE FOI CRIADO CORRETAMENTE
-- =====================================================

-- Verificar trigger
SELECT 
    'TRIGGER CRIADO' as status,
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_update_referrer_contracts';

-- Verificar função
SELECT 
    'FUNÇÃO CRIADA' as status,
    proname as function_name,
    CASE WHEN prosrc IS NOT NULL THEN 'SIM' ELSE 'NÃO' END as has_body
FROM pg_proc 
WHERE proname = 'update_referrer_contracts_on_friend_registration';

-- =====================================================
-- 5. TESTE MANUAL - CADASTRAR AMIGO DE TESTE
-- =====================================================

-- Encontrar um membro para ser referrer
SELECT 
    'MEMBRO PARA SER REFERRER' as categoria,
    name,
    contracts_completed,
    ranking_status
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL AND is_friend = false
LIMIT 1;

-- =====================================================
-- 6. SIMULAR CADASTRO DE AMIGO (TESTE)
-- =====================================================

-- Descomente e execute para testar (substitua 'NOME_DO_MEMBRO' pelo nome real)
-- INSERT INTO members (
--   id, name, phone, instagram, city, sector, referrer, registration_date, status,
--   couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
--   contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced, is_friend
-- ) VALUES (
--   gen_random_uuid(),
--   'Amigo Teste Trigger',
--   '99999-9999',
--   '@amigo_teste_trigger',
--   'Goiânia',
--   'Setor Central',
--   'NOME_DO_MEMBRO', -- Substitua pelo nome real
--   CURRENT_DATE,
--   'Ativo',
--   'Cônjuge Teste Trigger',
--   '88888-9999',
--   '@conjuge_teste_trigger',
--   'Goiânia',
--   'Setor Central',
--   0,
--   NULL,
--   'Vermelho',
--   false,
--   false,
--   true -- É um amigo
-- );

-- =====================================================
-- 7. VERIFICAR RESULTADO DO TESTE
-- =====================================================

-- Verificar se o membro teve contratos incrementados
-- SELECT 
--     'RESULTADO DO TESTE' as categoria,
--     name,
--     contracts_completed,
--     ranking_status,
--     ranking_position
-- FROM members 
-- WHERE name = 'NOME_DO_MEMBRO'; -- Substitua pelo nome real

-- =====================================================
-- RESUMO DAS CORREÇÕES:
-- =====================================================
-- ✅ Trigger removido e recriado
-- ✅ Função recriada com logs detalhados
-- ✅ Verificações incluídas
-- ✅ Teste manual disponível
-- ✅ Logs para debug incluídos
