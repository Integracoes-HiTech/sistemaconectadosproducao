// ====================================================
// SCRIPT: CRIAR USUÁRIO FELIPE ADMIN
// Descrição: Script Node.js para criar usuário Felipe Admin via Supabase
// ====================================================

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://hihvewjyfjcwhjoerule.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpaHZld2p5Zmpjd2hqb2VydWxlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzU1MTAyMCwiZXhwIjoyMDczMTI3MDIwfQ.VupFTs1imopXgiIfuWFjRAq2KutaLmpuNOGX9NqCER8';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function criarFelipeAdmin() {
    try {
        console.log('🔍 Verificando se usuário felipe já existe...');
        
        // Verificar se usuário já existe
        const { data: existingUser, error: checkError } = await supabase
            .from('auth_users')
            .select('*')
            .eq('username', 'felipe')
            .single();

        if (existingUser) {
            console.log('⚠️  Usuário felipe já existe. Atualizando permissões...');
            
            // Atualizar usuário existente
            const { data: updatedUser, error: updateError } = await supabase
                .from('auth_users')
                .update({
                    role: 'Felipe Admin',
                    display_name: 'Felipe Admin',
                    full_name: 'Felipe Admin',
                    is_active: true,
                    updated_at: new Date().toISOString()
                })
                .eq('username', 'felipe')
                .select()
                .single();

            if (updateError) {
                throw updateError;
            }

            console.log('✅ Usuário felipe atualizado para Felipe Admin');
            console.log('📋 Dados atualizados:', updatedUser);
        } else {
            console.log('📝 Criando novo usuário Felipe Admin...');
            
            // Criar novo usuário
            const { data: newUser, error: insertError } = await supabase
                .from('auth_users')
                .insert({
                    username: 'felipe',
                    password: 'felipe123',  // Senha padrão
                    name: 'Felipe',
                    role: 'Felipe Admin',
                    full_name: 'Felipe Admin',
                    display_name: 'Felipe Admin',
                    instagram: 'felipe_admin',
                    is_active: true,
                    created_at: new Date().toISOString(),
                    updated_at: new Date().toISOString()
                })
                .select()
                .single();

            if (insertError) {
                throw insertError;
            }

            console.log('✅ Usuário Felipe Admin criado com sucesso');
            console.log('📋 Dados criados:', newUser);
        }

        // Verificar resultado final
        const { data: finalUser, error: finalError } = await supabase
            .from('auth_users')
            .select('*')
            .eq('username', 'felipe')
            .single();

        if (finalError) {
            throw finalError;
        }

        console.log('\n🎉 USUÁRIO FELIPE ADMIN CONFIGURADO!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('🔐 CREDENCIAIS DE ACESSO:');
        console.log('👤 Usuário: felipe');
        console.log('🔑 Senha: felipe123');
        console.log('📋 Perfil: Felipe Admin');
        console.log('🆔 ID:', finalUser.id);
        console.log('📅 Criado em:', finalUser.created_at);
        console.log('\n✅ PERMISSÕES CONCEDIDAS:');
        console.log('   • Ver dashboard completo');
        console.log('   • Acessar estatísticas e relatórios');
        console.log('   • Exportar tabelas (Excel/PDF)');
        console.log('   • Gerar links de cadastro');
        console.log('   • Ver todos os usuários');
        console.log('\n❌ PERMISSÕES RESTRITAS:');
        console.log('   • Excluir usuários (membros/amigos)');
        console.log('   • Alterar tipos de links');
        console.log('\n⚠️  IMPORTANTE: Altere a senha no primeiro login!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    } catch (error) {
        console.error('❌ Erro ao criar usuário Felipe Admin:', error);
        
        if (error.message.includes('duplicate key')) {
            console.log('\n💡 SOLUÇÃO: O usuário já existe. Tente fazer login com:');
            console.log('👤 Usuário: felipe');
            console.log('🔑 Senha: felipe123');
        }
    }
}

// Executar script
criarFelipeAdmin();
