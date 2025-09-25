// services/emailService.ts
import emailjs from '@emailjs/browser'

// Configurações do EmailJS - SUAS CREDENCIAIS REAIS
const EMAILJS_SERVICE_ID = 'service_crb2xuj' // Seu Service ID
const EMAILJS_TEMPLATE_ID = 'template_nw72q9c' // Seu Template ID original
const EMAILJS_PUBLIC_KEY = 'YRVk-zhbMbi7_Ng0Q' // Sua Public Key

export interface EmailData {
  to_email: string
  to_name: string
  from_name: string
  login_url: string
  username: string
  password: string
  referrer_name: string
  system_url: string
}

export const emailService = {
  // Inicializar EmailJS
  init: () => {
    emailjs.init(EMAILJS_PUBLIC_KEY);
  },

  // Enviar email de boas-vindas com credenciais
  sendWelcomeEmail: async (emailData: EmailData) => {
    try {
      
      // Inicializar EmailJS antes de enviar
      emailjs.init(EMAILJS_PUBLIC_KEY);
      
      // Validar dados obrigatórios
      if (!emailData.to_email || !emailData.to_name) {
        throw new Error("Email e nome são obrigatórios");
      }
      
      const templateParams = {
        to_name: emailData.to_name,
        email: emailData.to_email,
        username: emailData.username,
        password: emailData.password,
        to_email: emailData.to_email,
        referrer_name: emailData.referrer_name,
        system_url: emailData.system_url
      }


      const response = await emailjs.send(
        EMAILJS_SERVICE_ID,
        EMAILJS_TEMPLATE_ID,
        templateParams
      )

      return { success: true, response }
      } catch (error) {
        throw error;
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Erro ao enviar email' 
      }
    }
  },

  // Enviar email de notificação para o referrer
  sendNotificationEmail: async (referrerEmail: string, referrerName: string, newUserData: {
    name: string;
    email: string;
  }) => {
    try {
      const templateParams = {
        to_email: referrerEmail,
        to_name: referrerName,
        new_user_name: newUserData.name,
        new_user_email: newUserData.email,
        registration_date: new Date().toLocaleDateString('pt-BR'),
        message: `
          Olá ${referrerName}!
          
          Uma nova pessoa se cadastrou através do seu link!
          
          Dados do novo cadastro:
          Nome: ${newUserData.name}
          Email: ${newUserData.email}
          Data: ${new Date().toLocaleDateString('pt-BR')}
          
          Continue compartilhando seu link para aumentar sua rede!
        `
      }

      const response = await emailjs.send(
        EMAILJS_SERVICE_ID,
        'template_notification', // Template diferente para notificação
        templateParams
      )

      return { success: true, response }
    } catch (error) {
      throw error;
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Erro ao enviar email de notificação' 
      }
    }
  }
}

// Função para gerar credenciais automáticas
export const generateCredentials = (userData: {
  email: string;
  name: string;
}) => {
  const username = userData.email.split('@')[0].toLowerCase()
  const password = Math.random().toString(36).slice(-8) // Senha aleatória de 8 caracteres
  
  return {
    username,
    password,
    login_url: `${window.location.origin}/login`,
    system_url: 'https://sistemaconectados.vercel.app/'
  }
}
