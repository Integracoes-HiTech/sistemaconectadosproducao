# 🔍 Filtros por Cidade e Setor Implementados

## ✅ **Implementação Concluída**

Agora a tabela de usuários no dashboard tem **filtros por Cidade e Setor**, facilitando a visualização e busca de dados específicos.

## 🔧 **Mudanças Implementadas**

### **1. Estados de Filtro Adicionados:**
```typescript
const [filterCity, setFilterCity] = useState("");
const [filterSector, setFilterSector] = useState("");
```

### **2. Lógica de Filtro Atualizada:**
```typescript
const matchesCity = filterCity === "" || member.city.toLowerCase().includes(filterCity.toLowerCase());

const matchesSector = filterSector === "" || member.sector.toLowerCase().includes(filterSector.toLowerCase());

return matchesSearch && matchesStatus && matchesDate && matchesReferrer && matchesCity && matchesSector;
```

### **3. Interface de Filtros Atualizada:**
```typescript
{/* Filtro por Cidade */}
<div className="relative">
  <MapPin className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
  <Input
    type="text"
    placeholder="Filtrar por cidade..."
    value={filterCity}
    onChange={(e) => setFilterCity(e.target.value)}
    className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
  />
</div>

{/* Filtro por Setor */}
<div className="relative">
  <Building className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
  <Input
    type="text"
    placeholder="Filtrar por setor..."
    value={filterSector}
    onChange={(e) => setFilterSector(e.target.value)}
    className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
  />
</div>
```

## 🎯 **Filtros Disponíveis**

### **Filtros Existentes:**
- ✅ **Busca Geral**: Nome, telefone, Instagram
- ✅ **Status**: Ativo/Inativo
- ✅ **Data**: Data de cadastro
- ✅ **Indicador**: Pessoa que indicou

### **Novos Filtros:**
- ✅ **Cidade**: Filtro por cidade do membro
- ✅ **Setor**: Filtro por setor do membro

## 🔍 **Como Funcionam os Filtros**

### **Filtro por Cidade:**
- **Campo**: `member.city`
- **Funcionamento**: Busca parcial (case-insensitive)
- **Exemplo**: Digite "Goiânia" para encontrar todos os membros de Goiânia
- **Ícone**: MapPin

### **Filtro por Setor:**
- **Campo**: `member.sector`
- **Funcionamento**: Busca parcial (case-insensitive)
- **Exemplo**: Digite "Central" para encontrar todos os membros do Setor Central
- **Ícone**: Building

### **Combinação de Filtros:**
- **Todos os filtros funcionam em conjunto**
- **Filtros são aplicados simultaneamente**
- **Resultado**: Membros que atendem a TODOS os critérios selecionados

## 🎨 **Interface dos Filtros**

### **Layout Responsivo:**
```typescript
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-6">
  {/* Busca Geral */}
  <div className="relative">
    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
    <Input
      type="text"
      placeholder="Buscar membros..."
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
    />
  </div>

  {/* Filtro por Indicador */}
  <div className="relative">
    <UserCheck className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
    <Input
      type="text"
      placeholder="Filtrar por indicador..."
      value={filterReferrer}
      onChange={(e) => setFilterReferrer(e.target.value)}
      className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
    />
  </div>

  {/* Filtro por Data */}
  <div className="relative">
    <CalendarDays className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
    <Input
      type="date"
      placeholder="Filtrar por data..."
      value={filterDate}
      onChange={(e) => setFilterDate(e.target.value)}
      className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
    />
  </div>

  {/* Filtro por Cidade */}
  <div className="relative">
    <MapPin className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
    <Input
      type="text"
      placeholder="Filtrar por cidade..."
      value={filterCity}
      onChange={(e) => setFilterCity(e.target.value)}
      className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
    />
  </div>

  {/* Filtro por Setor */}
  <div className="relative">
    <Building className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
    <Input
      type="text"
      placeholder="Filtrar por setor..."
      value={filterSector}
      onChange={(e) => setFilterSector(e.target.value)}
      className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
    />
  </div>

  {/* Filtro por Status */}
  <div className="relative">
    <Users className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
    <select
      value={filterStatus}
      onChange={(e) => setFilterStatus(e.target.value)}
      className="pl-10 w-full h-10 border border-institutional-light rounded-md focus:border-institutional-gold focus:ring-institutional-gold"
    >
      <option value="">Todos os status</option>
      <option value="Ativo">Ativo</option>
      <option value="Inativo">Inativo</option>
    </select>
  </div>
</div>
```

## 🚀 **Como Usar os Filtros**

### **1. Filtro por Cidade:**
- Digite o nome da cidade (ex: "Goiânia")
- O sistema buscará todos os membros dessa cidade
- Busca é parcial, então "Goi" encontrará "Goiânia"

### **2. Filtro por Setor:**
- Digite o nome do setor (ex: "Central")
- O sistema buscará todos os membros desse setor
- Busca é parcial, então "Cent" encontrará "Central"

### **3. Combinação de Filtros:**
- Use múltiplos filtros simultaneamente
- Exemplo: Cidade "Goiânia" + Setor "Central" = Membros de Goiânia do Setor Central
- Todos os filtros são aplicados em conjunto

## 📊 **Exemplos de Uso**

### **Cenário 1: Buscar Membros de Goiânia**
1. Digite "Goiânia" no filtro de cidade
2. Resultado: Todos os membros de Goiânia

### **Cenário 2: Buscar Membros do Setor Central**
1. Digite "Central" no filtro de setor
2. Resultado: Todos os membros do Setor Central

### **Cenário 3: Buscar Membros de Goiânia do Setor Central**
1. Digite "Goiânia" no filtro de cidade
2. Digite "Central" no filtro de setor
3. Resultado: Membros de Goiânia do Setor Central

### **Cenário 4: Buscar Membros Ativos de Goiânia**
1. Digite "Goiânia" no filtro de cidade
2. Selecione "Ativo" no filtro de status
3. Resultado: Membros ativos de Goiânia

## 📋 **Arquivos Modificados**

- **`src/pages/dashboard.tsx`** - Filtros de cidade e setor adicionados

## 🎯 **Benefícios**

- ✅ **Busca Específica**: Encontre membros por localização geográfica
- ✅ **Organização**: Filtre por setores para análise regional
- ✅ **Eficiência**: Combine múltiplos filtros para busca precisa
- ✅ **Interface Intuitiva**: Ícones visuais para cada tipo de filtro
- ✅ **Responsivo**: Layout adaptável para diferentes tamanhos de tela

## 🔍 **Funcionalidades dos Filtros**

### **Busca Parcial:**
- Digite parte do nome da cidade/setor
- Sistema encontra correspondências parciais
- Case-insensitive (não diferencia maiúsculas/minúsculas)

### **Filtros Combinados:**
- Todos os filtros funcionam simultaneamente
- Resultado mostra membros que atendem a TODOS os critérios
- Filtros são aplicados em tempo real

### **Interface Consistente:**
- Mesmo estilo visual dos outros filtros
- Ícones apropriados (MapPin para cidade, Building para setor)
- Placeholders informativos

**Agora você pode filtrar membros por cidade e setor na tabela do dashboard!** 🔍
