from dataclasses import asdict, dataclass, field
from datetime import datetime
from typing import Any, Dict, List, Optional


@dataclass
class OrdemServico:
    numero: str
    seguradora: str
    dados_api: Dict[str, Any] = field(default_factory=dict)


@dataclass
class Documento:
    tipo: str
    nome: str
    arquivo: Optional[str] = None
    metadados: Dict[str, Any] = field(default_factory=dict)


@dataclass
class DadosConference:
    os: str
    seguradora: str
    codigo: Optional[str] = None
    empresa: Optional[str] = None
    seguradora_codigo: Optional[str] = None
    cnpj_empresa: Optional[str] = None
    cnpj_seguradora: Optional[str] = None
    intermediadora_codigo: Optional[str] = None
    intermediadora: Optional[str] = None
    nota: Optional[str] = None
    data: Optional[str] = None
    serie: Optional[str] = None
    chassi: Optional[str] = None
    placa: Optional[str] = None
    sinistro: Optional[str] = None
    pedido_seguradora: Optional[str] = None
    status: Optional[str] = None
    valor_servicos: Optional[float] = None
    valor_pecas: Optional[float] = None
    valor_total: Optional[float] = None
    valor_franquia: Optional[float] = None
    complemento: Optional[Any] = None
    checklist: Dict[str, Any] = field(default_factory=dict)
    anexos: List[Documento] = field(default_factory=list)
    raw: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ValidacaoResultado:
    item: str
    status: str
    mensagem: str
    dados: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ResultadoConsolidacao:
    os: str
    seguradora: str
    status_consolidacao: str
    acao_sugerida: str
    validacoes: Dict[str, ValidacaoResultado]
    dados_conference: Dict[str, Any] = field(default_factory=dict)
    dados_extraidos: Dict[str, Any] = field(default_factory=dict)
    erros: List[str] = field(default_factory=list)
    criado_em: str = field(default_factory=lambda: datetime.now().isoformat(timespec="seconds"))

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)
