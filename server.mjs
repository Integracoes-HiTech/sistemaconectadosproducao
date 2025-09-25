// server.mjs - Servidor Express para comunicação com MySQL
import express from 'express';
import cors from 'cors';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? [
        'https://vereador-connect.vercel.app',
        'https://vereador-connect-git-main.vercel.app',
        'https://vereador-connect-git-master.vercel.app',
        /\.vercel\.app$/
      ]
    : ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:8080'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware para log de requisições
app.use((req, res, next) => {
  console.log(`🔍 ${req.method} ${req.url} - Origin: ${req.headers.origin}`);
  next();
});
app.use(express.json());

// Configuração do banco MySQL
const dbConfig = {
  host: process.env.VITE_MYSQL_HOST || 'srv2020.hstgr.io',
  user: process.env.VITE_MYSQL_USER || 'u877021150_admin',
  password: process.env.VITE_MYSQL_PASSWORD || 'Admin_kiradon9279',
  database: process.env.VITE_MYSQL_DATABASE || 'u877021150_conectados',
  charset: 'utf8mb4',
  timezone: 'Z',
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
    throw error;
  }
};

// Função para executar uma única query
const executeSingleQuery = async (query, params = []) => {
  try {
    console.log(`🔍 Debug - executeSingleQuery: ${query}`);
    console.log(`🔍 Debug - Parâmetros:`, params);
    const connection = await getConnection();
    const [rows] = await connection.execute(query, params);
    console.log(`🔍 Debug - Resultado:`, rows.length > 0 ? 'Encontrado' : 'Não encontrado');
    return rows.length > 0 ? rows[0] : null;
  } catch (error) {
    console.error(`❌ Erro em executeSingleQuery:`, error);
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
    console.log(`🔍 Debug - Executando query: ${query}`);
    console.log(`🔍 Debug - Valores:`, values);
    await connection.execute(query, values);
  } catch (error) {
    console.error(`❌ Erro em updateData para tabela ${table}:`, error);
    throw error;
  }
};

// Rota para testar tabela auth_users
app.get('/api/test-auth-users', async (req, res) => {
  try {
    console.log('🔍 Testando tabela auth_users...');
    const result = await executeQuery('SELECT COUNT(*) as count FROM auth_users');
    console.log('✅ Tabela auth_users existe:', result);
    
    const users = await executeQuery('SELECT id, username, name, role FROM auth_users LIMIT 5');
    console.log('✅ Usuários encontrados:', users);
    
    res.json({
      success: true,
      message: 'Tabela auth_users funcionando',
      count: result[0].count,
      users: users
    });
  } catch (error) {
    console.error('❌ Erro ao testar auth_users:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para login
app.post('/api/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    console.log(`🔍 Debug - Login attempt: username=${username}, password=${password ? '***' : 'empty'}`);

    if (!username || !password) {
      return res.status(400).json({ 
        success: false, 
        error: 'Username e password são obrigatórios' 
      });
    }

    // Normalizar username
    const normalizedUsername = username.replace('@', '').toLowerCase();
    console.log(`🔍 Debug - Normalized username: ${normalizedUsername}`);

    // Buscar usuário na tabela auth_users
    console.log(`🔍 Debug - Executando query: SELECT * FROM auth_users WHERE username = ? AND password = ?`);
    
    const user = await executeSingleQuery(
      'SELECT id, username, name, role, full_name, instagram, phone, is_active, created_at, updated_at FROM auth_users WHERE username = ? AND password = ?',
      [normalizedUsername, password]
    );
    console.log(`🔍 Debug - Resultado da query:`, user ? 'Usuário encontrado' : 'Usuário não encontrado');

    if (!user) {
      return res.status(401).json({ 
        success: false, 
        error: 'Usuário ou senha incorretos' 
      });
    }

    // Ativar usuário após login bem-sucedido
    console.log(`🔍 Debug - Ativando usuário ID: ${user.id}`);
    // Temporariamente comentado para debug
    /*
    await updateData('auth_users', {
      is_active: true,
      last_login: new Date().toISOString()
    }, { id: user.id });
    */

    // Atualizar status do usuário na tabela members para "Ativo" (se tiver instagram)
    // Temporariamente comentado para debug
    /*
    if (user.instagram) {
      await updateData('members', {
        status: 'Ativo',
        updated_at: new Date().toISOString()
      }, { instagram: user.instagram });
    }
    */

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

    console.log(`🔍 Debug - Login bem-sucedido para: ${user.name}`);
    res.json({ 
      success: true, 
      user: userData,
      message: `Bem-vindo, ${user.name}!`
    });

  } catch (error) {
    console.error(`❌ Erro no login:`, error);
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

    // Buscar status da fase baseado na contagem de membros
    const phaseStatusResult = await executeQuery('SELECT get_phase_status() as status');
    const phaseStatus = JSON.parse(phaseStatusResult[0].status);

    res.json({ 
      success: true, 
      settings: settingsData,
      phase_status: phaseStatus
    });

  } catch (error) {
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
      
      const count = members.filter(member => {
        // Usar UTC para ambas as datas para evitar problemas de fuso horário
        const memberDateStr = new Date(member.registration_date).toISOString().split('T')[0];
        return memberDateStr === dateStr;
      }).length;
      
      registrationsByDay.push({
        date: date.toLocaleDateString('pt-BR', { 
          day: '2-digit', 
          month: '2-digit' 
        }),
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
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota de teste para verificar se o servidor está funcionando
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'Servidor funcionando!',
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || 'development'
  });
});

// Rota para verificar views do banco de dados
app.get('/api/test-views', async (req, res) => {
  try {
    console.log('🔍 Testando views do banco de dados...');
    
    const results = {
      success: true,
      message: 'Views testadas',
      errors: [],
      definitions: {},
      tables: {}
    };
    
    // Verificar estrutura das tabelas principais
    const membersColumns = await executeQuery('DESCRIBE members');
    console.log('✅ Colunas da tabela members:', membersColumns);
    results.tables.members = membersColumns;
    
    const authUsersColumns = await executeQuery('DESCRIBE auth_users');
    console.log('✅ Colunas da tabela auth_users:', authUsersColumns);
    results.tables.auth_users = authUsersColumns;
    
    // Verificar se tabela paid_contracts existe
    try {
      const paidContractsColumns = await executeQuery('DESCRIBE paid_contracts');
      console.log('✅ Colunas da tabela paid_contracts:', paidContractsColumns);
      results.tables.paid_contracts = paidContractsColumns;
    } catch (error) {
      console.error('❌ Tabela paid_contracts não existe:', error.message);
      results.errors.push({
        table: 'paid_contracts',
        error: error.message
      });
    }
    
    // Testar view v_member_ranking
    try {
      const memberRanking = await executeQuery('SELECT * FROM v_member_ranking LIMIT 5');
      console.log('✅ View v_member_ranking funcionando:', memberRanking);
    } catch (error) {
      console.error('❌ Erro na view v_member_ranking:', error.message);
      results.errors.push({
        view: 'v_member_ranking',
        error: error.message
      });
    }
    
    // Testar view v_system_status
    try {
      const systemStatus = await executeQuery('SELECT * FROM v_system_status LIMIT 5');
      console.log('✅ View v_system_status funcionando:', systemStatus);
    } catch (error) {
      console.error('❌ Erro na view v_system_status:', error.message);
      results.errors.push({
        view: 'v_system_status',
        error: error.message
      });
    }
    
    // Verificar definição das views
    try {
      const memberRankingDef = await executeQuery('SHOW CREATE VIEW v_member_ranking');
      console.log('✅ Definição da view v_member_ranking:', memberRankingDef);
      results.definitions.v_member_ranking = memberRankingDef[0]['Create View'];
    } catch (error) {
      console.error('❌ Erro ao obter definição da view v_member_ranking:', error.message);
      results.errors.push({
        view: 'v_member_ranking_definition',
        error: error.message
      });
    }
    
    try {
      const systemStatusDef = await executeQuery('SHOW CREATE VIEW v_system_status');
      console.log('✅ Definição da view v_system_status:', systemStatusDef);
      results.definitions.v_system_status = systemStatusDef[0]['Create View'];
    } catch (error) {
      console.error('❌ Erro ao obter definição da view v_system_status:', error.message);
      results.errors.push({
        view: 'v_system_status_definition',
        error: error.message
      });
    }
    
    res.json(results);
  } catch (error) {
    console.error('❌ Erro ao testar views:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para corrigir views do banco de dados
app.post('/api/fix-views', async (req, res) => {
  try {
    console.log('🔧 Corrigindo views do banco de dados...');
    
    const results = {
      success: true,
      message: 'Views corrigidas',
      operations: []
    };
    
    // 1. Corrigir view v_member_ranking (remover dependência de paid_contracts)
    try {
      console.log('🔧 Corrigindo view v_member_ranking...');
      
      // Dropar a view existente
      await executeQuery('DROP VIEW IF EXISTS v_member_ranking');
      console.log('✅ View v_member_ranking removida');
      
      // Criar nova view sem dependência de paid_contracts
      const createMemberRankingView = `
        CREATE VIEW v_member_ranking AS
        SELECT 
          m.id,
          m.name,
          m.instagram,
          m.city,
          m.sector,
          m.contracts_completed,
          m.ranking_position,
          m.ranking_status,
          m.is_top_1500,
          m.can_be_replaced,
          m.contracts_completed as total_contracts,
          m.contracts_completed as completed_contracts,
          0 as pending_contracts
        FROM members m
        WHERE m.status = 'Ativo'
        ORDER BY m.ranking_position
      `;
      
      await executeQuery(createMemberRankingView);
      console.log('✅ View v_member_ranking criada com sucesso');
      
      results.operations.push({
        operation: 'fix_v_member_ranking',
        status: 'success',
        message: 'View corrigida removendo dependência de paid_contracts'
      });
      
    } catch (error) {
      console.error('❌ Erro ao corrigir v_member_ranking:', error.message);
      results.operations.push({
        operation: 'fix_v_member_ranking',
        status: 'error',
        message: error.message
      });
    }
    
    // 2. Criar view v_system_status
    try {
      console.log('🔧 Criando view v_system_status...');
      
      const createSystemStatusView = `
        CREATE VIEW v_system_status AS
        SELECT 
          'members' as table_name,
          COUNT(*) as total_records,
          COUNT(CASE WHEN status = 'Ativo' THEN 1 END) as active_records,
          COUNT(CASE WHEN status = 'Inativo' THEN 1 END) as inactive_records
        FROM members
        WHERE deleted_at IS NULL
        
        UNION ALL
        
        SELECT 
          'auth_users' as table_name,
          COUNT(*) as total_records,
          COUNT(CASE WHEN is_active = 1 THEN 1 END) as active_records,
          COUNT(CASE WHEN is_active = 0 THEN 1 END) as inactive_records
        FROM auth_users
      `;
      
      await executeQuery(createSystemStatusView);
      console.log('✅ View v_system_status criada com sucesso');
      
      results.operations.push({
        operation: 'create_v_system_status',
        status: 'success',
        message: 'View v_system_status criada com sucesso'
      });
      
    } catch (error) {
      console.error('❌ Erro ao criar v_system_status:', error.message);
      results.operations.push({
        operation: 'create_v_system_status',
        status: 'error',
        message: error.message
      });
    }
    
    res.json(results);
  } catch (error) {
    console.error('❌ Erro ao corrigir views:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para gerar link de cadastro usando função MySQL (equivalente ao Supabase)
app.post('/api/generate-link', async (req, res) => {
  try {
    console.log('🔍 Debug - generate-link chamado');
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
      member_links_type: 'friends' // Valor padrão: friends
    };

    settings.forEach(item => {
      if (item.setting_key === 'member_links_type') {
        settingsData.member_links_type = item.setting_value;
      }
    });

    console.log('🔍 Debug - Configurações lidas do banco:', settings);
    console.log('🔍 Debug - Configurações finais:', settingsData);

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
        full_url: `${req.protocol}://${req.get('host')}/cadastro/${link_id}`,
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
});

// Rota para ativar usuário auth_users
app.put('/api/auth-users/:id/activate', async (req, res) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: 'ID do usuário é obrigatório'
      });
    }

    // Ativar usuário
    await executeQuery(
      'UPDATE auth_users SET is_active = true, updated_at = ? WHERE id = ?',
      [new Date().toISOString(), id]
    );

    res.json({
      success: true,
      message: 'Usuário ativado com sucesso'
    });

  } catch (error) {
    console.error('❌ Erro ao ativar usuário:', error);
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

    // Buscar apenas o link único ativo do usuário
    const link = await executeSingleQuery(
      'SELECT * FROM user_links WHERE user_id = ? AND is_active = true ORDER BY created_at DESC LIMIT 1',
      [userId]
    );

    res.json({
      success: true,
      link: link || null,
      links: link ? [link] : [] // Manter compatibilidade com frontend
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para alterar tipo de link (apenas administradores)
app.post('/api/update-link-type', async (req, res) => {
  try {
    console.log('🔍 Debug - update-link-type chamado');
    console.log('🔍 Debug - req.body:', req.body);
    console.log('🔍 Debug - Content-Type:', req.headers['content-type']);
    
    const { linkType } = req.body;

    if (!linkType || !['members', 'friends'].includes(linkType)) {
      console.log('❌ Debug - Tipo de link inválido:', linkType);
      return res.status(400).json({
        success: false,
        error: 'Tipo de link deve ser "members" ou "friends"'
      });
    }

    console.log('🔍 Debug - Atualizando tipo de link para:', linkType);

    // Atualizar configuração do sistema
    await executeQuery(
      'UPDATE system_settings SET setting_value = ? WHERE setting_key = "member_links_type"',
      [linkType]
    );

    // Atualizar links existentes dos membros (não administradores)
    console.log('🔍 Debug - Atualizando links existentes dos membros...');
    
    // Buscar todos os usuários que não são administradores
    console.log('🔍 Debug - Buscando usuários não-administradores...');
    const nonAdminUsers = await executeQuery(`
      SELECT au.id, au.role
      FROM auth_users au 
      WHERE au.role NOT IN ('Administrador', 'Felipe Admin')
    `);
    
    console.log('🔍 Debug - Usuários não-administradores encontrados:', nonAdminUsers);

    let updatedLinksCount = 0;
    
    if (nonAdminUsers.length > 0) {
      // Atualizar links dos usuários não-administradores
      const userIds = nonAdminUsers.map(user => user.id);
      const placeholders = userIds.map(() => '?').join(',');
      
      console.log('🔍 Debug - IDs dos usuários para atualizar:', userIds);
      console.log('🔍 Debug - Query de atualização:', `UPDATE user_links SET link_type = ?, updated_at = NOW() WHERE user_id IN (${placeholders})`);
      
      const updateResult = await executeQuery(
        `UPDATE user_links 
         SET link_type = ?, updated_at = NOW() 
         WHERE user_id IN (${placeholders})`,
        [linkType, ...userIds]
      );
      
      updatedLinksCount = updateResult.affectedRows || 0;
      console.log('🔍 Debug - Resultado da atualização:', updateResult);
      console.log('🔍 Debug - Links atualizados:', updatedLinksCount);
    } else {
      console.log('🔍 Debug - Nenhum usuário não-administrador encontrado');
    }

    const response = {
      success: true,
      message: `Tipo de link alterado para: ${linkType === 'members' ? 'Novos Membros' : 'Amigos'}. ${updatedLinksCount} links de usuários "Membro" foram atualizados. Links de Administradores e Felipe Admin mantidos.`,
      updated_links_count: updatedLinksCount
    };

    console.log('🔍 Debug - Resposta enviada:', response);
    res.json(response);

  } catch (error) {
    console.log('❌ Debug - Erro em update-link-type:', error);
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
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para salvar membro (para PublicRegister)
app.post('/api/members', async (req, res) => {
  try {
    console.log('🔍 Debug - POST /api/members chamado');
    console.log('🔍 Debug - req.body:', req.body);
    console.log('🔍 Debug - Content-Type:', req.headers['content-type']);
    
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

    // Verificar se já existe um membro com o mesmo telefone ou Instagram que foi excluído (soft delete)
    const existingDeletedMember = await executeSingleQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM members WHERE (phone = ? OR instagram = ?) AND deleted_at IS NOT NULL',
      [phone, instagram]
    );

    if (existingDeletedMember) {
      return res.status(400).json({
        success: false,
        error: `Este usuário já foi excluído anteriormente. Nome: ${existingDeletedMember.name}, Telefone: ${existingDeletedMember.phone}, Instagram: ${existingDeletedMember.instagram}, Excluído em: ${existingDeletedMember.deleted_at}`
      });
    }

    // Verificar se já existe um membro ativo com o mesmo telefone ou Instagram
    const existingActiveMember = await executeSingleQuery(
      'SELECT id, name, phone, instagram FROM members WHERE (phone = ? OR instagram = ?) AND deleted_at IS NULL',
      [phone, instagram]
    );

    if (existingActiveMember) {
      return res.status(400).json({
        success: false,
        error: `Já existe um membro cadastrado com estes dados. Nome: ${existingActiveMember.name}, Telefone: ${existingActiveMember.phone}, Instagram: ${existingActiveMember.instagram}`
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

    const response = {
      success: true,
      data: {
        id: insertId,
        ...memberData
      }
    };

    console.log('🔍 Debug - Resposta POST /api/members:', response);
    res.json(response);

  } catch (error) {
    console.log('❌ Debug - Erro em POST /api/members:', error);
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

    // Verificar se já existe um amigo com o mesmo telefone ou Instagram que foi excluído (soft delete)
    const existingDeletedFriend = await executeSingleQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM friends WHERE (phone = ? OR instagram = ?) AND deleted_at IS NOT NULL',
      [phone, instagram]
    );

    if (existingDeletedFriend) {
      return res.status(400).json({
        success: false,
        error: `Este amigo já foi excluído anteriormente. Nome: ${existingDeletedFriend.name}, Telefone: ${existingDeletedFriend.phone}, Instagram: ${existingDeletedFriend.instagram}, Excluído em: ${existingDeletedFriend.deleted_at}`
      });
    }

    // Verificar se já existe um amigo ativo com o mesmo telefone ou Instagram
    const existingActiveFriend = await executeSingleQuery(
      'SELECT id, name, phone, instagram FROM friends WHERE (phone = ? OR instagram = ?) AND deleted_at IS NULL',
      [phone, instagram]
    );

    if (existingActiveFriend) {
      return res.status(400).json({
        success: false,
        error: `Já existe um amigo cadastrado com estes dados. Nome: ${existingActiveFriend.name}, Telefone: ${existingActiveFriend.phone}, Instagram: ${existingActiveFriend.instagram}`
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
      'INSERT INTO friends (name, phone, instagram, city, sector, referrer, registration_date, status, couple_name, couple_phone, couple_instagram, couple_city, couple_sector, member_id, contracts_completed, ranking_status, is_top_1500, can_be_replaced, post_verified_1, post_verified_2, post_url_1, post_url_2) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
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
        friendData.post_url_2
      ]
    );

    const insertId = result.insertId;

             // Atualizar membro após cadastro do amigo (sem conflito com triggers)
             try {
               // Contar amigos ativos do membro
               const friendsCountResult = await executeQuery(
                 'SELECT COUNT(*) as count FROM friends WHERE member_id = ? AND deleted_at IS NULL',
                 [friendData.member_id]
               );
               
               const friendsCount = friendsCountResult[0].count;
               
               // Atualizar contratos do membro
               await executeQuery(
                 'UPDATE members SET contracts_completed = ?, updated_at = NOW() WHERE id = ?',
                 [friendsCount, friendData.member_id]
               );
               
               console.log(`✅ Membro ID ${friendData.member_id} atualizado com ${friendsCount} contratos`);
               
               // Atualizar ranking automaticamente após cadastro de amigo
               console.log('🔄 Atualizando ranking automaticamente...');
               try {
                 // Buscar todos os membros ativos ordenados por contratos
                 const membersWithContracts = await executeQuery(
                   `SELECT id, contracts_completed 
                    FROM members 
                    WHERE deleted_at IS NULL 
                    ORDER BY contracts_completed DESC, id ASC`
                 );
                 
                 // Atualizar ranking de todos os membros
                 for (let i = 0; i < membersWithContracts.length; i++) {
                   const member = membersWithContracts[i];
                   const contracts = member.contracts_completed;
                   const rankingPosition = i + 1;
                   
                   // Calcular status baseado nos contratos
                   let rankingStatus = 'Vermelho';
                   let status = 'Inativo';
                   let isTop1500 = false;
                   let canBeReplaced = true;
                   
                   if (contracts >= 15) {
                     rankingStatus = 'Verde';
                     status = 'Ativo';
                     isTop1500 = true;
                     canBeReplaced = false;
                   } else if (contracts >= 1) {
                     rankingStatus = 'Amarelo';
                     status = 'Ativo'; // Mudado de 'Em Progresso' para 'Ativo'
                     isTop1500 = false;
                     canBeReplaced = true;
                   } else {
                     rankingStatus = 'Vermelho';
                     status = 'Inativo';
                     isTop1500 = false;
                     canBeReplaced = true;
                   }
                   
                   // Atualizar ranking do membro
                   await executeQuery(
                     `UPDATE members SET 
                       ranking_position = ?,
                       ranking_status = ?,
                       status = ?,
                       is_top_1500 = ?,
                       can_be_replaced = ?,
                       updated_at = NOW()
                     WHERE id = ?`,
                     [rankingPosition, rankingStatus, status, isTop1500, canBeReplaced, member.id]
                   );
                 }
                 
                 console.log('✅ Ranking atualizado automaticamente após cadastro de amigo');
               } catch (rankingError) {
                 console.error('❌ Erro ao atualizar ranking automaticamente:', rankingError);
               }
               
             } catch (updateError) {
               console.error('Erro ao atualizar membro após cadastro de amigo:', updateError);
             }

    res.json({
      success: true,
      data: {
        id: insertId,
        ...friendData
      }
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para buscar usuários de autenticação
app.get('/api/auth-users', async (req, res) => {
  try {
    const { search, role } = req.query;

    let query = 'SELECT id, username, name, role, full_name, instagram, phone, is_active, created_at, updated_at FROM auth_users';
    let params = [];

    if (search) {
      query += ' WHERE (name LIKE ? OR username LIKE ? OR full_name LIKE ?)';
      const searchTerm = `%${search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    if (role) {
      if (params.length > 0) {
        query += ' AND role = ?';
      } else {
        query += ' WHERE role = ?';
      }
      params.push(role);
    }

    query += ' ORDER BY created_at DESC';

    const users = await executeQuery(query, params);

    res.json({
      success: true,
      users: users
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para criar usuário de autenticação (para PublicRegister)
// Endpoint para criar usuário com credenciais baseadas nos dados do membro
app.post('/api/auth-users/from-member', async (req, res) => {
  try {
    const { member_id } = req.body;

    // Validar campos obrigatórios
    if (!member_id) {
      return res.status(400).json({
        success: false,
        error: 'member_id é obrigatório'
      });
    }

    // Buscar dados do membro
    const memberResult = await executeQuery(
      'SELECT id, name, instagram, phone FROM members WHERE id = ? AND deleted_at IS NULL',
      [member_id]
    );

    if (!memberResult || memberResult.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Membro não encontrado'
      });
    }

    const member = memberResult[0];

    // Gerar username baseado no Instagram (sem @) ou nome
    let username = '';
    if (member.instagram) {
      username = member.instagram.replace('@', '');
    } else {
      username = member.name.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '');
    }

    // Gerar senha: Instagram + últimos 4 dígitos do telefone
    let password = '';
    if (member.instagram && member.phone) {
      const instagramClean = member.instagram.replace('@', '');
      const lastFourDigits = member.phone.slice(-4);
      password = instagramClean + lastFourDigits;
    } else {
      password = '123456'; // Fallback se não tiver Instagram ou telefone
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

    // Criar usuário na tabela auth_users
    const authUserData = {
      username,
      password,
      name: member.name.trim(),
      role: 'Membro',
      full_name: member.name.trim(),
      instagram: member.instagram || null,
      phone: member.phone || null,
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const result = await executeQuery(
      'INSERT INTO auth_users (username, password, name, role, full_name, instagram, phone, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        authUserData.username,
        authUserData.password,
        authUserData.name,
        authUserData.role,
        authUserData.full_name,
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
        username: authUserData.username,
        password: authUserData.password,
        member_id: member_id,
        is_active: false,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      credentials: {
        username: authUserData.username,
        password: authUserData.password
      }
    });

  } catch (error) {
    console.error('❌ Erro ao criar usuário do membro:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

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
      instagram: instagram || null,
      phone: phone || null,
      is_active: is_active !== undefined ? is_active : false,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    const result = await executeQuery(
      'INSERT INTO auth_users (username, password, name, role, full_name, instagram, phone, is_active, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        authUserData.username,
        authUserData.password,
        authUserData.name,
        authUserData.role,
        authUserData.full_name,
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
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para atualizar fase automaticamente baseada na contagem de membros
app.post('/api/system-settings/update-phase', async (req, res) => {
  try {
    // Contar membros ativos
    const membersCountResult = await executeQuery(
      'SELECT COUNT(*) as count FROM members WHERE deleted_at IS NULL'
    );
    
    const totalMembers = membersCountResult[0].count;
    
    // Buscar fase atual
    const currentPhaseResult = await executeQuery(
      'SELECT setting_value FROM system_settings WHERE setting_key = "current_phase"'
    );
    
    const currentPhase = currentPhaseResult[0]?.setting_value || 'Fase 1';
    
    let newPhase = 'Fase 1';
    if (totalMembers >= 1500) {
      newPhase = 'Fase 3';
    } else if (totalMembers >= 500) {
      newPhase = 'Fase 2';
    }
    
    // Atualizar fase se necessário
    if (newPhase !== currentPhase) {
      await executeQuery(
        'UPDATE system_settings SET setting_value = ?, updated_at = NOW() WHERE setting_key = "current_phase"',
        [newPhase]
      );
    }
    
    // Buscar configurações atualizadas
    const settings = await executeQuery('SELECT setting_key, setting_value FROM system_settings');
    const settingsData = {};
    
    settings.forEach(item => {
      settingsData[item.setting_key] = item.setting_value;
    });

    // Criar status da fase
    const phaseStatus = {
      current_phase: newPhase,
      total_members: totalMembers,
      phase_1_limit: 500,
      phase_2_limit: 1500,
      phase_3_limit: 999999
    };

    res.json({
      success: true,
      message: 'Fase atualizada',
      phase_status: phaseStatus,
      settings: settingsData
    });

  } catch (error) {
    console.error('❌ Erro ao atualizar fase:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Rota para atualizar tipo de links de todos os usuários
app.put('/api/system-settings/link-type', async (req, res) => {
  try {
    const { link_type } = req.body;

    if (!link_type || !['members', 'friends'].includes(link_type)) {
      return res.status(400).json({
        success: false,
        error: 'Tipo de link inválido. Deve ser "members" ou "friends"'
      });
    }

    // 1. Atualizar configuração do sistema
    await executeQuery(
      'UPDATE system_settings SET setting_value = ? WHERE setting_key = ?',
      [link_type, 'member_links_type']
    );

    // 2. Atualizar todos os links existentes (apenas para usuários do tipo "Membro")
    const updateResult = await executeQuery(
      `UPDATE user_links ul 
       INNER JOIN auth_users au ON ul.user_id = au.id 
       SET ul.link_type = ?, ul.updated_at = NOW() 
       WHERE au.role = 'Membro'`,
      [link_type]
    );

    // 3. Buscar configurações atualizadas para retornar
    const settings = await executeQuery('SELECT setting_key, setting_value FROM system_settings');
    const settingsData = {};
    
    settings.forEach(item => {
      settingsData[item.setting_key] = item.setting_value;
    });

    res.json({
      success: true,
      message: `Tipo de links atualizado para ${link_type}. ${updateResult.affectedRows || 0} links de usuários "Membro" foram atualizados. Links de Administradores e Felipe Admin mantidos.`,
      settings: settingsData,
      updated_links_count: updateResult.affectedRows || 0
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint temporário para verificar dados dos membros
app.get('/api/admin/debug-members', async (req, res) => {
  try {
    const [rows] = await executeQuery(`
      SELECT 
        id, 
        name, 
        ranking_status, 
        referrer, 
        contracts_completed,
        ranking_position
      FROM members 
      WHERE deleted_at IS NULL 
      ORDER BY id DESC 
      LIMIT 5
    `);
    
    // Verificar caracteres especiais
    const debugData = Array.isArray(rows) ? rows.map(member => ({
      id: member.id,
      name: member.name,
      ranking_status: member.ranking_status,
      referrer: member.referrer
    })) : [];
    
    res.json({
      success: true,
      data: debugData
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});








// Endpoint para soft delete de membros (com cascade)
app.delete('/api/members/:id', async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`🗑️ Iniciando soft delete do membro ID: ${id}`);
    
    // Verificar se o membro existe e não está deletado
    const existingMemberResult = await executeQuery(
      'SELECT id, name, instagram FROM members WHERE id = ? AND deleted_at IS NULL',
      [id]
    );
    
    if (!existingMemberResult || existingMemberResult.length === 0) {
      console.log(`❌ Membro ID ${id} não encontrado ou já foi excluído`);
      return res.status(404).json({
        success: false,
        error: 'Membro não encontrado ou já foi excluído'
      });
    }
    
    const existingMember = existingMemberResult[0];
    console.log(`✅ Membro encontrado: ${existingMember.name} (Instagram: ${existingMember.instagram})`);
    
    let deletedItems = [];
    
    // Buscar auth_user_id do membro usando diferentes estratégias
    let authUser = null;
    
    // Estratégia 1: Buscar por username = instagram sem @
    if (existingMember.instagram) {
      const instagramUsername = existingMember.instagram.replace('@', '');
      console.log(`🔍 Buscando auth_user por username: ${instagramUsername}`);
      
      const authUserResult = await executeQuery(
        'SELECT id, username, name FROM auth_users WHERE username = ?',
        [instagramUsername]
      );
      
      if (authUserResult && authUserResult.length > 0) {
        authUser = authUserResult[0];
        console.log(`✅ Auth_user encontrado por username: ${authUser.username} (ID: ${authUser.id})`);
      }
    }
    
    // Estratégia 2: Se não encontrou, buscar por nome
    if (!authUser) {
      console.log(`🔍 Buscando auth_user por nome: ${existingMember.name}`);
      
      const authUserResult = await executeQuery(
        'SELECT id, username, name FROM auth_users WHERE name = ?',
        [existingMember.name]
      );
      
      if (authUserResult && authUserResult.length > 0) {
        authUser = authUserResult[0];
        console.log(`✅ Auth_user encontrado por nome: ${authUser.name} (ID: ${authUser.id})`);
      }
    }
    
    if (authUser && authUser.id) {
      const authUserId = authUser.id;
      console.log(`🗑️ Deletando dados relacionados ao auth_user ID: ${authUserId}`);
      
      // Buscar e deletar user_links
      const userLinksResult = await executeQuery(
        'SELECT id FROM user_links WHERE user_id = ?',
        [authUserId] // Usar o ID do auth_user
      );
      
      if (userLinksResult && userLinksResult.length > 0) {
        await executeQuery(
          'DELETE FROM user_links WHERE user_id = ?',
          [authUserId]
        );
        deletedItems.push(`${userLinksResult.length} user link(s)`);
        console.log(`✅ ${userLinksResult.length} user_links deletados`);
      }
      
      // Deletar auth_user
      await executeQuery(
        'DELETE FROM auth_users WHERE id = ?',
        [authUserId]
      );
      deletedItems.push('auth_user');
      console.log(`✅ Auth_user deletado`);
    } else {
      console.log(`ℹ️ Nenhum auth_user encontrado para o membro ${existingMember.name}`);
    }
    
    // Soft delete do membro (apenas deleted_at)
    await executeQuery(
      'UPDATE members SET deleted_at = NOW() WHERE id = ?',
      [id]
    );
    console.log(`✅ Membro ${existingMember.name} marcado como deletado`);
    
    const message = `Membro "${existingMember.name}" foi excluído com sucesso. ${deletedItems.length > 0 ? 'Itens removidos: ' + deletedItems.join(', ') : 'Nenhum item associado encontrado.'}`;
    
    res.json({
      success: true,
      message: message,
      data: { 
        id, 
        name: existingMember.name,
        deletedItems: deletedItems
      }
    });
    
  } catch (error) {
    console.error(`❌ Erro ao deletar membro ID ${req.params.id}:`, error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para soft delete de amigos
app.delete('/api/friends/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar se o amigo existe e não está deletado
    const [existingFriend] = await executeQuery(
      'SELECT id, name FROM friends WHERE id = ? AND deleted_at IS NULL',
      [id]
    );
    
    if (!existingFriend) {
      return res.status(404).json({
        success: false,
        error: 'Amigo não encontrado ou já foi excluído'
      });
    }
    
    // Executar soft delete
    await executeQuery(
      'UPDATE friends SET deleted_at = NOW() WHERE id = ?',
      [id]
    );
    
    res.json({
      success: true,
      message: `Amigo "${existingFriend.name}" foi excluído com sucesso`,
      data: { id, name: existingFriend.name }
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para corrigir dados corrompidos dos membros
app.post('/api/admin/fix-member-data', async (req, res) => {
  try {
    // Corrigir ranking_status removendo caracteres extras
    await executeQuery(`
      UPDATE members 
      SET ranking_status = CASE 
        WHEN ranking_status LIKE '%Verde%' THEN 'Verde'
        WHEN ranking_status LIKE '%Amarelo%' THEN 'Amarelo'
        WHEN ranking_status LIKE '%Vermelho%' THEN 'Vermelho'
        ELSE ranking_status
      END
      WHERE deleted_at IS NULL
    `);
    
    // Corrigir referrer removendo caracteres extras (assumindo que deve ser apenas o nome)
    await executeQuery(`
      UPDATE members 
      SET referrer = TRIM(REGEXP_REPLACE(referrer, '[^a-zA-Z\\s]', ''))
      WHERE deleted_at IS NULL AND referrer IS NOT NULL
    `);
    
    res.json({
      success: true,
      message: 'Dados dos membros corrigidos com sucesso'
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para atualizar ranking de todos os membros

// Endpoint para criar triggers de soft delete de membros
app.post('/api/admin/create-member-soft-delete-triggers', async (req, res) => {
  try {
    console.log('🔧 Criando triggers para soft delete de membros...');
    
    // 1. Dropar triggers existentes se existirem
    try {
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_links_trigger');
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_auth_trigger');
      console.log('✅ Triggers antigas removidas');
    } catch (error) {
      console.log('ℹ️ Nenhuma trigger anterior encontrada');
    }
    
    // 2. Criar trigger para HARD DELETE user_links quando membro for soft deletado
    const createLinksTriggerSQL = `
      CREATE TRIGGER soft_delete_member_links_trigger
      AFTER UPDATE ON members
      FOR EACH ROW
      BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
          DELETE FROM user_links WHERE user_id = NEW.id;
        END IF;
      END
    `;
    
    await executeQuery(createLinksTriggerSQL);
    console.log('✅ Trigger para HARD DELETE user_links criada');
    
    // 3. Criar trigger para HARD DELETE auth_users quando membro for soft deletado
    const createAuthTriggerSQL = `
      CREATE TRIGGER soft_delete_member_auth_trigger
      AFTER UPDATE ON members
      FOR EACH ROW
      BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
          DELETE FROM auth_users WHERE id = NEW.id;
        END IF;
      END
    `;
    
    await executeQuery(createAuthTriggerSQL);
    console.log('✅ Trigger para HARD DELETE auth_users criada');
    
    res.json({
      success: true,
      message: 'Triggers de exclusão híbrida de membros criadas com sucesso!',
      triggers: [
        'soft_delete_member_links_trigger - HARD DELETE user_links quando membro é soft deletado',
        'soft_delete_member_auth_trigger - HARD DELETE auth_users quando membro é soft deletado'
      ],
      behavior: {
        member: 'Soft delete (apenas deleted_at preenchido)',
        user_links: 'Hard delete (removido fisicamente)',
        auth_users: 'Hard delete (removido fisicamente)'
      }
    });
    
  } catch (error) {
    console.error('❌ Erro ao criar triggers:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para forçar recriação das triggers (limpa e recria)
app.post('/api/admin/force-recreate-triggers', async (req, res) => {
  try {
    console.log('🔧 Forçando recriação das triggers...');
    
    // 1. Dropar TODAS as triggers relacionadas
    try {
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_links_trigger');
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_auth_trigger');
      console.log('✅ Todas as triggers antigas removidas');
    } catch (error) {
      console.log('ℹ️ Nenhuma trigger anterior encontrada');
    }
    
    // 2. Aguardar um pouco para garantir que as triggers foram removidas
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // 3. Criar trigger para HARD DELETE user_links quando membro for soft deletado
    const createLinksTriggerSQL = `
      CREATE TRIGGER soft_delete_member_links_trigger
      AFTER UPDATE ON members
      FOR EACH ROW
      BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
          DELETE FROM user_links WHERE user_id = NEW.id;
        END IF;
      END
    `;
    
    await executeQuery(createLinksTriggerSQL);
    console.log('✅ Trigger para HARD DELETE user_links criada');
    
    // 4. Criar trigger para HARD DELETE auth_users quando membro for soft deletado
    const createAuthTriggerSQL = `
      CREATE TRIGGER soft_delete_member_auth_trigger
      AFTER UPDATE ON members
      FOR EACH ROW
      BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
          DELETE FROM auth_users WHERE id = NEW.id;
        END IF;
      END
    `;
    
    await executeQuery(createAuthTriggerSQL);
    console.log('✅ Trigger para HARD DELETE auth_users criada');
    
    res.json({
      success: true,
      message: 'Triggers recriadas com sucesso!',
      triggers: [
        'soft_delete_member_links_trigger',
        'soft_delete_member_auth_trigger'
      ]
    });
    
  } catch (error) {
    console.error('❌ Erro ao recriar triggers:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para configurar usuário Felipe como Felipe Admin
app.post('/api/admin/setup-felipe-admin', async (req, res) => {
  try {
    console.log('🔧 Configurando usuário Felipe como Felipe Admin...')
    
    // Verificar se o usuário Felipe existe
    const existingUsers = await executeQuery(
      'SELECT id, username, name, role FROM auth_users WHERE username = ?',
      ['felipe']
    )
    
    if (!existingUsers || existingUsers.length === 0) {
      console.log('❌ Usuário Felipe não encontrado. Criando...')
      
      // Criar usuário Felipe
      await executeQuery(
        `INSERT INTO auth_users (username, name, password, role, is_active, created_at) 
         VALUES (?, ?, ?, ?, ?, NOW())`,
        ['felipe', 'Felipe Admin', 'felipe123', 'Felipe Admin', 1]
      )
      
      console.log('✅ Usuário Felipe criado com sucesso!')
    } else {
      const existingUser = existingUsers[0]
      console.log(`📋 Usuário Felipe encontrado: ${existingUser.name} (Role: ${existingUser.role})`)
      
      // Atualizar role para Felipe Admin se necessário
      if (existingUser.role !== 'Felipe Admin') {
        await executeQuery(
          'UPDATE auth_users SET role = ? WHERE username = ?',
          ['Felipe Admin', 'felipe']
        )
        console.log('✅ Role do Felipe atualizado para "Felipe Admin"')
      } else {
        console.log('✅ Felipe já está configurado como Felipe Admin')
      }
    }
    
    // Verificar configuração final
    const finalUser = await executeQuery(
      'SELECT id, username, name, role, is_active FROM auth_users WHERE username = ?',
      ['felipe']
    )
    
    if (finalUser && finalUser.length > 0) {
      const user = finalUser[0]
      console.log('\n🎉 Configuração final do Felipe:')
      console.log(`   ID: ${user.id}`)
      console.log(`   Username: ${user.username}`)
      console.log(`   Nome: ${user.name}`)
      console.log(`   Role: ${user.role}`)
      console.log(`   Ativo: ${user.is_active ? 'Sim' : 'Não'}`)
      
      res.json({
        success: true,
        message: 'Felipe Admin configurado com sucesso!',
        user: user,
        credentials: {
          username: 'felipe',
          password: 'felipe123'
        }
      })
    } else {
      throw new Error('Erro ao verificar configuração final do Felipe')
    }
    
  } catch (error) {
    console.error('❌ Erro ao configurar Felipe Admin:', error)
    res.status(500).json({
      success: false,
      error: error.message
    })
  }
})

// Endpoint para reativar um membro que foi excluído (soft delete)
app.post('/api/admin/reactivate-member', async (req, res) => {
  try {
    const { phone, instagram } = req.body;

    if (!phone && !instagram) {
      return res.status(400).json({
        success: false,
        error: 'Telefone ou Instagram é obrigatório'
      });
    }

    // Buscar membro excluído
    let query = 'SELECT id, name, phone, instagram, deleted_at FROM members WHERE deleted_at IS NOT NULL';
    let params = [];
    
    if (phone && instagram) {
      query += ' AND (phone = ? OR instagram = ?)';
      params = [phone, instagram];
    } else if (phone) {
      query += ' AND phone = ?';
      params = [phone];
    } else if (instagram) {
      query += ' AND instagram = ?';
      params = [instagram];
    }
    
    const deletedMember = await executeSingleQuery(query, params);

    if (!deletedMember) {
      return res.status(404).json({
        success: false,
        error: 'Nenhum membro excluído encontrado com estes dados'
      });
    }

    // Verificar se já existe um membro ativo com os mesmos dados
    let activeQuery = 'SELECT id, name FROM members WHERE deleted_at IS NULL';
    let activeParams = [];
    
    if (phone && instagram) {
      activeQuery += ' AND (phone = ? OR instagram = ?)';
      activeParams = [phone, instagram];
    } else if (phone) {
      activeQuery += ' AND phone = ?';
      activeParams = [phone];
    } else if (instagram) {
      activeQuery += ' AND instagram = ?';
      activeParams = [instagram];
    }
    
    const activeMember = await executeSingleQuery(activeQuery, activeParams);

    if (activeMember) {
      return res.status(400).json({
        success: false,
        error: `Já existe um membro ativo com estes dados. Nome: ${activeMember.name}`
      });
    }

    // Reativar o membro (remover deleted_at)
    await executeQuery(
      'UPDATE members SET deleted_at = NULL, updated_at = NOW() WHERE id = ?',
      [deletedMember.id]
    );

    res.json({
      success: true,
      message: `Membro "${deletedMember.name}" foi reativado com sucesso!`,
      data: {
        id: deletedMember.id,
        name: deletedMember.name,
        phone: deletedMember.phone,
        instagram: deletedMember.instagram
      }
    });

  } catch (error) {
    console.error('❌ Erro ao reativar membro:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para reativar um amigo que foi excluído (soft delete)
app.post('/api/admin/reactivate-friend', async (req, res) => {
  try {
    const { phone, instagram } = req.body;

    if (!phone && !instagram) {
      return res.status(400).json({
        success: false,
        error: 'Telefone ou Instagram é obrigatório'
      });
    }

    // Buscar amigo excluído
    let query = 'SELECT id, name, phone, instagram, deleted_at FROM friends WHERE deleted_at IS NOT NULL';
    let params = [];
    
    if (phone && instagram) {
      query += ' AND (phone = ? OR instagram = ?)';
      params = [phone, instagram];
    } else if (phone) {
      query += ' AND phone = ?';
      params = [phone];
    } else if (instagram) {
      query += ' AND instagram = ?';
      params = [instagram];
    }
    
    const deletedFriend = await executeSingleQuery(query, params);

    if (!deletedFriend) {
      return res.status(404).json({
        success: false,
        error: 'Nenhum amigo excluído encontrado com estes dados'
      });
    }

    // Verificar se já existe um amigo ativo com os mesmos dados
    let activeQuery = 'SELECT id, name FROM friends WHERE deleted_at IS NULL';
    let activeParams = [];
    
    if (phone && instagram) {
      activeQuery += ' AND (phone = ? OR instagram = ?)';
      activeParams = [phone, instagram];
    } else if (phone) {
      activeQuery += ' AND phone = ?';
      activeParams = [phone];
    } else if (instagram) {
      activeQuery += ' AND instagram = ?';
      activeParams = [instagram];
    }
    
    const activeFriend = await executeSingleQuery(activeQuery, activeParams);

    if (activeFriend) {
      return res.status(400).json({
        success: false,
        error: `Já existe um amigo ativo com estes dados. Nome: ${activeFriend.name}`
      });
    }

    // Reativar o amigo (remover deleted_at)
    await executeQuery(
      'UPDATE friends SET deleted_at = NULL, updated_at = NOW() WHERE id = ?',
      [deletedFriend.id]
    );

    res.json({
      success: true,
      message: `Amigo "${deletedFriend.name}" foi reativado com sucesso!`,
      data: {
        id: deletedFriend.id,
        name: deletedFriend.name,
        phone: deletedFriend.phone,
        instagram: deletedFriend.instagram
      }
    });

  } catch (error) {
    console.error('❌ Erro ao reativar amigo:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para deletar fisicamente membros marcados como excluídos (soft delete) - SEM TRIGGERS
app.post('/api/admin/cleanup-without-triggers', async (req, res) => {
  try {
    console.log('🧹 Iniciando limpeza SEM TRIGGERS de membros excluídos...');
    
    // Remover todas as triggers relacionadas a membros
    console.log('🗑️ Removendo todas as triggers...');
    try {
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_links_trigger');
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_auth_trigger');
      await executeQuery('DROP TRIGGER IF EXISTS delete_member_auth_trigger');
      await executeQuery('DROP TRIGGER IF EXISTS delete_member_links_trigger');
      console.log('✅ Todas as triggers removidas');
    } catch (error) {
      console.log('ℹ️ Algumas triggers não existiam');
    }
    
    // Buscar todos os membros marcados como excluídos
    const deletedMembers = await executeQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM members WHERE deleted_at IS NOT NULL'
    );
    
    if (!deletedMembers || deletedMembers.length === 0) {
      return res.json({
        success: true,
        message: 'Nenhum membro excluído encontrado para limpeza',
        deletedCount: 0
      });
    }
    
    console.log(`📋 Encontrados ${deletedMembers.length} membros para limpeza física`);
    
    // Deletar todos os membros excluídos em uma única query
    const result = await executeQuery(
      'DELETE FROM members WHERE deleted_at IS NOT NULL'
    );
    
    const deletedCount = result.affectedRows || 0;
    
    console.log(`🎉 Limpeza SEM TRIGGERS concluída! ${deletedCount} membros deletados fisicamente`);
    
    res.json({
      success: true,
      message: `Limpeza SEM TRIGGERS concluída! ${deletedCount} membros deletados fisicamente`,
      deletedCount: deletedCount,
      totalFound: deletedMembers.length
    });
    
  } catch (error) {
    console.error('❌ Erro na limpeza sem triggers de membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para deletar fisicamente membros marcados como excluídos (soft delete) - DIRETO
app.post('/api/admin/direct-cleanup-deleted-members', async (req, res) => {
  try {
    console.log('🧹 Iniciando limpeza DIRETA de membros excluídos...');
    
    // Buscar todos os membros marcados como excluídos
    const deletedMembers = await executeQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM members WHERE deleted_at IS NOT NULL'
    );
    
    if (!deletedMembers || deletedMembers.length === 0) {
      return res.json({
        success: true,
        message: 'Nenhum membro excluído encontrado para limpeza',
        deletedCount: 0
      });
    }
    
    console.log(`📋 Encontrados ${deletedMembers.length} membros para limpeza física`);
    
    // Deletar todos os membros excluídos em uma única query
    const result = await executeQuery(
      'DELETE FROM members WHERE deleted_at IS NOT NULL'
    );
    
    const deletedCount = result.affectedRows || 0;
    
    console.log(`🎉 Limpeza DIRETA concluída! ${deletedCount} membros deletados fisicamente`);
    
    res.json({
      success: true,
      message: `Limpeza DIRETA concluída! ${deletedCount} membros deletados fisicamente`,
      deletedCount: deletedCount,
      totalFound: deletedMembers.length
    });
    
  } catch (error) {
    console.error('❌ Erro na limpeza direta de membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para deletar fisicamente membros marcados como excluídos (soft delete) - FORÇADO
app.post('/api/admin/force-cleanup-deleted-members', async (req, res) => {
  try {
    console.log('🧹 Iniciando limpeza FORÇADA de membros excluídos...');
    
    // Desabilitar triggers temporariamente
    console.log('🔧 Desabilitando triggers temporariamente...');
    await executeQuery('SET FOREIGN_KEY_CHECKS = 0');
    
    // Buscar todos os membros marcados como excluídos
    const deletedMembers = await executeQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM members WHERE deleted_at IS NOT NULL'
    );
    
    if (!deletedMembers || deletedMembers.length === 0) {
      await executeQuery('SET FOREIGN_KEY_CHECKS = 1');
      return res.json({
        success: true,
        message: 'Nenhum membro excluído encontrado para limpeza',
        deletedCount: 0
      });
    }
    
    console.log(`📋 Encontrados ${deletedMembers.length} membros para limpeza física`);
    
    let deletedCount = 0;
    let errors = [];
    
    // Deletar cada membro fisicamente
    for (const member of deletedMembers) {
      try {
        console.log(`🗑️ Deletando fisicamente: ${member.name} (ID: ${member.id})`);
        
        // Deletar fisicamente o membro
        await executeQuery(
          'DELETE FROM members WHERE id = ?',
          [member.id]
        );
        
        deletedCount++;
        console.log(`✅ Membro ${member.name} deletado fisicamente`);
        
      } catch (error) {
        console.error(`❌ Erro ao deletar membro ${member.name}:`, error);
        errors.push({
          member: member.name,
          id: member.id,
          error: error.message
        });
      }
    }
    
    // Reabilitar triggers
    console.log('🔧 Reabilitando triggers...');
    await executeQuery('SET FOREIGN_KEY_CHECKS = 1');
    
    console.log(`🎉 Limpeza FORÇADA concluída! ${deletedCount} membros deletados fisicamente`);
    
    res.json({
      success: true,
      message: `Limpeza FORÇADA concluída! ${deletedCount} membros deletados fisicamente`,
      deletedCount: deletedCount,
      totalFound: deletedMembers.length,
      errors: errors
    });
    
  } catch (error) {
    console.error('❌ Erro na limpeza forçada de membros:', error);
    // Garantir que as chaves estrangeiras sejam reabilitadas
    try {
      await executeQuery('SET FOREIGN_KEY_CHECKS = 1');
    } catch (e) {
      console.error('❌ Erro ao reabilitar chaves estrangeiras:', e);
    }
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para deletar fisicamente membros marcados como excluídos (soft delete)
app.post('/api/admin/cleanup-deleted-members', async (req, res) => {
  try {
    console.log('🧹 Iniciando limpeza de membros excluídos...');
    
    // Buscar todos os membros marcados como excluídos
    const deletedMembers = await executeQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM members WHERE deleted_at IS NOT NULL'
    );
    
    if (!deletedMembers || deletedMembers.length === 0) {
      return res.json({
        success: true,
        message: 'Nenhum membro excluído encontrado para limpeza',
        deletedCount: 0
      });
    }
    
    console.log(`📋 Encontrados ${deletedMembers.length} membros para limpeza física`);
    
    let deletedCount = 0;
    let errors = [];
    
    // Deletar cada membro fisicamente
    for (const member of deletedMembers) {
      try {
        console.log(`🗑️ Deletando fisicamente: ${member.name} (ID: ${member.id})`);
        
        // Deletar fisicamente o membro
        await executeQuery(
          'DELETE FROM members WHERE id = ?',
          [member.id]
        );
        
        deletedCount++;
        console.log(`✅ Membro ${member.name} deletado fisicamente`);
        
      } catch (error) {
        console.error(`❌ Erro ao deletar membro ${member.name}:`, error);
        errors.push({
          member: member.name,
          id: member.id,
          error: error.message
        });
      }
    }
    
    console.log(`🎉 Limpeza concluída! ${deletedCount} membros deletados fisicamente`);
    
    res.json({
      success: true,
      message: `Limpeza concluída! ${deletedCount} membros deletados fisicamente`,
      deletedCount: deletedCount,
      totalFound: deletedMembers.length,
      errors: errors
    });
    
  } catch (error) {
    console.error('❌ Erro na limpeza de membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para deletar fisicamente amigos marcados como excluídos (soft delete)
app.post('/api/admin/cleanup-deleted-friends', async (req, res) => {
  try {
    console.log('🧹 Iniciando limpeza de amigos excluídos...');
    
    // Buscar todos os amigos marcados como excluídos
    const deletedFriends = await executeQuery(
      'SELECT id, name, phone, instagram, deleted_at FROM friends WHERE deleted_at IS NOT NULL'
    );
    
    if (!deletedFriends || deletedFriends.length === 0) {
      return res.json({
        success: true,
        message: 'Nenhum amigo excluído encontrado para limpeza',
        deletedCount: 0
      });
    }
    
    console.log(`📋 Encontrados ${deletedFriends.length} amigos para limpeza física`);
    
    let deletedCount = 0;
    let errors = [];
    
    // Deletar cada amigo fisicamente
    for (const friend of deletedFriends) {
      try {
        console.log(`🗑️ Deletando fisicamente: ${friend.name} (ID: ${friend.id})`);
        
        // Deletar fisicamente o amigo
        await executeQuery(
          'DELETE FROM friends WHERE id = ?',
          [friend.id]
        );
        
        deletedCount++;
        console.log(`✅ Amigo ${friend.name} deletado fisicamente`);
        
      } catch (error) {
        console.error(`❌ Erro ao deletar amigo ${friend.name}:`, error);
        errors.push({
          friend: friend.name,
          id: friend.id,
          error: error.message
        });
      }
    }
    
    console.log(`🎉 Limpeza concluída! ${deletedCount} amigos deletados fisicamente`);
    
    res.json({
      success: true,
      message: `Limpeza concluída! ${deletedCount} amigos deletados fisicamente`,
      deletedCount: deletedCount,
      totalFound: deletedFriends.length,
      errors: errors
    });
    
  } catch (error) {
    console.error('❌ Erro na limpeza de amigos:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para limpar todas as triggers e funções não utilizadas
app.post('/api/admin/cleanup-unused-database-objects', async (req, res) => {
  try {
    console.log('🧹 Iniciando limpeza completa de triggers e funções não utilizadas...');
    
    let cleanedObjects = [];
    
    // 1. Remover todas as triggers relacionadas a membros
    console.log('🗑️ Removendo triggers de membros...');
    const memberTriggers = [
      'soft_delete_member_links_trigger',
      'soft_delete_member_auth_trigger', 
      'delete_member_auth_trigger',
      'delete_member_links_trigger',
      'member_ranking_trigger',
      'member_status_trigger',
      'update_member_contracts_trigger'
    ];
    
    for (const triggerName of memberTriggers) {
      try {
        await executeQuery(`DROP TRIGGER IF EXISTS ${triggerName}`);
        cleanedObjects.push(`TRIGGER: ${triggerName}`);
        console.log(`✅ Trigger removida: ${triggerName}`);
      } catch (error) {
        console.log(`ℹ️ Trigger ${triggerName} não existia`);
      }
    }
    
    // 2. Remover todas as triggers relacionadas a amigos
    console.log('🗑️ Removendo triggers de amigos...');
    const friendTriggers = [
      'friend_ranking_trigger',
      'friend_status_trigger',
      'update_friend_contracts_trigger',
      'delete_friend_auth_trigger',
      'delete_friend_links_trigger'
    ];
    
    for (const triggerName of friendTriggers) {
      try {
        await executeQuery(`DROP TRIGGER IF EXISTS ${triggerName}`);
        cleanedObjects.push(`TRIGGER: ${triggerName}`);
        console.log(`✅ Trigger removida: ${triggerName}`);
      } catch (error) {
        console.log(`ℹ️ Trigger ${triggerName} não existia`);
      }
    }
    
    // 3. Remover funções não utilizadas
    console.log('🗑️ Removendo funções não utilizadas...');
    const unusedFunctions = [
      'calculate_member_ranking',
      'update_member_status',
      'calculate_friend_ranking',
      'update_friend_status',
      'get_member_stats',
      'get_friend_stats',
      'cleanup_old_records',
      'backup_member_data',
      'restore_member_data'
    ];
    
    for (const functionName of unusedFunctions) {
      try {
        await executeQuery(`DROP FUNCTION IF EXISTS ${functionName}`);
        cleanedObjects.push(`FUNCTION: ${functionName}`);
        console.log(`✅ Função removida: ${functionName}`);
      } catch (error) {
        console.log(`ℹ️ Função ${functionName} não existia`);
      }
    }
    
    // 4. Remover procedures não utilizadas
    console.log('🗑️ Removendo procedures não utilizadas...');
    const unusedProcedures = [
      'update_member_after_friend_registration',
      'create_user_from_member',
      'backup_all_data',
      'restore_all_data',
      'cleanup_orphaned_records',
      'rebuild_member_rankings',
      'rebuild_friend_rankings'
    ];
    
    for (const procedureName of unusedProcedures) {
      try {
        await executeQuery(`DROP PROCEDURE IF EXISTS ${procedureName}`);
        cleanedObjects.push(`PROCEDURE: ${procedureName}`);
        console.log(`✅ Procedure removida: ${procedureName}`);
      } catch (error) {
        console.log(`ℹ️ Procedure ${procedureName} não existia`);
      }
    }
    
    // 5. Remover views não utilizadas
    console.log('🗑️ Removendo views não utilizadas...');
    const unusedViews = [
      'member_rankings_view',
      'friend_rankings_view',
      'member_stats_view',
      'friend_stats_view',
      'deleted_members_view',
      'deleted_friends_view'
    ];
    
    for (const viewName of unusedViews) {
      try {
        await executeQuery(`DROP VIEW IF EXISTS ${viewName}`);
        cleanedObjects.push(`VIEW: ${viewName}`);
        console.log(`✅ View removida: ${viewName}`);
      } catch (error) {
        console.log(`ℹ️ View ${viewName} não existia`);
      }
    }
    
    // 6. Remover índices não utilizados
    console.log('🗑️ Removendo índices não utilizados...');
    const unusedIndexes = [
      'idx_members_ranking_status',
      'idx_members_contracts_completed',
      'idx_friends_ranking_status',
      'idx_friends_contracts_completed',
      'idx_members_deleted_at',
      'idx_friends_deleted_at'
    ];
    
    for (const indexName of unusedIndexes) {
      try {
        await executeQuery(`DROP INDEX IF EXISTS ${indexName} ON members`);
        cleanedObjects.push(`INDEX: ${indexName} (members)`);
        console.log(`✅ Índice removido: ${indexName} (members)`);
      } catch (error) {
        try {
          await executeQuery(`DROP INDEX IF EXISTS ${indexName} ON friends`);
          cleanedObjects.push(`INDEX: ${indexName} (friends)`);
          console.log(`✅ Índice removido: ${indexName} (friends)`);
        } catch (error2) {
          console.log(`ℹ️ Índice ${indexName} não existia`);
        }
      }
    }
    
    console.log(`🎉 Limpeza completa concluída! ${cleanedObjects.length} objetos removidos`);
    
    res.json({
      success: true,
      message: `Limpeza completa concluída! ${cleanedObjects.length} objetos removidos`,
      cleanedCount: cleanedObjects.length,
      cleanedObjects: cleanedObjects
    });
    
  } catch (error) {
    console.error('❌ Erro na limpeza de objetos do banco:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para remover TODAS as triggers restantes
app.post('/api/admin/remove-all-remaining-triggers', async (req, res) => {
  try {
    console.log('🧹 Removendo TODAS as triggers restantes...');
    
    // Buscar todas as triggers existentes
    const triggersQuery = `
      SELECT TRIGGER_NAME 
      FROM information_schema.TRIGGERS 
      WHERE TRIGGER_SCHEMA = DATABASE()
    `;
    
    const triggers = await executeQuery(triggersQuery);
    
    let removedTriggers = [];
    
    if (triggers && triggers.length > 0) {
      console.log(`📋 Encontradas ${triggers.length} triggers para remoção`);
      
      for (const trigger of triggers) {
        try {
          await executeQuery(`DROP TRIGGER IF EXISTS ${trigger.TRIGGER_NAME}`);
          removedTriggers.push(trigger.TRIGGER_NAME);
          console.log(`✅ Trigger removida: ${trigger.TRIGGER_NAME}`);
        } catch (error) {
          console.log(`❌ Erro ao remover trigger ${trigger.TRIGGER_NAME}:`, error.message);
        }
      }
    }
    
    console.log(`🎉 Remoção concluída! ${removedTriggers.length} triggers removidas`);
    
    res.json({
      success: true,
      message: `Remoção concluída! ${removedTriggers.length} triggers removidas`,
      removedCount: removedTriggers.length,
      removedTriggers: removedTriggers
    });
    
  } catch (error) {
    console.error('❌ Erro na remoção de triggers:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para remover triggers conflitantes
app.post('/api/admin/remove-conflicting-triggers', async (req, res) => {
  try {
    console.log('🗑️ Removendo triggers conflitantes...');
    
    const triggersToRemove = [
      'member_ranking_trigger',
      'member_status_trigger',
      'friend_ranking_trigger', 
      'friend_status_trigger'
    ];
    
    let removedCount = 0;
    
    for (const triggerName of triggersToRemove) {
      try {
        await executeQuery(`DROP TRIGGER IF EXISTS ${triggerName}`);
        removedCount++;
        console.log(`✅ Trigger removida: ${triggerName}`);
      } catch (error) {
        console.log(`ℹ️ Trigger ${triggerName} não existia`);
      }
    }
    
    console.log(`🎉 ${removedCount} triggers conflitantes removidas`);
    
    res.json({
      success: true,
      message: `${removedCount} triggers conflitantes removidas`,
      removedCount: removedCount
    });
    
  } catch (error) {
    console.error('❌ Erro ao remover triggers:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para atualizar apenas contratos dos membros
app.post('/api/admin/update-members-contracts', async (req, res) => {
  try {
    console.log('🔄 Atualizando contratos de todos os membros...');
    
    // Buscar todos os membros ativos
    const members = await executeQuery(
      'SELECT id FROM members WHERE deleted_at IS NULL'
    );
    
    let updatedCount = 0;
    
    for (const member of members) {
      // Contar amigos ativos do membro
      const friendsCountResult = await executeQuery(
        'SELECT COUNT(*) as count FROM friends WHERE member_id = ? AND deleted_at IS NULL',
        [member.id]
      );
      
      const contracts = friendsCountResult[0].count;
      
      // Atualizar apenas contratos
      await executeQuery(
        'UPDATE members SET contracts_completed = ?, updated_at = NOW() WHERE id = ?',
        [contracts, member.id]
      );
      
      updatedCount++;
      console.log(`✅ Membro ID ${member.id}: ${contracts} contratos`);
    }
    
    console.log(`🎉 Atualização concluída! ${updatedCount} membros atualizados`);
    
    res.json({
      success: true,
      message: `Contratos atualizados para ${updatedCount} membros`,
      updatedCount: updatedCount
    });
    
  } catch (error) {
    console.error('❌ Erro ao atualizar contratos dos membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para corrigir status dos membros
app.post('/api/admin/fix-member-status', async (req, res) => {
  try {
    console.log('🔧 Corrigindo status dos membros...');
    
    // Buscar todos os membros ativos
    const members = await executeQuery(
      'SELECT id, contracts_completed FROM members WHERE deleted_at IS NULL'
    );
    
    let fixedCount = 0;
    
    for (const member of members) {
      const contracts = member.contracts_completed;
      let status = 'Inativo';
      
      if (contracts >= 1) {
        status = 'Ativo';
      } else {
        status = 'Inativo';
      }
      
      // Atualizar apenas o status
      await executeQuery(
        'UPDATE members SET status = ?, updated_at = NOW() WHERE id = ?',
        [status, member.id]
      );
      
      fixedCount++;
      console.log(`✅ Membro ID ${member.id}: ${contracts} contratos → Status: ${status}`);
    }
    
    console.log(`🎉 ${fixedCount} status corrigidos!`);
    
    res.json({
      success: true,
      message: `Status corrigidos para ${fixedCount} membros`,
      fixedCount: fixedCount
    });
    
  } catch (error) {
    console.error('❌ Erro ao corrigir status:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint de teste para verificar dados completos dos membros
app.get('/api/admin/debug-member-data', async (req, res) => {
  try {
    console.log('🔍 Debug: Verificando dados completos dos membros...');
    
    // Verificar dados dos primeiros 3 membros com todos os campos
    const members = await executeQuery(
      `SELECT id, name, contracts_completed, ranking_position, ranking_status, 
              is_top_1500, can_be_replaced, status
       FROM members 
       WHERE deleted_at IS NULL 
       ORDER BY ranking_position ASC 
       LIMIT 3`
    );
    
    console.log('📊 Dados completos dos membros:', members);
    
    res.json({
      success: true,
      members: members
    });
    
  } catch (error) {
    console.error('❌ Erro no debug:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint de teste para verificar ranking
app.get('/api/admin/debug-ranking', async (req, res) => {
  try {
    console.log('🔍 Debug: Verificando dados dos membros...');
    
    // Verificar estrutura da tabela
    const tableStructure = await executeQuery('DESCRIBE members');
    console.log('📋 Estrutura da tabela members:', tableStructure);
    
    // Verificar dados atuais
    const members = await executeQuery(
      'SELECT id, name, contracts_completed, ranking_position, ranking_status FROM members WHERE deleted_at IS NULL ORDER BY contracts_completed DESC'
    );
    console.log('📊 Membros atuais:', members);
    
    res.json({
      success: true,
      tableStructure: tableStructure,
      members: members
    });
    
  } catch (error) {
    console.error('❌ Erro no debug:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para atualizar ranking e status de todos os membros
app.post('/api/admin/update-members-ranking', async (req, res) => {
  try {
    console.log('🔄 Iniciando atualização de ranking e status de todos os membros...');
    
    // 1. Primeiro, atualizar contratos de todos os membros
    const members = await executeQuery(
      'SELECT id FROM members WHERE deleted_at IS NULL'
    );
    
    for (const member of members) {
      // Contar amigos ativos do membro
      const friendsCountResult = await executeQuery(
        'SELECT COUNT(*) as count FROM friends WHERE member_id = ? AND deleted_at IS NULL',
        [member.id]
      );
      
      const contracts = friendsCountResult[0].count;
      
      // Atualizar apenas contratos primeiro
      await executeQuery(
        'UPDATE members SET contracts_completed = ?, updated_at = NOW() WHERE id = ?',
        [contracts, member.id]
      );
    }
    
    // 2. Agora calcular ranking baseado na quantidade de contratos (maior para menor)
    const membersWithContracts = await executeQuery(
      `SELECT id, contracts_completed 
       FROM members 
       WHERE deleted_at IS NULL 
       ORDER BY contracts_completed DESC, id ASC`
    );
    
    let updatedCount = 0;
    
    for (let i = 0; i < membersWithContracts.length; i++) {
      const member = membersWithContracts[i];
      const contracts = member.contracts_completed;
      const rankingPosition = i + 1; // Posição 1, 2, 3, etc.
      
      // Calcular ranking e status
      let rankingStatus = 'Vermelho';
      let status = 'Inativo';
      let isTop1500 = false;
      let canBeReplaced = true;
      
      if (contracts >= 15) {
        rankingStatus = 'Verde';
        status = 'Ativo';
        isTop1500 = true;
        canBeReplaced = false;
      } else if (contracts >= 1) {
        rankingStatus = 'Amarelo';
        status = 'Ativo'; // Mudado de 'Em Progresso' para 'Ativo'
        isTop1500 = false;
        canBeReplaced = true;
      } else {
        rankingStatus = 'Vermelho';
        status = 'Inativo';
        isTop1500 = false;
        canBeReplaced = true;
      }
      
      // Atualizar membro com posição no ranking
      console.log(`🔍 Atualizando membro ID ${member.id}: posição ${rankingPosition}, status ${rankingStatus}`);
      await executeQuery(
        `UPDATE members SET 
          ranking_position = ?,
          ranking_status = ?,
          status = ?,
          is_top_1500 = ?,
          can_be_replaced = ?,
          updated_at = NOW()
        WHERE id = ?`,
        [rankingPosition, rankingStatus, status, isTop1500, canBeReplaced, member.id]
      );
      
      updatedCount++;
      console.log(`✅ Membro ID ${member.id}: ${contracts} contratos → Posição ${rankingPosition}º → ${rankingStatus} (${status})`);
    }
    
    console.log(`🎉 Atualização concluída! ${updatedCount} membros atualizados`);
    
    res.json({
      success: true,
      message: `Ranking e status atualizados para ${updatedCount} membros`,
      updatedCount: updatedCount
    });
    
  } catch (error) {
    console.error('❌ Erro ao atualizar ranking dos membros:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para restaurar TODAS as triggers e funções removidas
app.post('/api/admin/restore-all-triggers-and-functions', async (req, res) => {
  try {
    console.log('🔧 Restaurando todas as triggers e funções...');
    
    let restoredObjects = [];
    
    // 1. Recriar triggers de membros
    console.log('🔧 Recriando triggers de membros...');
    
    // Trigger para soft delete de user_links quando membro é deletado
    try {
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_links_trigger');
      await executeQuery(`
        CREATE TRIGGER soft_delete_member_links_trigger
        AFTER UPDATE ON members
        FOR EACH ROW
        BEGIN
          IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
            DELETE FROM user_links WHERE user_id = NEW.id;
          END IF;
        END
      `);
      restoredObjects.push('TRIGGER: soft_delete_member_links_trigger');
      console.log('✅ Trigger soft_delete_member_links_trigger criada');
    } catch (error) {
      console.log('❌ Erro ao criar trigger soft_delete_member_links_trigger:', error.message);
    }
    
    // Trigger para soft delete de auth_users quando membro é deletado
    try {
      await executeQuery('DROP TRIGGER IF EXISTS soft_delete_member_auth_trigger');
      await executeQuery(`
        CREATE TRIGGER soft_delete_member_auth_trigger
        AFTER UPDATE ON members
        FOR EACH ROW
        BEGIN
          IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
            DELETE FROM auth_users WHERE id = NEW.id;
          END IF;
        END
      `);
      restoredObjects.push('TRIGGER: soft_delete_member_auth_trigger');
      console.log('✅ Trigger soft_delete_member_auth_trigger criada');
    } catch (error) {
      console.log('❌ Erro ao criar trigger soft_delete_member_auth_trigger:', error.message);
    }
    
    // Trigger para ranking de membros
    try {
      await executeQuery('DROP TRIGGER IF EXISTS member_ranking_trigger');
      await executeQuery(`
        CREATE TRIGGER member_ranking_trigger
        AFTER UPDATE ON members
        FOR EACH ROW
        BEGIN
          IF OLD.contracts_completed != NEW.contracts_completed THEN
            UPDATE members SET 
              ranking_status = CASE 
                WHEN NEW.contracts_completed >= 15 THEN 'Verde'
                WHEN NEW.contracts_completed >= 10 THEN 'Amarelo'
                ELSE 'Vermelho'
              END,
              is_top_1500 = NEW.contracts_completed >= 15,
              can_be_replaced = NEW.contracts_completed < 15
            WHERE id = NEW.id;
          END IF;
        END
      `);
      restoredObjects.push('TRIGGER: member_ranking_trigger');
      console.log('✅ Trigger member_ranking_trigger criada');
    } catch (error) {
      console.log('❌ Erro ao criar trigger member_ranking_trigger:', error.message);
    }
    
    // Trigger para status de membros
    try {
      await executeQuery('DROP TRIGGER IF EXISTS member_status_trigger');
      await executeQuery(`
        CREATE TRIGGER member_status_trigger
        AFTER UPDATE ON members
        FOR EACH ROW
        BEGIN
          IF OLD.contracts_completed != NEW.contracts_completed THEN
            UPDATE members SET 
              status = CASE 
                WHEN NEW.contracts_completed >= 15 THEN 'Ativo'
                WHEN NEW.contracts_completed >= 10 THEN 'Em Progresso'
                ELSE 'Inativo'
              END
            WHERE id = NEW.id;
          END IF;
        END
      `);
      restoredObjects.push('TRIGGER: member_status_trigger');
      console.log('✅ Trigger member_status_trigger criada');
    } catch (error) {
      console.log('❌ Erro ao criar trigger member_status_trigger:', error.message);
    }
    
    // 2. Recriar triggers de amigos
    console.log('🔧 Recriando triggers de amigos...');
    
    // Trigger para ranking de amigos
    try {
      await executeQuery('DROP TRIGGER IF EXISTS friend_ranking_trigger');
      await executeQuery(`
        CREATE TRIGGER friend_ranking_trigger
        AFTER UPDATE ON friends
        FOR EACH ROW
        BEGIN
          IF OLD.contracts_completed != NEW.contracts_completed THEN
            UPDATE friends SET 
              ranking_status = CASE 
                WHEN NEW.contracts_completed >= 15 THEN 'Verde'
                WHEN NEW.contracts_completed >= 10 THEN 'Amarelo'
                ELSE 'Vermelho'
              END,
              is_top_1500 = NEW.contracts_completed >= 15,
              can_be_replaced = NEW.contracts_completed < 15
            WHERE id = NEW.id;
          END IF;
        END
      `);
      restoredObjects.push('TRIGGER: friend_ranking_trigger');
      console.log('✅ Trigger friend_ranking_trigger criada');
    } catch (error) {
      console.log('❌ Erro ao criar trigger friend_ranking_trigger:', error.message);
    }
    
    // Trigger para status de amigos
    try {
      await executeQuery('DROP TRIGGER IF EXISTS friend_status_trigger');
      await executeQuery(`
        CREATE TRIGGER friend_status_trigger
        AFTER UPDATE ON friends
        FOR EACH ROW
        BEGIN
          IF OLD.contracts_completed != NEW.contracts_completed THEN
            UPDATE friends SET 
              status = CASE 
                WHEN NEW.contracts_completed >= 15 THEN 'Ativo'
                WHEN NEW.contracts_completed >= 10 THEN 'Em Progresso'
                ELSE 'Inativo'
              END
            WHERE id = NEW.id;
          END IF;
        END
      `);
      restoredObjects.push('TRIGGER: friend_status_trigger');
      console.log('✅ Trigger friend_status_trigger criada');
    } catch (error) {
      console.log('❌ Erro ao criar trigger friend_status_trigger:', error.message);
    }
    
    // 3. Recriar funções
    console.log('🔧 Recriando funções...');
    
    // Função para calcular ranking de membros
    try {
      await executeQuery('DROP FUNCTION IF EXISTS calculate_member_ranking');
      await executeQuery(`
        CREATE FUNCTION calculate_member_ranking(contracts INT) 
        RETURNS VARCHAR(20)
        DETERMINISTIC
        BEGIN
          RETURN CASE 
            WHEN contracts >= 15 THEN 'Verde'
            WHEN contracts >= 10 THEN 'Amarelo'
            ELSE 'Vermelho'
          END;
        END
      `);
      restoredObjects.push('FUNCTION: calculate_member_ranking');
      console.log('✅ Função calculate_member_ranking criada');
    } catch (error) {
      console.log('❌ Erro ao criar função calculate_member_ranking:', error.message);
    }
    
    // Função para atualizar status de membros
    try {
      await executeQuery('DROP FUNCTION IF EXISTS update_member_status');
      await executeQuery(`
        CREATE FUNCTION update_member_status(contracts INT) 
        RETURNS VARCHAR(20)
        DETERMINISTIC
        BEGIN
          RETURN CASE 
            WHEN contracts >= 15 THEN 'Ativo'
            WHEN contracts >= 10 THEN 'Em Progresso'
            ELSE 'Inativo'
          END;
        END
      `);
      restoredObjects.push('FUNCTION: update_member_status');
      console.log('✅ Função update_member_status criada');
    } catch (error) {
      console.log('❌ Erro ao criar função update_member_status:', error.message);
    }
    
    // Função para calcular ranking de amigos
    try {
      await executeQuery('DROP FUNCTION IF EXISTS calculate_friend_ranking');
      await executeQuery(`
        CREATE FUNCTION calculate_friend_ranking(contracts INT) 
        RETURNS VARCHAR(20)
        DETERMINISTIC
        BEGIN
          RETURN CASE 
            WHEN contracts >= 15 THEN 'Verde'
            WHEN contracts >= 10 THEN 'Amarelo'
            ELSE 'Vermelho'
          END;
        END
      `);
      restoredObjects.push('FUNCTION: calculate_friend_ranking');
      console.log('✅ Função calculate_friend_ranking criada');
    } catch (error) {
      console.log('❌ Erro ao criar função calculate_friend_ranking:', error.message);
    }
    
    // Função para atualizar status de amigos
    try {
      await executeQuery('DROP FUNCTION IF EXISTS update_friend_status');
      await executeQuery(`
        CREATE FUNCTION update_friend_status(contracts INT) 
        RETURNS VARCHAR(20)
        DETERMINISTIC
        BEGIN
          RETURN CASE 
            WHEN contracts >= 15 THEN 'Ativo'
            WHEN contracts >= 10 THEN 'Em Progresso'
            ELSE 'Inativo'
          END;
        END
      `);
      restoredObjects.push('FUNCTION: update_friend_status');
      console.log('✅ Função update_friend_status criada');
    } catch (error) {
      console.log('❌ Erro ao criar função update_friend_status:', error.message);
    }
    
    // 4. Recriar procedures
    console.log('🔧 Recriando procedures...');
    
    // Procedure para atualizar membro após cadastro de amigo
    try {
      await executeQuery('DROP PROCEDURE IF EXISTS update_member_after_friend_registration');
      await executeQuery(`
        CREATE PROCEDURE update_member_after_friend_registration(IN member_id INT, OUT success BOOLEAN, OUT message VARCHAR(255))
        BEGIN
          DECLARE member_contracts INT DEFAULT 0;
          DECLARE friends_count INT DEFAULT 0;
          
          SELECT COUNT(*) INTO friends_count 
          FROM friends 
          WHERE member_id = member_id AND deleted_at IS NULL;
          
          SELECT contracts_completed INTO member_contracts 
          FROM members 
          WHERE id = member_id;
          
          IF member_contracts < friends_count THEN
            UPDATE members 
            SET contracts_completed = friends_count,
                ranking_status = calculate_member_ranking(friends_count),
                status = update_member_status(friends_count),
                is_top_1500 = friends_count >= 15,
                can_be_replaced = friends_count < 15,
                updated_at = NOW()
            WHERE id = member_id;
            
            SET success = TRUE;
            SET message = 'Membro atualizado com sucesso';
          ELSE
            SET success = FALSE;
            SET message = 'Nenhuma atualização necessária';
          END IF;
        END
      `);
      restoredObjects.push('PROCEDURE: update_member_after_friend_registration');
      console.log('✅ Procedure update_member_after_friend_registration criada');
    } catch (error) {
      console.log('❌ Erro ao criar procedure update_member_after_friend_registration:', error.message);
    }
    
    // Procedure para criar usuário a partir de membro
    try {
      await executeQuery('DROP PROCEDURE IF EXISTS create_user_from_member');
      await executeQuery(`
        CREATE PROCEDURE create_user_from_member(
          IN member_id INT, 
          OUT username VARCHAR(255), 
          OUT \`password\` VARCHAR(255), 
          OUT user_id INT, 
          OUT success BOOLEAN, 
          OUT message VARCHAR(255)
        )
        BEGIN
          DECLARE member_name VARCHAR(255);
          DECLARE member_instagram VARCHAR(255);
          DECLARE generated_username VARCHAR(255);
          
          SELECT name, instagram INTO member_name, member_instagram 
          FROM members 
          WHERE id = member_id AND deleted_at IS NULL;
          
          IF member_name IS NULL THEN
            SET success = FALSE;
            SET message = 'Membro não encontrado';
          ELSE
            SET generated_username = IF(member_instagram IS NOT NULL AND member_instagram != '', 
              REPLACE(member_instagram, '@', ''), 
              LOWER(REPLACE(REPLACE(member_name, ' ', '_'), '-', '_'))
            );
            SET \`password\` = '123456';
            
            INSERT INTO auth_users (username, password, name, role, full_name, instagram, is_active, created_at, updated_at)
            VALUES (generated_username, \`password\`, member_name, 'Membro', member_name, member_instagram, FALSE, NOW(), NOW());
            
            SET user_id = LAST_INSERT_ID();
            SET username = generated_username;
            SET success = TRUE;
            SET message = 'Usuário criado com sucesso';
          END IF;
        END
      `);
      restoredObjects.push('PROCEDURE: create_user_from_member');
      console.log('✅ Procedure create_user_from_member criada');
    } catch (error) {
      console.log('❌ Erro ao criar procedure create_user_from_member:', error.message);
    }
    
    // Procedure para gerar ou buscar link de usuário
    try {
      await executeQuery('DROP PROCEDURE IF EXISTS get_or_generate_user_link');
      await executeQuery(`
        CREATE PROCEDURE get_or_generate_user_link(
          IN user_id INT, 
          IN user_name VARCHAR(255), 
          IN link_type VARCHAR(50), 
          OUT link_id VARCHAR(36), 
          OUT is_existing BOOLEAN, 
          OUT success BOOLEAN, 
          OUT message VARCHAR(255)
        )
        BEGIN
          DECLARE existing_link_id VARCHAR(36);
          
          SELECT link_id INTO existing_link_id 
          FROM user_links 
          WHERE user_id = user_id AND is_active = TRUE 
          LIMIT 1;
          
          IF existing_link_id IS NOT NULL THEN
            SET link_id = existing_link_id;
            SET is_existing = TRUE;
            SET success = TRUE;
            SET message = 'Link existente encontrado';
          ELSE
            SET link_id = UUID();
            INSERT INTO user_links (link_id, user_id, link_type, is_active, created_at, updated_at)
            VALUES (link_id, user_id, link_type, TRUE, NOW(), NOW());
            SET is_existing = FALSE;
            SET success = TRUE;
            SET message = 'Novo link gerado';
          END IF;
        END
      `);
      restoredObjects.push('PROCEDURE: get_or_generate_user_link');
      console.log('✅ Procedure get_or_generate_user_link criada');
    } catch (error) {
      console.log('❌ Erro ao criar procedure get_or_generate_user_link:', error.message);
    }
    
    // Procedure para atualizar fase baseada em membros
    try {
      await executeQuery('DROP PROCEDURE IF EXISTS update_phase_based_on_members');
      await executeQuery(`
        CREATE PROCEDURE update_phase_based_on_members()
        BEGIN
          DECLARE total_members INT;
          DECLARE current_phase VARCHAR(50);
          
          SELECT COUNT(*) INTO total_members 
          FROM members 
          WHERE deleted_at IS NULL;
          
          SELECT setting_value INTO current_phase 
          FROM system_settings 
          WHERE setting_key = 'current_phase';
          
          IF total_members >= 1500 AND current_phase != 'Fase 3' THEN
            UPDATE system_settings 
            SET setting_value = 'Fase 3', updated_at = NOW() 
            WHERE setting_key = 'current_phase';
          ELSEIF total_members >= 500 AND current_phase != 'Fase 2' THEN
            UPDATE system_settings 
            SET setting_value = 'Fase 2', updated_at = NOW() 
            WHERE setting_key = 'current_phase';
          ELSEIF total_members < 500 AND current_phase != 'Fase 1' THEN
            UPDATE system_settings 
            SET setting_value = 'Fase 1', updated_at = NOW() 
            WHERE setting_key = 'current_phase';
          END IF;
        END
      `);
      restoredObjects.push('PROCEDURE: update_phase_based_on_members');
      console.log('✅ Procedure update_phase_based_on_members criada');
    } catch (error) {
      console.log('❌ Erro ao criar procedure update_phase_based_on_members:', error.message);
    }
    
    // Função para obter status da fase
    try {
      await executeQuery('DROP FUNCTION IF EXISTS get_phase_status');
      await executeQuery(`
        CREATE FUNCTION get_phase_status() 
        RETURNS JSON
        DETERMINISTIC
        BEGIN
          DECLARE total_members INT;
          DECLARE current_phase VARCHAR(50);
          
          SELECT COUNT(*) INTO total_members 
          FROM members 
          WHERE deleted_at IS NULL;
          
          SELECT setting_value INTO current_phase 
          FROM system_settings 
          WHERE setting_key = 'current_phase';
          
          RETURN JSON_OBJECT(
            'current_phase', IFNULL(current_phase, 'Fase 1'),
            'total_members', total_members,
            'phase_1_limit', 500,
            'phase_2_limit', 1500,
            'phase_3_limit', 999999
          );
        END
      `);
      restoredObjects.push('FUNCTION: get_phase_status');
      console.log('✅ Função get_phase_status criada');
    } catch (error) {
      console.log('❌ Erro ao criar função get_phase_status:', error.message);
    }
    
    console.log(`🎉 Restauração concluída! ${restoredObjects.length} objetos restaurados`);
    
    res.json({
      success: true,
      message: `Restauração concluída! ${restoredObjects.length} objetos restaurados`,
      restoredCount: restoredObjects.length,
      restoredObjects: restoredObjects
    });
    
  } catch (error) {
    console.error('❌ Erro na restauração de objetos:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para verificar triggers existentes
app.get('/api/admin/check-triggers', async (req, res) => {
  try {
    console.log('🔍 Verificando triggers existentes...');
    
    // Verificar triggers relacionadas a membros
    const triggersQuery = `
      SELECT 
        TRIGGER_NAME,
        EVENT_MANIPULATION,
        EVENT_OBJECT_TABLE,
        ACTION_STATEMENT
      FROM information_schema.TRIGGERS 
      WHERE TRIGGER_SCHEMA = DATABASE()
      AND (TRIGGER_NAME LIKE '%member%' OR EVENT_OBJECT_TABLE = 'members')
      ORDER BY TRIGGER_NAME
    `;
    
    const triggers = await executeQuery(triggersQuery);
    
    console.log(`✅ Encontradas ${triggers.length} triggers relacionadas a membros`);
    
    res.json({
      success: true,
      message: `Encontradas ${triggers.length} triggers relacionadas a membros`,
      triggers: triggers
    });
    
  } catch (error) {
    console.error('❌ Erro ao verificar triggers:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Endpoint para criar funções de atualização de membros
app.post('/api/admin/create-member-update-functions', async (req, res) => {
  try {
    // Primeiro, dropar a procedure se existir
    try {
      await executeQuery('DROP PROCEDURE IF EXISTS update_member_after_friend_registration');
    } catch (error) {
      // Nenhuma procedure anterior para remover
    }
    
    // Criar a procedure
    const createProcedureSQL = `CREATE PROCEDURE update_member_after_friend_registration(
      IN p_member_id INT,
      OUT p_success BOOLEAN,
      OUT p_message VARCHAR(500)
    )
    BEGIN
      DECLARE member_exists INT DEFAULT 0;
      DECLARE current_contracts INT DEFAULT 0;
      DECLARE new_ranking_status VARCHAR(20);
      DECLARE new_ranking_position INT;
      
      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Erro ao atualizar membro após cadastro de amigo';
      END;
      
      START TRANSACTION;
      
      SELECT COUNT(*) INTO member_exists 
      FROM members 
      WHERE id = p_member_id;
      
      IF member_exists = 0 THEN
        SET p_success = FALSE;
        SET p_message = 'Membro não encontrado';
        ROLLBACK;
      ELSE
        SELECT COUNT(*) INTO current_contracts 
        FROM friends 
        WHERE member_id = p_member_id AND deleted_at IS NULL;
        
        IF current_contracts >= 15 THEN
          SET new_ranking_status = 'Verde';
        ELSEIF current_contracts >= 1 THEN
          SET new_ranking_status = 'Amarelo';
        ELSE
          SET new_ranking_status = 'Vermelho';
        END IF;
        
        SELECT COUNT(*) + 1 INTO new_ranking_position
        FROM members m
        WHERE m.contracts_completed > current_contracts
        AND m.deleted_at IS NULL;
        
        UPDATE members 
        SET 
          contracts_completed = current_contracts,
          ranking_status = new_ranking_status,
          ranking_position = new_ranking_position,
          updated_at = NOW()
        WHERE id = p_member_id;
        
        SET p_success = TRUE;
        SET p_message = CONCAT('Membro atualizado: ', current_contracts, ' contratos, status: ', new_ranking_status, ', posição: ', new_ranking_position);
        
        COMMIT;
      END IF;
    END`;
    
    // Executar criação da procedure
    await executeQuery(createProcedureSQL);
    
    res.json({
      success: true,
      message: 'Funções de atualização de membros criadas com sucesso'
    });
    
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Iniciar servidor somente fora do Vercel (ambiente local)
if (!process.env.VERCEL) {
  app.listen(PORT, () => {
    // Servidor iniciado localmente
  });
}

// Export para Vercel Serverless Function
export default app;

// Iniciar o servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📡 API disponível em: http://localhost:${PORT}/api`);
});

// Também exportar como module.exports para compatibilidade
if (typeof module !== 'undefined' && module.exports) {
  module.exports = app;
}
