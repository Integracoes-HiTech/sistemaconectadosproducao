// Script para criar funções de controle de fase no MySQL
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  port: process.env.DB_PORT || 3306
};

async function createPhaseControlFunctions() {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao banco de dados');

    // Ler o arquivo SQL
    const fs = await import('fs');
    const sqlContent = fs.readFileSync('./docs/PHASE_CONTROL_LOGIC.sql', 'utf8');
    
    // Dividir em comandos individuais
    const commands = sqlContent.split('//').filter(cmd => cmd.trim());
    
    for (const command of commands) {
      if (command.trim()) {
        try {
          await connection.execute(command);
          console.log('✅ Comando executado com sucesso');
        } catch (error) {
          if (error.code === 'ER_SP_ALREADY_EXISTS' || error.code === 'ER_FUNC_DUPLICATE_FUNCTION') {
            console.log('⚠️ Função já existe, pulando...');
          } else {
            console.error('❌ Erro ao executar comando:', error.message);
          }
        }
      }
    }

    console.log('🎉 Funções de controle de fase criadas com sucesso!');

    // Testar as funções
    console.log('\n🧪 Testando funções...');
    
    const [shouldActivate] = await connection.execute('SELECT should_activate_paid_contracts_phase() as should_activate');
    console.log('📊 Deve ativar fase:', shouldActivate[0].should_activate);
    
    const [phaseStatus] = await connection.execute('SELECT get_phase_status() as status');
    console.log('📋 Status da fase:', JSON.parse(phaseStatus[0].status));
    
    const [updateResult] = await connection.execute('CALL update_phase_based_on_members()');
    console.log('🔄 Resultado da atualização:', updateResult[0]);

  } catch (error) {
    console.error('❌ Erro durante a criação das funções:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada.');
    }
  }
}

createPhaseControlFunctions().catch(console.error);
