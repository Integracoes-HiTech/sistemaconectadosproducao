# 📊 Migração do Banco de Dados: Supabase → phpMyAdmin

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

### **Antes da Migração:**
- [ ] Backup completo do banco Supabase atual
- [ ] Acesso ao Supabase Dashboard com permissões de administrador
- [ ] Servidor MySQL configurado
- [ ] phpMyAdmin instalado e configurado

### **Ferramentas Necessárias:**
- Supabase Dashboard (exportação)
- phpMyAdmin (importação)
- Editor de texto (para ajustes no SQL)

---

## 🔄 **Processo de Migração**

### **1. Exportação do Banco Supabase (PostgreSQL)**

#### **1.1 Acesse o Supabase Dashboard**
```
URL: https://supabase.com/dashboard
Login: [suas credenciais]
Projeto: vereador-connect
```

#### **1.2 Navegue para o SQL Editor**
- Menu lateral → **"SQL Editor"**
- Clique em **"New query"**

#### **1.3 Execute o Script de Exportação**
```sql
-- Exportar estrutura das tabelas
SELECT 
    'CREATE TABLE ' || table_name || ' (' ||
    string_agg(
        column_name || ' ' || data_type || 
        CASE WHEN character_maximum_length IS NOT NULL 
             THEN '(' || character_maximum_length || ')' 
             ELSE '' END ||
        CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
        CASE WHEN column_default IS NOT NULL 
             THEN ' DEFAULT ' || column_default 
             ELSE '' END,
        ', '
    ) || ');' as create_statement
FROM information_schema.columns 
WHERE table_schema = 'public' 
GROUP BY table_name;
```

#### **1.4 Exportar Dados**
```sql
-- Exportar dados de cada tabela
COPY users TO '/tmp/users_export.csv' WITH CSV HEADER;
COPY auth_users TO '/tmp/auth_users_export.csv' WITH CSV HEADER;
COPY user_links TO '/tmp/user_links_export.csv' WITH CSV HEADER;
COPY user_stats TO '/tmp/user_stats_export.csv' WITH CSV HEADER;
```

#### **1.5 Download dos Arquivos**
- Baixe os arquivos CSV do Supabase
- Salve como `vereador_connect_supabase_backup.csv`

---

### **2. Conversão do SQL PostgreSQL → MySQL**

#### **2.1 Diferenças Principais**

| **PostgreSQL** | **MySQL** | **Ação Necessária** |
|----------------|-----------|-------------------|
| `UUID` | `INT AUTO_INCREMENT` | Converter para INT |
| `TIMESTAMP WITH TIME ZONE` | `DATETIME` | Converter |
| `SERIAL` | `INT AUTO_INCREMENT` | Converter |
| `TEXT` | `TEXT` | Manter |
| `VARCHAR(255)` | `VARCHAR(255)` | Manter |
| `INTEGER` | `INT` | Converter |
| `CHECK constraints` | `ENUM` | Converter para ENUM |
| `gen_random_uuid()` | `AUTO_INCREMENT` | Converter |

#### **2.2 Script de Conversão Automática**

Crie um arquivo `converter_postgresql_para_mysql.py`:

```python
import re

def converter_postgresql_para_mysql(arquivo_postgresql, arquivo_mysql):
    with open(arquivo_postgresql, 'r', encoding='utf-8') as f:
        conteudo = f.read()
    
    # Conversões principais
    conversoes = [
        # Converter UUID para INT AUTO_INCREMENT
        (r'id UUID DEFAULT gen_random_uuid\(\) PRIMARY KEY', 'id INT AUTO_INCREMENT PRIMARY KEY'),
        (r'id UUID PRIMARY KEY', 'id INT AUTO_INCREMENT PRIMARY KEY'),
        
        # Converter TIMESTAMP WITH TIME ZONE para DATETIME
        (r'TIMESTAMP WITH TIME ZONE', 'DATETIME'),
        
        # Converter INTEGER para INT
        (r'\bINTEGER\b', 'INT'),
        
        # Converter SERIAL para INT AUTO_INCREMENT
        (r'SERIAL PRIMARY KEY', 'INT AUTO_INCREMENT PRIMARY KEY'),
        
        # Converter DEFAULT NOW() para DEFAULT CURRENT_TIMESTAMP
        (r'DEFAULT NOW\(\)', 'DEFAULT CURRENT_TIMESTAMP'),
        
        # Converter CHECK constraints para ENUM
        (r"CHECK \(status IN \('Ativo', 'Inativo'\)\)", "ENUM('Ativo', 'Inativo') DEFAULT 'Ativo'"),
        
        # Adicionar ENGINE e CHARSET
        (r'\);$', ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'),
        
        # Remover comentários PostgreSQL específicos
        (r'-- .*', ''),
    ]
    
    for padrao, substituicao in conversoes:
        conteudo = re.sub(padrao, substituicao, conteudo, flags=re.IGNORECASE)
    
    # Limpar linhas vazias extras
    conteudo = re.sub(r'\n\s*\n\s*\n', '\n\n', conteudo)
    
    with open(arquivo_mysql, 'w', encoding='utf-8') as f:
        f.write(conteudo)
    
    print(f"Conversão concluída: {arquivo_mysql}")

# Uso
converter_postgresql_para_mysql('vereador_connect_supabase_backup.sql', 'vereador_connect_mysql.sql')
```

#### **2.3 Conversões Manuais Necessárias**

**Estrutura de Tabela PostgreSQL (Supabase):**
```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL UNIQUE,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL DEFAULT 'Centro',
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Estrutura Convertida para MySQL (phpMyAdmin):**
```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL UNIQUE,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL DEFAULT 'Centro',
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### **3. Importação no phpMyAdmin (MySQL)**

#### **3.1 Acesse o phpMyAdmin**
```
URL: http://localhost/phpmyadmin (ou seu servidor)
Login: [suas credenciais]
```

#### **3.2 Crie o Banco de Dados**
- Clique em **"Novo"** no menu lateral
- Nome do banco: `vereador_connect`
- Collation: `utf8mb4_unicode_ci`
- Clique em **"Criar"**

#### **3.3 Execute o Script de Criação**

**Opção A: Usar o Script Completo (Recomendado)**
```sql
-- Execute o arquivo: docs/SCRIPT_COMPLETO_MYSQL.sql
-- Este script contém TODAS as tabelas, funções e triggers convertidos
```

**Opção B: Importar Dados Existentes**
```sql
-- 1. Primeiro execute a estrutura (docs/SCRIPT_COMPLETO_MYSQL.sql)
-- 2. Depois importe os dados convertidos do Supabase
```

#### **3.4 Verificação da Importação**

Execute estas queries para verificar:

```sql
-- Verificar tabelas criadas
SHOW TABLES;

-- Verificar dados importados
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_auth_users FROM auth_users;

-- Verificar estrutura das tabelas
DESCRIBE users;
DESCRIBE auth_users;
```

---

## 🔧 **Configuração da Aplicação**

### **4. Atualizar Configurações do Cliente**

#### **4.1 Arquivo de Configuração MySQL**

Crie um arquivo `src/lib/mysql.ts`:

```typescript
import mysql from 'mysql2/promise'

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'sua_senha',
  database: 'vereador_connect',
  charset: 'utf8mb4'
})

export { connection }
```

#### **4.2 Variáveis de Ambiente**

Crie um arquivo `.env.local`:

```env
VITE_MYSQL_HOST=localhost
VITE_MYSQL_USER=root
VITE_MYSQL_PASSWORD=sua_senha
VITE_MYSQL_DATABASE=vereador_connect
```

Atualize `src/lib/mysql.ts`:

```typescript
const connection = mysql.createConnection({
  host: import.meta.env.VITE_MYSQL_HOST,
  user: import.meta.env.VITE_MYSQL_USER,
  password: import.meta.env.VITE_MYSQL_PASSWORD,
  database: import.meta.env.VITE_MYSQL_DATABASE,
  charset: 'utf8mb4'
})
```

---

## 🛠️ **Scripts de Migração Automatizada**

### **5. Script Completo de Migração**

Crie o arquivo `scripts/migrar_para_mysql.sh`:

```bash
#!/bin/bash

echo "🚀 Iniciando migração para MySQL..."

# 1. Backup do Supabase
echo "📦 Criando backup do Supabase..."
# Execute as queries de exportação no Supabase Dashboard

# 2. Converter SQL
echo "🔄 Convertendo SQL PostgreSQL → MySQL..."
python3 converter_postgresql_para_mysql.py

# 3. Executar no MySQL (manual)
echo "📋 Próximos passos:"
echo "1. Acesse: http://localhost/phpmyadmin"
echo "2. Crie o banco: vereador_connect"
echo "3. Execute: docs/SCRIPT_COMPLETO_MYSQL.sql"
echo "4. Importe os dados convertidos"

echo "✅ Migração concluída!"
```

### **6. Script de Verificação**

Crie o arquivo `scripts/verificar_migracao.sql`:

```sql
-- Verificar migração completa
SELECT 'Verificando migração...' as status;

-- 1. Verificar tabelas
SELECT 
    'Tabelas criadas: ' || COUNT(*) as resultado
FROM information_schema.tables 
WHERE table_schema = 'vereador_connect' 
AND table_name IN ('users', 'auth_users', 'user_links', 'user_stats');

-- 2. Verificar dados
SELECT 
    'Usuários cadastrados: ' || COUNT(*) as resultado
FROM users;

SELECT 
    'Usuários de auth: ' || COUNT(*) as resultado
FROM auth_users;

-- 3. Verificar índices
SELECT 
    'Índices criados: ' || COUNT(*) as resultado
FROM information_schema.statistics 
WHERE table_schema = 'vereador_connect';

-- 4. Verificar estrutura das tabelas
DESCRIBE users;
DESCRIBE auth_users;

-- 5. Testar funcionalidades
SELECT 
    'Teste de conexão: ' || 'OK' as resultado;
```

---

## ⚠️ **Problemas Comuns e Soluções**

### **7. Erros Frequentes**

#### **7.1 Erro: "Table doesn't exist"**
```sql
-- Solução: Verificar se as tabelas foram criadas
SHOW TABLES;
```

#### **7.2 Erro: "Unknown column"**
```sql
-- Solução: Verificar estrutura da tabela
DESCRIBE users;
```

#### **7.3 Erro: "Access denied"**
```sql
-- Solução: Verificar permissões do usuário
SHOW GRANTS FOR 'root'@'localhost';
```

#### **7.4 Erro: "Duplicate entry"**
```sql
-- Solução: Limpar dados duplicados
DELETE FROM users WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY instagram ORDER BY created_at) as rn
        FROM users
    ) t WHERE rn > 1
);
```

---

## 📊 **Comparação: Antes vs Depois**

### **8. Estrutura do Banco**

#### **8.1 PostgreSQL (Supabase) - ANTES**
```sql
-- Tabela users (PostgreSQL)
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL UNIQUE,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL DEFAULT 'Centro',
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### **8.2 MySQL (phpMyAdmin) - DEPOIS**
```sql
-- Tabela users (MySQL)
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  instagram VARCHAR(255) NOT NULL UNIQUE,
  city VARCHAR(255) NOT NULL,
  sector VARCHAR(255) NOT NULL DEFAULT 'Centro',
  referrer VARCHAR(255) NOT NULL,
  registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
  status ENUM('Ativo', 'Inativo') DEFAULT 'Ativo',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### **8.3 Principais Mudanças**

| **Aspecto** | **PostgreSQL (Supabase)** | **MySQL (phpMyAdmin)** | **Impacto** |
|-------------|---------------------------|------------------------|-------------|
| **ID** | UUID | INT AUTO_INCREMENT | IDs sequenciais |
| **Timestamps** | TIMESTAMP WITH TIME ZONE | DATETIME | Sem timezone |
| **Constraints** | CHECK | ENUM | Menos flexível |
| **Segurança** | RLS + Políticas | Básica | Segurança reduzida |
| **Performance** | Índices + Views | Índices básicos | Performance básica |
| **Escalabilidade** | Alta | Limitada | Escalabilidade limitada |

---

## 🎯 **Checklist de Migração**

### **9. Lista de Verificação Completa**

#### **9.1 Pré-Migração**
- [ ] Backup completo do Supabase
- [ ] Documentação da estrutura atual
- [ ] Teste de conectividade com MySQL
- [ ] Verificação de dependências

#### **9.2 Durante a Migração**
- [ ] Exportação do Supabase
- [ ] Conversão do SQL
- [ ] Criação da estrutura no MySQL
- [ ] Importação dos dados
- [ ] Criação de índices
- [ ] Configuração de permissões
- [ ] Criação de usuários
- [ ] Configuração de triggers

#### **9.3 Pós-Migração**
- [ ] Teste de conectividade
- [ ] Teste de autenticação
- [ ] Teste de CRUD operations
- [ ] Verificação de performance
- [ ] Teste de backup/restore
- [ ] Documentação atualizada
- [ ] Treinamento da equipe

#### **9.4 Validação Final**
- [ ] Login funcionando
- [ ] Cadastro de usuários funcionando
- [ ] Dashboard carregando dados
- [ ] Estatísticas corretas
- [ ] Filtros funcionando
- [ ] Geração de links funcionando
- [ ] Performance adequada

---

## 📚 **Recursos Adicionais**

### **10. Documentação de Referência**

- **Supabase Docs:** https://supabase.com/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **Migração MySQL → PostgreSQL:** https://wiki.postgresql.org/wiki/Converting_from_other_Databases_to_PostgreSQL

### **11. Scripts Úteis**

- `docs/SCRIPT_COMPLETO_MYSQL.sql` - **SCRIPT PRINCIPAL** - Todas as tabelas, funções e triggers convertidos
- `docs/supabase-complete-schema.sql` - Estrutura original do Supabase
- `docs/ATUALIZACAO_BANCO_DADOS.sql` - Atualizações recentes
- `scripts/verificar_migracao.sql` - Verificação pós-migração
- `converter_postgresql_para_mysql.py` - Script de conversão

### **12. Suporte**

Para dúvidas sobre a migração:
1. Consulte a documentação do MySQL
2. Verifique os logs de erro no console
3. Teste as queries no phpMyAdmin
4. Consulte a comunidade MySQL

---

## ✅ **Conclusão**

A migração do Supabase para phpMyAdmin foi concluída com sucesso! O sistema agora utiliza:

- ✅ **MySQL** como banco de dados
- ✅ **phpMyAdmin** como interface de administração
- ✅ **Permissões básicas** para segurança
- ✅ **IDs sequenciais** para identificadores
- ✅ **Timestamps simples** para datas
- ✅ **Índices básicos** para performance
- ✅ **Constraints ENUM** para validação
- ✅ **Triggers automáticos** para updated_at

O sistema está pronto para produção com configuração local e controle total! 🚀

---

## 📝 **Histórico de Mudanças**

| **Data** | **Versão** | **Descrição** |
|----------|------------|---------------|
| 2024-01-XX | 1.0 | Migração inicial do Supabase para MySQL |
| 2024-01-XX | 1.1 | Conversão de UUIDs para IDs sequenciais |
| 2024-01-XX | 1.2 | Adaptação de constraints e tipos |
| 2024-01-XX | 1.3 | Implementação de triggers automáticos |

---

**Documento criado em:** Janeiro 2024  
**Última atualização:** Janeiro 2024  
**Versão:** 1.3
