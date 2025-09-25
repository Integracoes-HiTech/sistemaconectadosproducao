-- SQL para adicionar campo deleted_at nas tabelas members e friends
-- Este script implementa soft delete para permitir exclusão lógica dos registros
-- Compatível com MySQL 5.7+ e MySQL 8.0+

-- Adicionar campo deleted_at na tabela members
ALTER TABLE members 
ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL 
COMMENT 'Data e hora da exclusão lógica (soft delete)';

-- Adicionar campo deleted_at na tabela friends  
ALTER TABLE friends 
ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL 
COMMENT 'Data e hora da exclusão lógica (soft delete)';

-- Criar índices para melhorar performance das consultas com deleted_at
CREATE INDEX idx_members_deleted_at ON members(deleted_at);
CREATE INDEX idx_friends_deleted_at ON friends(deleted_at);

-- Verificar se as colunas foram criadas corretamente
SHOW COLUMNS FROM members LIKE 'deleted_at';
SHOW COLUMNS FROM friends LIKE 'deleted_at';

-- Mostrar alguns registros para verificar (apenas registros não deletados)
SELECT id, name, deleted_at FROM members WHERE deleted_at IS NULL LIMIT 5;
SELECT id, name, deleted_at FROM friends WHERE deleted_at IS NULL LIMIT 5;

-- Verificar estrutura completa das tabelas
DESCRIBE members;
DESCRIBE friends;
