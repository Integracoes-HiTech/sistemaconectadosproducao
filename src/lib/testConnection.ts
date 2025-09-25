// lib/testConnection.ts
import { testConnection, executeQuery } from './database'

export const testDatabaseConnection = async () => {
  
  try {
    // Testar conexão básica
    const isConnected = await testConnection()
    
    if (!isConnected) {
      // Falha na conexão
      return false
    }

    // Testar consulta simples
    const result = await executeQuery('SELECT 1 as test')

    // Testar tabelas existentes
    const tables = await executeQuery<{table_name: string}>(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'vereador_connect'"
    )
    

    // Testar usuários de autenticação
    const authUsers = await executeQuery('SELECT username, name, role FROM auth_users LIMIT 5')

    // Testar configurações do sistema
    const settings = await executeQuery('SELECT setting_key, setting_value FROM system_settings LIMIT 5')

    return true

  } catch (error) {
    // Erro silencioso
    return false
  }
}

// Função para verificar se todas as tabelas necessárias existem
export const verifyDatabaseStructure = async () => {
  const requiredTables = [
    'auth_users', 
    'user_links',
    'members',
    'friends',
    'system_settings',
    'phase_control',
  ]

  try {
    const tables = await executeQuery<{table_name: string}>(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'vereador_connect'"
    )
    
    const existingTables = tables.map(t => t.table_name)
    const missingTables = requiredTables.filter(table => !existingTables.includes(table))
    
    if (missingTables.length > 0) {
      console.warn('⚠️ Tabelas faltando:', missingTables)
      return false
    }
    
    return true
    
  } catch (error) {
    // Erro silencioso
    return false
  }
}
