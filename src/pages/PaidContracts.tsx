import React, { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Logo } from "@/components/Logo";
import { useToast } from "@/hooks/use-toast";
import { useNavigate } from "react-router-dom";
import { 
  Users, 
  UserPlus, 
  CheckCircle, 
  AlertCircle,
  Instagram,
  Phone,
  Calendar,
  Search,
  Filter,
  Eye,
  Edit,
  Trash2,
  ExternalLink,
  Copy,
  Verified
} from "lucide-react";
import { useAuth } from "@/hooks/useAuth";
import { usePaidContracts } from "@/hooks/usePaidContracts";
import { useMembers } from "@/hooks/useMembers";
import { useSystemSettings } from "@/hooks/useSystemSettings";

export default function PaidContracts() {
  const [searchTerm, setSearchTerm] = useState("");
  const [phoneSearchTerm, setPhoneSearchTerm] = useState("");
  const [filterStatus, setFilterStatus] = useState("");
  const [filterMember, setFilterMember] = useState("");
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedMember, setSelectedMember] = useState("");
  
  const { toast } = useToast();
  const navigate = useNavigate();
  const { user, logout, isAdmin } = useAuth();

  const { 
    contracts, 
    contractStats, 
    loading: contractsLoading,
    addContract,
    updateContractStatus,
    verifyInstagramPost,
    getContractStatusColor,
    getContractStatusIcon,
    getContractsByStatus,
    getContractsNeedingVerification,
    canAddMoreContracts
  } = usePaidContracts();

  const { 
    members, 
    loading: membersLoading,
    getTopMembers
  } = useMembers();

  const { 
    settings, 
    loading: settingsLoading,
    isPhaseActive
  } = useSystemSettings();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  // Formulário para adicionar contrato
  const [contractForm, setContractForm] = useState({
    member_id: "",
    couple_name_1: "",
    couple_name_2: "",
    couple_phone_1: "",
    couple_phone_2: "",
    couple_instagram_1: "",
    couple_instagram_2: ""
  });

  const handleAddContract = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!contractForm.member_id) {
      toast({
        title: "Erro",
        description: "Selecione um membro para vincular o contrato.",
        variant: "destructive",
      });
      return;
    }

    const result = await addContract(contractForm);
    
    if (result.success) {
      toast({
        title: "Contrato adicionado!",
        description: "O contrato foi cadastrado com sucesso.",
      });
      setShowAddForm(false);
      setContractForm({
        member_id: "",
        couple_name_1: "",
        couple_name_2: "",
        couple_phone_1: "",
        couple_phone_2: "",
        couple_instagram_1: "",
        couple_instagram_2: ""
      });
    } else {
      toast({
        title: "Erro ao adicionar contrato",
        description: result.error || "Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const handleVerifyPost = async (contractId: string, personNumber: 1 | 2, postUrl: string) => {
    if (!postUrl.trim()) {
      toast({
        title: "Erro",
        description: "Digite a URL do post do Instagram.",
        variant: "destructive",
      });
      return;
    }

    const result = await verifyInstagramPost(contractId, personNumber, postUrl);
    
    if (result.success) {
      toast({
        title: "Post verificado!",
        description: "O post foi verificado com sucesso.",
      });
    } else {
      toast({
        title: "Erro ao verificar post",
        description: result.error || "Tente novamente.",
        variant: "destructive",
      });
    }
  };

  const handleStatusChange = async (contractId: string, newStatus: 'Pendente' | 'Ativo' | 'Completo' | 'Cancelado') => {
    const result = await updateContractStatus(contractId, newStatus);
    
    if (result.success) {
      toast({
        title: "Status atualizado!",
        description: "O status do contrato foi atualizado.",
      });
    } else {
      toast({
        title: "Erro ao atualizar status",
        description: result.error || "Tente novamente.",
        variant: "destructive",
      });
    }
  };

  // Filtrar contratos
  const filteredContracts = contracts.filter(contract => {
    const matchesSearch = searchTerm === "" || 
      contract.couple_name_1.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contract.couple_name_2.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contract.couple_instagram_1.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contract.couple_instagram_2.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contract.member_data?.name.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesPhone = phoneSearchTerm === "" || 
      contract.couple_phone_1.includes(phoneSearchTerm) ||
      contract.couple_phone_2.includes(phoneSearchTerm);

    const matchesStatus = filterStatus === "" || contract.contract_status === filterStatus;
    const matchesMember = filterMember === "" || contract.member_id === filterMember;

    return matchesSearch && matchesPhone && matchesStatus && matchesMember;
  });

  // Loading state
  if (contractsLoading || membersLoading || settingsLoading) {
    return (
      <div className="min-h-screen bg-institutional-blue flex items-center justify-center">
        <div className="text-center">
          <div className="w-8 h-8 border-2 border-institutional-gold border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-white">Carregando contratos...</p>
        </div>
      </div>
    );
  }

  // Verificar se a fase está ativa
  if (!isPhaseActive('paid_contracts')) {
    return (
      <div className="min-h-screen bg-institutional-blue flex flex-col items-center justify-center p-4">
        {/* Logo no topo */}
        <div className="mb-8">
          <Logo size="lg" showText={true} layout="vertical" textColor="white" />
        </div>

        {/* Mensagem de fase bloqueada */}
        <div className="w-full max-w-md text-center">
          <div className="bg-white rounded-lg shadow-lg p-8 mb-8">
            <AlertCircle className="w-16 h-16 text-yellow-500 mx-auto mb-4" />
            <h2 className="text-2xl font-bold text-institutional-blue mb-2">
              Fase Bloqueada
            </h2>
            <p className="text-gray-600 mb-4">
              A fase de amigos ainda não está ativa. Ela será liberada a partir de julho de 2026.
            </p>
            <div className="bg-yellow-50 p-4 rounded-lg mb-4">
              <p className="text-sm text-yellow-800">
                <strong>Quando ativada:</strong><br />
                • Cada membro poderá cadastrar até 15 duplas pagas<br />
                • Total de 22.500 contratos (45.000 pessoas)<br />
                • Fiscalização via posts do Instagram<br />
                • Hashtags únicas para cada contrato
              </p>
            </div>
            <div 
              onClick={() => navigate("/dashboard")}
              className="w-full cursor-pointer flex justify-center"
            >
              <Logo size="sm" />
            </div>
          </div>
        </div>

        {/* Rodapé */}
        <div className="text-center text-white text-sm">
          <p>Todos os direitos reservados HitechDesenvolvimento 2025</p>
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

      {/* Conteúdo Principal */}
      <main className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="bg-white shadow-[var(--shadow-card)] rounded-lg p-6 mb-8 border border-institutional-light">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <h1 className="text-2xl font-bold text-institutional-blue">
                Amigos - Sistema de Fiscalização
              </h1>
              <p className="text-muted-foreground mt-1">
                Gerencie amigos e fiscalize posts do Instagram
              </p>
            </div>
            
            {isAdmin() && (
              <Button
                onClick={() => setShowAddForm(true)}
                className="bg-institutional-gold hover:bg-institutional-gold/90 text-institutional-blue font-medium"
              >
                <UserPlus className="w-4 h-4 mr-2" />
                Adicionar Contrato
              </Button>
            )}
          </div>
        </div>

        {/* Cards de Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <Card className="shadow-[var(--shadow-card)] border-l-4 border-l-blue-500">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Total de Contratos</p>
                  <p className="text-2xl font-bold text-blue-600">{contractStats?.total_contracts || 0}</p>
                </div>
                <div className="p-3 rounded-full bg-blue-50">
                  <Users className="w-6 h-6 text-blue-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-[var(--shadow-card)] border-l-4 border-l-green-500">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Completos</p>
                  <p className="text-2xl font-bold text-green-600">{contractStats?.completed_contracts || 0}</p>
                </div>
                <div className="p-3 rounded-full bg-green-50">
                  <CheckCircle className="w-6 h-6 text-green-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-[var(--shadow-card)] border-l-4 border-l-yellow-500">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Pendentes</p>
                  <p className="text-2xl font-bold text-yellow-600">{contractStats?.pending_contracts || 0}</p>
                </div>
                <div className="p-3 rounded-full bg-yellow-50">
                  <AlertCircle className="w-6 h-6 text-yellow-600" />
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="shadow-[var(--shadow-card)] border-l-4 border-l-purple-500">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Posts Verificados</p>
                  <p className="text-2xl font-bold text-purple-600">{contractStats?.verified_posts || 0}</p>
                </div>
                <div className="p-3 rounded-full bg-purple-50">
                  <Verified className="w-6 h-6 text-purple-600" />
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Modal para Adicionar Contrato */}
        {showAddForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
              <h3 className="text-xl font-bold text-institutional-blue mb-4">
                Adicionar Novo Amigo
              </h3>
              
              <form onSubmit={handleAddContract} className="space-y-4">
                {/* Seleção do Membro */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Membro Responsável *
                  </label>
                  <select
                    value={contractForm.member_id}
                    onChange={(e) => setContractForm({...contractForm, member_id: e.target.value})}
                    className="w-full p-2 border border-gray-300 rounded-md focus:border-institutional-gold focus:ring-institutional-gold"
                    required
                  >
                    <option value="">Selecione um membro</option>
                    {members.filter(member => canAddMoreContracts(member.id)).map(member => (
                      <option key={member.id} value={member.id}>
                        {member.name} - Status: {member.ranking_status}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Pessoa 1 */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Nome da Pessoa 1 *
                    </label>
                    <Input
                      value={contractForm.couple_name_1}
                      onChange={(e) => setContractForm({...contractForm, couple_name_1: e.target.value})}
                      placeholder="Nome completo"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      WhatsApp da Pessoa 1 *
                    </label>
                    <Input
                      value={contractForm.couple_phone_1}
                      onChange={(e) => setContractForm({...contractForm, couple_phone_1: e.target.value})}
                      placeholder="(62) 99999-9999"
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Instagram da Pessoa 1 *
                  </label>
                  <Input
                    value={contractForm.couple_instagram_1}
                    onChange={(e) => setContractForm({...contractForm, couple_instagram_1: e.target.value})}
                    placeholder="@usuario"
                    required
                  />
                </div>

                {/* Pessoa 2 */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Nome da Pessoa 2 *
                    </label>
                    <Input
                      value={contractForm.couple_name_2}
                      onChange={(e) => setContractForm({...contractForm, couple_name_2: e.target.value})}
                      placeholder="Nome completo"
                      required
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      WhatsApp da Pessoa 2 *
                    </label>
                    <Input
                      value={contractForm.couple_phone_2}
                      onChange={(e) => setContractForm({...contractForm, couple_phone_2: e.target.value})}
                      placeholder="(62) 99999-9999"
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Instagram da Pessoa 2 *
                  </label>
                  <Input
                    value={contractForm.couple_instagram_2}
                    onChange={(e) => setContractForm({...contractForm, couple_instagram_2: e.target.value})}
                    placeholder="@usuario"
                    required
                  />
                </div>

                <div className="flex gap-3 pt-4">
                  <Button
                    type="submit"
                    className="flex-1 bg-institutional-gold hover:bg-institutional-gold/90 text-institutional-blue"
                  >
                    Adicionar Contrato
                  </Button>
                  <Button
                    type="button"
                    onClick={() => setShowAddForm(false)}
                    variant="outline"
                    className="flex-1"
                  >
                    Cancelar
                  </Button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Filtros */}
        <Card className="shadow-[var(--shadow-card)] mb-8">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-institutional-blue">
              <Filter className="w-5 h-5" />
              Filtros
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  type="text"
                  placeholder="Pesquisar por nome ou Instagram..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
                />
              </div>

              <div className="relative">
                <Phone className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input
                  type="text"
                  placeholder="Pesquisar por telefone..."
                  value={phoneSearchTerm}
                  onChange={(e) => setPhoneSearchTerm(e.target.value)}
                  className="pl-10 border-institutional-light focus:border-institutional-gold focus:ring-institutional-gold"
                />
              </div>

              <div>
                <select
                  value={filterStatus}
                  onChange={(e) => setFilterStatus(e.target.value)}
                  className="w-full p-2 border border-institutional-light rounded-md focus:border-institutional-gold focus:ring-institutional-gold bg-white"
                >
                  <option value="">Todos os Status</option>
                  <option value="Pendente">Pendente</option>
                  <option value="Ativo">Ativo</option>
                  <option value="Completo">Completo</option>
                  <option value="Cancelado">Cancelado</option>
                </select>
              </div>

              <div>
                <select
                  value={filterMember}
                  onChange={(e) => setFilterMember(e.target.value)}
                  className="w-full p-2 border border-institutional-light rounded-md focus:border-institutional-gold focus:ring-institutional-gold bg-white"
                >
                  <option value="">Todos os Membros</option>
                  {members.map(member => (
                    <option key={member.id} value={member.id}>
                      {member.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Tabela de Contratos */}
        <Card className="shadow-[var(--shadow-card)]">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-institutional-blue">
              <Users className="w-5 h-5" />
              Contratos Cadastrados
            </CardTitle>
            <CardDescription>
              Lista de todos os amigos cadastrados no sistema
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full border-collapse">
                <thead>
                  <tr className="border-b border-institutional-light">
                    <th className="text-left py-3 px-4 font-semibold text-institutional-blue">Dupla</th>
                    <th className="text-left py-3 px-4 font-semibold text-institutional-blue">Contatos</th>
                    <th className="text-left py-3 px-4 font-semibold text-institutional-blue">Membro</th>
                    <th className="text-left py-3 px-4 font-semibold text-institutional-blue">Status</th>
                    <th className="text-left py-3 px-4 font-semibold text-institutional-blue">Posts</th>
                    <th className="text-left py-3 px-4 font-semibold text-institutional-blue">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredContracts.map((contract) => (
                    <tr key={contract.id} className="border-b border-institutional-light/50 hover:bg-institutional-light/30 transition-colors">
                      <td className="py-3 px-4">
                        <div>
                          <div className="font-medium text-institutional-blue">{contract.couple_name_1}</div>
                          <div className="text-sm text-gray-600">{contract.couple_name_2}</div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="space-y-1">
                          <div className="flex items-center gap-2">
                            <Phone className="w-4 h-4 text-muted-foreground" />
                            <span className="text-sm">{contract.couple_phone_1}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <Phone className="w-4 h-4 text-muted-foreground" />
                            <span className="text-sm">{contract.couple_phone_2}</span>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div>
                          <div className="text-sm text-institutional-gold font-medium">
                            {contract.member_data?.name || 'N/A'}
                          </div>
                          <div className="text-xs text-gray-500">Membro Responsável</div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <span className="text-lg">{getContractStatusIcon(contract.contract_status)}</span>
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getContractStatusColor(contract.contract_status)}`}>
                            {contract.contract_status}
                          </span>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="space-y-1">
                          <div className="flex items-center gap-2">
                            <Instagram className="w-4 h-4 text-muted-foreground" />
                            <span className="text-sm">{contract.couple_instagram_1}</span>
                            {contract.post_verified_1 ? (
                              <Verified className="w-4 h-4 text-green-600" />
                            ) : (
                              <AlertCircle className="w-4 h-4 text-yellow-600" />
                            )}
                          </div>
                          <div className="flex items-center gap-2">
                            <Instagram className="w-4 h-4 text-muted-foreground" />
                            <span className="text-sm">{contract.couple_instagram_2}</span>
                            {contract.post_verified_2 ? (
                              <Verified className="w-4 h-4 text-green-600" />
                            ) : (
                              <AlertCircle className="w-4 h-4 text-yellow-600" />
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex gap-2">
                          {isAdmin() && (
                            <>
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => {
                                  const postUrl = prompt("Digite a URL do post do Instagram da primeira pessoa:");
                                  if (postUrl) {
                                    handleVerifyPost(contract.id, 1, postUrl);
                                  }
                                }}
                                disabled={contract.post_verified_1}
                              >
                                <Eye className="w-4 h-4" />
                              </Button>
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => {
                                  const postUrl = prompt("Digite a URL do post do Instagram da segunda pessoa:");
                                  if (postUrl) {
                                    handleVerifyPost(contract.id, 2, postUrl);
                                  }
                                }}
                                disabled={contract.post_verified_2}
                              >
                                <Eye className="w-4 h-4" />
                              </Button>
                              <select
                                value={contract.contract_status}
                                onChange={(e) => handleStatusChange(contract.id, e.target.value as any)}
                                className="text-xs border border-gray-300 rounded px-2 py-1"
                              >
                                <option value="Pendente">Pendente</option>
                                <option value="Ativo">Ativo</option>
                                <option value="Completo">Completo</option>
                                <option value="Cancelado">Cancelado</option>
                              </select>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              
              {filteredContracts.length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  <Users className="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
                  <p>Nenhum contrato encontrado com os critérios de pesquisa.</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
