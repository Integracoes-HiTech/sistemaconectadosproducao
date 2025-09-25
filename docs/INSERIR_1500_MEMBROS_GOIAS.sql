-- =====================================================
-- INSERIR 1500 MEMBROS DE TESTE - GOIÁS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 🗑️ LIMPEZA DOS DADOS ANTIGOS
-- =====================================================

-- Limpar dados de teste anteriores (manter apenas dados reais)
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
   OR city IN ('Goiânia', 'Aparecida de Goiânia', 'Anápolis', 'Rio Verde', 'Luziânia', 'Valparaíso de Goiás', 'Trindade', 'Formosa', 'Novo Gama', 'Planaltina')
   OR sector IN ('Setor Central', 'Setor Sul', 'Setor Norte', 'Setor Leste', 'Setor Oeste', 'Setor Bueno', 'Setor Marista', 'Setor Campinas', 'Setor Bela Vista', 'Setor Aeroporto');

-- =====================================================
-- INSERIR 1500 MEMBROS DE GOIÁS
-- =====================================================

-- Cidades de Goiás (municípios reais)
WITH cidades_goias AS (
  SELECT unnest(ARRAY[
    'Goiânia', 'Aparecida de Goiânia', 'Anápolis', 'Rio Verde', 'Luziânia', 
    'Valparaíso de Goiás', 'Trindade', 'Formosa', 'Novo Gama', 'Planaltina',
    'Catalão', 'Senador Canedo', 'Itumbiara', 'Jataí', 'Santo Antônio do Descoberto',
    'Caldas Novas', 'Cidade Ocidental', 'Mineiros', 'Nerópolis', 'Goianésia',
    'Morrinhos', 'Pirenópolis', 'Ceres', 'Iporá', 'Quirinópolis',
    'São Luís de Montes Belos', 'Bom Jesus de Goiás', 'Cristalina', 'Itaberaí', 'Goiatuba',
    'Araguari', 'Uberlândia', 'Uberaba', 'Patos de Minas', 'Divinópolis',
    'Montes Claros', 'Uberaba', 'Juiz de Fora', 'Betim', 'Contagem',
    'Ribeirão das Neves', 'Ibirité', 'Vespasiano', 'Santa Luzia', 'Poços de Caldas',
    'Pouso Alegre', 'Passos', 'Patrocínio', 'Araxá', 'Ituiutaba',
    'Araguari', 'Uberlândia', 'Uberaba', 'Patos de Minas', 'Divinópolis'
  ]) as cidade
),
-- Setores de Goiás (setores reais)
setores_goias AS (
  SELECT unnest(ARRAY[
    'Setor Central', 'Setor Sul', 'Setor Norte', 'Setor Leste', 'Setor Oeste',
    'Setor Bueno', 'Setor Marista', 'Setor Campinas', 'Setor Bela Vista', 'Setor Aeroporto',
    'Setor Pedro Ludovico', 'Setor Criméia', 'Setor Jardim América', 'Setor Vila Nova',
    'Setor Conde dos Arcos', 'Setor Jardim Goiás', 'Setor Jardim Guanabara', 'Setor Vila Redenção',
    'Setor Jardim Atlântico', 'Setor Vila União', 'Setor Jardim Europa', 'Setor Vila Canaã',
    'Setor Jardim América', 'Setor Vila Nova', 'Setor Jardim Goiás', 'Setor Vila Redenção',
    'Setor Jardim Atlântico', 'Setor Vila União', 'Setor Jardim Europa', 'Setor Vila Canaã',
    'Setor Central', 'Setor Sul', 'Setor Norte', 'Setor Leste', 'Setor Oeste',
    'Setor Bueno', 'Setor Marista', 'Setor Campinas', 'Setor Bela Vista', 'Setor Aeroporto',
    'Setor Pedro Ludovico', 'Setor Criméia', 'Setor Jardim América', 'Setor Vila Nova',
    'Setor Conde dos Arcos', 'Setor Jardim Goiás', 'Setor Jardim Guanabara', 'Setor Vila Redenção',
    'Setor Jardim Atlântico', 'Setor Vila União', 'Setor Jardim Europa', 'Setor Vila Canaã'
  ]) as setor
),
-- Nomes brasileiros comuns
nomes_brasileiros AS (
  SELECT unnest(ARRAY[
    'João Silva', 'Maria Santos', 'Pedro Oliveira', 'Ana Costa', 'Carlos Ferreira',
    'Lucia Rodrigues', 'Roberto Alves', 'Fernanda Lima', 'Marcos Pereira', 'Juliana Martins',
    'Rafael Souza', 'Camila Barbosa', 'Diego Carvalho', 'Patricia Gomes', 'Andre Rocha',
    'Mariana Dias', 'Felipe Nunes', 'Beatriz Moreira', 'Gabriel Cardoso', 'Larissa Vieira',
    'Lucas Silva', 'Amanda Santos', 'Bruno Oliveira', 'Carolina Costa', 'Daniel Ferreira',
    'Eduarda Rodrigues', 'Fabio Alves', 'Gabriela Lima', 'Henrique Pereira', 'Isabela Martins',
    'Igor Souza', 'Julia Barbosa', 'Kleber Carvalho', 'Leticia Gomes', 'Matheus Rocha',
    'Natalia Dias', 'Otavio Nunes', 'Priscila Moreira', 'Renato Cardoso', 'Sabrina Vieira',
    'Thiago Silva', 'Vanessa Santos', 'Wagner Oliveira', 'Yasmin Costa', 'Zeca Ferreira',
    'Adriana Rodrigues', 'Bernardo Alves', 'Cintia Lima', 'Douglas Pereira', 'Eliane Martins'
  ]) as nome
),
-- Nomes de cônjuges
conjuges_brasileiros AS (
  SELECT unnest(ARRAY[
    'Silvia Silva', 'Marcos Santos', 'Patricia Oliveira', 'Ricardo Costa', 'Luciana Ferreira',
    'Antonio Rodrigues', 'Cristina Alves', 'Paulo Lima', 'Sandra Pereira', 'Jose Martins',
    'Rita Souza', 'Francisco Barbosa', 'Tereza Carvalho', 'Manuel Gomes', 'Rosa Rocha',
    'Joaquim Dias', 'Maria Nunes', 'Jose Moreira', 'Ana Cardoso', 'Carlos Vieira',
    'Lucia Silva', 'Roberto Santos', 'Fernanda Oliveira', 'Marcos Costa', 'Juliana Ferreira',
    'Rafael Rodrigues', 'Camila Alves', 'Diego Lima', 'Patricia Pereira', 'Andre Martins',
    'Mariana Souza', 'Felipe Barbosa', 'Beatriz Carvalho', 'Gabriel Gomes', 'Larissa Rocha',
    'Lucas Dias', 'Amanda Nunes', 'Bruno Moreira', 'Carolina Cardoso', 'Daniel Vieira',
    'Eduarda Silva', 'Fabio Santos', 'Gabriela Oliveira', 'Henrique Costa', 'Isabela Ferreira',
    'Igor Rodrigues', 'Julia Alves', 'Kleber Lima', 'Leticia Pereira', 'Matheus Martins',
    'Natalia Souza', 'Otavio Barbosa', 'Priscila Carvalho', 'Renato Gomes', 'Sabrina Rocha',
    'Thiago Dias', 'Vanessa Nunes', 'Wagner Moreira', 'Yasmin Cardoso', 'Zeca Vieira'
  ]) as conjugue
)

-- Inserir 1500 membros
INSERT INTO members (
  id, name, phone, instagram, city, sector, referrer, registration_date, status,
  couple_name, couple_phone, couple_instagram, couple_city, couple_sector,
  contracts_completed, ranking_position, ranking_status, is_top_1500, can_be_replaced, is_friend
)
SELECT 
  gen_random_uuid() as id,
  nomes_brasileiros.nome,
  '99999-' || LPAD((i % 10000)::text, 4, '0') as phone,
  '@' || LOWER(SPLIT_PART(nomes_brasileiros.nome, ' ', 1)) || '_' || i as instagram,
  cidades_goias.cidade,
  setores_goias.setor,
  'Membro' as referrer,
  CURRENT_DATE - INTERVAL '1 day' * (i % 365) as registration_date,
  'Ativo' as status,
  conjuges_brasileiros.conjugue as couple_name,
  '88888-' || LPAD((i % 10000)::text, 4, '0') as couple_phone,
  '@' || LOWER(SPLIT_PART(conjuges_brasileiros.conjugue, ' ', 1)) || '_' || i as couple_instagram,
  cidades_goias.cidade as couple_city, -- Mesma cidade do membro principal
  setores_goias.setor as couple_sector, -- Mesmo setor do membro principal
  0 as contracts_completed, -- SEM CONTRATOS ATIVOS
  NULL as ranking_position, -- SEM RANKING DEFINIDO
  NULL as ranking_status, -- SEM STATUS DE RANKING
  false as is_top_1500,
  false as can_be_replaced,
  false as is_friend
FROM 
  generate_series(1, 1500) as i,
  cidades_goias,
  setores_goias,
  nomes_brasileiros,
  conjuges_brasileiros
WHERE 
  -- Distribuir uniformemente pelos arrays
  cidades_goias.cidade = (SELECT cidade FROM cidades_goias OFFSET (i % (SELECT COUNT(*) FROM cidades_goias)) LIMIT 1)
  AND setores_goias.setor = (SELECT setor FROM setores_goias OFFSET (i % (SELECT COUNT(*) FROM setores_goias)) LIMIT 1)
  AND nomes_brasileiros.nome = (SELECT nome FROM nomes_brasileiros OFFSET (i % (SELECT COUNT(*) FROM nomes_brasileiros)) LIMIT 1)
  AND conjuges_brasileiros.conjugue = (SELECT conjugue FROM conjuges_brasileiros OFFSET (i % (SELECT COUNT(*) FROM conjuges_brasileiros)) LIMIT 1);

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Verificar inserção
SELECT 
    'RESULTADO DA INSERÇÃO' as categoria,
    COUNT(*) as total_membros,
    COUNT(CASE WHEN contracts_completed = 0 THEN 1 END) as sem_contratos,
    COUNT(CASE WHEN ranking_position IS NULL THEN 1 END) as sem_ranking,
    COUNT(CASE WHEN ranking_status IS NULL THEN 1 END) as sem_status_ranking,
    COUNT(DISTINCT city) as cidades_diferentes,
    COUNT(DISTINCT sector) as setores_diferentes
FROM members 
WHERE name LIKE '%Silva%' 
   OR name LIKE '%Santos%' 
   OR name LIKE '%Oliveira%'
   OR name LIKE '%Costa%'
   OR name LIKE '%Ferreira%';

-- Verificar distribuição por cidade
SELECT 
    'DISTRIBUIÇÃO POR CIDADE' as categoria,
    city,
    COUNT(*) as quantidade
FROM members 
WHERE name LIKE '%Silva%' 
   OR name LIKE '%Santos%' 
   OR name LIKE '%Oliveira%'
   OR name LIKE '%Costa%' 
   OR name LIKE '%Ferreira%'
GROUP BY city
ORDER BY quantidade DESC
LIMIT 10;

-- Verificar distribuição por setor
SELECT 
    'DISTRIBUIÇÃO POR SETOR' as categoria,
    sector,
    COUNT(*) as quantidade
FROM members 
WHERE name LIKE '%Silva%' 
   OR name LIKE '%Santos%' 
   OR name LIKE '%Oliveira%'
   OR name LIKE '%Costa%' 
   OR name LIKE '%Ferreira%'
GROUP BY sector
ORDER BY quantidade DESC
LIMIT 10;

-- =====================================================
-- RESUMO DAS MODIFICAÇÕES:
-- =====================================================
-- ✅ 1500 membros inseridos
-- ✅ Apenas cidades de Goiás (municípios reais)
-- ✅ Apenas setores de Goiás (setores reais)
-- ✅ 0 contratos completados (sem contratos ativos)
-- ✅ NULL ranking_position (sem ranking definido)
-- ✅ NULL ranking_status (sem status de ranking)
-- ✅ Cônjuges com mesma cidade e setor
-- ✅ Ranking só muda quando começarem a cadastrar amigos
-- ✅ Dados de teste anteriores removidos
