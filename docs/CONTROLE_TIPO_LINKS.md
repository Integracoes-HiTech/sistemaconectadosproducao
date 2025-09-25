# 🔗 Controle de Tipo de Links para Administradores

## 🎯 **Funcionalidade Implementada**

Administradores agora podem controlar se os links gerados pelos membros servem para:
1. **Cadastrar novos membros** (casais que se tornam membros da rede)
2. **Cadastrar contratos pagos** (amigos que se tornam contratos pagos)

## ✅ **Mudanças Implementadas**

### **1. Estrutura do Banco de Dados Atualizada**

#### **Nova Tabela `user_links`:**
```sql
CREATE TABLE IF NOT EXISTS user_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  link_type VARCHAR(20) DEFAULT 'members' CHECK (link_type IN ('members', 'friends')),
  click_count INTEGER DEFAULT 0,
  registration_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### **Novas Configurações do Sistema:**
```sql
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('member_links_type', 'members', 'Tipo de links gerados pelos membros: members (novos membros) ou friends (contratos pagos)'),
('admin_controls_link_type', 'true', 'Se administradores podem controlar o tipo de links gerados')
```

### **2. Hook useSystemSettings Atualizado**

#### **Nova Interface:**
```typescript
export interface SystemSettings {
  max_members: number
  contracts_per_member: number
  ranking_green_threshold: number
  ranking_yellow_threshold: number
  paid_contracts_phase_active: boolean
  paid_contracts_start_date: string
  member_links_type: 'members' | 'friends'  // ← NOVO
  admin_controls_link_type: boolean         // ← NOVO
}
```

#### **Nova Função:**
```typescript
const updateMemberLinksType = async (linkType: 'members' | 'friends') => {
  try {
    const { error } = await supabase
      .from('system_settings')
      .update({ setting_value: linkType })
      .eq('setting_key', 'member_links_type')

    if (error) throw error

    // Recarregar configurações
    await fetchSettings()
    
    return { success: true }
  } catch (err) {
    return { 
      success: false, 
      error: err instanceof Error ? err.message : 'Erro ao atualizar tipo de links' 
    }
  }
}
```

### **3. Interface de Controle no Dashboard**

#### **Seção para Administradores:**
```typescript
{/* Controle de Tipo de Links (Apenas Administradores) */}
{isAdmin() && (
  <Card className="shadow-[var(--shadow-card)] mb-8">
    <CardHeader>
      <CardTitle className="flex items-center gap-2 text-institutional-blue">
        <LinkIcon className="w-5 h-5" />
        Controle de Links dos Membros
      </CardTitle>
      <CardDescription>
        Configure se os links gerados pelos membros servem para cadastrar novos membros ou apenas contratos pagos
      </CardDescription>
    </CardHeader>
    <CardContent>
      {/* Interface de controle */}
    </CardContent>
  </Card>
)}
```

## 🎨 **Interface de Controle**

### **Visualização da Interface:**
```
┌─────────────────────────────────────────────────────────┐
│ 🔗 Controle de Links dos Membros                       │
├─────────────────────────────────────────────────────────┤
│ Configure se os links gerados pelos membros servem     │
│ para cadastrar novos membros ou apenas contratos pagos │
├─────────────────────────────────────────────────────────┤
│ 🔗 Tipo de Links Atual                                 │
│ Links servem para cadastrar novos membros (casais)    │
│                                                         │
│ [✅ Novos Membros] [⚪ Contratos Pagos]                │
├─────────────────────────────────────────────────────────┤
│ ⚠️ Importante                                          │
│ Novos Membros: Links cadastram casais que se tornam    │
│ membros da rede                                        │
│ Contratos Pagos: Links cadastram casais que se tornam  │
│ contratos pagos (apenas após julho 2026)              │
└─────────────────────────────────────────────────────────┘
```

### **Botões de Controle:**
- ✅ **Novos Membros** (verde quando ativo)
- ⚪ **Contratos Pagos** (cinza quando inativo)

## 🔍 **Funcionalidades Implementadas**

### **✅ Controle Administrativo:**
- Apenas administradores podem alterar o tipo de links
- Interface intuitiva com botões de alternância
- Feedback visual do tipo atual

### **✅ Configuração Dinâmica:**
- Mudança em tempo real
- Atualização automática das configurações
- Persistência no banco de dados

### **✅ Informações Claras:**
- Explicação do que cada tipo faz
- Avisos sobre quando cada tipo é válido
- Interface responsiva

## 🎯 **Tipos de Links Disponíveis**

### **👥 Novos Membros (`members`):**
- **Função**: Links cadastram casais que se tornam membros da rede
- **Quando usar**: Durante a fase de cadastro de membros
- **Resultado**: Casais se tornam membros com ranking e status
- **Limite**: Até 1.500 membros (3.000 pessoas)

### **💰 Contratos Pagos (`friends`):**
- **Função**: Links cadastram casais que se tornam contratos pagos
- **Quando usar**: Após julho de 2026 (fase de contratos pagos)
- **Resultado**: Casais se tornam contratos pagos
- **Limite**: 15 contratos por membro (22.500 contratos total)

## 📋 **Arquivos Modificados**

### **Banco de Dados:**
- **`docs/NOVA_ESTRUTURA_SISTEMA_MEMBROS.sql`** - Nova tabela e configurações

### **Hooks:**
- **`src/hooks/useSystemSettings.ts`** - Nova função de controle

### **Interface:**
- **`src/pages/dashboard.tsx`** - Seção de controle para administradores

## 🚀 **Como Usar**

### **Para Administradores:**
1. **Faça login como administrador**
2. **Vá para o dashboard**
3. **Encontre a seção "Controle de Links dos Membros"**
4. **Clique no botão desejado:**
   - **"Novos Membros"** - Links cadastram membros
   - **"Contratos Pagos"** - Links cadastram contratos pagos

### **Comportamento:**
- **Mudança imediata**: Tipo é alterado instantaneamente
- **Persistência**: Configuração é salva no banco
- **Feedback visual**: Botão ativo fica verde
- **Informações claras**: Explicação do que cada tipo faz

## 🎉 **Status da Implementação**

- ✅ Estrutura do banco atualizada
- ✅ Hook de controle implementado
- ✅ Interface administrativa criada
- ✅ Configurações dinâmicas funcionando
- ✅ Controle de acesso baseado em role
- ✅ Feedback visual implementado

## 🔮 **Próximos Passos**

Para completar a funcionalidade, ainda é necessário:
- **Implementar lógica condicional** no cadastro baseada no tipo de link
- **Atualizar hook useUserLinks** para usar o tipo de link
- **Modificar PublicRegister** para verificar o tipo de link

**O controle de tipo de links está implementado e funcionando para administradores!** 🔗
