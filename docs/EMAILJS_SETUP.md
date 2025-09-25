# Configuração do EmailJS

## Instruções para configurar o EmailJS

### 1. Criar conta no EmailJS
1. Acesse [https://www.emailjs.com/](https://www.emailjs.com/)
2. Crie uma conta gratuita
3. Verifique seu email

### 2. Configurar Service
1. No dashboard, vá em "Email Services"
2. Clique em "Add New Service"
3. Escolha seu provedor de email (Gmail, Outlook, etc.)
4. Configure as credenciais do seu email
5. Anote o **Service ID** gerado

### 3. Criar Templates
1. Vá em "Email Templates"
2. Clique em "Create New Template"
3. Crie um template para email de boas-vindas:

**Template ID: `template_welcome`**
```
Assunto: Bem-vindo ao Sistema Conectados!

Olá {{to_name}}!

Seu cadastro foi realizado com sucesso no Sistema Conectados!

Suas credenciais de acesso:
👤 Usuário: {{username}}
🔑 Senha: {{password}}

🔗 Link de acesso: {{login_url}}

Você foi indicado por: {{referrer_name}}

Com essas credenciais, você poderá:
- Acessar o sistema
- Gerar seus próprios links de cadastro
- Acompanhar suas indicações
- Expandir sua rede de contatos

Obrigado por fazer parte da nossa rede!

---
Sistema Conectados
```

### 4. Obter Public Key
1. Vá em "Account" > "General"
2. Copie sua **Public Key**

### 5. Atualizar configurações no código
Edite o arquivo `src/services/emailService.ts` e substitua:

```typescript
const EMAILJS_SERVICE_ID = 'seu_service_id_aqui'
const EMAILJS_TEMPLATE_ID = 'template_welcome'
const EMAILJS_PUBLIC_KEY = 'sua_public_key_aqui'
```

### 6. Testar configuração
1. Faça um cadastro de teste
2. Verifique se o email foi enviado
3. Confirme se as credenciais estão corretas

### 7. Limites da conta gratuita
- 200 emails por mês
- Templates ilimitados
- Suporte por email

### 8. Upgrade (opcional)
Se precisar de mais emails:
- Plano Starter: $15/mês - 1.000 emails
- Plano Pro: $30/mês - 5.000 emails
- Plano Business: $60/mês - 20.000 emails

## Troubleshooting

### Email não enviado
1. Verifique se as credenciais estão corretas
2. Confirme se o template existe
3. Verifique os logs no console do navegador
4. Teste com um email diferente

### Template não encontrado
1. Verifique se o Template ID está correto
2. Confirme se o template está publicado
3. Teste o template no dashboard do EmailJS

### Service não configurado
1. Verifique se o Service ID está correto
2. Confirme se o serviço está ativo
3. Teste a conexão no dashboard
