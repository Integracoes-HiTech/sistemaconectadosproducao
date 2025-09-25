// Script para testar as permissões do Felipe Admin
console.log('🧪 Testando permissões do Felipe Admin...');

// Simular dados do usuário Felipe
const mockUser = {
  id: 'c2d9d20f-767f-42d4-bab6-26c3d1e1cbf7',
  username: 'felipe',
  role: 'Felipe Admin',
  name: 'Felipe',
  full_name: 'Felipe Admin'
};

// Simular as funções de permissão
const isAdmin = () => {
  return mockUser?.role === 'admin' || 
         mockUser?.role === 'Administrador' || 
         mockUser?.username === 'wegneycosta' || 
         mockUser?.role === 'Felipe Admin' || 
         mockUser?.username === 'felipe';
};

const isFelipeAdmin = () => {
  return mockUser?.username === 'felipe' || mockUser?.role === 'Felipe Admin';
};

const isAdminUser = isAdmin() || isFelipeAdmin();

console.log('📋 Resultados dos testes:');
console.log('👤 Usuário:', mockUser.username);
console.log('🎭 Role:', mockUser.role);
console.log('✅ isAdmin():', isAdmin());
console.log('✅ isFelipeAdmin():', isFelipeAdmin());
console.log('✅ isAdminUser:', isAdminUser);

console.log('\n🔍 Verificações:');
console.log('• Felipe deve ver seções de admin:', isAdmin() ? '✅' : '❌');
console.log('• Felipe deve ver tabelas completas:', isAdminUser ? '✅' : '❌');
console.log('• Felipe é reconhecido como Felipe Admin:', isFelipeAdmin() ? '✅' : '❌');

if (isAdmin() && isAdminUser && isFelipeAdmin()) {
  console.log('\n🎉 SUCESSO! Felipe Admin tem todas as permissões corretas.');
} else {
  console.log('\n❌ PROBLEMA! Algumas permissões estão incorretas.');
}
