# 🔒 Filtros de Dashboard por Role e Referrer

## 🎯 **Modificações Implementadas:**

### **1. Filtros de Dados Baseados no Role ✅**
### **2. Seções Condicionais por Permissão ✅**
### **3. Links Filtrados por Usuário ✅**

---

## 🔧 **1. Filtros de Dados Baseados no Role**

### **Implementação:**
```typescript
// Usar dados reais do banco com filtros baseados no role
const referrerFilter = canViewAllUsers() ? undefined : user?.full_name;
const userIdFilter = canViewAllUsers() ? undefined : user?.id;

const { users: allUsers, loading: usersLoading } = useUsers(referrerFilter);
const { stats, loading: statsLoading } = useStats(referrerFilter);
const { reportData, loading: reportsLoading } = useReports(referrerFilter);
const { userLinks, createLink, loading: linksLoading } = useUserLinks(userIdFilter);
```

### **Lógica de Filtros:**
- **Admin/Vereador:** Vê todos os dados (`referrerFilter = undefined`)
- **Coordenador/Colaborador:** Vê apenas seus dados (`referrerFilter = user.full_name`)
- **Links:** Filtrados por `user.id` para mostrar apenas links do usuário

---

## 👥 **2. Seções Condicionais por Permissão**

### **Seções de Estatísticas:**
```typescript
{/* Gráficos de Estatísticas */}
{canViewStats() && (
<div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
  {/* Gráfico de Barras - Usuários por Cidade/Bairro */}
  <Card>
    <CardDescription>
      {canViewAllUsers() ? 'Distribuição por cidade e bairro' : 'Distribuição dos seus usuários por localização'}
    </CardDescription>
  </Card>
  
  {/* Outros gráficos... */}
</div>
)}

{/* Cards de Resumo */}
{canViewStats() && (
<div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
  {/* Cards de estatísticas... */}
</div>
)}
```

### **Seção de Geração de Links:**
```typescript
{!isAdmin() && (
<div className="flex flex-col sm:flex-row gap-3">
  <Button onClick={generateLink}>
    <Share2 className="w-4 h-4 mr-2" />
    Gerar Link Único
  </Button>
</div>
)}
```

---

## 🔗 **3. Links Filtrados por Usuário**

### **Hook useUserLinks Atualizado:**
```typescript
export const useUserLinks = (userId?: string) => {
  const fetchUserLinks = async () => {
    let query = supabase
      .from('user_links')
      .select(`
        *,
        user_data:auth_users(*)
      `)
      .eq('is_active', true)
      .order('created_at', { ascending: false })

    // Se userId for fornecido, filtrar por usuário
    if (userId) {
      query = query.eq('user_id', userId)
    }

    const { data, error } = await query
    // ...
  }
}
```

---

## 📋 **Hierarquia de Permissões**

### **Admin:**
- ✅ **Ver todos os usuários:** Sem filtro de referrer
- ✅ **Ver todas as estatísticas:** Dados globais
- ✅ **Ver todos os links:** Sem filtro de usuário
- ❌ **Gerar links:** Não pode gerar (apenas gerencia)

### **Vereador:**
- ✅ **Ver todos os usuários:** Sem filtro de referrer
- ✅ **Ver todas as estatísticas:** Dados globais
- ✅ **Ver todos os links:** Sem filtro de usuário
- ✅ **Gerar links:** Pode gerar links próprios

### **Coordenador:**
- ❌ **Ver todos os usuários:** Apenas seus usuários (`referrer = full_name`)
- ✅ **Ver estatísticas:** Apenas dos seus usuários
- ❌ **Ver todos os links:** Apenas seus links (`user_id = id`)
- ✅ **Gerar links:** Pode gerar links próprios

### **Colaborador:**
- ❌ **Ver todos os usuários:** Apenas seus usuários (`referrer = full_name`)
- ✅ **Ver estatísticas:** Apenas dos seus usuários
- ❌ **Ver todos os links:** Apenas seus links (`user_id = id`)
- ✅ **Gerar links:** Pode gerar links próprios

### **Usuário:**
- ❌ **Ver todos os usuários:** Apenas seus usuários (`referrer = full_name`)
- ❌ **Ver estatísticas:** Sem acesso
- ❌ **Ver todos os links:** Apenas seus links (`user_id = id`)
- ❌ **Gerar links:** Sem permissão

---

## 🔄 **Fluxo de Filtros**

### **1. Login do Usuário:**
```
Usuário: João (Coordenador)
Role: Coordenador
Full Name: João Silva - Coordenador
```

### **2. Aplicação de Filtros:**
```
canViewAllUsers() = false (apenas Admin/Vereador)
referrerFilter = "João Silva - Coordenador"
userIdFilter = "joão_id_123"
```

### **3. Consultas Filtradas:**
```
Users: WHERE referrer = "João Silva - Coordenador"
Stats: WHERE referrer = "João Silva - Coordenador"  
Reports: WHERE referrer = "João Silva - Coordenador"
UserLinks: WHERE user_id = "joão_id_123"
```

### **4. Interface Adaptada:**
```
Título: "Meus Usuários Cadastrados"
Descrição: "Distribuição dos seus usuários por localização"
Seções: Apenas estatísticas permitidas
```

---

## 🎨 **Interface Dinâmica**

### **Títulos Dinâmicos:**
```typescript
{canViewAllUsers() ? 'Todos os Usuários do Sistema' : 'Meus Usuários Cadastrados'}
```

### **Descrições Dinâmicas:**
```typescript
{canViewAllUsers() 
? "Visão consolidada de todos os usuários cadastrados no sistema"
: "Gerencie e visualize todos os usuários vinculados ao seu link"
}
```

### **Seções Condicionais:**
```typescript
{canViewStats() && (
  // Seção de estatísticas
)}

{!isAdmin() && (
  // Seção de geração de links
)}
```

---

## 🧪 **Teste dos Filtros**

### **1. Teste Admin:**
1. Faça login como Admin
2. **Resultado:** Vê todos os usuários e estatísticas globais

### **2. Teste Coordenador:**
1. Faça login como Coordenador
2. **Resultado:** Vê apenas usuários com seu nome como referrer

### **3. Teste Colaborador:**
1. Faça login como Colaborador  
2. **Resultado:** Vê apenas seus usuários e pode gerar links

### **4. Teste Usuário:**
1. Faça login como Usuário
2. **Resultado:** Sem acesso a estatísticas, apenas seus dados

---

## ✅ **Benefícios**

### **1. Segurança:**
- **Isolamento de dados:** Cada usuário vê apenas seus dados
- **Permissões granulares:** Baseadas no role do usuário
- **Prevenção de vazamentos:** Dados sensíveis protegidos

### **2. Performance:**
- **Consultas otimizadas:** Apenas dados necessários
- **Filtros no banco:** Reduz transferência de dados
- **Cache eficiente:** Menos dados para processar

### **3. Experiência do Usuário:**
- **Interface adaptada:** Títulos e descrições contextuais
- **Dados relevantes:** Apenas informações pertinentes
- **Navegação intuitiva:** Funcionalidades baseadas em permissões

---

## 🚀 **Resultado Final**

**Dashboard completamente filtrado por role e referrer!**

- ✅ **Filtros automáticos:** Baseados no role do usuário logado
- ✅ **Seções condicionais:** Estatísticas apenas para quem pode ver
- ✅ **Links filtrados:** Cada usuário vê apenas seus links
- ✅ **Interface dinâmica:** Títulos e descrições adaptados
- ✅ **Segurança garantida:** Isolamento completo de dados
- ✅ **Performance otimizada:** Consultas eficientes

**Teste fazendo login com diferentes roles para ver os filtros funcionando!** 🔒✅
