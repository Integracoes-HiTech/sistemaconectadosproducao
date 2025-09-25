// hooks/usePaidContracts.ts
import { useState, useEffect, useCallback } from 'react'

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

      // Funcionalidade de contratos pagos ainda não implementada no backend
      setContracts([])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erro ao carregar contratos')
    } finally {
      setLoading(false)
    }
  }, [memberId])

  const fetchContractStats = useCallback(async () => {
    try {
      // Funcionalidade de contratos pagos ainda não implementada no backend
      const stats: ContractStats = {
        total_contracts: 0,
        completed_contracts: 0,
        pending_contracts: 0,
        active_contracts: 0,
        cancelled_contracts: 0,
        verified_posts: 0,
        pending_verification: 0
      }

      setContractStats(stats)
    } catch (err) {
      // Erro silencioso
    }
  }, [])

  const addContract = async (contractData: Omit<PaidContract, 'id' | 'created_at' | 'updated_at' | 'member_data'>) => {
    try {
      // Funcionalidade de contratos pagos ainda não implementada no backend
      throw new Error('A fase de contratos pagos ainda não está ativa. Funcionalidade em desenvolvimento.')

      // Gerar hashtags únicas
      const hashtag1 = `#Conectados${contractData.member_id.slice(-6)}${contractData.couple_instagram_1.slice(-3)}`
      const hashtag2 = `#Conectados${contractData.member_id.slice(-6)}${contractData.couple_instagram_2.slice(-3)}`

      // Funcionalidade de contratos pagos ainda não implementada no backend
      throw new Error('Funcionalidade de contratos pagos ainda não implementada')
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

      // Funcionalidade de contratos pagos ainda não implementada no backend
      throw new Error('Funcionalidade de contratos pagos ainda não implementada')
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

      // Funcionalidade de contratos pagos ainda não implementada no backend
      throw new Error('Funcionalidade de contratos pagos ainda não implementada')
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
