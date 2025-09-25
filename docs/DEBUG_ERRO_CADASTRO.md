# 🔍 Debug: Erro no Cadastro de Membros

## 🎯 **Problema Identificado**

Erro ao cadastrar membro: "Erro ao adicionar membro"

## 🔍 **Possíveis Causas**

### **1. Tabela `members` não existe no banco**
- ❌ Script SQL não foi executado
- ❌ Tabela não foi criada corretamente

### **2. Campos obrigatórios faltando**
- ❌ Campos `couple_name`, `couple_phone`, `couple_instagram` não existem na tabela
- ❌ Campos são NOT NULL mas não estão sendo enviados

### **3. Função `can_register_member` não existe**
- ❌ Função RPC não foi criada no banco
- ❌ Erro na chamada da função

### **4. Políticas de Segurança (RLS)**
- ❌ Row Level Security bloqueando inserção
- ❌ Política de INSERT não configurada corretamente

## ✅ **Soluções Implementadas**

### **1. Logs de Debug Adicionados**

#### **No PublicRegister.tsx:**
```typescript
console.log('📝 Dados do membro a serem salvos:', memberData);
```

#### **No useMembers.ts:**
```typescript
console.log('🔍 Hook useMembers - Dados recebidos:', memberData);
console.log('🔍 Verificando se pode cadastrar mais membros...');
console.log('🔍 Resultado da verificação:', { canRegister, canRegisterError });
console.log('🔍 Inserindo membro no banco...');
console.log('🔍 Dados para inserção:', insertData);
console.log('🔍 Resultado da inserção:', { data, error });
```

### **2. Verificação de Dados**

#### **Dados sendo enviados:**
```typescript
const memberData = {
  name: formData.name.trim(),
  phone: formData.phone,
  instagram: formData.instagram.trim(),
  city: formData.city,
  sector: formData.sector,
  referrer: formData.referrer,
  registration_date: new Date().toISOString().split('T')[0],
  status: 'Ativo' as const,
  // Dados da segunda pessoa (obrigatório)
  couple_name: formData.couple_name.trim(),
  couple_phone: formData.couple_phone,
  couple_instagram: formData.couple_instagram.trim()
};
```

## 🔧 **Como Resolver**

### **Passo 1: Verificar se o Script SQL foi executado**

1. Acesse o Supabase Dashboard
2. Vá em SQL Editor
3. Execute o script `docs/NOVA_ESTRUTURA_SISTEMA_MEMBROS.sql`
4. Verifique se a tabela `members` foi criada

### **Passo 2: Verificar estrutura da tabela**

Execute no SQL Editor:
```sql
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'members' 
AND table_schema = 'public';
```

### **Passo 3: Verificar se a função existe**

Execute no SQL Editor:
```sql
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'can_register_member' 
AND routine_schema = 'public';
```

### **Passo 4: Testar inserção manual**

Execute no SQL Editor:
```sql
INSERT INTO members (
  name, phone, instagram, city, sector, referrer, 
  couple_name, couple_phone, couple_instagram,
  registration_date, status
) VALUES (
  'Teste', '(62) 99999-9999', '@teste', 'Goiânia', 'Educação', 'Admin',
  'Teste Casal', '(62) 88888-8888', '@testecasal',
  CURRENT_DATE, 'Ativo'
);
```

## 🎯 **Próximos Passos**

1. **Execute o script SQL** se ainda não foi executado
2. **Teste o cadastro** com os logs de debug
3. **Verifique o console** do navegador para ver os logs
4. **Reporte o erro específico** que aparecer nos logs

## 📋 **Checklist de Verificação**

- [ ] Script SQL executado no Supabase
- [ ] Tabela `members` existe
- [ ] Campos `couple_*` existem na tabela
- [ ] Função `can_register_member` existe
- [ ] Políticas RLS configuradas
- [ ] Logs de debug funcionando
- [ ] Teste de inserção manual funcionando

## 🚨 **Se o erro persistir**

1. **Copie os logs do console** do navegador
2. **Execute o teste manual** no SQL Editor
3. **Verifique as políticas RLS** no Supabase
4. **Reporte o erro específico** com os logs completos

**Os logs de debug vão mostrar exatamente onde está o problema!** 🔍
