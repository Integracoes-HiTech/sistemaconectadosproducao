// hooks/useStats.ts
import { useState, useEffect } from 'react'
import { Stats } from '@/lib/database'

// URL base da API - dinâmica para funcionar em desenvolvimento e produção
const getApiBaseUrl = () => {
  // Se VITE_API_URL estiver definida, usar ela
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }
  
  // Se estiver em desenvolvimento, usar localhost
  if (import.meta.env.DEV) {
    return 'http://localhost:3001/api';
  }
  
  // Em produção, usar URL relativa
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

export const useStats = (referrer?: string) => {
  const [stats, setStats] = useState<Stats>({
    total_users: 0,
    active_users: 0,
    recent_registrations: 0,
    engagement_rate: 0,
    today_registrations: 0
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // Limpar estado anterior antes de buscar novos dados
    setStats({
      total_users: 0,
      active_users: 0,
      recent_registrations: 0,
      engagement_rate: 0,
      today_registrations: 0
    })
    setError(null)
    fetchStats()
  }, [referrer])

  const fetchStats = async () => {
    try {
      setLoading(true)
      setError(null)

      // Construir URL com parâmetros
      const url = new URL('/stats', API_BASE_URL);
      if (referrer) {
        url.searchParams.append('referrer', referrer);
      }

      const result = await apiRequest(url.pathname + url.search);

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar estatísticas');
      }

      setStats(result.stats);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar estatísticas')
    } finally {
      setLoading(false)
    }
  }

  return {
    stats,
    loading,
    error,
    refetch: fetchStats
  }
}