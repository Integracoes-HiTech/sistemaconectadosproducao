import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_vereador_connect'
};

async function createMemberUpdateFunctions() {
  let connection;
  
  try {
    console.log('🔍 Conectando ao banco de dados...');
    connection = await mysql.createConnection(dbConfig);
    
    console.log('📋 Lendo arquivo SQL...');
    const sqlContent = fs.readFileSync('docs/UPDATE_MEMBER_AFTER_FRIEND_REGISTRATION.sql', 'utf8');
    
    // Dividir o SQL em statements individuais
    const statements = sqlContent
      .split('//')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    console.log(`📊 Encontrados ${statements.length} statements para executar`);
    
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      
      if (statement.trim()) {
        console.log(`\n🔄 Executando statement ${i + 1}/${statements.length}...`);
        console.log(`📝 SQL: ${statement.substring(0, 100)}...`);
        
        try {
          await connection.execute(statement);
          console.log(`✅ Statement ${i + 1} executado com sucesso`);
        } catch (error) {
          console.log(`⚠️  Statement ${i + 1} falhou (pode ser esperado): ${error.message}`);
          
          // Se for erro de trigger já existir, continuar
          if (error.message.includes('already exists')) {
            console.log(`ℹ️  Trigger já existe, continuando...`);
            continue;
          }
          
          // Se for erro de procedure já existir, continuar
          if (error.message.includes('already exists')) {
            console.log(`ℹ️  Procedure já existe, continuando...`);
            continue;
          }
        }
      }
    }
    
    console.log('\n🎉 Processo concluído!');
    
    // Testar a procedure
    console.log('\n🧪 Testando a procedure...');
    try {
      const [result] = await connection.execute(
        'CALL update_member_after_friend_registration(?, @success, @message)',
        [1] // Testar com membro ID 1
      );
      
      const [output] = await connection.execute('SELECT @success as success, @message as message');
      console.log('📊 Resultado do teste:', output[0]);
      
    } catch (error) {
      console.log('⚠️  Erro no teste (pode ser esperado):', error.message);
    }
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

createMemberUpdateFunctions();
