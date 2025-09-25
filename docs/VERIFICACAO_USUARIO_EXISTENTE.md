# 🔍 Verificação de Usuário Existente

## 🎯 **Funcionalidade Implementada:**
Verificação automática de usuários já cadastrados por **email** e **telefone** antes de salvar no PublicRegister.

## ✅ **Como Funciona:**

### **1. Verificação Dupla:**
```typescript
const checkUserExists = async (email: string, phone: string) => {
  const { data, error } = await supabase
    .from('users')
    .select('id, name, email, phone')
    .or(`email.eq.${email},phone.eq.${phone}`)
}
```

### **2. Detecção Inteligente:**
- **Email duplicado:** Detecta se email já existe
- **Telefone duplicado:** Detecta se telefone já existe
- **Ambos:** Verifica os dois campos simultaneamente

## 🚨 **Cenários de Conflito:**

### **Email Duplicado:**
```
Usuário já cadastrado com este email: joao@exemplo.com
```

### **Telefone Duplicado:**
```
Usuário já cadastrado com este telefone: (11) 99999-9999
```

### **Ambos Duplicados:**
```
Usuário já cadastrado com este email: maria@teste.com
```

## 🔄 **Fluxo de Validação:**

### **Antes (Problema):**
1. Usuário preenche formulário
2. Sistema salva diretamente
3. **Problema:** Usuários duplicados no banco

### **Depois (Solução):**
1. Usuário preenche formulário
2. **Sistema verifica:** Email/telefone já existe?
3. **Se existe:** Mostra erro e bloqueia salvamento
4. **Se não existe:** Salva normalmente

## 📋 **Exemplos Práticos:**

### **Cenário 1 - Email Duplicado:**
```
Usuário digita: joao@exemplo.com
Sistema verifica: Email já existe
Resultado: ❌ "Usuário já cadastrado com este email: joao@exemplo.com"
```

### **Cenário 2 - Telefone Duplicado:**
```
Usuário digita: (11) 99999-9999
Sistema verifica: Telefone já existe
Resultado: ❌ "Usuário já cadastrado com este telefone: (11) 99999-9999"
```

### **Cenário 3 - Dados Únicos:**
```
Usuário digita: maria@novo.com + (22) 88888-8888
Sistema verifica: Dados únicos
Resultado: ✅ Usuário salvo com sucesso
```

## 🎨 **Interface do Usuário:**

### **Toast de Erro:**
```
🔴 Usuário já cadastrado
Usuário já cadastrado com este email: joao@exemplo.com
```

### **Comportamento:**
- **Botão fica desabilitado** durante verificação
- **Loading spinner** aparece
- **Erro vermelho** se usuário existe
- **Sucesso verde** se dados são únicos

## 🔧 **Implementação Técnica:**

### **Hook useUsers:**
```typescript
const checkUserExists = async (email: string, phone: string) => {
  // Query Supabase com OR para email OU telefone
  const { data, error } = await supabase
    .from('users')
    .select('id, name, email, phone')
    .or(`email.eq.${email},phone.eq.${phone}`)
  
  // Retorna resultado detalhado
  return {
    exists: data.length > 0,
    user: data[0],
    conflictType: 'email' | 'telefone',
    message: 'Mensagem personalizada'
  }
}
```

### **PublicRegister:**
```typescript
const handleSubmit = async (e: React.FormEvent) => {
  // 1. Verificar se usuário existe
  const userExistsCheck = await checkUserExists(email, phone);
  
  if (userExistsCheck.exists) {
    // 2. Mostrar erro e parar
    toast({
      title: "Usuário já cadastrado",
      description: userExistsCheck.message,
      variant: "destructive",
    });
    return;
  }
  
  // 3. Se não existe, salvar normalmente
  await addUser(userData);
}
```

## ✅ **Benefícios:**

### **1. Prevenção de Duplicatas:**
- **Email único:** Cada email só pode ser usado uma vez
- **Telefone único:** Cada telefone só pode ser usado uma vez

### **2. Experiência do Usuário:**
- **Feedback imediato:** Usuário sabe se dados já existem
- **Mensagem clara:** Explica qual campo está duplicado
- **Não perde dados:** Formulário permanece preenchido

### **3. Qualidade dos Dados:**
- **Banco limpo:** Sem usuários duplicados
- **Integridade:** Dados consistentes
- **Confiabilidade:** Sistema mais robusto

## 🧪 **Teste:**

### **1. Teste Email Duplicado:**
1. Cadastre usuário com `joao@teste.com`
2. Tente cadastrar outro com mesmo email
3. **Resultado:** Erro "Usuário já cadastrado com este email"

### **2. Teste Telefone Duplicado:**
1. Cadastre usuário com `(11) 99999-9999`
2. Tente cadastrar outro com mesmo telefone
3. **Resultado:** Erro "Usuário já cadastrado com este telefone"

### **3. Teste Dados Únicos:**
1. Use email e telefone únicos
2. **Resultado:** Usuário salvo com sucesso

## 🚀 **Resultado Final:**

**Agora o sistema previne usuários duplicados automaticamente!**

- ✅ **Email único:** Cada email só pode ser usado uma vez
- ✅ **Telefone único:** Cada telefone só pode ser usado uma vez  
- ✅ **Feedback claro:** Usuário sabe exatamente qual campo está duplicado
- ✅ **Banco limpo:** Sem dados duplicados
- ✅ **UX melhorada:** Experiência mais profissional

**Teste cadastrando o mesmo email/telefone duas vezes para ver a validação funcionando!** 🔍
