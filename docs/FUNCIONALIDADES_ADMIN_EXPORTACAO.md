# 🔧 Funcionalidades Administrativas e Exportação

## 🎯 **Funcionalidades Implementadas**

### **1. Remoção de Membros (Apenas Administradores)**

#### **✅ Funcionalidade:**
- Apenas administradores podem remover membros
- Botão "Remover" na tabela de membros
- Confirmação antes da remoção
- Feedback visual com toast

#### **🎨 Interface:**
```typescript
{isAdmin() && (
  <td className="py-3 px-4">
    <Button
      size="sm"
      variant="destructive"
      onClick={() => handleRemoveMember(member.id, member.name)}
      className="bg-red-600 hover:bg-red-700 text-white"
    >
      <UserIcon className="w-4 h-4 mr-1" />
      Remover
    </Button>
  </td>
)}
```

#### **🔒 Segurança:**
- Verificação de permissão antes da ação
- Confirmação obrigatória
- Mensagem de erro se não for administrador

### **2. Exportação de Relatórios**

#### **📊 Hook de Exportação Criado:**
**`src/hooks/useExportReports.ts`**

#### **✅ Funcionalidades Disponíveis:**

##### **📄 Exportação para PDF:**
- Converte elementos HTML para PDF
- Suporte a múltiplas páginas
- Qualidade alta (scale: 2)
- Fundo branco

##### **📈 Exportação para Excel:**
- Dados estruturados em planilhas
- Múltiplas abas
- Formatação automática
- Nomes de arquivo personalizáveis

#### **🎯 Tipos de Exportação:**

##### **👥 Membros para Excel:**
```typescript
const exportMembersToExcel = (members) => {
  const data = members.map(member => ({
    'Posição': member.ranking_position,
    'Nome': member.name,
    'Cônjuge': member.couple_name,
    'WhatsApp': member.phone,
    'Instagram': member.instagram,
    'Cidade': member.city,
    'Setor': member.sector,
    'Contratos Completos': member.contracts_completed,
    'Status': member.ranking_status,
    'Indicado por': member.referrer,
    'Data de Cadastro': new Date(member.registration_date).toLocaleDateString('pt-BR'),
    'Top 1500': member.is_top_1500 ? 'Sim' : 'Não'
  }))
  
  exportToExcel(data, 'membros.xlsx', 'Membros')
}
```

##### **📋 Contratos Pagos para Excel:**
```typescript
const exportContractsToExcel = (contracts) => {
  const data = contracts.map(contract => ({
    'ID': contract.id,
    'Membro Responsável': contract.member_data?.name,
    'Casal 1': contract.couple_name_1,
    'Casal 2': contract.couple_name_2,
    'WhatsApp 1': contract.couple_phone_1,
    'WhatsApp 2': contract.couple_phone_2,
    'Instagram 1': contract.couple_instagram_1,
    'Instagram 2': contract.couple_instagram_2,
    'Status': contract.contract_status,
    'Data do Contrato': new Date(contract.contract_date).toLocaleDateString('pt-BR'),
    'Data de Conclusão': contract.completion_date ? new Date(contract.completion_date).toLocaleDateString('pt-BR') : 'N/A',
    'Post Verificado 1': contract.post_verified_1 ? 'Sim' : 'Não',
    'Post Verificado 2': contract.post_verified_2 ? 'Sim' : 'Não'
  }))
  
  exportToExcel(data, 'contratos_pagos.xlsx', 'Contratos Pagos')
}
```

##### **📊 Estatísticas para Excel:**
```typescript
const exportStatsToExcel = (stats) => {
  const data = [
    { 'Métrica': 'Total de Membros', 'Valor': stats.total_members },
    { 'Métrica': 'Membros Verdes', 'Valor': stats.green_members },
    { 'Métrica': 'Membros Amarelos', 'Valor': stats.yellow_members },
    { 'Métrica': 'Membros Vermelhos', 'Valor': stats.red_members },
    { 'Métrica': 'Top 1500', 'Valor': stats.top_1500_members },
    { 'Métrica': 'Contagem Atual', 'Valor': stats.current_member_count },
    { 'Métrica': 'Limite Máximo', 'Valor': stats.max_member_limit }
  ]
  
  exportToExcel(data, 'estatisticas.xlsx', 'Estatísticas')
}
```

### **3. Botões de Exportação no Dashboard**

#### **📋 Ranking de Membros:**
- ✅ **Exportar Excel** - Dados completos dos membros
- ✅ **Exportar PDF** - Tabela visual em PDF

#### **📊 Resumo do Sistema:**
- ✅ **Exportar Estatísticas Excel** - Métricas do sistema

#### **🎨 Interface dos Botões:**
```typescript
{isAdmin() && (
  <div className="flex gap-2 mt-4">
    <Button
      size="sm"
      onClick={() => exportMembersToExcel(filteredMembers)}
      className="bg-green-600 hover:bg-green-700 text-white"
    >
      <BarChart3 className="w-4 h-4 mr-2" />
      Exportar Excel
    </Button>
    <Button
      size="sm"
      onClick={() => exportToPDF('members-table', 'ranking_membros.pdf')}
      className="bg-red-600 hover:bg-red-700 text-white"
    >
      <BarChart3 className="w-4 h-4 mr-2" />
      Exportar PDF
    </Button>
  </div>
)}
```

## 🔧 **Dependências Instaladas**

```bash
npm install jspdf html2canvas xlsx
```

- **jsPDF**: Geração de PDFs
- **html2canvas**: Conversão de HTML para canvas
- **xlsx**: Manipulação de planilhas Excel

## 🎯 **Funcionalidades por Tipo de Usuário**

### **👑 Administradores:**
- ✅ **Remover membros** - Botão na tabela
- ✅ **Exportar Excel** - Membros, contratos, estatísticas
- ✅ **Exportar PDF** - Tabelas visuais
- ✅ **Acesso completo** - Todos os relatórios

### **👤 Membros:**
- ❌ **Não podem remover** - Apenas visualizar
- ❌ **Não podem exportar** - Apenas visualizar
- ✅ **Acesso limitado** - Apenas informações pessoais

## 📋 **Arquivos Criados/Modificados**

### **Novos Arquivos:**
- **`src/hooks/useExportReports.ts`** - Hook para exportação

### **Arquivos Modificados:**
- **`src/pages/dashboard.tsx`** - Botões de remoção e exportação

## 🎉 **Status da Implementação**

- ✅ Funcionalidade de remoção implementada
- ✅ Hook de exportação criado
- ✅ Botões de exportação adicionados
- ✅ Controle de acesso baseado em role
- ✅ Dependências instaladas
- ✅ Interface responsiva mantida

## 🚀 **Como Usar**

### **Para Remover um Membro:**
1. Faça login como administrador
2. Vá para a tabela de membros
3. Clique no botão "Remover" na linha do membro
4. Confirme a remoção

### **Para Exportar Relatórios:**
1. Faça login como administrador
2. Vá para a seção desejada (Ranking ou Resumo)
3. Clique no botão de exportação (Excel ou PDF)
4. O arquivo será baixado automaticamente

**Todas as funcionalidades administrativas e de exportação estão implementadas!** 🎉
