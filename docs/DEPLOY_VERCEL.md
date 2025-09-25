# Instruções para Deploy no Vercel

## Problemas Identificados e Soluções Implementadas

### 1. URL da API Incorreta
**Problema**: O frontend estava configurado para usar `http://localhost:3001/api` mesmo em produção.
**Solução**: Atualizado `src/lib/database.ts` para usar URL dinâmica baseada no ambiente.

### 2. Configuração do Vercel
**Problema**: `vercel.json` não estava configurado corretamente para um projeto full-stack.
**Solução**: Atualizado com configuração adequada para API e frontend.

### 3. CORS
**Problema**: CORS não estava configurado para produção.
**Solução**: Configurado CORS no `server.mjs` para aceitar requisições do domínio do Vercel.

## Passos para Deploy no Vercel

### 1. Configurar Variáveis de Ambiente no Vercel
No painel do Vercel, vá em Settings > Environment Variables e adicione:

```
VITE_MYSQL_HOST=srv2020.hstgr.io
VITE_MYSQL_USER=u877021150_admin
VITE_MYSQL_PASSWORD=Admin_kiradon9279
VITE_MYSQL_DATABASE=u877021150_conectados
NODE_ENV=production
```

### 2. Fazer Deploy
1. Conecte seu repositório GitHub ao Vercel
2. O Vercel detectará automaticamente as configurações do `vercel.json`
3. O build será executado automaticamente

### 3. Verificar Deploy
Após o deploy, teste:
- Acesse a URL do projeto no Vercel
- Tente fazer login
- Verifique se as requisições para `/api/*` estão funcionando

## Arquivos Modificados

1. **src/lib/database.ts**: URL dinâmica da API
2. **vercel.json**: Configuração completa do Vercel
3. **server.mjs**: CORS configurado para produção
4. **package.json**: Script de build para Vercel
5. **env.example**: Documentação das variáveis de ambiente

## Troubleshooting

### Se o login ainda não funcionar:
1. Verifique se as variáveis de ambiente estão configuradas no Vercel
2. Verifique os logs do Vercel para erros de conexão com o banco
3. Teste a rota `/api/test-connection` diretamente

### Se houver problemas de CORS:
1. Verifique se o domínio do Vercel está na lista de origins permitidos
2. Adicione o domínio específico do seu projeto nas configurações de CORS

## URLs Esperadas
- Frontend: `https://seu-projeto.vercel.app`
- API: `https://seu-projeto.vercel.app/api/*`
