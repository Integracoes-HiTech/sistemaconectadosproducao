-- =====================================================
-- LIMPAR MEMBROS CADASTRADOS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- ⚠️ ATENÇÃO: ESTE SCRIPT VAI APAGAR TODOS OS MEMBROS!
-- ⚠️ FAÇA BACKUP ANTES DE EXECUTAR!

-- =====================================================
-- OPÇÃO 1: APAGAR TODOS OS MEMBROS (HARD DELETE)
-- =====================================================

-- Descomente a linha abaixo para apagar TODOS os membros permanentemente
-- DELETE FROM members;

-- =====================================================
-- OPÇÃO 2: APAGAR APENAS MEMBROS DE TESTE (RECOMENDADO)
-- =====================================================

-- Apagar apenas membros de teste (mantém dados reais)
DELETE FROM members 
WHERE name LIKE '%Silva%' 
   OR name LIKE '%Santos%' 
   OR name LIKE '%Oliveira%'
   OR name LIKE '%Costa%' 
   OR name LIKE '%Ferreira%'
   OR name LIKE '%Rodrigues%'
   OR name LIKE '%Alves%'
   OR name LIKE '%Lima%'
   OR name LIKE '%Pereira%'
   OR name LIKE '%Martins%'
   OR name LIKE '%Souza%'
   OR name LIKE '%Barbosa%'
   OR name LIKE '%Carvalho%'
   OR name LIKE '%Gomes%'
   OR name LIKE '%Rocha%'
   OR name LIKE '%Dias%'
   OR name LIKE '%Nunes%'
   OR name LIKE '%Moreira%'
   OR name LIKE '%Cardoso%'
   OR name LIKE '%Vieira%'
   OR phone LIKE '99999-%'
   OR phone LIKE '88888-%'
   OR instagram LIKE '@joao%'
   OR instagram LIKE '@maria%'
   OR instagram LIKE '@pedro%'
   OR instagram LIKE '@ana%'
   OR instagram LIKE '@carlos%'
   OR instagram LIKE '@lucia%'
   OR instagram LIKE '@roberto%'
   OR instagram LIKE '@fernanda%'
   OR instagram LIKE '@marcos%'
   OR instagram LIKE '@juliana%'
   OR instagram LIKE '@rafael%'
   OR instagram LIKE '@camila%'
   OR instagram LIKE '@diego%'
   OR instagram LIKE '@patricia%'
   OR instagram LIKE '@andre%'
   OR instagram LIKE '@mariana%'
   OR instagram LIKE '@felipe%'
   OR instagram LIKE '@beatriz%'
   OR city IN ('Goiânia', 'Aparecida de Goiânia', 'Anápolis', 'Rio Verde', 'Luziânia', 'Valparaíso de Goiás', 'Trindade', 'Formosa', 'Novo Gama', 'Planaltina', 'Catalão', 'Senador Canedo', 'Itumbiara', 'Jataí', 'Santo Antônio do Descoberto', 'Caldas Novas', 'Cidade Ocidental', 'Mineiros', 'Nerópolis', 'Goianésia', 'Morrinhos', 'Pirenópolis', 'Ceres', 'Iporá', 'Quirinópolis', 'São Luís de Montes Belos', 'Bom Jesus de Goiás', 'Cristalina', 'Itaberaí', 'Goiatuba', 'Araguari', 'Uberlândia', 'Uberaba', 'Patos de Minas', 'Divinópolis', 'Montes Claros', 'Uberaba', 'Juiz de Fora', 'Betim', 'Contagem', 'Ribeirão das Neves', 'Ibirité', 'Vespasiano', 'Santa Luzia', 'Poços de Caldas', 'Pouso Alegre', 'Passos', 'Patrocínio', 'Araxá', 'Ituiutaba', 'Araguari', 'Uberlândia', 'Uberaba', 'Patos de Minas', 'Divinópolis')
   OR sector IN ('Setor Central', 'Setor Sul', 'Setor Norte', 'Setor Leste', 'Setor Oeste', 'Setor Bueno', 'Setor Marista', 'Setor Campinas', 'Setor Bela Vista', 'Setor Aeroporto', 'Setor Pedro Ludovico', 'Setor Criméia', 'Setor Jardim América', 'Setor Vila Nova', 'Setor Conde dos Arcos', 'Setor Jardim Goiás', 'Setor Jardim Guanabara', 'Setor Vila Redenção', 'Setor Jardim Atlântico', 'Setor Vila União', 'Setor Jardim Europa', 'Setor Vila Canaã', 'Setor Central', 'Setor Sul', 'Setor Norte', 'Setor Leste', 'Setor Oeste', 'Setor Bueno', 'Setor Marista', 'Setor Campinas', 'Setor Bela Vista', 'Setor Aeroporto', 'Setor Pedro Ludovico', 'Setor Criméia', 'Setor Jardim América', 'Setor Vila Nova', 'Setor Conde dos Arcos', 'Setor Jardim Goiás', 'Setor Jardim Guanabara', 'Setor Vila Redenção', 'Setor Jardim Atlântico', 'Setor Vila União', 'Setor Jardim Europa', 'Setor Vila Canaã');

-- =====================================================
-- OPÇÃO 3: SOFT DELETE (MARCA COMO EXCLUÍDO)
-- =====================================================

-- Descomente as linhas abaixo para fazer soft delete (marca como excluído)
-- UPDATE members 
-- SET deleted_at = NOW()
-- WHERE name LIKE '%Silva%' 
--    OR name LIKE '%Santos%' 
--    OR name LIKE '%Oliveira%'
--    OR name LIKE '%Costa%' 
--    OR name LIKE '%Ferreira%'
--    OR phone LIKE '99999-%'
--    OR phone LIKE '88888-%'
--    OR instagram LIKE '@joao%'
--    OR instagram LIKE '@maria%'
--    OR city IN ('Goiânia', 'Aparecida de Goiânia', 'Anápolis', 'Rio Verde', 'Luziânia');

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Verificar quantos membros restaram
SELECT 
    'RESULTADO DA LIMPEZA' as categoria,
    COUNT(*) as total_membros_restantes,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as ativos,
    COUNT(CASE WHEN deleted_at IS NULL THEN 1 END) as nao_excluidos,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos_nao_excluidos
FROM members;

-- Verificar alguns membros restantes
SELECT 
    'MEMBROS RESTANTES' as categoria,
    name,
    city,
    sector,
    status,
    deleted_at,
    created_at
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- ATUALIZAR CONTADORES APÓS LIMPEZA
-- =====================================================

-- Atualizar contador da fase
UPDATE phase_control 
SET current_count = (
    SELECT COUNT(*) 
    FROM members 
    WHERE status = 'Ativo' AND deleted_at IS NULL
)
WHERE phase_name = 'members_registration';

-- Recriar view v_system_stats
DROP VIEW IF EXISTS v_system_stats;

CREATE OR REPLACE VIEW v_system_stats AS
SELECT 
  -- Total de membros ativos
  (SELECT COUNT(*) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL) as total_members,
  
  -- Membros verdes (15+ contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Verde' AND status = 'Ativo' AND deleted_at IS NULL) as green_members,
  
  -- Membros amarelos (1-14 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Amarelo' AND status = 'Ativo' AND deleted_at IS NULL) as yellow_members,
  
  -- Membros vermelhos (0 contratos)
  (SELECT COUNT(*) FROM members WHERE ranking_status = 'Vermelho' AND status = 'Ativo' AND deleted_at IS NULL) as red_members,
  
  -- Top 1500 membros
  (SELECT COUNT(*) FROM members WHERE is_top_1500 = true AND status = 'Ativo' AND deleted_at IS NULL) as top_1500_members,
  
  -- Contratos completos
  (SELECT SUM(contracts_completed) FROM members WHERE status = 'Ativo' AND deleted_at IS NULL) as completed_contracts,
  
  -- Contratos pendentes
  0 as pending_contracts,
  
  -- Contador atual da fase
  (SELECT COALESCE(current_count, 0) FROM phase_control WHERE phase_name = 'members_registration') as current_member_count,
  
  -- Limite máximo da fase
  (SELECT COALESCE(max_limit, 1500) FROM phase_control WHERE phase_name = 'members_registration') as max_member_limit;

-- Verificar contadores atualizados
SELECT 
    'CONTADORES ATUALIZADOS' as categoria,
    total_members,
    green_members,
    yellow_members,
    red_members,
    current_member_count,
    max_member_limit
FROM v_system_stats;

-- =====================================================
-- RESUMO DAS OPÇÕES:
-- =====================================================
-- ✅ OPÇÃO 1: DELETE FROM members; (APAGA TUDO)
-- ✅ OPÇÃO 2: DELETE com WHERE (APAGA APENAS TESTES) - RECOMENDADO
-- ✅ OPÇÃO 3: UPDATE com deleted_at (SOFT DELETE)
-- ✅ Contadores atualizados automaticamente
-- ✅ Verificações incluídas
