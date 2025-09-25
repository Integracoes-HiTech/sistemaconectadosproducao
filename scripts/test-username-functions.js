import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  port: process.env.DB_PORT || 3306
};

async function testUsernameFunctions() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao banco de dados');

    // Testar função generate_unique_username
    console.log('\n🧪 Testando função generate_unique_username...');
    
    const testCases = [
      '@antonio_nett02',
      '@maria_silva',
      '@joao123',
      '@test_user',
      '@antonio_nett02' // Teste de duplicata
    ];

    for (const instagram of testCases) {
      try {
        const [result] = await connection.execute(
          'SELECT generate_unique_username(?) as username',
          [instagram]
        );
        console.log(`📱 Instagram: ${instagram} → Username: ${result[0].username}`);
      } catch (error) {
        console.error(`❌ Erro ao testar ${instagram}:`, error.message);
      }
    }

    // Testar função generate_password
    console.log('\n🔐 Testando função generate_password...');
    
    const passwordTests = [
      { instagram: '@antonio_nett02', phone: '11999884455' },
      { instagram: '@maria_silva', phone: '21987654321' },
      { instagram: '@joao123', phone: '85912345678' }
    ];

    for (const test of passwordTests) {
      try {
        const [result] = await connection.execute(
          'SELECT generate_password(?, ?) as password',
          [test.instagram, test.phone]
        );
        console.log(`📱 ${test.instagram} + ${test.phone} → Password: ${result[0].password}`);
      } catch (error) {
        console.error(`❌ Erro ao testar password:`, error.message);
      }
    }

    // Testar procedure completa
    console.log('\n🚀 Testando procedure create_user_with_unique_credentials...');
    
    try {
      // Chamar a procedure
      await connection.execute(
        'CALL create_user_with_unique_credentials(?, ?, ?, ?, ?, ?, @username, @password, @user_id, @success, @message)',
        ['Teste Usuario', '@teste_procedure', '11999887766', 'Admin', 'Membro', 'Teste Usuario - Membro']
      );

      // Buscar resultados
      const [output] = await connection.execute(
        'SELECT @username as username, @password as password, @user_id as user_id, @success as success, @message as message'
      );

      const result = output[0];
      console.log('📊 Resultado da procedure:', result);

      if (result.success) {
        console.log('✅ Procedure executada com sucesso!');
        console.log(`👤 Username: ${result.username}`);
        console.log(`🔑 Password: ${result.password}`);
        console.log(`🆔 User ID: ${result.user_id}`);
      } else {
        console.log('❌ Procedure falhou:', result.message);
      }

    } catch (error) {
      console.error('❌ Erro ao testar procedure:', error.message);
    }

    console.log('\n🎉 Testes concluídos!');

  } catch (error) {
    console.error('❌ Erro geral:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

testUsernameFunctions().catch(console.error);
