// add-deleted-at-members.js - Script para adicionar deleted_at apenas na tabela members
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

async function addDeletedAtToMembers() {
  let connection;
  
  try {
    console.log('🔌 Conectando ao MySQL...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao MySQL com sucesso!');

    // Adicionar campo deleted_at na tabela members
    console.log('\n🔧 Adicionando campo deleted_at na tabela members...');
    await connection.execute(`
      ALTER TABLE members 
      ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL 
      COMMENT 'Data e hora da exclusão lógica (soft delete)'
    `);
    console.log('✅ Campo deleted_at adicionado na tabela members!');

    // Criar índice para melhorar performance
    console.log('\n🔧 Criando índice para deleted_at na tabela members...');
    try {
      await connection.execute('CREATE INDEX idx_members_deleted_at ON members(deleted_at)');
      console.log('✅ Índice criado com sucesso!');
    } catch (error) {
      if (error.code === 'ER_DUP_KEYNAME') {
        console.log('⚠️ Índice já existe, pulando...');
      } else {
        throw error;
      }
    }

    // Verificar se foi criado
    console.log('\n📋 Verificando estrutura da tabela members:');
    const [columns] = await connection.execute('SHOW COLUMNS FROM members LIKE "deleted_at"');
    if (columns.length > 0) {
      console.log('✅ Campo deleted_at encontrado:', columns[0]);
    } else {
      console.log('❌ Campo deleted_at não encontrado');
    }

    // Testar query
    console.log('\n🧪 Testando query com deleted_at:');
    const [result] = await connection.execute('SELECT COUNT(*) as total FROM members WHERE deleted_at IS NULL');
    console.log(`✅ Query funcionou: ${result[0].total} registros encontrados`);
    
  } catch (error) {
    if (error.code === 'ER_DUP_FIELDNAME') {
      console.log('⚠️ Campo deleted_at já existe na tabela members');
    } else {
      console.error('❌ Erro:', error.message);
    }
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Conexão encerrada');
    }
  }
}

addDeletedAtToMembers();
