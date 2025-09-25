import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_vereador_connect'
};

async function checkFriendsTable() {
  let connection;
  
  try {
    console.log('🔍 Conectando ao banco de dados...');
    connection = await mysql.createConnection(dbConfig);
    
    console.log('📋 Verificando estrutura da tabela friends...');
    const [rows] = await connection.execute('DESCRIBE friends');
    
    console.log('\n📊 Estrutura da tabela friends:');
    console.table(rows);
    
    console.log('\n🔢 Total de colunas:', rows.length);
    
    // Mostrar apenas os nomes das colunas
    const columnNames = rows.map(row => row.Field);
    console.log('\n📝 Nomes das colunas:');
    console.log(columnNames.join(', '));
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkFriendsTable();
