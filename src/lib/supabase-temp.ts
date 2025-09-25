// lib/supabase-temp.ts - Arquivo temporário para substituir Supabase

// Tipos locais para evitar problemas de importação
export interface User {
  id: string
  name: string
  phone: string
  instagram: string
  city: string
  sector: string
  referrer: string
  registration_date: string
  status: 'Ativo' | 'Inativo'
  created_at: string
  updated_at: string
}

export interface AuthUser {
  id: string
  username: string
  name: string
  role: string
  full_name: string
  display_name?: string
  instagram?: string
  phone?: string
  is_active?: boolean
  last_login?: string
  created_at: string
  updated_at: string
}

export interface Stats {
  total_users: number
  active_users: number
  recent_registrations: number
  engagement_rate: number
  today_registrations: number
}

// Função temporária para simular supabase.from()
export const supabase = {
  from: (table: string) => ({
    select: (columns: string) => ({
      is: (column: string, value: any) => ({
        eq: (col: string, val: any) => ({
          order: (orderBy: string) => ({
            limit: (limit: number) => ({
              then: (callback: (result: any) => void) => {
                // Implementação temporária - retorna dados vazios
                callback({ data: [], error: null })
              }
            })
          })
        })
      })
    }),
    insert: (data: any) => ({
      then: (callback: (result: any) => void) => {
        callback({ data: null, error: null })
      }
    }),
    update: (data: any) => ({
      eq: (column: string, value: any) => ({
        then: (callback: (result: any) => void) => {
          callback({ data: null, error: null })
        }
      })
    }),
    delete: () => ({
      eq: (column: string, value: any) => ({
        then: (callback: (result: any) => void) => {
          callback({ data: null, error: null })
        }
      })
    }),
    rpc: (functionName: string) => ({
      then: (callback: (result: any) => void) => {
        callback({ data: null, error: null })
      }
    })
  })
}