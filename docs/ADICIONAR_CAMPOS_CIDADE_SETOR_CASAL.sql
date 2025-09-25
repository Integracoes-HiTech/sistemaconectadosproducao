-- Script para adicionar campos de cidade e setor da segunda pessoa na tabela members
-- Execute este script no Supabase SQL Editor

-- Adicionar campos de cidade e setor da segunda pessoa
ALTER TABLE members 
ADD COLUMN IF NOT EXISTS couple_city VARCHAR(255),
ADD COLUMN IF NOT EXISTS couple_sector VARCHAR(255);

-- Comentários para documentação
COMMENT ON COLUMN members.couple_city IS 'Cidade da segunda pessoa do casal';
COMMENT ON COLUMN members.couple_sector IS 'Setor da segunda pessoa do casal';

-- Atualizar registros existentes (opcional - apenas se necessário)
-- UPDATE members 
-- SET couple_city = city, couple_sector = sector 
-- WHERE couple_city IS NULL OR couple_sector IS NULL;

-- Verificar se os campos foram adicionados corretamente
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'members' 
AND column_name IN ('couple_city', 'couple_sector')
ORDER BY column_name;
