# Configuração do DBeaver para Vereador Connect

## 📋 Passo a Passo para Configurar DBeaver

### 1. Instalar DBeaver
- Baixe o DBeaver Community Edition: https://dbeaver.io/download/
- Instale normalmente no seu sistema

### 2. Configurar Conexão MySQL
1. Abra o DBeaver
2. Clique em "New Database Connection" (ícone de plug)
3. Selecione "MySQL"
4. Configure os seguintes parâmetros:

```
Host: srv2020.hstgr.io
Port: 3306
Database: u877021150_conectados
Username: u877021150_admin
Password: Admin_kiradon9279
```

### 3. Testar Conexão
- Clique em "Test Connection"
- Se tudo estiver correto, clique em "OK"

### 4. Executar Script SQL
1. Clique com botão direito na conexão criada
2. Selecione "SQL Editor" > "New SQL Script"
3. Copie e cole o conteúdo do arquivo `docs/SCRIPT_COMPLETO_MYSQL.sql`
4. Execute o script (Ctrl+Enter ou botão "Execute")

### 5. Verificar Tabelas Criadas
Após executar o script, você deve ver as seguintes tabelas:
- users
- auth_users
- user_links
- members
- friends
- paid_contracts
- system_settings
- member_ranking
- phase_control
- instagram_posts

## 🔧 Configuração do Projeto

### 1. Variáveis de Ambiente
Crie um arquivo `.env.local` na raiz do projeto com:

```env
VITE_MYSQL_HOST=srv2020.hstgr.io
VITE_MYSQL_USER=u877021150_admin
VITE_MYSQL_PASSWORD=Admin_kiradon9279
VITE_MYSQL_DATABASE=u877021150_conectados
```

### 2. Instalar Dependências
```bash
npm install mysql2
```

### 3. Testar Conexão
Execute o projeto e verifique se a conexão está funcionando:
```bash
npm run dev
```

## 🚨 Troubleshooting

### Erro de Conexão
- Verifique se o MySQL está rodando
- Confirme as credenciais no arquivo `.env.local`
- Teste a conexão no DBeaver primeiro

### Erro de Permissão
- Certifique-se de que o usuário MySQL tem permissões adequadas
- Para desenvolvimento, pode usar o usuário `root`

### Erro de Banco Não Encontrado
- Execute o script SQL para criar o banco e as tabelas
- Verifique se o nome do banco está correto nas configurações

## 📊 Estrutura do Banco

O banco `vereador_connect` contém:
- **10 tabelas principais** com a estrutura atual do sistema
- **Triggers** para atualização automática de rankings
- **Procedures** para operações complexas
- **Views** para relatórios e estatísticas
- **Índices** para performance
- **Dados de exemplo** para teste

## 🔄 Migração Completa

Após configurar o DBeaver e executar o script:
1. ✅ Banco MySQL configurado
2. ✅ Tabelas criadas
3. ✅ Dados de exemplo inseridos
4. ✅ Aplicação conectada ao MySQL
5. ✅ Supabase removido

O sistema agora está totalmente migrado para MySQL!
