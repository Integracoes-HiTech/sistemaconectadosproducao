import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_vereador_connect'
};

async function checkMemberData() {
  let connection;
  
  try {
    console.log('🔍 Conectando ao banco de dados...');
    connection = await mysql.createConnection(dbConfig);
    
    console.log('📋 Verificando dados dos membros...');
    const [rows] = await connection.execute(`
      SELECT 
        id, 
        name, 
        ranking_status, 
        referrer, 
        contracts_completed,
        ranking_position
      FROM members 
      WHERE deleted_at IS NULL 
      ORDER BY id DESC 
      LIMIT 5
    `);
    
    console.log('\n📊 Dados dos membros:');
    console.table(rows);
    
    // Verificar se há caracteres estranhos
    console.log('\n🔍 Verificando caracteres especiais:');
    rows.forEach(member => {
      console.log(`Membro ${member.id} (${member.name}):`);
      console.log(`  - ranking_status: "${member.ranking_status}" (length: ${member.ranking_status?.length})`);
      console.log(`  - referrer: "${member.referrer}" (length: ${member.referrer?.length})`);
      
      // Verificar se há caracteres não visíveis
      if (member.ranking_status) {
        const statusChars = member.ranking_status.split('').map((char, i) => ({
          char: char,
          code: char.charCodeAt(0),
          position: i
        }));
        console.log(`  - ranking_status chars:`, statusChars);
      }
      
      if (member.referrer) {
        const referrerChars = member.referrer.split('').map((char, i) => ({
          char: char,
          code: char.charCodeAt(0),
          position: i
        }));
        console.log(`  - referrer chars:`, referrerChars);
      }
    });
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkMemberData();
