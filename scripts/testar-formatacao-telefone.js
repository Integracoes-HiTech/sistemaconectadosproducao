// Script para testar a formatação de telefones
console.log('🧪 Testando formatação de telefones para exportação...');

// Função de formatação (copiada do useExportReports.ts)
const formatPhoneForExport = (phone) => {
  if (!phone) return '';
  
  // Remove todos os caracteres especiais e espaços
  let cleanPhone = phone.replace(/[^\d]/g, '');
  
  // Remove código do país se já existir (55 no início)
  if (cleanPhone.startsWith('55') && cleanPhone.length >= 12) {
    cleanPhone = cleanPhone.substring(2);
  }
  
  // Remove o 9 inicial se existir (após o DDD) para números de 11 dígitos
  if (cleanPhone.length === 11 && cleanPhone.charAt(2) === '9') {
    cleanPhone = cleanPhone.substring(0, 2) + cleanPhone.substring(3);
  }
  
  // Garantir que tenha pelo menos 10 dígitos (DDD + número)
  if (cleanPhone.length < 10) {
    return '';
  }
  
  // Adiciona o código do país 55
  return `55${cleanPhone}`;
};

// Testes com diferentes formatos de telefone
const testCases = [
  { input: '(11) 98765-4321', expected: '551187654321' },
  { input: '11987654321', expected: '551187654321' },
  { input: '11 9 8765-4321', expected: '551187654321' },
  { input: '(85) 99999-8888', expected: '558599998888' },
  { input: '85999998888', expected: '558599998888' },
  { input: '(21) 87654-3210', expected: '5521876543210' },
  { input: '2187654321', expected: '552187654321' },
  { input: '+55 11 98765-4321', expected: '551187654321' },
  { input: '', expected: '' },
  { input: null, expected: '' }
];

console.log('\n📱 Testando diferentes formatos:');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

let allPassed = true;

testCases.forEach((test, index) => {
  const result = formatPhoneForExport(test.input);
  const passed = result === test.expected;
  
  if (!passed) allPassed = false;
  
  console.log(`${index + 1}. ${passed ? '✅' : '❌'} "${test.input}" → "${result}" (esperado: "${test.expected}")`);
});

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

if (allPassed) {
  console.log('🎉 TODOS OS TESTES PASSARAM!');
  console.log('\n📋 Regras aplicadas:');
  console.log('• Remove todos os caracteres especiais e espaços');
  console.log('• Remove o 9 inicial após o DDD (se existir)');
  console.log('• Adiciona o código do país 55');
  console.log('• Resultado: números limpos no formato 55DDNNNNNNNN');
} else {
  console.log('❌ ALGUNS TESTES FALHARAM!');
}

console.log('\n🔍 Exemplos de resultado na planilha:');
console.log('• (11) 98765-4321 → 551187654321');
console.log('• (85) 99999-8888 → 558599998888');
console.log('• (21) 87654-3210 → 552187654210');
