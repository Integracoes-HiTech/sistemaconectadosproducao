# 🔍 Filtro por Indicador - Dashboard Admin

## 🎯 **Funcionalidade Implementada:**
Sistema de filtro por indicador que permite ao administrador visualizar dados específicos de usuários indicados por uma pessoa específica.

## 🔧 **Implementação Técnica:**

### **1. Estado de Controle:**
```typescript
const [selectedReferrerFilter, setSelectedReferrerFilter] = useState<string>("");
```

### **2. Lógica de Filtro:**
```typescript
// Se um indicador específico foi selecionado, usar esse filtro
const referrerFilter = selectedReferrerFilter 
  ? selectedReferrerFilter 
  : (isAdmin() ? undefined : user?.full_name);
```

### **3. Lista de Indicadores Únicos:**
```typescript
const getUniqueReferrers = () => {
  const referrers = allUsers.map(user => user.referrer).filter(Boolean);
  return Array.from(new Set(referrers)).sort();
};
```

## 🎨 **Interface Implementada:**

### **Seletor de Indicador (Apenas Admin):**
```jsx
{isAdmin() && (
  <div className="bg-white shadow-[var(--shadow-card)] rounded-lg p-6 mb-8">
    <div className="flex items-center justify-between mb-4">
      <h3 className="text-lg font-semibold text-institutional-blue">
        Filtro por Indicador
      </h3>
      {selectedReferrerFilter && (
        <Button onClick={clearReferrerFilter}>
          Limpar Filtro
        </Button>
      )}
    </div>
    
    <select
      value={selectedReferrerFilter}
      onChange={(e) => setSelectedReferrerFilter(e.target.value)}
    >
      <option value="">Todos os Indicadores</option>
      {uniqueReferrers.map((referrer) => (
        <option key={referrer} value={referrer}>
          {referrer}
        </option>
      ))}
    </select>
  </div>
)}
```

## 📊 **Dados Filtrados:**

### **1. Tabela de Usuários:**
- **Sem filtro:** Todos os usuários do sistema
- **Com filtro:** Apenas usuários indicados pelo selecionado

### **2. Gráficos e Estatísticas:**
- **Gráfico de Localização:** Dados filtrados por indicador
- **Gráfico de Cadastros:** Dados filtrados por indicador
- **Cards de Resumo:** Estatísticas filtradas por indicador

### **3. Títulos Dinâmicos:**
```typescript
// Título da tabela
{selectedReferrerFilter 
  ? `Usuários Indicados por ${selectedReferrerFilter}`
  : isAdmin() 
    ? 'Todos os Usuários do Sistema' 
    : 'Meus Usuários Cadastrados'
}

// Descrição dos gráficos
{selectedReferrerFilter 
  ? `Distribuição por cidade e bairro - Usuários de ${selectedReferrerFilter}`
  : isAdmin() 
    ? 'Distribuição por cidade e bairro - Todos os usuários' 
    : 'Distribuição dos seus usuários por localização'
}
```

## 🔒 **Permissões:**

### **Admin:**
- ✅ **Pode usar filtro:** Acesso total ao seletor de indicadores
- ✅ **Vê todos os dados:** Com ou sem filtro aplicado
- ✅ **Pode limpar filtro:** Botão para voltar à visão completa

### **Outros Roles:**
- ❌ **Não veem o filtro:** Interface não aparece
- ❌ **Dados limitados:** Apenas seus próprios usuários
- ✅ **Funcionalidade normal:** Dashboard funciona normalmente

## 🎯 **Casos de Uso:**

### **1. Análise por Indicador:**
```
Admin seleciona "João Silva - Coordenador"
→ Vê apenas usuários indicados pelo João
→ Gráficos mostram dados específicos do João
→ Estatísticas refletem performance do João
```

### **2. Comparação de Performance:**
```
Admin pode alternar entre diferentes indicadores
→ Comparar resultados de diferentes pessoas
→ Identificar top performers
→ Analisar distribuição geográfica por indicador
```

### **3. Auditoria e Controle:**
```
Admin pode verificar usuários de um indicador específico
→ Validar cadastros
→ Verificar qualidade dos dados
→ Monitorar atividade por pessoa
```

## 🔄 **Fluxo de Funcionamento:**

### **1. Carregamento Inicial:**
```
1. Dashboard carrega todos os usuários
2. Lista de indicadores únicos é gerada
3. Seletor é populado com opções
4. Dados são exibidos sem filtro
```

### **2. Aplicação de Filtro:**
```
1. Admin seleciona um indicador
2. selectedReferrerFilter é atualizado
3. referrerFilter é recalculado
4. Hooks refazem consultas com filtro
5. Interface atualiza com dados filtrados
```

### **3. Limpeza de Filtro:**
```
1. Admin clica em "Limpar Filtro"
2. selectedReferrerFilter volta para ""
3. referrerFilter volta para undefined
4. Dados completos são recarregados
5. Interface volta ao estado inicial
```

## 📈 **Benefícios:**

1. **Análise Granular:** Dados específicos por indicador
2. **Performance Tracking:** Acompanhar resultados individuais
3. **Auditoria:** Verificar qualidade dos cadastros
4. **Comparação:** Analisar diferentes indicadores
5. **Controle:** Monitorar atividade por pessoa

## 🧪 **Como Testar:**

1. **Login como Admin**
2. **Verificar seletor:** Deve aparecer "Filtro por Indicador"
3. **Selecionar indicador:** Escolher um da lista
4. **Verificar filtros:** Tabela e gráficos devem mostrar apenas dados do indicador
5. **Limpar filtro:** Clicar em "Limpar Filtro"
6. **Verificar volta:** Dados devem voltar ao estado completo

**Filtro por indicador implementado com sucesso!** 🎯
