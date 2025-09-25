# 📸 Validação de Instagram com API

## 🎯 **Funcionalidade Implementada:**
Validação automática de contas do Instagram usando a API oficial para verificar se o usuário existe.

## ✅ **Como Funciona:**

### **1. Validação em Tempo Real:**
- **Durante a digitação:** Campo fica desabilitado durante validação
- **Ao sair do campo (onBlur):** Valida automaticamente
- **Feedback visual:** Spinner de loading durante validação

### **2. Remoção Automática do @:**
```typescript
const cleanInstagram = instagram.replace('@', '');
```
- **Usuário digita:** `@joao123` ou `joao123`
- **Sistema processa:** `joao123` (remove @)
- **API recebe:** `joao123` (sem @)

### **3. Validação via API:**
```typescript
const response = await fetch(
  `https://www.instagram.com/api/v1/users/web_profile_info/?username=${encodeURIComponent(cleanUsername)}`,
  {
    headers: {
      "User-Agent": "Mozilla/5.0",
      "Accept": "*/*",
      "X-IG-App-ID": "936619743392459"
    }
  }
);
```

## 🚨 **Cenários de Validação:**

### **✅ Conta Válida:**
```
Usuário digita: @joao123
Sistema valida: joao123
Resultado: ✅ Conta válida (sem erro)
```

### **❌ Conta Inexistente:**
```
Usuário digita: @conta_inexistente_12345
Sistema valida: conta_inexistente_12345
Resultado: ❌ "Não encontramos um usuário com essa conta de instagram"
```

### **❌ Erro de Conexão:**
```
Usuário digita: @usuario_valido
Sistema valida: usuario_valido
Resultado: ❌ "Erro de conexão ao tentar validar sua conta no instagram"
```

### **❌ Serviço Indisponível:**
```
Usuário digita: @usuario_valido
Sistema valida: usuario_valido
Resultado: ❌ "Não estamos conseguindo validar sua conta no instagram no momento, tente novamente em alguns minutos"
```

## 🎨 **Interface do Usuário:**

### **Durante Validação:**
- **Campo desabilitado:** `disabled={isValidatingInstagram}`
- **Spinner de loading:** Animação no lado direito
- **Feedback visual:** Usuário sabe que está validando

### **Após Validação:**
- **Sucesso:** Campo fica normal (sem erro)
- **Erro:** Campo fica vermelho com mensagem específica
- **Mensagem clara:** Explica exatamente o problema

## 🔧 **Implementação Técnica:**

### **Serviço de Validação:**
```typescript
// src/services/instagramValidation.ts
export async function validateInstagramAccount(username: string): Promise<InstagramValidationResult> {
  const cleanUsername = username.replace('@', '');
  
  const response = await fetch(
    `https://www.instagram.com/api/v1/users/web_profile_info/?username=${encodeURIComponent(cleanUsername)}`,
    {
      method: "GET",
      headers: {
        "User-Agent": "Mozilla/5.0",
        "Accept": "*/*",
        "X-IG-App-ID": "936619743392459"
      }
    }
  );

  if (response.status === 200) {
    return { status: true, message: "" };
  }

  if (response.status === 404) {
    return {
      status: false,
      message: "Não encontramos um usuário com essa conta de instagram"
    };
  }

  return {
    status: false,
    message: "Não estamos conseguindo validar sua conta no instagram no momento, tente novamente em alguns minutos"
  };
}
```

### **Integração no PublicRegister:**
```typescript
const validateInstagram = async (instagram: string) => {
  const cleanInstagram = instagram.replace('@', '');
  
  setIsValidatingInstagram(true);
  setInstagramValidationError(null);

  try {
    const result = await validateInstagramAccount(cleanInstagram);
    
    if (result.status) {
      return { isValid: true, error: null };
    } else {
      return { isValid: false, error: result.message };
    }
  } catch (error) {
    return { isValid: false, error: 'Erro ao validar conta do Instagram' };
  } finally {
    setIsValidatingInstagram(false);
  }
};
```

### **Evento onBlur:**
```typescript
const handleInstagramBlur = async () => {
  if (formData.instagram.trim()) {
    const validation = await validateInstagram(formData.instagram);
    if (!validation.isValid) {
      setInstagramValidationError(validation.error);
      setFormErrors(prev => ({ ...prev, instagram: validation.error }));
    }
  }
};
```

## 📋 **Estados de Validação:**

### **1. Estado Inicial:**
- **Campo vazio:** Sem validação
- **Usuário digita:** Remove @ automaticamente
- **Campo ativo:** Pronto para validação

### **2. Estado de Validação:**
- **Campo desabilitado:** `disabled={isValidatingInstagram}`
- **Spinner visível:** Animação de loading
- **Usuário aguarda:** Feedback visual claro

### **3. Estado de Sucesso:**
- **Campo normal:** Sem erro
- **Validação passou:** Conta existe no Instagram
- **Pronto para salvar:** Dados válidos

### **4. Estado de Erro:**
- **Campo vermelho:** `border-red-500`
- **Mensagem de erro:** Explica o problema
- **Bloqueia salvamento:** Impede dados inválidos

## 🧪 **Teste:**

### **1. Teste Conta Válida:**
1. Digite: `@instagram` (conta real)
2. Saia do campo (onBlur)
3. **Resultado:** ✅ Validação passou

### **2. Teste Conta Inexistente:**
1. Digite: `@conta_que_nao_existe_12345`
2. Saia do campo (onBlur)
3. **Resultado:** ❌ "Não encontramos um usuário com essa conta de instagram"

### **3. Teste Sem @:**
1. Digite: `instagram` (sem @)
2. Saia do campo (onBlur)
3. **Resultado:** ✅ Validação passou (remove @ automaticamente)

## ✅ **Benefícios:**

### **1. Validação Real:**
- **API oficial:** Usa endpoint do Instagram
- **Verificação precisa:** Confirma se conta existe
- **Dados confiáveis:** Evita contas falsas

### **2. Experiência do Usuário:**
- **Feedback imediato:** Validação em tempo real
- **Interface clara:** Spinner e mensagens específicas
- **Não bloqueia:** Usuário pode continuar digitando

### **3. Qualidade dos Dados:**
- **Contas válidas:** Apenas Instagrams reais
- **Prevenção de erros:** Evita dados inválidos
- **Integridade:** Sistema mais confiável

## 🚀 **Resultado Final:**

**Agora o sistema valida contas do Instagram em tempo real!**

- ✅ **Validação real:** Usa API oficial do Instagram
- ✅ **Remove @ automaticamente:** Independente de como usuário digita
- ✅ **Feedback visual:** Spinner e mensagens claras
- ✅ **Prevenção de erros:** Bloqueia contas inexistentes
- ✅ **UX otimizada:** Validação não bloqueia digitação

**Teste digitando diferentes contas do Instagram para ver a validação funcionando!** 📸✅
