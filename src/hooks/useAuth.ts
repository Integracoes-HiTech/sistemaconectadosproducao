// hooks/useAuth.ts
import { useState, useEffect, useCallback } from 'react'
import { loginUser, validateSession, AuthUser } from '@/lib/database'
import { useToast } from '@/hooks/use-toast'

export const useAuth = () => {
  const [user, setUser] = useState<AuthUser | null>(null)
  const [loading, setLoading] = useState(true)
  const { toast } = useToast()

  const validateUserSession = useCallback(async () => {
    try {
      setLoading(true)
      
      const savedUser = localStorage.getItem('loggedUser')
      if (savedUser) {
        const userData = JSON.parse(savedUser)
        
        // Validar sessão com a API
        const result = await validateSession(userData.id)
        
        if (result.success) {
          setUser(result.user)
        } else {
          localStorage.removeItem('loggedUser')
        }
      }
    } catch (error) {
      localStorage.removeItem('loggedUser')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    validateUserSession()
  }, [validateUserSession])

  const login = async (username: string, password: string) => {
    try {
      setLoading(true)

      // Fazer login via API
      const result = await loginUser(username, password)

      if (!result.success) {
        throw new Error(result.error || 'Erro no login')
      }

      setUser(result.user)
      localStorage.setItem('loggedUser', JSON.stringify(result.user))
        
      toast({
        title: "Login realizado com sucesso!",
        description: result.message || `Bem-vindo, ${result.user.name}!`,
      })

      return { success: true, user: result.user }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erro no login'
      toast({
        title: "Erro no login",
        description: errorMessage,
        variant: "destructive",
      })
      return { success: false, error: errorMessage }
    } finally {
      setLoading(false)
    }
  }

  const logout = () => {
    setUser(null)
    localStorage.removeItem('loggedUser')
    toast({
      title: "Logout realizado",
      description: "Você foi desconectado com sucesso.",
    })
  }

  const isAuthenticated = () => {
    return !!user
  }

  const isAdmin = () => {
    return user?.role === 'Admin' || user?.role === 'Administrador'
  }

  const isFullAdmin = () => {
    return user?.role === 'Administrador'
  }

  const canModifyLinkTypes = () => {
    return isFullAdmin() && !isFelipeAdmin()
  }

  const canViewAllUsers = () => {
    return isAdmin() || isFelipeAdmin()
  }

  const canViewOwnUsers = () => {
    return !!user
  }

  const canViewStats = () => {
    return isAdmin() || isFelipeAdmin()
  }

  const canGenerateLinks = () => {
    return isAdmin() || isMembro() || isFelipeAdmin()
  }

  const isMembro = () => {
    return user?.role === 'Membro'
  }

  const isAmigo = () => {
    return user?.role === 'Amigo'
  }

  const isConvidado = () => {
    return user?.role === 'Convidado'
  }

  const isFelipeAdmin = () => {
    return user?.username === 'felipe' || user?.role === 'Felipe Admin'
  }

  const canDeleteUsers = () => {
    return isAdmin() && !isFelipeAdmin()
  }

  const canExportReports = () => {
    return isAdmin() || isFelipeAdmin()
  }

  return {
    user,
    loading,
    login,
    logout,
    isAuthenticated,
    isAdmin,
    isFullAdmin,
    isFelipeAdmin,
    canModifyLinkTypes,
    canViewAllUsers,
    canViewOwnUsers,
    canViewStats,
    canGenerateLinks,
    canDeleteUsers,
    canExportReports,
    isMembro,
    isAmigo,
    isConvidado
  }
}