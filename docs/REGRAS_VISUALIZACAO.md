# 👥 Regras de Visualização por Cargo

## 🎯 **Hierarquia de Cargos:**

### **1️⃣ Admin/Administrador**
- ✅ **Pode ver:** Todos os usuários
- ✅ **Pode ver:** Todas as estatísticas
- ✅ **Pode gerar:** Links
- ✅ **Acesso total:** Sistema completo

### **2️⃣ Vereador**
- ✅ **Pode ver:** Todos os usuários
- ✅ **Pode ver:** Todas as estatísticas
- ✅ **Pode gerar:** Links
- ✅ **Acesso:** Quase total

### **3️⃣ Coordenador**
- ✅ **Pode ver:** Todos os usuários
- ✅ **Pode ver:** Todas as estatísticas
- ✅ **Pode gerar:** Links
- ✅ **Acesso:** Gerencial

### **4️⃣ Colaborador**
- ❌ **Pode ver:** Apenas seus próprios usuários
- ❌ **Pode ver:** Apenas suas estatísticas
- ✅ **Pode gerar:** Links
- ✅ **Acesso:** Limitado

## 🔧 **Implementação:**

### **Funções de Permissão:**
```typescript
// Verificar cargo específico
isAdmin()        // Admin ou wegneycosta
isCoordenador()  // Coordenador ou superior
isColaborador()  // Colaborador ou superior
isVereador()     // Vereador ou superior

// Verificar permissões
canViewAllUsers()   // Admin, Coordenador, Vereador
canViewStats()      // Admin, Coordenador, Vereador
canGenerateLinks()  // Todos os cargos
```

### **Filtros Aplicados:**
- **Admin/Coordenador/Vereador:** Veem todos os usuários
- **Colaborador:** Veem apenas seus próprios usuários

## 📊 **Exemplo Prático:**

### **João (Coordenador):**
- ✅ Vê todos os usuários cadastrados
- ✅ Vê estatísticas gerais
- ✅ Pode gerar links
- ✅ Nome e cargo aparecem no cabeçalho

### **Maria (Colaboradora):**
- ❌ Vê apenas usuários que ela cadastrou
- ❌ Vê apenas suas estatísticas
- ✅ Pode gerar links
- ✅ Nome e cargo aparecem no cabeçalho

## 🎨 **Interface Atualizada:**

### **Cabeçalho:**
```
Bem-vindo, João Silva
Coordenador
```

### **Dashboard:**
- **Admin/Coordenador/Vereador:** Tabela completa
- **Colaborador:** Tabela filtrada

## ✅ **Status da Implementação:**

- ✅ Funções de permissão criadas
- ✅ Cabeçalho mostra nome e cargo
- ✅ Filtros aplicados por cargo
- ✅ Dashboard adaptado

**Agora cada usuário vê apenas o que tem permissão!** 🚀
