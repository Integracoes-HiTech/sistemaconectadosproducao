// Script para verificar estrutura da tabela members
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

async function checkTableStructure() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao banco de dados');

    // Verificar estrutura da tabela members
    const [columns] = await connection.execute('SHOW COLUMNS FROM members');
    console.log('\n📋 Estrutura da tabela members:');
    columns.forEach(col => {
      console.log(`   ${col.Field} (${col.Type})`);
    });

  } catch (error) {
    console.error('❌ Erro ao verificar estrutura:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

checkTableStructure().catch(console.error);
