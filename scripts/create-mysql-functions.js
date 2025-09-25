// Script para criar as funções MySQL diretamente
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

async function createMySQLFunctions() {
  let connection;
  
  try {
    console.log('🔗 Conectando ao banco MySQL...');
    
    // Usar as mesmas configurações do server.mjs
    const dbConfig = {
      host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
      user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
      password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
      database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
      charset: 'utf8mb4',
      timezone: 'Z',
      acquireTimeout: 60000,
      timeout: 60000,
      reconnect: true,
      connectionLimit: 10
    };
    
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado com sucesso!');

    console.log('📋 Criando função generate_unique_link...');
    
    // Criar função generate_unique_link
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
              
              SELECT COUNT(*) INTO link_exists 
              FROM user_links 
              WHERE link_id = link_id;
              
              SET attempts = attempts + 1;
              
              IF link_exists > 0 THEN
                  SET @sleep_time = RAND() * 0.001;
                  DO SLEEP(@sleep_time);
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
    
    console.log('📋 Criando procedure generate_and_insert_user_link...');
    
    // Criar procedure generate_and_insert_user_link
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
          
          DECLARE EXIT HANDLER FOR SQLWARNING
          BEGIN
              ROLLBACK;
              SET p_success = FALSE;
              SET p_message = 'Aviso durante geração do link';
              RESIGNAL;
          END;
          
          START TRANSACTION;
          
          UPDATE user_links 
          SET is_active = 0, updated_at = NOW() 
          WHERE user_id = p_user_id;
          
          SET p_link_id = generate_unique_link(p_user_username);
          
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
    
    console.log('📋 Criando procedure get_or_generate_user_link...');
    
    // Criar procedure get_or_generate_user_link
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
              SET p_link_id = existing_link_id;
              SET p_is_existing = TRUE;
              SET p_success = TRUE;
              SET p_message = 'Link existente retornado';
          ELSE
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
    
    console.log('📋 Verificando funções criadas...');
    
    // Verificar funções criadas
    const [functions] = await connection.execute(`
      SELECT ROUTINE_NAME, ROUTINE_TYPE, CREATED 
      FROM information_schema.ROUTINES 
      WHERE ROUTINE_SCHEMA = ? 
      AND ROUTINE_NAME LIKE '%link%'
      ORDER BY ROUTINE_TYPE, ROUTINE_NAME
    `, [dbConfig.database]);
    
    console.log('🔍 Funções e procedures criadas:');
    functions.forEach(func => {
      console.log(`  - ${func.ROUTINE_TYPE}: ${func.ROUTINE_NAME} (criada em: ${func.CREATED})`);
    });
    
    console.log('\n📊 Onde ficam armazenadas as funções MySQL:');
    console.log('📍 Localização: information_schema.ROUTINES');
    console.log(`📍 Banco: ${dbConfig.database}`);
    console.log('📍 Tipo: FUNCTION e PROCEDURE');
    
    console.log('\n🔍 Para ver todas as funções do banco:');
    console.log(`SELECT ROUTINE_NAME, ROUTINE_TYPE FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA = "${dbConfig.database}";`);
    
    console.log('\n✅ Todas as funções foram criadas com sucesso!');
    
  } catch (error) {
    console.error('❌ Erro ao criar funções:', error.message);
    console.error('Detalhes:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

// Executar criação das funções
createMySQLFunctions().catch(console.error);
