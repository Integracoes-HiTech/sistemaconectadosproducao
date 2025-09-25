-- =====================================================
-- VERIFICAÇÃO DA TABELA MEMBERS
-- Execute este script no SQL Editor do Supabase
-- =====================================================

-- 1. Verificar se a tabela members existe
SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_name = 'members' 
AND table_schema = 'public';

-- 2. Verificar estrutura da tabela members
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'members' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Verificar se a tabela phase_control existe e tem dados
SELECT * FROM phase_control WHERE phase_name = 'members_registration';

-- 4. Verificar se a função can_register_member existe
SELECT 
  routine_name, 
  routine_type,
  data_type
FROM information_schema.routines 
WHERE routine_name = 'can_register_member' 
AND routine_schema = 'public';

-- 5. Testar a função can_register_member
SELECT can_register_member() as can_register;

-- 6. Verificar políticas RLS da tabela members
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'members';

-- 7. Verificar se RLS está habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'members';
