-- ====================================================
-- SUPABASE: INSERIR USUÁRIO FELIPE ADMIN
-- Descrição: Script para executar no SQL Editor do Supabase
-- URL: https://hihvewjyfjcwhjoerule.supabase.co
-- ====================================================

-- 1. Verificar se usuário já existe
SELECT 
    'VERIFICANDO USUÁRIO EXISTENTE...' as status,
    COUNT(*) as usuarios_felipe_existentes
FROM auth_users 
WHERE username = 'felipe';

-- 2. Inserir ou atualizar usuário Felipe Admin
INSERT INTO auth_users (
    id,
    username, 
    password, 
    name, 
    role, 
    full_name, 
    display_name,
    instagram,
    is_active,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'felipe',
    'felipe123',  -- ⚠️ ALTERAR APÓS PRIMEIRO LOGIN
    'Felipe',
    'Felipe Admin',
    'Felipe Admin',
    'Felipe Admin',
    'felipe_admin',
    true,
    now(),
    now()
)
ON CONFLICT (username) 
DO UPDATE SET
    role = 'Felipe Admin',
    display_name = 'Felipe Admin',
    full_name = 'Felipe Admin',
    is_active = true,
    updated_at = now();

-- 3. Verificar se foi criado/atualizado
SELECT 
    '✅ USUÁRIO CRIADO/ATUALIZADO' as status,
    id,
    username,
    name,
    role,
    display_name,
    is_active,
    created_at,
    updated_at
FROM auth_users 
WHERE username = 'felipe';

-- 4. Verificar total de administradores
SELECT 
    '📊 RESUMO ADMINISTRADORES' as status,
    role,
    COUNT(*) as total
FROM auth_users 
WHERE role IN ('admin', 'Administrador', 'Felipe Admin')
GROUP BY role
ORDER BY role;
