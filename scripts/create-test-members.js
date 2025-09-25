// Script para criar membros de teste para simular limite de 1500
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

    // Criar apenas alguns membros para demonstrar a funcionalidade
    const membersToCreate = Math.min(5, 1500 - currentCount);
    console.log(`🎯 Criando ${membersToCreate} membros de teste para demonstração...`);

    if (membersToCreate <= 0) {
      console.log('✅ Já temos membros suficientes!');
      return;
    }

    // Criar membros em lotes de 100 para não sobrecarregar
    const batchSize = 100;
    const batches = Math.ceil(membersToCreate / batchSize);

    for (let batch = 0; batch < batches; batch++) {
      const membersInThisBatch = Math.min(batchSize, membersToCreate - (batch * batchSize));
      console.log(`📦 Criando lote ${batch + 1}/${batches} com ${membersInThisBatch} membros...`);

      const values = [];
      for (let i = 0; i < membersInThisBatch; i++) {
        const memberNumber = (batch * batchSize) + i + 1;
        values.push([
          `Membro Teste ${memberNumber}`,
          `1199999${String(memberNumber).padStart(4, '0')}`,
          `@membro_teste_${memberNumber}`,
          'São Paulo',
          'Teste',
          'Admin',
          new Date().toISOString().split('T')[0],
          'Ativo',
          `Dupla Teste ${memberNumber}`,
          `1198888${String(memberNumber).padStart(4, '0')}`,
          `@dupla_teste_${memberNumber}`,
          'São Paulo',
          'Teste',
          0,
          'Vermelho',
          false,
          false,
          new Date().toISOString(),
          new Date().toISOString()
        ]);
      }

      // Criar membros um por um para evitar problemas de sintaxe
      for (const memberData of values) {
        const query = `
          INSERT INTO members (
            name, phone, instagram, city, sector, referrer, registration_date, 
            status, couple_name, couple_phone, couple_instagram, couple_city, 
            couple_sector, contracts_completed, ranking_status, is_top_1500, 
            can_be_replaced, created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        await connection.execute(query, memberData);
      }
      console.log(`✅ Lote ${batch + 1} criado com sucesso!`);
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
