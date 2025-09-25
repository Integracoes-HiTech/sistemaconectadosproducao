-- =====================================================
-- VERIFICAR DADOS ATUAIS DOS MEMBROS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- Verificar dados atuais dos membros
SELECT 
    'Dados Atuais' as categoria,
    COUNT(*) as total_members,
    COUNT(CASE WHEN status = 'Ativo' AND deleted_at IS NULL THEN 1 END) as active_members,
    COUNT(CASE WHEN ranking_status = 'Verde' THEN 1 END) as green_members,
    COUNT(CASE WHEN ranking_status = 'Amarelo' THEN 1 END) as yellow_members,
    COUNT(CASE WHEN ranking_status = 'Vermelho' THEN 1 END) as red_members,
    COUNT(CASE WHEN ranking_status IS NULL THEN 1 END) as null_status
FROM members;

-- Verificar view v_system_stats
SELECT 'View Stats' as categoria, * FROM v_system_stats;

-- Verificar membros individuais
SELECT 
    id,
    name,
    status,
    ranking_status,
    contracts_completed,
    deleted_at
FROM members 
ORDER BY created_at DESC;
