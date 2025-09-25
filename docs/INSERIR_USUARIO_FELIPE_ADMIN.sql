-- ====================================================
-- SCRIPT: INSERIR USUÁRIO FELIPE ADMIN
-- Descrição: Cria o usuário Felipe com perfil de administrador especial
-- Data: 2024
-- ====================================================

-- Verificar se o usuário já existe
DO $$
BEGIN
    -- Verificar se já existe usuário com username 'felipe'
    IF EXISTS (SELECT 1 FROM auth_users WHERE username = 'felipe') THEN
        RAISE NOTICE '⚠️  Usuário felipe já existe. Atualizando permissões...';
        
        -- Atualizar usuário existente para Felipe Admin
        UPDATE auth_users 
        SET 
            role = 'Felipe Admin',
            display_name = 'Felipe Admin',
            is_active = true,
            updated_at = NOW()
        WHERE username = 'felipe';
        
        RAISE NOTICE '✅ Usuário felipe atualizado para Felipe Admin';
    ELSE
        RAISE NOTICE '📝 Criando novo usuário Felipe Admin...';
        
        -- Inserir novo usuário Felipe Admin
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
            'felipe123',  -- Senha padrão (alterar após primeiro login)
            'Felipe',
            'Felipe Admin',
            'Felipe Admin',
            'Felipe Admin',
            'felipe_admin',
            true,
            NOW(),
            NOW()
        );
        
        RAISE NOTICE '✅ Usuário Felipe Admin criado com sucesso';
    END IF;
END
$$;

-- Verificar se foi criado/atualizado corretamente
SELECT 
    id,
    username,
    name,
    role,
    display_name,
    is_active,
    created_at
FROM auth_users 
WHERE username = 'felipe';

-- Exibir informações de login
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔐 CREDENCIAIS DE ACESSO:';
    RAISE NOTICE '👤 Usuário: felipe';
    RAISE NOTICE '🔑 Senha: felipe123';
    RAISE NOTICE '📋 Perfil: Felipe Admin';
    RAISE NOTICE '';
    RAISE NOTICE '✅ PERMISSÕES CONCEDIDAS:';
    RAISE NOTICE '   • Ver dashboard completo';
    RAISE NOTICE '   • Acessar estatísticas e relatórios';
    RAISE NOTICE '   • Exportar tabelas (Excel/PDF)';
    RAISE NOTICE '   • Gerar links de cadastro';
    RAISE NOTICE '   • Ver todos os usuários';
    RAISE NOTICE '';
    RAISE NOTICE '❌ PERMISSÕES RESTRITAS:';
    RAISE NOTICE '   • Excluir usuários (membros/amigos)';
    RAISE NOTICE '   • Alterar tipos de links';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANTE: Altere a senha no primeiro login!';
END
$$;
