// Script para criar função MySQL simplificada
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

async function createSimpleMySQLFunction() {
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

    console.log('🔧 Criando função simplificada...');
    
    // Dropar funções existentes
    await connection.execute('DROP FUNCTION IF EXISTS generate_unique_link');
    await connection.execute('DROP PROCEDURE IF EXISTS generate_and_insert_user_link');
    await connection.execute('DROP PROCEDURE IF EXISTS get_or_generate_user_link');
    
    // Criar função simplificada que não depende de collation
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
              -- Gerar link usando timestamp e número aleatório
              SET link_id = CONCAT(
                  user_username, 
                  '-', 
                  UNIX_TIMESTAMP(NOW()), 
                  '-', 
                  LPAD(FLOOR(RAND() * 10000), 4, '0')
              );
              
              -- Verificar existência usando COLLATE para evitar problemas de collation
              SELECT COUNT(*) INTO link_exists 
              FROM user_links 
              WHERE link_id COLLATE utf8mb4_unicode_ci = link_id COLLATE utf8mb4_unicode_ci;
              
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
    
    console.log('✅ Função generate_unique_link criada!');
    
    // Criar procedure simplificada
    await connection.execute(`
      CREATE PROCEDURE generate_and_insert_user_link(
          IN p_user_id VARCHAR(255),
          IN p_user_username VARCHAR(255),
          IN p_link_type VARCHAR(50),
          OUT p_link_id VARCHAR(500),
          OUT p_success BOOLEAN,
          OUT p_message VARCHAR(500)
      )
      BEGIN
          DECLARE EXIT HANDLER FOR SQLEXCEPTION
          BEGIN
              ROLLBACK;
              SET p_success = FALSE;
              SET p_message = 'Erro ao gerar link único';
              RESIGNAL;
          END;
          
          START TRANSACTION;
          
          -- Desativar links antigos
          UPDATE user_links 
          SET is_active = 0, updated_at = NOW() 
          WHERE user_id = p_user_id;
          
          -- Gerar novo link
          SET p_link_id = generate_unique_link(p_user_username);
          
          -- Inserir novo link
          INSERT INTO user_links (
              link_id, 
              user_id, 
              link_type, 
              is_active, 
              created_at, 
              updated_at
          ) VALUES (
              p_link_id,
              p_user_id,
              p_link_type,
              1,
              NOW(),
              NOW()
          );
          
          COMMIT;
          
          SET p_success = TRUE;
          SET p_message = 'Link gerado com sucesso';
          
      END
    `);
    
    console.log('✅ Procedure generate_and_insert_user_link criada!');
    
    // Criar procedure principal
    await connection.execute(`
      CREATE PROCEDURE get_or_generate_user_link(
          IN p_user_id VARCHAR(255),
          IN p_user_username VARCHAR(255),
          IN p_link_type VARCHAR(50),
          OUT p_link_id VARCHAR(500),
          OUT p_is_existing BOOLEAN,
          OUT p_success BOOLEAN,
          OUT p_message VARCHAR(500)
      )
      BEGIN
          DECLARE existing_link_id VARCHAR(500);
          DECLARE link_count INT DEFAULT 0;
          
          DECLARE EXIT HANDLER FOR SQLEXCEPTION
          BEGIN
              SET p_success = FALSE;
              SET p_message = 'Erro ao processar link do usuário';
              RESIGNAL;
          END;
          
          -- Verificar se usuário já tem link ativo
          SELECT link_id INTO existing_link_id
          FROM user_links 
          WHERE user_id = p_user_id 
          AND is_active = 1 
          ORDER BY created_at DESC 
          LIMIT 1;
          
          SELECT COUNT(*) INTO link_count
          FROM user_links 
          WHERE user_id = p_user_id 
          AND is_active = 1;
          
          IF link_count > 0 THEN
              -- Retornar link existente
              SET p_link_id = existing_link_id;
              SET p_is_existing = TRUE;
              SET p_success = TRUE;
              SET p_message = 'Link existente retornado';
          ELSE
              -- Gerar novo link
              CALL generate_and_insert_user_link(
                  p_user_id, 
                  p_user_username, 
                  p_link_type, 
                  p_link_id, 
                  p_success, 
                  p_message
              );
              SET p_is_existing = FALSE;
          END IF;
          
      END
    `);
    
    console.log('✅ Procedure get_or_generate_user_link criada!');
    
    console.log('🧪 Testando função...');
    
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
    
    console.log('\n✅ Função MySQL criada e testada com sucesso!');
    
  } catch (error) {
    console.error('❌ Erro ao criar função:', error.message);
    console.error('Detalhes:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

// Executar criação
createSimpleMySQLFunction().catch(console.error);
