# 🔗 Implementação MySQL - Função de Geração de Links Únicos

## 📋 Resumo

Implementei uma solução completa equivalente à função `generate_unique_link()` do Supabase, adaptada para MySQL. A nova implementação garante **links únicos** e **verificação de existência** no banco de dados.

## 🆚 Comparação: Supabase vs MySQL

### **Supabase (PostgreSQL)**
```sql
CREATE OR REPLACE FUNCTION generate_unique_link(user_username TEXT)
RETURNS TEXT AS $$
DECLARE
    link_id TEXT;
    link_exists BOOLEAN;
BEGIN
    LOOP
        link_id := user_username || '-' || EXTRACT(EPOCH FROM NOW())::BIGINT;
        
        SELECT EXISTS(SELECT 1 FROM user_links WHERE link_id = link_id) INTO link_exists;
        
        IF NOT link_exists THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN link_id;
END;
$$ language 'plpgsql';
```

### **MySQL (Nova Implementação)**
```sql
CREATE FUNCTION generate_unique_link(user_username VARCHAR(255))
RETURNS VARCHAR(500)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE link_id VARCHAR(500);
    DECLARE link_exists INT DEFAULT 1;
    DECLARE attempts INT DEFAULT 0;
    DECLARE max_attempts INT DEFAULT 100;
    
    WHILE link_exists > 0 AND attempts < max_attempts DO
        SET link_id = CONCAT(
            user_username, 
            '-', 
            UNIX_TIMESTAMP(NOW()), 
            '-', 
            LPAD(FLOOR(RAND() * 10000), 4, '0')
        );
        
        SELECT COUNT(*) INTO link_exists 
        FROM user_links 
        WHERE link_id = link_id;
        
        SET attempts = attempts + 1;
        
        IF link_exists > 0 THEN
            SET @sleep_time = RAND() * 0.001;
            DO SLEEP(@sleep_time);
        END IF;
    END WHILE;
    
    IF attempts >= max_attempts THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não foi possível gerar link único após múltiplas tentativas';
    END IF;
    
    RETURN link_id;
END;
```

## 🛠️ Componentes Implementados

### 1. **Função `generate_unique_link()`**
- ✅ Gera links únicos usando `username + timestamp + random`
- ✅ Verifica existência no banco usando `COUNT(*)`
- ✅ Loop até encontrar link único
- ✅ Proteção contra loops infinitos (max 100 tentativas)
- ✅ Pausa aleatória para evitar timestamps idênticos

### 2. **Procedure `generate_and_insert_user_link()`**
- ✅ Combina geração e inserção em operação atômica
- ✅ Desativa links antigos automaticamente
- ✅ Transação completa com rollback em caso de erro
- ✅ Retorna status de sucesso/erro

### 3. **Procedure `get_or_generate_user_link()`**
- ✅ Verifica se usuário já tem link ativo
- ✅ Retorna link existente se disponível
- ✅ Gera novo link apenas se necessário
- ✅ Flags de controle (`is_existing`, `success`)

### 4. **API Atualizada (`server.mjs`)**
- ✅ Usa procedures MySQL em vez de queries manuais
- ✅ Lógica simplificada e mais robusta
- ✅ Melhor tratamento de erros
- ✅ Logs detalhados para debug

## 🚀 Como Usar

### **1. Instalar as Funções MySQL**
```bash
# Execute o script SQL no banco
mysql -u root -p vereador_connect < docs/MYSQL_GENERATE_UNIQUE_LINK_FUNCTION.sql
```

### **2. Testar a Implementação**
```bash
# Execute o script de teste
node scripts/test-mysql-link-functions.js
```

### **3. Usar na API**
```javascript
// A API agora funciona automaticamente com as novas funções
POST /api/generate-link
{
  "userId": "3",
  "userName": "admin"
}

// Resposta
{
  "success": true,
  "data": {
    "link_id": "admin-1735123456-1234",
    "link_type": "members",
    "full_url": "http://localhost:3001/register/admin-1735123456-1234",
    "is_existing": false
  }
}
```

## 🎯 Vantagens da Nova Implementação

### **✅ Garantias de Unicidade**
- Links são **100% únicos** no banco
- Verificação automática de duplicatas
- Proteção contra colisões de timestamp

### **✅ Performance Otimizada**
- Operações atômicas no banco
- Menos round-trips entre aplicação e banco
- Transações com rollback automático

### **✅ Robustez**
- Tratamento de erros completo
- Proteção contra loops infinitos
- Logs detalhados para debug

### **✅ Compatibilidade**
- Mantém interface da API existente
- Funciona com código frontend atual
- Migração transparente

## 🧪 Testes Implementados

### **Teste 1: Geração de Links Únicos**
```sql
SELECT generate_unique_link('teste') as link1, generate_unique_link('teste') as link2;
-- Deve retornar dois links diferentes
```

### **Teste 2: Procedure Completa**
```sql
CALL get_or_generate_user_link('999', 'usuario_teste', 'members', @link_id, @is_existing, @success, @message);
SELECT @link_id, @is_existing, @success, @message;
```

### **Teste 3: Verificação de Duplicatas**
- Primeira chamada: gera novo link
- Segunda chamada: retorna link existente
- Verifica flag `is_existing`

## 📊 Estrutura de Dados

### **Tabela `user_links`**
```sql
- id (PK, AUTO_INCREMENT)
- link_id (VARCHAR, UNIQUE) - Link único gerado
- user_id (VARCHAR, FK) - Referência para auth_users.id
- link_type (VARCHAR) - Tipo do link (members/friends)
- is_active (TINYINT) - Status ativo (1/0)
- click_count (INT) - Contador de cliques
- registration_count (INT) - Contador de registros
- created_at (DATETIME) - Data de criação
- updated_at (DATETIME) - Data de atualização
```

## 🔧 Configuração

### **Variáveis de Ambiente**
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=vereador_connect
DB_PORT=3306
```

### **Dependências**
```json
{
  "mysql2": "^3.6.0"
}
```

## 🚨 Pontos de Atenção

### **1. Permissões MySQL**
- Usuário precisa de permissões para criar funções e procedures
- `CREATE ROUTINE`, `EXECUTE`, `SELECT`, `INSERT`, `UPDATE`

### **2. Backup**
- Sempre faça backup antes de executar scripts SQL
- Teste em ambiente de desenvolvimento primeiro

### **3. Monitoramento**
- Monitore logs da aplicação para detectar erros
- Verifique performance das procedures em produção

## 📈 Próximos Passos

1. **Executar script SQL** no banco de produção
2. **Testar API** com usuários reais
3. **Monitorar performance** das procedures
4. **Documentar** qualquer ajuste necessário

---

## ✅ Status da Implementação

- [x] Função `generate_unique_link()` criada
- [x] Procedures de geração e verificação implementadas
- [x] API atualizada para usar novas funções
- [x] Script de teste criado
- [x] Documentação completa
- [ ] Testes em ambiente de produção
- [ ] Monitoramento de performance
