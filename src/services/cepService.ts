// =====================================================
// SERVIÇO: BUSCA DE CEP VIA VIA CEP API
// =====================================================
// Este serviço busca informações de endereço através do CEP
// usando a API pública do ViaCEP
// =====================================================

export interface CepData {
  cidade: string;
  bairro: string;
  logradouro?: string;
  uf?: string;
  cep?: string;
}

export interface CepError {
  message: string;
  code?: string;
}

/**
 * Busca informações de endereço através do CEP
 * @param cep - CEP a ser consultado (com ou sem formatação)
 * @returns Promise com dados do endereço ou erro
 */
export async function buscarCep(cep: string): Promise<CepData> {
  try {
    // Buscando CEP
    
    // Remove traços, espaços e caracteres não numéricos
    const cepLimpo = cep.replace(/\D/g, "");

    // Validação: CEP precisa ter 8 dígitos numéricos
    if (!/^[0-9]{8}$/.test(cepLimpo)) {
      throw new Error("Por favor, informe um CEP válido com 8 dígitos.");
    }

    const url = `https://viacep.com.br/ws/${cepLimpo}/json/`;

    // Fazendo requisição para API

    const response = await fetch(url);
    
    if (!response.ok) {
      throw new Error(`Erro ao consultar o ViaCEP: ${response.status}`);
    }

    const data = await response.json();

    // Dados recebidos do ViaCEP

    if (data.erro) {
      throw new Error("CEP não encontrado!");
    }

    // Validação dos dados retornados
    if (!data.localidade || !data.bairro) {
      throw new Error("Dados incompletos retornados pelo ViaCEP");
    }

    // Retorna dados formatados
    const resultado: CepData = {
      cidade: data.localidade.trim(),
      bairro: data.bairro.trim(),
      logradouro: data.logradouro?.trim() || '',
      uf: data.uf?.trim() || '',
      cep: data.cep?.trim() || cepLimpo
    };

    // CEP encontrado
    return resultado;

  } catch (error) {
    // Erro ao buscar CEP
    
    if (error instanceof Error) {
      throw error;
    }
    
    throw new Error("Erro inesperado ao consultar CEP");
  }
}

/**
 * Valida formato do CEP
 * @param cep - CEP a ser validado
 * @returns true se válido, false caso contrário
 */
export function validarFormatoCep(cep: string): boolean {
  const cepLimpo = cep.replace(/\D/g, "");
  return /^[0-9]{8}$/.test(cepLimpo);
}

/**
 * Formata CEP para exibição (00000-000)
 * @param cep - CEP a ser formatado
 * @returns CEP formatado
 */
export function formatarCep(cep: string): string {
  const cepLimpo = cep.replace(/\D/g, "");
  
  if (cepLimpo.length === 8) {
    return `${cepLimpo.slice(0, 5)}-${cepLimpo.slice(5)}`;
  }
  
  return cepLimpo;
}

/**
 * Remove formatação do CEP (apenas números)
 * @param cep - CEP formatado
 * @returns CEP apenas com números
 */
export function limparCep(cep: string): string {
  return cep.replace(/\D/g, "");
}

/**
 * Hook para busca de CEP com loading e error states
 * @returns Objeto com função de busca, loading e error
 */
export function useCepSearch() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const buscarCepComLoading = async (cep: string): Promise<CepData | null> => {
    setLoading(true);
    setError(null);

    try {
      const resultado = await buscarCep(cep);
      return resultado;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : "Erro ao buscar CEP";
      setError(errorMessage);
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    buscarCep: buscarCepComLoading,
    loading,
    error,
    clearError: () => setError(null)
  };
}

// Import necessário para o hook
import { useState } from 'react';
