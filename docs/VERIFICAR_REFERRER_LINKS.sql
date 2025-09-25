-- =====================================================
-- VERIFICAR PROBLEMA DE REFERRER EM LINKS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- =====================================================
-- O referrer está sendo definido como full_name do auth_users
-- Mas na tabela members, o referrer deve ser o name do membro
-- Isso causa inconsistência e impede a atualização de contratos

-- =====================================================
-- 1. VERIFICAR DADOS DOS LINKS
-- =====================================================

-- Verificar links e seus referrers
SELECT 
    'LINKS E REFERRERS' as categoria,
    ul.link_id,
    ul.referrer_name,
    ul.link_type,
    au.full_name as auth_user_full_name,
    au.name as auth_user_name,
    au.role as auth_user_role
FROM user_links ul
LEFT JOIN auth_users au ON ul.user_id = au.id
WHERE ul.is_active = true
ORDER BY ul.created_at DESC
LIMIT 10;

-- =====================================================
-- 2. VERIFICAR MEMBROS E SEUS REFERRERS
-- =====================================================

-- Verificar membros e seus referrers
SELECT 
    'MEMBROS E REFERRERS' as categoria,
    name as membro,
    referrer,
    is_friend,
    contracts_completed,
    ranking_status,
    created_at
FROM members 
WHERE status = 'Ativo' AND deleted_at IS NULL
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- 3. VERIFICAR INCONSISTÊNCIAS
-- =====================================================

-- Verificar se há membros com referrer que não existe na tabela members
SELECT 
    'INCONSISTÊNCIAS DE REFERRER' as categoria,
    m.name as membro,
    m.referrer,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM members m2 
            WHERE m2.name = m.referrer 
            AND m2.status = 'Ativo' 
            AND m2.deleted_at IS NULL
        ) THEN '✅ REFERRER EXISTE'
        ELSE '❌ REFERRER NÃO EXISTE'
    END as status_referrer
FROM members m
WHERE m.status = 'Ativo' 
  AND m.deleted_at IS NULL 
  AND m.referrer IS NOT NULL
  AND m.referrer != 'Administrador'
ORDER BY m.created_at DESC;

-- =====================================================
-- 4. VERIFICAR AMIGOS COM REFERRER INCORRETO
-- =====================================================

-- Verificar amigos que foram cadastrados mas não atualizaram contratos
SELECT 
    'AMIGOS COM REFERRER INCORRETO' as categoria,
    name as amigo,
    referrer,
    is_friend,
    contracts_completed,
    ranking_status,
    created_at
FROM members 
WHERE status = 'Ativo' 
  AND deleted_at IS NULL 
  AND is_friend = true
ORDER BY created_at DESC;

-- =====================================================
-- 5. CORRIGIR REFERRERS INCORRETOS
-- =====================================================

-- Atualizar referrers de amigos para usar o nome correto do membro
-- Primeiro, vamos ver quais precisam ser corrigidos
WITH referrer_corrections AS (
  SELECT 
    m.id,
    m.name as amigo,
    m.referrer as referrer_atual,
    au.name as referrer_correto
  FROM members m
  LEFT JOIN auth_users au ON au.full_name = m.referrer
  WHERE m.status = 'Ativo' 
    AND m.deleted_at IS NULL 
    AND m.is_friend = true
    AND au.name IS NOT NULL
)
SELECT 
    'CORREÇÕES NECESSÁRIAS' as categoria,
    amigo,
    referrer_atual,
    referrer_correto
FROM referrer_corrections;

-- =====================================================
-- 6. APLICAR CORREÇÕES (DESCOMENTE PARA EXECUTAR)
-- =====================================================

-- Descomente as linhas abaixo para aplicar as correções
-- UPDATE members 
-- SET referrer = au.name
-- FROM auth_users au
-- WHERE members.referrer = au.full_name
--   AND members.status = 'Ativo'
--   AND members.deleted_at IS NULL
--   AND members.is_friend = true;

-- =====================================================
-- 7. RECALCULAR CONTRATOS APÓS CORREÇÃO
-- =====================================================

-- Descomente para recalcular contratos após correção
-- WITH amigos_por_membro AS (
--   SELECT 
--     referrer as membro,
--     COUNT(*) as amigos_cadastrados
--   FROM members 
--   WHERE status = 'Ativo' 
--     AND deleted_at IS NULL 
--     AND is_friend = true 
--     AND referrer IS NOT NULL
--   GROUP BY referrer
-- )
-- UPDATE members 
-- SET 
--   contracts_completed = apm.amigos_cadastrados,
--   updated_at = NOW()
-- FROM amigos_por_membro apm
-- WHERE members.name = apm.membro
--   AND members.status = 'Ativo'
--   AND members.deleted_at IS NULL
--   AND members.is_friend = false;

-- Executar ranking após correção
-- SELECT update_complete_ranking();

-- =====================================================
-- 8. VERIFICAR RESULTADO APÓS CORREÇÃO
-- =====================================================

-- Verificar se as correções funcionaram
-- SELECT 
--     'RESULTADO APÓS CORREÇÃO' as categoria,
--     name as membro,
--     contracts_completed,
--     ranking_status,
--     ranking_position
-- FROM members 
-- WHERE status = 'Ativo' 
--   AND deleted_at IS NULL 
--   AND is_friend = false
-- ORDER BY contracts_completed DESC;

-- =====================================================
-- RESUMO DO PROBLEMA:
-- =====================================================
-- ✅ Referrer está sendo definido como full_name do auth_users
-- ✅ Mas na tabela members deve ser o name do membro
-- ✅ Isso impede a atualização de contratos
-- ✅ Correção: usar au.name em vez de au.full_name
-- ✅ Recalcular contratos após correção
-- ✅ Executar ranking para atualizar status
