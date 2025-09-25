# 📊 Tabela Friends Separada - Implementada

## ✅ **Implementação Concluída**

Criei uma estrutura separada para os amigos, da mesma forma que temos uma tabela `members` e uma seção de ranking dos membros. Agora temos uma tabela `friends` e uma seção de ranking dos amigos.

## 🗄️ **Nova Estrutura do Banco**

### **1. Tabela `friends` (Amigos)**
```sql
CREATE TABLE IF NOT EXISTS friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  
  -- Dados do casal amigo
  couple_name_1 VARCHAR(255) NOT NULL,
  couple_name_2 VARCHAR(255) NOT NULL,
  couple_phone_1 VARCHAR(20) NOT NULL,
  couple_phone_2 VARCHAR(20) NOT NULL,
  couple_instagram_1 VARCHAR(255) NOT NULL,
  couple_instagram_2 VARCHAR(255) NOT NULL,
  
  -- Dados adicionais
  couple_city VARCHAR(255),
  couple_sector VARCHAR(255),
  
  -- Status do amigo
  friend_status VARCHAR(20) DEFAULT 'Ativo' CHECK (friend_status IN ('Ativo', 'Inativo', 'Suspenso')),
  
  -- Ranking e performance
  users_cadastrados INTEGER DEFAULT 0,
  ranking_position INTEGER,
  ranking_status VARCHAR(10) DEFAULT 'Vermelho' CHECK (ranking_status IN ('Verde', 'Amarelo', 'Vermelho')),
  is_top_performer BOOLEAN DEFAULT false,
  
  -- Fiscalização
  instagram_post_1 VARCHAR(255),
  instagram_post_2 VARCHAR(255),
  hashtag_1 VARCHAR(100),
  hashtag_2 VARCHAR(100),
  post_verified_1 BOOLEAN DEFAULT false,
  post_verified_2 BOOLEAN DEFAULT false,
  
  -- Datas
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  last_activity_date DATE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **2. Tabela `friend_referrals` (Usuários Cadastrados pelos Amigos)**
```sql
CREATE TABLE IF NOT EXISTS friend_referrals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  friend_id UUID NOT NULL REFERENCES friends(id) ON DELETE CASCADE,
  
  -- Dados do usuário cadastrado pelo amigo
  referred_user_name VARCHAR(255) NOT NULL,
  referred_user_phone VARCHAR(20) NOT NULL,
  referred_user_instagram VARCHAR(255) NOT NULL,
  referred_user_city VARCHAR(255) NOT NULL,
  referred_user_sector VARCHAR(255) NOT NULL,
  
  -- Dados do cadastro
  referral_date DATE NOT NULL DEFAULT CURRENT_DATE,
  referral_status VARCHAR(20) DEFAULT 'Ativo' CHECK (referral_status IN ('Ativo', 'Inativo', 'Cancelado')),
  
  -- Fiscalização
  instagram_post VARCHAR(255),
  hashtag VARCHAR(100),
  post_verified BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### **3. View `v_friends_ranking` (Ranking dos Amigos)**
```sql
CREATE OR REPLACE VIEW v_friends_ranking AS
SELECT 
  f.id as friend_id,
  f.member_id,
  m.name as member_name,
  m.instagram as member_instagram,
  f.couple_name_1,
  f.couple_name_2,
  f.couple_phone_1,
  f.couple_phone_2,
  f.couple_instagram_1,
  f.couple_instagram_2,
  f.couple_city,
  f.couple_sector,
  f.friend_status,
  f.users_cadastrados,
  f.ranking_position,
  f.ranking_status,
  f.is_top_performer,
  f.registration_date,
  f.last_activity_date,
  COUNT(fr.id) as total_referrals,
  COUNT(CASE WHEN fr.referral_status = 'Ativo' THEN 1 END) as active_referrals,
  COUNT(CASE WHEN fr.referral_status = 'Inativo' THEN 1 END) as inactive_referrals,
  COUNT(CASE WHEN fr.post_verified = true THEN 1 END) as verified_posts,
  RANK() OVER (ORDER BY f.users_cadastrados DESC, f.registration_date ASC) as global_rank
FROM friends f
LEFT JOIN members m ON f.member_id = m.id
LEFT JOIN friend_referrals fr ON f.id = fr.friend_id
WHERE f.friend_status = 'Ativo'
GROUP BY f.id, f.member_id, m.name, m.instagram, f.couple_name_1, f.couple_name_2,
         f.couple_phone_1, f.couple_phone_2, f.couple_instagram_1, f.couple_instagram_2,
         f.couple_city, f.couple_sector, f.friend_status, f.users_cadastrados, f.ranking_position,
         f.ranking_status, f.is_top_performer, f.registration_date, f.last_activity_date
ORDER BY global_rank;
```

## 🔧 **Hook Atualizado: `useFriendsRanking`**

### **Interface `FriendRanking` Atualizada:**
```typescript
export interface FriendRanking {
  id: string;
  member_id: string;
  couple_name_1: string;
  couple_name_2: string;
  couple_phone_1: string;
  couple_phone_2: string;
  couple_instagram_1: string;
  couple_instagram_2: string;
  couple_city: string;
  couple_sector: string;
  friend_status: string;
  users_cadastrados: number;
  ranking_position: number;
  ranking_status: 'Verde' | 'Amarelo' | 'Vermelho';
  is_top_performer: boolean;
  member_name: string;
  member_instagram: string;
  registration_date: string;
  last_activity_date: string;
  total_referrals: number;
  active_referrals: number;
  inactive_referrals: number;
  verified_posts: number;
  global_rank: number;
  created_at: string;
  updated_at: string;
}
```

### **Busca da View `v_friends_ranking`:**
```typescript
const fetchFriendsRanking = async () => {
  try {
    setLoading(true);
    setError(null);

    console.log('🔍 Buscando ranking dos amigos...');

    const { data, error: fetchError } = await supabase
      .from('v_friends_ranking')
      .select('*')
      .order('global_rank', { ascending: true });

    if (fetchError) {
      console.error('❌ Erro ao buscar ranking dos amigos:', fetchError);
      setError(`Erro ao buscar dados: ${fetchError.message}`);
      return;
    }

    console.log('✅ Ranking dos amigos carregado:', data);
    setFriends(data || []);
  } catch (err) {
    console.error('❌ Erro geral ao buscar ranking dos amigos:', err);
    setError('Erro inesperado ao carregar dados');
  } finally {
    setLoading(false);
  }
};
```

### **Funções Atualizadas:**

**1. `addFriendReferral`:**
```typescript
const addFriendReferral = async (friendId: string, referralData: {
  name: string;
  phone: string;
  instagram: string;
  city: string;
  sector: string;
  instagram_post?: string;
  hashtag?: string;
}) => {
  const { data, error } = await supabase
    .from('friend_referrals')
    .insert([{
      friend_id: friendId,  // ✅ Campo correto
      referred_user_name: referralData.name,
      referred_user_phone: referralData.phone,
      referred_user_instagram: referralData.instagram,
      referred_user_city: referralData.city,
      referred_user_sector: referralData.sector,
      instagram_post: referralData.instagram_post,
      hashtag: referralData.hashtag,
      post_verified: false
    }])
    .select();
};
```

**2. `getFriendsByMember`:**
```typescript
const getFriendsByMember = async (memberId: string) => {
  const { data, error } = await supabase
    .from('friends')  // ✅ Tabela correta
    .select(`
      *,
      members!inner(name)
    `)
    .eq('member_id', memberId)
    .eq('friend_status', 'Ativo')  // ✅ Status correto
    .order('created_at', { ascending: false });
};
```

**3. `updateUsersCadastradosCount`:**
```typescript
const updateUsersCadastradosCount = async (friendId: string) => {
  // Contar referências ativas para este amigo
  const { count, error: countError } = await supabase
    .from('friend_referrals')
    .select('*', { count: 'exact', head: true })
    .eq('friend_id', friendId)  // ✅ Campo correto
    .eq('referral_status', 'Ativo');

  // Atualizar contador na tabela friends
  const { error: updateError } = await supabase
    .from('friends')  // ✅ Tabela correta
    .update({ 
      users_cadastrados: count || 0,
      last_activity_date: new Date().toISOString().split('T')[0],
      updated_at: new Date().toISOString()
    })
    .eq('id', friendId);
};
```

## 📊 **Dashboard Atualizado**

### **Campos Corretos na Tabela:**

**1. Posição:**
```typescript
<span className="font-bold text-institutional-blue">
  {friend.global_rank || 'N/A'}º
</span>
```

**2. Casal Amigo:**
```typescript
<span className="font-medium text-institutional-blue">
  {friend.couple_name_1} & {friend.couple_name_2}
</span>
<div className="text-xs text-gray-500">
  {friend.friend_status}  {/* ✅ Status correto */}
</div>
```

**3. Data de Cadastro:**
```typescript
<span className="text-sm">
  {new Date(friend.registration_date).toLocaleDateString('pt-BR')}  {/* ✅ Data correta */}
</span>
```

### **Filtros Atualizados:**
```typescript
const filteredFriends = friends.filter(friend => {
  const matchesSearch = friendsSearchTerm === "" || 
    friend.couple_name_1.toLowerCase().includes(friendsSearchTerm.toLowerCase()) ||
    friend.couple_name_2.toLowerCase().includes(friendsSearchTerm.toLowerCase()) ||
    friend.couple_phone_1.includes(friendsSearchTerm) ||
    friend.couple_instagram_1.toLowerCase().includes(friendsSearchTerm.toLowerCase()) ||
    friend.couple_city?.toLowerCase().includes(friendsSearchTerm.toLowerCase()) ||  // ✅ Campo adicionado
    friend.couple_sector?.toLowerCase().includes(friendsSearchTerm.toLowerCase());   // ✅ Campo adicionado

  const matchesStatus = friendsStatusFilter === "" || friend.ranking_status === friendsStatusFilter;
  
  const matchesMember = friendsMemberFilter === "" || 
    friend.member_name.toLowerCase().includes(friendsMemberFilter.toLowerCase());

  return matchesSearch && matchesStatus && matchesMember;
});
```

## 🔄 **Função de Atualização Automática**

### **Trigger para Ranking:**
```sql
-- Função para atualizar ranking dos amigos
CREATE OR REPLACE FUNCTION update_friends_ranking()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualiza a contagem de users_cadastrados para o amigo
  UPDATE friends
  SET users_cadastrados = (
    SELECT COUNT(*)
    FROM friend_referrals
    WHERE friend_id = NEW.friend_id
    AND referral_status = 'Ativo'
  ),
  last_activity_date = CURRENT_DATE
  WHERE id = NEW.friend_id;

  -- Recalcula o ranking e status para todos os amigos
  WITH ranked_friends AS (
    SELECT
      id,
      users_cadastrados,
      RANK() OVER (ORDER BY users_cadastrados DESC, registration_date ASC) as new_rank,
      CASE
        WHEN users_cadastrados >= 15 THEN 'Verde'
        WHEN users_cadastrados >= 5 THEN 'Amarelo'
        ELSE 'Vermelho'
      END as new_status,
      (users_cadastrados >= 15) as new_top_performer
    FROM friends
    WHERE friend_status = 'Ativo'
  )
  UPDATE friends f
  SET
    ranking_position = rf.new_rank,
    ranking_status = rf.new_status,
    is_top_performer = rf.new_top_performer,
    updated_at = NOW()
  FROM ranked_friends rf
  WHERE f.id = rf.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers para executar a função
CREATE OR REPLACE TRIGGER trg_update_friends_ranking
AFTER INSERT ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();

CREATE OR REPLACE TRIGGER trg_update_friends_ranking_update
AFTER UPDATE ON friend_referrals
FOR EACH ROW EXECUTE FUNCTION update_friends_ranking();
```

## 🎯 **Estrutura Separada Implementada**

### **Analogia com Members:**
- **`members`** ↔ **`friends`**: Tabelas principais
- **`members` ranking** ↔ **`friends` ranking**: Seções de ranking
- **`members` stats** ↔ **`friends` stats**: Estatísticas
- **`members` filters** ↔ **`friends` filters**: Filtros

### **Benefícios da Separação:**
- ✅ **Estrutura clara**: Cada entidade tem sua própria tabela
- ✅ **Manutenção fácil**: Mudanças em uma não afetam a outra
- ✅ **Performance**: Queries mais específicas e otimizadas
- ✅ **Escalabilidade**: Fácil adicionar novos campos específicos
- ✅ **Consistência**: Padrão uniforme no sistema

## 🚀 **Próximos Passos**

### **Para Funcionar Completamente:**

**1. Executar Script SQL:**
```sql
-- Executar no Supabase SQL Editor
-- Arquivo: docs/CRIAR_TABELA_FRIENDS.sql
```

**2. Criar Dados de Teste:**
- Cadastrar alguns amigos na tabela `friends`
- Adicionar referências na tabela `friend_referrals`
- Testar filtros e ranking

**3. Verificar Estrutura:**
- Confirmar que as tabelas foram criadas
- Verificar se os triggers estão funcionando
- Testar a view `v_friends_ranking`

## 📋 **Arquivos Criados/Modificados**

- **`docs/CRIAR_TABELA_FRIENDS.sql`** - Script SQL para criar estrutura
- **`src/hooks/useFriendsRanking.ts`** - Hook atualizado para usar tabela friends
- **`src/pages/dashboard.tsx`** - Dashboard atualizado para usar dados corretos

## 🎉 **Resultado Final**

**Agora temos uma estrutura separada e consistente para os amigos!**

### **Funcionalidades Implementadas:**
- ✅ **Tabela `friends`**: Separada da `paid_contracts`
- ✅ **Tabela `friend_referrals`**: Para usuários cadastrados pelos amigos
- ✅ **View `v_friends_ranking`**: Para ranking dos amigos
- ✅ **Hook atualizado**: Usando a nova estrutura
- ✅ **Dashboard atualizado**: Campos corretos da nova tabela
- ✅ **Triggers automáticos**: Atualização de ranking em tempo real
- ✅ **Filtros expandidos**: Incluindo cidade e setor dos amigos

### **Estrutura Consistente:**
- **Members**: `members` + ranking de membros
- **Friends**: `friends` + ranking de amigos
- **Padrão uniforme**: Mesma estrutura, diferentes entidades

**A estrutura está pronta e aguardando apenas a execução do script SQL no banco de dados!** 📊
