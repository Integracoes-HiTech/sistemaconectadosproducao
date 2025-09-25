# 🔍 Teste do Autocomplete para Casal

## ❌ **Problema Identificado**

O Autocomplete do campo "Setor da Segunda Pessoa" não está carregando os dados do banco.

## 🔧 **Debug Implementado**

### **Logs Adicionados no Autocomplete:**
```typescript
} else if (type === 'sector' && cityValue) {
  console.log('🔍 Buscando setores para cidade:', cityValue, 'query:', query);
  const { data, error } = await supabase
    .from('sectors')
    .select(`
      id, 
      name,
      cities!inner(name)
    `)
    .ilike('name', `%${query}%`)
    .ilike('cities.name', `%${cityValue}%`)
    .order('name')
    .limit(10);

  console.log('🔍 Resultado da busca de setores:', { data, error });
  if (!error && data) {
    suggestions = data.map((item: { id: string; name: string }) => ({
      id: item.id,
      name: item.name
    }));
  }
} else if (type === 'sector' && !cityValue) {
  console.log('⚠️ Tentando buscar setores sem cidade definida');
}
```

## 🧪 **Como Testar**

### **Passo 1: Abrir o Console**
1. Abra o navegador
2. Pressione F12 para abrir as ferramentas de desenvolvedor
3. Vá para a aba "Console"

### **Passo 2: Testar o Cadastro**
1. Acesse o formulário de cadastro público
2. Preencha os dados da primeira pessoa
3. **Preencha a cidade da segunda pessoa** (ex: "Goiânia")
4. **Clique no campo "Setor da Segunda Pessoa"**
5. **Digite pelo menos 2 caracteres** (ex: "Set")

### **Passo 3: Verificar os Logs**
No console, você deve ver:
- `🔍 Buscando setores para cidade: Goiânia query: Set`
- `🔍 Resultado da busca de setores: { data: [...], error: null }`

## 🔍 **Possíveis Problemas**

### **1. Cidade não está sendo passada:**
- **Sintoma**: Log `⚠️ Tentando buscar setores sem cidade definida`
- **Causa**: Campo `couple_city` não está sendo preenchido
- **Solução**: Verificar se o campo cidade está funcionando

### **2. Erro na consulta SQL:**
- **Sintoma**: Log com `error: {...}` 
- **Causa**: Problema na consulta ao banco
- **Solução**: Verificar estrutura das tabelas `sectors` e `cities`

### **3. Dados não retornados:**
- **Sintoma**: Log com `data: []` (array vazio)
- **Causa**: Não há setores cadastrados para a cidade
- **Solução**: Verificar se existem dados na tabela `sectors`

### **4. Problema de relacionamento:**
- **Sintoma**: Erro na consulta com `cities!inner(name)`
- **Causa**: Relacionamento entre tabelas não configurado
- **Solução**: Verificar foreign keys e relacionamentos

## 📋 **Checklist de Verificação**

### **Banco de Dados:**
- [ ] Tabela `cities` existe e tem dados
- [ ] Tabela `sectors` existe e tem dados  
- [ ] Relacionamento entre `cities` e `sectors` está configurado
- [ ] Há setores cadastrados para Goiânia

### **Frontend:**
- [ ] Campo `couple_city` está sendo preenchido
- [ ] Campo `couple_sector` recebe o valor de `couple_city`
- [ ] Autocomplete está sendo chamado corretamente
- [ ] Logs aparecem no console

### **Teste Manual:**
- [ ] Preencher cidade da segunda pessoa
- [ ] Clicar no campo setor da segunda pessoa
- [ ] Digitar pelo menos 2 caracteres
- [ ] Verificar se aparecem sugestões

## 🚀 **Próximos Passos**

1. **Execute o teste** conforme descrito acima
2. **Verifique os logs** no console
3. **Reporte o resultado** para identificar o problema específico
4. **Implemente a correção** baseada no diagnóstico

## 📝 **Resultado Esperado**

Se tudo estiver funcionando corretamente, você deve ver:
- Logs de busca no console
- Sugestões de setores aparecendo no dropdown
- Possibilidade de selecionar um setor da lista

**Execute o teste e me informe o resultado dos logs!** 🔍
