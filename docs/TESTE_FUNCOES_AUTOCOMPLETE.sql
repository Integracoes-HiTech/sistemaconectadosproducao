-- TESTE DAS FUNÇÕES DE AUTOCOMPLETE
-- Execute este script para testar se as funções estão funcionando

-- 1. Testar função upsert_city
SELECT upsert_city('Teste Cidade') as cidade_id;

-- 2. Verificar se a cidade foi criada
SELECT * FROM cities WHERE name = 'Teste Cidade';

-- 3. Testar função upsert_sector
SELECT upsert_sector('Teste Setor', 'Teste Cidade') as sector_id;

-- 4. Verificar se o setor foi criado
SELECT s.*, c.name as cidade_nome 
FROM sectors s 
JOIN cities c ON s.city_id = c.id 
WHERE s.name = 'Teste Setor';

-- 5. Testar função search_cities
SELECT * FROM search_cities('teste');

-- 6. Testar função search_sectors
SELECT * FROM search_sectors('teste', 'Teste Cidade');

-- 7. Limpar dados de teste
DELETE FROM sectors WHERE name = 'Teste Setor';
DELETE FROM cities WHERE name = 'Teste Cidade';

-- 8. Verificar se foi limpo
SELECT 'Teste concluído' as resultado;
