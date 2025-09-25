// hooks/useFriends.ts
import { useState, useEffect, useCallback } from 'react'

// URL base da API
const API_BASE_URL = 'http://localhost:3001/api';

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

export interface Friend {
  id: string
  member_id: string
  // Mesma estrutura de membros
  name: string
  phone: string
  instagram: string
  city: string
  sector: string
  referrer: string
  registration_date: string
  status: 'Ativo' | 'Inativo'
  // Dados da segunda pessoa (obrigatório - regra da dupla)
  couple_name: string
  couple_phone: string
  couple_instagram: string
  couple_city: string
  couple_sector: string
  // Campos específicos do sistema de amigos (mesma lógica de membros)
  contracts_completed: number
  ranking_position: number | null
  ranking_status: 'Verde' | 'Amarelo' | 'Vermelho'
  is_top_1500: boolean
  can_be_replaced: boolean
  // Campos de verificação de posts (específicos de amigos)
  post_verified_1: boolean
  post_verified_2: boolean
  post_url_1: string | null
  post_url_2: string | null
  // Campo para soft delete
  deleted_at: string | null
  created_at: string
  updated_at: string
}

export const useFriends = () => {
  const [friends, setFriends] = useState<Friend[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchFriends = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      const result = await apiRequest('/friends');

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar amigos');
      }

      setFriends(result.friends || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar amigos')
    } finally {
      setLoading(false)
    }
  }, [])

  const addFriend = async (friendData: Omit<Friend, 'id' | 'created_at' | 'updated_at' | 'contracts_completed' | 'ranking_position' | 'ranking_status' | 'is_top_1500' | 'can_be_replaced' | 'post_verified_1' | 'post_verified_2' | 'post_url_1' | 'post_url_2'>) => {
    try {
      
      // Buscar o ID do membro que está cadastrando o amigo
      
      // Primeiro tentar busca exata
      const membersResult = await apiRequest(`/members?search=${encodeURIComponent(friendData.referrer)}`);
      
      if (!membersResult.success) {
        throw new Error(`Erro ao buscar membro referrer: ${membersResult.error}`);
      }

      let memberData = membersResult.members?.find((member: any) => 
        member.name.toLowerCase() === friendData.referrer.toLowerCase()
      );

      if (!memberData) {
        // Tentar busca case-insensitive
        memberData = membersResult.members?.find((member: any) => 
          member.name.toLowerCase().includes(friendData.referrer.toLowerCase())
        );

        if (!memberData) {
          throw new Error(`Membro referrer "${friendData.referrer}" não encontrado na tabela members`);
        }
      }


      const insertData = {
        ...friendData,
        member_id: memberData.id,
        contracts_completed: 0,
        ranking_status: 'Vermelho' as const,
        is_top_1500: false,
        can_be_replaced: false,
        post_verified_1: false,
        post_verified_2: false,
        post_url_1: null,
        post_url_2: null
      };
      

      const result = await apiRequest('/friends', {
        method: 'POST',
        body: JSON.stringify(insertData)
      });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao inserir amigo');
      }


      // Atualizar contratos do membro referrer
      await updateReferrerContracts(friendData.referrer);

      // Recarregar dados
      await fetchFriends()

      return { success: true, data: result.data }
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao adicionar amigo' 
      }
    }
  }

  const updateReferrerContracts = async (referrerName: string) => {
    try {
      
      // Buscar o membro referrer pelo nome
      const membersResult = await apiRequest(`/members?search=${encodeURIComponent(referrerName)}`);
      
      if (!membersResult.success) {
        return;
      }

      const referrerMember = membersResult.members?.find((member: any) => 
        member.name.toLowerCase() === referrerName.toLowerCase()
      );

      if (!referrerMember) {
        return;
      }

      // Contar amigos ativos cadastrados por este membro
      const friendsResult = await apiRequest(`/friends?member=${encodeURIComponent(referrerName)}`);
      
      if (!friendsResult.success) {
        return;
      }

      const friendsCount = friendsResult.friends?.length || 0;
      const currentContracts = referrerMember.contracts_completed;


      // Atualizar contracts_completed
      
      const updateResult = await apiRequest(`/members/${referrerMember.id}`, {
        method: 'PUT',
        body: JSON.stringify({ 
          contracts_completed: friendsCount,
          updated_at: new Date().toISOString()
        })
      });

      if (!updateResult.success) {
        return;
      }

      
      // Atualizar ranking após mudança nos contratos
      await updateRanking();
      
    } catch (err) {
    }
  }

  const updateRanking = async () => {
    try {
      
      // Por enquanto, apenas recarregar os dados
      // Implementar endpoint de ranking quando necessário
      await fetchFriends()
    } catch (err) {
    }
  }

  const softDeleteFriend = async (friendId: string) => {
    try {
      
      const result = await apiRequest(`/friends/${friendId}`, {
        method: 'DELETE'
      });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao excluir amigo');
      }


      // Recarregar dados após exclusão
      await fetchFriends();

      return { success: true, data: result.data };
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao excluir amigo' 
      };
    }
  }

  useEffect(() => {
    fetchFriends()
  }, [fetchFriends])

  return {
    friends,
    loading,
    error,
    addFriend,
    updateRanking,
    softDeleteFriend,
    refetch: fetchFriends
  }
}