# 🔧 Atualizar Hooks para Tabelas Separadas

## 📋 **Arquivos que precisam ser atualizados:**

### **1. Hook `useMembers` (`src/hooks/useMembers.ts`)**
- Alterar para usar tabela `members_clean`
- Remover lógica de amigos (is_friend)
- Focar apenas em membros

### **2. Hook `useFriendsRanking` (`src/hooks/useFriendsRanking.ts`)**
- Alterar para usar tabela `friends_clean`
- Usar view `v_friends_ranking`
- Separar completamente da lógica de membros

### **3. Dashboard (`src/pages/dashboard.tsx`)**
- Separar seções de membros e amigos
- Usar hooks específicos para cada tipo
- Atualizar contadores para usar views corretas

## 🔄 **Mudanças necessárias:**

### **Hook useMembers:**
```typescript
// Antes: tabela 'members' com campo 'is_friend'
const { data, error } = await supabase
  .from('members')
  .select('*')
  .eq('is_friend', false)

// Depois: tabela 'members_clean' (apenas membros)
const { data, error } = await supabase
  .from('members_clean')
  .select('*')
```

### **Hook useFriendsRanking:**
```typescript
// Antes: tabela 'members' com campo 'is_friend'
const { data, error } = await supabase
  .from('members')
  .select('*')
  .eq('is_friend', true)

// Depois: view 'v_friends_ranking' (apenas amigos)
const { data, error } = await supabase
  .from('v_friends_ranking')
  .select('*')
```

### **Dashboard:**
```typescript
// Antes: memberStats misturado
const { memberStats } = useMembers()

// Depois: stats separadas
const { memberStats } = useMembers() // Apenas membros
const { friendsStats } = useFriendsRanking() // Apenas amigos
```

## 📊 **Views disponíveis:**

1. **`v_system_stats`** - Estatísticas de membros
2. **`v_friends_stats`** - Estatísticas de amigos  
3. **`v_friends_ranking`** - Ranking de amigos
4. **`v_members_ranking`** - Ranking de membros

## ✅ **Benefícios da separação:**

- **Contadores corretos** - Sem mistura de dados
- **Lógica clara** - Cada tipo tem sua própria tabela
- **Performance melhor** - Queries mais específicas
- **Manutenção fácil** - Código mais organizado
- **Escalabilidade** - Fácil adicionar novos campos específicos
