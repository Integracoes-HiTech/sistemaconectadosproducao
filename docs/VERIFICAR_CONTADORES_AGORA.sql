-- =====================================================
-- VERIFICAÇÃO RÁPIDA DOS CONTADORES
-- Execute este script para ver o que está acontecendo
-- =====================================================

-- 1. Verificar dados brutos da tabela members
SELECT 
    'DADOS BRUTOS' as categoria,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as ativos,
    COUNT(CASE WHEN deleted_at IS NULL THEN 1 END) as nao_excluidos,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as ativos_nao_excluidos,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as verdes,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as amarelos,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as vermelhos,
    COUNT(CASE WHEN ranking_status IS NULL THEN 1 END) as sem_status
FROM members;

-- 2. Verificar contador da fase
SELECT 
    'CONTADOR DA FASE' as categoria,
    current_count,
    max_limit,
    ROUND((current_count::NUMERIC / max_limit::NUMERIC) * 100, 2) as percentage
FROM phase_control 
WHERE phase_name = 'members_registration';

-- 3. Verificar se a view existe e retorna dados
SELECT 
    'VIEW v_system_stats' as categoria,
    total_members,
    green_members,
    yellow_members,
    red_members,
    current_member_count,
    max_member_limit
FROM v_system_stats;

-- 4. Verificar alguns membros específicos
SELECT 
    'EXEMPLOS DE MEMBROS' as categoria,
    name,
    status,
    ranking_status,
    contracts_completed,
    deleted_at
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 5;

-- 5. Verificar distribuição de ranking_status
SELECT 
    'DISTRIBUIÇÃO RANKING' as categoria,
    ranking_status,
    COUNT(*) as quantidade,
    CASE 
        WHEN ranking_status = 'Verde' THEN '🟢'
        WHEN ranking_status = 'Amarelo' THEN '🟡'
        WHEN ranking_status = 'Vermelho' THEN '🔴'
        ELSE '⚪'
    END as emoji
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
GROUP BY ranking_status
ORDER BY 
    CASE ranking_status 
        WHEN 'Verde' THEN 1 
        WHEN 'Amarelo' THEN 2 
        WHEN 'Vermelho' THEN 3 
        ELSE 4
    END;
