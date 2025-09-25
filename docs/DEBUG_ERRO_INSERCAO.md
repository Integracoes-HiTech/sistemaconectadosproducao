# 🔍 Debug: Erro na Inserção de Membros

## 🎯 **Problema Atual**

```
❌ Erro: Failed to load resource: the server responded with a status of 400
❌ Local: Inserção na tabela members
❌ Status: 400 Bad Request
```

## 🔍 **Possíveis Causas**

### **1. Tabela `members` não existe**
- ❌ Script SQL não foi executado
- ❌ Tabela não foi criada

### **2. Campos obrigatórios faltando**
- ❌ Campos `couple_*` não existem na tabela
- ❌ Campos são NOT NULL mas não estão sendo enviados

### **3. Políticas RLS bloqueando**
- ❌ Row Level Security habilitado
- ❌ Política de INSERT não configurada

### **4. Estrutura da tabela incorreta**
- ❌ Tipos de dados incompatíveis
- ❌ Constraints violados

## ✅ **Soluções Implementadas**

### **1. Logs Melhorados**
```typescript
console.error('❌ Detalhes do erro:', JSON.stringify(error, null, 2));
```

### **2. Scripts de Verificação**
- **`docs/VERIFICAR_TABELA_MEMBERS.sql`** - Verificar estrutura
- **`docs/TESTE_INSERCAO_MANUAL.sql`** - Testar inserção manual

## 🔧 **Como Resolver**

### **Passo 1: Verificar se a Tabela Existe**
Execute no SQL Editor:
```sql
-- Execute: docs/VERIFICAR_TABELA_MEMBERS.sql
```

### **Passo 2: Testar Inserção Manual**
Execute no SQL Editor:
```sql
-- Execute: docs/TESTE_INSERCAO_MANUAL.sql
```

### **Passo 3: Verificar Logs Detalhados**
1. Abra o console do navegador (F12)
2. Tente cadastrar um membro
3. Copie os logs que aparecerem
4. Me envie os logs detalhados

## 🎯 **Próximos Passos**

1. **Execute o script de verificação** no Supabase
2. **Teste a inserção manual** no SQL Editor
3. **Verifique os logs detalhados** no console
4. **Reporte o erro específico** com os logs completos

## 📋 **Checklist de Verificação**

- [ ] Tabela `members` existe
- [ ] Campos `couple_*` existem
- [ ] Políticas RLS configuradas
- [ ] Inserção manual funciona
- [ ] Logs detalhados funcionando

## 🚨 **Se o erro persistir**

1. **Execute os scripts de verificação**
2. **Teste a inserção manual**
3. **Copie os logs detalhados do console**
4. **Reporte o erro específico**

**Os logs detalhados vão mostrar exatamente qual é o problema!** 🔍
