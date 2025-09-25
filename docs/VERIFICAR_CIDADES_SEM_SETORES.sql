-- VERIFICAR CIDADES SEM SETORES NO BANCO DE DADOS
-- Execute este script para identificar cidades que não possuem setores cadastrados

-- 1. Listar todas as cidades e quantos setores cada uma possui
SELECT 
    c.id,
    c.name as cidade,
    c.state,
    COUNT(s.id) as total_setores,
    CASE 
        WHEN COUNT(s.id) = 0 THEN '❌ SEM SETORES'
        WHEN COUNT(s.id) < 5 THEN '⚠️ POUCOS SETORES'
        ELSE '✅ COM SETORES'
    END as status
FROM cities c
LEFT JOIN sectors s ON c.id = s.city_id
GROUP BY c.id, c.name, c.state
ORDER BY total_setores ASC, c.name;

-- 2. Listar apenas cidades SEM setores (mais crítico)
SELECT 
    c.id,
    c.name as cidade,
    c.state,
    c.created_at
FROM cities c
LEFT JOIN sectors s ON c.id = s.city_id
WHERE s.id IS NULL
ORDER BY c.name;

-- 3. Contar quantas cidades não têm setores
SELECT 
    COUNT(*) as cidades_sem_setores,
    (SELECT COUNT(*) FROM cities) as total_cidades,
    ROUND(
        (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cities)), 
        2
    ) as percentual_sem_setores
FROM cities c
LEFT JOIN sectors s ON c.id = s.city_id
WHERE s.id IS NULL;

-- 4. Listar cidades com poucos setores (menos de 5)
SELECT 
    c.id,
    c.name as cidade,
    c.state,
    COUNT(s.id) as total_setores
FROM cities c
LEFT JOIN sectors s ON c.id = s.city_id
GROUP BY c.id, c.name, c.state
HAVING COUNT(s.id) < 5 AND COUNT(s.id) > 0
ORDER BY total_setores ASC, c.name;

-- 5. Verificar se há usuários cadastrados nessas cidades sem setores
SELECT 
    c.name as cidade,
    COUNT(u.id) as usuarios_cadastrados
FROM cities c
LEFT JOIN sectors s ON c.id = s.city_id
LEFT JOIN users u ON normalize_text(u.city) = normalize_text(c.name)
WHERE s.id IS NULL
GROUP BY c.id, c.name
HAVING COUNT(u.id) > 0
ORDER BY usuarios_cadastrados DESC;

-- 6. Resumo geral
SELECT 
    'RESUMO GERAL' as tipo,
    COUNT(DISTINCT c.id) as total_cidades,
    COUNT(DISTINCT CASE WHEN s.id IS NOT NULL THEN c.id END) as cidades_com_setores,
    COUNT(DISTINCT CASE WHEN s.id IS NULL THEN c.id END) as cidades_sem_setores,
    COUNT(DISTINCT s.id) as total_setores
FROM cities c
LEFT JOIN sectors s ON c.id = s.city_id;
