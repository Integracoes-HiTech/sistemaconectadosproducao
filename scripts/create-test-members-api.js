// Script para criar membros de teste via API

const API_BASE = 'http://localhost:3001';

async function createTestMembers() {
  try {
    console.log('🎯 Criando membros de teste via API...');

    // Criar 5 membros de teste
    for (let i = 1; i <= 5; i++) {
      const memberData = {
        name: `Membro Teste ${i}`,
        phone: `1199999${String(i).padStart(4, '0')}`,
        instagram: `@membro_teste_${i}`,
        city: 'São Paulo',
        sector: 'Teste',
        referrer: 'Admin',
        registration_date: new Date().toISOString().split('T')[0],
        status: 'Ativo',
        couple_name: `Dupla Teste ${i}`,
        couple_phone: `1198888${String(i).padStart(4, '0')}`,
        couple_instagram: `@dupla_teste_${i}`,
        couple_city: 'São Paulo',
        couple_sector: 'Teste'
      };

      const response = await fetch(`${API_BASE}/api/members`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(memberData)
      });

      const result = await response.json();

      if (result.success) {
        console.log(`✅ Membro ${i} criado com sucesso!`);
      } else {
        console.log(`❌ Erro ao criar membro ${i}:`, result.error);
      }
    }

    // Verificar contagem final
    const countResponse = await fetch(`${API_BASE}/api/stats`);
    const countResult = await countResponse.json();
    
    if (countResult.success) {
      console.log(`🎉 Total de membros após criação: ${countResult.stats.total_members}`);
    }

    // Testar status da fase
    const settingsResponse = await fetch(`${API_BASE}/api/system-settings`);
    const settingsResult = await settingsResponse.json();
    
    if (settingsResult.success) {
      console.log('\n📋 Status da fase:');
      console.log(`   Membros: ${settingsResult.phase_status.member_count}/${settingsResult.phase_status.max_members}`);
      console.log(`   Status: ${settingsResult.phase_status.message} (${settingsResult.phase_status.percentage}%)`);
      console.log(`   Deve ativar fase: ${settingsResult.phase_status.should_activate_phase ? 'Sim' : 'Não'}`);
    }

  } catch (error) {
    console.error('❌ Erro durante a criação dos membros:', error);
  }
}

createTestMembers().catch(console.error);
