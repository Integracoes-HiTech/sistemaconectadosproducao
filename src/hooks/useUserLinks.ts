// hooks/useUserLinks.ts
import { useState, useEffect } from 'react'

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

export interface UserLink {
  id: string
  link_id: string
  user_id: string
  referrer_name: string
  is_active: boolean
  click_count: number
  registration_count: number
  link_type: 'members' | 'friends'
  created_at: string
  expires_at?: string
  updated_at: string
  deleted_at?: string | null
  user_data?: any
}

export const useUserLinks = (userId?: string) => {
  const [userLink, setUserLink] = useState<UserLink | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchUserLink()
  }, [userId])

  const fetchUserLink = async () => {
    try {
      setLoading(true)
      setError(null)

      if (!userId) {
        setUserLink(null)
        return
      }

      // Construir URL manualmente para evitar problemas com new URL()
      let url = `${API_BASE_URL}/user-links`;
      const searchParams = new URLSearchParams();
      searchParams.append('userId', userId);
      url += `?${searchParams.toString()}`;
      
      const result = await apiRequest(url.replace(API_BASE_URL, ''));

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar link');
      }

      // Usar o link único retornado
      setUserLink(result.link || null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar link')
    } finally {
      setLoading(false)
    }
  }

  // Função para buscar link por ID (para PublicRegister)
  const getUserByLinkId = async (linkId: string) => {
    try {
      const result = await apiRequest(`/link/${linkId}`);

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar link');
      }

      return { success: true, data: result.data };
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao buscar link' 
      };
    }
  }

  // Função para incrementar contador de cliques
  const incrementClickCount = async (linkId: string) => {
    try {
      const result = await apiRequest(`/link/${linkId}/increment-clicks`, {
        method: 'PUT'
      });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao incrementar cliques');
      }

      return { success: true };
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao incrementar cliques' 
      };
    }
  }

  const createLink = async (userId: string, fullName: string) => {
    try {
      console.log('🔍 Debug - createLink chamada com:', { userId, fullName });
      
      const result = await apiRequest('/generate-link', {
        method: 'POST',
        body: JSON.stringify({ userId, userName: fullName })
      });

      console.log('🔍 Debug - Resultado da API:', result);

      if (!result.success) {
        throw new Error(result.error || 'Erro ao criar link');
      }

      // Atualizar lista de links apenas se userId estiver definido
      if (userId) {
        console.log('🔍 Debug - Atualizando lista de links...');
        await fetchUserLink();
      }
      
      console.log('🔍 Debug - createLink sucesso:', result);
      return result;
    } catch (err) {
      console.log('❌ Debug - Erro em createLink:', err);
      const errorMessage = err instanceof Error ? err.message : 'Erro ao criar link';
      return { success: false, error: errorMessage };
    }
  }

  const updateLink = async (linkId: string, updates: Partial<UserLink>) => {
    try {
      const result = await apiRequest(`/user-links/${linkId}`, {
        method: 'PUT',
        body: JSON.stringify(updates)
      });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao atualizar link');
      }

      // Atualizar lista de links
      await fetchUserLink();
      
      return result;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao atualizar link';
      return { success: false, error: errorMessage };
    }
  }

  const deleteLink = async (linkId: string) => {
    try {
      const result = await apiRequest(`/user-links/${linkId}`, {
        method: 'DELETE'
      });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao excluir link');
      }

      // Atualizar lista de links
      await fetchUserLink();
      
      return result;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro ao excluir link';
      return { success: false, error: errorMessage };
    }
  }

  return {
    userLink, // Link único
    userLinks: userLink ? [userLink] : [], // Manter compatibilidade
    loading,
    error,
    createLink,
    updateLink,
    deleteLink,
    getUserByLinkId,
    incrementClickCount,
    refetch: fetchUserLink
  }
}