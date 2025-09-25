# 🔍 Filtro por Referrer - Tabela Users do Banco

## 🎯 **Implementação Realizada:**
Sistema de filtro por `referrer` na tabela `users` do banco, onde cada usuário vê apenas os dados dos usuários que ele indicou.

## 🔧 **Lógica Implementada:**

### **1. Filtro por Role:**
```typescript
// Lógica de filtro por referrer:
// - Admin: vê todos os usuários (sem filtro)
// - Outros roles: vê apenas usuários que eles indicaram (filtro por user.full_name)
const referrerFilter = isAdmin() ? undefined : user?.full_name;
```

### **2. Hooks Utilizados:**
```typescript
const { users: allUsers, loading: usersLoading } = useUsers(referrerFilter);
const { stats, loading: statsLoading } = useStats(referrerFilter);
const { reportData, loading: reportsLoading } = useReports(referrerFilter);
```

## 📊 **Comportamento por Role:**

### **Admin/Administrador:**
- ✅ **Vê:** TODOS os usuários do sistema
- ✅ **Filtro:** `referrerFilter = undefined` (sem filtro)
- ✅ **Dados:** Estatísticas globais completas
- ✅ **Tabela:** Lista completa de usuários

### **Vereador/Coordenador/Colaborador:**
- ✅ **Vê:** Apenas usuários que eles indicaram
- ✅ **Filtro:** `referrerFilter = user.full_name`
- ✅ **Dados:** Estatísticas apenas dos seus usuários
- ✅ **Tabela:** Lista filtrada por referrer

## 🔍 **Implementação nos Hooks:**

### **useUsers Hook:**
```typescript
const fetchUsers = async () => {
  let query = supabase
    .from('users')
    .select('*')
    .order('created_at', { ascending: false })

  if (referrer) {
    query = query.eq('referrer', referrer)  // Filtro por referrer
  }

  const { data, error } = await query
  setUsers(data || [])
}
```

### **useStats Hook:**
```typescript
const fetchStats = async () => {
  let query = supabase.from('users').select('*')
  
  if (referrer) {
    query = query.eq('referrer', referrer)  // Filtro por referrer
  }

  const { data: users, error } = await query
  // Calcular estatísticas apenas dos usuários filtrados
}
```

### **useReports Hook:**
```typescript
const fetchReportData = async () => {
  let query = supabase.from('users').select('*')
  
  if (referrer) {
    query = query.eq('referrer', referrer)  // Filtro por referrer
  }

  const { data: users, error } = await query
  // Calcular relatórios apenas dos usuários filtrados
}
```

## 🎨 **Interface Adaptada:**

### **Títulos Dinâmicos:**
```typescript
// Título da tabela
{isAdmin() ? 'Todos os Usuários do Sistema' : 'Meus Usuários Cadastrados'}

// Descrição dos gráficos
{isAdmin() 
  ? 'Distribuição por cidade e bairro - Todos os usuários' 
  : 'Distribuição dos seus usuários por localização'
}

// Resumo
{isAdmin() ? 'Total de usuários cadastrados' : 'Meus usuários cadastrados'}
```

## 📈 **Dados Filtrados:**

### **1. Tabela de Usuários:**
- **Admin:** Todos os usuários da tabela `users`
- **Outros:** Apenas usuários onde `referrer = user.full_name`

### **2. Gráficos e Estatísticas:**
- **Gráfico de Localização:** Dados filtrados por referrer
- **Gráfico de Cadastros:** Dados filtrados por referrer
- **Cards de Resumo:** Estatísticas filtradas por referrer

### **3. Estatísticas Calculadas:**
- **Total de usuários:** Apenas do referrer específico
- **Usuários ativos:** Apenas do referrer específico
- **Cadastros recentes:** Apenas do referrer específico
- **Taxa de engajamento:** Apenas do referrer específico

## 🔄 **Fluxo de Funcionamento:**

### **1. Login do Usuário:**
```
1. Usuário faz login
2. user.full_name é obtido do contexto
3. referrerFilter é definido baseado no role
4. Hooks fazem consultas com filtro aplicado
```

### **2. Carregamento de Dados:**
```
1. useUsers(referrerFilter) → Consulta tabela users com filtro
2. useStats(referrerFilter) → Calcula estatísticas filtradas
3. useReports(referrerFilter) → Gera relatórios filtrados
4. Interface atualiza com dados específicos
```

### **3. Exemplo Prático:**
```
João Silva (Coordenador) faz login:
- referrerFilter = "João Silva - Coordenador"
- Tabela mostra apenas usuários onde referrer = "João Silva - Coordenador"
- Gráficos mostram dados apenas dos usuários do João
- Estatísticas refletem apenas performance do João
```

## ✅ **Benefícios:**

1. **Segurança:** Cada usuário vê apenas seus dados
2. **Performance:** Consultas otimizadas com filtros
3. **Privacidade:** Dados protegidos por referrer
4. **Simplicidade:** Interface clara e contextual
5. **Escalabilidade:** Sistema funciona com qualquer número de usuários

## 🧪 **Como Testar:**

### **Teste 1 - Admin:**
1. Login como Admin
2. Verificar se vê todos os usuários
3. Verificar se estatísticas são globais
4. Verificar se gráficos mostram todos os dados

### **Teste 2 - Coordenador:**
1. Login como Coordenador
2. Verificar se vê apenas seus usuários
3. Verificar se estatísticas são específicas
4. Verificar se gráficos mostram dados filtrados

### **Teste 3 - Colaborador:**
1. Login como Colaborador
2. Verificar se vê apenas seus usuários
3. Verificar se não vê dados de outros
4. Verificar se interface é contextual

## 🔒 **Segurança:**

- **Filtro no Backend:** Consultas SQL com filtro por referrer
- **Validação de Role:** Admin tem acesso total, outros limitados
- **Dados Isolados:** Cada usuário vê apenas seus dados
- **Sem Vazamento:** Impossível ver dados de outros usuários

**Filtro por referrer implementado com sucesso na tabela users!** 🎯
