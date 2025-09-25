// api/login.js
import mysql from 'mysql2/promise';

// Configuração do banco MySQL
const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  charset: 'utf8mb4',
  timezone: 'Z'
};

// Função para executar query
const executeQuery = async (query, params = []) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute(query, params);
    await connection.end();
    return rows;
  } catch (error) {
    console.error('Erro na query:', error);
    throw error;
  }
};

// Função para executar uma única query
const executeSingleQuery = async (query, params = []) => {
  try {
    const connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute(query, params);
    await connection.end();
    return rows.length > 0 ? rows[0] : null;
  } catch (error) {
    console.error('Erro na query:', error);
    throw error;
  }
};

export default async function handler(req, res) {
  // Configurar CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ 
      success: false, 
      error: 'Método não permitido' 
    });
  }

  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        error: 'Username e password são obrigatórios'
      });
    }

    // Normalizar username
    const normalizedUsername = username.replace('@', '').toLowerCase();

    // Buscar usuário na tabela auth_users
    const user = await executeSingleQuery(
      'SELECT * FROM auth_users WHERE username = ? AND password = ?',
      [normalizedUsername, password]
    );

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Credenciais inválidas'
      });
    }

    if (!user.is_active) {
      return res.status(401).json({
        success: false,
        error: 'Usuário inativo'
      });
    }

    // Atualizar último login
    await executeQuery(
      'UPDATE auth_users SET last_login = ? WHERE id = ?',
      [new Date().toISOString(), user.id]
    );

    res.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role,
        full_name: user.full_name,
        display_name: user.display_name,
        instagram: user.instagram,
        phone: user.phone,
        is_active: user.is_active,
        last_login: user.last_login,
        created_at: user.created_at,
        updated_at: user.updated_at
      },
      message: `Bem-vindo, ${user.name}!`
    });

  } catch (error) {
    console.error('❌ Erro no login:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
}
