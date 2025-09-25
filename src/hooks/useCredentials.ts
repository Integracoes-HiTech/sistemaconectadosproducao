// hooks/useCredentials.ts
import { useState } from 'react'

// URL base da API - dinâmica para funcionar em desenvolvimento e produção
const getApiBaseUrl = () => {
  // Se VITE_API_URL estiver definida, usar ela
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  
  // Em desenvolvimento e produção, usar URL relativa (proxy do Vite)
  return '/api';
};

const API_BASE_URL = getApiBaseUrl();

// Função para fazer requisições à API
const apiRequest = async (endpoint: string, options: RequestInit = {}) => {
  try {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    throw error;
  }
};

export interface Credentials {
  username: string
  password: string
  login_url: string
}

export const useCredentials = () => {
  const [loading, setLoading] = useState(false)

  // Gerar credenciais automáticas baseadas no Instagram e telefone
  const generateCredentials = (userData: { instagram: string; phone: string }): Credentials => {
    // Username baseado no Instagram (sem @)
    const username = userData.instagram.replace('@', '').toLowerCase()
    
    // Senha baseada no Instagram + últimos 4 dígitos do telefone
    const instagramClean = userData.instagram.replace('@', '').toLowerCase()
    const phoneDigits = userData.phone.replace(/\D/g, '') // Remove caracteres não numéricos
    const lastDigits = phoneDigits.slice(-4) // Últimos 4 dígitos
    const password = `${instagramClean}${lastDigits}` // Ex: joaosilva4321
    
    return {
      username,
      password,
      login_url: `${window.location.origin}/login`
    }
  }

  // Criar usuário de autenticação com credenciais geradas
  const createAuthUser = async (userData: { name: string; instagram: string; phone: string; referrer?: string; display_name?: string }, credentials: Credentials) => {
    try {
      setLoading(true)

      // Verificar se a fase de contratos pagos está ativa
      const settingsResult = await apiRequest('/system-settings');
      
      if (!settingsResult.success) {
        throw new Error(settingsResult.error || 'Erro ao buscar configurações');
      }

      const settings = settingsResult.settings;
      const isPaidContractsPhaseActive = settings?.paid_contracts_phase_active === true;

      // Determinar role baseado no referrer e na fase ativa
      let userRole = 'Membro'; // Padrão: sempre Membro
      let fullName = `${userData.name} - Membro`;

      // Se tem referrer, verificar o role do referrer
      if (userData.referrer) {
        // Buscar dados do referrer para determinar role
        const authUsersResult = await apiRequest(`/auth-users?referrer=${encodeURIComponent(userData.referrer)}`);
        
        if (authUsersResult.success && authUsersResult.users?.length > 0) {
          const referrerData = authUsersResult.users[0];

          // Se referrer é Administrador, usuário é Membro
          if (referrerData.role === 'Administrador') {
            userRole = 'Membro';
            fullName = `${userData.name} - Membro`;
          }
          // Se referrer é Membro, usuário pode ser Amigo (mas só se a fase estiver ativa)
          else if (referrerData.role === 'Membro') {
            if (isPaidContractsPhaseActive) {
              userRole = 'Amigo';
              fullName = `${userData.name} - Amigo`;
            } else {
              // Fase inativa: membros cadastram membros
              userRole = 'Membro';
              fullName = `${userData.name} - Membro`;
            }
          }
          // Se referrer é Amigo, usuário é Membro (não há mais Convidado)
          else if (referrerData.role === 'Amigo') {
            userRole = 'Membro';
            fullName = `${userData.name} - Membro`;
          }
        }
      }

      const authUserData = {
        username: credentials.username,
        password: credentials.password,
        name: userData.name,
        role: userRole,
        full_name: fullName,
        display_name: userData.display_name || null,
        instagram: userData.instagram,
        phone: userData.phone,
        is_active: false // Status inativo por padrão
      }

      const result = await apiRequest('/auth-users', {
        method: 'POST',
        body: JSON.stringify(authUserData)
      });
      
      if (!result.success) {
        // Erro na API
        throw new Error(result.error || 'Erro ao criar usuário de autenticação');
      }

      // Usuário criado com sucesso
      return { success: true, data: result.data }
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao criar usuário de autenticação' 
      }
    } finally {
      setLoading(false)
    }
  }

  // Verificar se username já existe
  const checkUsernameExists = async (username: string) => {
    try {
      const result = await apiRequest(`/auth-users?username=${encodeURIComponent(username)}`);
      
      if (!result.success) {
        return { exists: false, error: result.error };
      }
      
      return { exists: result.users && result.users.length > 0 }
    } catch (err) {
      return { 
        exists: false, 
        error: err instanceof Error ? err.message : 'Erro ao verificar username' 
      }
    }
  }

  // Gerar username único
  const generateUniqueUsername = async (baseUsername: string) => {
    let username = baseUsername
    let counter = 1

    while (true) {
      const { exists } = await checkUsernameExists(username)
      if (!exists) break
      
      username = `${baseUsername}${counter}`
      counter++
    }

    return username
  }

  // Processo completo: gerar credenciais únicas e criar usuário
  const createUserWithCredentials = async (memberId: number): Promise<{
    success: true;
    credentials: Credentials;
    authUser: unknown;
  } | {
    success: false;
    error: string;
  }> => {
    try {
      setLoading(true)

      // Usar o novo endpoint que cria usuário baseado nos dados do membro
      const result = await apiRequest('/auth-users/from-member', {
        method: 'POST',
        body: JSON.stringify({
          member_id: memberId
        })
      });
      
      if (!result.success) {
        return {
          success: false,
          error: result.error || 'Erro ao criar usuário de autenticação'
        }
      }

      // Usuário criado com sucesso
      return { 
        success: true, 
        credentials: result.credentials,
        authUser: result.data
      }
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao criar usuário com credenciais' 
      }
    } finally {
      setLoading(false)
    }
  }

  return {
    loading,
    generateCredentials,
    createAuthUser,
    checkUsernameExists,
    generateUniqueUsername,
    createUserWithCredentials
  }
}