// execute-add-deleted-at.js - Script para executar SQL de adição do campo deleted_at
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  charset: 'utf8mb4',
  timezone: 'Z'
};

async function executeSQL() {
  let connection;
  
  try {
    console.log('🔌 Conectando ao MySQL...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao MySQL com sucesso!');

    // Ler o arquivo SQL
    const sqlContent = fs.readFileSync('docs/ADD_DELETED_AT_COLUMNS.sql', 'utf8');
    
    // Dividir em comandos individuais (separados por ;)
    const commands = sqlContent
      .split(';')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0 && !cmd.startsWith('--'));

    console.log(`📝 Executando ${commands.length} comandos SQL...`);

    for (let i = 0; i < commands.length; i++) {
      const command = commands[i];
      
      if (command.trim()) {
        try {
          console.log(`\n🔧 Executando comando ${i + 1}:`);
          console.log(command.substring(0, 100) + (command.length > 100 ? '...' : ''));
          
          const [result] = await connection.execute(command);
          
          if (Array.isArray(result)) {
            console.log(`✅ Resultado: ${result.length} registros encontrados`);
            if (result.length > 0 && result.length <= 5) {
              console.log('📊 Dados:', result);
            }
          } else {
            console.log('✅ Comando executado com sucesso');
          }
        } catch (error) {
          if (error.code === 'ER_DUP_FIELDNAME') {
            console.log('⚠️ Campo já existe, pulando...');
          } else if (error.code === 'ER_DUP_KEYNAME') {
            console.log('⚠️ Índice já existe, pulando...');
          } else {
            console.error('❌ Erro ao executar comando:', error.message);
            throw error;
          }
        }
      }
    }

    console.log('\n🎉 Script executado com sucesso!');
    console.log('✅ Campos deleted_at adicionados nas tabelas members e friends');
    console.log('✅ Índices criados para melhorar performance');
    
  } catch (error) {
    console.error('❌ Erro geral:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada');
    }
  }
}

// Executar o script
executeSQL();
