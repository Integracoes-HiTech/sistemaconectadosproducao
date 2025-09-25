# 🔍 Filtro por Referrer - Regras de Visualização

## 🎯 **Como Funciona:**

**A tabela sempre aparece, mas os dados são filtrados pelo cargo do usuário!**

## 👥 **Hierarquia de Visualização:**

### **1️⃣ Admin/Administrador**
- ✅ **Vê:** TODOS os usuários cadastrados
- ✅ **Filtro:** Nenhum (vê tudo)
- ✅ **Título:** "Todos os Usuários do Sistema"

### **2️⃣ Vereador**
- ✅ **Vê:** TODOS os usuários cadastrados
- ✅ **Filtro:** Nenhum (vê tudo)
- ✅ **Título:** "Todos os Usuários do Sistema"

### **3️⃣ Coordenador**
- ✅ **Vê:** Apenas usuários que ele cadastrou
- ✅ **Filtro:** `referrer = "Nome do Coordenador"`
- ✅ **Título:** "Meus Usuários Cadastrados"

### **4️⃣ Colaborador**
- ✅ **Vê:** Apenas usuários que ele cadastrou
- ✅ **Filtro:** `referrer = "Nome do Colaborador"`
- ✅ **Título:** "Meus Usuários Cadastrados"

## 🔧 **Implementação:**

### **Filtro Automático:**
```typescript
const referrerFilter = canViewAllUsers() ? undefined : user?.full_name;
```

### **Lógica:**
- **Admin/Vereador:** `referrerFilter = undefined` (sem filtro)
- **Coordenador/Colaborador:** `referrerFilter = "Nome do Usuário"`

### **Hook useUsers:**
```typescript
const { users: allUsers } = useUsers(referrerFilter);
```

## 📊 **Exemplo Prático:**

### **João (Admin):**
```
Tabela mostra:
- Maria Silva (referrer: João Silva)
- Pedro Santos (referrer: Maria Silva)
- Ana Costa (referrer: Pedro Santos)
- TODOS os usuários
```

### **Maria (Coordenadora):**
```
Tabela mostra:
- Pedro Santos (referrer: Maria Silva)
- Ana Costa (referrer: Maria Silva)
- APENAS usuários que Maria cadastrou
```

### **Pedro (Colaborador):**
```
Tabela mostra:
- Ana Costa (referrer: Pedro Santos)
- APENAS usuários que Pedro cadastrou
```

## 🎨 **Interface Adaptada:**

### **Título Dinâmico:**
- **Admin/Vereador:** "Todos os Usuários do Sistema"
- **Coordenador/Colaborador:** "Meus Usuários Cadastrados"

### **Descrição Dinâmica:**
- **Admin/Vereador:** "Visão consolidada de todos os usuários..."
- **Coordenador/Colaborador:** "Gerencie e visualize todos os usuários vinculados ao seu link"

## ✅ **Benefícios:**

1. **Privacidade:** Cada usuário vê apenas seus dados
2. **Segurança:** Dados protegidos por cargo
3. **Simplicidade:** Interface consistente para todos
4. **Controle:** Filtro automático por referrer

## 🧪 **Teste:**

1. **Login como Admin:** Vê todos os usuários
2. **Login como Coordenador:** Vê apenas seus usuários
3. **Login como Colaborador:** Vê apenas seus usuários

**Agora a tabela sempre aparece, mas os dados são filtrados automaticamente!** 🔍
