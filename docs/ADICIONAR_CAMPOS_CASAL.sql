-- =====================================================
-- ADICIONAR CAMPOS DA SEGUNDA PESSOA (CASAL)
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. Verificar se a tabela members existe
SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_name = 'members' 
AND table_schema = 'public';

-- 2. Verificar estrutura atual da tabela members
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'members' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Adicionar campos da segunda pessoa (se não existirem)
DO $$
BEGIN
    -- Verificar e adicionar couple_name
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'members' 
        AND column_name = 'couple_name'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE members ADD COLUMN couple_name VARCHAR(255) NOT NULL DEFAULT '';
    END IF;

    -- Verificar e adicionar couple_phone
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'members' 
        AND column_name = 'couple_phone'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE members ADD COLUMN couple_phone VARCHAR(20) NOT NULL DEFAULT '';
    END IF;

    -- Verificar e adicionar couple_instagram
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'members' 
        AND column_name = 'couple_instagram'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE members ADD COLUMN couple_instagram VARCHAR(255) NOT NULL DEFAULT '';
    END IF;
END $$;

-- 4. Verificar estrutura após adição dos campos
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'members' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. Testar inserção com os novos campos
INSERT INTO members (
  name, 
  phone, 
  instagram, 
  city, 
  sector, 
  referrer,
  couple_name,
  couple_phone,
  couple_instagram,
  registration_date, 
  status
) VALUES (
  'Teste Usuario',
  '(62) 99999-9999',
  '@teste',
  'Goiânia',
  'Educação',
  'Admin',
  'Teste Casal',
  '(62) 88888-8888',
  '@testecasal',
  CURRENT_DATE,
  'Ativo'
);

-- 6. Verificar se foi inserido
SELECT * FROM members WHERE name = 'Teste Usuario';

-- 7. Limpar dados de teste
DELETE FROM members WHERE name = 'Teste Usuario';
