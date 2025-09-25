# 📊 Migração do Banco de Dados: Supabase → MySQL (DBeaver)

## 🎯 **Visão Geral da Migração**

Este documento detalha a migração completa do sistema de banco de dados do **Supabase (PostgreSQL)** para **MySQL com DBeaver** no projeto Vereador Connect.

### **📋 O que será migrado:**
- ✅ **10 tabelas principais** com estrutura atual
- ✅ **Triggers** para atualização automática
- ✅ **Procedures** para operações complexas  
- ✅ **Views** para relatórios e estatísticas
- ✅ **Índices** para performance
- ✅ **Dados de exemplo** para teste
- ✅ **Configurações do sistema**

### **🔄 Processo de Migração:**
1. **Configurar MySQL** e DBeaver
2. **Executar script SQL** completo
3. **Configurar aplicação** para MySQL
4. **Testar conexão** e funcionalidades
5. **Remover dependências** do Supabase

---

## 📋 **Pré-requisitos**

### **Para Configurar MySQL:**
- ✅ Servidor MySQL instalado e rodando
- ✅ DBeaver Community Edition instalado
- ✅ Usuário MySQL com permissões adequadas
- ✅ Banco de dados `vereador_connect` criado

### **Para Configurar Aplicação:**
- ✅ Node.js e npm instalados
- ✅ Dependência `mysql2` instalada
- ✅ Arquivo `.env.local` configurado
- ✅ Variáveis de ambiente definidas

---

## 🔄 **Processo de Migração**

### **1. Configuração do MySQL e DBeaver**

#### **1.1 Instalar DBeaver**
```bash
# Baixar DBeaver Community Edition
https://dbeaver.io/download/
```

#### **1.2 Configurar Conexão MySQL**
1. Abra o DBeaver
2. Clique em "New Database Connection" (ícone de plug)
3. Selecione "MySQL"
4. Configure os parâmetros:

```
Host: localhost
Port: 3306
Database: vereador_connect
Username: root
Password: [sua_senha_do_mysql]
```

#### **1.3 Testar Conexão**
- Clique em "Test Connection"
- Se tudo estiver correto, clique em "OK"

### **2. Executar Script SQL Completo**

#### **2.1 Abrir SQL Editor**
1. Clique com botão direito na conexão criada
2. Selecione "SQL Editor" > "New SQL Script"

#### **2.2 Executar Script**
1. Copie todo o conteúdo do arquivo `docs/SCRIPT_COMPLETO_MYSQL.sql`
2. Cole no editor SQL do DBeaver
3. Execute o script (Ctrl+Enter ou botão "Execute")

#### **2.3 Verificar Tabelas Criadas**
Após executar o script, você deve ver as seguintes tabelas:
- `users` - Usuários cadastrados
- `auth_users` - Usuários de autenticação
- `user_links` - Links gerados
- `members` - Sistema principal de membros
- `friends` - Sistema de amigos/contratos pagos
- `paid_contracts` - Contratos pagos
- `system_settings` - Configurações do sistema
- `member_ranking` - Ranking dos membros
- `phase_control` - Controle de fases
- `instagram_posts` - Fiscalização via posts

### **3. Configurar Aplicação para MySQL**

#### **3.1 Instalar Dependência**
```bash
npm install mysql2
```

#### **3.2 Configurar Variáveis de Ambiente**
Crie um arquivo `.env.local` na raiz do projeto:

```env
VITE_MYSQL_HOST=localhost
VITE_MYSQL_USER=root
VITE_MYSQL_PASSWORD=sua_senha_aqui
VITE_MYSQL_DATABASE=vereador_connect
```

#### **3.3 Arquivos Atualizados**
Os seguintes arquivos foram atualizados para MySQL:
- `src/lib/database.ts` - Nova configuração de banco
- `src/hooks/useAuth.ts` - Autenticação com MySQL
- `src/hooks/useSystemSettings.ts` - Configurações com MySQL
- `src/lib/testConnection.ts` - Teste de conexão

### **4. Testar Conexão e Funcionalidades**

#### **4.1 Testar Conexão**
```bash
npm run dev
```

#### **4.2 Verificar no Console**
- ✅ "Conexão com MySQL estabelecida com sucesso!"
- ✅ Tabelas encontradas
- ✅ Usuários de autenticação carregados
- ✅ Configurações do sistema carregadas

#### **4.3 Testar Funcionalidades**
- ✅ Login com usuários padrão
- ✅ Dashboard carregando dados
- ✅ Cadastro público funcionando
- ✅ Configurações do sistema

### **5. Remover Dependências do Supabase**

#### **5.1 Desinstalar Pacotes**
```bash
npm uninstall @supabase/supabase-js
```

#### **5.2 Remover Arquivos**
- `src/lib/supabase.ts` (substituído por `database.ts`)

#### **5.3 Limpar Código**
- Remover imports do Supabase
- Atualizar referências para MySQL

---

## 🗂️ **Estrutura do Banco Migrado**

### **Tabelas Principais:**
```sql
-- Usuários cadastrados (público)
users (id, name, phone, instagram, city, sector, referrer, ...)

-- Usuários de autenticação (sistema)
auth_users (id, username, password, name, role, full_name, ...)

-- Links gerados
user_links (id, user_id, link_type, click_count, registration_count, ...)

-- Sistema principal de membros
members (id, name, phone, instagram, city, sector, referrer, ...)

-- Sistema de amigos/contratos pagos
friends (id, member_id, name, phone, instagram, city, sector, ...)

-- Contratos pagos
paid_contracts (id, member_id, couple_name_1, couple_name_2, ...)

-- Configurações do sistema
system_settings (id, setting_key, setting_value, description, ...)

-- Ranking dos membros
member_ranking (id, member_id, ranking_position, contracts_completed, ...)

-- Controle de fases
phase_control (id, phase_name, is_active, max_limit, current_count, ...)

-- Posts do Instagram (fiscalização)
instagram_posts (id, contract_id, person_number, post_url, hashtag, ...)
```

### **Funcionalidades Incluídas:**
- ✅ **Triggers** para atualização automática de rankings
- ✅ **Procedures** para verificação de limites e atualização de rankings
- ✅ **Views** para estatísticas e rankings
- ✅ **Índices** para performance
- ✅ **Configurações iniciais** do sistema
- ✅ **Dados de exemplo** para teste

---

## 🔧 **Configuração do DBeaver**

### **Conexão Recomendada:**
```
Nome: Vereador Connect
Tipo: MySQL
Host: localhost
Port: 3306
Database: vereador_connect
Username: root
Password: [sua_senha]
```

### **Configurações Avançadas:**
- **Charset:** utf8mb4
- **Timezone:** UTC
- **Connection Timeout:** 60 segundos
- **Auto Reconnect:** Habilitado

---

## 🚨 **Troubleshooting**

### **Erro de Conexão:**
- Verifique se o MySQL está rodando
- Confirme as credenciais no arquivo `.env.local`
- Teste a conexão no DBeaver primeiro

### **Erro de Permissão:**
- Certifique-se de que o usuário MySQL tem permissões adequadas
- Para desenvolvimento, pode usar o usuário `root`

### **Erro de Banco Não Encontrado:**
- Execute o script SQL para criar o banco e as tabelas
- Verifique se o nome do banco está correto nas configurações

### **Erro de Tabela Não Encontrada:**
- Execute o script `docs/SCRIPT_COMPLETO_MYSQL.sql` completo
- Verifique se todas as tabelas foram criadas

---

## ✅ **Checklist de Migração**

### **Configuração Inicial:**
- [ ] MySQL instalado e rodando
- [ ] DBeaver instalado e configurado
- [ ] Conexão testada no DBeaver
- [ ] Banco `vereador_connect` criado

### **Execução do Script:**
- [ ] Script SQL executado completamente
- [ ] Todas as 10 tabelas criadas
- [ ] Triggers e procedures criados
- [ ] Dados de exemplo inseridos
- [ ] Configurações do sistema inseridas

### **Configuração da Aplicação:**
- [ ] Dependência `mysql2` instalada
- [ ] Arquivo `.env.local` configurado
- [ ] Arquivos de código atualizados
- [ ] Conexão testada na aplicação

### **Testes Finais:**
- [ ] Login funcionando
- [ ] Dashboard carregando dados
- [ ] Cadastro público funcionando
- [ ] Configurações do sistema funcionando
- [ ] Sem erros no console

### **Limpeza:**
- [ ] Dependências do Supabase removidas
- [ ] Arquivos antigos removidos
- [ ] Código limpo e atualizado

---

## 🎉 **Migração Concluída**

Após seguir todos os passos:

1. ✅ **Banco MySQL configurado** com DBeaver
2. ✅ **Tabelas criadas** com estrutura atual
3. ✅ **Dados migrados** e funcionando
4. ✅ **Aplicação conectada** ao MySQL
5. ✅ **Supabase removido** completamente

O sistema agora está totalmente migrado para MySQL e pronto para uso!

---

## 📚 **Arquivos de Referência**

- `docs/SCRIPT_COMPLETO_MYSQL.sql` - Script completo para criar o banco
- `docs/CONFIGURACAO_DBEAVER.md` - Guia detalhado do DBeaver
- `src/lib/database.ts` - Configuração de conexão MySQL
- `src/lib/testConnection.ts` - Teste de conexão
- `env.example` - Exemplo de variáveis de ambiente
