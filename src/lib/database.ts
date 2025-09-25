// lib/database.ts - Cliente para API backend
// Tipos para o banco de dados
export interface User {
  id: string
  name: string
  phone: string
  instagram: string
  city: string
  sector: string
  referrer: string
  registration_date: string
  status: 'Ativo' | 'Inativo'
  created_at: string
  updated_at: string
}

export interface AuthUser {
  id: string
  username: string
  name: string
  role: string
  full_name: string
  display_name?: string
  instagram?: string
  phone?: string
  is_active?: boolean
  last_login?: string
  created_at: string
  updated_at: string
}

export interface Stats {
  total_users: number
  active_users: number
  recent_registrations: number
  engagement_rate: number
  today_registrations: number
}

export interface Member {
  id: number
  name: string
  phone: string
  instagram: string
  city: string
  sector: string
  referrer: string
  registration_date: string
  status: 'Ativo' | 'Inativo'
  couple_name: string
  couple_phone: string
  couple_instagram: string
  couple_city: string
  couple_sector: string
  contracts_completed: number
  ranking_position?: number
  ranking_status: 'Verde' | 'Amarelo' | 'Vermelho'
  is_top_1500: boolean
  can_be_replaced: boolean
  is_friend?: boolean
  deleted_at?: string | null
  created_at: string
  updated_at: string
}

export interface Friend {
  id: number
  member_id: number
  name: string
  phone: string
  instagram: string
  city: string
  sector: string
  referrer: string
  registration_date: string
  status: 'Ativo' | 'Inativo'
  couple_name: string
  couple_phone: string
  couple_instagram: string
  couple_city: string
  couple_sector: string
  contracts_completed: number
  ranking_position?: number
  ranking_status: 'Verde' | 'Amarelo' | 'Vermelho'
  is_top_1500: boolean
  can_be_replaced: boolean
  post_verified_1: boolean
  post_verified_2: boolean
  post_url_1?: string
  post_url_2?: string
  created_at: string
  updated_at: string
}

export interface PaidContract {
  id: number
  member_id: number
  couple_name_1: string
  couple_phone_1: string
  couple_instagram_1: string
  couple_name_2: string
  couple_phone_2: string
  couple_instagram_2: string
  contract_date: string
  status: 'Ativo' | 'Inativo'
  created_at: string
  updated_at: string
}

export interface UserLink {
  id: number
  link_id: string
  user_id: string
  link_type: 'members' | 'friends'
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface SystemSettings {
  max_members: number
  contracts_per_member: number
  ranking_green_threshold: number
  ranking_yellow_threshold: number
  paid_contracts_phase_active: boolean
  paid_contracts_start_date: string
  member_links_type: 'members' | 'friends'
  admin_controls_link_type: boolean
}

export interface PhaseControl {
  id: number
  phase_name: string
  is_active: boolean
  start_date?: string
  end_date?: string
  max_limit?: number
  current_count: number
  created_at: string
  updated_at: string
}

// URL base da API - dinâmica para funcionar em desenvolvimento e produção
const getApiBaseUrl = () => {
  // Se VITE_API_URL estiver definida, usar ela
  if (import.meta.env.VITE_API_URL) {
    console.log('🔍 Debug - getApiBaseUrl: Usando VITE_API_URL:', import.meta.env.VITE_API_URL);
    return import.meta.env.VITE_API_URL;
  }
  
  // Em desenvolvimento, usa o proxy (mesma porta do frontend)
  if (import.meta.env.DEV) {
    console.log('🔍 Debug - getApiBaseUrl: Usando URL relativa (DEV): /api');
    return '/api';
  }
  
  // Em produção, usar URL relativa
  console.log('🔍 Debug - getApiBaseUrl: Usando URL relativa (PROD): /api');
  return '/api';
};

const API_BASE_URL = getApiBaseUrl();
console.log('🔍 Debug - API_BASE_URL definida como:', API_BASE_URL);

// Função para fazer requisições à API
const apiRequest = async (endpoint: string, options: RequestInit = {}) => {
  const url = `${API_BASE_URL}${endpoint}`;
  console.log('🔍 Debug - apiRequest: Fazendo requisição para:', url);
  
  const response = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  });

  console.log('🔍 Debug - apiRequest: Status da resposta:', response.status);

  if (!response.ok) {
    console.error('❌ Debug - apiRequest: Erro HTTP:', response.status);
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  const data = await response.json();
  console.log('🔍 Debug - apiRequest: Dados recebidos:', data);
  return data;
};

// Funções para comunicação com a API
export const executeQuery = async <T = unknown>(
  query: string, 
  params: unknown[] = []
): Promise<T[]> => {
  // Esta função será implementada quando necessário
  return [];
}

export const executeSingleQuery = async <T = unknown>(
  query: string, 
  params: unknown[] = []
): Promise<T | null> => {
  // Esta função será implementada quando necessário
  return null;
}

export const insertData = async (
  table: string, 
  data: Record<string, unknown>
): Promise<void> => {
  // Esta função será implementada quando necessário
}

export const updateData = async (
  table: string, 
  data: Record<string, unknown>, 
  where: Record<string, unknown>
): Promise<void> => {
  // Esta função será implementada quando necessário
}

export const deleteData = async (
  table: string, 
  where: Record<string, unknown>
): Promise<void> => {
  // Esta função será implementada quando necessário
}

export const testConnection = async (): Promise<boolean> => {
  try {
    const result = await apiRequest('/test-connection');
    return result.success;
  } catch (error) {
    return false;
  }
}

// Função para login via API
export const loginUser = async (username: string, password: string) => {
  const result = await apiRequest('/login', {
    method: 'POST',
    body: JSON.stringify({ username, password }),
  });
  return result;
}

// Função para validar sessão via API
export const validateSession = async (userId: string) => {
  const result = await apiRequest('/validate-session', {
    method: 'POST',
    body: JSON.stringify({ userId }),
  });
  return result;
}

// Função para buscar configurações do sistema via API
export const getSystemSettings = async () => {
  const result = await apiRequest('/system-settings');
  return result;
}

// Função para buscar estatísticas via API
export const getStats = async (referrer?: string) => {
  // Construir URL manualmente para evitar problemas com new URL()
  let url = `${API_BASE_URL}/stats`;
  const searchParams = new URLSearchParams();
  
  if (referrer) {
    searchParams.append('referrer', referrer);
  }
  
  if (searchParams.toString()) {
    url += `?${searchParams.toString()}`;
  }
  
  const result = await apiRequest(url.replace(API_BASE_URL, ''));
  return result;
}

// Função para buscar dados de relatórios via API
export const getReports = async (referrer?: string) => {
  // Construir URL manualmente para evitar problemas com new URL()
  let url = `${API_BASE_URL}/reports`;
  const searchParams = new URLSearchParams();
  
  if (referrer) {
    searchParams.append('referrer', referrer);
  }
  
  if (searchParams.toString()) {
    url += `?${searchParams.toString()}`;
  }
  
  const result = await apiRequest(url.replace(API_BASE_URL, ''));
  return result;
}

// Função para buscar membros via API
export const getMembers = async (params?: {
  referrer?: string;
  search?: string;
  phone?: string;
  status?: string;
  city?: string;
  sector?: string;
  page?: number;
  limit?: number;
}) => {
    console.log('🔍 Debug - getMembers: Parâmetros recebidos:', params);
    
    // Construir URL manualmente para evitar problemas com new URL()
    let url = `${API_BASE_URL}/members`;
    const searchParams = new URLSearchParams();
    
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, value.toString());
        }
      });
    }
    
    if (searchParams.toString()) {
      url += `?${searchParams.toString()}`;
    }
    
    console.log('🔍 Debug - getMembers: URL final:', url);
    const result = await apiRequest(url.replace(API_BASE_URL, ''));
    console.log('🔍 Debug - getMembers: Resultado da API:', result);
    return result;
}

// Função para buscar estatísticas de membros via API
export const getMemberStats = async (referrer?: string) => {
  // Construir URL manualmente para evitar problemas com new URL()
  let url = `${API_BASE_URL}/member-stats`;
  const searchParams = new URLSearchParams();
  
  if (referrer) {
    searchParams.append('referrer', referrer);
  }
  
  if (searchParams.toString()) {
    url += `?${searchParams.toString()}`;
  }
  
  const result = await apiRequest(url.replace(API_BASE_URL, ''));
  return result;
}

// Função para buscar amigos via API
export const getFriends = async (params?: {
  search?: string;
  phone?: string;
  member?: string;
  city?: string;
  sector?: string;
  page?: number;
  limit?: number;
}) => {
    // Construir URL manualmente para evitar problemas com new URL()
    let url = `${API_BASE_URL}/friends`;
    const searchParams = new URLSearchParams();
    
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, value.toString());
        }
      });
    }
    
    if (searchParams.toString()) {
      url += `?${searchParams.toString()}`;
    }
    
    const result = await apiRequest(url.replace(API_BASE_URL, ''));
    return result;
}

// Função para buscar estatísticas de amigos via API
export const getFriendStats = async () => {
  const result = await apiRequest('/friend-stats');
  return result;
}

// Funções para system_settings
export const getSystemSettingsByKey = async (key: string) => {
  try {
    const result = await apiRequest(`/system-settings?key=${key}`);
    return { data: result.data || [], error: null };
  } catch (error) {
    return { data: [], error: error };
  }
}

export const insertSystemSetting = async (setting: {
  setting_key: string;
  setting_value: string;
  description: string;
}) => {
  try {
    const result = await apiRequest('/system-settings', {
      method: 'POST',
      body: JSON.stringify(setting),
    });
    return { data: result.data, error: null };
  } catch (error) {
    return { data: null, error: error };
  }
}