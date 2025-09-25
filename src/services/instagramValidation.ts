// services/instagramValidation.ts

export type InstagramValidationResult = {
  status: boolean;
  message: string;
};

export async function validateInstagramAccount(username: string): Promise<InstagramValidationResult> {
  try {
    // Remove @ se o usuário digitou
    const cleanUsername = username.replace('@', '');
    
    // Validação básica primeiro
    const basicValidation = await validateInstagramBasic(cleanUsername);
    if (!basicValidation.status) {
      return basicValidation;
    }

    // Tentar validação via webhook
    try {
      const webhookUrl = `http://72.60.13.233:8001/webhook/d81103cd-3857-4531-af82-f2a1bda9de5c?username=${encodeURIComponent(cleanUsername)}`;
      
      const response = await fetch(webhookUrl, {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        }
      });

      if (response.ok) {
        const data = await response.json();
        
        // Webhook retorna true se válido, false se inválido
        if (data === true) {
          return { status: true, message: "" };
        } else {
          return {
            status: false,
            message: "Não encontramos um usuário com essa conta de instagram"
          };
        }
      } else {
        // Se webhook falhar, usar validação básica
        // Webhook do Instagram indisponível, usando validação básica
        return basicValidation;
      }
    } catch (webhookError) {
      // Se webhook falhar, usar validação básica
      // Erro no webhook do Instagram, usando validação básica
      return basicValidation;
    }

  } catch (error) {
    // Erro na validação do Instagram
    return {
      status: false,
      message: "Erro ao validar conta do Instagram"
    };
  }
}

// Validação básica como fallback
async function validateInstagramBasic(username: string): Promise<InstagramValidationResult> {
  // Validação básica de formato
  if (username.length < 3) {
    return {
      status: false,
      message: "Nome de usuário do Instagram deve ter pelo menos 3 caracteres"
    };
  }

  if (username.length > 30) {
    return {
      status: false,
      message: "Nome de usuário do Instagram deve ter no máximo 30 caracteres"
    };
  }

  // Verificar caracteres válidos (Instagram permite letras, números, pontos e underscores)
  const validChars = /^[a-zA-Z0-9._]+$/;
  if (!validChars.test(username)) {
    return {
      status: false,
      message: "Nome de usuário do Instagram deve conter apenas letras, números, pontos (.) e underscores (_). Não são permitidos espaços ou símbolos especiais como @, #, $, etc."
    };
  }

  // Verificar se não começa ou termina com ponto ou underscore
  if (username.startsWith('.') || username.startsWith('_') || 
      username.endsWith('.') || username.endsWith('_')) {
    return {
      status: false,
      message: "Nome de usuário do Instagram não pode começar ou terminar com ponto ou underscore"
    };
  }

  // Verificar se não tem pontos ou underscores consecutivos (apenas pontos duplos são inválidos)
  if (username.includes('..') || username.includes('__')) {
    return {
      status: false,
      message: "Nome de usuário do Instagram não pode ter pontos (..) ou underscores (__) consecutivos"
    };
  }

  // Se passou na validação básica, aceitar
  return {
    status: true,
    message: "Conta aceita (validação de formato - não verificada no Instagram)"
  };
}
