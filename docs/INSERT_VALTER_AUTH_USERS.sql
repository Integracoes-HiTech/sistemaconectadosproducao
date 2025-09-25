-- INSERT ESPECÍFICO PARA VALTER GOMES DA SILVA NA TABELA AUTH_USERS
-- Baseado nos dados da tabela users

INSERT INTO auth_users (
  id,
  username,
  password,
  name,
  role,
  full_name,
  instagram,
  phone,
  is_active,
  created_at,
  updated_at
) VALUES (
  '3918e18a-3078-4705-85b9-cf0dd29e5b7b',  -- Mesmo ID do users
  'maestrovaltergomes',                      -- Username baseado no Instagram (sem @)
  'senha123',                                -- Senha padrão (pode ser alterada depois)
  'Valter Gomes da Silva',                   -- Nome completo
  'Membro',                                  -- Role (ajustar conforme necessário)
  'Valter Gomes da Silva - Membro',         -- Full name com role
  'Maestrovaltergomes',                     -- Instagram (sem @)
  '(62) 99362-8028',                        -- Telefone
  false,                                     -- Inativo (baseado no status 'Inativo' do users)
  '2025-09-13 01:57:33.609612+00',         -- Mesma data de criação
  '2025-09-13 01:57:33.609612+00'          -- Mesma data de atualização
);

-- Verificar se foi inserido corretamente
SELECT 
  id,
  username,
  name,
  role,
  full_name,
  instagram,
  phone,
  is_active,
  created_at
FROM auth_users 
WHERE id = '3918e18a-3078-4705-85b9-cf0dd29e5b7b';
