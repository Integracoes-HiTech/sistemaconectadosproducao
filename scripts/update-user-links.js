// Script para atualizar tabela user_links no banco de dados
const { createClient } = require('@supabase/supabase-js');

// Configuração do Supabase (use suas credenciais)
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseKey = 'your-anon-key';

const supabase = createClient(supabaseUrl, supabaseKey);

async function updateUserLinks() {
  try {
    console.log('🔍 Iniciando atualização da tabela user_links...');

    // 1. Verificar configuração atual do sistema
    console.log('\n📋 1. Verificando configuração atual...');
    const { data: settings, error: settingsError } = await supabase
      .from('system_settings')
      .select('setting_value')
      .eq('setting_key', 'member_links_type')
      .single();

    if (settingsError) {
      console.error('❌ Erro ao buscar configuração:', settingsError);
      return;
    }

    const currentSetting = settings.setting_value;
    console.log(`✅ Configuração atual: ${currentSetting}`);

    // 2. Verificar estado atual dos links
    console.log('\n📊 2. Verificando estado atual dos links...');
    const { data: currentLinks, error: currentError } = await supabase
      .from('user_links')
      .select('link_type, user_id')
      .neq('user_id', 'admin');

    if (currentError) {
      console.error('❌ Erro ao buscar links atuais:', currentError);
      return;
    }

    const linksByType = currentLinks.reduce((acc, link) => {
      acc[link.link_type] = (acc[link.link_type] || 0) + 1;
      return acc;
    }, {});

    console.log('📈 Links atuais:', linksByType);

    // 3. Verificar links do admin
    console.log('\n👑 3. Verificando links do admin...');
    const { data: adminLinks, error: adminError } = await supabase
      .from('user_links')
      .select('link_type')
      .eq('user_id', 'admin');

    if (adminError) {
      console.error('❌ Erro ao buscar links do admin:', adminError);
      return;
    }

    console.log(`👑 Admin tem ${adminLinks.length} links do tipo: ${adminLinks[0]?.link_type || 'N/A'}`);

    // 4. Atualizar links baseado na configuração
    console.log('\n🔄 4. Atualizando links...');
    
    let updateResult;
    if (currentSetting === 'friends') {
      // Atualizar todos os links 'members' para 'friends' (exceto admin)
      updateResult = await supabase
        .from('user_links')
        .update({ 
          link_type: 'friends',
          updated_at: new Date().toISOString()
        })
        .eq('link_type', 'members')
        .neq('user_id', 'admin');
      
      console.log('✅ Atualizando links de MEMBERS para FRIENDS (exceto admin)');
      
    } else if (currentSetting === 'members') {
      // Atualizar todos os links 'friends' para 'members' (exceto admin)
      updateResult = await supabase
        .from('user_links')
        .update({ 
          link_type: 'members',
          updated_at: new Date().toISOString()
        })
        .eq('link_type', 'friends')
        .neq('user_id', 'admin');
      
      console.log('✅ Atualizando links de FRIENDS para MEMBERS (exceto admin)');
      
    } else {
      console.log('⚠️ Configuração não reconhecida:', currentSetting);
      return;
    }

    if (updateResult.error) {
      console.error('❌ Erro ao atualizar links:', updateResult.error);
      return;
    }

    console.log(`✅ ${updateResult.count || 0} links atualizados com sucesso!`);

    // 5. Verificar resultado após atualização
    console.log('\n📊 5. Verificando resultado após atualização...');
    const { data: updatedLinks, error: updatedError } = await supabase
      .from('user_links')
      .select('link_type, user_id');

    if (updatedError) {
      console.error('❌ Erro ao verificar links atualizados:', updatedError);
      return;
    }

    const updatedLinksByType = updatedLinks.reduce((acc, link) => {
      acc[link.link_type] = (acc[link.link_type] || 0) + 1;
      return acc;
    }, {});

    console.log('📈 Links após atualização:', updatedLinksByType);

    // 6. Verificar se admin permaneceu como 'members'
    const adminLinksAfter = updatedLinks.filter(link => link.user_id === 'admin');
    console.log(`👑 Admin após atualização: ${adminLinksAfter.length} links do tipo: ${adminLinksAfter[0]?.link_type || 'N/A'}`);

    // 7. Resumo final
    console.log('\n🎯 RESUMO FINAL:');
    console.log(`📋 Configuração do sistema: ${currentSetting}`);
    console.log(`🔄 Links atualizados: ${updateResult.count || 0}`);
    console.log(`👑 Admin protegido: ${adminLinksAfter[0]?.link_type === 'members' ? 'SIM' : 'NÃO'}`);
    console.log(`✅ Atualização concluída com sucesso!`);

  } catch (error) {
    console.error('❌ Erro geral:', error);
  }
}

// Executar o script
updateUserLinks();
