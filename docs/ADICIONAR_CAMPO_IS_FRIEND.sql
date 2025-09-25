-- =====================================================
-- ADICIONAR CAMPO is_friend NA TABELA MEMBERS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- =====================================================
-- 1. ADICIONAR CAMPO is_friend NA TABELA MEMBERS
-- =====================================================

-- Adicionar coluna is_friend na tabela members
ALTER TABLE members 
ADD COLUMN IF NOT EXISTS is_friend BOOLEAN DEFAULT false;

-- =====================================================
-- 2. COMENTÁRIO DA COLUNA
-- =====================================================

COMMENT ON COLUMN members.is_friend IS 'Indica se é um amigo (contrato pago) ou membro normal. true = amigo, false = membro';

-- =====================================================
-- 3. VERIFICAR SE A COLUNA FOI ADICIONADA
-- =====================================================

-- Verificar se a coluna foi criada corretamente
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'members' 
    AND column_name = 'is_friend';

-- =====================================================
-- 4. ATUALIZAR REGISTROS EXISTENTES (OPCIONAL)
-- =====================================================

-- Se você quiser marcar registros existentes como membros (não amigos)
-- UPDATE members SET is_friend = false WHERE is_friend IS NULL;

-- =====================================================
-- 5. VERIFICAR DADOS APÓS ATUALIZAÇÃO
-- =====================================================

-- Verificar quantos membros e amigos existem
SELECT 
    CASE 
        WHEN is_friend = true THEN 'Amigos (Contratos Pagos)'
        WHEN is_friend = false THEN 'Membros Normais'
        ELSE 'Não Definido'
    END as tipo,
    COUNT(*) as quantidade
FROM members 
GROUP BY is_friend
ORDER BY is_friend;

-- =====================================================
-- 6. EXEMPLO DE CONSULTAS ÚTEIS
-- =====================================================

-- Buscar apenas membros (não amigos)
-- SELECT * FROM members WHERE is_friend = false OR is_friend IS NULL;

-- Buscar apenas amigos (contratos pagos)
-- SELECT * FROM members WHERE is_friend = true;

-- Buscar todos os registros com tipo definido
-- SELECT * FROM members WHERE is_friend IS NOT NULL;
