// Script para corrigir a função MySQL
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

async function fixMySQLFunction() {
  let connection;
  
  try {
    console.log('🔗 Conectando ao banco MySQL...');
    
    const dbConfig = {
      host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
      user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
      password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
      database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
      charset: 'utf8mb4',
      timezone: 'Z'
    };
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado com sucesso!');

    console.log('🔧 Corrigindo função generate_unique_link...');
    
    // Dropar e recriar a função com correção
    await connection.execute('DROP FUNCTION IF EXISTS generate_unique_link');
    
    await connection.execute(`
      CREATE FUNCTION generate_unique_link(user_username VARCHAR(255))
      RETURNS VARCHAR(500)
      READS SQL DATA
      DETERMINISTIC
      BEGIN
          DECLARE link_id VARCHAR(500);
          DECLARE link_exists INT DEFAULT 1;
          DECLARE attempts INT DEFAULT 0;
          DECLARE max_attempts INT DEFAULT 100;
          
          WHILE link_exists > 0 AND attempts < max_attempts DO
              SET link_id = CONCAT(
                  user_username, 
                  '-', 
                  UNIX_TIMESTAMP(NOW()), 
                  '-', 
                  LPAD(FLOOR(RAND() * 10000), 4, '0')
              );
              
              -- Usar uma variável temporária para evitar conflito de nomes
              SELECT COUNT(*) INTO link_exists 
              FROM user_links 
              WHERE user_links.link_id = link_id;
              
              SET attempts = attempts + 1;
              
              -- Pequena pausa para evitar timestamps idênticos
              IF link_exists > 0 THEN
                  DO SLEEP(0.001);
              END IF;
          END WHILE;
          
          IF attempts >= max_attempts THEN
              SIGNAL SQLSTATE '45000' 
              SET MESSAGE_TEXT = 'Não foi possível gerar link único após múltiplas tentativas';
          END IF;
          
          RETURN link_id;
      END
    `);
    
    console.log('✅ Função generate_unique_link corrigida!');
    
    console.log('🧪 Testando função corrigida...');
    
    // Testar a função
    const [result1] = await connection.execute('SELECT generate_unique_link(?) as link1', ['teste']);
    const [result2] = await connection.execute('SELECT generate_unique_link(?) as link2', ['teste']);
    
    console.log('✅ Link 1 gerado:', result1[0].link1);
    console.log('✅ Link 2 gerado:', result2[0].link2);
    
    if (result1[0].link1 !== result2[0].link2) {
      console.log('✅ Função gera links únicos corretamente!');
    } else {
      console.log('❌ Função ainda gera links idênticos!');
    }
    
    console.log('\n🧪 Testando procedure completa...');
    
    // Testar procedure
    await connection.execute(`
      CALL get_or_generate_user_link('999', 'usuario_teste', 'members', @link_id, @is_existing, @success, @message)
    `);
    
    const [output] = await connection.execute(`
      SELECT @link_id as link_id, @is_existing as is_existing, @success as success, @message as message
    `);
    
    console.log('📋 Resultado da procedure:', output[0]);
    
    if (output[0].success) {
      console.log('✅ Procedure funcionando corretamente!');
    } else {
      console.log('❌ Procedure ainda com erro:', output[0].message);
    }
    
    console.log('\n✅ Correção concluída!');
    
  } catch (error) {
    console.error('❌ Erro ao corrigir função:', error.message);
    console.error('Detalhes:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

// Executar correção
fixMySQLFunction().catch(console.error);
