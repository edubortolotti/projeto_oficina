"use client";

import {
  Activity,
  AlertTriangle,
  ArrowDownUp,
  Banknote,
  Building2,
  CheckCircle2,
  Clock3,
  Database,
  Download,
  Eye,
  FileCheck2,
  Gauge,
  History,
  KeyRound,
  LogOut,
  ListChecks,
  Pencil,
  Plus,
  RefreshCw,
  Route,
  Save,
  Search,
  Trash2,
  TimerReset,
  UserCog,
  X,
  Zap,
} from "lucide-react";
import { useEffect, useMemo, useState } from "react";

const tabs = [
  { id: "dashboard", label: "Dashboard", icon: Gauge, permission: "VIEW_DASHBOARD" },
  { id: "consolidacoes", label: "Consolidações", icon: Route, permission: "VIEW_CONSOLIDACOES" },
  { id: "fechamentos", label: "Fechamentos", icon: FileCheck2, permission: "VIEW_FECHAMENTOS" },
  { id: "execucoes", label: "Execuções", icon: History, permission: "VIEW_EXECUCOES" },
  { id: "cnpjs", label: "CNPJs", icon: Building2, permission: "VIEW_CNPJS" },
  { id: "portais", label: "Portais", icon: KeyRound, permission: "VIEW_PORTAIS" },
  { id: "usuarios", label: "Usuários", icon: UserCog, permission: "VIEW_USUARIOS" },
];

const rolePermissions = {
  ADMIN: new Set([
    "VIEW_DASHBOARD",
    "VIEW_CONSOLIDACOES",
    "VIEW_DETALHES_OS",
    "DOWNLOAD_DOCUMENTOS",
    "SYNC_CONFERENCE",
    "RUN_PASSO_1",
    "RUN_PASSO_2",
    "APROVAR_OS",
    "RETORNAR_OS",
    "REVISAR_CNPJ_OS",
    "AJUSTAR_VALORES_OS",
    "REPROCESSAR_OS",
    "FORCAR_PROCESSAMENTO_OS",
    "VIEW_FECHAMENTOS",
    "CANCELAR_FECHAMENTO",
    "VOLTAR_FECHAMENTO_CONSOLIDACAO",
    "VIEW_EXECUCOES",
    "VIEW_CNPJS",
    "MANAGE_CNPJS",
    "VIEW_PORTAIS",
    "MANAGE_PORTAIS",
    "VIEW_USUARIOS",
    "MANAGE_USUARIOS",
  ]),
  CURADOR: new Set([
    "VIEW_DASHBOARD",
    "VIEW_CONSOLIDACOES",
    "VIEW_DETALHES_OS",
    "DOWNLOAD_DOCUMENTOS",
    "APROVAR_OS",
    "RETORNAR_OS",
    "REVISAR_CNPJ_OS",
    "AJUSTAR_VALORES_OS",
    "REPROCESSAR_OS",
    "VIEW_FECHAMENTOS",
    "CANCELAR_FECHAMENTO",
    "VOLTAR_FECHAMENTO_CONSOLIDACAO",
    "VIEW_EXECUCOES",
    "VIEW_CNPJS",
    "MANAGE_CNPJS",
  ]),
  OPERADOR: new Set([
    "VIEW_DASHBOARD",
    "VIEW_CONSOLIDACOES",
    "VIEW_DETALHES_OS",
    "DOWNLOAD_DOCUMENTOS",
    "SYNC_CONFERENCE",
    "RUN_PASSO_1",
    "RUN_PASSO_2",
    "REPROCESSAR_OS",
    "VIEW_FECHAMENTOS",
    "VIEW_EXECUCOES",
  ]),
  LEITURA: new Set([
    "VIEW_DASHBOARD",
    "VIEW_CONSOLIDACOES",
    "VIEW_DETALHES_OS",
    "VIEW_FECHAMENTOS",
    "VIEW_EXECUCOES",
  ]),
};

const statusNames = {
  APROVADA_CONSOLIDACAO: "Aprovadas",
  FALHA_SINCRONIZACAO_NBS_FECHAR_MANUAL: "Valores",
  PENDENTE_BATIMENTO_HUMANO: "Pendentes",
  PENDENTE_COMPLEMENTO_MANUAL: "Manual",
  REPROVADA_CNPJ_INVALIDO: "CNPJ",
  REPROVADA_FALTA_ANEXO: "Anexos",
  REPROVADA_TERMO_INVALIDO: "Termo",
  REPROVADA_VALOR_DIVERGENTE: "Valores",
  ERRO_TECNICO: "Erro tecnico",
  ENCERRADO_MANUALMENTE: "Encerrado Manualmente",
  NAO_PROCESSADO: "Não processado",
  PENDENTE_PASSO_1: "Pendente Passo 1",
  PENDENTE_PASSO_3: "Pendente Passo 3",
};

function useModalDismiss(onClose, disabled = false) {
  useEffect(() => {
    if (disabled) return undefined;
    function handleKeyDown(event) {
      if (event.key === "Escape") onClose?.();
    }
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [disabled, onClose]);

  return (event) => {
    if (!disabled && event.target === event.currentTarget) onClose?.();
  };
}

export default function DashboardPage() {
  const [activeTab, setActiveTab] = useState("dashboard");
  const [consolidacoes, setConsolidacoes] = useState(emptyConsolidacoes());
  const [fechamentos, setFechamentos] = useState(emptyFechamentos());
  const [execucoes, setExecucoes] = useState(emptyExecucoes());
  const [cnpjsSeguradoras, setCnpjsSeguradoras] = useState(emptyCnpjsSeguradoras());
  const [senhasPortais, setSenhasPortais] = useState(emptySenhasPortais());
  const [usuariosSistema, setUsuariosSistema] = useState(emptyUsuariosSistema());
  const [loading, setLoading] = useState(true);
  const [syncingConference, setSyncingConference] = useState(false);
  const [runningPasso1, setRunningPasso1] = useState(false);
  const [syncProgress, setSyncProgress] = useState("");
  const [processingAutomaticClosures, setProcessingAutomaticClosures] = useState(false);
  const [approvingOs, setApprovingOs] = useState("");
  const [reprocessingOs, setReprocessingOs] = useState("");
  const [forcingOs, setForcingOs] = useState("");
  const [returningOs, setReturningOs] = useState("");
  const [reviewingCnpj, setReviewingCnpj] = useState("");
  const [adjustingManualOs, setAdjustingManualOs] = useState("");
  const [cancelingFechamentoOs, setCancelingFechamentoOs] = useState("");
  const [resettingConsolidacaoOs, setResettingConsolidacaoOs] = useState("");
  const [savingCnpj, setSavingCnpj] = useState(false);
  const [savingPortalPassword, setSavingPortalPassword] = useState(false);
  const [savingUser, setSavingUser] = useState(false);
  const [approveModal, setApproveModal] = useState(null);
  const [returnModal, setReturnModal] = useState(null);
  const [cancelFechamentoModal, setCancelFechamentoModal] = useState(null);
  const [resetConsolidacaoModal, setResetConsolidacaoModal] = useState(null);
  const [forceProcessingModal, setForceProcessingModal] = useState(null);
  const [detailModal, setDetailModal] = useState(null);
  const [notice, setNotice] = useState(null);
  const [query, setQuery] = useState("");
  const [currentUser, setCurrentUser] = useState(null);

  function showError(message) {
    setNotice({ tone: "error", title: "Falha na operação", message });
  }

  function showSuccess(message) {
    setNotice({ tone: "success", title: "Sincronização concluída", message });
  }

  async function loadData(user = currentUser) {
    if (!user) {
      setLoading(false);
      return;
    }
    setLoading(true);
    try {
      const [consolidacoesResponse, fechamentosResponse, execucoesResponse, cnpjsResponse, senhasPortaisResponse, usuariosResponse] = await Promise.all([
        canUser(user, "VIEW_CONSOLIDACOES")
          ? fetchJson("/api/dashboard/consolidacoes", { cache: "no-store" }, "Falha ao carregar consolidações.")
          : Promise.resolve(emptyConsolidacoes()),
        canUser(user, "VIEW_FECHAMENTOS")
          ? fetchJson("/api/dashboard/fechamentos", { cache: "no-store" }, "Falha ao carregar fechamentos.")
          : Promise.resolve(emptyFechamentos()),
        canUser(user, "VIEW_EXECUCOES")
          ? fetchJson("/api/dashboard/execucoes", { cache: "no-store" }, "Falha ao carregar execuções.")
          : Promise.resolve(emptyExecucoes()),
        canUser(user, "VIEW_CNPJS")
          ? fetchJson("/api/dashboard/cnpjs-seguradoras", { cache: "no-store" }, "Falha ao carregar CNPJs.")
          : Promise.resolve(emptyCnpjsSeguradoras()),
        canUser(user, "VIEW_PORTAIS")
          ? fetchJson("/api/dashboard/portais-senhas", { cache: "no-store" }, "Falha ao carregar senhas dos portais.")
          : Promise.resolve(emptySenhasPortais()),
        canUser(user, "VIEW_USUARIOS")
          ? fetchJson("/api/dashboard/usuarios", { cache: "no-store" }, "Falha ao carregar usuários.")
          : Promise.resolve(emptyUsuariosSistema()),
      ]);

      setConsolidacoes(consolidacoesResponse);
      setFechamentos(fechamentosResponse);
      setExecucoes(execucoesResponse);
      setCnpjsSeguradoras(cnpjsResponse);
      setSenhasPortais(senhasPortaisResponse);
      setUsuariosSistema(usuariosResponse);
      return {
        consolidacoes: consolidacoesResponse,
        fechamentos: fechamentosResponse,
        execucoes: execucoesResponse,
        cnpjsSeguradoras: cnpjsResponse,
        senhasPortais: senhasPortaisResponse,
        usuariosSistema: usuariosResponse,
      };
    } catch (error) {
      showError(error.message);
      return null;
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    async function init() {
      const user = await loadSession();
      if (user) await loadData(user);
    }
    init();
  }, []);

  async function loadSession() {
    try {
      const response = await fetch("/api/auth/me", { cache: "no-store" });
      if (!response.ok) return null;
      const payload = await response.json();
      const user = payload.user || null;
      setCurrentUser(user);
      return user;
    } catch {
      setCurrentUser(null);
      return null;
    }
  }

  async function logout() {
    await fetch("/api/auth/logout", { method: "POST", cache: "no-store" });
    window.location.href = "/login";
  }

  async function syncConference() {
    setSyncingConference(true);
    setSyncProgress("Sincronizando Conference");
    try {
      const { response, payload } = await fetchJsonWithResponse("/api/dashboard/consolidacoes/sincronizar-conference", {
        method: "POST",
        cache: "no-store",
      }, "Falha ao sincronizar Conference.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao sincronizar Conference.");
      }
      const resultado = payload.resultado || {};
      await loadData();
      const sincronizados = resultado.sincronizados ?? 0;
      const inativadas = resultado.inativadas ?? resultado.removidas ?? 0;
      showSuccess(
        `Sincronização concluída. ${sincronizados} OS(s) sincronizadas e ${inativadas} inativadas na lista ativa.`,
      );
    } catch (error) {
      showError(error.message);
    } finally {
      setSyncingConference(false);
      setSyncProgress("");
    }
  }

  async function runPasso1() {
    setRunningPasso1(true);
    setSyncProgress("Executando Passo 1");
    try {
      const { response, payload } = await fetchJsonWithResponse("/api/dashboard/consolidacoes/executar-passo1", {
        method: "POST",
        cache: "no-store",
      }, "Falha ao executar Passo 1.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao executar Passo 1.");
      }
      const resultado = payload.resultado || {};
      await loadData();
      const analisados = resultado.analisados ?? 0;
      showSuccess(`Passo 1 concluido. Processadas ${analisados} OS(s) da tabela de consolidacoes.`);
    } catch (error) {
      showError(error.message);
    } finally {
      setRunningPasso1(false);
      setSyncProgress("");
    }
  }

  async function approveConsolidacao(os) {
    setApprovingOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/aprovar`, {
        method: "POST",
        cache: "no-store",
      }, "Falha ao aprovar OS.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao aprovar OS.");
      }
      setApproveModal(null);
      await loadData();
    } catch (error) {
      showError(error.message);
    } finally {
      setApprovingOs("");
    }
  }

  async function reprocessConsolidacao(os) {
    setReprocessingOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/reprocessar`, {
        method: "POST",
        cache: "no-store",
      }, "Falha ao reprocessar OS.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao reprocessar OS.");
      }
      await loadData();
    } catch (error) {
      showError(error.message);
    } finally {
      setReprocessingOs("");
    }
  }

  async function forceProcessing(os) {
    setForcingOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(
        `/api/dashboard/consolidacoes/${encodeURIComponent(os)}/forcar-processamento`,
        { method: "POST", cache: "no-store" },
        "Falha ao forcar o processamento da OS.",
      );
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao forcar o processamento da OS.");
      }

      setForceProcessingModal(null);
      await loadData();
      const resultado = payload.resultado || {};
      const statusPasso1 = resultado.passo1?.status_consolidacao || "concluido";
      const passo2Total = resultado.passo2?.total ?? 0;
      const passo3 = resultado.passo3?.ignorado
        ? "Passo 3 nao executado"
        : resultado.passo3?.ok
          ? "Passo 3 executado"
          : "Passo 3 com falha";
      showSuccess(`OS ${os}: Passo 1 ${statusPasso1}; Passo 2 processou ${passo2Total}; ${passo3}.`);
    } catch (error) {
      showError(error.message);
    } finally {
      setForcingOs("");
    }
  }

  async function returnConsolidacao(os, observacao) {
    setReturningOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/voltar`, {
        method: "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ observacao }),
      }, "Falha ao marcar retorno da OS.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao marcar retorno da OS.");
      }
      setReturnModal(null);
      await loadData();
    } catch (error) {
      showError(error.message);
    } finally {
      setReturningOs("");
    }
  }

  async function reviewCnpjConsolidacao(os, aprovado) {
    setReviewingCnpj(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/cnpj`, {
        method: "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ aprovado }),
      }, "Falha ao revisar CNPJ.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao revisar CNPJ.");
      }
      setDetailModal(null);
      await loadData();
    } catch (error) {
      showError(error.message);
    } finally {
      setReviewingCnpj("");
    }
  }

  async function adjustManualField(item, campo) {
    const os = getCodigoConference(item);
    const conference = item?.dadosConference || {};
    const orcamento = getValidation(item, "orcamento")?.dados?.orcamento || {};
    const currentValueByField = {
      cnpj: formatCnpj(orcamento?.dados_faturamento?.cnpj || conference.cnpj_seguradora),
      valor_pecas: formatOptionalMoney(orcamento.valor_pecas),
      valor_servicos: formatOptionalMoney(orcamento.valor_servicos),
      valor_franquia: formatOptionalMoney(orcamento.valor_franquia),
    };
    const labelByField = {
      cnpj: "CNPJ",
      valor_pecas: "valor de peças",
      valor_servicos: "valor de M.O.",
      valor_franquia: "valor de franquia",
    };
    const currentValue = currentValueByField[campo] || "";
    const label = labelByField[campo] || "valor";
    const input = window.prompt(`Informe o novo ${label}:`, currentValue === "-" ? "" : currentValue);
    if (input === null) return;

    const valor = input.trim();
    if (!valor) {
      showError(`Informe o ${label}.`);
      return;
    }

    setAdjustingManualOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/ajustes`, {
        method: "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ campo, valor }),
      }, "Falha ao salvar ajuste manual.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao salvar ajuste manual.");
      }
      const loaded = await loadData();
      const atualizado = findItemByCodigo(loaded, os);
      if (atualizado) setDetailModal(atualizado);
      showSuccess("Ajuste manual salvo.");
    } catch (error) {
      showError(error.message);
    } finally {
      setAdjustingManualOs("");
    }
  }

  async function addManualOccurrence(item) {
    const os = getCodigoConference(item);
    const idInput = window.prompt("Informe o código da ocorrência:", "MANUAL");
    if (idInput === null) return;
    const comentarioInput = window.prompt("Informe o texto da ocorrência:");
    if (comentarioInput === null) return;

    const id = idInput.trim() || "MANUAL";
    const comentario = comentarioInput.trim();
    if (!comentario) {
      showError("Informe o texto da ocorrência.");
      return;
    }

    setAdjustingManualOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/ocorrencias`, {
        method: "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, comentario }),
      }, "Falha ao inserir ocorrência.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao inserir ocorrência.");
      }
      const loaded = await loadData();
      const atualizado = findItemByCodigo(loaded, os);
      if (atualizado) setDetailModal(atualizado);
      showSuccess("Ocorrência inserida.");
    } catch (error) {
      showError(error.message);
    } finally {
      setAdjustingManualOs("");
    }
  }

  async function removeManualOccurrence(item, index) {
    const os = getCodigoConference(item);
    const ocorrencia = getPasso3Occurrences(item)[index];
    const label = ocorrencia?.id ? `${ocorrencia.id} - ${ocorrencia.comentario || ""}` : ocorrencia?.comentario || "esta ocorrência";
    if (!window.confirm(`Remover ${label}?`)) return;

    setAdjustingManualOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/consolidacoes/${encodeURIComponent(os)}/ocorrencias`, {
        method: "DELETE",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ index }),
      }, "Falha ao remover ocorrência.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao remover ocorrência.");
      }
      const loaded = await loadData();
      const atualizado = findItemByCodigo(loaded, os);
      if (atualizado) setDetailModal(atualizado);
      showSuccess("Ocorrência removida.");
    } catch (error) {
      showError(error.message);
    } finally {
      setAdjustingManualOs("");
    }
  }

  async function saveCnpjSeguradora(payload) {
    setSavingCnpj(true);
    try {
      const isUpdate = Boolean(payload.id);
      const { response, payload: result } = await fetchJsonWithResponse("/api/dashboard/cnpjs-seguradoras", {
        method: isUpdate ? "PUT" : "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      }, "Falha ao salvar CNPJ.");
      if (!response.ok || result.ok === false) {
        throw new Error(result.error || "Falha ao salvar CNPJ.");
      }
      await loadData();
      showSuccess("CNPJ da seguradora salvo.");
    } catch (error) {
      showError(error.message);
    } finally {
      setSavingCnpj(false);
    }
  }

  async function deleteCnpjSeguradora(id) {
    setSavingCnpj(true);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/cnpjs-seguradoras?id=${encodeURIComponent(id)}`, {
        method: "DELETE",
        cache: "no-store",
      }, "Falha ao excluir CNPJ.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "Falha ao excluir CNPJ.");
      }
      await loadData();
      showSuccess("Vinculo de CNPJ removido.");
    } catch (error) {
      showError(error.message);
    } finally {
      setSavingCnpj(false);
    }
  }

  async function savePortalPassword(payload) {
    setSavingPortalPassword(true);
    try {
      const isUpdate = Boolean(payload.id);
      const { response, payload: result } = await fetchJsonWithResponse("/api/dashboard/portais-senhas", {
        method: isUpdate ? "PUT" : "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      }, "Falha ao salvar senha do portal.");
      if (!response.ok || result.ok === false) {
        throw new Error(result.error || "Falha ao salvar senha do portal.");
      }
      await loadData();
      showSuccess("Senha do portal salva.");
    } catch (error) {
      showError(error.message);
    } finally {
      setSavingPortalPassword(false);
    }
  }

  async function deletePortalPassword(id) {
    setSavingPortalPassword(true);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/portais-senhas?id=${encodeURIComponent(id)}`, {
        method: "DELETE",
        cache: "no-store",
      }, "Falha ao excluir senha do portal.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "Falha ao excluir senha do portal.");
      }
      await loadData();
      showSuccess("Senha do portal removida.");
    } catch (error) {
      showError(error.message);
    } finally {
      setSavingPortalPassword(false);
    }
  }

  async function saveSystemUser(payload) {
    setSavingUser(true);
    try {
      const isUpdate = Boolean(payload.id);
      const { response, payload: result } = await fetchJsonWithResponse("/api/dashboard/usuarios", {
        method: isUpdate ? "PUT" : "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      }, "Falha ao salvar usuário.");
      if (!response.ok || result.ok === false) {
        throw new Error(result.error || "Falha ao salvar usuário.");
      }
      await loadData();
      showSuccess("Usuário salvo.");
    } catch (error) {
      showError(error.message);
    } finally {
      setSavingUser(false);
    }
  }

  async function deleteSystemUser(id) {
    setSavingUser(true);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/usuarios?id=${encodeURIComponent(id)}`, {
        method: "DELETE",
        cache: "no-store",
      }, "Falha ao excluir usuário.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "Falha ao excluir usuário.");
      }
      await loadData();
      showSuccess("Usuário removido.");
    } catch (error) {
      showError(error.message);
    } finally {
      setSavingUser(false);
    }
  }

  async function cancelFechamentoAction(os) {
    setCancelingFechamentoOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/fechamentos/${encodeURIComponent(os)}/cancelar`, {
        method: "POST",
        cache: "no-store",
      }, "Falha ao cancelar ação.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "Falha ao cancelar ação.");
      }
      setCancelFechamentoModal(null);
      await loadData();
      showSuccess("Ação pendente cancelada.");
    } catch (error) {
      showError(error.message);
    } finally {
      setCancelingFechamentoOs("");
    }
  }

  async function resetFechamentoToConsolidacao(os) {
    setResettingConsolidacaoOs(os);
    try {
      const { response, payload } = await fetchJsonWithResponse(`/api/dashboard/fechamentos/${encodeURIComponent(os)}/voltar-consolidacao`, {
        method: "POST",
        cache: "no-store",
      }, "Falha ao voltar OS para consolidação.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "Falha ao voltar OS para consolidação.");
      }
      setResetConsolidacaoModal(null);
      await loadData();
      showSuccess("OS voltou para a fila de consolidação.");
    } catch (error) {
      showError(error.message);
    } finally {
      setResettingConsolidacaoOs("");
    }
  }

  const filteredConsolidacoes = useMemo(() => {
    const pendentes = (consolidacoes.items || []).filter(isConsolidacaoAguardandoCurador);
    return filterItems(pendentes, query, [
      "osObjeto",
      "codigoConference",
      "os",
      "execucaoId",
      "seguradora",
      "empresa",
      "empresaNome",
      "placa",
      "chassi",
      "status",
      "batimentoBusca",
    ]);
  }, [consolidacoes.items, query]);

  const automaticConsolidacoes = useMemo(() => {
    return filteredConsolidacoes.filter(isConsolidacaoAutomatica);
  }, [filteredConsolidacoes]);

  async function processAutomaticClosures() {
    setProcessingAutomaticClosures(true);
    try {
      const { response, payload } = await fetchJsonWithResponse("/api/dashboard/consolidacoes/fechamento-automatico", {
        method: "POST",
        cache: "no-store",
      }, "Falha ao aprovar/reprovar automaticamente.");
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || payload.detail || "Falha ao aprovar/reprovar automaticamente.");
      }
      await loadData();
      const total = payload.resultado?.total ?? 0;
      showSuccess(`Passo 2 preparou ${total} OS(s) para o Passo 3.`);
    } catch (error) {
      showError(error.message);
    } finally {
      setProcessingAutomaticClosures(false);
    }
  }

  const filteredFechamentos = useMemo(() => {
    return filterItems(fechamentos.items, query, [
      "osObjeto",
      "codigoConference",
      "os",
      "decisao",
      "status",
      "erro",
      "seguradora",
      "empresa",
      "empresaNome",
      "placa",
      "chassi",
    ]);
  }, [fechamentos.items, query]);

  const filteredExecucoes = useMemo(() => {
    return filterItems(execucoes.items, query, [
      "os",
      "codigoConference",
      "seguradora",
      "empresa",
      "placa",
      "chassi",
      "status",
      "statusOperacional",
      "acao",
    ]);
  }, [execucoes.items, query]);

  const filteredCnpjs = useMemo(() => {
    return filterItems(cnpjsSeguradoras.items, query, [
      "empresaCodigo",
      "empresaNome",
      "empresaCnpj",
      "seguradoraCodigo",
      "seguradoraNome",
      "cnpj",
      "grupo",
    ]);
  }, [cnpjsSeguradoras.items, query]);

  const filteredPortalPasswords = useMemo(() => {
    return filterItems(senhasPortais.items, query, [
      "portalNome",
      "portalUrl",
      "usuario",
      "seguradoraCodigo",
      "seguradoraNome",
      "observacao",
    ]);
  }, [senhasPortais.items, query]);

  const filteredUsers = useMemo(() => {
    return filterItems(usuariosSistema.items, query, [
      "nome",
      "email",
      "login",
      "perfil",
      "dominio",
    ]);
  }, [usuariosSistema.items, query]);

  const visibleTabs = useMemo(() => {
    return tabs.filter((tab) => canUser(currentUser, tab.permission));
  }, [currentUser]);

  useEffect(() => {
    if (!currentUser || visibleTabs.some((tab) => tab.id === activeTab)) return;
    setActiveTab(visibleTabs[0]?.id || "dashboard");
  }, [activeTab, currentUser, visibleTabs]);

  return (
    <main className="shell">
      <section className="topbar">
        <div>
          <p className="eyebrow">ATRI RPA</p>
          <h1>Painel operacional</h1>
        </div>
        <div className="topbarActions">
          <div className="searchBox">
            <Search size={18} />
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="OS, seguradora, placa"
            />
          </div>
          {canUser(currentUser, "SYNC_CONFERENCE") && (
            <button
              className="topActionButton"
              disabled={syncingConference || runningPasso1}
              onClick={syncConference}
              type="button"
              title="Sincronizar a lista atual do Conference"
            >
              <Database size={18} />
              {syncingConference ? "Sincronizando" : "Sincronizar"}
            </button>
          )}
          {canUser(currentUser, "RUN_PASSO_1") && (
            <button
              className="topActionButton"
              disabled={syncingConference || runningPasso1}
              onClick={runPasso1}
              type="button"
              title="Executar Passo 1 nas OSs sincronizadas"
            >
              <ListChecks size={18} />
              {runningPasso1 ? "Processando" : "Executar Passo 1"}
            </button>
          )}
          {(syncingConference || runningPasso1) && syncProgress && <span className="syncProgress">{syncProgress}</span>}
          <button className="iconButton" onClick={() => loadData()} type="button" title="Atualizar dados">
            <RefreshCw size={18} className={loading ? "spin" : ""} />
          </button>
          <button
            className="iconButton"
            onClick={logout}
            type="button"
            title={currentUser ? `Sair de ${currentUser.login}` : "Sair"}
          >
            <LogOut size={18} />
          </button>
        </div>
      </section>

      <nav className="tabs" aria-label="Visoes do painel">
        {visibleTabs.map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              className={activeTab === tab.id ? "tab active" : "tab"}
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              type="button"
            >
              <Icon size={18} />
              {tab.label}
            </button>
          );
        })}
      </nav>

      {activeTab === "dashboard" ? (
        <DashboardView data={consolidacoes} />
      ) : activeTab === "consolidacoes" ? (
        <ConsolidacoesView
          approvingOs={approvingOs}
          canApprove={canUser(currentUser, "APROVAR_OS")}
          canDownloadDocuments={canUser(currentUser, "DOWNLOAD_DOCUMENTOS")}
          canForceProcessing={canUser(currentUser, "FORCAR_PROCESSAMENTO_OS")}
          canReprocess={canUser(currentUser, "REPROCESSAR_OS")}
          canReturn={canUser(currentUser, "RETORNAR_OS")}
          canRunAutomaticClosures={canUser(currentUser, "RUN_PASSO_2")}
          data={consolidacoes}
          items={filteredConsolidacoes}
          automaticCount={automaticConsolidacoes.length}
          onApprove={setApproveModal}
          onAutomaticClosures={processAutomaticClosures}
          onDetails={setDetailModal}
          onForceProcessing={setForceProcessingModal}
          onReprocess={reprocessConsolidacao}
          onRequestReturn={setReturnModal}
          processingAutomaticClosures={processingAutomaticClosures}
          forcingOs={forcingOs}
          reprocessingOs={reprocessingOs}
          returningOs={returningOs}
        />
      ) : activeTab === "fechamentos" ? (
        <FechamentosView
          canCancel={canUser(currentUser, "CANCELAR_FECHAMENTO")}
          canDownloadDocuments={canUser(currentUser, "DOWNLOAD_DOCUMENTOS")}
          canResetConsolidacao={canUser(currentUser, "VOLTAR_FECHAMENTO_CONSOLIDACAO")}
          cancelingOs={cancelingFechamentoOs}
          data={fechamentos}
          items={filteredFechamentos}
          onCancel={setCancelFechamentoModal}
          onDetails={setDetailModal}
          onResetConsolidacao={setResetConsolidacaoModal}
          resettingOs={resettingConsolidacaoOs}
        />
      ) : activeTab === "execucoes" ? (
        <ExecucoesView data={execucoes} items={filteredExecucoes} />
      ) : activeTab === "cnpjs" ? (
        <CnpjsSeguradorasView
          canManage={canUser(currentUser, "MANAGE_CNPJS")}
          data={cnpjsSeguradoras}
          items={filteredCnpjs}
          onDelete={deleteCnpjSeguradora}
          onSave={saveCnpjSeguradora}
          saving={savingCnpj}
        />
      ) : activeTab === "portais" ? (
        <PortalPasswordsView
          canManage={canUser(currentUser, "MANAGE_PORTAIS")}
          data={senhasPortais}
          items={filteredPortalPasswords}
          onDelete={deletePortalPassword}
          onSave={savePortalPassword}
          saving={savingPortalPassword}
        />
      ) : (
        <SystemUsersView
          canManage={canUser(currentUser, "MANAGE_USUARIOS")}
          data={usuariosSistema}
          items={filteredUsers}
          onDelete={deleteSystemUser}
          onSave={saveSystemUser}
          saving={savingUser}
        />
      )}
      {approveModal && (
        <ConfirmActionModal
          confirmLabel="Confirmar aprovação"
          icon={CheckCircle2}
          item={approveModal}
          loading={approvingOs === getCodigoConference(approveModal)}
          message="Esta OS entrará na fila de fechamento como aprovada e ficará pendente do Passo 3."
          onClose={() => setApproveModal(null)}
          onConfirm={() => approveConsolidacao(getCodigoConference(approveModal))}
          title="Aprovar OS"
          tone="approve"
        />
      )}
      {returnModal && (
        <ReturnOsModal
          item={returnModal}
          loading={returningOs === getCodigoConference(returnModal)}
          onClose={() => setReturnModal(null)}
          onSubmit={(observacao) => returnConsolidacao(getCodigoConference(returnModal), observacao)}
        />
      )}
      {cancelFechamentoModal && (
        <ConfirmActionModal
          confirmLabel="Cancelar ação"
          icon={X}
          item={cancelFechamentoModal}
          loading={cancelingFechamentoOs === getCodigoConference(cancelFechamentoModal)}
          message="Esta ação será removida da fila do Passo 3. Se a OS continuar elegível após a próxima sincronização, ela poderá entrar novamente na fila."
          onClose={() => setCancelFechamentoModal(null)}
          onConfirm={() => cancelFechamentoAction(getCodigoConference(cancelFechamentoModal))}
          title="Cancelar ação pendente"
          tone="danger"
        />
      )}
      {resetConsolidacaoModal && (
        <ConfirmActionModal
          confirmLabel="Voltar para consolidação"
          icon={TimerReset}
          item={resetConsolidacaoModal}
          loading={resettingConsolidacaoOs === getCodigoConference(resetConsolidacaoModal)}
          message="Esta OS será removida das pendências do Passo 3 e voltará para o Passo 1 como não processada. Fechamentos já executados permanecem no histórico."
          onClose={() => setResetConsolidacaoModal(null)}
          onConfirm={() => resetFechamentoToConsolidacao(getCodigoConference(resetConsolidacaoModal))}
          title="Voltar para consolidação"
          tone="danger"
        />
      )}
      {forceProcessingModal && (
        <ConfirmActionModal
          confirmLabel="Forcar processamento"
          icon={Zap}
          item={forceProcessingModal}
          loading={forcingOs === getCodigoConference(forceProcessingModal)}
          message="Esta acao ignorara o bloqueio de complemento manual nesta execucao, relera os documentos e executara os Passos 1, 2 e 3 quando a OS estiver elegivel. O Passo 3 pode alterar o Conference."
          onClose={() => setForceProcessingModal(null)}
          onConfirm={() => forceProcessing(getCodigoConference(forceProcessingModal))}
          title="Forcar processamento da OS"
          tone="danger"
        />
      )}
      {detailModal && (
        <OsDetailModal
          adjustingManual={adjustingManualOs === getCodigoConference(detailModal)}
          canDownloadDocuments={canUser(currentUser, "DOWNLOAD_DOCUMENTOS")}
          canAdjustValues={canUser(currentUser, "AJUSTAR_VALORES_OS")}
          canReviewCnpj={canUser(currentUser, "REVISAR_CNPJ_OS")}
          item={detailModal}
          loadingCnpj={reviewingCnpj === getCodigoConference(detailModal)}
          onAdjustCnpj={() => adjustManualField(detailModal, "cnpj")}
          onAdjustFranquia={() => adjustManualField(detailModal, "valor_franquia")}
          onAdjustMo={() => adjustManualField(detailModal, "valor_servicos")}
          onAdjustPecas={() => adjustManualField(detailModal, "valor_pecas")}
          onAddOccurrence={() => addManualOccurrence(detailModal)}
          onClose={() => setDetailModal(null)}
          onRemoveOccurrence={(index) => removeManualOccurrence(detailModal, index)}
          onReviewCnpj={(aprovado) => reviewCnpjConsolidacao(getCodigoConference(detailModal), aprovado)}
        />
      )}
      {notice && <NoticeModal notice={notice} onClose={() => setNotice(null)} />}
    </main>
  );
}

function DashboardView({ data }) {
  const totals = data.totals || {};
  const maxStatus = Math.max(...(data.byStatus || []).map((item) => item.value), 1);

  return (
    <div className="viewStack">
      <section className="metricGrid">
        <MetricCard label="Valor consolidado" value={formatMoney(totals.valorTotal)} icon={Banknote} tone="green" className="valueMetric" />
        <MetricCard label="Analisadas pelo robô" value={formatNumber(totals.total)} icon={Gauge} tone="teal" />
        <MetricCard label="Aguardando curadoria" value={formatNumber(totals.aguardandoCuradoria)} icon={Clock3} tone="amber" />
        <MetricCard label="Automáticos" value={formatNumber(totals.automaticos)} icon={Activity} tone="teal" />
        <MetricCard label="Aprovadas pelo curador" value={formatNumber(totals.curadorAprovadas)} icon={CheckCircle2} tone="gray" />
      </section>

      <section className="dashboardGrid">
        <Panel title="Regua de tempo" icon={Activity} className="wide">
          <Timeline data={data.timeline} valueKey="valor" />
        </Panel>

        <Panel title="Fluxo de status" icon={Gauge}>
          <div className="barList">
            {(data.byStatus || []).map((status) => (
              <div className="barRow" key={status.key}>
                <div className="barHeader">
                  <span>{statusNames[status.key] || status.key}</span>
                  <strong>{formatNumber(status.value)}</strong>
                </div>
                <div className="barTrack">
                  <span className={`barFill ${statusClass(status.key)}`} style={{ width: `${(status.value / maxStatus) * 100}%` }} />
                </div>
              </div>
            ))}
          </div>
        </Panel>

        <Panel title="Seguradoras" icon={Database}>
          <div className="rankList">
            {(data.bySeguradora || []).map((item) => (
              <div className="rankRow" key={item.key}>
                <span>{item.key}</span>
                <strong>{formatNumber(item.value)}</strong>
              </div>
            ))}
          </div>
        </Panel>

        <Panel title="Validações" icon={ListChecks}>
          <div className="validationGrid">
            {(data.byValidation || []).slice(0, 12).map((item) => {
              const [name, status] = item.key.split(":");
              return (
                <div className="validationCell" key={item.key}>
                  <span>{name}</span>
                  <strong className={statusClass(status)}>{status}</strong>
                  <em>{formatNumber(item.value)}</em>
                </div>
              );
            })}
          </div>
        </Panel>
      </section>

      <DataWarning data={data} />
    </div>
  );
}

function ConsolidacoesView({
  approvingOs,
  automaticCount,
  canApprove,
  canDownloadDocuments,
  canForceProcessing,
  canReprocess,
  canReturn,
  canRunAutomaticClosures,
  data,
  items,
  onApprove,
  onAutomaticClosures,
  onDetails,
  onForceProcessing,
  onReprocess,
  onRequestReturn,
  processingAutomaticClosures,
  forcingOs,
  reprocessingOs,
  returningOs,
}) {
  return (
    <div className="viewStack">
      <Panel
        title={<ConsolidacoesPanelTitle data={data} />}
        icon={ArrowDownUp}
        className="tablePanel"
        actions={canRunAutomaticClosures ? (
          <button
            className="topActionButton"
            disabled={!automaticCount || processingAutomaticClosures}
            onClick={onAutomaticClosures}
            type="button"
            title="Mover OSs aprovadas e reprovadas automaticamente para fechamentos"
          >
            <CheckCircle2 size={18} />
            {processingAutomaticClosures ? "Processando" : `Aprovar/Reprovar (${automaticCount})`}
          </button>
        ) : null}
      >
        <div className="tableWrap">
          <table className="curationTable">
            <thead>
              <tr>
                <th>OS</th>
                <th>Empresa</th>
                <th>Seguradora</th>
                <th>Status</th>
                <th>Regras</th>
                <th>Batimento</th>
                <th>M.O.</th>
                <th>Total</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {items.slice(0, 80).map((item) => {
                const codigoConference = getCodigoConference(item);
                const pendentePasso1 = item.status === "PENDENTE_PASSO_1" || item.status === "NAO_PROCESSADO";
                return (
                  <tr key={item.id}>
                    <td>
                      <div className="osCell">
                        <strong>{getDisplayOs(item)}</strong>
                        {isAllRisk(item) && <span className="allRiskBadge">All Risk</span>}
                      </div>
                    </td>
                    <td>{formatEmpresa(item)}</td>
                    <td>{item.seguradora}</td>
                    <td>
                      <StatusPill status={item.status} />
                    </td>
                    <td>
                      <ValidationSummary item={item} />
                    </td>
                    <td>
                      <BalanceValue item={item} />
                    </td>
                    <td>{formatMoney(getValorServicos(item))}</td>
                    <td>{formatMoney(getValorTotal(item))}</td>
                    <td>
                      <div className="actionStack">
                        {canApprove && (
                          <button
                            className="approveButton"
                            disabled={pendentePasso1 || approvingOs === codigoConference || reprocessingOs === codigoConference || returningOs === codigoConference}
                            onClick={() => onApprove(item)}
                            title={pendentePasso1 ? "Execute o Passo 1 antes de aprovar" : approvingOs === codigoConference ? "Aprovando" : "Aprovar"}
                            type="button"
                            aria-label={approvingOs === codigoConference ? "Aprovando OS" : "Aprovar OS"}
                          >
                            <CheckCircle2 size={16} />
                          </button>
                        )}
                        <button
                          className="detailButton"
                          disabled={approvingOs === codigoConference || reprocessingOs === codigoConference || returningOs === codigoConference}
                          onClick={() => onDetails(item)}
                          title="Detalhes"
                          type="button"
                          aria-label="Ver detalhes da OS"
                        >
                          <Eye size={16} />
                        </button>
                        {canReprocess && (
                          <button
                            className="reprocessButton"
                            disabled={approvingOs === codigoConference || reprocessingOs === codigoConference || returningOs === codigoConference}
                            onClick={() => onReprocess(codigoConference)}
                            title={reprocessingOs === codigoConference ? "Rodando" : "Reprocessar"}
                            type="button"
                            aria-label={reprocessingOs === codigoConference ? "Reprocessando OS" : "Reprocessar OS"}
                          >
                            <RefreshCw size={16} className={reprocessingOs === codigoConference ? "spin" : ""} />
                          </button>
                        )}
                        {canForceProcessing && (
                          <button
                            className="returnButton"
                            disabled={approvingOs === codigoConference || reprocessingOs === codigoConference || forcingOs === codigoConference || returningOs === codigoConference}
                            onClick={() => onForceProcessing(item)}
                            title={forcingOs === codigoConference ? "Processando Passos 1, 2 e 3" : "Forcar processamento completo"}
                            type="button"
                            aria-label={forcingOs === codigoConference ? "Forcando processamento da OS" : "Forcar processamento completo da OS"}
                          >
                            <Zap size={16} className={forcingOs === codigoConference ? "spin" : ""} />
                          </button>
                        )}
                        {canReturn && (
                          <button
                            className="returnButton"
                            disabled={pendentePasso1 || approvingOs === codigoConference || reprocessingOs === codigoConference || returningOs === codigoConference}
                            onClick={() => onRequestReturn(item)}
                            title={pendentePasso1 ? "Execute o Passo 1 antes de voltar a OS" : returningOs === codigoConference ? "Gravando" : "Voltar OS"}
                            type="button"
                            aria-label={returningOs === codigoConference ? "Gravando retorno da OS" : "Voltar OS"}
                          >
                            <TimerReset size={16} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {!items.length && <EmptyState />}
        </div>
      </Panel>

      <DataWarning data={data} />
    </div>
  );
}

function ConsolidacoesPanelTitle({ data }) {
  const total = data?.totals?.total || 0;
  const ultimaLeitura = data?.ultimaLeituraConference || data?.updatedAt;

  return (
    <span className="consolidacoesPanelTitle">
      <span>Última leitura no Conference: <strong>{formatDateTime(ultimaLeitura)}</strong></span>
      <span>Total de registros: <strong>{formatNumber(total)}</strong></span>
    </span>
  );
}

function ReturnOsModal({ item, loading, onClose, onSubmit }) {
  const [observacao, setObservacao] = useState("");
  const canSubmit = observacao.trim().length >= 3 && !loading;
  const onBackdropClick = useModalDismiss(onClose, loading);

  return (
    <div className="modalBackdrop" role="presentation" onClick={onBackdropClick}>
      <div className="modalPanel" role="dialog" aria-modal="true" aria-labelledby="return-os-title">
        <div className="modalHeader">
          <div>
            <span className="modalKicker">OS {getDisplayOs(item)}</span>
            <h2 id="return-os-title">Voltar OS</h2>
          </div>
          <button className="modalClose" onClick={onClose} type="button" disabled={loading}>
            x
          </button>
        </div>
        <p className="modalCopy">
          Esta OS entrará na fila de fechamento como retorno para oficina e ficará pendente do Passo 3.
        </p>
        <label className="fieldStack">
          <span>Comentário da ocorrência</span>
          <textarea
            autoFocus
            disabled={loading}
            onChange={(event) => setObservacao(event.target.value)}
            placeholder="Descreva o motivo para retorno da OS"
            rows={5}
            value={observacao}
          />
        </label>
        <div className="modalActions">
          <button className="secondaryButton" onClick={onClose} type="button" disabled={loading}>
            Cancelar
          </button>
          <button className="returnButton modalActionButton" disabled={!canSubmit} onClick={() => onSubmit(observacao)} type="button">
            <TimerReset size={16} />
            {loading ? "Gravando" : "Confirmar retorno"}
          </button>
        </div>
      </div>
    </div>
  );
}

function ConfirmActionModal({ item, loading, onClose, onConfirm, title, message, confirmLabel, icon: Icon, tone }) {
  const buttonClass = tone === "approve" ? "approveButton modalActionButton" : "returnButton modalActionButton";
  const onBackdropClick = useModalDismiss(onClose, loading);

  return (
    <div className="modalBackdrop" role="presentation" onClick={onBackdropClick}>
      <div className="modalPanel" role="dialog" aria-modal="true" aria-labelledby="confirm-action-title">
        <div className="modalHeader">
          <div>
            <span className="modalKicker">OS {getDisplayOs(item)}</span>
            <h2 id="confirm-action-title">{title}</h2>
          </div>
          <button className="modalClose" onClick={onClose} type="button" disabled={loading}>
            x
          </button>
        </div>
        <p className="modalCopy">{message}</p>
        <div className="modalActions">
          <button className="secondaryButton" onClick={onClose} type="button" disabled={loading}>
            Cancelar
          </button>
          <button className={buttonClass} disabled={loading} onClick={onConfirm} type="button">
            <Icon size={16} />
            {loading ? "Confirmando" : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}

function NoticeModal({ notice, onClose }) {
  const Icon = notice.tone === "success" ? CheckCircle2 : AlertTriangle;
  const onBackdropClick = useModalDismiss(onClose);

  return (
    <div className="modalBackdrop" role="presentation" onClick={onBackdropClick}>
      <div className="modalPanel noticePanel" role="alertdialog" aria-modal="true" aria-labelledby="notice-title">
        <div className={`noticeIcon ${notice.tone === "success" ? "success" : "error"}`}>
          <Icon size={20} />
        </div>
        <div className="noticeBody">
          <h2 id="notice-title">{notice.title}</h2>
          <p>{notice.message}</p>
          <div className="modalActions noticeActions">
            <button className="secondaryButton modalActionButton" onClick={onClose} type="button" autoFocus>
              Entendi
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function OsDetailModal({
  adjustingManual = false,
  canAdjustValues = false,
  canDownloadDocuments = true,
  canReviewCnpj = false,
  item,
  loadingCnpj = false,
  onAdjustCnpj,
  onAdjustFranquia,
  onAdjustMo,
  onAdjustPecas,
  onAddOccurrence,
  onClose,
  onRemoveOccurrence,
  onReviewCnpj,
}) {
  const onBackdropClick = useModalDismiss(onClose, adjustingManual || loadingCnpj);
  const codigo = getCodigoConference(item);
  const conference = item?.dadosConference || {};
  const orcamentoValidacao = getValidation(item, "orcamento") || {};
  const cnpjValidacao = getValidation(item, "cnpj") || {};
  const orcamento = orcamentoValidacao?.dados?.orcamento || {};
  const comparisons = (orcamentoValidacao?.dados?.comparacoes || []).filter(isFinancialComparison);
  const downloads = item?.dadosExtraidos?.downloads || {};
  const allRisk = isAllRisk(item);
  const ocorrenciasPasso3 = getPasso3Occurrences(item);
  const storedOccurrencesCount = Array.isArray(item?.dadosExtraidos?.ocorrencias_passo3) ? item.dadosExtraidos.ocorrencias_passo3.length : 0;
  const showTokioCnpjActions = isTokio(item) && (cnpjValidacao?.status || "PENDENTE") === "PENDENTE";
  const showManualAdjustments = canAdjustValues;

  return (
    <div className="modalBackdrop" role="presentation" onClick={onBackdropClick}>
      <div className="modalPanel detailModalPanel" role="dialog" aria-modal="true" aria-labelledby="os-detail-title">
        <div className="modalHeader">
          <div>
            <span className="modalKicker">OS {getDisplayOs(item)} | Código {codigo}</span>
            <h2 id="os-detail-title">
              Detalhe da OS
              {allRisk && <span className="allRiskBadge detailBadge">All Risk</span>}
            </h2>
          </div>
          <button className="modalClose" onClick={onClose} type="button">
            x
          </button>
        </div>

        <div className="detailGrid">
          <section className="detailSection">
            <h3>Documentos</h3>
            <div className="documentActions">
              <DocumentDownloadButton codigo={codigo} enabled={canDownloadDocuments && Boolean(downloads.orcamento_final)} label="Orçamento" tipo="orcamento_final" />
              <DocumentDownloadButton codigo={codigo} enabled={canDownloadDocuments && Boolean(downloads.termo_quitacao)} label="TQ" tipo="termo_quitacao" />
            </div>
          </section>

          <section className="detailSection">
            <h3>Identificação</h3>
            <dl className="detailList">
              <DetailItem label="Empresa" value={formatEmpresa(item) || conference.empresa} />
              <DetailItem label="Seguradora" value={item.seguradora} />
              <DetailItem label="Chassi" value={item.chassi} />
              <DetailItem label="Placa" value={allRisk ? "Sem placa" : item.placa} />
              <DetailItem label="Sinistro" value={conference.sinistro} />
              <DetailItem label="Status" value={formatStatusName(item.statusOperacional || item.statusConsolidacao || item.status)} />
            </dl>
          </section>

          <section className="detailSection">
            <h3>Valores Conference</h3>
            <dl className="detailList">
              <DetailItem label="Peças" value={formatOptionalMoney(conference.valor_pecas)} />
              <DetailItem label="M.O." value={formatOptionalMoney(conference.valor_servicos)} />
              <DetailItem label="Franquia" value={formatOptionalMoney(conference.valor_franquia)} />
              <DetailItem label="Total" value={formatOptionalMoney(conference.valor_total)} />
            </dl>
          </section>

          <section className="detailSection">
            <div className="detailSectionHeader">
              <h3>Valores Orçamento</h3>
              {showManualAdjustments && (
                <div className="manualAdjustActions">
                  <button className="detailButton manualAdjustButton" disabled={adjustingManual} onClick={onAdjustCnpj} title="Ajustar CNPJ" type="button" aria-label="Ajustar CNPJ">
                    <Pencil size={15} />
                    CNPJ
                  </button>
                  <button className="detailButton manualAdjustButton" disabled={adjustingManual} onClick={onAdjustPecas} title="Ajustar valor de peças" type="button" aria-label="Ajustar valor de peças">
                    <Pencil size={15} />
                    Peças
                  </button>
                  <button className="detailButton manualAdjustButton" disabled={adjustingManual} onClick={onAdjustMo} title="Ajustar valor de M.O." type="button" aria-label="Ajustar valor de M.O.">
                    <Pencil size={15} />
                    M.O.
                  </button>
                  <button className="detailButton manualAdjustButton" disabled={adjustingManual} onClick={onAdjustFranquia} title="Ajustar valor da franquia" type="button" aria-label="Ajustar valor da franquia">
                    <Pencil size={15} />
                    Franquia
                  </button>
                </div>
              )}
            </div>
            <dl className="detailList">
              <DetailItem label="Peças" value={formatOptionalMoney(orcamento.valor_pecas)} />
              <DetailItem label="M.O." value={formatOptionalMoney(orcamento.valor_servicos)} />
              <DetailItem label="Franquia efetiva" value={formatOptionalMoney(orcamento.valor_franquia)} />
              <DetailItem label="Franquia lida" value={formatOptionalMoney(orcamento.valor_franquia_extraido)} />
              <DetailItem label="Total" value={formatOptionalMoney(orcamento.valor_total)} />
              <DetailItem label="Data orçamento" value={orcamento.data_orcamento} />
            </dl>
          </section>
        </div>

        <section className="detailSection full">
          <h3>Batimentos</h3>
          <div className="detailTableWrap">
            <table className="detailTable">
              <thead>
                <tr>
                  <th>Campo</th>
                  <th>Conference</th>
                  <th>Valor correto</th>
                  <th>Diferença</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Status CNPJ</td>
                  <td>{formatCnpj(conference.cnpj_seguradora)}</td>
                  <td>{formatCnpj(orcamento?.dados_faturamento?.cnpj)}</td>
                  <td>-</td>
                  <td>
                    <span className={`miniPill ${statusClass(cnpjValidacao?.status || "PENDENTE")}`} title={cnpjValidacao?.mensagem || ""}>
                      {validationLabel(cnpjValidacao)}
                    </span>
                  </td>
                </tr>
                {showTokioCnpjActions && canReviewCnpj && (
                  <tr>
                    <td colSpan={5}>
                      <div className="cnpjReviewActions">
                        <button className="approveButton cnpjReviewButton" disabled={loadingCnpj} onClick={() => onReviewCnpj?.(true)} type="button">
                          <CheckCircle2 size={16} />
                          Aprovar CNPJ
                        </button>
                        <button className="returnButton cnpjReviewButton" disabled={loadingCnpj} onClick={() => onReviewCnpj?.(false)} type="button">
                          <X size={16} />
                          Reprovar CNPJ
                        </button>
                      </div>
                    </td>
                  </tr>
                )}
                {comparisons.map((comparison) => (
                  <tr key={comparison.campo}>
                    <td>{comparisonLabel(comparison.campo)}</td>
                    <td>{formatOptionalMoney(comparison.conference)}</td>
                    <td>{formatOptionalMoney(comparison.orcamento)}</td>
                    <td>{formatSignedOptionalMoney(comparison.diferenca || 0)}</td>
                    <td>
                      <span className={`miniPill ${comparison.confere ? "ok" : "bad"}`}>{comparison.confere ? "OK" : "Reprovado"}</span>
                    </td>
                  </tr>
                ))}
                {!comparisons.length && (
                  <tr>
                    <td colSpan={5}>Sem batimentos disponíveis.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </section>

        <section className="detailSection full">
          <h3>Validações</h3>
          <div className="validationStack">
            {Object.entries(item.validacoes || {})
              .filter(([key]) => key !== "sincronizacao_nbs")
              .map(([key, validation]) => (
                <span className={`miniPill ${statusClass(validation?.status || "PENDENTE")}`} key={key} title={validation?.mensagem || ""}>
                  {key}: {validationLabel(validation)}
                </span>
              ))}
          </div>
        </section>

        <section className="detailSection full">
          <div className="detailSectionHeader">
            <h3>Ocorrências Passo 3</h3>
            {canAdjustValues && (
              <button className="detailButton manualAdjustButton" disabled={adjustingManual} onClick={onAddOccurrence} title="Inserir ocorrência manual" type="button" aria-label="Inserir ocorrência manual">
                <Plus size={15} />
                Ocorrência
              </button>
            )}
          </div>
          {ocorrenciasPasso3.length ? (
            <ol className="occurrenceList">
              {ocorrenciasPasso3.map((ocorrencia, index) => (
                <li className={canAdjustValues ? "editableOccurrence" : ""} key={`${ocorrencia.id || "passo3"}-${index}`}>
                  <span>{ocorrencia.id || "Passo 3"}</span>
                  <p>{ocorrencia.comentario}</p>
                  {canAdjustValues && index < storedOccurrencesCount && (
                    <button className="occurrenceDeleteButton" disabled={adjustingManual} onClick={() => onRemoveOccurrence?.(index)} title="Remover ocorrência" type="button" aria-label="Remover ocorrência">
                      <Trash2 size={15} />
                    </button>
                  )}
                </li>
              ))}
            </ol>
          ) : (
            <p className="emptyText">Sem ocorrências previstas para envio.</p>
          )}
        </section>
      </div>
    </div>
  );
}

function DocumentDownloadButton({ codigo, enabled, label, tipo }) {
  const href = `/api/dashboard/consolidacoes/${encodeURIComponent(codigo)}/documentos/${tipo}`;
  return (
    <a
      className={enabled ? "downloadButton" : "downloadButton disabled"}
      href={enabled ? href : undefined}
      rel="noreferrer"
      target="_blank"
    >
      <Download size={16} />
      {label}
    </a>
  );
}

function DetailItem({ label, value }) {
  return (
    <>
      <dt>{label}</dt>
      <dd>{value ?? "-"}</dd>
    </>
  );
}

function FechamentosView({ canCancel, canResetConsolidacao, cancelingOs, data, items, onCancel, onDetails, onResetConsolidacao, resettingOs }) {
  const totals = data.totals || {};

  return (
    <div className="viewStack">
      <section className="metricGrid">
        <MetricCard label="Valor aprovado" value={formatMoney(totals.valorAprovado)} icon={Banknote} tone="green" />
        <MetricCard label="Fechamentos" value={formatNumber(totals.total)} icon={FileCheck2} tone="teal" />
        <MetricCard label="Pendentes" value={formatNumber(totals.pendentes)} icon={Clock3} tone="amber" />
        <MetricCard label="Erros" value={formatNumber(totals.erros)} icon={AlertTriangle} tone="red" />
      </section>

      <section className="dashboardGrid">
        <Panel title="Regua de fechamento" icon={Activity} className="wide">
          <Timeline data={data.timeline} valueKey="valor" />
        </Panel>

        <Panel title="Status fechamento" icon={Gauge}>
          <div className="rankList">
            {(data.byStatus || []).map((item) => (
              <div className="rankRow" key={item.key}>
                <span>{item.key}</span>
                <strong>{formatNumber(item.value)}</strong>
              </div>
            ))}
          </div>
        </Panel>

        <Panel title="Decisoes" icon={ListChecks}>
          <div className="rankList">
            {(data.byDecision || []).map((item) => (
              <div className="rankRow" key={item.key}>
                <span>{item.key}</span>
                <strong>{formatNumber(item.value)}</strong>
              </div>
            ))}
          </div>
        </Panel>
      </section>

      <Panel title="Fila de execucao" icon={ArrowDownUp} className="tablePanel">
        <div className="tableWrap">
          <table>
            <thead>
              <tr>
                <th>OS</th>
                <th>Empresa</th>
                <th>Decisao</th>
                <th>Status</th>
                <th>Valor aprovado</th>
                <th>Ocorrencias</th>
                <th>Anexos</th>
                <th>Atualizado</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {items.slice(0, 100).map((item) => {
                const codigoConference = getCodigoConference(item);
                const canCancelItem = canCancel && item.status === "PENDENTE_PASSO_3";
                const canResetConsolidacaoItem = canResetConsolidacao && item.statusConsolidacao !== "NAO_PROCESSADO";
                return (
                  <tr key={item.id}>
                    <td className="strong">{getDisplayOs(item)}</td>
                    <td>{formatEmpresa(item)}</td>
                    <td>{item.decisao || "-"}</td>
                    <td>
                      <StatusPill status={item.status} />
                    </td>
                    <td>{formatMoney(item.valorAprovado)}</td>
                    <td>{countPayload(item.ocorrencias)}</td>
                    <td>{countPayload(item.anexos)}</td>
                    <td>{formatDate(item.atualizadoEm)}</td>
                    <td>
                      <div className="actionStack">
                        <button
                          className="detailButton"
                          onClick={() => onDetails(item)}
                          title="Detalhes"
                          type="button"
                          aria-label="Ver detalhes da OS"
                        >
                          <Eye size={16} />
                        </button>
                        {canCancelItem && (
                          <button
                            className="returnButton"
                            disabled={cancelingOs === codigoConference}
                            onClick={() => onCancel(item)}
                            title={cancelingOs === codigoConference ? "Cancelando" : "Cancelar ação"}
                            type="button"
                            aria-label="Cancelar ação pendente"
                          >
                            <X size={16} />
                          </button>
                        )}
                        {canResetConsolidacaoItem && (
                          <button
                            className="reprocessButton"
                            disabled={resettingOs === codigoConference}
                            onClick={() => onResetConsolidacao(item)}
                            title={resettingOs === codigoConference ? "Voltando" : "Voltar para consolidação"}
                            type="button"
                            aria-label="Voltar OS para consolidação"
                          >
                            <TimerReset size={16} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
          {!items.length && <EmptyState />}
        </div>
      </Panel>

      <DataWarning data={data} />
    </div>
  );
}

function ExecucoesView({ data, items }) {
  const totals = data.totals || {};

  return (
    <div className="viewStack">
      <section className="metricGrid">
        <MetricCard label="Execuções" value={formatNumber(totals.total)} icon={History} tone="teal" />
        <MetricCard label="Encerradas manualmente" value={formatNumber(totals.encerradasManualmente)} icon={FileCheck2} tone="gray" />
        <MetricCard label="Com erro" value={formatNumber(totals.comErro)} icon={AlertTriangle} tone="red" />
      </section>

      <section className="dashboardGrid">
        <Panel title="Regua de execuções" icon={Activity} className="wide">
          <Timeline data={data.timeline} valueKey="total" />
        </Panel>

        <Panel title="Status operacional" icon={Gauge}>
          <div className="rankList">
            {(data.byStatus || []).map((item) => (
              <div className="rankRow" key={item.key}>
                <span>{statusNames[item.key] || item.key}</span>
                <strong>{formatNumber(item.value)}</strong>
              </div>
            ))}
          </div>
        </Panel>

        <Panel title="Ações" icon={ListChecks}>
          <div className="rankList">
            {(data.byAction || []).map((item) => (
              <div className="rankRow" key={item.key}>
                <span>{compactAction(item.key)}</span>
                <strong>{formatNumber(item.value)}</strong>
              </div>
            ))}
          </div>
        </Panel>
      </section>

      <Panel title="Execuções realizadas" icon={ArrowDownUp} className="tablePanel">
        <div className="tableWrap">
          <table>
            <thead>
              <tr>
                <th>OS</th>
                <th>Código</th>
                <th>Seguradora</th>
                <th>Chassi</th>
                <th>Status</th>
                <th>Status Conference</th>
                <th>Ação</th>
                <th>Finalizado</th>
              </tr>
            </thead>
            <tbody>
              {items.slice(0, 150).map((item) => (
                <tr key={item.id}>
                  <td className="strong">{item.os}</td>
                  <td className="monoValue">{item.codigoConference}</td>
                  <td>{item.seguradora}</td>
                  <td>{item.chassi || "-"}</td>
                  <td>
                    <StatusPill status={item.statusOperacional || item.status} />
                  </td>
                  <td>{formatConferenceStatus(item.conferenceStatus)}</td>
                  <td>{compactAction(item.acao || "-")}</td>
                  <td>{formatDate(item.finalizadoEm)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {!items.length && <EmptyState />}
        </div>
      </Panel>

      <DataWarning data={data} />
    </div>
  );
}

function CnpjsSeguradorasView({ canManage = false, data, items, onDelete, onSave, saving }) {
  const emptyForm = {
    id: "",
    empresaId: "",
    seguradoraId: "",
    cnpj: "",
    grupo: "",
    ativo: true,
  };
  const [form, setForm] = useState(emptyForm);
  const editing = Boolean(form.id);
  const canSave = form.empresaId && form.seguradoraId && onlyDigits(form.cnpj).length === 14 && !saving;

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function resetForm() {
    setForm(emptyForm);
  }

  function editItem(item) {
    setForm({
      id: item.id,
      empresaId: item.empresaId,
      seguradoraId: item.seguradoraId,
      cnpj: formatCnpj(item.cnpj),
      grupo: item.grupo || "",
      ativo: item.ativo,
    });
  }

  async function submitForm(event) {
    event.preventDefault();
    if (!canSave) return;

    await onSave({
      id: form.id || undefined,
      empresaId: form.empresaId,
      seguradoraId: form.seguradoraId,
      cnpj: form.cnpj,
      grupo: form.grupo,
      ativo: form.ativo,
    });
    resetForm();
  }

  return (
    <div className="viewStack">
      <section className="metricGrid">
        <MetricCard label="Regras CNPJ" value={formatNumber(data.items?.length)} icon={Building2} tone="teal" />
        <MetricCard label="Ativas" value={formatNumber((data.items || []).filter((item) => item.ativo).length)} icon={CheckCircle2} tone="green" />
        <MetricCard label="Empresas" value={formatNumber(data.empresas?.length)} icon={Database} tone="gray" />
        <MetricCard label="Seguradoras" value={formatNumber(data.seguradoras?.length)} icon={ListChecks} tone="amber" />
      </section>

      {canManage && (
        <Panel title={editing ? "Editar CNPJ da seguradora" : "Novo CNPJ da seguradora"} icon={editing ? Pencil : Plus}>
          <form className="cnpjForm" onSubmit={submitForm}>
          <label className="fieldStack">
            <span>Empresa</span>
            <select value={form.empresaId} onChange={(event) => updateField("empresaId", event.target.value)} disabled={saving}>
              <option value="">Selecione</option>
              {(data.empresas || []).map((empresa) => (
                <option key={empresa.id} value={empresa.id}>
                  {empresa.nome || empresa.codigo} {empresa.cnpj ? `- ${formatCnpj(empresa.cnpj)}` : ""}
                </option>
              ))}
            </select>
          </label>

          <label className="fieldStack">
            <span>Seguradora</span>
            <select value={form.seguradoraId} onChange={(event) => updateField("seguradoraId", event.target.value)} disabled={saving}>
              <option value="">Selecione</option>
              {(data.seguradoras || []).map((seguradora) => (
                <option key={seguradora.id} value={seguradora.id}>
                  {seguradora.nome || seguradora.codigo} {seguradora.cnpj ? `- ${formatCnpj(seguradora.cnpj)}` : ""}
                </option>
              ))}
            </select>
          </label>

          <label className="fieldStack">
            <span>CNPJ faturamento</span>
            <input
              disabled={saving}
              inputMode="numeric"
              maxLength={18}
              onChange={(event) => updateField("cnpj", formatCnpjInput(event.target.value))}
              placeholder="00.000.000/0000-00"
              value={form.cnpj}
            />
          </label>

          <label className="fieldStack">
            <span>Grupo</span>
            <input
              disabled={saving}
              maxLength={120}
              onChange={(event) => updateField("grupo", event.target.value)}
              placeholder="Nome operacional do grupo"
              value={form.grupo}
            />
          </label>

          <label className="toggleField">
            <input
              checked={Boolean(form.ativo)}
              disabled={saving}
              onChange={(event) => updateField("ativo", event.target.checked)}
              type="checkbox"
            />
            <span>Ativo</span>
          </label>

          <div className="formActions">
            {editing && (
              <button className="secondaryButton" disabled={saving} onClick={resetForm} type="button">
                <X size={16} />
                Cancelar
              </button>
            )}
            <button className="topActionButton" disabled={!canSave} type="submit">
              <Save size={16} />
              {saving ? "Salvando" : editing ? "Salvar edição" : "Cadastrar"}
            </button>
          </div>
          </form>
        </Panel>
      )}

      <Panel title="CNPJs cadastrados" icon={ArrowDownUp} className="tablePanel">
        <div className="tableWrap">
          <table>
            <thead>
              <tr>
                <th>Empresa</th>
                <th>Seguradora</th>
                <th>CNPJ</th>
                <th>Grupo</th>
                <th>Status</th>
                <th>Atualizado</th>
                {canManage && <th>Ações</th>}
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id}>
                  <td>
                    <strong>{item.empresaNome || item.empresaCodigo}</strong>
                    <span className="subText">{formatCnpj(item.empresaCnpj)}</span>
                  </td>
                  <td>
                    <strong>{item.seguradoraNome || item.seguradoraCodigo}</strong>
                    <span className="subText">{item.seguradoraCodigo}</span>
                  </td>
                  <td className="monoValue">{formatCnpj(item.cnpj)}</td>
                  <td>{item.grupo || "-"}</td>
                  <td>
                    <span className={`miniPill ${item.ativo ? "ok" : "neutral"}`}>{item.ativo ? "Ativo" : "Inativo"}</span>
                  </td>
                  <td>{formatDate(item.atualizadoEm)}</td>
                  {canManage && (
                    <td>
                      <div className="actionStack">
                        <button className="detailButton" disabled={saving} onClick={() => editItem(item)} title="Editar" type="button">
                          <Pencil size={16} />
                        </button>
                        <button className="returnButton" disabled={saving} onClick={() => onDelete(item.id)} title="Excluir vínculo" type="button">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
          {!items.length && <EmptyState />}
        </div>
      </Panel>

      <DataWarning data={data} />
    </div>
  );
}

function PortalPasswordsView({ canManage = false, data, items, onDelete, onSave, saving }) {
  const emptyForm = {
    id: "",
    seguradoraId: "",
    portalNome: "",
    portalUrl: "",
    usuario: "",
    senha: "",
    observacao: "",
    ativo: true,
  };
  const [form, setForm] = useState(emptyForm);
  const editing = Boolean(form.id);
  const canSave = form.portalNome.trim() && form.usuario.trim() && (!editing ? form.senha.trim() : true) && !saving;

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function resetForm() {
    setForm(emptyForm);
  }

  function editItem(item) {
    setForm({
      id: item.id,
      seguradoraId: item.seguradoraId || "",
      portalNome: item.portalNome || "",
      portalUrl: item.portalUrl || "",
      usuario: item.usuario || "",
      senha: "",
      observacao: item.observacao || "",
      ativo: item.ativo,
    });
  }

  async function submitForm(event) {
    event.preventDefault();
    if (!canSave) return;

    await onSave({
      id: form.id || undefined,
      seguradoraId: form.seguradoraId || null,
      portalNome: form.portalNome,
      portalUrl: form.portalUrl,
      usuario: form.usuario,
      senha: form.senha,
      observacao: form.observacao,
      ativo: form.ativo,
    });
    resetForm();
  }

  return (
    <div className="viewStack">
      <section className="metricGrid">
        <MetricCard label="Credenciais" value={formatNumber(data.items?.length)} icon={KeyRound} tone="teal" />
        <MetricCard label="Ativas" value={formatNumber((data.items || []).filter((item) => item.ativo).length)} icon={CheckCircle2} tone="green" />
        <MetricCard label="Com senha" value={formatNumber((data.items || []).filter((item) => item.hasSenha).length)} icon={Save} tone="gray" />
        <MetricCard label="Seguradoras" value={formatNumber(data.seguradoras?.length)} icon={ListChecks} tone="amber" />
      </section>

      {canManage && (
        <Panel title={editing ? "Editar senha do portal" : "Nova senha do portal"} icon={editing ? Pencil : Plus}>
          <form className="cnpjForm" onSubmit={submitForm}>
          <label className="fieldStack">
            <span>Seguradora</span>
            <select value={form.seguradoraId} onChange={(event) => updateField("seguradoraId", event.target.value)} disabled={saving}>
              <option value="">Sem seguradora especifica</option>
              {(data.seguradoras || []).map((seguradora) => (
                <option key={seguradora.id} value={seguradora.id}>
                  {seguradora.nome || seguradora.codigo}
                </option>
              ))}
            </select>
          </label>

          <label className="fieldStack">
            <span>Portal</span>
            <input
              disabled={saving}
              maxLength={120}
              onChange={(event) => updateField("portalNome", event.target.value)}
              placeholder="Nome do portal"
              value={form.portalNome}
            />
          </label>

          <label className="fieldStack">
            <span>URL</span>
            <input
              disabled={saving}
              maxLength={255}
              onChange={(event) => updateField("portalUrl", event.target.value)}
              placeholder="https://..."
              value={form.portalUrl}
            />
          </label>

          <label className="fieldStack">
            <span>Usuário</span>
            <input
              autoComplete="off"
              disabled={saving}
              maxLength={180}
              onChange={(event) => updateField("usuario", event.target.value)}
              placeholder="Login, e-mail ou CPF"
              value={form.usuario}
            />
          </label>

          <label className="fieldStack">
            <span>{editing ? "Nova senha" : "Senha"}</span>
            <input
              autoComplete="new-password"
              disabled={saving}
              onChange={(event) => updateField("senha", event.target.value)}
              placeholder={editing ? "Deixe em branco para manter" : "Senha do portal"}
              type="password"
              value={form.senha}
            />
          </label>

          <label className="fieldStack">
            <span>Observação</span>
            <input
              disabled={saving}
              maxLength={255}
              onChange={(event) => updateField("observacao", event.target.value)}
              placeholder="Perfil, MFA, unidade ou instrução"
              value={form.observacao}
            />
          </label>

          <label className="toggleField">
            <input
              checked={Boolean(form.ativo)}
              disabled={saving}
              onChange={(event) => updateField("ativo", event.target.checked)}
              type="checkbox"
            />
            <span>Ativo</span>
          </label>

          <div className="formActions">
            {editing && (
              <button className="secondaryButton" disabled={saving} onClick={resetForm} type="button">
                <X size={16} />
                Cancelar
              </button>
            )}
            <button className="topActionButton" disabled={!canSave} type="submit">
              <Save size={16} />
              {saving ? "Salvando" : editing ? "Salvar edição" : "Cadastrar"}
            </button>
          </div>
          </form>
        </Panel>
      )}

      <Panel title="Senhas cadastradas" icon={ArrowDownUp} className="tablePanel">
        <div className="tableWrap">
          <table>
            <thead>
              <tr>
                <th>Portal</th>
                <th>Seguradora</th>
                <th>Usuário</th>
                <th>Senha</th>
                <th>Status</th>
                <th>Atualizado</th>
                {canManage && <th>Ações</th>}
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id}>
                  <td>
                    <strong>{item.portalNome}</strong>
                    <span className="subText">{portalCredentialSubtitle(item)}</span>
                    {item.importWarnings?.length > 0 && <span className="subText">{item.importWarnings.join(" | ")}</span>}
                  </td>
                  <td>{item.seguradoraNome || item.seguradoraCodigo || "-"}</td>
                  <td className="monoValue">{item.usuario}</td>
                  <td>
                    <span className={`miniPill ${item.hasSenha ? "ok" : "warn"}`}>{item.hasSenha ? "Cadastrada" : "Ausente"}</span>
                  </td>
                  <td>
                    <span className={`miniPill ${item.ativo ? "ok" : "neutral"}`}>{item.ativo ? "Ativo" : "Inativo"}</span>
                    {item.importWarnings?.length > 0 && <span className="miniPill warn">Aviso</span>}
                  </td>
                  <td>{formatDate(item.atualizadoEm)}</td>
                  {canManage && (
                    <td>
                      <div className="actionStack">
                        <button className="detailButton" disabled={saving} onClick={() => editItem(item)} title="Editar" type="button">
                          <Pencil size={16} />
                        </button>
                        <button className="returnButton" disabled={saving} onClick={() => onDelete(item.id)} title="Excluir senha" type="button">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
          {!items.length && <EmptyState />}
        </div>
      </Panel>

      <DataWarning data={data} />
    </div>
  );
}

function SystemUsersView({ canManage = false, data, items, onDelete, onSave, saving }) {
  const emptyForm = {
    id: "",
    nome: "",
    email: "",
    login: "",
    perfil: "OPERADOR",
    ativo: true,
  };
  const [form, setForm] = useState(emptyForm);
  const editing = Boolean(form.id);
  const canSave = form.nome.trim() && form.login.trim() && form.perfil && !saving;

  function updateField(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function resetForm() {
    setForm(emptyForm);
  }

  function editItem(item) {
    setForm({
      id: item.id,
      nome: item.nome || "",
      email: item.email || "",
      login: item.login || "",
      perfil: item.perfil || "OPERADOR",
      ativo: item.ativo,
    });
  }

  async function submitForm(event) {
    event.preventDefault();
    if (!canSave) return;

    await onSave({
      id: form.id || undefined,
      nome: form.nome,
      email: form.email,
      login: form.login,
      perfil: form.perfil,
      ativo: form.ativo,
    });
    resetForm();
  }

  return (
    <div className="viewStack">
      <section className="metricGrid">
        <MetricCard label="Usuários" value={formatNumber(data.items?.length)} icon={UserCog} tone="teal" />
        <MetricCard label="Ativos" value={formatNumber((data.items || []).filter((item) => item.ativo).length)} icon={CheckCircle2} tone="green" />
        <MetricCard label="AD" value={formatNumber((data.items || []).filter((item) => item.adUsuario).length)} icon={Building2} tone="gray" />
      </section>

      {canManage && (
        <Panel title={editing ? "Editar usuário" : "Novo usuário"} icon={editing ? Pencil : Plus}>
          <form className="cnpjForm" onSubmit={submitForm}>
          <label className="fieldStack">
            <span>Nome</span>
            <input
              disabled={saving}
              maxLength={160}
              onChange={(event) => updateField("nome", event.target.value)}
              placeholder="Nome completo"
              value={form.nome}
            />
          </label>

          <label className="fieldStack">
            <span>Login</span>
            <input
              autoComplete="off"
              disabled={saving}
              maxLength={120}
              onChange={(event) => updateField("login", event.target.value)}
              placeholder="usuario"
              value={form.login}
            />
          </label>

          <label className="fieldStack">
            <span>E-mail</span>
            <input
              disabled={saving}
              maxLength={180}
              onChange={(event) => updateField("email", event.target.value)}
              placeholder="usuario@empresa.com"
              type="email"
              value={form.email}
            />
          </label>

          <label className="fieldStack">
            <span>Perfil</span>
            <select value={form.perfil} onChange={(event) => updateField("perfil", event.target.value)} disabled={saving}>
              <option value="ADMIN">Admin</option>
              <option value="CURADOR">Curador</option>
              <option value="OPERADOR">Operador</option>
              <option value="LEITURA">Leitura</option>
            </select>
          </label>

          <label className="toggleField">
            <input
              checked={Boolean(form.ativo)}
              disabled={saving}
              onChange={(event) => updateField("ativo", event.target.checked)}
              type="checkbox"
            />
            <span>Ativo</span>
          </label>

          <div className="formActions">
            {editing && (
              <button className="secondaryButton" disabled={saving} onClick={resetForm} type="button">
                <X size={16} />
                Cancelar
              </button>
            )}
            <button className="topActionButton" disabled={!canSave} type="submit">
              <Save size={16} />
              {saving ? "Salvando" : editing ? "Salvar edição" : "Cadastrar"}
            </button>
          </div>
          </form>
        </Panel>
      )}

      <Panel title="Usuários cadastrados" icon={ArrowDownUp} className="tablePanel">
        <div className="tableWrap">
          <table>
            <thead>
              <tr>
                <th>Nome</th>
                <th>Login</th>
                <th>Perfil</th>
                <th>Origem</th>
                <th>Status</th>
                <th>Atualizado</th>
                {canManage && <th>Ações</th>}
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id}>
                  <td>
                    <strong>{item.nome}</strong>
                    <span className="subText">{item.email || "-"}</span>
                  </td>
                  <td className="monoValue">{item.login}</td>
                  <td>{item.perfil}</td>
                  <td>
                    <span className={`miniPill ${item.adUsuario ? "ok" : "warn"}`}>{item.adUsuario ? `AD${item.dominio ? ` ${item.dominio}` : ""}` : "Local"}</span>
                  </td>
                  <td>
                    <span className={`miniPill ${item.ativo ? "ok" : "neutral"}`}>{item.ativo ? "Ativo" : "Inativo"}</span>
                  </td>
                  <td>{formatDate(item.atualizadoEm)}</td>
                  {canManage && (
                    <td>
                      <div className="actionStack">
                        <button className="detailButton" disabled={saving} onClick={() => editItem(item)} title="Editar" type="button">
                          <Pencil size={16} />
                        </button>
                        <button className="returnButton" disabled={saving} onClick={() => onDelete(item.id)} title="Excluir usuário" type="button">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
          {!items.length && <EmptyState />}
        </div>
      </Panel>

      <DataWarning data={data} />
    </div>
  );
}

function MetricCard({ label, value, icon: Icon, tone, className = "" }) {
  return (
    <article className={`metricCard ${tone} ${className}`}>
      <div className="metricIcon">
        <Icon size={22} />
      </div>
      <div>
        <span>{label}</span>
        <strong>{value}</strong>
      </div>
    </article>
  );
}

function Panel({ title, icon: Icon, children, className = "", actions = null }) {
  return (
    <section className={`panel ${className}`}>
      <header className="panelHeader">
        <div>
          <Icon size={18} />
          <h2>{title}</h2>
        </div>
        {actions && <div className="panelActions">{actions}</div>}
      </header>
      {children}
    </section>
  );
}

function Timeline({ data, valueKey }) {
  const max = Math.max(...(data || []).map((item) => item[valueKey] || item.total || 0), 1);
  const valueIsMoney = valueKey !== "total";

  return (
    <div className="timeline">
      {(data || []).slice(-18).map((item) => {
        const height = Math.max(8, ((item[valueKey] || item.total || 0) / max) * 100);
        return (
          <div className="timeColumn" key={item.data}>
            <div className="timeBar" style={{ height: `${height}%` }}>
              <span>{valueIsMoney ? formatMoney(item.valor || 0) : formatNumber(item.total || 0)}</span>
            </div>
            <strong>{item.total}</strong>
            <em>{shortDate(item.data)}</em>
          </div>
        );
      })}
      {!data?.length && <EmptyState />}
    </div>
  );
}

function StatusPill({ status }) {
  return <span className={`statusPill ${statusClass(status)}`}>{statusNames[status] || status || "Nao informado"}</span>;
}

function ValidationSummary({ item }) {
  const gates = Object.values(item?.gatesValidacao || {}).filter((gate) => shouldShowGate(item, gate));

  return (
    <div className="validationStack">
      {gates.map((gate) => (
        <span className={`miniPill ${statusClass(gate?.status || "PENDENTE")}`} key={gate.key} title={gate?.mensagem || ""}>
          {gate.label}: {validationLabel(gate)}
        </span>
      ))}
      {!gates.length && <span className="miniPill warn">Regras: Pendente</span>}
    </div>
  );
}

function shouldShowGate(item, gate) {
  const key = gate?.key;
  if (isAllRisk(item)) return [...baseGateKeys, ...allRiskGateKeys].includes(key);
  return baseGateKeys.includes(key);
}

const baseGateKeys = ["cnpj", "orcamento", "valor_franquia", "termo_quitacao"];
const allRiskGateKeys = ["fotos_anexos", "conhecimento_transporte", "nf_fabrica"];

function isAllRisk(item) {
  return !String(item?.placa || item?.dadosConference?.placa || "").trim();
}

function isTokio(item) {
  return normalizeKey(item?.seguradora || item?.dadosConference?.seguradora || "").startsWith("tokio");
}

function BalanceValue({ item }) {
  if (item?.batimentoLabel) {
    return <span className="balanceBadge warn">{item.batimentoLabel}</span>;
  }

  const balance = getBalanceDifference(item);
  if (balance === null) return <span className="mutedValue">Pendente</span>;
  if (Math.abs(balance) <= 0.01) {
    return <span className="balanceBadge ok">Batimento OK</span>;
  }
  return (
    <span className="balanceStack">
      <span className="balanceBadge bad">Reprovado</span>
      <strong>{formatSignedMoney(balance)}</strong>
    </span>
  );
}

function DataWarning({ data }) {
  if (data?.ok !== false) return null;
  return (
    <div className="dataWarning">
      <AlertTriangle size={18} />
      <span>{data.error}</span>
    </div>
  );
}

function EmptyState() {
  return (
    <div className="emptyState">
      <Database size={22} />
      <span>Sem registros</span>
    </div>
  );
}

function emptyConsolidacoes() {
  return {
    ok: true,
    totals: {
      total: 0,
      aprovadas: 0,
      pendentes: 0,
      reprovadas: 0,
      erros: 0,
      naoAnalisadas: 0,
      curadorAprovadas: 0,
      aguardandoCuradoria: 0,
      automaticos: 0,
      valorTotal: 0,
      aprovadoValor: 0,
      pendenteValor: 0,
    },
    timeline: [],
    byStatus: [],
    byAction: [],
    bySeguradora: [],
    byValidation: [],
    items: [],
  };
}

function emptyFechamentos() {
  return {
    ok: true,
    totals: { total: 0, valorAprovado: 0, erros: 0, pendentes: 0 },
    timeline: [],
    byStatus: [],
    byDecision: [],
    items: [],
  };
}

function emptyExecucoes() {
  return {
    ok: true,
    totals: { total: 0, encerradasManualmente: 0, comErro: 0 },
    timeline: [],
    byStatus: [],
    byAction: [],
    items: [],
  };
}

function emptyCnpjsSeguradoras() {
  return {
    ok: true,
    empresas: [],
    seguradoras: [],
    items: [],
  };
}

function emptySenhasPortais() {
  return {
    ok: true,
    seguradoras: [],
    items: [],
  };
}

function emptyUsuariosSistema() {
  return {
    ok: true,
    items: [],
  };
}

function canUser(user, permission) {
  const perfil = String(user?.perfil || "").trim().toUpperCase();
  return Boolean(perfil && rolePermissions[perfil]?.has(permission));
}

function filterItems(items = [], search, keys) {
  const value = search.trim().toLowerCase();
  if (!value) return items;
  return items.filter((item) => keys.some((key) => String(item[key] || "").toLowerCase().includes(value)));
}

function isConsolidacaoAguardandoCurador(item) {
  return !item?.curadoria?.aprovado && !item?.encerradoManualmente;
}

function isConsolidacaoAutomatica(item) {
  if (!isConsolidacaoAguardandoCurador(item)) return false;
  const status = String(item?.statusOperacional || item?.statusConsolidacao || item?.status || "");
  if (isManualStatus(item) || status.includes("PENDENTE")) return false;
  return status === "APROVADA_CONSOLIDACAO" || statusClass(status) === "bad";
}

function isManualStatus(item) {
  const statuses = [item?.statusOperacional, item?.statusConsolidacao, item?.status];
  return statuses.some((status) => String(status || "") === "PENDENTE_COMPLEMENTO_MANUAL");
}

function formatStatusName(status) {
  return statusNames[status] || status || "-";
}

function formatMoney(value) {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
    maximumFractionDigits: 0,
  }).format(Number(value || 0));
}

function formatOptionalMoney(value) {
  if (value === null || value === undefined || value === "") return "-";
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(Number(value || 0));
}

function formatNumber(value) {
  return new Intl.NumberFormat("pt-BR").format(Number(value || 0));
}

function formatCnpj(value) {
  const digits = String(value || "").replace(/\D/g, "");
  if (!digits) return "-";
  if (digits.length !== 14) return value;
  return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}/${digits.slice(8, 12)}-${digits.slice(12)}`;
}

function formatCnpjInput(value) {
  const digits = onlyDigits(value).slice(0, 14);
  if (digits.length <= 2) return digits;
  if (digits.length <= 5) return `${digits.slice(0, 2)}.${digits.slice(2)}`;
  if (digits.length <= 8) return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5)}`;
  if (digits.length <= 12) return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}/${digits.slice(8)}`;
  return `${digits.slice(0, 2)}.${digits.slice(2, 5)}.${digits.slice(5, 8)}/${digits.slice(8, 12)}-${digits.slice(12)}`;
}

function onlyDigits(value) {
  return String(value || "").replace(/\D/g, "");
}

function formatSignedMoney(value) {
  const formatted = formatMoney(value);
  return Number(value || 0) > 0 ? `+${formatted}` : formatted;
}

function formatSignedOptionalMoney(value) {
  const formatted = formatOptionalMoney(value);
  return Number(value || 0) > 0 ? `+${formatted}` : formatted;
}

function formatDate(value) {
  if (!value) return "-";
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(value));
}

function formatDateTime(value) {
  if (!value) return "-";
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).format(new Date(value));
}

function shortDate(value) {
  if (!value || value === "sem-data") return "--";
  return new Intl.DateTimeFormat("pt-BR", {
    day: "2-digit",
    month: "2-digit",
  }).format(new Date(value));
}

function statusClass(status = "") {
  status = String(status || "");
  if (status.includes("ENCERRADO")) return "neutral";
  if (status.includes("REPROVADO") || status.includes("REPROVADA") || status.includes("ERRO")) return "bad";
  if (status.includes("APROVADO") || status.includes("APROVADA") || status.includes("FECHADO")) return "ok";
  if (status.includes("FALHA")) return "bad";
  if (status.includes("MANUAL")) return "warn";
  if (status.includes("PENDENTE")) return "warn";
  if (status.includes("CNPJ")) return "bad";
  return "neutral";
}

function formatConferenceStatus(status) {
  const value = String(status || "").trim();
  if (value === "5") return "Reparo encerrado";
  return value || "-";
}

function compactAction(action = "") {
  return action.replace("ENVIAR_PARA_", "").replace("BATIMENTO_HUMANO", "BATIMENTO").replace("RETORNAR_", "RET.");
}

function getValidation(item, key) {
  return item?.validacoes?.[key] || null;
}

function normalizeKey(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "_");
}

function getRoboValidation(item) {
  const seguradoraKey = normalizeKey(item?.seguradora || "");
  return (
    getValidation(item, `robo_${seguradoraKey}`) ||
    getValidation(item, "robo_seguradora") ||
    getValidation(item, "dados_conference")
  );
}

function validationLabel(validation) {
  if (!validation) return "Pendente";
  if (validation.status === "APROVADO") return "OK";
  return validation.status || "Pendente";
}

function getBalanceDifference(item) {
  if (item?.batimento !== undefined && item?.batimento !== null) return Number(item.batimento);

  const gateDifference = item?.gatesValidacao?.orcamento?.dados?.diferenca;
  if (gateDifference !== undefined && gateDifference !== null) return Number(gateDifference);

  const comparisons = getValidation(item, "orcamento")?.dados?.comparacoes || [];
  const total = comparisons.find((comparison) => comparison.campo === "valor_total");
  if (!total || total.diferenca === undefined || total.diferenca === null) return null;
  return Number(total.diferenca);
}

function comparisonLabel(campo) {
  const labels = {
    valor_servicos: "M.O.",
    valor_total: "Total",
    valor_franquia: "Franquia",
    valor_pecas: "Peças",
  };
  return labels[campo] || campo;
}

function isFinancialComparison(comparison) {
  return ["valor_total", "valor_franquia"].includes(comparison?.campo);
}

function getPasso3Occurrences(item) {
  const ocorrencias = item?.dadosExtraidos?.ocorrencias_passo3 || [];
  if (!item?.curadoria?.aprovado) return ocorrencias;

  const seguradora = item?.dadosConference?.seguradora || item?.seguradora || "seguradora";
  const valorMo = getValorServicos(item);
  const dataOrcamento = getValidation(item, "orcamento")?.dados?.orcamento?.data_orcamento || "data nao informada";
  return [
    ...ocorrencias,
    {
      id: "C19",
      comentario: "OS validada pela curadoria. Autorizada emissão de nota.",
    },
    {
      id: "OBS",
      comentario: `Processo conferido. Faturamento liberado no valor de ${formatOptionalMoney(valorMo)} conforme orçamento final autorizado pela cia em ${dataOrcamento} e consulta efetuada no portal ${seguradora}.`,
    },
  ];
}

function shortExecutionId(value) {
  if (!value) return "-";
  return String(value).slice(0, 8);
}

function getCodigoConference(item) {
  return item?.codigoConference || item?.os || "";
}

function getDisplayOs(item) {
  return item?.osObjeto || item?.dadosConference?.raw?.os || item?.dadosConference?.os || item?.os || "-";
}

function formatEmpresa(item) {
  const codigo = String(item?.empresa || item?.dadosConference?.empresa || "").trim();
  const nome = String(item?.empresaNome || item?.dadosConference?.empresaNome || "").trim();
  if (codigo && nome && codigo !== nome) return `${codigo} - ${nome}`;
  return nome || codigo || "-";
}

function portalCredentialSubtitle(item) {
  if (item?.portalUrl) return item.portalUrl;
  const parts = [
    item?.segmento,
    item?.empresaNome || item?.empresaNomeCadastro,
    formatCnpj(item?.cnpj),
  ].filter((value) => value && value !== "-");
  return parts.length ? parts.join(" | ") : "-";
}

function findItemByCodigo(data, codigo) {
  if (!data) return null;
  const collections = [
    data.consolidacoes?.items,
    data.fechamentos?.items,
    data.execucoes?.items,
  ];
  return collections.flatMap((items) => items || []).find((item) => getCodigoConference(item) === codigo) || null;
}

async function fetchJson(url, options, fallbackMessage) {
  const { payload } = await fetchJsonWithResponse(url, options, fallbackMessage);
  return payload;
}

async function fetchJsonWithResponse(url, options, fallbackMessage) {
  const response = await fetch(url, options);
  const text = await response.text();
  const payload = parseJsonPayload(text, fallbackMessage, response.status);
  return { response, payload };
}

function parseJsonPayload(text, fallbackMessage, status) {
  if (!text) return {};

  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`${fallbackMessage} HTTP ${status}: ${textPreview(text)}`);
  }
}

function textPreview(text) {
  return String(text)
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 180) || "resposta vazia ou invalida";
}

function getValorServicos(item) {
  return (
    getValidation(item, "orcamento")?.dados?.orcamento?.valor_servicos ??
    item?.dadosExtraidos?.orcamento?.valor_servicos ??
    item?.dadosConference?.valor_servicos ??
    item?.dadosExtraidos?.financeiro_conference?.valor_servicos ??
    0
  );
}

function getValorTotal(item) {
  return item?.dadosConference?.valor_total ?? item?.dadosExtraidos?.financeiro_conference?.valor_total ?? item?.valor ?? 0;
}

function countPayload(value) {
  if (!value) return 0;
  if (Array.isArray(value)) return value.length;
  if (typeof value === "object") return Object.keys(value).length;
  return 1;
}
