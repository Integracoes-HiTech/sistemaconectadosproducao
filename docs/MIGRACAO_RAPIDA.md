# 🚀 Migração Rápida: Supabase → MySQL (DBeaver)

## ⚡ **Passos Rápidos**

### **1. Instalar DBeaver**
```bash
# Baixar: https://dbeaver.io/download/
# Instalar normalmente
```

### **2. Configurar Conexão MySQL**
```
Host: srv2020.hstgr.io
Port: 3306
Database: u877021150_conectados
Username: u877021150_admin
Password: Admin_kiradon9279
```

### **3. Executar Script SQL**
1. Abrir SQL Editor no DBeaver
2. Copiar conteúdo de `docs/SCRIPT_COMPLETO_MYSQL.sql`
3. Executar script (Ctrl+Enter)

### **4. Configurar Aplicação**
```bash
# Instalar dependência
npm install mysql2

# Criar arquivo .env.local
VITE_MYSQL_HOST=srv2020.hstgr.io
VITE_MYSQL_USER=u877021150_admin
VITE_MYSQL_PASSWORD=Admin_kiradon9279
VITE_MYSQL_DATABASE=u877021150_conectados
```

### **5. Testar**
```bash
npm run dev
```

## ✅ **Verificações**

- [ ] DBeaver conectado ao MySQL
- [ ] 10 tabelas criadas
- [ ] Aplicação rodando sem erros
- [ ] Login funcionando
- [ ] Dashboard carregando dados

## 🎯 **Resultado**

Sistema migrado do Supabase para MySQL com DBeaver!
