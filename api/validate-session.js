// api/validate-session.js
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
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ 
        success: false, 
        error: 'User ID é obrigatório' 
      });
    }

    // Verificar se o usuário ainda existe e está ativo
    const user = await executeSingleQuery(
      'SELECT * FROM auth_users WHERE id = ? AND is_active = true',
      [userId]
    );

    if (!user) {
      return res.status(401).json({ 
        success: false, 
        error: 'Sessão inválida' 
      });
    }

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
      }
    });

  } catch (error) {
    console.error('❌ Erro na validação de sessão:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
}
