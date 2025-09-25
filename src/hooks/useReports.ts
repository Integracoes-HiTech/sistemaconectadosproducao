// hooks/useReports.ts
import { useState, useEffect, useCallback } from 'react'

// URL base da API - dinâmica para funcionar em desenvolvimento e produção
const API_BASE_URL = import.meta.env.VITE_API_URL || 
  (import.meta.env.DEV ? 'http://localhost:3001/api' : '/api');

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
      setLoading(true)
      setError(null)

      // Construir URL com parâmetros
      const url = new URL('/reports', API_BASE_URL);
      if (referrer) {
        url.searchParams.append('referrer', referrer);
      }

      const result = await apiRequest(url.pathname + url.search);

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar dados dos relatórios');
      }

      setReportData(result.reportData);
    } catch (err) {
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