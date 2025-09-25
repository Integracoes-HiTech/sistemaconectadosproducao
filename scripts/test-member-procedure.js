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

async function testMemberProcedure() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao banco de dados');

    // Primeiro, inserir um membro de teste
    console.log('\n📝 Inserindo membro de teste...');
    const memberData = {
      name: 'Antonio Netto',
      phone: '11999884455',
      instagram: '@antonio_nett02',
      city: 'São Paulo',
      sector: 'Centro',
      referrer: 'Admin',
      registration_date: new Date().toISOString().split('T')[0],
      status: 'Ativo',
      couple_name: 'Maria Silva',
      couple_phone: '11999884456',
      couple_instagram: '@maria_silva',
      couple_city: 'São Paulo',
      couple_sector: 'Centro',
      contracts_completed: 0,
      ranking_status: 'Vermelho',
      is_top_1500: false,
      can_be_replaced: false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const insertResult = await connection.execute(
      'INSERT INTO members (name, phone, instagram, city, sector, referrer, registration_date, status, couple_name, couple_phone, couple_instagram, couple_city, couple_sector, contracts_completed, ranking_status, is_top_1500, can_be_replaced, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        memberData.name,
        memberData.phone,
        memberData.instagram,
        memberData.city,
        memberData.sector,
        memberData.referrer,
        memberData.registration_date,
        memberData.status,
        memberData.couple_name,
        memberData.couple_phone,
        memberData.couple_instagram,
        memberData.couple_city,
        memberData.couple_sector,
        memberData.contracts_completed,
        memberData.ranking_status,
        memberData.is_top_1500,
        memberData.can_be_replaced,
        memberData.created_at,
        memberData.updated_at
      ]
    );

    const memberId = insertResult[0].insertId;
    console.log(`✅ Membro inserido com ID: ${memberId}`);

    // Testar a procedure
    console.log('\n🚀 Testando procedure create_user_from_member...');
    
    try {
      // Chamar a procedure
      await connection.execute(
        'CALL create_user_from_member(?, @username, @password, @user_id, @success, @message)',
        [memberId]
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
        console.log(`📱 Instagram original: ${memberData.instagram}`);
        console.log(`📞 Telefone original: ${memberData.phone}`);
        
        // Verificar se as credenciais estão corretas
        const expectedUsername = 'antonionett02';
        const expectedPassword = 'antonionett024455';
        
        console.log('\n🔍 Verificando credenciais:');
        console.log(`✅ Username esperado: ${expectedUsername}`);
        console.log(`✅ Username gerado: ${result.username}`);
        console.log(`✅ Password esperado: ${expectedPassword}`);
        console.log(`✅ Password gerado: ${result.password}`);
        
        if (result.username === expectedUsername && result.password === expectedPassword) {
          console.log('🎉 Credenciais estão corretas!');
        } else {
          console.log('⚠️ Credenciais não coincidem com o esperado');
        }
      } else {
        console.log('❌ Procedure falhou:', result.message);
      }

    } catch (error) {
      console.error('❌ Erro ao testar procedure:', error.message);
    }

    console.log('\n🎉 Teste concluído!');

  } catch (error) {
    console.error('❌ Erro geral:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

testMemberProcedure().catch(console.error);
