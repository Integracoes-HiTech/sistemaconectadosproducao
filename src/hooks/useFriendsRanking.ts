// hooks/useFriendsRanking.ts
import { useState, useEffect } from 'react';

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

export interface FriendRanking {
  id: string;
  member_id: string;
  // Dados do amigo (mesma estrutura de membros)
  name: string;
  phone: string;
  instagram: string;
  city: string;
  sector: string;
  referrer: string;
  registration_date: string;
  status: string;
  couple_name: string;
  couple_phone: string;
  couple_instagram: string;
  couple_city: string;
  couple_sector: string;
  contracts_completed: number; // Quantos usuários este amigo cadastrou
  ranking_position: number;
  ranking_status: 'Verde' | 'Amarelo' | 'Vermelho';
  is_top_1500: boolean;
  can_be_replaced: boolean;
  post_verified_1: boolean;
  post_verified_2: boolean;
  post_url_1: string | null;
  post_url_2: string | null;
  created_at: string;
  updated_at: string;
  // Dados do membro que cadastrou
  member_name: string;
  member_instagram: string;
  member_phone: string;
  member_city: string;
  member_sector: string;
}

export const useFriendsRanking = () => {
  const [friends, setFriends] = useState<FriendRanking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchFriendsRanking = async () => {
    try {
      setLoading(true);
      setError(null);

      const result = await apiRequest('/friends');
      
      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar amigos');
      }

      // Adicionar dados do membro (referrer) para cada amigo
      const friendsWithMemberData = result.friends.map((friend: any) => ({
        ...friend,
        member_name: friend.referrer,
        member_instagram: '', // Implementar se necessário
        member_phone: '', // Implementar se necessário
        member_city: '', // Implementar se necessário
        member_sector: '' // Implementar se necessário
      }));

      setFriends(friendsWithMemberData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar ranking de amigos');
    } finally {
      setLoading(false);
    }
  };

  const getFriendsStats = () => {
    const total = friends.length;
    const verde = friends.filter(f => f.ranking_status === 'Verde').length;
    const amarelo = friends.filter(f => f.ranking_status === 'Amarelo').length;
    const vermelho = friends.filter(f => f.ranking_status === 'Vermelho').length;

    return {
      total,
      verde,
      amarelo,
      vermelho
    };
  };

  const softDeleteFriend = async (friendId: string) => {
    try {
      const result = await apiRequest(`/friends/${friendId}`, {
        method: 'DELETE'
      });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao excluir amigo');
      }
      
      // Recarregar dados após exclusão
      await fetchFriendsRanking();
      
      return { success: true, data: result.data };
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao excluir amigo' 
      };
    }
  };

  useEffect(() => {
    fetchFriendsRanking();
  }, []);

  return {
    friends,
    loading,
    error,
    getFriendsStats,
    softDeleteFriend,
    refetch: fetchFriendsRanking
  };
};