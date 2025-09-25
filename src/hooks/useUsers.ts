// hooks/useUsers.ts
import { useState, useEffect } from 'react'
import { getMembers, Member } from '@/lib/database'

export const useUsers = (referrer?: string) => {
  const [users, setUsers] = useState<Member[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    // Limpar estado anterior antes de buscar novos dados
    setUsers([])
    setError(null)
    setLoading(true)
    
    // Adicionar delay para evitar race conditions
    const timeoutId = setTimeout(() => {
      fetchUsers()
    }, 100)
    
    return () => clearTimeout(timeoutId)
  }, [referrer])

  const fetchUsers = async () => {
    try {
      setLoading(true)
      setError(null)

      // Validar referrer antes de fazer a query
      if (referrer && typeof referrer !== 'string') {
        // Referrer inválido
        setUsers([])
        setLoading(false)
        return
      }

      const result = await getMembers({ referrer });

      if (!result.success) {
        throw new Error(result.error || 'Erro ao buscar usuários');
      }

      setUsers(result.members || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar usuários')
    } finally {
      setLoading(false)
    }
  }

  return {
    users,
    loading,
    error,
    refetch: fetchUsers
  }
}