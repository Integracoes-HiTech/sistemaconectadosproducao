// api/generate-link.js
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
    console.log('🔍 Debug - generate-link chamado via Vercel API');
    console.log('🔍 Debug - req.body:', req.body);
    
    const { userId, userName } = req.body;

    if (!userId || !userName) {
      console.log('❌ Debug - Campos obrigatórios faltando:', { userId, userName });
      return res.status(400).json({
        success: false,
        error: 'User ID e User Name são obrigatórios'
      });
    }

    console.log('🔍 Debug - Buscando configurações do sistema...');
    // Buscar configurações do sistema para determinar o tipo de link
    const settings = await executeQuery('SELECT setting_key, setting_value FROM system_settings');
    const settingsData = {
      member_links_type: 'members'
    };

    settings.forEach(item => {
      if (item.setting_key === 'member_links_type') {
        settingsData.member_links_type = item.setting_value;
      }
    });

    // Verificar se o usuário é Admin ou Felipe Admin - eles sempre cadastram membros
    const userResult = await executeQuery(
      'SELECT role FROM auth_users WHERE id = ?',
      [userId]
    );
    
    const userRole = userResult[0]?.role;
    console.log('🔍 Debug - Role do usuário:', userRole);
    
    // Se for Admin ou Felipe Admin, sempre usar 'members'
    if (userRole === 'Administrador' || userRole === 'Felipe Admin') {
      settingsData.member_links_type = 'members';
      console.log('🔍 Debug - Usuário é Admin/Felipe Admin - forçando tipo: members');
    }

    console.log('🔍 Debug - Configurações finais:', settingsData);

    // Verificar se já existe um link ativo para o usuário
    const existingLink = await executeSingleQuery(
      'SELECT link_id FROM user_links WHERE user_id = ? AND is_active = true ORDER BY created_at DESC LIMIT 1',
      [userId]
    );

    let link_id;
    let is_existing = false;

    if (existingLink) {
      // Link existente encontrado
      link_id = existingLink.link_id;
      is_existing = true;
      console.log('🔍 Debug - Link existente encontrado:', link_id);
    } else {
      // Gerar novo link usando timestamp + random
      link_id = `${userName}-${Date.now()}-${Math.floor(Math.random() * 100000)}`;
      console.log('🔍 Debug - Gerando novo link:', link_id);
      
      await executeQuery(
        'INSERT INTO user_links (link_id, user_id, link_type, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
        [link_id, userId, settingsData.member_links_type, true, new Date().toISOString(), new Date().toISOString()]
      );
      console.log('🔍 Debug - Novo link inserido no banco');
    }

    // Retornar resposta baseada no resultado
    const response = {
      success: true,
      data: {
        link_id: link_id,
        link_type: settingsData.member_links_type,
        full_url: `${req.headers.host ? `https://${req.headers.host}` : 'https://vereador-connect.vercel.app'}/cadastro/${link_id}`,
        is_existing: is_existing
      }
    };
    
    console.log('🔍 Debug - Resposta enviada:', response);
    res.json(response);

  } catch (error) {
    console.error('❌ Debug - Erro em generate-link:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
}
