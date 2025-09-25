import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Logo } from '@/components/Logo';
import { useAuth } from '@/hooks/useAuth';
import { useSystemSettings } from '@/hooks/useSystemSettings';
import { useToast } from '@/hooks/use-toast';
import { Users, UserCheck, ArrowLeft, RefreshCw, AlertTriangle } from 'lucide-react';
import { supabase } from '@/lib/supabase-temp'

export default function Settings() {
  const navigate = useNavigate();
  const { user, logout, canModifyLinkTypes } = useAuth();
  const { 
    settings, 
    phases,
    loading, 
    error, 
    refetch, 
    updateMemberLinksType,
    activatePaidContractsPhase,
    deactivatePaidContractsPhase,
    canActivatePaidContracts
  } = useSystemSettings();
  const [isUpdating, setIsUpdating] = useState(false);
  const { toast } = useToast();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  // Garantir configuração inicial quando o componente carregar
  useEffect(() => {
    const ensureInitialSettings = async () => {
      try {
        const { data: existingSettings, error: fetchError } = await supabase
          .from('system_settings')
          .select('*')
          .eq('setting_key', 'member_links_type');

        if (fetchError) throw fetchError;

        if (!existingSettings || existingSettings.length === 0) {
          // Criando configuração inicial
          
          const { error: insertError } = await supabase
            .from('system_settings')
            .insert([{
              setting_key: 'member_links_type',
              setting_value: 'members',
              description: 'Tipo de links gerados pelos membros: members (novos membros) ou friends (amigos)'
            }]);

          if (insertError) throw insertError;
          
          // Configuração inicial criada
          await refetch();
        }
      } catch (err) {
        // Erro ao criar configuração inicial
      }
    };

    if (!loading && !error) {
      ensureInitialSettings();
    }
  }, [loading, error, refetch]);

  const handleUpdateLinkType = async (linkType: 'members' | 'friends') => {
    if (!canModifyLinkTypes()) {
      toast({
        title: "Acesso negado",
        description: "Apenas administradores completos podem alterar tipos de links.",
        variant: "destructive",
      });
      return;
    }

    try {
      setIsUpdating(true);
      
      const result = await updateMemberLinksType(linkType);
      
      if (result.success) {
        toast({
          title: "Configuração atualizada!",
          description: `Tipo de links alterado para: ${linkType === 'members' ? 'Novos Membros' : 'Amigos'}. ${result.updated_links_count || 0} links de usuários "Membro" foram atualizados. Links de Administradores e Felipe Admin mantidos.`,
        });
        // Tipo de links atualizado com sucesso
        
        // Recarregar configurações
        await refetch();
      } else {
        toast({
          title: "Erro ao atualizar",
          description: result.error || "Não foi possível alterar o tipo de links",
          variant: "destructive",
        });
      }
    } catch (err) {
      toast({
        title: "Erro",
        description: "Ocorreu um erro inesperado",
        variant: "destructive",
      });
    } finally {
      setIsUpdating(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-institutional-blue">
        {/* Header */}
        <header className="bg-white shadow-md border-b-2 border-institutional-gold">
          <div className="container mx-auto px-4 py-4">
            <div className="flex items-center justify-between">s
              <Logo size="md" />
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <span className="text-institutional-blue font-medium">Bem-vindo, {user?.display_name || user?.name}</span>
                  <div className="text-sm text-muted-foreground">{user?.role}</div>
                </div>
                <Button
                  onClick={handleLogout}
                  variant="outline"
                  className="border-institutional-gold text-institutional-gold hover:bg-institutional-gold/10"
                >
                  Sair
                </Button>
              </div>
            </div>
          </div>
        </header>

        {/* Conteúdo de carregamento */}
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <Card className="max-w-md mx-auto">
            <CardContent className="p-8 text-center">
              <div className="w-8 h-8 border-2 border-institutional-gold border-t-transparent rounded-full animate-spin mx-auto mb-4" />
              <h2 className="text-xl font-semibold text-gray-800 mb-2">Carregando...</h2>
              <p className="text-gray-600">Aguarde enquanto carregamos as configurações.</p>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-institutional-blue">
        {/* Header */}
        <header className="bg-white shadow-md border-b-2 border-institutional-gold">
          <div className="container mx-auto px-4 py-4">
            <div className="flex items-center justify-between">
              <Logo size="md" />
              <div className="flex items-center gap-4">
                <div className="text-right">
                  <span className="text-institutional-blue font-medium">Bem-vindo, {user?.display_name || user?.name}</span>
                  <div className="text-sm text-muted-foreground">{user?.role}</div>
                </div>
                <Button
                  onClick={handleLogout}
                  variant="outline"
                  className="border-institutional-gold text-institutional-gold hover:bg-institutional-gold/10"
                >
                  Sair
                </Button>
              </div>
            </div>
          </div>
        </header>

        {/* Conteúdo de erro */}
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <Card className="max-w-md mx-auto">
            <CardContent className="p-8 text-center">
              <AlertTriangle className="w-16 h-16 mx-auto mb-4 text-red-500" />
              <h2 className="text-xl font-semibold text-gray-800 mb-2">Erro</h2>
              <p className="text-gray-600 mb-4">{error}</p>
              <Button onClick={() => refetch()} className="w-full">
                <RefreshCw className="w-4 h-4 mr-2" />
                Tentar Novamente
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-institutional-blue">
      {/* Header */}
      <header className="bg-white shadow-md border-b-2 border-institutional-gold">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div 
              onClick={() => navigate("/dashboard")}
              className="cursor-pointer"
            >
              <Logo size="md" />
            </div>
            <div className="flex items-center gap-4">
              <div className="text-right">
                <span className="text-institutional-blue font-medium">Bem-vindo, {user?.name}</span>
                <div className="text-sm text-muted-foreground">{user?.role}</div>
              </div>
              <Button
                onClick={handleLogout}
                variant="outline"
                className="border-institutional-gold text-institutional-gold hover:bg-institutional-gold/10"
              >
                Sair
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Conteúdo Principal */}
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Título da Página */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-4">
            <Button
              onClick={() => navigate("/dashboard")}
              variant="outline"
              className="border-institutional-gold text-institutional-gold hover:bg-institutional-gold/10"
            >
              <ArrowLeft className="w-4 h-4 mr-2" />
              Voltar ao Dashboard
            </Button>
          </div>
          <h1 className="text-2xl font-bold text-institutional-blue">
            Configurações do Sistema
          </h1>
        </div>

        {/* Controle de Tipo de Links */}
        <Card className="shadow-lg">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-blue-600">
              <Users className="w-5 h-5" />
              Controle de Tipo de Links
            </CardTitle>
            <CardDescription>
              Configure se os links gerados pelos membros servem para cadastrar novos membros ou amigos
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Status Atual */}
            <div className="p-4 bg-gray-50 rounded-lg border">
              <h4 className="font-semibold text-gray-800 mb-2">Status Atual</h4>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                <span className="text-gray-700">
                  {settings?.member_links_type === 'members' 
                    ? 'Links servem para cadastrar novos membros (duplas)'
                    : 'Links servem para cadastrar amigos'
                  }
                </span>
              </div>
            </div>

            {/* Botões de Controle */}
            <div className="space-y-4">
              <h4 className="font-semibold text-gray-800">Alterar Tipo de Links</h4>
              {!canModifyLinkTypes() && (
                <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
                  <p className="text-sm text-yellow-800">
                    <AlertTriangle className="w-4 h-4 inline mr-2" />
                    Apenas administradores completos podem alterar os tipos de links.
                  </p>
                </div>
              )}
              <div className="grid grid-cols-1 gap-3">
                <Button
                  onClick={() => handleUpdateLinkType('members')}
                  disabled={isUpdating || !canModifyLinkTypes()}
                  className={`h-16 text-left justify-start ${
                    settings?.member_links_type === 'members' 
                      ? 'bg-green-600 hover:bg-green-700 text-white' 
                      : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                  } ${!canModifyLinkTypes() ? 'opacity-50 cursor-not-allowed' : ''}`}
                >
                  <div className="flex items-center gap-3">
                    <Users className="w-6 h-6" />
                    <div>
                      <div className="font-semibold">Novos Membros</div>
                      <div className="text-sm opacity-90">
                        Links cadastram duplas que se tornam membros da rede
                      </div>
                    </div>
                  </div>
                </Button>

                <Button
                  onClick={() => handleUpdateLinkType('friends')}
                  disabled={isUpdating || !canModifyLinkTypes()}
                  className={`h-16 text-left justify-start ${
                    settings?.member_links_type === 'friends' 
                      ? 'bg-green-600 hover:bg-green-700 text-white' 
                      : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                  } ${!canModifyLinkTypes() ? 'opacity-50 cursor-not-allowed' : ''}`}
                >
                  <div className="flex items-center gap-3">
                    <UserCheck className="w-6 h-6" />
                    <div>
                      <div className="font-semibold">Amigos</div>
                      <div className="text-sm opacity-90">
                        Links cadastram duplas que se tornam amigos
                      </div>
                    </div>
                  </div>
                </Button>
              </div>
            </div>

            {/* Controle de Fase - Simples */}
            <div className="space-y-4">
              <h4 className="font-semibold text-gray-800">Controle de Fase</h4>
              <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                <div className="flex items-center justify-between">
                  <div>
                    <div className="font-semibold text-blue-800">
                      {settings?.paid_contracts_phase_active ? 'Fase Ativa' : 'Fase Inativa'}
                    </div>
                    <div className="text-sm text-blue-600">
                      {settings?.paid_contracts_phase_active 
                        ? 'Fase de amigos ativa - Cada membro pode cadastrar até 15 duplas pagas'
                        : `Cada membro poderá cadastrar até 15 duplas pagas quando ativada (${settings?.phase_status?.member_count || 0}/${settings?.phase_status?.max_members || 1500} membros)`
                      }
                    </div>
                    {settings?.phase_status && (
                      <div className="text-xs text-blue-500 mt-1">
                        Status: {settings.phase_status.message} ({settings.phase_status.percentage}%)
                        {settings.phase_status.should_activate_phase && !settings.paid_contracts_phase_active && 
                          " - Fase pode ser ativada automaticamente"
                        }
                      </div>
                    )}
                  </div>
                  <div>
                    {settings?.paid_contracts_phase_active ? (
                      <Button
                        onClick={async () => {
                          try {
                            setIsUpdating(true);
                            const result = await deactivatePaidContractsPhase();
                            
                            if (result.success) {
                              toast({
                                title: "Fase desativada!",
                                description: "Voltou para cadastro de membros normais.",
                              });
                            } else {
                              toast({
                                title: "Erro ao desativar",
                                description: result.error || "Não foi possível desativar",
                                variant: "destructive",
                              });
                            }
                          } catch (err) {
                            toast({
                              title: "Erro",
                              description: "Ocorreu um erro inesperado",
                              variant: "destructive",
                            });
                          } finally {
                            setIsUpdating(false);
                          }
                        }}
                        disabled={isUpdating}
                        variant="destructive"
                        size="sm"
                      >
                        Desativar
                      </Button>
                    ) : (
                      <Button
                        onClick={async () => {
                          try {
                            setIsUpdating(true);
                            const result = await activatePaidContractsPhase();
                            
                            if (result.success) {
                              toast({
                                title: "Fase ativada!",
                                description: "Membros agora podem cadastrar amigos.",
                              });
                            } else {
                              toast({
                                title: "Erro ao ativar",
                                description: result.error || "Não foi possível ativar",
                                variant: "destructive",
                              });
                            }
                          } catch (err) {
                            toast({
                              title: "Erro",
                              description: "Ocorreu um erro inesperado",
                              variant: "destructive",
                            });
                          } finally {
                            setIsUpdating(false);
                          }
                        }}
                        disabled={isUpdating || !canActivatePaidContracts()}
                        className={canActivatePaidContracts() ? 'bg-green-600 hover:bg-green-700' : 'bg-gray-300 cursor-not-allowed'}
                        size="sm"
                      >
                        {canActivatePaidContracts() ? 'Ativar' : 'Aguardando 1500 membros'}
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Informações Importantes */}
            <div className="p-4 bg-yellow-50 rounded-lg border border-yellow-200">
              <h4 className="font-semibold text-yellow-800 mb-2">⚠️ Informações Importantes</h4>
              <ul className="text-yellow-700 text-sm space-y-1">
                <li>• <strong>Novos Membros:</strong> Cadastram duplas que se tornam membros da rede</li>
                <li>• <strong>Amigos:</strong> Cadastram duplas que se tornam amigos</li>
                <li>• A mudança afeta todos os links gerados pelos membros</li>
                <li>• Links já gerados continuam funcionando com o tipo atual</li>
              </ul>
            </div>
          </CardContent>
        </Card>

      </div>
    </div>
  );
}