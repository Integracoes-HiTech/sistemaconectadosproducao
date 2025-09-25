// check-deleted-at.js - Script para verificar se o campo deleted_at foi criado
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  charset: 'utf8mb4',
  timezone: 'Z'
};

async function checkDeletedAt() {
  let connection;
  
  try {
    console.log('🔌 Conectando ao MySQL...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao MySQL com sucesso!');

    // Verificar estrutura da tabela members
    console.log('\n📋 Estrutura da tabela members:');
    const [membersColumns] = await connection.execute('SHOW COLUMNS FROM members');
    membersColumns.forEach(col => {
      console.log(`  ${col.Field}: ${col.Type} ${col.Null === 'YES' ? 'NULL' : 'NOT NULL'} ${col.Default ? `DEFAULT ${col.Default}` : ''}`);
    });

    // Verificar estrutura da tabela friends
    console.log('\n📋 Estrutura da tabela friends:');
    const [friendsColumns] = await connection.execute('SHOW COLUMNS FROM friends');
    friendsColumns.forEach(col => {
      console.log(`  ${col.Field}: ${col.Type} ${col.Null === 'YES' ? 'NULL' : 'NOT NULL'} ${col.Default ? `DEFAULT ${col.Default}` : ''}`);
    });

    // Testar query com deleted_at
    console.log('\n🧪 Testando query com deleted_at:');
    try {
      const [members] = await connection.execute('SELECT COUNT(*) as total FROM members WHERE deleted_at IS NULL');
      console.log(`✅ Query members funcionou: ${members[0].total} registros`);
    } catch (error) {
      console.log(`❌ Erro na query members: ${error.message}`);
    }

    try {
      const [friends] = await connection.execute('SELECT COUNT(*) as total FROM friends WHERE deleted_at IS NULL');
      console.log(`✅ Query friends funcionou: ${friends[0].total} registros`);
    } catch (error) {
      console.log(`❌ Erro na query friends: ${error.message}`);
    }
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Conexão encerrada');
    }
  }
}

checkDeletedAt();
