// add-link-id-column.js - Script para adicionar coluna link_id na tabela user_links
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

async function addLinkIdColumn() {
  let connection;
  
  try {
    console.log('🔌 Conectando ao MySQL...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao MySQL com sucesso!');

    // Adicionar coluna link_id
    console.log('\n🔧 Adicionando coluna link_id...');
    try {
      await connection.execute(`
        ALTER TABLE user_links 
        ADD COLUMN link_id VARCHAR(255) NOT NULL UNIQUE AFTER id
      `);
      console.log('✅ Coluna link_id adicionada com sucesso!');
    } catch (error) {
      if (error.code === 'ER_DUP_FIELDNAME') {
        console.log('⚠️ Coluna link_id já existe');
      } else {
        throw error;
      }
    }

    // Adicionar coluna is_active se não existir
    console.log('\n🔧 Verificando coluna is_active...');
    try {
      await connection.execute(`
        ALTER TABLE user_links 
        ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE
      `);
      console.log('✅ Coluna is_active adicionada!');
    } catch (error) {
      if (error.code === 'ER_DUP_FIELDNAME') {
        console.log('⚠️ Coluna is_active já existe');
      } else {
        throw error;
      }
    }

    // Verificar estrutura final
    console.log('\n📋 Estrutura final da tabela user_links:');
    const [columns] = await connection.execute('SHOW COLUMNS FROM user_links');
    columns.forEach(col => {
      console.log(`  ${col.Field}: ${col.Type} ${col.Null === 'YES' ? 'NULL' : 'NOT NULL'} ${col.Default ? `DEFAULT ${col.Default}` : ''}`);
    });

    // Testar inserção
    console.log('\n🧪 Testando inserção...');
    const testLinkId = `test_link_${Date.now()}`;
    await connection.execute(
      'INSERT INTO user_links (link_id, user_id, link_type, is_active) VALUES (?, ?, ?, ?)',
      [testLinkId, '1', 'members', true]
    );
    console.log('✅ Inserção funcionou!');
    
    // Limpar dados de teste
    await connection.execute('DELETE FROM user_links WHERE link_id = ?', [testLinkId]);
    console.log('✅ Dados de teste removidos');
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Conexão encerrada');
    }
  }
}

addLinkIdColumn();
