import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  port: process.env.DB_PORT || 3306
};

async function recreateUsernameFunctions() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao banco de dados');

    // Dropar funções existentes
    console.log('🗑️ Removendo funções existentes...');
    try {
      await connection.execute('DROP FUNCTION IF EXISTS generate_unique_username');
      console.log('✅ Função generate_unique_username removida');
    } catch (error) {
      console.log('⚠️ Função generate_unique_username não existia');
    }

    try {
      await connection.execute('DROP FUNCTION IF EXISTS generate_password');
      console.log('✅ Função generate_password removida');
    } catch (error) {
      console.log('⚠️ Função generate_password não existia');
    }

    try {
      await connection.execute('DROP PROCEDURE IF EXISTS create_user_with_unique_credentials');
      console.log('✅ Procedure create_user_with_unique_credentials removida');
    } catch (error) {
      console.log('⚠️ Procedure create_user_with_unique_credentials não existia');
    }

    // Ler o arquivo SQL
    const sqlFile = path.join(process.cwd(), 'docs', 'GENERATE_UNIQUE_USERNAME_FUNCTION.sql');
    const sqlContent = fs.readFileSync(sqlFile, 'utf8');
    
    // Dividir em statements individuais (remover DELIMITER)
    const statements = sqlContent
      .split('//')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt && !stmt.startsWith('DELIMITER'))
      .map(stmt => stmt.replace(/DELIMITER\s+[;\/]/g, '').trim())
      .filter(stmt => stmt.length > 0);

    console.log(`📋 Encontrados ${statements.length} statements para executar`);

    // Executar cada statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        console.log(`🔄 Executando statement ${i + 1}/${statements.length}...`);
        console.log(`📝 SQL: ${statement.substring(0, 100)}...`);
        
        try {
          await connection.execute(statement);
          console.log(`✅ Statement ${i + 1} executado com sucesso`);
        } catch (error) {
          console.error(`❌ Erro no statement ${i + 1}:`, error.message);
          // Continuar com os próximos statements mesmo se um falhar
        }
      }
    }

    console.log('🎉 Funções de username único recriadas com sucesso!');

  } catch (error) {
    console.error('❌ Erro ao recriar funções de username:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

recreateUsernameFunctions().catch(console.error);
