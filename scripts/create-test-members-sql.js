// Script para criar membros de teste diretamente no banco
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

async function createTestMembers() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao banco de dados');

    // Primeiro, vamos ver quantos membros existem
    const [countResult] = await connection.execute('SELECT COUNT(*) as count FROM members WHERE deleted_at IS NULL');
    const currentCount = countResult[0].count;
    console.log(`📊 Membros atuais: ${currentCount}`);

    // Criar 5 membros de teste
    console.log('🎯 Criando 5 membros de teste...');

    for (let i = 1; i <= 5; i++) {
      const query = `
        INSERT INTO members (
          name, phone, instagram, city, sector, referrer, registration_date, 
          status, couple_name, couple_phone, couple_instagram, 
          contracts_completed, ranking_status, is_top_1500, can_be_replaced, 
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;

      const values = [
        `Membro Teste ${i}`,
        `1199999${String(i).padStart(4, '0')}`,
        `@membro_teste_${i}`,
        'São Paulo',
        'Teste',
        'Admin',
        new Date().toISOString().split('T')[0],
        'Ativo',
        `Dupla Teste ${i}`,
        `1198888${String(i).padStart(4, '0')}`,
        `@dupla_teste_${i}`,
        0,
        'Vermelho',
        false,
        false,
        new Date().toISOString(),
        new Date().toISOString()
      ];

      await connection.execute(query, values);
      console.log(`✅ Membro ${i} criado com sucesso!`);
    }

    // Verificar contagem final
    const [finalCount] = await connection.execute('SELECT COUNT(*) as count FROM members WHERE deleted_at IS NULL');
    console.log(`🎉 Total de membros após criação: ${finalCount[0].count}`);

    // Testar as funções de fase
    console.log('\n🧪 Testando funções de fase...');
    
    const [shouldActivate] = await connection.execute('SELECT should_activate_paid_contracts_phase() as should_activate');
    console.log('📊 Deve ativar fase:', shouldActivate[0].should_activate);
    
    const [phaseStatus] = await connection.execute('SELECT get_phase_status() as status');
    console.log('📋 Status da fase:', JSON.parse(phaseStatus[0].status));

  } catch (error) {
    console.error('❌ Erro durante a criação dos membros:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

createTestMembers().catch(console.error);
