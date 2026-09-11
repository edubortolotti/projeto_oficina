import argparse

from integrations.conference.client import build_conference_client
from repositories.consolidacao_repository import ConsolidacaoRepository
from services.ia.document_reader import build_document_reader
from steps.passo_1_consolidacao.executar import Passo1Consolidacao


def main():
    parser = argparse.ArgumentParser(description="Executa o Passo 1 de consolidacao das OSs.")
    parser.add_argument(
        "--database",
        default="data/consolidacao.db",
        help="Caminho do banco SQLite de consolidacao.",
    )
    args = parser.parse_args()

    passo = Passo1Consolidacao(
        conference_client=build_conference_client(),
        document_reader=build_document_reader(),
        repository=ConsolidacaoRepository(args.database),
    )

    resultados = passo.executar()

    print(f"OSs processadas: {len(resultados)}")
    for resultado in resultados:
        print(f"{resultado.os};{resultado.seguradora};{resultado.status_consolidacao};{resultado.acao_sugerida}")


if __name__ == "__main__":
    main()
