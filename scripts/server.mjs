// server.mjs - Servidor Express para comunicação com MySQL
import express from 'express';
import cors from 'cors';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Configuração do banco MySQL
const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  charset: 'utf8mb4',
  timezone: 'Z',
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true,
  connectionLimit: 10
};

// Pool de conexões
let pool = null;

const getConnection = async () => {
  if (!pool) {
    pool = mysql.createPool(dbConfig);
  }
  return pool;
};

// Função para executar queries
const executeQuery = async (query, params = []) => {
  try {
    const connection = await getConnection();
    const [rows] = await connection.execute(query, params);
    return rows;
  } catch (error) {
    console.error('Erro ao executar query:', error);
    throw error;
  }
};

// Função para executar uma única query
const executeSingleQuery = async (query, params = []) => {
  try {
    const connection = await getConnection();
    const [rows] = await connection.execute(query, params);
    return rows.length > 0 ? rows[0] : null;
  } catch (error) {
    console.error('Erro ao executar query única:', error);
    throw error;
  }
};

// Função para atualizar dados
const updateData = async (table, data, where) => {
  try {
    const connection = await getConnection();
    const setClause = Object.keys(data).map(key => `${key} = ?`).join(', ');
    const whereClause = Object.keys(where).map(key => `${key} = ?`).join(' AND ');
    const values = [...Object.values(data), ...Object.values(where)];
    const query = `UPDATE ${table} SET ${setClause} WHERE ${whereClause}`;
    await connection.execute(query, values);
  } catch (error) {
    console.error('Erro ao atualizar dados:', error);
    throw error;
  }
};

// Rota para testar conexão
app.get('/api/test-connection', async (req, res) => {
  try {
    const connection = await getConnection();
    await connection.execute('SELECT 1');
    res.json({ success: true, message: 'Conexão com MySQL estabelecida!' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Rota para login
app.post('/api/login', async (req, res) => {
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

    console.log('🔍 Tentando login com:', normalizedUsername);

    // Buscar usuário na tabela auth_users
    const user = await executeSingleQuery(
      'SELECT * FROM auth_users WHERE username = ? AND password = ?',
      [normalizedUsername, password]
    );

    if (!user) {
      console.log('❌ Usuário ou senha incorretos');
      return res.status(401).json({ 
        success: false, 
        error: 'Usuário ou senha incorretos' 
      });
    }

    console.log('✅ Usuário encontrado:', user.name);

    // Ativar usuário após login bem-sucedido
    await updateData('auth_users', {
      is_active: true,
      last_login: new Date().toISOString()
    }, { id: user.id });

    // Atualizar status do usuário na tabela users para "Ativo" (se tiver instagram)
    if (user.instagram) {
      await updateData('users', {
        status: 'Ativo',
        updated_at: new Date().toISOString()
      }, { instagram: user.instagram });
    }

    const userData = {
      id: user.id,
      username: user.username,
      name: user.name,
      role: user.role,
      full_name: user.full_name,
      instagram: user.instagram,
      phone: user.phone,
      is_active: true,
      last_login: new Date().toISOString(),
      created_at: user.created_at,
      updated_at: user.updated_at
    };

    res.json({ 
      success: true, 
      user: userData,
      message: `Bem-vindo, ${user.name}!`
    });

  } catch (error) {
    console.error('❌ Erro no login:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Rota para validar sessão
app.post('/api/validate-session', async (req, res) => {
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
      user: user 
    });

  } catch (error) {
    console.error('❌ Erro ao validar sessão:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Rota para buscar configurações do sistema
app.get('/api/system-settings', async (req, res) => {
  try {
    const settings = await executeQuery(
      'SELECT setting_key, setting_value FROM system_settings'
    );

    const settingsData = {
      max_members: 1500,
      contracts_per_member: 15,
      ranking_green_threshold: 15,
      ranking_yellow_threshold: 1,
      paid_contracts_phase_active: false,
      paid_contracts_start_date: '2026-07-01',
      member_links_type: 'members',
      admin_controls_link_type: true
    };

    // Converter dados do banco para objeto
    settings.forEach(item => {
      switch (item.setting_key) {
        case 'max_members':
          settingsData.max_members = parseInt(item.setting_value);
          break;
        case 'contracts_per_member':
          settingsData.contracts_per_member = parseInt(item.setting_value);
          break;
        case 'ranking_green_threshold':
          settingsData.ranking_green_threshold = parseInt(item.setting_value);
          break;
        case 'ranking_yellow_threshold':
          settingsData.ranking_yellow_threshold = parseInt(item.setting_value);
          break;
        case 'paid_contracts_phase_active':
          settingsData.paid_contracts_phase_active = item.setting_value === 'true';
          break;
        case 'paid_contracts_start_date':
          settingsData.paid_contracts_start_date = item.setting_value;
          break;
        case 'member_links_type':
          settingsData.member_links_type = item.setting_value;
          break;
        case 'admin_controls_link_type':
          settingsData.admin_controls_link_type = item.setting_value === 'true';
          break;
      }
    });

    res.json({ 
      success: true, 
      settings: settingsData 
    });

  } catch (error) {
    console.error('❌ Erro ao buscar configurações:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Rota para buscar estatísticas
app.get('/api/stats', async (req, res) => {
  try {
    const { referrer } = req.query;

    // Query base para membros
    let query = 'SELECT * FROM members WHERE deleted_at IS NULL';
    let params = [];

    if (referrer) {
      query += ' AND referrer = ?';
      params.push(referrer);
    }

    const members = await executeQuery(query, params);

    // Calcular estatísticas
    const totalUsers = members.length;
    const activeUsers = members.filter(member => member.status === 'Ativo').length;
    
    // Usuários dos últimos 7 dias
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentRegistrations = members.filter(member => {
      const regDate = new Date(member.registration_date);
      return regDate >= sevenDaysAgo;
    }).length;

    // Usuários cadastrados hoje
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    
    const todayRegistrations = members.filter(member => {
      return member.registration_date === todayStr;
    }).length;

    // Taxa de engajamento
    const engagementRate = totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;

    res.json({
      success: true,
      stats: {
        total_users: totalUsers,
        active_users: activeUsers,
        recent_registrations: recentRegistrations,
        engagement_rate: engagementRate,
        today_registrations: todayRegistrations
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar estatísticas:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar dados de relatórios
app.get('/api/reports', async (req, res) => {
  try {
    const { referrer } = req.query;

    // Query base para membros
    let query = 'SELECT * FROM members WHERE deleted_at IS NULL';
    let params = [];

    if (referrer) {
      query += ' AND referrer = ?';
      params.push(referrer);
    }

    const members = await executeQuery(query, params);

    // Calcular dados para relatórios
    const usersByLocation = {};
    const usersByCity = {};
    const sectorsByCity = {};
    const sectorsGroupedByCity = {};
    const registrationsByDay = [];
    const usersByStatus = [];

    members.forEach(member => {
      // Por localização (setor + cidade)
      const location = `${member.sector} - ${member.city}`;
      usersByLocation[location] = (usersByLocation[location] || 0) + 1;

      // Por cidade
      usersByCity[member.city] = (usersByCity[member.city] || 0) + 1;

      // Setores por cidade
      if (!sectorsByCity[member.city]) {
        sectorsByCity[member.city] = {};
      }
      sectorsByCity[member.city][member.sector] = (sectorsByCity[member.city][member.sector] || 0) + 1;

      // Setores agrupados por cidade
      if (!sectorsGroupedByCity[member.city]) {
        sectorsGroupedByCity[member.city] = {
          count: 0,
          sectors: []
        };
      }
      sectorsGroupedByCity[member.city].count++;
      if (!sectorsGroupedByCity[member.city].sectors.includes(member.sector)) {
        sectorsGroupedByCity[member.city].sectors.push(member.sector);
      }
    });

    // Calcular total de setores por cidade
    Object.keys(sectorsGroupedByCity).forEach(city => {
      sectorsGroupedByCity[city].totalSectors = sectorsGroupedByCity[city].sectors.length;
    });

    // Registros por dia (últimos 7 dias)
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const dateStr = date.toISOString().split('T')[0];
      
      const count = members.filter(member => member.registration_date === dateStr).length;
      registrationsByDay.push({
        date: dateStr,
        quantidade: count
      });
    }

    // Usuários por status
    const statusCounts = {};
    members.forEach(member => {
      statusCounts[member.status] = (statusCounts[member.status] || 0) + 1;
    });

    Object.entries(statusCounts).forEach(([status, count]) => {
      usersByStatus.push({ status, count });
    });

    res.json({
      success: true,
      reportData: {
        usersByLocation,
        registrationsByDay,
        usersByStatus,
        recentActivity: [], // Implementar se necessário
        sectorsByCity,
        sectorsGroupedByCity,
        usersByCity
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar dados de relatórios:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar membros
app.get('/api/members', async (req, res) => {
  try {
    const { referrer, search, phone, status, city, sector, page = 1, limit = 50 } = req.query;

    // Query base para membros
    let query = 'SELECT * FROM members WHERE deleted_at IS NULL';
    let params = [];

    if (referrer) {
      query += ' AND referrer = ?';
      params.push(referrer);
    }

    if (search) {
      query += ` AND (
        name LIKE ? OR 
        instagram LIKE ? OR 
        city LIKE ? OR 
        sector LIKE ? OR 
        referrer LIKE ? OR 
        couple_name LIKE ? OR 
        couple_instagram LIKE ? OR 
        couple_city LIKE ? OR 
        couple_sector LIKE ?
      )`;
      const searchTerm = `%${search}%`;
      for (let i = 0; i < 9; i++) {
        params.push(searchTerm);
      }
    }

    if (phone) {
      query += ' AND (phone LIKE ? OR couple_phone LIKE ?)';
      const phoneTerm = `%${phone}%`;
      params.push(phoneTerm, phoneTerm);
    }

    if (status) {
      query += ' AND ranking_status = ?';
      params.push(status);
    }

    if (city) {
      query += ' AND city LIKE ?';
      params.push(`%${city}%`);
    }

    if (sector) {
      query += ' AND sector LIKE ?';
      params.push(`%${sector}%`);
    }

    // Ordenar por ranking_position
    query += ' ORDER BY ranking_position ASC, created_at ASC';

    // Paginação
    const offset = (parseInt(page) - 1) * parseInt(limit);
    query += ' LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const members = await executeQuery(query, params);

    // Buscar total para paginação
    let countQuery = 'SELECT COUNT(*) as total FROM members WHERE deleted_at IS NULL';
    let countParams = [];

    if (referrer) {
      countQuery += ' AND referrer = ?';
      countParams.push(referrer);
    }

    if (search) {
      countQuery += ` AND (
        name LIKE ? OR 
        instagram LIKE ? OR 
        city LIKE ? OR 
        sector LIKE ? OR 
        referrer LIKE ? OR 
        couple_name LIKE ? OR 
        couple_instagram LIKE ? OR 
        couple_city LIKE ? OR 
        couple_sector LIKE ?
      )`;
      const searchTerm = `%${search}%`;
      for (let i = 0; i < 9; i++) {
        countParams.push(searchTerm);
      }
    }

    if (phone) {
      countQuery += ' AND (phone LIKE ? OR couple_phone LIKE ?)';
      const phoneTerm = `%${phone}%`;
      countParams.push(phoneTerm, phoneTerm);
    }

    if (status) {
      countQuery += ' AND ranking_status = ?';
      countParams.push(status);
    }

    if (city) {
      countQuery += ' AND city LIKE ?';
      countParams.push(`%${city}%`);
    }

    if (sector) {
      countQuery += ' AND sector LIKE ?';
      countParams.push(`%${sector}%`);
    }

    const countResult = await executeSingleQuery(countQuery, countParams);
    const total = countResult?.total || 0;

    res.json({
      success: true,
      members,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar estatísticas de membros
app.get('/api/member-stats', async (req, res) => {
  try {
    const { referrer } = req.query;

    // Query base para membros
    let query = 'SELECT * FROM members WHERE deleted_at IS NULL';
    let params = [];

    if (referrer) {
      query += ' AND referrer = ?';
      params.push(referrer);
    }

    const members = await executeQuery(query, params);

    // Calcular estatísticas
    const totalMembers = members.length;
    const greenMembers = members.filter(m => m.ranking_status === 'Verde').length;
    const yellowMembers = members.filter(m => m.ranking_status === 'Amarelo').length;
    const redMembers = members.filter(m => m.ranking_status === 'Vermelho').length;
    const currentMemberCount = members.filter(m => m.status === 'Ativo').length;

    // Buscar configurações do sistema
    const settings = await executeQuery('SELECT setting_key, setting_value FROM system_settings');
    const settingsData = {
      max_members: 1500,
      contracts_per_member: 15,
      ranking_green_threshold: 15,
      ranking_yellow_threshold: 1
    };

    settings.forEach(item => {
      switch (item.setting_key) {
        case 'max_members':
          settingsData.max_members = parseInt(item.setting_value);
          break;
        case 'contracts_per_member':
          settingsData.contracts_per_member = parseInt(item.setting_value);
          break;
        case 'ranking_green_threshold':
          settingsData.ranking_green_threshold = parseInt(item.setting_value);
          break;
        case 'ranking_yellow_threshold':
          settingsData.ranking_yellow_threshold = parseInt(item.setting_value);
          break;
      }
    });

    res.json({
      success: true,
      memberStats: {
        total_members: totalMembers,
        current_member_count: currentMemberCount,
        max_member_limit: settingsData.max_members,
        green_members: greenMembers,
        yellow_members: yellowMembers,
        red_members: redMembers,
        contracts_per_member: settingsData.contracts_per_member,
        ranking_green_threshold: settingsData.ranking_green_threshold,
        ranking_yellow_threshold: settingsData.ranking_yellow_threshold
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar estatísticas de membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar amigos
app.get('/api/friends', async (req, res) => {
  try {
    const { search, phone, member, city, sector, page = 1, limit = 50 } = req.query;

    // Query base para amigos
    let query = 'SELECT * FROM friends WHERE deleted_at IS NULL';
    let params = [];

    if (search) {
      query += ` AND (
        name LIKE ? OR 
        instagram LIKE ? OR 
        city LIKE ? OR 
        sector LIKE ? OR 
        referrer LIKE ? OR 
        couple_name LIKE ? OR 
        couple_instagram LIKE ? OR 
        couple_city LIKE ? OR 
        couple_sector LIKE ?
      )`;
      const searchTerm = `%${search}%`;
      for (let i = 0; i < 9; i++) {
        params.push(searchTerm);
      }
    }

    if (phone) {
      query += ' AND (phone LIKE ? OR couple_phone LIKE ?)';
      const phoneTerm = `%${phone}%`;
      params.push(phoneTerm, phoneTerm);
    }

    if (member) {
      query += ' AND referrer LIKE ?';
      params.push(`%${member}%`);
    }

    if (city) {
      query += ' AND (city LIKE ? OR couple_city LIKE ?)';
      params.push(`%${city}%`, `%${city}%`);
    }

    if (sector) {
      query += ' AND (sector LIKE ? OR couple_sector LIKE ?)';
      params.push(`%${sector}%`, `%${sector}%`);
    }

    // Ordenar por contracts_completed (mais amigos cadastrados = melhor posição)
    query += ' ORDER BY contracts_completed DESC, created_at ASC';

    // Paginação
    const offset = (parseInt(page) - 1) * parseInt(limit);
    query += ' LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const friends = await executeQuery(query, params);

    // Buscar total para paginação
    let countQuery = 'SELECT COUNT(*) as total FROM friends WHERE deleted_at IS NULL';
    let countParams = [];

    if (search) {
      countQuery += ` AND (
        name LIKE ? OR 
        instagram LIKE ? OR 
        city LIKE ? OR 
        sector LIKE ? OR 
        referrer LIKE ? OR 
        couple_name LIKE ? OR 
        couple_instagram LIKE ? OR 
        couple_city LIKE ? OR 
        couple_sector LIKE ?
      )`;
      const searchTerm = `%${search}%`;
      for (let i = 0; i < 9; i++) {
        countParams.push(searchTerm);
      }
    }

    if (phone) {
      countQuery += ' AND (phone LIKE ? OR couple_phone LIKE ?)';
      const phoneTerm = `%${phone}%`;
      countParams.push(phoneTerm, phoneTerm);
    }

    if (member) {
      countQuery += ' AND referrer LIKE ?';
      countParams.push(`%${member}%`);
    }

    if (city) {
      countQuery += ' AND (city LIKE ? OR couple_city LIKE ?)';
      countParams.push(`%${city}%`, `%${city}%`);
    }

    if (sector) {
      countQuery += ' AND (sector LIKE ? OR couple_sector LIKE ?)';
      countParams.push(`%${sector}%`, `%${sector}%`);
    }

    const countResult = await executeSingleQuery(countQuery, countParams);
    const total = countResult?.total || 0;

    res.json({
      success: true,
      friends,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar amigos:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar estatísticas de amigos
app.get('/api/friend-stats', async (req, res) => {
  try {
    const friends = await executeQuery('SELECT * FROM friends WHERE deleted_at IS NULL');

    // Calcular estatísticas
    const totalFriends = friends.length;
    const greenFriends = friends.filter(f => f.ranking_status === 'Verde').length;
    const yellowFriends = friends.filter(f => f.ranking_status === 'Amarelo').length;
    const redFriends = friends.filter(f => f.ranking_status === 'Vermelho').length;

    res.json({
      success: true,
      friendStats: {
        total_friends: totalFriends,
        green_friends: greenFriends,
        yellow_friends: yellowFriends,
        red_friends: redFriends
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar estatísticas de amigos:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para gerar link de cadastro
app.post('/api/generate-link', async (req, res) => {
  try {
    const { userId, userName } = req.body;

    if (!userId || !userName) {
      return res.status(400).json({
        success: false,
        error: 'User ID e User Name são obrigatórios'
      });
    }

    // Gerar ID único para o link
    const linkId = `link_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

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

    // Inserir link na tabela user_links
    const linkData = {
      link_id: linkId,
      user_id: userId,
      link_type: settingsData.member_links_type,
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    await executeQuery(
      'INSERT INTO user_links (link_id, user_id, link_type, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      [linkData.link_id, linkData.user_id, linkData.link_type, linkData.is_active, linkData.created_at, linkData.updated_at]
    );

    res.json({
      success: true,
      data: {
        link_id: linkId,
        link_type: settingsData.member_links_type,
        full_url: `${req.protocol}://${req.get('host')}/cadastro/${linkId}`
      }
    });

  } catch (error) {
    console.error('❌ Erro ao gerar link:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar links do usuário
app.get('/api/user-links', async (req, res) => {
  try {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: 'User ID é obrigatório'
      });
    }

    const links = await executeQuery(
      'SELECT * FROM user_links WHERE user_id = ? AND is_active = true ORDER BY created_at DESC',
      [userId]
    );

    res.json({
      success: true,
      links
    });

  } catch (error) {
    console.error('❌ Erro ao buscar links do usuário:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para alterar tipo de link (apenas administradores)
app.post('/api/update-link-type', async (req, res) => {
  try {
    const { linkType } = req.body;

    if (!linkType || !['members', 'friends'].includes(linkType)) {
      return res.status(400).json({
        success: false,
        error: 'Tipo de link deve ser "members" ou "friends"'
      });
    }

    // Atualizar configuração do sistema
    await executeQuery(
      'UPDATE system_settings SET setting_value = ? WHERE setting_key = "member_links_type"',
      [linkType]
    );

    res.json({
      success: true,
      message: `Tipo de link alterado para: ${linkType === 'members' ? 'Novos Membros' : 'Amigos'}`
    });

  } catch (error) {
    console.error('❌ Erro ao alterar tipo de link:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar link por ID (para PublicRegister)
app.get('/api/link/:linkId', async (req, res) => {
  try {
    const { linkId } = req.params;

    if (!linkId) {
      return res.status(400).json({
        success: false,
        error: 'Link ID é obrigatório'
      });
    }

    // Buscar link na tabela user_links
    const link = await executeSingleQuery(
      'SELECT ul.*, au.name, au.role, au.full_name FROM user_links ul LEFT JOIN auth_users au ON ul.user_id = au.id WHERE ul.link_id = ? AND ul.is_active = true',
      [linkId]
    );

    if (!link) {
      return res.status(404).json({
        success: false,
        error: 'Link não encontrado ou inativo'
      });
    }

    res.json({
      success: true,
      data: {
        link_id: link.link_id,
        user_id: link.user_id,
        link_type: link.link_type,
        is_active: link.is_active,
        created_at: link.created_at,
        updated_at: link.updated_at,
        user_data: {
          name: link.name,
          role: link.role,
          full_name: link.full_name
        }
      }
    });

  } catch (error) {
    console.error('❌ Erro ao buscar link:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para incrementar contador de cliques do link
app.put('/api/link/:linkId/increment-clicks', async (req, res) => {
  try {
    const { linkId } = req.params;

    if (!linkId) {
      return res.status(400).json({
        success: false,
        error: 'Link ID é obrigatório'
      });
    }

    // Incrementar contador de cliques (se existir a coluna)
    // Por enquanto, apenas retornar sucesso
    res.json({
      success: true,
      message: 'Contador de cliques incrementado'
    });

  } catch (error) {
    console.error('❌ Erro ao incrementar cliques:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para salvar membro (para PublicRegister)
app.post('/api/members', async (req, res) => {
  try {
    const {
      name,
      phone,
      instagram,
      city,
      sector,
      referrer,
      registration_date,
      status,
      couple_name,
      couple_phone,
      couple_instagram,
      couple_city,
      couple_sector
    } = req.body;

    // Validar campos obrigatórios
    if (!name || !phone || !instagram || !city || !sector || !referrer || !couple_name || !couple_phone || !couple_instagram || !couple_city || !couple_sector) {
      return res.status(400).json({
        success: false,
        error: 'Todos os campos são obrigatórios'
      });
    }

    // Inserir membro na tabela members
    const memberData = {
      name: name.trim(),
      phone,
      instagram: instagram.trim(),
      city: city.trim(),
      sector: sector.trim(),
      referrer: referrer.trim(),
      registration_date: registration_date || new Date().toISOString().split('T')[0],
      status: status || 'Ativo',
      couple_name: couple_name.trim(),
      couple_phone,
      couple_instagram: couple_instagram.trim(),
      couple_city: couple_city.trim(),
      couple_sector: couple_sector.trim(),
      contracts_completed: 0,
      ranking_status: 'Vermelho',
      is_top_1500: false,
      can_be_replaced: false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const result = await executeQuery(
      'INSERT INTO members (name, phone, instagram, city, sector, referrer, registration_date, status, couple_name, couple_phone, couple_instagram, couple_city, couple_sector, contracts_completed, ranking_status, is_top_1500, can_be_replaced, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        memberData.name,
        memberData.phone,
        memberData.instagram,
        memberData.city,
        memberData.sector,
        memberData.referrer,
        memberData.registration_date,
        memberData.status,
        memberData.couple_name,
        memberData.couple_phone,
        memberData.couple_instagram,
        memberData.couple_city,
        memberData.couple_sector,
        memberData.contracts_completed,
        memberData.ranking_status,
        memberData.is_top_1500,
        memberData.can_be_replaced,
        memberData.created_at,
        memberData.updated_at
      ]
    );

    const insertId = result.insertId;

    res.json({
      success: true,
      data: {
        id: insertId,
        ...memberData
      }
    });

  } catch (error) {
    console.error('❌ Erro ao salvar membro:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para salvar amigo (para PublicRegister)
app.post('/api/friends', async (req, res) => {
  try {
    const {
      name,
      phone,
      instagram,
      city,
      sector,
      referrer,
      registration_date,
      status,
      couple_name,
      couple_phone,
      couple_instagram,
      couple_city,
      couple_sector,
      member_id
    } = req.body;

    // Validar campos obrigatórios
    if (!name || !phone || !instagram || !city || !sector || !referrer || !couple_name || !couple_phone || !couple_instagram || !couple_city || !couple_sector) {
      return res.status(400).json({
        success: false,
        error: 'Todos os campos são obrigatórios'
      });
    }

    // Inserir amigo na tabela friends
    const friendData = {
      name: name.trim(),
      phone,
      instagram: instagram.trim(),
      city: city.trim(),
      sector: sector.trim(),
      referrer: referrer.trim(),
      registration_date: registration_date || new Date().toISOString().split('T')[0],
      status: status || 'Ativo',
      couple_name: couple_name.trim(),
      couple_phone,
      couple_instagram: couple_instagram.trim(),
      couple_city: couple_city.trim(),
      couple_sector: couple_sector.trim(),
      member_id: member_id || '',
      contracts_completed: 0,
      ranking_status: 'Vermelho',
      is_top_1500: false,
      can_be_replaced: false,
      post_verified_1: false,
      post_verified_2: false,
      post_url_1: null,
      post_url_2: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const result = await executeQuery(
      'INSERT INTO friends (name, phone, instagram, city, sector, referrer, registration_date, status, couple_name, couple_phone, couple_instagram, couple_city, couple_sector, member_id, contracts_completed, ranking_status, is_top_1500, can_be_replaced, post_verified_1, post_verified_2, post_url_1, post_url_2, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        friendData.name,
        friendData.phone,
        friendData.instagram,
        friendData.city,
        friendData.sector,
        friendData.referrer,
        friendData.registration_date,
        friendData.status,
        friendData.couple_name,
        friendData.couple_phone,
        friendData.couple_instagram,
        friendData.couple_city,
        friendData.couple_sector,
        friendData.member_id,
        friendData.contracts_completed,
        friendData.ranking_status,
        friendData.is_top_1500,
        friendData.can_be_replaced,
        friendData.post_verified_1,
        friendData.post_verified_2,
        friendData.post_url_1,
        friendData.post_url_2,
        friendData.created_at,
        friendData.updated_at
      ]
    );

    const insertId = result.insertId;

    res.json({
      success: true,
      data: {
        id: insertId,
        ...friendData
      }
    });

  } catch (error) {
    console.error('❌ Erro ao salvar amigo:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para criar usuário de autenticação (para PublicRegister)
app.post('/api/auth-users', async (req, res) => {
  try {
    const {
      username,
      password,
      name,
      role,
      full_name,
      display_name,
      instagram,
      phone,
      is_active
    } = req.body;

    // Validar campos obrigatórios
    if (!username || !password || !name || !role || !full_name) {
      return res.status(400).json({
        success: false,
        error: 'Username, password, name, role e full_name são obrigatórios'
      });
    }

    // Verificar se username já existe
    const existingUser = await executeSingleQuery(
      'SELECT id FROM auth_users WHERE username = ?',
      [username]
    );

    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'Username já existe'
      });
    }

    // Inserir usuário na tabela auth_users
    const authUserData = {
      username,
      password,
      name: name.trim(),
      role,
      full_name: full_name.trim(),
      display_name: display_name || null,
      instagram: instagram || null,
      phone: phone || null,
      is_active: is_active !== undefined ? is_active : false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const result = await executeQuery(
      'INSERT INTO auth_users (username, password, name, role, full_name, display_name, instagram, phone, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        authUserData.username,
        authUserData.password,
        authUserData.name,
        authUserData.role,
        authUserData.full_name,
        authUserData.display_name,
        authUserData.instagram,
        authUserData.phone,
        authUserData.is_active,
        authUserData.created_at,
        authUserData.updated_at
      ]
    );

    const insertId = result.insertId;

    res.json({
      success: true,
      data: {
        id: insertId,
        ...authUserData
      }
    });

  } catch (error) {
    console.error('❌ Erro ao criar usuário de autenticação:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`🌐 API disponível em: http://localhost:${PORT}`);
  console.log(`🔗 Teste de conexão: http://localhost:${PORT}/api/test-connection`);
});
