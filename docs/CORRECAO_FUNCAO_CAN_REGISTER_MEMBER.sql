-- =====================================================
-- CORREÇÃO DA FUNÇÃO can_register_member
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- Corrigir a função can_register_member para resolver ambiguidade de colunas
CREATE OR REPLACE FUNCTION can_register_member()
RETURNS BOOLEAN AS $$
DECLARE
  current_member_count INTEGER;
  max_member_limit INTEGER;
BEGIN
  SELECT pc.current_count, pc.max_limit 
  INTO current_member_count, max_member_limit
  FROM phase_control pc
  WHERE pc.phase_name = 'members_registration';
  
  RETURN current_member_count < max_member_limit;
END;
$$ LANGUAGE plpgsql;

-- Testar a função
SELECT can_register_member() as can_register;

-- Verificar dados da tabela phase_control
SELECT * FROM phase_control WHERE phase_name = 'members_registration';
