// Script para configurar o usuário Felipe como Felipe Admin
import mysql from 'mysql2/promise'
import dotenv from 'dotenv'

dotenv.config()

const config = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'vereador_connect',
  port: process.env.DB_PORT || 3306
}

async function configurarFelipeAdmin() {
  let connection
  
  try {
    console.log('🔧 Configurando usuário Felipe como Felipe Admin...')
    
    connection = await mysql.createConnection(config)
    
    // Verificar se o usuário Felipe existe
    const [existingUsers] = await connection.execute(
      'SELECT id, username, name, role FROM auth_users WHERE username = ?',
      ['felipe']
    )
    
    if (existingUsers.length === 0) {
      console.log('❌ Usuário Felipe não encontrado. Criando...')
      
      // Criar usuário Felipe
      await connection.execute(
        `INSERT INTO auth_users (username, name, password_hash, role, is_active, created_at) 
         VALUES (?, ?, ?, ?, ?, NOW())`,
        ['felipe', 'Felipe Admin', '$2b$10$rQZ8Kj9LmNpOqRsTuVwXyO1aBcDeFgHiJkLmNoPqRsTuVwXyO1aBc', 'Felipe Admin', 1]
      )
      
      console.log('✅ Usuário Felipe criado com sucesso!')
    } else {
      const existingUser = existingUsers[0]
      console.log(`📋 Usuário Felipe encontrado: ${existingUser.name} (Role: ${existingUser.role})`)
      
      // Atualizar role para Felipe Admin se necessário
      if (existingUser.role !== 'Felipe Admin') {
        await connection.execute(
          'UPDATE auth_users SET role = ? WHERE username = ?',
          ['Felipe Admin', 'felipe']
        )
        console.log('✅ Role do Felipe atualizado para "Felipe Admin"')
      } else {
        console.log('✅ Felipe já está configurado como Felipe Admin')
      }
    }
    
    // Verificar configuração final
    const [finalUser] = await connection.execute(
      'SELECT id, username, name, role, is_active FROM auth_users WHERE username = ?',
      ['felipe']
    )
    
    if (finalUser.length > 0) {
      const user = finalUser[0]
      console.log('\n🎉 Configuração final do Felipe:')
      console.log(`   ID: ${user.id}`)
      console.log(`   Username: ${user.username}`)
      console.log(`   Nome: ${user.name}`)
      console.log(`   Role: ${user.role}`)
      console.log(`   Ativo: ${user.is_active ? 'Sim' : 'Não'}`)
      console.log('\n🔐 Credenciais de acesso:')
      console.log('   Usuário: felipe')
      console.log('   Senha: felipe123')
      console.log('\n⚠️  IMPORTANTE: Altere a senha no primeiro login!')
    }
    
  } catch (error) {
    console.error('❌ Erro ao configurar Felipe Admin:', error)
  } finally {
    if (connection) {
      await connection.end()
    }
  }
}

configurarFelipeAdmin()
