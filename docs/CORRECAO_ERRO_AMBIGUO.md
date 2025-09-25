# 🔧 Correção: Erro de Coluna Ambígua

## 🎯 **Problema Identificado**

```
❌ Erro: column reference "current_count" is ambiguous
❌ Código: 42702
❌ Função: can_register_member()
```

## 🔍 **Causa do Erro**

A função `can_register_member()` tinha uma ambiguidade na referência das colunas:

```sql
-- ❌ PROBLEMA: Variáveis com mesmo nome das colunas
DECLARE
  current_count INTEGER;  -- ← Mesmo nome da coluna
  max_limit INTEGER;      -- ← Mesmo nome da coluna
BEGIN
  SELECT current_count, max_limit  -- ← Ambíguo!
  INTO current_count, max_limit
  FROM phase_control 
  WHERE phase_name = 'members_registration';
```

## ✅ **Solução Implementada**

### **1. Renomear Variáveis**
```sql
-- ✅ SOLUÇÃO: Variáveis com nomes diferentes
DECLARE
  current_member_count INTEGER;  -- ← Nome diferente
  max_member_limit INTEGER;      -- ← Nome diferente
BEGIN
  SELECT pc.current_count, pc.max_limit  -- ← Com alias da tabela
  INTO current_member_count, max_member_limit
  FROM phase_control pc  -- ← Alias da tabela
  WHERE pc.phase_name = 'members_registration';
```

### **2. Usar Alias da Tabela**
- Adicionado alias `pc` para a tabela `phase_control`
- Referências explícitas: `pc.current_count`, `pc.max_limit`

## 🔧 **Como Aplicar a Correção**

### **Passo 1: Execute o Script de Correção**
```sql
-- Execute no SQL Editor do Supabase:
docs/CORRECAO_FUNCAO_CAN_REGISTER_MEMBER.sql
```

### **Passo 2: Verificar se Funcionou**
```sql
-- Testar a função
SELECT can_register_member() as can_register;

-- Verificar dados da tabela
SELECT * FROM phase_control WHERE phase_name = 'members_registration';
```

## 🎯 **Resultado Esperado**

Após a correção:
- ✅ Função `can_register_member()` funcionará corretamente
- ✅ Cadastro de membros funcionará
- ✅ Verificação de limite funcionará
- ✅ Logs de debug mostrarão sucesso

## 📋 **Arquivos Atualizados**

1. **`docs/NOVA_ESTRUTURA_SISTEMA_MEMBROS.sql`** - Script principal corrigido
2. **`docs/CORRECAO_FUNCAO_CAN_REGISTER_MEMBER.sql`** - Script de correção específica

## 🚀 **Próximos Passos**

1. **Execute o script de correção** no Supabase
2. **Teste o cadastro** novamente
3. **Verifique os logs** no console
4. **Confirme que funcionou**

**A correção resolve o problema de ambiguidade de colunas!** ✅
