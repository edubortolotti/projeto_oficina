import os
from typing import Any, Dict, Optional


class DocumentReader:
    def ler_orcamento(
        self,
        arquivo: str,
        seguradora: Optional[str] = None,
        perfil: Optional[str] = None,
    ) -> Optional[Dict[str, Any]]:
        raise NotImplementedError

    def ler_termo_quitacao(self, arquivo: str) -> Optional[Dict[str, Any]]:
        raise NotImplementedError

    def ler_dados_faturamento(self, arquivo: str) -> Optional[Dict[str, Any]]:
        raise NotImplementedError


class GeminiDocumentReader(DocumentReader):
    def ler_orcamento(
        self,
        arquivo: str,
        seguradora: Optional[str] = None,
        perfil: Optional[str] = None,
    ) -> Optional[Dict[str, Any]]:
        from ia.gemini import generate

        return generate(arquivo, seguradora=seguradora, perfil=perfil)

    def ler_termo_quitacao(self, arquivo: str) -> Optional[Dict[str, Any]]:
        from ia.gemini import verificarTQ

        return verificarTQ(arquivo)

    def ler_dados_faturamento(self, arquivo: str) -> Optional[Dict[str, Any]]:
        from ia.gemini import extrair_dados_faturamento

        return extrair_dados_faturamento(arquivo)


class OpenAIDocumentReader(DocumentReader):
    def ler_orcamento(
        self,
        arquivo: str,
        seguradora: Optional[str] = None,
        perfil: Optional[str] = None,
    ) -> Optional[Dict[str, Any]]:
        from ia.openai_document import generate

        return generate(arquivo, seguradora=seguradora, perfil=perfil)

    def ler_termo_quitacao(self, arquivo: str) -> Optional[Dict[str, Any]]:
        from ia.openai_document import verificar_tq

        return verificar_tq(arquivo)

    def ler_dados_faturamento(self, arquivo: str) -> Optional[Dict[str, Any]]:
        from ia.openai_document import extrair_dados_faturamento

        return extrair_dados_faturamento(arquivo)


def build_document_reader(provider: Optional[str] = None) -> DocumentReader:
    provider_name = (provider or os.getenv("DOCUMENT_READER_PROVIDER") or "gemini").strip().lower()
    if provider_name in ("gemini", "google", "vertex", "vertexai"):
        return GeminiDocumentReader()
    if provider_name in ("openai", "gpt"):
        return OpenAIDocumentReader()
    raise ValueError(f"DOCUMENT_READER_PROVIDER invalido: {provider_name}")
