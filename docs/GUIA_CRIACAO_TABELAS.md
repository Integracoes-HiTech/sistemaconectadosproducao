# 🗄️ Guia Completo - Criar Tabelas no Supabase

## 📋 Passo a Passo para Executar no Supabase

### 1. Acessar o Supabase Dashboard
- Acesse: https://supabase.com/dashboard
- Faça login na sua conta
- Selecione o projeto: `hihvewjyfjcwhjoerule`

### 2. Abrir o SQL Editor
- No menu lateral, clique em **"SQL Editor"**
- Clique em **"New query"**

### 3. Executar o Script
- Copie todo o conteúdo do arquivo `supabase-complete-schema.sql`
- Cole no editor SQL
- Clique em **"Run"** ou pressione `Ctrl+Enter`

### 4. Verificar se Funcionou
Após executar, você deve ver:
- ✅ "Tabelas criadas com sucesso!"
- ✅ Lista dos usuários inseridos
- ✅ Contagem de usuários de exemplo

## 🏗️ Estrutura das Tabelas Criadas

### 📊 Tabela `users` (Usuários Cadastrados)
```sql
- id (UUID) - Chave primária
- name (VARCHAR) - Nome completo
- address (TEXT) - Endereço
- state (VARCHAR) - UF (2 caracteres)
- city (VARCHAR) - Cidade
- neighborhood (VARCHAR) - Bairro
- phone (VARCHAR) - Telefone
- email (VARCHAR) - Email
- instagram (VARCHAR) - Instagram
- referrer (VARCHAR) - Quem indicou
- registration_date (DATE) - Data de cadastro
- status (VARCHAR) - Ativo/Inativo
- created_at (TIMESTAMP) - Data de criação
- updated_at (TIMESTAMP) - Data de atualização
```

### 🔐 Tabela `auth_users` (Usuários do Sistema)
```sql
- id (UUID) - Chave primária
- username (VARCHAR) - Nome de usuário
- password (VARCHAR) - Senha
- name (VARCHAR) - Nome completo
- role (VARCHAR) - Função/Cargo
- full_name (VARCHAR) - Nome completo com cargo
- email (VARCHAR) - Email
- phone (VARCHAR) - Telefone
- is_active (BOOLEAN) - Ativo/Inativo
- last_login (TIMESTAMP) - Último login
- created_at (TIMESTAMP) - Data de criação
- updated_at (TIMESTAMP) - Data de atualização
```

### 🔗 Tabela `user_links` (Links Gerados)
```sql
- id (UUID) - Chave primária
- link_id (VARCHAR) - ID único do link
- user_id (UUID) - Referência ao usuário
- referrer_name (VARCHAR) - Nome de quem indicou
- is_active (BOOLEAN) - Link ativo
- click_count (INTEGER) - Contador de cliques
- registration_count (INTEGER) - Contador de cadastros
- created_at (TIMESTAMP) - Data de criação
- expires_at (TIMESTAMP) - Data de expiração
- updated_at (TIMESTAMP) - Data de atualização
```

### 📈 Tabela `user_stats` (Estatísticas)
```sql
- id (UUID) - Chave primária
- user_id (UUID) - Referência ao usuário
- date (DATE) - Data das estatísticas
- total_users (INTEGER) - Total de usuários
- active_users (INTEGER) - Usuários ativos
- new_registrations (INTEGER) - Novos cadastros
- engagement_rate (DECIMAL) - Taxa de engajamento
- created_at (TIMESTAMP) - Data de criação
- updated_at (TIMESTAMP) - Data de atualização
```

## 👥 Usuários Padrão Criados

| Usuário | Senha | Nome | Cargo |
|---------|-------|------|-------|
| joao | coordenador | João Silva | Coordenador |
| marcos | colaborador | Marcos Santos | Colaborador |
| admin | admin123 | Admin | Administrador |
| wegneycosta | vereador | Wegney Costa | Vereador |

## 🔧 Funcionalidades Implementadas

### ✅ Segurança
- Row Level Security (RLS) habilitado
- Políticas de segurança configuradas
- Índices para performance otimizada

### ✅ Automatizações
- Triggers para `updated_at` automático
- Contador de registros automático
- Funções auxiliares para estatísticas

### ✅ Views Úteis
- `user_statistics` - Estatísticas consolidadas
- `active_links` - Links ativos

### ✅ Dados de Exemplo
- 10 usuários de exemplo inseridos
- Dados distribuídos entre João Silva e Marcos Santos

## 🧪 Testando Após Executar

### 1. Teste de Login
- Use qualquer usuário padrão para fazer login
- Verifique se o dashboard carrega

### 2. Teste de Cadastro
- Gere um link único no dashboard
- Acesse o link e teste o cadastro público
- Verifique se o usuário aparece na tabela

### 3. Teste de Estatísticas
- Verifique se as estatísticas são calculadas corretamente
- Teste os filtros de pesquisa

## 🚨 Possíveis Erros e Soluções

### Erro: "relation already exists"
- **Solução:** O script já foi executado antes
- **Ação:** Ignore o erro, as tabelas já existem

### Erro: "permission denied"
- **Solução:** Verifique se você tem permissões de administrador no projeto
- **Ação:** Entre em contato com o administrador do projeto

### Erro: "duplicate key value"
- **Solução:** Os dados já foram inseridos
- **Ação:** Ignore o erro, os dados já existem

## ✅ Verificação Final

Após executar o script, verifique se:

1. ✅ 4 tabelas foram criadas (`users`, `auth_users`, `user_links`, `user_stats`)
2. ✅ 4 usuários padrão foram inseridos
3. ✅ 10 usuários de exemplo foram inseridos
4. ✅ Índices foram criados
5. ✅ RLS foi habilitado
6. ✅ Triggers foram criados

## 🎯 Próximo Passo

Após executar o script com sucesso:
1. Teste o login na aplicação
2. Gere um link único
3. Teste o cadastro público
4. Verifique o dashboard com dados reais

**O banco de dados estará pronto para uso!** 🚀
