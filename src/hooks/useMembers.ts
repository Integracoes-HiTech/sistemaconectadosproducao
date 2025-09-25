// hooks/useMembers.ts
import { useState, useEffect, useCallback } from 'react'
import { getMembers, getMemberStats, getSystemSettings, Member, MemberStats, SystemSettings } from '@/lib/database'

// URL base da API - dinâmica para funcionar em desenvolvimento e produção
const API_BASE_URL = import.meta.env.VITE_API_URL || 
  (import.meta.env.DEV ? '${API_BASE_URL}' : '/api');

// Re-exportar tipos para uso em outros componentes
export type { Member, MemberStats, SystemSettings }

export const useMembers = (referrer?: string) => {
  const [members, setMembers] = useState<Member[]>([])
  const [memberStats, setMemberStats] = useState<MemberStats | null>(null)
  const [systemSettings, setSystemSettings] = useState<SystemSettings | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchMembers = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const result = await getMembers({ referrer });
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar membros');
      }

      setMembers(result.members || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar membros')
    } finally {
      setLoading(false)
    }
  }, [referrer])

  const fetchMemberStats = useCallback(async () => {
    try {
      const result = await getMemberStats(referrer);
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar estatísticas');
      }

      const stats: MemberStats = {
        total_members: result.memberStats.total_members || 0,
        green_members: result.memberStats.green_members || 0,
        yellow_members: result.memberStats.yellow_members || 0,
        red_members: result.memberStats.red_members || 0,
        top_1500_members: 0, // Implementar se necessário
        current_member_count: result.memberStats.current_member_count || 0,
        max_member_limit: result.memberStats.max_member_limit || 1500,
        can_register_more: (result.memberStats.current_member_count || 0) < (result.memberStats.max_member_limit || 1500)
      }

      setMemberStats(stats)
    } catch (err) {
      // Erro ao carregar estatísticas dos membros
    }
  }, [referrer])

  const fetchSystemSettings = useCallback(async () => {
    try {
      const result = await getSystemSettings();
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar configurações');
      }

      const settings: SystemSettings = {
        max_members: result.settings.max_members || 1500,
        contracts_per_member: result.settings.contracts_per_member || 15,
        ranking_green_threshold: result.settings.ranking_green_threshold || 15,
        ranking_yellow_threshold: result.settings.ranking_yellow_threshold || 1,
        paid_contracts_phase_active: result.settings.paid_contracts_phase_active || false,
        paid_contracts_start_date: result.settings.paid_contracts_start_date || '2026-07-01'
      }

      setSystemSettings(settings)
    } catch (err) {
      // Erro ao carregar configurações do sistema
    }
  }, [])

  // Funções auxiliares para o dashboard
  const getRankingStatusColor = (status: string) => {
    switch (status) {
      case 'Verde':
        return 'bg-green-100 text-green-800'
      case 'Amarelo':
        return 'bg-yellow-100 text-yellow-800'
      case 'Vermelho':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getRankingStatusIcon = (status: string) => {
    switch (status) {
      case 'Verde':
        return '🟢'
      case 'Amarelo':
        return '🟡'
      case 'Vermelho':
        return '🔴'
      default:
        return '⚪'
    }
  }

  const getTopMembers = (limit: number = 10) => {
    return members
      .filter(member => member.ranking_position !== null)
      .sort((a, b) => (a.ranking_position || 0) - (b.ranking_position || 0))
      .slice(0, limit)
  }

  const getMembersByStatus = (status: 'Verde' | 'Amarelo' | 'Vermelho') => {
    return members.filter(member => member.ranking_status === status)
  }

  const getMemberRole = (member: Member) => {
    if (member.is_friend) {
      return 'Amigo'
    }
    return 'Membro'
  }

  const addMember = async (memberData: Omit<Member, 'id' | 'created_at' | 'updated_at' | 'contracts_completed' | 'ranking_position' | 'ranking_status' | 'is_top_1500' | 'can_be_replaced'>) => {
    try {
      const response = await fetch('${API_BASE_URL}/members', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(memberData)
      });

      const result = await response.json();
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao adicionar membro');
      }

      // Recarregar dados após adição
      await fetchMembers();
      
      return { success: true, data: result.data };
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao adicionar membro' 
      };
    }
  };

  const softDeleteMember = async (memberId: string) => {
    try {
      const response = await fetch(`${API_BASE_URL}/members/${memberId}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        }
      });

      const result = await response.json();
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao excluir membro');
      }
      
      // Recarregar dados após exclusão
      await fetchMembers();
      
      return { success: true, data: result.data };
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao excluir membro' 
      };
    }
  }

  useEffect(() => {
    fetchMembers()
    fetchMemberStats()
    fetchSystemSettings()
  }, [fetchMembers, fetchMemberStats, fetchSystemSettings])

  return {
    members,
    memberStats,
    systemSettings,
    loading,
    error,
    getRankingStatusColor,
    getRankingStatusIcon,
    getTopMembers,
    getMembersByStatus,
    getMemberRole,
    addMember,
    softDeleteMember,
    refetch: fetchMembers
  }
}