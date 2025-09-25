import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'conectados',
  port: parseInt(process.env.DB_PORT || '3306')
};

async function createDeleteMemberCascadeFunction() {
  let connection;
  
  try {
    console.log('🔌 Conectando ao banco de dados...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ Conectado ao MySQL');
    
    console.log('📄 Lendo arquivo SQL...');
    const fs = await import('fs');
    const sqlContent = fs.readFileSync('docs/DELETE_MEMBER_CASCADE_FUNCTION.sql', 'utf8');
    
    console.log('🔧 Executando função de delete com cascade...');
    
    // Dividir o SQL em comandos individuais
    const commands = sqlContent
      .split('//')
      .map(cmd => cmd.trim())
      .filter(cmd => cmd.length > 0);
    
    for (const command of commands) {
      if (command.trim()) {
        console.log('⚡ Executando comando:', command.substring(0, 50) + '...');
        await connection.execute(command);
      }
    }
    
    console.log('✅ Função delete_member_with_cascade criada com sucesso!');
    
    // Testar a função
    console.log('🧪 Testando a função...');
    
    // Primeiro, criar um membro de teste
    console.log('📝 Criando membro de teste...');
    await connection.execute(`
      INSERT INTO members (
        name, phone, instagram, city, sector, referrer, 
        registration_date, status, couple_name, couple_phone, 
        couple_instagram, couple_city, couple_sector
      ) VALUES (
        'Teste Delete', '(62) 99999-9999', '@teste_delete', 
        'Goiânia', 'Centro', 'Admin', NOW(), 'Ativo',
        'Cônjuge Teste', '(62) 88888-8888', '@conjuge_teste',
        'Goiânia', 'Centro'
      )
    `);
    
    const [memberResult] = await connection.execute('SELECT LAST_INSERT_ID() as id');
    const memberId = memberResult[0].id;
    
    console.log(`✅ Membro de teste criado com ID: ${memberId}`);
    
    // Criar auth_user para o membro
    console.log('👤 Criando auth_user de teste...');
    await connection.execute(`
      INSERT INTO auth_users (username, password, role, display_name)
      VALUES ('teste_delete', 'teste123', 'Membro', 'Teste Delete')
    `);
    
    const [authResult] = await connection.execute('SELECT LAST_INSERT_ID() as id');
    const authUserId = authResult[0].id;
    
    console.log(`✅ Auth user criado com ID: ${authUserId}`);
    
    // Criar user_link
    console.log('🔗 Criando user_link de teste...');
    await connection.execute(`
      INSERT INTO user_links (user_id, link_id, link_type, is_active, created_at)
      VALUES (?, 'teste-link-123', 'members', true, NOW())
    `, [authUserId]);
    
    const [linkResult] = await connection.execute('SELECT LAST_INSERT_ID() as id');
    const linkId = linkResult[0].id;
    
    console.log(`✅ User link criado com ID: ${linkId}`);
    
    // Testar a função de delete
    console.log(`🗑️ Testando delete com cascade para membro ID: ${memberId}`);
    
    const [result] = await connection.execute(
      'CALL delete_member_with_cascade(?, @success, @message)',
      [memberId]
    );
    
    const [output] = await connection.execute('SELECT @success as success, @message as message');
    
    console.log('📊 Resultado do teste:', output[0]);
    
    if (output[0].success) {
      console.log('✅ Teste bem-sucedido!');
      console.log('📝 Mensagem:', output[0].message);
      
      // Verificar se os dados foram deletados corretamente
      const [memberCheck] = await connection.execute(
        'SELECT id, name, deleted_at FROM members WHERE id = ?',
        [memberId]
      );
      
      const [authCheck] = await connection.execute(
        'SELECT COUNT(*) as count FROM auth_users WHERE id = ?',
        [authUserId]
      );
      
      const [linkCheck] = await connection.execute(
        'SELECT COUNT(*) as count FROM user_links WHERE id = ?',
        [linkId]
      );
      
      console.log('🔍 Verificação:');
      console.log(`  - Membro: ${memberCheck[0].name} (deleted_at: ${memberCheck[0].deleted_at})`);
      console.log(`  - Auth User: ${authCheck[0].count} registros (deve ser 0)`);
      console.log(`  - User Link: ${linkCheck[0].count} registros (deve ser 0)`);
      
    } else {
      console.log('❌ Teste falhou:', output[0].message);
    }
    
  } catch (error) {
    console.error('❌ Erro:', error);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Conexão encerrada');
    }
  }
}

createDeleteMemberCascadeFunction();
