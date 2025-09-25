// hooks/useSystemSettings.ts
import { useState, useEffect, useCallback } from 'react'
import { getSystemSettings, SystemSettings, PhaseControl } from '@/lib/database'

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

export const useSystemSettings = () => {
  const [settings, setSettings] = useState<SystemSettings | null>(null)
  const [phases, setPhases] = useState<PhaseControl[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchSettings = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const result = await getSystemSettings()

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar configurações')
      }
      
      setSettings(result.settings)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro desconhecido')
    } finally {
      setLoading(false)
    }
  }, [])

  const fetchPhases = useCallback(async () => {
    try {
      // Por enquanto, retornar array vazio
      // Implementar endpoint para phases quando necessário
      setPhases([])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao buscar fases')
    }
  }, [])

  useEffect(() => {
    fetchSettings()
    fetchPhases()
  }, [fetchSettings, fetchPhases])

  // Funções auxiliares para o dashboard
  const shouldShowMemberLimitAlert = () => {
    if (!settings) return false;
    // Usar dados da API que já calcula baseado na contagem real de membros
    return settings.phase_status?.status === 'near' || 
           settings.phase_status?.status === 'reached' || 
           settings.phase_status?.status === 'exceeded';
  }

  const getMemberLimitStatus = () => {
    if (!settings?.phase_status) return { status: 'unknown', message: '', percentage: 0 };
    
    const phaseStatus = settings.phase_status;
    
    return {
      status: phaseStatus.status,
      message: phaseStatus.message,
      percentage: parseFloat(phaseStatus.percentage),
      member_count: parseInt(phaseStatus.member_count),
      max_members: parseInt(phaseStatus.max_members),
      can_register: phaseStatus.can_register,
      should_activate_phase: phaseStatus.should_activate_phase
    };
  }

  const canActivatePaidContracts = () => {
    // Só pode ativar se não estiver ativa E se atingiu 1500 membros
    return settings?.paid_contracts_phase_active === false && 
           settings?.phase_status?.should_activate_phase === true;
  }

  const checkMemberLimit = async () => {
    try {
      // Buscar contagem atual de membros via API
      const response = await fetch(`${API_BASE_URL}/members`);
      const result = await response.json();
      
      if (!result.success) {
        return { canRegister: false, message: 'Erro ao verificar limite de membros', max: 1500 };
      }
      
      const currentCount = result.members?.length || 0;
      const maxMembers = 1500;
      
      if (currentCount >= maxMembers) {
        return { 
          canRegister: false, 
          message: `O sistema atingiu o limite máximo de ${maxMembers} membros.`, 
          max: maxMembers 
        };
      }
      
      return { 
        canRegister: true, 
        message: `Dentro do limite (${currentCount}/${maxMembers})`, 
        max: maxMembers 
      };
    } catch (error) {
      return { canRegister: false, message: 'Erro ao verificar limite', max: 1500 };
    }
  }

  const activatePaidContractsPhase = async (active: boolean) => {
    try {
      
      
      const response = await fetch(`${API_BASE_URL}/system-settings/update-phase`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        }
      });

      const result = await response.json();

      if (!result.success) {
        throw new Error(result.error || 'Erro ao atualizar fase');
      }

     
      
      // Atualizar configurações locais
      if (result.settings) {
        setSettings(prev => ({
          ...prev,
          paid_contracts_phase_active: result.settings.paid_contracts_phase_active === 'true',
          phase_status: result.phase_status
        }));
      }

      return { 
        success: true, 
        message: result.message,
        phase_status: result.phase_status
      };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Erro ao atualizar fase' 
      };
    }
  }

  const updateMemberLinksType = async (type: 'members' | 'friends') => {
    try {
      
      const response = await fetch(`${API_BASE_URL}/update-link-type`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ linkType: type })
      });

      const result = await response.json();

      if (!result.success) {
        throw new Error(result.error || 'Erro ao atualizar tipo de links');
      }

      
      // Atualizar configurações locais
      setSettings(prev => ({
        ...prev,
        member_links_type: type
      }));

      return { 
        success: true, 
        message: result.message,
        updated_links_count: result.updated_links_count
      };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Erro ao atualizar tipo de links' 
      };
    }
  }

  return {
    settings,
    phases,
    loading,
    error,
    refetch: fetchSettings,
    refetchPhases: fetchPhases,
    shouldShowMemberLimitAlert,
    getMemberLimitStatus,
    canActivatePaidContracts,
    activatePaidContractsPhase,
    updateMemberLinksType,
    checkMemberLimit
  }
}