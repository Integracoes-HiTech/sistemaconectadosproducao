# 📧 Configuração EmailJS - Service ID: service_4wxt8a2

## 🎯 **O que você precisa fazer:**

### 1️⃣ **Obter sua Public Key**
1. Acesse [https://dashboard.emailjs.com/](https://dashboard.emailjs.com/)
2. Faça login na sua conta
3. Vá em **Account** → **General**
4. Copie sua **Public Key** (algo como: `abc123def456ghi789`)

### 2️⃣ **Atualizar o código**
Edite o arquivo `src/services/emailService.ts` e substitua:
```typescript
const EMAILJS_PUBLIC_KEY = 'SUA_PUBLIC_KEY_AQUI'
```

### 3️⃣ **Criar Template de Email**
No dashboard do EmailJS:

1. Vá em **Email Templates**
2. Clique **Create New Template**
3. Use estas configurações:

**Template ID:** `template_welcome`
**Subject:** `Bem-vindo ao Sistema Conectados!`

**Template Body:**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Bem-vindo ao Sistema Conectados</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #1e3a8a, #fbbf24); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 28px;">🎉 Bem-vindo ao Sistema Conectados!</h1>
        </div>
        
        <!-- Content -->
        <div style="background: #f8fafc; padding: 30px; border-radius: 0 0 10px 10px;">
            
            <p style="font-size: 18px; margin-bottom: 20px;">
                Olá <strong>{{to_name}}</strong>! 👋
            </p>
            
            <p style="font-size: 16px; margin-bottom: 25px;">
                Seu cadastro foi realizado com <strong>sucesso</strong> no Sistema Conectados!
            </p>
            
            <!-- Credentials Card -->
            <div style="background: white; padding: 25px; border-radius: 10px; border-left: 5px solid #fbbf24; margin: 25px 0;">
                <h3 style="color: #1e3a8a; margin-top: 0;">🔑 Suas Credenciais de Acesso:</h3>
                
                <div style="background: #f1f5f9; padding: 15px; border-radius: 8px; margin: 15px 0;">
                    <p style="margin: 5px 0;"><strong>👤 Usuário:</strong> <code style="background: #e2e8f0; padding: 2px 6px; border-radius: 4px;">{{username}}</code></p>
                    <p style="margin: 5px 0;"><strong>🔑 Senha:</strong> <code style="background: #e2e8f0; padding: 2px 6px; border-radius: 4px;">{{password}}</code></p>
                </div>
                
                <div style="text-align: center; margin: 20px 0;">
                    <a href="{{login_url}}" style="background: #1e3a8a; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
                        🚀 Acessar Sistema
                    </a>
                </div>
            </div>
            
            <!-- Referrer Info -->
            <div style="background: #fef3c7; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <p style="margin: 0; color: #92400e;">
                    <strong>📋 Você foi indicado por:</strong> {{referrer_name}}
                </p>
            </div>
            
            <!-- Features -->
            <div style="margin: 30px 0;">
                <h3 style="color: #1e3a8a;">✨ Com essas credenciais, você poderá:</h3>
                <ul style="padding-left: 20px;">
                    <li>🔗 Gerar seus próprios links de cadastro</li>
                    <li>📊 Acompanhar suas indicações</li>
                    <li>👥 Expandir sua rede de contatos</li>
                    <li>📈 Ver estatísticas em tempo real</li>
                </ul>
            </div>
            
            <!-- Footer -->
            <div style="text-align: center; margin-top: 40px; padding-top: 20px; border-top: 2px solid #e2e8f0;">
                <p style="color: #64748b; font-size: 14px; margin: 0;">
                    Obrigado por fazer parte da nossa rede! 🌟
                </p>
                <p style="color: #64748b; font-size: 12px; margin: 10px 0 0 0;">
                    Sistema Conectados - Todos os direitos reservados
                </p>
            </div>
            
        </div>
    </div>
</body>
</html>
```

### 4️⃣ **Configurar Variáveis do Template**
No template, certifique-se de que estas variáveis estão configuradas:
- `{{to_name}}` - Nome do destinatário
- `{{to_email}}` - Email do destinatário  
- `{{username}}` - Usuário gerado
- `{{password}}` - Senha gerada
- `{{login_url}}` - URL de login
- `{{referrer_name}}` - Nome de quem indicou

### 5️⃣ **Testar Configuração**
1. Salve o template
2. Publique o template
3. Teste com um email real
4. Verifique se chegou na caixa de entrada

## 🔧 **Código Final Atualizado:**

Após configurar, seu `src/services/emailService.ts` ficará assim:

```typescript
const EMAILJS_SERVICE_ID = 'service_4wxt8a2' // ✅ Seu Service ID
const EMAILJS_TEMPLATE_ID = 'template_welcome' // ✅ Template criado
const EMAILJS_PUBLIC_KEY = 'sua_public_key_aqui' // ⚠️ Substitua pela sua
```

## 🚨 **Importante:**

1. **Public Key é obrigatória** - Sem ela o email não funciona
2. **Template deve estar publicado** - Não apenas salvo
3. **Teste sempre** - Faça um cadastro de teste primeiro
4. **Verifique spam** - Emails podem ir para spam inicialmente

## 📱 **Teste Rápido:**

1. Configure tudo acima
2. Faça um cadastro no PublicRegister
3. Verifique se o email chegou
4. Teste o login com as credenciais

**Pronto! Seu sistema de email estará funcionando!** 🚀
