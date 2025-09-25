# 📧 Template EmailJS - Campos Básicos

## 🎯 **Template Simples:**

### **Template ID:** `template_nw72q9c`
### **Subject:** `Bem-vindo ao Sistema Conectados!`

### **Body:**
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
                    <a href="https://seudominio.com/login" style="background: #1e3a8a; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
                        🚀 Acessar Sistema
                    </a>
                </div>
            </div>
            
            <!-- Email Info -->
            <div style="background: #fef3c7; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <p style="margin: 0; color: #92400e;">
                    <strong>📧 Email:</strong> {{email}}
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

## 🔧 **Configuração no EmailJS:**

### **1️⃣ Atualizar Template:**
1. Acesse [https://dashboard.emailjs.com/](https://dashboard.emailjs.com/)
2. Vá em **Email Templates**
3. Edite o template `template_nw72q9c`
4. Cole o HTML acima
5. **Publique** o template

### **2️⃣ Variáveis Configuradas:**
- `{{to_name}}` - Nome do destinatário
- `{{email}}` - Email do destinatário
- `{{username}}` - Usuário gerado
- `{{password}}` - Senha gerada

## 🧪 **Teste Agora:**

1. **Atualize o template** no EmailJS
2. **Faça um cadastro** no PublicRegister
3. **Verifique se o email chegou**

## ✅ **Dados que serão enviados:**

- **Nome:** `{{to_name}}` - Nome preenchido no formulário
- **Email:** `{{email}}` - Email preenchido no formulário
- **Usuário:** `{{username}}` - Baseado no email
- **Senha:** `{{password}}` - 8 caracteres aleatórios

**Agora o template está correto e deve funcionar perfeitamente!** 🚀
