import React, { useState, useEffect, useRef, useCallback } from 'react';
import { createPortal } from 'react-dom';
import { Input } from './input';
import { Check, ChevronDown, Search } from 'lucide-react';
import { supabase } from '@/lib/supabase-temp';
import { useToast } from '../../hooks/use-toast';

interface AutocompleteProps {
  value: string;
  onChange: (value: string) => void;
  placeholder: string;
  icon: React.ReactNode;
  type: 'city' | 'sector';
  cityValue?: string; // Para filtrar setores por cidade
  className?: string;
  error?: string;
  onValidationChange?: (isValid: boolean) => void;
  ref?: React.Ref<AutocompleteRef>;
}

interface Suggestion {
  id: string;
  name: string;
}

// Função para normalizar texto (remove acentos, converte para minúsculo)
const normalizeText = (text: string): string => {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // Remove acentos
    .replace(/[^a-z0-9\s]/g, '') // Remove caracteres especiais
    .trim();
};

export interface AutocompleteRef {
  validateValue: () => Promise<{ isValid: boolean; error?: string }>;
  getValue: () => string;
}

export const Autocomplete = React.forwardRef<AutocompleteRef, AutocompleteProps>(({
  value,
  onChange,
  placeholder,
  icon,
  type,
  cityValue,
  className = '',
  error,
  onValidationChange
}, ref) => {
  const { toast } = useToast();
  const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0, width: 0 });
  const inputRef = useRef<HTMLInputElement>(null);
  const debounceRef = useRef<NodeJS.Timeout>();

  // Função de busca simplificada
  const searchSuggestions = useCallback(async (query: string) => {
    if (query.length < 2) {
      setSuggestions([]);
      return;
    }

    setIsLoading(true);
    try {
      let suggestions: Suggestion[] = [];

      if (type === 'city') {
        const { data, error } = await supabase
          .from('cities')
          .select('id, name')
          .eq('state', 'GO')
          .ilike('name', `%${query}%`)
          .order('name')
          .limit(10);

        if (!error && data) {
          suggestions = data.map((item: { id: string; name: string }) => ({
            id: item.id,
            name: item.name
          }));
        }

      } else if (type === 'sector' && cityValue) {
        // Buscando setores para cidade
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

        // Resultado da busca de setores
        if (!error && data) {
          suggestions = data.map((item: { id: string; name: string }) => ({
            id: item.id,
            name: item.name
          }));
        }
      } else if (type === 'sector' && !cityValue) {
        // Tentando buscar setores sem cidade definida
      }

      setSuggestions(suggestions);
    } catch (error) {
      // Erro ao buscar sugestões
      setSuggestions([]);
    } finally {
      setIsLoading(false);
    }
  }, [type, cityValue]);

  // Handle input change with debounce
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    onChange(newValue);
    
    // Clear previous debounce
    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    // Mostrar sugestões quando há texto
    if (newValue.trim().length >= 2) {
      updateDropdownPosition();
      setIsOpen(true);
      debounceRef.current = setTimeout(() => {
        searchSuggestions(newValue);
      }, 300);
    } else {
      setIsOpen(false);
      setSuggestions([]);
    }

    setSelectedIndex(-1);
  };

  // Handle suggestion selection
  const handleSuggestionClick = (suggestion: Suggestion) => {
    
    // Fechar dropdown ANTES de qualquer coisa
    setIsOpen(false);
    setSelectedIndex(-1);
    
    // Atualizar valor
    onChange(suggestion.name);
    
    // Focar no input
    setTimeout(() => {
      if (inputRef.current) {
        inputRef.current.focus();
      }
    }, 50);
  };

  // Handle focus - abrir sugestões se há valor
  const handleFocus = () => {
    if (value.trim().length >= 2) {
      updateDropdownPosition();
      setIsOpen(true);
      searchSuggestions(value);
    }
  };

  // Atualizar posição do dropdown
  const updateDropdownPosition = useCallback(() => {
    if (inputRef.current) {
      const rect = inputRef.current.getBoundingClientRect();
      setDropdownPosition({
        top: rect.bottom + 4, // 4px de margem
        left: rect.left,
        width: rect.width
      });
    }
  }, []);

  // Verificar se o valor atual é válido
  const isValidValue = useCallback((currentValue: string): boolean => {
    if (!currentValue.trim()) return false;
    
    // Verificar se existe uma sugestão exata
    return suggestions.some(s => 
      normalizeText(s.name) === normalizeText(currentValue)
    );
  }, [suggestions]);

  // Handle keyboard navigation
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (!isOpen) return;

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        setSelectedIndex(prev => 
          prev < suggestions.length - 1 ? prev + 1 : prev
        );
        break;
      case 'ArrowUp':
        e.preventDefault();
        setSelectedIndex(prev => prev > 0 ? prev - 1 : -1);
        break;
      case 'Enter':
        e.preventDefault();
        if (selectedIndex >= 0 && selectedIndex < suggestions.length) {
          handleSuggestionClick(suggestions[selectedIndex]);
        }
        break;
      case 'Escape':
        setIsOpen(false);
        setSelectedIndex(-1);
        break;
    }
  };

  // Close suggestions when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      const target = event.target as Node;
      const container = inputRef.current?.parentElement;
      const dropdown = document.querySelector('[data-suggestion-container]');
      
      if (container && !container.contains(target) && (!dropdown || !dropdown.contains(target))) {
        setIsOpen(false);
        setSelectedIndex(-1);
      }
    };

    const handleScroll = () => {
      if (isOpen) {
        updateDropdownPosition();
      }
    };

    const handleResize = () => {
      if (isOpen) {
        updateDropdownPosition();
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    window.addEventListener('scroll', handleScroll, true);
    window.addEventListener('resize', handleResize);
    
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      window.removeEventListener('scroll', handleScroll, true);
      window.removeEventListener('resize', handleResize);
    };
  }, [isOpen, updateDropdownPosition]);

  // Cleanup debounce on unmount
  useEffect(() => {
    return () => {
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
    };
  }, []);

  // Notificar sobre mudanças na validação
  useEffect(() => {
    if (onValidationChange) {
      const isValid = isValidValue(value);
      onValidationChange(isValid);
    }
  }, [value, suggestions, onValidationChange, isValidValue]);

  // Monitorar mudanças no estado isOpen
  useEffect(() => {
    // Estado isOpen mudou
  }, [isOpen]);

  // Função para validar valor contra o banco de dados
  const validateValueInDatabase = async (): Promise<{ isValid: boolean; error?: string }> => {
    if (!value.trim()) {
      return { isValid: false, error: `${type === 'city' ? 'Cidade' : 'Setor'} é obrigatório` };
    }

    try {
      if (type === 'city') {
        const { data, error } = await supabase
          .from('cities')
          .select('id, name')
          .eq('state', 'GO')
          .ilike('name', value.trim())
          .single();

        if (error || !data) {
          return { 
            isValid: false, 
            error: `Cidade "${value.trim()}" não encontrada. Selecione uma cidade válida da lista.` 
          };
        }

        return { isValid: true };

      } else if (type === 'sector' && cityValue) {
        const { data, error } = await supabase
          .from('sectors')
          .select(`
            id, 
            name,
            cities!inner(name)
          `)
          .ilike('name', value.trim())
          .ilike('cities.name', cityValue)
          .single();

        if (error || !data) {
          return { 
            isValid: false, 
            error: `Setor "${value.trim()}" não encontrado em ${cityValue}. Selecione um setor válido da lista.` 
          };
        }

        return { isValid: true };
      }

      return { isValid: false, error: 'Tipo de validação não suportado' };
    } catch (error) {
      // Erro silencioso
      return { 
        isValid: false, 
        error: `Erro ao validar ${type === 'city' ? 'cidade' : 'setor'}. Tente novamente.` 
      };
    }
  };

  // Expor métodos via ref
  React.useImperativeHandle(ref, () => ({
    validateValue: validateValueInDatabase,
    getValue: () => value
  }));

  return (
    <div className="relative" style={{ zIndex: 10000 }}>
      <div className="relative">
        {icon}
        <Input
          ref={inputRef}
          type="text"
          placeholder={placeholder}
          value={value}
          onChange={handleInputChange}
          onKeyDown={handleKeyDown}
          onFocus={handleFocus}
          className={`pl-12 pr-10 h-12 bg-gray-800 border-gray-700 text-white placeholder-gray-400 focus:border-institutional-gold focus:ring-institutional-gold rounded-lg ${
            error ? 'border-red-500' : 
            value.trim() && !isValidValue(value) ? 'border-yellow-500' : ''
          } ${className}`}
          required
        />
        {/* Ícone de dropdown */}
        <div className="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
          <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${isOpen ? 'rotate-180' : ''}`} />
        </div>
      </div>

      {/* Suggestions dropdown via Portal */}
      {isOpen && createPortal(
        <div 
          className="bg-gray-800 border border-gray-700 rounded-lg shadow-lg max-h-60 overflow-y-auto"
          data-suggestion-container
          style={{ 
            position: 'fixed',
            top: `${dropdownPosition.top}px`,
            left: `${dropdownPosition.left}px`,
            width: `${dropdownPosition.width}px`,
            zIndex: 999999,
            pointerEvents: 'auto',
            maxHeight: '240px',
            userSelect: 'none',
            WebkitUserSelect: 'none',
            MozUserSelect: 'none',
            msUserSelect: 'none',
            isolation: 'isolate'
          }}
        >
          {/* Loading state */}
          {isLoading && (
            <div className="px-4 py-3 text-gray-400 text-sm text-center">
              <div className="flex items-center justify-center gap-2">
                <div className="w-4 h-4 border-2 border-institutional-gold border-t-transparent rounded-full animate-spin" />
                Buscando...
              </div>
            </div>
          )}

          {/* Suggestions */}
          {!isLoading && suggestions.length > 0 && (
            <>
              {suggestions.map((suggestion, index) => {
                const isExactMatch = normalizeText(suggestion.name) === normalizeText(value);
                
                return (
                  <div
                    key={suggestion.id}
                    data-suggestion
                    onMouseDown={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                      handleSuggestionClick(suggestion);
                    }}
                    onClick={(e) => {
                      e.preventDefault();
                      e.stopPropagation();
                    }}
                    className={`w-full px-4 py-3 text-left text-white hover:bg-gray-700 active:bg-gray-600 flex items-center gap-3 transition-colors cursor-pointer select-none ${
                      index === selectedIndex ? 'bg-gray-700' : ''
                    } ${isExactMatch ? 'bg-green-900/20' : ''}`}
                    style={{
                      pointerEvents: 'auto',
                      userSelect: 'none',
                      WebkitUserSelect: 'none',
                      MozUserSelect: 'none',
                      msUserSelect: 'none'
                    }}
                  >
                    <Check className={`w-4 h-4 ${isExactMatch ? 'text-green-400' : 'text-gray-500'}`} />
                    <span className="font-medium">{suggestion.name}</span>
                  </div>
                );
              })}
            </>
          )}

          {/* No results */}
          {!isLoading && suggestions.length === 0 && value.length >= 2 && (
            <div className="px-4 py-3 text-gray-400 text-sm text-center">
              <div className="flex items-center justify-center gap-2">
                <Search className="w-4 h-4" />
                Nenhum resultado encontrado
              </div>
            </div>
          )}

        </div>,
        document.body
      )}

      {/* Error message */}
      {error && (
        <div className="flex items-center gap-1 text-red-400 text-sm mt-1">
          <span>{error}</span>
        </div>
      )}
    </div>
  );
});
