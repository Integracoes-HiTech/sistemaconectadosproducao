# Vereador Connect - Configuração do Banco de Dados

## 🚀 Configuração do Supabase

### 1. Credenciais Configuradas
- **URL:** https://hihvewjyfjcwhjoerule.supabase.co
- **Chave:** Configurada no código

### 2. Executar Script SQL
Execute o arquivo `supabase-schema.sql` no SQL Editor do Supabase para criar as tabelas necessárias.

### 3. Tabelas Criadas

#### `users` - Usuários Cadastrados
- `id` - UUID (chave primária)
- `name` - Nome completo
- `address` - Endereço
- `state` - UF (2 caracteres)
- `city` - Cidade
- `neighborhood` - Bairro
- `phone` - Telefone
- `email` - Email
- `instagram` - Instagram
- `referrer` - Quem indicou
- `registration_date` - Data de cadastro
- `status` - Ativo/Inativo
- `created_at` - Data de criação
- `updated_at` - Data de atualização

#### `auth_users` - Usuários de Autenticação
- `id` - UUID (chave primária)
- `username` - Nome de usuário
- `password` - Senha
- `name` - Nome completo
- `role` - Função/Cargo
- `full_name` - Nome completo com cargo
- `created_at` - Data de criação
- `updated_at` - Data de atualização

### 4. Usuários Padrão Criados
- **joao** / coordenador - João Silva - Coordenador
- **marcos** / colaborador - Marcos Santos - Colaborador  
- **admin** / admin123 - Admin - Administrador
- **wegneycosta** / vereador - Wegney Costa - Vereador

### 5. Funcionalidades Implementadas
- ✅ Autenticação real com banco
- ✅ Cadastro de usuários no banco
- ✅ Dashboard com dados reais
- ✅ Estatísticas dinâmicas
- ✅ Filtros por referrer
- ✅ Validações completas

### 6. Próximos Passos
1. Execute o script SQL no Supabase
2. Teste o login com os usuários padrão
3. Teste o cadastro público
4. Verifique o dashboard com dados reais

### 7. Segurança
- Row Level Security (RLS) habilitado
- Políticas de segurança configuradas
- Índices para performance
- Triggers para updated_at automático

## 🎯 Testando a Aplicação

1. **Login:** Use qualquer um dos usuários padrão
2. **Cadastro:** Acesse um link gerado para testar o cadastro público
3. **Dashboard:** Visualize dados reais e estatísticas
4. **Filtros:** Teste os filtros de pesquisa

O projeto está pronto para uso com banco de dados real! 🚀
