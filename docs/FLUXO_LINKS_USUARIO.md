# 🔗 Sistema de Links de Usuário - Fluxo Completo

## 📋 **Como Funciona:**

### 1️⃣ **Geração do Link (Dashboard)**
```
Usuário logado → Clica "Gerar Link" → Sistema cria link único
```

**Exemplo:**
- Usuário: João Silva (Coordenador)
- Username: joao
- Timestamp: 1735123456
- Link gerado: `joao-1735123456`

### 2️⃣ **Salvamento no Banco**
```sql
INSERT INTO user_links (
  user_id,           -- ID do usuário que gerou
  link_id,           -- joao-1735123456
  referrer_name,     -- João Silva - Coordenador
  is_active,         -- true
  click_count,       -- 0
  registration_count -- 0
)
```

### 3️⃣ **URL Completa**
```
https://seudominio.com/cadastro/joao-1735123456
```

### 4️⃣ **Compartilhamento**
- Link é copiado automaticamente
- Usuário compartilha no WhatsApp, Instagram, etc.
- Cada pessoa que acessa o link é direcionada para o PublicRegister

### 5️⃣ **Acesso ao Link (PublicRegister)**
```
Alguém acessa o link → Sistema extrai linkId → Busca dados do referrer
```

**Processo:**
1. URL: `/cadastro/joao-1735123456`
2. Sistema extrai: `linkId = "joao-1735123456"`
3. Busca no banco: `SELECT * FROM user_links WHERE link_id = 'joao-1735123456'`
4. Encontra dados do João Silva
5. Preenche campo referrer automaticamente

### 6️⃣ **Cadastro Vinculado**
```
Maria preenche formulário → Sistema salva vinculado ao João Silva
```

**Resultado:**
- Maria fica vinculada a João Silva
- João Silva recebe +1 no contador de registros
- Maria recebe credenciais de acesso por email

## 🎯 **Exemplo Prático Completo:**

### **Cenário:**
João Silva quer expandir sua rede de contatos

### **Passo a Passo:**

1. **João faz login** no sistema
2. **Clica "Gerar Link"** no dashboard
3. **Sistema gera:** `joao-1735123456`
4. **URL criada:** `https://app.com/cadastro/joao-1735123456`
5. **Link é copiado** automaticamente
6. **João compartilha** no WhatsApp: "Cadastre-se aqui: [link]"
7. **Maria acessa** o link
8. **PublicRegister abre** com:
   - Campo referrer preenchido: "João Silva - Coordenador"
   - Informações do João exibidas
9. **Maria preenche** seus dados
10. **Sistema salva:**
    - Maria na tabela `users` (referrer: "João Silva - Coordenador")
    - Maria na tabela `auth_users` (com credenciais)
    - Contador do João +1
11. **Email enviado** para Maria com login/senha
12. **Maria pode** agora gerar seus próprios links

## 🔄 **Fluxo de Dados:**

```
Dashboard (João) 
    ↓ [Gera Link]
Banco (user_links)
    ↓ [Salva linkId]
URL Compartilhada
    ↓ [Alguém acessa]
PublicRegister
    ↓ [Busca referrer]
Banco (user_links)
    ↓ [Encontra João]
Formulário Preenchido
    ↓ [Maria cadastra]
Banco (users + auth_users)
    ↓ [Vincula a João]
Email com Credenciais
    ↓ [Enviado para Maria]
Sistema Completo ✅
```

## 🎯 **Benefícios:**

1. **Rastreabilidade:** Cada cadastro fica vinculado ao gerador
2. **Estatísticas:** Contadores automáticos por usuário
3. **Credenciais:** Acesso automático ao sistema
4. **Expansão:** Rede cresce organicamente
5. **Controle:** Cada usuário gerencia seus próprios links

## 🔧 **Implementação Técnica:**

### **Arquivos Envolvidos:**
- `src/pages/dashboard.tsx` - Geração do link
- `src/hooks/useUserLinks.ts` - Gerenciamento de links
- `src/pages/PublicRegister.tsx` - Formulário de cadastro
- `src/hooks/useCredentials.ts` - Geração de credenciais
- `src/services/emailService.ts` - Envio de email

### **Tabelas do Banco:**
- `user_links` - Links gerados
- `users` - Cadastros públicos
- `auth_users` - Usuários do sistema
- `user_stats` - Estatísticas (automático)

## ✅ **Status da Implementação:**

- ✅ Geração de links únicos
- ✅ Salvamento no banco
- ✅ Busca de referrer por linkId
- ✅ Preenchimento automático do formulário
- ✅ Vinculação de cadastros
- ✅ Geração de credenciais
- ✅ Envio de email
- ✅ Contadores automáticos

**O sistema está 100% funcional!** 🚀
