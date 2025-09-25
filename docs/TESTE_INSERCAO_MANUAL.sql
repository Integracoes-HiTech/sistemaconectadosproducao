-- =====================================================
-- TESTE DE INSERÇÃO MANUAL NA TABELA MEMBERS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- Teste 1: Inserção básica
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

-- Verificar se foi inserido
SELECT * FROM members WHERE name = 'Teste Usuario';

-- Limpar dados de teste
DELETE FROM members WHERE name = 'Teste Usuario';

-- Teste 2: Verificar se todos os campos obrigatórios estão sendo fornecidos
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
  status,
  contracts_completed,
  ranking_status,
  is_top_1500,
  can_be_replaced
) VALUES (
  'Teste Completo',
  '(62) 77777-7777',
  '@testecompleto',
  'Goiânia',
  'Educação',
  'Admin',
  'Teste Casal Completo',
  '(62) 66666-6666',
  '@testecasalcompleto',
  CURRENT_DATE,
  'Ativo',
  0,
  'Vermelho',
  false,
  false
);

-- Verificar inserção
SELECT * FROM members WHERE name = 'Teste Completo';

-- Limpar dados de teste
DELETE FROM members WHERE name = 'Teste Completo';
