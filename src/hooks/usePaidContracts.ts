// hooks/usePaidContracts.ts
import { useState, useEffect, useCallback } from 'react'
import { supabase } from '@/lib/supabase-temp'

export interface PaidContract {
  id: string
  member_id: string
  couple_name_1: string
  couple_name_2: string
  couple_phone_1: string
  couple_phone_2: string
  couple_instagram_1: string
  couple_instagram_2: string
  instagram_post_1: string | null
  instagram_post_2: string | null
  hashtag_1: string | null
  hashtag_2: string | null
  post_verified_1: boolean
  post_verified_2: boolean
  contract_status: 'Pendente' | 'Ativo' | 'Completo' | 'Cancelado'
  contract_date: string
  completion_date: string | null
  created_at: string
  updated_at: string
  member_data?: {
    name: string
    instagram: string
  }
}

export interface ContractStats {
  total_contracts: number
  completed_contracts: number
  pending_contracts: number
  active_contracts: number
  cancelled_contracts: number
  verified_posts: number
  pending_verification: number
}

export const usePaidContracts = (memberId?: string) => {
  const [contracts, setContracts] = useState<PaidContract[]>([])
  const [contractStats, setContractStats] = useState<ContractStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchContracts = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      let query = supabase
        .from('paid_contracts')
        .select(`
          *,
          member_data:members(name, instagram)
        `)
        .order('created_at', { ascending: false })

      if (memberId) {
        query = query.eq('member_id', memberId)
      }

      const { data, error } = await query

      if (error) throw error

      setContracts(data || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar contratos')
    } finally {
      setLoading(false)
    }
  }, [memberId])

  const fetchContractStats = useCallback(async () => {
    try {
      const { data, error } = await supabase
        .from('paid_contracts')
        .select('contract_status, post_verified_1, post_verified_2')

      if (error) throw error

      const stats: ContractStats = {
        total_contracts: data?.length || 0,
        completed_contracts: data?.filter(c => c.contract_status === 'Completo').length || 0,
        pending_contracts: data?.filter(c => c.contract_status === 'Pendente').length || 0,
        active_contracts: data?.filter(c => c.contract_status === 'Ativo').length || 0,
        cancelled_contracts: data?.filter(c => c.contract_status === 'Cancelado').length || 0,
        verified_posts: data?.filter(c => c.post_verified_1 && c.post_verified_2).length || 0,
        pending_verification: data?.filter(c => !c.post_verified_1 || !c.post_verified_2).length || 0
      }

      setContractStats(stats)
    } catch (err) {
      // Erro silencioso
    }
  }, [])

  const addContract = async (contractData: Omit<PaidContract, 'id' | 'created_at' | 'updated_at' | 'member_data'>) => {
    try {
      // Verificar se a fase de contratos pagos está ativa
      const { data: canRegister, error: canRegisterError } = await supabase
        .rpc('can_register_paid_contract')

      if (canRegisterError) throw canRegisterError

      if (!canRegister) {
        throw new Error('A fase de contratos pagos ainda não está ativa. Aguarde até julho de 2025.')
      }

      // Verificar se o membro já tem 15 contratos
      const { data: existingContracts, error: countError } = await supabase
        .from('paid_contracts')
        .select('id')
        .eq('member_id', contractData.member_id)
        .in('contract_status', ['Pendente', 'Ativo', 'Completo'])

      if (countError) throw countError

      if (existingContracts && existingContracts.length >= 15) {
        throw new Error('Este membro já atingiu o limite de 15 contratos pagos.')
      }

      // Gerar hashtags únicas
      const hashtag1 = `#Conectados${contractData.member_id.slice(-6)}${contractData.couple_instagram_1.slice(-3)}`
      const hashtag2 = `#Conectados${contractData.member_id.slice(-6)}${contractData.couple_instagram_2.slice(-3)}`

      const { data, error } = await supabase
        .from('paid_contracts')
        .insert([{
          ...contractData,
          hashtag_1: hashtag1,
          hashtag_2: hashtag2,
          post_verified_1: false,
          post_verified_2: false
        }])
        .select()
        .single()

      if (error) throw error

      return { success: true, data }
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao adicionar contrato' 
      }
    }
  }

  const updateContractStatus = async (contractId: string, status: 'Pendente' | 'Ativo' | 'Completo' | 'Cancelado') => {
    try {
      const updateData: any = { contract_status: status }
      
      if (status === 'Completo') {
        updateData.completion_date = new Date().toISOString().split('T')[0]
      }

      const { data, error } = await supabase
        .from('paid_contracts')
        .update(updateData)
        .eq('id', contractId)
        .select()
        .single()

      if (error) throw error

      return { success: true, data }
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao atualizar contrato' 
      }
    }
  }

  const verifyInstagramPost = async (contractId: string, personNumber: 1 | 2, postUrl: string) => {
    try {
      const updateData = {
        [`instagram_post_${personNumber}`]: postUrl,
        [`post_verified_${personNumber}`]: true
      }

      const { data, error } = await supabase
        .from('paid_contracts')
        .update(updateData)
        .eq('id', contractId)
        .select()
        .single()

      if (error) throw error

      // Salvar também na tabela de posts do Instagram
      const { error: postError } = await supabase
        .from('instagram_posts')
        .insert([{
          contract_id: contractId,
          person_number: personNumber,
          post_url: postUrl,
          hashtag: personNumber === 1 ? data.hashtag_1 : data.hashtag_2,
          post_date: new Date().toISOString().split('T')[0],
          verified: true
        }])

      if (postError) throw postError

      return { success: true, data }
    } catch (err) {
      return { 
        success: false, 
        error: err instanceof Error ? err.message : 'Erro ao verificar post' 
      }
    }
  }

  const getContractStatusColor = (status: 'Pendente' | 'Ativo' | 'Completo' | 'Cancelado') => {
    switch (status) {
      case 'Completo':
        return 'text-green-600 bg-green-100'
      case 'Ativo':
        return 'text-blue-600 bg-blue-100'
      case 'Pendente':
        return 'text-yellow-600 bg-yellow-100'
      case 'Cancelado':
        return 'text-red-600 bg-red-100'
      default:
        return 'text-gray-600 bg-gray-100'
    }
  }

  const getContractStatusIcon = (status: 'Pendente' | 'Ativo' | 'Completo' | 'Cancelado') => {
    switch (status) {
      case 'Completo':
        return '✅'
      case 'Ativo':
        return '🔄'
      case 'Pendente':
        return '⏳'
      case 'Cancelado':
        return '❌'
      default:
        return '❓'
    }
  }

  const getContractsByStatus = (status: 'Pendente' | 'Ativo' | 'Completo' | 'Cancelado') => {
    return contracts.filter(contract => contract.contract_status === status)
  }

  const getContractsNeedingVerification = () => {
    return contracts.filter(contract => 
      contract.contract_status === 'Ativo' && 
      (!contract.post_verified_1 || !contract.post_verified_2)
    )
  }

  const getContractsByMember = (memberId: string) => {
    return contracts.filter(contract => contract.member_id === memberId)
  }

  const canAddMoreContracts = (memberId: string) => {
    const memberContracts = getContractsByMember(memberId)
    return memberContracts.length < 15
  }

  useEffect(() => {
    fetchContracts()
    fetchContractStats()
  }, [fetchContracts, fetchContractStats])

  return {
    contracts,
    contractStats,
    loading,
    error,
    addContract,
    updateContractStatus,
    verifyInstagramPost,
    getContractStatusColor,
    getContractStatusIcon,
    getContractsByStatus,
    getContractsNeedingVerification,
    getContractsByMember,
    canAddMoreContracts,
    refetch: fetchContracts
  }
}
