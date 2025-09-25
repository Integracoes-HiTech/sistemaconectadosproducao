// check-user-links-table.js - Script para verificar/criar tabela user_links
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

async function checkUserLinksTable() {
  let connection;
  
  try {
    console.log('🔌 Conectando ao MySQL...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao MySQL com sucesso!');

    // Verificar se a tabela user_links existe
    console.log('\n📋 Verificando tabela user_links...');
    try {
      const [columns] = await connection.execute('SHOW COLUMNS FROM user_links');
      console.log('✅ Tabela user_links existe!');
      console.log('📊 Colunas encontradas:');
      columns.forEach(col => {
        console.log(`  ${col.Field}: ${col.Type} ${col.Null === 'YES' ? 'NULL' : 'NOT NULL'} ${col.Default ? `DEFAULT ${col.Default}` : ''}`);
      });
    } catch (error) {
      if (error.code === 'ER_NO_SUCH_TABLE') {
        console.log('❌ Tabela user_links não existe. Criando...');
        
        // Criar tabela user_links
        await connection.execute(`
          CREATE TABLE user_links (
            id INT AUTO_INCREMENT PRIMARY KEY,
            link_id VARCHAR(255) NOT NULL UNIQUE,
            user_id VARCHAR(255) NOT NULL,
            link_type ENUM('members', 'friends') NOT NULL DEFAULT 'members',
            is_active BOOLEAN NOT NULL DEFAULT TRUE,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_user_id (user_id),
            INDEX idx_link_id (link_id),
            INDEX idx_is_active (is_active)
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        `);
        
        console.log('✅ Tabela user_links criada com sucesso!');
      } else {
        throw error;
      }
    }

    // Testar inserção de um link de exemplo
    console.log('\n🧪 Testando inserção de link...');
    try {
      const testLinkId = `test_link_${Date.now()}`;
      await connection.execute(
        'INSERT INTO user_links (link_id, user_id, link_type, is_active) VALUES (?, ?, ?, ?)',
        [testLinkId, '1', 'members', true]
      );
      console.log('✅ Inserção de teste funcionou!');
      
      // Limpar dados de teste
      await connection.execute('DELETE FROM user_links WHERE link_id = ?', [testLinkId]);
      console.log('✅ Dados de teste removidos');
    } catch (error) {
      console.error('❌ Erro no teste de inserção:', error.message);
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

checkUserLinksTable();
