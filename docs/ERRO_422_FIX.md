# 🚨 Erro 422 - EmailJS

## 🔍 **Problema Identificado:**
O erro `422` indica que há um problema com os dados enviados para o EmailJS.

## 🎯 **Possíveis Causas:**

### 1️⃣ **Template não configurado**
- Template `template_nw72q9c` não existe
- Template não está publicado
- Template não tem as variáveis corretas

### 2️⃣ **Service não configurado**
- Service `service_crb2xuj` não existe
- Service não está ativo
- Service não tem email configurado

### 3️⃣ **Variáveis incorretas**
- Template espera variáveis diferentes
- Variáveis não estão sendo enviadas corretamente

### 4️⃣ **Dados inválidos**
- Email inválido
- Nome vazio
- Dados obrigatórios faltando

## 🔧 **Soluções:**

### **Solução 1: Verificar Template**
1. Acesse [https://dashboard.emailjs.com/](https://dashboard.emailjs.com/)
2. Vá em **Email Templates**
3. Verifique se `template_nw72q9c` existe
4. Se não existir, crie um novo template

### **Solução 2: Verificar Service**
1. Vá em **Email Services**
2. Verifique se `service_crb2xuj` existe
3. Se não existir, crie um novo service

### **Solução 3: Testar Template Simples**
Crie um template de teste simples:

**Template ID:** `template_test`
**Subject:** `Teste`
**Body:**
```html
<h1>Teste</h1>
<p>Nome: {{to_name}}</p>
<p>Email: {{to_email}}</p>
<p>Usuário: {{username}}</p>
<p>Senha: {{password}}</p>
```

## 🧪 **Teste Passo a Passo:**

### **Passo 1: Verificar Console**
1. Abra F12 no navegador
2. Vá na aba **Console**
3. Faça um cadastro
4. Veja as mensagens de erro

### **Passo 2: Verificar EmailJS Dashboard**
1. Acesse [https://dashboard.emailjs.com/](https://dashboard.emailjs.com/)
2. Vá em **Email Templates**
3. Verifique se `template_nw72q9c` existe
4. Se não existir, crie um novo

### **Passo 3: Testar Template**
1. Crie um template simples
2. Teste no EmailJS
3. Se funcionar, use no código

## 📋 **O que fazer agora:**

**Me diga:**
1. O que aparece no console quando você faz o cadastro?
2. O template `template_nw72q9c` existe no seu EmailJS?
3. O service `service_crb2xuj` existe?

## 🚀 **Alternativa Rápida:**

Se quiser testar rapidamente:
1. Crie um template novo no EmailJS
2. ID: `template_simple`
3. Subject: `Teste`
4. Body: `Teste: {{to_name}} - {{username}} - {{password}}`
5. Me envie o novo Template ID
6. Atualizo o código

**O erro 422 indica que o template ou service não está configurado corretamente!** 🎯
