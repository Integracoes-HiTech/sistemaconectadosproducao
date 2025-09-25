// hooks/useReports.ts
import { useState, useEffect, useCallback } from 'react'

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

export interface ReportData {
  usersByLocation: Record<string, number>
  registrationsByDay: Array<{ date: string; quantidade: number }>
  usersByStatus: Array<{ name: string; value: number; color: string }>
  recentActivity: Array<{
    id: string
    name: string
    action: string
    date: string
  }>
  sectorsByCity: Record<string, number>
  sectorsGroupedByCity: Record<string, { sectors: string[]; count: number; totalSectors: number }>
  usersByCity: Record<string, number>
}

export const useReports = (referrer?: string) => {
  const [reportData, setReportData] = useState<ReportData>({
    usersByLocation: {},
    registrationsByDay: [],
    usersByStatus: [],
    recentActivity: [],
    sectorsByCity: {},
    sectorsGroupedByCity: {},
    usersByCity: {}
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchReportData = useCallback(async () => {
    try {
      console.log('🔍 Debug - useReports: Iniciando busca de reports com referrer:', referrer);
      setLoading(true)
      setError(null)

      // Construir URL manualmente para evitar problemas com new URL()
      let url = `${API_BASE_URL}/reports`;
      const searchParams = new URLSearchParams();
      
      if (referrer) {
        searchParams.append('referrer', referrer);
      }
      
      if (searchParams.toString()) {
        url += `?${searchParams.toString()}`;
      }
      
      console.log('🔍 Debug - useReports: URL final:', url);
      const result = await apiRequest(url.replace(API_BASE_URL, ''));
      console.log('🔍 Debug - useReports: Resultado da API:', result);

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar dados dos relatórios');
      }

      console.log('🔍 Debug - useReports: Reports encontrados:', result.reportData);
      setReportData(result.reportData);
    } catch (err) {
      console.error('❌ Debug - useReports: Erro:', err);
      setError(err instanceof Error ? err.message : 'Erro ao carregar dados dos relatórios')
    } finally {
      setLoading(false)
    }
  }, [referrer])

  useEffect(() => {
    // Limpar estado anterior antes de buscar novos dados
    setReportData({
      usersByLocation: {},
      registrationsByDay: [],
      usersByStatus: [],
      recentActivity: [],
      sectorsByCity: {},
      sectorsGroupedByCity: {},
      usersByCity: {}
    })
    setError(null)
    fetchReportData()
  }, [fetchReportData])

  return {
    reportData,
    loading,
    error,
    refetch: fetchReportData
  }
}