// Script para testar com usuário real
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

async function testWithRealUser() {
  let connection;
  
  try {
    const dbConfig = {
      host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
      user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
      password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
      database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
      charset: 'utf8mb4',
      timezone: 'Z'
    };
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado!');

    // Buscar um usuário real
    const [users] = await connection.execute('SELECT id, username FROM auth_users LIMIT 1');
    
    if (users.length > 0) {
      const userId = users[0].id;
      const userName = users[0].username;
      
      console.log(`🧪 Testando com usuário real: ${userName} (ID: ${userId})`);
      
      // Testar procedure
      await connection.execute(`
        CALL get_or_generate_user_link(?, ?, 'members', @link_id, @is_existing, @success, @message)
      `, [userId, userName]);
      
      const [output] = await connection.execute(`
        SELECT @link_id as link_id, @is_existing as is_existing, @success as success, @message as message
      `);
      
      console.log('📋 Resultado:', output[0]);
      
      if (output[0].success) {
        console.log('✅ Procedure funcionando perfeitamente!');
        console.log(`🔗 Link gerado: ${output[0].link_id}`);
        console.log(`📊 É link existente: ${output[0].is_existing ? 'Sim' : 'Não'}`);
      }
      
      // Testar segunda chamada (deve retornar o mesmo link)
      console.log('\n🔄 Testando segunda chamada...');
      await connection.execute(`
        CALL get_or_generate_user_link(?, ?, 'members', @link_id, @is_existing, @success, @message)
      `, [userId, userName]);
      
      const [output2] = await connection.execute(`
        SELECT @link_id as link_id, @is_existing as is_existing, @success as success, @message as message
      `);
      
      console.log('📋 Resultado segunda chamada:', output2[0]);
      
      if (output[0].link_id === output2[0].link_id) {
        console.log('✅ Retorna o mesmo link existente!');
      }
      
    } else {
      console.log('❌ Nenhum usuário encontrado na tabela auth_users');
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

testWithRealUser().catch(console.error);
