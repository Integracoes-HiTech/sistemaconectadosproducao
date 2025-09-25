// Script para testar a nova função MySQL de geração de links únicos
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

// Configuração do banco (ajuste conforme necessário)
const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  charset: 'utf8mb4',
  timezone: 'Z',
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true,
  connectionLimit: 10
};

async function testMySQLFunctions() {
  let connection;
  
  try {
    console.log('🔗 Conectando ao banco MySQL...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado com sucesso!');

    // Teste 1: Verificar se as funções existem
    console.log('\n📋 1. Verificando se as funções foram criadas...');
    
    const [functions] = await connection.execute(`
      SELECT ROUTINE_NAME, ROUTINE_TYPE 
      FROM information_schema.ROUTINES 
      WHERE ROUTINE_SCHEMA = ? 
      AND ROUTINE_NAME LIKE '%link%'
    `, [dbConfig.database]);
    
    console.log('🔍 Funções encontradas:', functions);
    
    if (functions.length === 0) {
      console.log('❌ Nenhuma função encontrada. Execute primeiro o script create-mysql-functions.js');
      return;
    }

    // Teste 2: Testar função generate_unique_link
    console.log('\n🧪 2. Testando função generate_unique_link...');
    
    try {
      const [result1] = await connection.execute('SELECT generate_unique_link(?) as link1', ['teste']);
      const [result2] = await connection.execute('SELECT generate_unique_link(?) as link2', ['teste']);
      
      console.log('✅ Link 1 gerado:', result1[0].link1);
      console.log('✅ Link 2 gerado:', result2[0].link2);
      
      if (result1[0].link1 !== result2[0].link2) {
        console.log('✅ Função gera links únicos corretamente!');
      } else {
        console.log('❌ Função gerou links idênticos!');
      }
    } catch (error) {
      console.log('❌ Erro ao testar função:', error.message);
    }

    // Teste 3: Testar procedure get_or_generate_user_link
    console.log('\n🧪 3. Testando procedure get_or_generate_user_link...');
    
    try {
      // Primeira chamada - deve gerar novo link
      console.log('🔄 Primeira chamada (deve gerar novo link)...');
      await connection.execute(`
        CALL get_or_generate_user_link('999', 'usuario_teste', 'members', @link_id, @is_existing, @success, @message)
      `);
      
      const [output1] = await connection.execute(`
        SELECT @link_id as link_id, @is_existing as is_existing, @success as success, @message as message
      `);
      
      console.log('📋 Resultado primeira chamada:', output1[0]);
      
      // Segunda chamada - deve retornar link existente
      console.log('🔄 Segunda chamada (deve retornar link existente)...');
      await connection.execute(`
        CALL get_or_generate_user_link('999', 'usuario_teste', 'members', @link_id, @is_existing, @success, @message)
      `);
      
      const [output2] = await connection.execute(`
        SELECT @link_id as link_id, @is_existing as is_existing, @success as success, @message as message
      `);
      
      console.log('📋 Resultado segunda chamada:', output2[0]);
      
      // Verificar se os links são iguais
      if (output1[0].link_id === output2[0].link_id) {
        console.log('✅ Procedure retorna link existente corretamente!');
      } else {
        console.log('❌ Procedure não está retornando link existente!');
      }
      
      // Verificar se is_existing está correto
      if (output1[0].is_existing === 0 && output2[0].is_existing === 1) {
        console.log('✅ Flag is_existing está correta!');
      } else {
        console.log('❌ Flag is_existing incorreta!');
      }
      
    } catch (error) {
      console.log('❌ Erro ao testar procedure:', error.message);
    }

    // Teste 4: Verificar dados na tabela
    console.log('\n📊 4. Verificando dados na tabela user_links...');
    
    const [links] = await connection.execute(`
      SELECT link_id, user_id, link_type, is_active, created_at 
      FROM user_links 
      WHERE user_id = '999' 
      ORDER BY created_at DESC
    `);
    
    console.log('📋 Links do usuário teste:', links);
    
    // Verificar se há apenas um link ativo
    const activeLinks = links.filter(link => link.is_active === 1);
    if (activeLinks.length === 1) {
      console.log('✅ Apenas um link ativo por usuário!');
    } else {
      console.log(`❌ ${activeLinks.length} links ativos encontrados!`);
    }

    // Teste 5: Testar API endpoint (simulação)
    console.log('\n🌐 5. Simulando chamada da API...');
    
    // Simular o que a API faria
    const userId = '999';
    const userName = 'usuario_teste';
    
    // Buscar configurações
    const [settings] = await connection.execute('SELECT setting_key, setting_value FROM system_settings');
    const settingsData = { member_links_type: 'members' };
    
    settings.forEach(item => {
      if (item.setting_key === 'member_links_type') {
        settingsData.member_links_type = item.setting_value;
      }
    });
    
    // Chamar procedure
    await connection.execute(`
      CALL get_or_generate_user_link(?, ?, ?, @link_id, @is_existing, @success, @message)
    `, [userId, userName, settingsData.member_links_type]);
    
    const [apiResult] = await connection.execute(`
      SELECT @link_id as link_id, @is_existing as is_existing, @success as success, @message as message
    `);
    
    console.log('📋 Resultado simulação API:', apiResult[0]);
    
    // Simular resposta da API
    const apiResponse = {
      success: true,
      data: {
        link_id: apiResult[0].link_id,
        link_type: settingsData.member_links_type,
        full_url: `http://localhost:3001/register/${apiResult[0].link_id}`,
        is_existing: Boolean(apiResult[0].is_existing)
      }
    };
    
    console.log('📤 Resposta da API:', JSON.stringify(apiResponse, null, 2));

    console.log('\n✅ Todos os testes concluídos!');

  } catch (error) {
    console.error('❌ Erro durante os testes:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

// Executar testes
testMySQLFunctions().catch(console.error);
